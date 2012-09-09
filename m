From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next] r8169: use unlimited DMA burst for TX
Date: Mon, 10 Sep 2012 01:55:26 +0200
Message-ID: <1347234926-5263-1-git-send-email-mschmidt@redhat.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab2IIXzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Sep 2012 19:55:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The r8169 driver currently limits the DMA burst for TX to 1024 bytes. I have
a box where this prevents the interface from using the gigabit line to its full
potential. This patch solves the problem by setting TX_DMA_BURST to unlimited.

The box has an ASRock B75M motherboard with on-board RTL8168evl/8111evl
(XID 0c900880). TSO is enabled.

I used netperf (TCP_STREAM test) to measure the dependency of TX throughput
on MTU. I did it for three different values of TX_DMA_BURST ('5'=512, '6'=1024,
'7'=unlimited). This chart shows the results:
http://michich.fedorapeople.org/r8169/r8169-effects-of-TX_DMA_BURST.png

Interesting points:
 - With the current DMA burst limit (1024):
   - at the default MTU=1500 I get only 842 Mbit/s.
   - when going from small MTU, the performance rises monotonically with
     increasing MTU only up to a peak at MTU=1076 (908 MBit/s). Then there's
     a sudden drop to 762 MBit/s from which the throughput rises monotonically
     again with further MTU increases.
 - With a smaller DMA burst limit (512):
   - there's a similar peak at MTU=1076 and another one at MTU=564.
 - With unlimited DMA burst:
   - at the default MTU=1500 I get nice 940 Mbit/s.
   - the throughput rises monotonically with increasing MTU with no strange
     peaks.

Notice that the peaks occur at MTU sizes that are multiples of the DMA burst
limit plus 52. Why 52? Because:
  20 (IP header) + 20 (TCP header) + 12 (TCP options) = 52

The Realtek-provided r8168 driver (v8.032.00) uses unlimited TX DMA burst too,
except for CFG_METHOD_1 where the TX DMA burst is set to 512 bytes.
CFG_METHOD_1 appears to be the oldest MAC version of "RTL8168B/8111B",
i.e. RTL_GIGA_MAC_VER_11 in r8169. Not sure if this MAC version really needs
the smaller burst limit, or if any other versions have similar requirements.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b47d5b3..549314f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -77,7 +77,7 @@
 static const int multicast_filter_limit = 32;
 
 #define MAX_READ_REQUEST_SHIFT	12
-#define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
+#define TX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
-- 
1.7.1
