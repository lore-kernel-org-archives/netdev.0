From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v7 net-next 07/16] fou: Split out {fou,gue}_build_header
Date: Wed, 18 May 2016 09:06:15 -0700
Message-ID: <1463587584-2315623-8-git-send-email-tom@herbertland.com>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:63563 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932753AbcERQGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:06:43 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4IG4363016941
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22wypbbc14-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:42 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 820a39aa1d1211e689100002c99293a0-3fbf2c50 for <netdev@vger.kernel.org>;	Wed,
 18 May 2016 09:06:41 -0700
In-Reply-To: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create __fou_build_header and __gue_build_header. These implement the
protocol generic parts of building the fou and gue header.
fou_build_header and gue_build_header implement the IPv4 specific
functions and call the __*_build_header functions.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/fou.h |  8 ++++----
 net/ipv4/fou.c    | 47 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/include/net/fou.h b/include/net/fou.h
index 19b8a0c..7d2fda2 100644
--- a/include/net/fou.h
+++ b/include/net/fou.h
@@ -11,9 +11,9 @@
 size_t fou_encap_hlen(struct ip_tunnel_encap *e);
 static size_t gue_encap_hlen(struct ip_tunnel_encap *e);
 
-int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		     u8 *protocol, struct flowi4 *fl4);
-int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		     u8 *protocol, struct flowi4 *fl4);
+int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		       u8 *protocol, __be16 *sport, int type);
+int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		       u8 *protocol, __be16 *sport, int type);
 
 #endif
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 6cbc725..f4f2ddd 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -780,6 +780,22 @@ static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	*protocol = IPPROTO_UDP;
 }
 
+int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		       u8 *protocol, __be16 *sport, int type)
+{
+	int err;
+
+	err = iptunnel_handle_offloads(skb, type);
+	if (err)
+		return err;
+
+	*sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
+						skb, 0, 0, false);
+
+	return 0;
+}
+EXPORT_SYMBOL(__fou_build_header);
+
 int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		     u8 *protocol, struct flowi4 *fl4)
 {
@@ -788,26 +804,21 @@ int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	__be16 sport;
 	int err;
 
-	err = iptunnel_handle_offloads(skb, type);
+	err = __fou_build_header(skb, e, protocol, &sport, type);
 	if (err)
 		return err;
 
-	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
-					       skb, 0, 0, false);
 	fou_build_udp(skb, e, fl4, protocol, sport);
 
 	return 0;
 }
 EXPORT_SYMBOL(fou_build_header);
 
-int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		     u8 *protocol, struct flowi4 *fl4)
+int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		       u8 *protocol, __be16 *sport, int type)
 {
-	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
-						       SKB_GSO_UDP_TUNNEL;
 	struct guehdr *guehdr;
 	size_t hdrlen, optlen = 0;
-	__be16 sport;
 	void *data;
 	bool need_priv = false;
 	int err;
@@ -826,8 +837,8 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		return err;
 
 	/* Get source port (based on flow hash) before skb_push */
-	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
-					       skb, 0, 0, false);
+	*sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
+						skb, 0, 0, false);
 
 	hdrlen = sizeof(struct guehdr) + optlen;
 
@@ -872,6 +883,22 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	}
 
+	return 0;
+}
+EXPORT_SYMBOL(__gue_build_header);
+
+int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
+		     u8 *protocol, struct flowi4 *fl4)
+{
+	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
+						       SKB_GSO_UDP_TUNNEL;
+	__be16 sport;
+	int err;
+
+	err = __gue_build_header(skb, e, protocol, &sport, type);
+	if (err)
+		return err;
+
 	fou_build_udp(skb, e, fl4, protocol, sport);
 
 	return 0;
-- 
2.8.0.rc2
