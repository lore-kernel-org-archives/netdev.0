From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 1/2] net: Pre-step for supporting GRO on vxlan traffic
Date: Sun,  5 Jan 2014 17:23:41 +0200
Message-ID: <1388935422-7331-2-git-send-email-ogerlitz@mellanox.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52439 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751186AbaAEPXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 10:23:52 -0500
In-Reply-To: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a pre-step for supporting vxlan with the GRO stack, move the
vxlan header structure definition to common header file and
enhance the vxlan code not to alter the ip_summed field for RX
skb's marked with CHECKSUM_PARTIAL, as done by the TCP GRO code.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/vxlan.c |   10 ++--------
 include/net/vxlan.h |    6 ++++++
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 474a99e..e3d8183 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -64,12 +64,6 @@
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
-/* VXLAN protocol header */
-struct vxlanhdr {
-	__be32 vx_flags;
-	__be32 vx_vni;
-};
-
 /* UDP port for VXLAN traffic.
  * The IANA assigned port is 4789, but the Linux default is 8472
  * for compatibility with early adopters.
@@ -1125,8 +1119,8 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 	 * leave the CHECKSUM_UNNECESSARY, the device checksummed it
 	 * for us. Otherwise force the upper layers to verify it.
 	 */
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY || !skb->encapsulation ||
-	    !(vxlan->dev->features & NETIF_F_RXCSUM))
+	if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||
+	    !skb->encapsulation || !(vxlan->dev->features & NETIF_F_RXCSUM))
 		skb->ip_summed = CHECKSUM_NONE;
 
 	skb->encapsulation = 0;
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 6b6d180..dede91c 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -5,6 +5,12 @@
 #include <linux/netdevice.h>
 #include <linux/udp.h>
 
+/* VXLAN protocol header */
+struct vxlanhdr {
+	__be32 vx_flags;
+	__be32 vx_vni;
+};
+
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 
-- 
1.7.1
