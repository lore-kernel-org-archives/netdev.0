From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH 1/7] fou: Get net from sock_net if dev_net unavailable
Date: Mon, 23 May 2016 15:48:20 -0700
Message-ID: <1464043706-2843932-2-git-send-email-tom@herbertland.com>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34569 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751667AbcEWWsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 18:48:45 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4NMkx5x024132
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:43 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2341q73793-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:39 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 7d49ec1a213811e697a70002c9931860-31cbd6d0 for <netdev@vger.kernel.org>;	Mon,
 23 May 2016 15:48:38 -0700
In-Reply-To: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the implementation of Transports over UDP fou and gue build header
may be called before skb->dev is set. This patch checks skb->dev and
if it is not set then tries to get net from sock_net.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/fou.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 5f9207c..96260c6 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -807,13 +807,20 @@ int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		       u8 *protocol, __be16 *sport, int type)
 {
 	int err;
+	struct net *net;
 
 	err = iptunnel_handle_offloads(skb, type);
 	if (err)
 		return err;
 
-	*sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
-						skb, 0, 0, false);
+	if (skb->dev)
+		net = dev_net(skb->dev);
+	else if (skb->sk)
+		net = sock_net(skb->sk);
+	else
+		return -EINVAL;
+
+	*sport = e->sport ? : udp_flow_src_port(net, skb, 0, 0, false);
 
 	return 0;
 }
@@ -845,6 +852,14 @@ int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	void *data;
 	bool need_priv = false;
 	int err;
+	struct net *net;
+
+	if (skb->dev)
+		net = dev_net(skb->dev);
+	else if (skb->sk)
+		net = sock_net(skb->sk);
+	else
+		return -EINVAL;
 
 	if ((e->flags & TUNNEL_ENCAP_FLAG_REMCSUM) &&
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -860,8 +875,7 @@ int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		return err;
 
 	/* Get source port (based on flow hash) before skb_push */
-	*sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
-						skb, 0, 0, false);
+	*sport = e->sport ? : udp_flow_src_port(net, skb, 0, 0, false);
 
 	hdrlen = sizeof(struct guehdr) + optlen;
 
-- 
2.8.0.rc2
