From: Jesse Barnes <jbarnes@sgi.com>
Subject: [PATCH] work around 5701 misalignment
Date: Wed, 13 Oct 2004 15:54:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410131554.19845.jbarnes@sgi.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_7XZbBpmB1NXJpF6"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_7XZbBpmB1NXJpF6
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch helps deal with 5701s running in PCI-X mode on platforms (like 
ia64) where unaligned accesses are very expensive.  It was made a config 
option at davem's request, afaik, and only affects 5701s when enabled.  Patch 
originally by John Partridge.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
Signed-off-by: John Partridge <johnip@sgi.com>

Thanks,
Jesse

--Boundary-00=_7XZbBpmB1NXJpF6
Content-Type: text/x-diff;
  charset="us-ascii";
  name="tg3-unaligned-expensive.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="tg3-unaligned-expensive.patch"


===========================================================================
linux/drivers/net/Kconfig
===========================================================================

--- a/linux/drivers/net/Kconfig	2004-10-13 15:25:03.000000000 -0500
+++ b/linux/drivers/net/Kconfig	2004-10-13 15:22:39.000000000 -0500
@@ -2062,6 +2062,15 @@
 
 endmenu
 
+config UNALIGNED_EXPENSIVE
+	depends on TIGON3
+	bool "Do aligned kernel buffers for PCI-X 5701 Cards"
+	help 
+		This aligns kernel buffers for PCI-X 5701
+		other cards do not have this problem.
+		This will help performance on 5701 cards
+		and not adversly affect any other cards.
+
 #
 #	10 Gigabit Ethernet
 #

===========================================================================
linux/drivers/net/tg3.c
===========================================================================

--- a/linux/drivers/net/tg3.c	2004-10-13 15:25:03.000000000 -0500
+++ b/linux/drivers/net/tg3.c	2004-10-13 15:14:45.000000000 -0500
@@ -2352,7 +2352,12 @@
 
 		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) - 4; /* omit crc */
 
-		if (len > RX_COPY_THRESHOLD) {
+		if (len > RX_COPY_THRESHOLD
+#if defined(CONFIG_UNALIGNED_EXPENSIVE)
+                                && tp->rx_offset == 2
+#endif
+)
+{
 			int skb_size;
 
 			skb_size = tg3_alloc_rx_skb(tp, opaque_key,

--Boundary-00=_7XZbBpmB1NXJpF6--
