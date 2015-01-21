From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] ipv4: try to cache dst_entries which would cause a redirect
Date: Wed, 21 Jan 2015 13:41:27 +0100
Message-ID: <c758eb2d861f2eeb981615c3297b19443d4061d6.1421837207.git.hannes@stressinduktion.org>
Cc: Julian Anastasov <ja@ssi.bg>,
	Marcelo Leitner <mleitner@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:33189 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750754AbbAUMle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:41:34 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 2311720835
	for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 07:41:33 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not caching dst_entries which cause redirects could be exploited by hosts
on the same subnet, causing a severe DoS attack. This effect aggravated
since commit f88649721268999 ("ipv4: fix dst race in sk_dst_get()").

Lookups causing redirects will be allocated with DST_NOCACHE set which
will force dst_release to free them via RCU.  Unfortunately waiting for
RCU grace period just takes too long, we can end up with >1M dst_entries
waiting to be released and the system will run OOM. rcuos threads cannot
catch up under high softirq load.

Attaching the flag to emit a redirect later on to the specific skb allows
us to cache those dst_entries thus reducing the pressure on allocation
and deallocation.

This issue was discovered by Marcelo Leitner.

Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Marcelo Leitner <mleitner@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2:
Julian noticed that v1 did omit the redirect flag in rtnetlink queries,
fixed. Thanks!

 include/net/ip.h      | 11 ++++++-----
 net/ipv4/ip_forward.c |  3 ++-
 net/ipv4/route.c      |  8 ++++----
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0e5a0ba..14211ea 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -39,11 +39,12 @@ struct inet_skb_parm {
 	struct ip_options	opt;		/* Compiled IP options		*/
 	unsigned char		flags;
 
-#define IPSKB_FORWARDED		1
-#define IPSKB_XFRM_TUNNEL_SIZE	2
-#define IPSKB_XFRM_TRANSFORMED	4
-#define IPSKB_FRAG_COMPLETE	8
-#define IPSKB_REROUTED		16
+#define IPSKB_FORWARDED		BIT(0)
+#define IPSKB_XFRM_TUNNEL_SIZE	BIT(1)
+#define IPSKB_XFRM_TRANSFORMED	BIT(2)
+#define IPSKB_FRAG_COMPLETE	BIT(3)
+#define IPSKB_REROUTED		BIT(4)
+#define IPSKB_DOREDIRECT	BIT(5)
 
 	u16			frag_max_size;
 };
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 3a83ce5..787b3c2 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -129,7 +129,8 @@ int ip_forward(struct sk_buff *skb)
 	 *	We now generate an ICMP HOST REDIRECT giving the route
 	 *	we calculated.
 	 */
-	if (rt->rt_flags&RTCF_DOREDIRECT && !opt->srr && !skb_sec_path(skb))
+	if (IPCB(skb)->flags & IPSKB_DOREDIRECT && !opt->srr &&
+	    !skb_sec_path(skb))
 		ip_rt_send_redirect(skb);
 
 	skb->priority = rt_tos2priority(iph->tos);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2000110..868c829 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1568,10 +1568,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	do_cache = res->fi && !itag;
 	if (out_dev == in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
 	    (IN_DEV_SHARED_MEDIA(out_dev) ||
-	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res)))) {
-		flags |= RTCF_DOREDIRECT;
-		do_cache = false;
-	}
+	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
+		IPCB(skb)->flags |= IPSKB_DOREDIRECT;
 
 	if (skb->protocol != htons(ETH_P_IP)) {
 		/* Not IP (i.e. ARP). Do not create route, if it is
@@ -2316,6 +2314,8 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	r->rtm_flags	= (rt->rt_flags & ~0xFFFF) | RTM_F_CLONED;
 	if (rt->rt_flags & RTCF_NOTIFY)
 		r->rtm_flags |= RTM_F_NOTIFY;
+	if (IPCB(skb)->flags & IPSKB_DOREDIRECT)
+		r->rtm_flags |= RTCF_DOREDIRECT;
 
 	if (nla_put_be32(skb, RTA_DST, dst))
 		goto nla_put_failure;
-- 
2.1.0
