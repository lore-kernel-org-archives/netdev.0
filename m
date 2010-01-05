From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Tue, 05 Jan 2010 16:50:47 +0100
Message-ID: <20100105155047.13309.79610.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:49658 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab0AEQXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 11:23:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to be used together with switch technologies, like RFC3069,
that where the individual ports are not allowed to communicate with
each other, but they are allowed to talk to the upstream router.  As
described in RFC 3069, it is possible to allow these hosts to
communicate through the upstream router by proxy_arp'ing.

This patch basically allow proxy arp replies back to the same
interface (from which the ARP request/solicitation was received).

Tunable per device via proc "proxy_arp_pvlan":
  /proc/sys/net/ipv4/conf/*/proxy_arp_pvlan

This switch technology is known by different vendor names:
 - In RFC 3069 it is called VLAN Aggregation.
 - Cisco and Allied Telesyn call it Private VLAN.
 - Hewlett-Packard call it Source-Port filtering or port-isolation.
 - Ericsson call it MAC-Forced Forwarding (RFC Draft).

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 Documentation/networking/ip-sysctl.txt |   19 ++++++++++++
 include/linux/inetdevice.h             |    1 +
 include/linux/sysctl.h                 |    1 +
 net/ipv4/arp.c                         |   52 ++++++++++++++++++++++++++++++--
 net/ipv4/devinet.c                     |    1 +
 net/ipv4/route.c                       |    7 ++++
 6 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 006b39d..c532884 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -692,6 +692,25 @@ proxy_arp - BOOLEAN
 	conf/{all,interface}/proxy_arp is set to TRUE,
 	it will be disabled otherwise
 
+proxy_arp_pvlan - BOOLEAN
+	Private VLAN proxy arp.
+	Basically allow proxy arp replies back to the same interface
+	(from which the ARP request/solicitation was received).
+
+	This is done to support (ethernet) switch features, like RFC
+	3069, where the individual ports are NOT allowed to
+	communicate with each other, but they are allowed to talk to
+	the upstream router.  As described in RFC 3069, it is possible
+	to allow these hosts to communicate through the upstream
+	router by proxy_arp'ing. Don't need to be used together with
+	proxy_arp.
+
+	This technology is known by different names:
+	  In RFC 3069 it is called VLAN Aggregation.
+	  Cisco and Allied Telesyn call it Private VLAN.
+	  Hewlett-Packard call it Source-Port filtering or port-isolation.
+	  Ericsson call it MAC-Forced Forwarding (RFC Draft).
+
 shared_media - BOOLEAN
 	Send(router) or accept(host) RFC1620 shared media redirects.
 	Overrides ip_secure_redirects.
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 699e85c..9a8c574 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -88,6 +88,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 
 #define IN_DEV_LOG_MARTIANS(in_dev)	IN_DEV_ORCONF((in_dev), LOG_MARTIANS)
 #define IN_DEV_PROXY_ARP(in_dev)	IN_DEV_ORCONF((in_dev), PROXY_ARP)
+#define IN_DEV_PROXY_ARP_PVLAN(in_dev)	IN_DEV_CONF_GET(in_dev, PROXY_ARP_PVLAN)
 #define IN_DEV_SHARED_MEDIA(in_dev)	IN_DEV_ORCONF((in_dev), SHARED_MEDIA)
 #define IN_DEV_TX_REDIRECTS(in_dev)	IN_DEV_ORCONF((in_dev), SEND_REDIRECTS)
 #define IN_DEV_SEC_REDIRECTS(in_dev)	IN_DEV_ORCONF((in_dev), \
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 877ba03..24ff7e3 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -482,6 +482,7 @@ enum
 	NET_IPV4_CONF_ARP_ACCEPT=21,
 	NET_IPV4_CONF_ARP_NOTIFY=22,
 	NET_IPV4_CONF_ACCEPT_LOCAL=23,
+	NET_IPV4_CONF_PROXY_ARP_PVLAN=24,
 	__NET_IPV4_CONF_MAX
 };
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c95cd93..0787092 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -70,6 +70,7 @@
  *					bonding can change the skb before
  *					sending (e.g. insert 8021q tag).
  *		Harald Welte	:	convert to make use of jenkins hash
+ *		Jesper D. Brouer:       Proxy ARP PVLAN RFC 3069 support.
  */
 
 #include <linux/module.h>
