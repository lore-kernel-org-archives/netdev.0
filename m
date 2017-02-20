From: Brian Russell <brussell@brocade.com>
Subject: [PATCH net] Don't allow overwrite of config src addr
Date: Mon, 20 Feb 2017 17:03:54 +0000
Message-ID: <1487610234-8239-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54880 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753795AbdBTRUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 12:20:22 -0500
Received: from pps.filterd (m0048192.ppops.net [127.0.0.1])
        by mx0b-000f0801.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1KH3Hrx029798
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 09:04:09 -0800
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
        by mx0b-000f0801.pphosted.com with ESMTP id 28ppecq86k-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 09:04:09 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using IPv6 transport and a default dst, a pointer to the configured
source address is passed into the route lookup. If no source address is
configured, then the value is overwritten.

IPv6 route lookup ignores egress ifindex match if the source adress is set,
so if egress ifindex match is desired, the source address must be passed
as any. The overwrite breaks this for subsequent lookups.

Avoid this by copying the configured address to an existing stack variable
and pass a pointer to that instead.

Signed-off-by: Brian Russell <brussell@brocade.com>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 30b04cf..3cca908 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2019,7 +2019,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
 		vni = rdst->remote_vni;
-		src = &vxlan->cfg.saddr;
+		local_ip = vxlan->cfg.saddr;
 		dst_cache = &rdst->dst_cache;
 		md->gbp = skb->mark;
 		ttl = vxlan->cfg.ttl;
@@ -2052,7 +2052,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst = &remote_ip;
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = tunnel_id_to_key32(info->key.tun_id);
-		src = &local_ip;
 		dst_cache = &info->dst_cache;
 		if (info->options_len)
 			md = ip_tunnel_info_opts(info);
@@ -2061,6 +2060,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		label = info->key.label;
 		udp_sum = !!(info->key.tun_flags & TUNNEL_CSUM);
 	}
+	src = &local_ip;
 	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
 				     vxlan->cfg.port_max, true);
 
-- 
2.1.4
