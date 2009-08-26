From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 1/3] Revert Backoff [v3]: Rename skb to icmp_skb in tcp_v4_err()
Date: Wed, 26 Aug 2009 12:16:27 +0200
Message-ID: <4A950B7B.4010601@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:38245 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756798AbZHZKQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 06:16:26 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOZ00GTVB7BUDA0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 26 Aug 2009 12:16:27 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n7QAGRMY012855	for
 <netdev@vger.kernel.org>; Wed, 26 Aug 2009 12:16:27 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This supplementary patch renames skb to icmp_skb in tcp_v4_err() in order to
disambiguate from another sk_buff variable, which will be introduced
in a separate patch.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 net/ipv4/tcp_ipv4.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6d88219..6ca1bc8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -328,26 +328,26 @@ static void do_pmtu_discovery(struct sock *sk, struct iphdr *iph, u32 mtu)
  *
  */
 
-void tcp_v4_err(struct sk_buff *skb, u32 info)
+void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 {
-	struct iphdr *iph = (struct iphdr *)skb->data;
-	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
+	struct iphdr *iph = (struct iphdr *)icmp_skb->data;
+	struct tcphdr *th = (struct tcphdr *)(icmp_skb->data + (iph->ihl << 2));
 	struct tcp_sock *tp;
 	struct inet_sock *inet;
-	const int type = icmp_hdr(skb)->type;
-	const int code = icmp_hdr(skb)->code;
+	const int type = icmp_hdr(icmp_skb)->type;
+	const int code = icmp_hdr(icmp_skb)->code;
 	struct sock *sk;
 	__u32 seq;
 	int err;
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(icmp_skb->dev);
 
-	if (skb->len < (iph->ihl << 2) + 8) {
+	if (icmp_skb->len < (iph->ihl << 2) + 8) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
 
 	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
-			iph->saddr, th->source, inet_iif(skb));
+			iph->saddr, th->source, inet_iif(icmp_skb));
 	if (!sk) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
-- 
1.6.3.3

