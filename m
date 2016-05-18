From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v7 net-next 14/16] ip6ip6: Support for GSO/GRO
Date: Wed, 18 May 2016 09:06:22 -0700
Message-ID: <1463587584-2315623-15-git-send-email-tom@herbertland.com>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53985 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932774AbcERQGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:06:48 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4IG1ttu017564
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:48 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 230s3e8q74-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:48 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 85c620c21d1211e689100002c99293a0-3fbf2c50 for <netdev@vger.kernel.org>;	Wed,
 18 May 2016 09:06:47 -0700
In-Reply-To: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_offload.c | 24 +++++++++++++++++++++---
 net/ipv6/ip6_tunnel.c  |  5 +++++
 2 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 787e55f..332d6a0 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -253,9 +253,11 @@ out:
 	return pp;
 }
 
-static struct sk_buff **sit_gro_receive(struct sk_buff **head,
-					struct sk_buff *skb)
+static struct sk_buff **sit_ip6ip6_gro_receive(struct sk_buff **head,
+					       struct sk_buff *skb)
 {
+	/* Common GRO receive for SIT and IP6IP6 */
+
 	if (NAPI_GRO_CB(skb)->encap_mark) {
 		NAPI_GRO_CB(skb)->flush = 1;
 		return NULL;
@@ -298,6 +300,13 @@ static int sit_gro_complete(struct sk_buff *skb, int nhoff)
 	return ipv6_gro_complete(skb, nhoff);
 }
 
+static int ip6ip6_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	skb->encapsulation = 1;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_IPXIP6;
+	return ipv6_gro_complete(skb, nhoff);
+}
+
 static struct packet_offload ipv6_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
 	.callbacks = {
@@ -310,11 +319,19 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
 static const struct net_offload sit_offload = {
 	.callbacks = {
 		.gso_segment	= ipv6_gso_segment,
-		.gro_receive    = sit_gro_receive,
+		.gro_receive    = sit_ip6ip6_gro_receive,
 		.gro_complete   = sit_gro_complete,
 	},
 };
 
+static const struct net_offload ip6ip6_offload = {
+	.callbacks = {
+		.gso_segment	= ipv6_gso_segment,
+		.gro_receive    = sit_ip6ip6_gro_receive,
+		.gro_complete   = ip6ip6_gro_complete,
+	},
+};
+
 static int __init ipv6_offload_init(void)
 {
 
@@ -326,6 +343,7 @@ static int __init ipv6_offload_init(void)
 	dev_add_offload(&ipv6_packet_offload);
 
 	inet_add_offload(&sit_offload, IPPROTO_IPV6);
+	inet6_add_offload(&ip6ip6_offload, IPPROTO_IPV6);
 
 	return 0;
 }
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index cabf492..d26d226 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1242,6 +1242,11 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
+	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP6))
+		return -1;
+
+	skb_set_inner_ipproto(skb, IPPROTO_IPV6);
+
 	err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
 			   IPPROTO_IPV6);
 	if (err != 0) {
-- 
2.8.0.rc2
