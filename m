From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Wed, 18 Jul 2012 05:46:06 +0200
Message-ID: <1342583166.2626.1367.camel@edumazet-glaptop>
References: <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg>
	 <20120717.134651.562831385960975623.davem@davemloft.net>
	 <alpine.LFD.2.00.1207180052420.2128@ja.ssi.bg>
	 <20120717.150920.1324071045620152376.davem@davemloft.net>
	 <alpine.LFD.2.00.1207180358190.2128@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:56149 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab2GRDqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 23:46:12 -0400
Received: by vcbfk26 with SMTP id fk26so800486vcb.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 20:46:11 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1207180358190.2128@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 04:06 +0300, Julian Anastasov wrote:

> 
> 	I created patch with seqlock usage. This version
> is with global seqlock because I'm not sure if 2048 locks
> per NH are good idea. This is only compile tested.
> After comments may be I have to resubmit in separate message.
> 
> 
> Subject: [PATCH] ipv4: use seqlock for nh_exceptions
> 
> From: Julian Anastasov <ja@ssi.bg>
> 
> 	Use global seqlock for the nh_exceptions. Call
> fnhe_oldest with the right hash chain. Correct the diff
> value for dst_set_expires.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/net/ip_fib.h |    2 +-
>  net/ipv4/route.c     |  117 ++++++++++++++++++++++++++++++++------------------
>  2 files changed, 76 insertions(+), 43 deletions(-)
> 

...

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index f67e702..e037c73 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1334,8 +1334,9 @@ static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
>  }
>  
>  static DEFINE_SPINLOCK(fnhe_lock);
> +static DEFINE_SEQLOCK(fnhe_seqlock);

Hi Julian

I find this patch too complex.

You could only change fnhe_lock to a seqlock

 net/ipv4/route.c |   35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f67e702..a96fc9d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1333,7 +1333,7 @@ static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 		build_sk_flow_key(fl4, sk);
 }
 
-static DEFINE_SPINLOCK(fnhe_lock);
+static DEFINE_SEQLOCK(fnhe_seqlock);
 
 static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash, __be32 daddr)
 {
@@ -1454,11 +1454,11 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 				struct fib_nh *nh = &FIB_RES_NH(res);
 				struct fib_nh_exception *fnhe;
 
-				spin_lock_bh(&fnhe_lock);
+				write_seqlock_bh(&fnhe_seqlock);
 				fnhe = find_or_create_fnhe(nh, fl4->daddr);
 				if (fnhe)
 					fnhe->fnhe_gw = new_gw;
-				spin_unlock_bh(&fnhe_lock);
+				write_sequnlock_bh(&fnhe_seqlock);
 			}
 			rt->rt_gateway = new_gw;
 			rt->rt_flags |= RTCF_REDIRECTED;
@@ -1665,13 +1665,13 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 		struct fib_nh *nh = &FIB_RES_NH(res);
 		struct fib_nh_exception *fnhe;
 
-		spin_lock_bh(&fnhe_lock);
+		write_seqlock_bh(&fnhe_seqlock);
 		fnhe = find_or_create_fnhe(nh, fl4->daddr);
 		if (fnhe) {
 			fnhe->fnhe_pmtu = mtu;
 			fnhe->fnhe_expires = jiffies + ip_rt_mtu_expires;
 		}
-		spin_unlock_bh(&fnhe_lock);
+		write_sequnlock_bh(&fnhe_seqlock);
 	}
 	rt->rt_pmtu = mtu;
 	dst_set_expires(&rt->dst, ip_rt_mtu_expires);
@@ -1904,18 +1904,29 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
 
 	for (fnhe = rcu_dereference(hash[hval].chain); fnhe;
 	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
-		if (fnhe->fnhe_daddr == daddr) {
-			if (fnhe->fnhe_pmtu) {
-				unsigned long expires = fnhe->fnhe_expires;
-				unsigned long diff = jiffies - expires;
+		unsigned int seq;
+		__be32 fnhe_daddr, gw;
+		u32 pmtu;
+		unsigned long expires;
+
+		do {
+			seq = read_seqbegin(&fnhe_seqlock);
+			fnhe_daddr = fnhe->fnhe_daddr;
+			gw = fnhe->fnhe_gw;
+			pmtu = fnhe->fnhe_pmtu;
+			expires = fnhe->fnhe_expires;
+		} while (read_seqretry(&fnhe_seqlock, seq));
+		if (fnhe_daddr == daddr) {
+			if (pmtu) {
+				unsigned long diff = expires - jiffies;
 
 				if (time_before(jiffies, expires)) {
-					rt->rt_pmtu = fnhe->fnhe_pmtu;
+					rt->rt_pmtu = pmtu;
 					dst_set_expires(&rt->dst, diff);
 				}
 			}
-			if (fnhe->fnhe_gw)
-				rt->rt_gateway = fnhe->fnhe_gw;
+			if (gw)
+				rt->rt_gateway = gw;
 			fnhe->fnhe_stamp = jiffies;
 			break;
 		}
