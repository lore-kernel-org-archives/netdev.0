From: Davide Ciminaghi <ciminaghi@gnudd.com>
Subject: [PATCH v2] net/ethernet: ks8851_mll fix rx frame buffer overflow
Date: Fri, 13 Apr 2012 16:48:25 +0200
Message-ID: <20120413144825.GA5223@recalcati>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raffaele.recalcati@bticino.it
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.bticino.it ([91.208.195.91]:54758 "EHLO bticino.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753162Ab2DMOwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2012 10:52:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the beginning of ks_rcv(), a for loop retrieves the
header information relevant to all the frames stored
in the mac's internal buffers. The number of pending
frames is stored as an 8 bits field in KS_RXFCTR.
If interrupts are disabled long enough to allow for more than
32 frames to accumulate in the MAC's internal buffers, a buffer
overflow occurs.
This patch fixes the problem by making the
driver's frame_head_info buffer big enough.
Well actually, since the chip appears to have 12K of
internal rx buffers and the shortest ethernet frame should
be 64 bytes long, maybe the limit could be set to
12*1024/64 = 192 frames, but 255 should be safer.

Signed-off-by: Davide Ciminaghi <ciminaghi@gnudd.com>
Signed-off-by: Raffaele Recalcati <raffaele.recalcati@bticino.it>
---
The buffer overflow triggers weird random oopses.
The following setup helped reproducing the bug rather frequently
on our omap3 platform with 2.6.37 kernel:
- nfs rootfs
- host $ sudo ping -f $TARGET_IP_ADDRESS
- host $ scp -r BIG_DIR user@$TARGET_IP_ADDRESS:

 drivers/net/ethernet/micrel/ks8851_mll.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 2784bc7..927dbd2 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -40,7 +40,7 @@
 #define	DRV_NAME	"ks8851_mll"
 
 static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0x00, 0x10, 0xA1, 0x86, 0x95, 0x11 };
-#define MAX_RECV_FRAMES			32
+#define MAX_RECV_FRAMES			255
 #define MAX_BUF_SIZE			2048
 #define TX_BUF_SIZE			2000
 #define RX_BUF_SIZE			2000
-- 
1.7.0.4
