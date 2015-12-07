From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net v3 2/2] vxlan: support ndo_fill_metadata_dst also for IPv6
Date: Mon,  7 Dec 2015 13:04:31 +0100
Message-ID: <74570f0b32576fcbab697ec6c9f72ac4593b935c.1449489733.git.jbenc@redhat.com>
References: <cover.1449489733.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41259 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140AbbLGMEu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 07:04:50 -0500
In-Reply-To: <cover.1449489733.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fill the metadata correctly even when tunneling over IPv6. Also, check that
the provided metadata is of an address family that is supported by the
tunnel.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v3: use #if/#else in the IPv6 part
v2: fixed unused variable warning when building without IPv6
---
 drivers/net/vxlan.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5a38558da157..14cfa4cdf903 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2419,9 +2419,30 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 				  vxlan->cfg.port_max, true);
 	dport = info->key.tp_dst ? : vxlan->cfg.dst_port;
 
-	if (ip_tunnel_info_af(info) == AF_INET)
+	if (ip_tunnel_info_af(info) == AF_INET) {
+		if (!vxlan->vn4_sock)
+			return -EINVAL;
 		return egress_ipv4_tun_info(dev, skb, info, sport, dport);
-	return -EINVAL;
+	} else {
+#if IS_ENABLED(CONFIG_IPV6)
+		struct dst_entry *ndst;
+
+		if (!vxlan->vn6_sock)
+			return -EINVAL;
+		ndst = vxlan6_get_route(vxlan, skb, 0,
+					&info->key.u.ipv6.dst,
+					&info->key.u.ipv6.src);
+		if (IS_ERR(ndst))
+			return PTR_ERR(ndst);
+		dst_release(ndst);
+
+		info->key.tp_src = sport;
+		info->key.tp_dst = dport;
+#else /* !CONFIG_IPV6 */
+		return -EPFNOSUPPORT;
+#endif
+	}
+	return 0;
 }
 
 static const struct net_device_ops vxlan_netdev_ops = {
-- 
1.8.3.1
