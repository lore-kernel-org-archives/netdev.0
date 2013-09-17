From: Ansis Atteka <aatteka@nicira.com>
Subject: [PATCH net] ip: generate unique IP identificator if local fragmentation is allowed
Date: Tue, 17 Sep 2013 15:25:00 -0700
Message-ID: <1379456700-8033-1-git-send-email-aatteka@nicira.com>
Cc: Ansis Atteka <aatteka@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:37868 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753301Ab3IQWc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 18:32:57 -0400
Received: by mail-qe0-f49.google.com with SMTP id s14so4128033qeb.8
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 15:32:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If local fragmentation is allowed, then ip_select_ident() and
ip_select_ident_more() need to generate unique IDs to ensure
correct defragmentation on the peer.

For example, if IPsec (tunnel mode) has to encrypt large skbs
that have local_df bit set, then all IP fragments that belonged
to different ESP datagrams would have used the same identificator.
If one of these IP fragments would get lost or reordered, then
peer could possibly stitch together wrong IP fragments that did
not belong to the same datagram. This would lead to a packet loss
or data corruption.

Signed-off-by: Ansis Atteka <aatteka@nicira.com>
---
 drivers/net/ppp/pptp.c          |    2 +-
 include/net/ip.h                |   12 ++++++++----
 net/ipv4/igmp.c                 |    4 ++--
 net/ipv4/inetpeer.c             |    4 ++--
 net/ipv4/ip_output.c            |    7 ++++---
 net/ipv4/ipmr.c                 |    2 +-
 net/ipv4/raw.c                  |    2 +-
 net/ipv4/xfrm4_mode_tunnel.c    |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c |    2 +-
 9 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 6fa5ae0..0180531 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -281,7 +281,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	nf_reset(skb);
 
 	skb->ip_summed = CHECKSUM_NONE;
-	ip_select_ident(iph, &rt->dst, NULL);
+	ip_select_ident(skb, &rt->dst, NULL);
 	ip_send_check(iph);
 
 	ip_local_out(skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index 48f5597..5e52688 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -264,9 +264,11 @@ int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 
 extern void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more);
 
