From: akepner@sgi.com
Subject: [PATCH bk-2.6.10] tg3:align IP headers from 5701 in PCI-X mode
Date: Mon, 3 Jan 2005 17:45:01 -0800 (PST)
Message-ID: <Pine.LNX.4.33.0501031713460.16417-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <davem@davemloft.net>, <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We still have customers using 5701 cards, and their syslogs fill with 
"kernel unaligned access" messages. They may also see a significant 
performance degradation due to the expense of unaligned accesses on 
ia64. Here's a patch to address this (it is almost the same as the 
patch which was discussed in 
http://marc.theaimsgroup.com/?l=linux-netdev&m=109770128816605&w=2).

In a quick throughput test, I found that this could improve throughput
by ~30% on an Altix.

diffstats:
 drivers/net/Kconfig |   13 +++++++++++++
 drivers/net/tg3.c   |    8 +++++++-
 2 files changed, 20 insertions(+), 1 deletion(-)

Signed-off-by: Arthur Kepner <akepner@sgi.com>

===== drivers/net/Kconfig 1.97 vs edited =====
--- 1.97/drivers/net/Kconfig	2004-12-27 01:29:18 -08:00
+++ edited/drivers/net/Kconfig	2005-01-03 17:12:26 -08:00
@@ -2089,6 +2089,19 @@ config TIGON3
 	  To compile this driver as a module, choose M here: the module
 	  will be called tg3.  This is recommended.
 
+config 5701_PCIX_IP_ALIGN
+	bool "align IP headers from 5701 cards in the driver (in PCI-X mode)"
+	depends on TIGON3
+	help
+	  IP headers from 5701 cards (in PCI-X mode only) are not aligned as 
+	  the TCP/IP stack expects. On some architectures (including ia64) 
+	  unaligned accesses are particularly expensive, and the performance 
+	  of 5701 cards in PCI-X mode suffers. Configuring 5701_PCIX_IP_ALIGN 
+	  causes the driver to copy packets so that the IP headers are 
+	  aligned. 5701_PCIX_IP_ALIGN only affects operation of the TIGON3 driver 
+	  when used with a 5701 card in PCI-X mode - other cards are unaffected 
+	  by this option.
+
 config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on 85xx
===== drivers/net/tg3.c 1.222 vs edited =====
--- 1.222/drivers/net/tg3.c	2004-11-15 15:53:08 -08:00
+++ edited/drivers/net/tg3.c	2005-01-03 17:25:09 -08:00
@@ -2702,7 +2702,13 @@ static int tg3_rx(struct tg3 *tp, int bu
 
 		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) - 4; /* omit crc */
 
-		if (len > RX_COPY_THRESHOLD) {
+		if (len > RX_COPY_THRESHOLD 
+#ifdef CONFIG_5701_PCIX_IP_ALIGN
+			&& tp->rx_offset == 2
+			/* rx_offset != 2 iff this is a 5701 card running
+			 * in PCI-X mode [see tg3_get_invariants()] */
+#endif
+		) {
 			int skb_size;
 
 			skb_size = tg3_alloc_rx_skb(tp, opaque_key,
-- 
Arthur
