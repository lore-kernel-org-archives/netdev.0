From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 4/4] sunvnet: generate ICMP PTMUD messages for smaller
 port MTUs
Date: Mon, 29 Sep 2014 13:17:06 -0400
Message-ID: <54299412.2010404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33204 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbaI2RQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 13:16:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sends ICMP and ICMPv6 messages for Path MTU Discovery when a remote
port MTU is smaller than the device MTU. This allows mixing newer VIO protocol
devices that support MTU negotiation with older devices that do not on the
same vswitch. It also allows Linux-Linux LDOMs to use 64K-1 data packets even
though Solaris vswitch is limited to <16K MTU.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   37 +++++++++++++++++++++++++++++++++++-
 1 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 1a7dce0..cb2d2b7 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -17,6 +17,13 @@
 #include <linux/mutex.h>
 #include <linux/if_vlan.h>
 +#if IS_ENABLED(CONFIG_IPV6)
+#include <linux/icmpv6.h>
+#endif
+
+#include <net/icmp.h>
+#include <net/route.h>
+
 #include <asm/vio.h>
 #include <asm/ldc.h>
 @@ -884,8 +891,36 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
  	skb = vnet_skb_shape(skb, &start, &nlen);
 -	if (skb->len > port->rmtu)
+	if (skb->len > port->rmtu) {
+		unsigned long localmtu = port->rmtu - ETH_HLEN;
+
+		if (vio_version_after_eq(&port->vio, 1, 3))
+			localmtu -= VLAN_HLEN;
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			struct flowi4 fl4;
+			struct rtable *rt = NULL;
+
+			memset(&fl4, 0, sizeof(fl4));
+			fl4.flowi4_oif = dev->ifindex;
+			fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
+			fl4.daddr = ip_hdr(skb)->daddr;
+			fl4.saddr = ip_hdr(skb)->saddr;
+
+			rt = ip_route_output_key(dev_net(dev), &fl4);
+			if (!IS_ERR(rt)) {
+				skb_dst_set(skb, &rt->dst);
+				icmp_send(skb, ICMP_DEST_UNREACH,
+					  ICMP_FRAG_NEEDED,
+					  htonl(localmtu));
+			}
+		}
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, localmtu);
+#endif
 		goto out_dropped;
+	}
  	spin_lock_irqsave(&port->vio.lock, flags);
 -- 1.7.1