-static inline void ip_select_ident(struct iphdr *iph, struct dst_entry *dst, struct sock *sk)
+static inline void ip_select_ident(struct sk_buff *skb, struct dst_entry *dst, struct sock *sk)
 {
-	if (iph->frag_off & htons(IP_DF)) {
+	struct iphdr *iph = ip_hdr(skb);
+
+	if ((iph->frag_off & htons(IP_DF)) && !skb->local_df) {
 		/* This is only to work around buggy Windows95/2000
 		 * VJ compression implementations.  If the ID field
 		 * does not change, they drop every other packet in
@@ -278,9 +280,11 @@ static inline void ip_select_ident(struct iphdr *iph, struct dst_entry *dst, str
 		__ip_select_ident(iph, dst, 0);
 }
 
-static inline void ip_select_ident_more(struct iphdr *iph, struct dst_entry *dst, struct sock *sk, int more)
+static inline void ip_select_ident_more(struct sk_buff *skb, struct dst_entry *dst, struct sock *sk, int more)
 {
-	if (iph->frag_off & htons(IP_DF)) {
+	struct iphdr *iph = ip_hdr(skb);
+
+	if ((iph->frag_off & htons(IP_DF)) && !skb->local_df) {
 		if (sk && inet_sk(sk)->inet_daddr) {
 			iph->id = htons(inet_sk(sk)->inet_id);
 			inet_sk(sk)->inet_id += 1 + more;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d6c0e64..dace87f 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -369,7 +369,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	pip->saddr    = fl4.saddr;
 	pip->protocol = IPPROTO_IGMP;
 	pip->tot_len  = 0;	/* filled in later */
-	ip_select_ident(pip, &rt->dst, NULL);
+	ip_select_ident(skb, &rt->dst, NULL);
 	((u8 *)&pip[1])[0] = IPOPT_RA;
 	((u8 *)&pip[1])[1] = 4;
 	((u8 *)&pip[1])[2] = 0;
@@ -714,7 +714,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	iph->daddr    = dst;
 	iph->saddr    = fl4.saddr;
 	iph->protocol = IPPROTO_IGMP;
-	ip_select_ident(iph, &rt->dst, NULL);
+	ip_select_ident(skb, &rt->dst, NULL);
 	((u8 *)&iph[1])[0] = IPOPT_RA;
 	((u8 *)&iph[1])[1] = 4;
 	((u8 *)&iph[1])[2] = 0;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 000e3d2..33d5537 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -32,8 +32,8 @@
  *  At the moment of writing this notes identifier of IP packets is generated
  *  to be unpredictable using this code only for packets subjected
  *  (actually or potentially) to defragmentation.  I.e. DF packets less than
- *  PMTU in size uses a constant ID and do not use this code (see
- *  ip_select_ident() in include/net/ip.h).
+ *  PMTU in size when local fragmentation is disabled use a constant ID and do
+ *  not use this code (see ip_select_ident() in include/net/ip.h).
  *
  *  Route cache entries hold references to our nodes.
  *  New cache entries get references via lookup by destination IP address in
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 9ee17e3..f9c4fbb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -148,7 +148,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	iph->daddr    = (opt && opt->opt.srr ? opt->opt.faddr : daddr);
 	iph->saddr    = saddr;
 	iph->protocol = sk->sk_protocol;
-	ip_select_ident(iph, &rt->dst, sk);
+	ip_select_ident(skb, &rt->dst, sk);
 
 	if (opt && opt->opt.optlen) {
 		iph->ihl += opt->opt.optlen>>2;
@@ -386,7 +386,7 @@ packet_routed:
 		ip_options_build(skb, &inet_opt->opt, inet->inet_daddr, rt, 0);
 	}
 
-	ip_select_ident_more(iph, &rt->dst, sk,
+	ip_select_ident_more(skb, &rt->dst, sk,
 			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
 	skb->priority = sk->sk_priority;
@@ -1317,6 +1317,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 		ttl = ip_select_ttl(inet, &rt->dst);
 
 	iph = (struct iphdr *)skb->data;
+
 	iph->version = 4;
 	iph->ihl = 5;
 	iph->tos = inet->tos;
@@ -1324,7 +1325,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	iph->ttl = ttl;
 	iph->protocol = sk->sk_protocol;
 	ip_copy_addrs(iph, fl4);
-	ip_select_ident(iph, &rt->dst, sk);
+	ip_select_ident(skb, &rt->dst, sk);
 
 	if (opt) {
 		iph->ihl += opt->optlen>>2;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9ae54b0..62212c7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1658,7 +1658,7 @@ static void ip_encap(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 	iph->protocol	=	IPPROTO_IPIP;
 	iph->ihl	=	5;
 	iph->tot_len	=	htons(skb->len);
-	ip_select_ident(iph, skb_dst(skb), NULL);
+	ip_select_ident(skb, skb_dst(skb), NULL);
 	ip_send_check(iph);
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index a86c7ae..bfec521 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -387,7 +387,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 		iph->check   = 0;
 		iph->tot_len = htons(length);
 		if (!iph->id)
-			ip_select_ident(iph, &rt->dst, NULL);
+			ip_select_ident(skb, &rt->dst, NULL);
 
 		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 	}
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index eb1dd4d..b5663c3 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -117,7 +117,7 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
 		0 : (XFRM_MODE_SKB_CB(skb)->frag_off & htons(IP_DF));
-	ip_select_ident(top_iph, dst->child, NULL);
+	ip_select_ident(skb, dst->child, NULL);
 
 	top_iph->ttl = ip4_dst_hoplimit(dst->child);
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index b75ff64..c47444e 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -883,7 +883,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->daddr		=	cp->daddr.ip;
 	iph->saddr		=	saddr;
 	iph->ttl		=	old_iph->ttl;
-	ip_select_ident(iph, &rt->dst, NULL);
+	ip_select_ident(skb, &rt->dst, NULL);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
-- 
1.7.9.5
