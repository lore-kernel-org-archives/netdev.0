From: Brian Russell <brussell@brocade.com>
Subject: [PATCH net v2] vxlan: don't allow overwrite of config src addr
Date: Fri, 24 Feb 2017 17:47:11 +0000
Message-ID: <1487958431-8115-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:51333 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751121AbdBXSID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 13:08:03 -0500
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
        by mx0b-000f0801.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1OHeXLg026424
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 09:47:25 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
        by mx0b-000f0801.pphosted.com with ESMTP id 28sa5s1xsu-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 09:47:25 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using IPv6 transport and a default dst, a pointer to the configured
source address is passed into the route lookup. If no source address is
configured, then the value is overwritten.

IPv6 route lookup ignores egress ifindex match if the source address is set,
so if egress ifindex match is desired, the source address must be passed
as any. The overwrite breaks this for subsequent lookups.

Avoid this by copying the configured address to an existing stack variable
and pass a pointer to that instead.

Fixes: 272d96a5ab10 ("net: vxlan: lwt: Use source ip address during route lookup.")

Signed-off-by: Brian Russell <brussell@brocade.com>
Acked-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 556953f..2e05129 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2035,7 +2035,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	const struct iphdr *old_iph = ip_hdr(skb);
 	union vxlan_addr *dst;
 	union vxlan_addr remote_ip, local_ip;
-	union vxlan_addr *src;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
 	__be16 src_port = 0, dst_port;
@@ -2062,7 +2061,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
 		vni = (rdst->remote_vni) ? : default_vni;
-		src = &vxlan->cfg.saddr;
+		local_ip = vxlan->cfg.saddr;
 		dst_cache = &rdst->dst_cache;
 		md->gbp = skb->mark;
 		ttl = vxlan->cfg.ttl;
@@ -2095,7 +2094,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst = &remote_ip;
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = tunnel_id_to_key32(info->key.tun_id);
-		src = &local_ip;
 		dst_cache = &info->dst_cache;
 		if (info->options_len)
 			md = ip_tunnel_info_opts(info);
@@ -2115,7 +2113,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		rt = vxlan_get_route(vxlan, dev, sock4, skb,
 				     rdst ? rdst->remote_ifindex : 0, tos,
 				     dst->sin.sin_addr.s_addr,
-				     &src->sin.sin_addr.s_addr,
+				     &local_ip.sin.sin_addr.s_addr,
 				     dst_port, src_port,
 				     dst_cache, info);
 		if (IS_ERR(rt)) {
@@ -2142,7 +2140,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		if (err < 0)
 			goto tx_error;
 
-		udp_tunnel_xmit_skb(rt, sock4->sock->sk, skb, src->sin.sin_addr.s_addr,
+		udp_tunnel_xmit_skb(rt, sock4->sock->sk, skb, local_ip.sin.sin_addr.s_addr,
 				    dst->sin.sin_addr.s_addr, tos, ttl, df,
 				    src_port, dst_port, xnet, !udp_sum);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -2152,7 +2150,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
 					label, &dst->sin6.sin6_addr,
-					&src->sin6.sin6_addr,
+					&local_ip.sin6.sin6_addr,
 					dst_port, src_port,
 					dst_cache, info);
 		if (IS_ERR(ndst)) {
@@ -2180,7 +2178,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			goto tx_error;
 
 		udp_tunnel6_xmit_skb(ndst, sock6->sock->sk, skb, dev,
-				     &src->sin6.sin6_addr,
+				     &local_ip.sin6.sin6_addr,
 				     &dst->sin6.sin6_addr, tos, ttl,
 				     label, src_port, dst_port, !udp_sum);
 #endif
-- 
2.1.4
