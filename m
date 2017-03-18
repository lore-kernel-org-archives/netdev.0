From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: [PATCH net-next v4 2/2]L2TP:Adjust intf MTU, add underlay L3, L2
 hdrs
Date: Fri, 17 Mar 2017 19:00:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1703171854310.10094@vera100.eng.brocade.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kleptog@svana.org, jchapman@katalix.com, davem@redhat.com,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In existing kernel code, when setting up the L2TP interface, all of the
tunnel encapsulation headers are not taken into account when setting
up the MTU on the  L2TP logical interface device. Due to this, the
packets created by the applications on top of the L2TP layer are larger
than they ought to be, relative to the underlay MTU, which leads to
needless fragmentation once the L2TP packet is encapsulated in an outer IP
packet.  Specifically, the MTU calculation  does not take into account the
(outer) IP header imposed on the encapsulated L2TP packet, and the Layer 2
header imposed on the inner L2TP packet prior to encapsulation.

Change-set here (2/2) uses the new kernel API to compute the IP overhead
on an IPv4 or IPv6 socket, introduced in 1/2, in the L2TP Eth device setup
to factor the additional encap overheads from the underlay IP header and
Ethernet header on overlay (inner packet), to size the MTU on the L2TP
logical device to its correct value.

Signed-off-by: R. Parameswaran <rparames@brocade.com>
---
 net/l2tp/l2tp_eth.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 51 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 8bf18a5..f143fa4 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -30,6 +30,9 @@
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/udp.h>
 
 #include "l2tp_core.h"
 
@@ -204,6 +207,53 @@ static void l2tp_eth_show(struct seq_file *m, void *arg)
 }
 #endif
 
+static void l2tp_eth_adjust_mtu(struct l2tp_tunnel *tunnel,
+				struct l2tp_session *session,
+				struct net_device *dev)
+{
+	unsigned int overhead = 0;
+	struct dst_entry *dst;
+	u32 l3_overhead = 0;
+
+	/* if the encap is UDP, account for UDP header size */
+	if (tunnel->encap == L2TP_ENCAPTYPE_UDP) {
+		overhead += sizeof(struct udphdr);
+		dev->needed_headroom += sizeof(struct udphdr);
+	}
+	if (session->mtu != 0) {
+		dev->mtu = session->mtu;
+		dev->needed_headroom += session->hdr_len;
+		return;
+	}
+	l3_overhead = kernel_sock_ip_overhead(tunnel->sock);
+	if (l3_overhead == 0) {
+		/* L3 Overhead couldn't be identified, this could be
+		 * because tunnel->sock was NULL or the socket's
+		 * address family was not IPv4 or IPv6,
+		 * dev mtu stays at 1500.
+		 */
+		return;
+	}
+	/* Adjust MTU, factor overhead - underlay L3, overlay L2 hdr
+	 * UDP overhead, if any, was already factored in above.
+	 */
+	overhead += session->hdr_len + ETH_HLEN + l3_overhead;
+
+	/* If PMTU discovery was enabled, use discovered MTU on L2TP device */
+	dst = sk_dst_get(tunnel->sock);
+	if (dst) {
+		/* dst_mtu will use PMTU if found, else fallback to intf MTU */
+		u32 pmtu = dst_mtu(dst);
+
+		if (pmtu != 0)
+			dev->mtu = pmtu;
+		dst_release(dst);
+	}
+	session->mtu = dev->mtu - overhead;
+	dev->mtu = session->mtu;
+	dev->needed_headroom += session->hdr_len;
+}
+
 static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
 {
 	struct net_device *dev;
@@ -253,13 +303,10 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 	}
 
 	dev_net_set(dev, net);
-	if (session->mtu == 0)
-		session->mtu = dev->mtu - session->hdr_len;
-	dev->mtu = session->mtu;
-	dev->needed_headroom += session->hdr_len;
 	dev->min_mtu = 0;
 	dev->max_mtu = ETH_MAX_MTU;
 
+	l2tp_eth_adjust_mtu(tunnel, session, dev);
 	priv = netdev_priv(dev);
 	priv->dev = dev;
 	priv->session = session;
-- 
2.1.4
