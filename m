From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/3] gre: move iptunnel_pull_header down to ipgre_rcv
Date: Tue,  3 May 2016 17:10:07 +0200
Message-ID: <1182680697edd5cd944aaf81e65facccdeaff127.1462286214.git.jbenc@redhat.com>
References: <cover.1462286214.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, pravin shelar <pshelar@ovn.org>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755635AbcECPKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 11:10:36 -0400
In-Reply-To: <cover.1462286214.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow to make the pull dependent on the tunnel type.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/ip_gre.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 8260a707b9b8..8f377dad5489 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -260,7 +260,8 @@ static __be32 tunnel_id_to_key(__be64 x)
 #endif
 }
 
-static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
+static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
+		     int hdr_len)
 {
 	struct net *net = dev_net(skb->dev);
 	struct metadata_dst *tun_dst = NULL;
@@ -278,6 +279,9 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 				  iph->saddr, iph->daddr, tpi->key);
 
 	if (tunnel) {
+		if (iptunnel_pull_header(skb, hdr_len, tpi->proto, false) < 0)
+			goto drop;
+
 		skb_pop_mac_header(skb);
 		if (tunnel->collect_md) {
 			__be16 flags;
@@ -294,6 +298,10 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 		return PACKET_RCVD;
 	}
 	return PACKET_REJECT;
+
+drop:
+	kfree_skb(skb);
+	return PACKET_RCVD;
 }
 
 static int gre_rcv(struct sk_buff *skb)
@@ -314,10 +322,7 @@ static int gre_rcv(struct sk_buff *skb)
 	if (hdr_len < 0)
 		goto drop;
 
-	if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false))
-		goto drop;
-
-	if (ipgre_rcv(skb, &tpi) == PACKET_RCVD)
+	if (ipgre_rcv(skb, &tpi, hdr_len) == PACKET_RCVD)
 		return 0;
 
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
-- 
1.8.3.1
