From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: nft_counter: rework atomic dump and
 reset
Date: Sat, 10 Dec 2016 15:25:01 +0100
Message-ID: <20161210142501.GA25221@salvia>
References: <1481378741-19871-1-git-send-email-pablo@netfilter.org>
 <20161210141655.GA19963@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57534 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752034AbcLJOZK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Dec 2016 09:25:10 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 548ABD1621
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 15:25:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 43AACDA808
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 15:25:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 295BDDA7F6
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 15:25:06 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20161210141655.GA19963@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 10, 2016 at 03:16:55PM +0100, Pablo Neira Ayuso wrote:
> On Sat, Dec 10, 2016 at 03:05:41PM +0100, Pablo Neira Ayuso wrote:
> [...]
> > -static void nft_counter_reset(struct nft_counter_percpu __percpu *counter,
> > -			      struct nft_counter *total)
> > -{
> > -	struct nft_counter_percpu *cpu_stats;
> > -	u64 bytes, packets;
> > -	unsigned int seq;
> > -	int cpu;
> > -
> > -	memset(total, 0, sizeof(*total));
> > -	for_each_possible_cpu(cpu) {
> > -		bytes = packets = 0;
> > -
> > -		cpu_stats = per_cpu_ptr(counter, cpu);
> > -		do {
> > -			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
> > -			packets	+= __nft_counter_reset(&cpu_stats->counter.packets);
> > -			bytes	+= __nft_counter_reset(&cpu_stats->counter.bytes);
> > -		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
> > -
> > -		total->packets += packets;
> > -		total->bytes += bytes;
> > +			seq	= read_seqcount_begin(myseq);
> > +			bytes	= this_cpu->bytes;
> > +			packets	= this_cpu->packets;
> > +		} while (read_seqcount_retry(myseq, seq));
> > +
> > +		total->bytes	+= bytes;
> > +		total->packets	+= packets;
> > +
> > +		if (reset) {
> > +			local_bh_disable();
> > +			this_cpu->packets -= packets;
> > +			this_cpu->bytes -= bytes;
> > +			local_bh_enable();
> > +		}
> 
> Actually this is not right either, Eric proposed this instead:
> 
> static void nft_counter_reset(struct nft_counter_percpu __percpu *counter,
>                               struct nft_counter *total)
> {
>       struct nft_counter_percpu *cpu_stats;
> 
>       local_bh_disable();
>       cpu_stats = this_cpu_ptr(counter);
>       cpu_stats->counter.packets -= total->packets;
>       cpu_stats->counter.bytes -= total->bytes;
>       local_bh_enable();
> }
> 
> The cpu that running over the reset code is guaranteed to own this
> stats exclusively, but this is not guaranteed by my patch.
> 
> I'm going to send a v2. I think I need to turn packet and byte
> counters into s64, otherwise a sufficient large total->packets may
> underflow and confuse stats.

So my plan is to fold this incremental change on this patch and send a
v2.

diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index c37983d0a141..5647feb43f43 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -18,8 +18,8 @@
 #include <net/netfilter/nf_tables.h>
 
 struct nft_counter {
-       u64             bytes;
-       u64             packets;
+       s64             bytes;
+       s64             packets;
 };
 
 struct nft_counter_percpu_priv {
@@ -102,8 +102,20 @@ static void nft_counter_obj_destroy(struct nft_object *obj)
        nft_counter_do_destroy(priv);
 }
 
+static void nft_counter_reset(struct nft_counter_percpu_priv __percpu *priv,
+                             struct nft_counter *total)
+{
+       struct nft_counter *this_cpu;
+
+       local_bh_disable();
+       this_cpu = this_cpu_ptr(priv->counter);
+       this_cpu->packets -= total->packets;
+       this_cpu->bytes -= total->bytes;
+       local_bh_enable();
+}
+
 static void nft_counter_fetch(struct nft_counter_percpu_priv *priv,
-                             struct nft_counter *total, bool reset)
+                             struct nft_counter *total)
 {
        struct nft_counter *this_cpu;
        const seqcount_t *myseq;
@@ -123,13 +135,6 @@ static void nft_counter_fetch(struct nft_counter_percpu_priv *priv,
 
                total->bytes    += bytes;
                total->packets  += packets;
-
-               if (reset) {
-                       local_bh_disable();
-                       this_cpu->packets -= packets;
-                       this_cpu->bytes -= bytes;
-                       local_bh_enable();
-               }
        }
 }

@@ -139,7 +144,9 @@ static int nft_counter_do_dump(struct sk_buff
*skb,
 {
        struct nft_counter total;
 
-       nft_counter_fetch(priv, &total, reset);
+       nft_counter_fetch(priv, &total);
+       if (reset)
+               nft_counter_reset(priv, &total);
 
        if (nla_put_be64(skb, NFTA_COUNTER_BYTES,
cpu_to_be64(total.bytes),
                         NFTA_COUNTER_PAD) ||
@@ -218,7 +225,7 @@ static int nft_counter_clone(struct nft_expr *dst,
const struct nft_expr *src)
        struct nft_counter *this_cpu;
        struct nft_counter total;
 
-       nft_counter_fetch(priv, &total, false);
+       nft_counter_fetch(priv, &total);
 
        cpu_stats = alloc_percpu_gfp(struct nft_counter, GFP_ATOMIC);
        if (cpu_stats == NULL)