@@ -524,12 +525,15 @@ int arp_bind_neighbour(struct dst_entry *dst)
 /*
  * Check if we can use proxy ARP for this path
  */
-
-static inline int arp_fwd_proxy(struct in_device *in_dev, struct rtable *rt)
+static inline int arp_fwd_proxy(struct in_device *in_dev,
+				struct net_device *dev,	struct rtable *rt)
 {
 	struct in_device *out_dev;
 	int imi, omi = -1;
 
+	if (rt->u.dst.dev == dev)
+		return 0;
+
 	if (!IN_DEV_PROXY_ARP(in_dev))
 		return 0;
 
@@ -548,6 +552,43 @@ static inline int arp_fwd_proxy(struct in_device *in_dev, struct rtable *rt)
 }
 
 /*
+ * Check for RFC3069 proxy arp private VLAN (allow to send back to same dev)
+ *
+ * RFC3069 supports proxy arp replies back to the same interface.  This
+ * is done to support (ethernet) switch features, like RFC 3069, where
+ * the individual ports are not allowed to communicate with each
+ * other, BUT they are allowed to talk to the upstream router.  As
+ * described in RFC 3069, it is possible to allow these hosts to
+ * communicate through the upstream router, by proxy_arp'ing.
+ *
+ * RFC 3069: "VLAN Aggregation for Efficient IP Address Allocation"
+ *
+ *  This technology is known by different names:
+ *    In RFC 3069 it is called VLAN Aggregation.
+ *    Cisco and Allied Telesyn call it Private VLAN.
+ *    Hewlett-Packard call it Source-Port filtering or port-isolation.
+ *    Ericsson call it MAC-Forced Forwarding (RFC Draft).
+ *
+ */
+static inline int arp_fwd_pvlan(struct in_device *in_dev,
+				struct net_device *dev,	struct rtable *rt,
+				__be32 sip, __be32 tip)
+{
+	/* Private VLAN is only concerned about the same ethernet segment */
+	if (rt->u.dst.dev != dev)
+		return 0;
+
+	/* Don't reply on self probes (often done by windowz boxes)*/
+	if (sip == tip)
+		return 0;
+
+	if (IN_DEV_PROXY_ARP_PVLAN(in_dev))
+		return 1;
+	else
+		return 0;
+}
+
+/*
  *	Interface to link layer: send routine and receive handler.
  */
 
@@ -833,8 +874,11 @@ static int arp_process(struct sk_buff *skb)
 			}
 			goto out;
 		} else if (IN_DEV_FORWARD(in_dev)) {
-			    if (addr_type == RTN_UNICAST  && rt->u.dst.dev != dev &&
-			     (arp_fwd_proxy(in_dev, rt) || pneigh_lookup(&arp_tbl, net, &tip, dev, 0))) {
+			if (addr_type == RTN_UNICAST  &&
+			    (arp_fwd_proxy(in_dev, dev, rt) ||
+			     arp_fwd_pvlan(in_dev, dev, rt, sip, tip) ||
+			     pneigh_lookup(&arp_tbl, net, &tip, dev, 0)))
+			{
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n)
 					neigh_release(n);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5cdbc10..0715f4c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1407,6 +1407,7 @@ static struct devinet_sysctl_table {
 		DEVINET_SYSCTL_RW_ENTRY(ARP_IGNORE, "arp_ignore"),
 		DEVINET_SYSCTL_RW_ENTRY(ARP_ACCEPT, "arp_accept"),
 		DEVINET_SYSCTL_RW_ENTRY(ARP_NOTIFY, "arp_notify"),
+		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP_PVLAN, "proxy_arp_pvlan"),
 
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e446496..1cc3394 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1988,8 +1988,13 @@ static int __mkroute_input(struct sk_buff *skb,
 	if (skb->protocol != htons(ETH_P_IP)) {
 		/* Not IP (i.e. ARP). Do not create route, if it is
 		 * invalid for proxy arp. DNAT routes are always valid.
+		 *
+		 * Proxy arp feature have been extended to allow, ARP
+		 * replies back to the same interface, to support
+		 * Private VLAN switch technologies. See arp.c.
 		 */
-		if (out_dev == in_dev) {
+		if (out_dev == in_dev &&
+		    IN_DEV_PROXY_ARP_PVLAN(in_dev) == 0) {
 			err = -EINVAL;
 			goto cleanup;
 		}

