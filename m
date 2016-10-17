From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: [RFC PATCH v3 2/2] L2TP:Adjust intf MTU,factor underlay L3,overlay
 L2
Date: Sun, 16 Oct 2016 22:20:21 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1610162216250.13394@duvvury48.eng.vyatta.net>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net> <57ED30D7.6000009@katalix.com> <alpine.DEB.2.11.1609291913070.8509@duvvury48.eng.vyatta.net> <1cec5be4-0719-0dca-d3c6-8c794c867672@katalix.com> <alpine.DEB.2.11.1610031954330.2198@duvvury48.eng.vyatta.net>
 <149288c4-a352-ae30-ad3a-91d1edfa4bce@katalix.com> <CAGeBGG7AS1JZYHC6T5_H6vY4wfptUtPzO=+kdCcUzJGXA0m6_A@mail.gmail.com> <52890af4-38d6-6aa7-a9e0-69be60fe89fa@katalix.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: R Parameswaran <parameswaran.r7@gmail.com>, kleptog@svana.org,
        netdev@vger.kernel.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        Robert Shearman <rshearma@brocade.com>, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com,
        bhong@brocade.com
To: James Chapman <jchapman@katalix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52890af4-38d6-6aa7-a9e0-69be60fe89fa@katalix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



[v3: Picked up review comments from James Chapman, added a
 function  to compute ip header + ip option overhead on a socket, and factored
 it  into L2TP change-set, RFC, would like early feedback on name and
 placement  of new function while I test this.

 Part 2/2: Changes in l2tp_eth.c, using the new API from part 1]

>From f4066da53e781ef167055c1e89ca1a7819215a40 Mon Sep 17 00:00:00 2001
From: "R. Parameswaran" <rparames@brocade.com>
Date: Sun, 16 Oct 2016 20:27:20 -0700

In existing kernel code, when setting up the L2TP interface, all of the
tunnel encapsulation headers are not taken into account when setting
up the MTU on the  L2TP logical interface device. Due to this, the
packets created by the applications on top of the L2TP layer are larger
than they ought to be, relative to the underlay MTU, which leads to
needless fragmentation once the L2TP packet is encapsulated in an outer IP
packet.

Specifically, the MTU calculation  does not take into account the (outer)
IP header imposed on the encapsulated L2TP packet, and the Layer 2 header
imposed on the inner L2TP packet prior to encapsulation. The patch posted
here takes care of these.

Existing code also seems to assume an Ethernet (non-jumbo) underlay. The
patch uses the PMTU mechanism and the dst entry in the L2TP tunnel socket
to directly pull up the underlay MTU (as the baseline number on top of
which the encapsulation headers are factored in).  Ethernet MTU is
assumed as a fallback only if this fails.

Picked up review comments from James Chapman, added a function
to compute ip header + ip option overhead on a socket, and factored it
into L2TP change-set.

Signed-off-by: nprachan@brocade.com,
Signed-off-by: bhong@brocade.com,
Signed-off-by: rshearma@brocade.com,
Signed-off-by: dfawcus@brocade.com
---
 net/l2tp/l2tp_eth.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 47 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 965f7e3..75eb5d3 100644
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
 
@@ -206,6 +209,49 @@ static void l2tp_eth_show(struct seq_file *m, void *arg)
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
+	if (session->mtu != 0) {
+		dev->mtu = session->mtu;
+		dev->needed_headroom += session->hdr_len;
+		if (tunnel->encap == L2TP_ENCAPTYPE_UDP)
+			dev->needed_headroom += sizeof(struct udphdr);
+		return;
+	}
+	overhead = session->hdr_len;
+	l3_overhead = kernel_sock_ip_overhead(tunnel->sock);
+	if (!tunnel->sock || (l3_overhead == 0)) {
+		/* L3 Overhead couldn't be identified, dev mtu stays at 1500 */
+		return;
+	}
+	/* Adjust MTU, factor overhead - underlay L3, overlay L2 hdr*/
+	overhead += ETH_HLEN + l3_overhead;
+	/* Additionally, if the encap is UDP, account for UDP header size */
+	if (tunnel->encap == L2TP_ENCAPTYPE_UDP)
+		overhead += sizeof(struct udphdr);
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
+	if (tunnel->encap == L2TP_ENCAPTYPE_UDP)
+		dev->needed_headroom += sizeof(struct udphdr);
+}
+
 static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
 {
 	struct net_device *dev;
@@ -255,11 +301,8 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 	}
 
 	dev_net_set(dev, net);
-	if (session->mtu == 0)
-		session->mtu = dev->mtu - session->hdr_len;
-	dev->mtu = session->mtu;
-	dev->needed_headroom += session->hdr_len;
 
+	l2tp_eth_adjust_mtu(tunnel, session, dev);
 	priv = netdev_priv(dev);
 	priv->dev = dev;
 	priv->session = session;
-- 
2.1.4

----

> 
> I think keep it simple. A function to return the size of the IP header
> associated with any IP socket, not necessarily a tunnel socket. Don't
> mix in any MTU derivation logic or UDP header size etc.
> 
> Post code early as an RFC. You're more likely to get review feedback
> from others.
> 
> 
> 
> 
