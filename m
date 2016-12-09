From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 37/50] netfilter: nf_tables: atomic dump and reset for
 stateful objects
Date: Fri, 09 Dec 2016 07:22:06 -0800
Message-ID: <1481296926.4930.171.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
         <1481147576-5690-38-git-send-email-pablo@netfilter.org>
         <CAP=VYLp-ZBFjR1W9=V_vyPYAi1=Yub3ugq6D8hkoLigcPaaxFg@mail.gmail.com>
         <20161209102432.GA986@salvia>
         <1481293492.4930.168.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
        netfilter-devel@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1481293492.4930.168.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-12-09 at 06:24 -0800, Eric Dumazet wrote:

> It looks that you want a seqcount, even on 64bit arches,
> so that CPU 2 can restart its loop, and more importantly you need
> to not accumulate the values you read, because they might be old/invalid.

Untested patch to give general idea. I can polish it a bit later today.

 net/netfilter/nft_counter.c |   59 +++++++++++++---------------------
 1 file changed, 23 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index f6a02c5071c2aeafca7635da3282a809aa04d6ab..57ed95b024473a2aa76298fe5bb5013bf709801b 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -31,18 +31,25 @@ struct nft_counter_percpu_priv {
 	struct nft_counter_percpu __percpu *counter;
 };
 
+static DEFINE_PER_CPU(seqcount_t, nft_counter_seq);
+
 static inline void nft_counter_do_eval(struct nft_counter_percpu_priv *priv,
 				       struct nft_regs *regs,
 				       const struct nft_pktinfo *pkt)
 {
 	struct nft_counter_percpu *this_cpu;
+	seqcount_t *myseq;
 
 	local_bh_disable();
 	this_cpu = this_cpu_ptr(priv->counter);
-	u64_stats_update_begin(&this_cpu->syncp);
+	myseq = this_cpu_ptr(&nft_counter_seq);
+
+	write_seqcount_begin(myseq);
+
 	this_cpu->counter.bytes += pkt->skb->len;
 	this_cpu->counter.packets++;
-	u64_stats_update_end(&this_cpu->syncp);
+
+	write_seqcount_end(myseq);
 	local_bh_enable();
 }
 
@@ -110,52 +117,30 @@ static void nft_counter_fetch(struct nft_counter_percpu __percpu *counter,
 
 	memset(total, 0, sizeof(*total));
 	for_each_possible_cpu(cpu) {
+		seqcount_t *seqp = per_cpu_ptr(&nft_counter_seq, cpu);
+
 		cpu_stats = per_cpu_ptr(counter, cpu);
 		do {
-			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
+			seq	= read_seqcount_begin(seqp);
 			bytes	= cpu_stats->counter.bytes;
 			packets	= cpu_stats->counter.packets;
-		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
+		} while (read_seqcount_retry(seqp, seq));
 
 		total->packets += packets;
 		total->bytes += bytes;
 	}
 }
 
-static u64 __nft_counter_reset(u64 *counter)
-{
-	u64 ret, old;
-
-	do {
-		old = *counter;
-		ret = cmpxchg64(counter, old, 0);
-	} while (ret != old);
-
-	return ret;
-}
-
 static void nft_counter_reset(struct nft_counter_percpu __percpu *counter,
 			      struct nft_counter *total)
 {
 	struct nft_counter_percpu *cpu_stats;
-	u64 bytes, packets;
-	unsigned int seq;
-	int cpu;
 
-	memset(total, 0, sizeof(*total));
-	for_each_possible_cpu(cpu) {
-		bytes = packets = 0;
-
-		cpu_stats = per_cpu_ptr(counter, cpu);
-		do {
-			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
-			packets	+= __nft_counter_reset(&cpu_stats->counter.packets);
-			bytes	+= __nft_counter_reset(&cpu_stats->counter.bytes);
-		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
-
-		total->packets += packets;
-		total->bytes += bytes;
-	}
+	local_bh_disable();
+	cpu_stats = this_cpu_ptr(counter);
+	cpu_stats->counter.packets -= total->packets;
+	cpu_stats->counter.bytes -= total->bytes;
+	local_bh_enable();
 }
 
 static int nft_counter_do_dump(struct sk_buff *skb,
@@ -164,10 +149,9 @@ static int nft_counter_do_dump(struct sk_buff *skb,
 {
 	struct nft_counter total;
 
+	nft_counter_fetch(priv->counter, &total);
 	if (reset)
 		nft_counter_reset(priv->counter, &total);
-	else
-		nft_counter_fetch(priv->counter, &total);
 
 	if (nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes),
 			 NFTA_COUNTER_PAD) ||
@@ -285,7 +269,10 @@ static struct nft_expr_type nft_counter_type __read_mostly = {
 
 static int __init nft_counter_module_init(void)
 {
-	int err;
+	int err, cpu;
+
+	for_each_possible_cpu(cpu)
+		seqcount_init(per_cpu_ptr(&nft_counter_seq, cpu));
 
 	err = nft_register_obj(&nft_counter_obj);
 	if (err < 0)
