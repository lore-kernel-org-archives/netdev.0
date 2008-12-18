From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/5] tg3: Remove unused cfgspc device members
Date: Wed, 17 Dec 2008 18:23:13 -0800
Message-ID: <1229717360.5502@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1128 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbYLSUJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 15:09:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the pci_bist and pci_hdr_type members from the
device structure and removes the code that references them.  They are
not really used.

The patch rounds out the changes by moving the pci_cmd member to plug
a structure hole that would have been created.  On 32-bit systems, this
movement removes a subsequent structure hole later in the structure. On
64-bit systems though, the movement merely consolidates two holes into
one larger hole.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   23 ++++++-----------------
 drivers/net/tg3.h |    4 +---
 2 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9af8c9b..218c11a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12160,7 +12160,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		{ },
 	};
 	u32 misc_ctrl_reg;
-	u32 cacheline_sz_reg;
 	u32 pci_state_reg, grc_misc_cfg;
 	u32 val;
 	u16 pci_cmd;
@@ -12330,14 +12329,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	pci_write_config_dword(tp->pdev, TG3PCI_MISC_HOST_CTRL,
 			       tp->misc_host_ctrl);
 
-	pci_read_config_dword(tp->pdev, TG3PCI_CACHELINESZ,
-			      &cacheline_sz_reg);
-
-	tp->pci_cacheline_sz = (cacheline_sz_reg >>  0) & 0xff;
-	tp->pci_lat_timer    = (cacheline_sz_reg >>  8) & 0xff;
-	tp->pci_hdr_type     = (cacheline_sz_reg >> 16) & 0xff;
-	tp->pci_bist         = (cacheline_sz_reg >> 24) & 0xff;
-
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714))
 		tp->pdev_peer = tg3_find_peer(tp);
@@ -12447,17 +12438,15 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
 		tp->tg3_flags |= TG3_FLAG_MBOX_WRITE_REORDER;
 
+	pci_read_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
+			     &tp->pci_cacheline_sz);
+	pci_read_config_byte(tp->pdev, PCI_LATENCY_TIMER,
+			     &tp->pci_lat_timer);
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 &&
 	    tp->pci_lat_timer < 64) {
 		tp->pci_lat_timer = 64;
-
-		cacheline_sz_reg  = ((tp->pci_cacheline_sz & 0xff) <<  0);
-		cacheline_sz_reg |= ((tp->pci_lat_timer    & 0xff) <<  8);
-		cacheline_sz_reg |= ((tp->pci_hdr_type     & 0xff) << 16);
-		cacheline_sz_reg |= ((tp->pci_bist         & 0xff) << 24);
-
-		pci_write_config_dword(tp->pdev, TG3PCI_CACHELINESZ,
-				       cacheline_sz_reg);
+		pci_write_config_byte(tp->pdev, PCI_LATENCY_TIMER,
+				      tp->pci_lat_timer);
 	}
 
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5700_BX) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f3cda64..814d82b 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2676,10 +2676,9 @@ struct tg3 {
 
 	/* PCI block */
 	u32				pci_chip_rev_id;
+	u16				pci_cmd;
 	u8				pci_cacheline_sz;
 	u8				pci_lat_timer;
-	u8				pci_hdr_type;
-	u8				pci_bist;
 
 	int				pm_cap;
 	int				msi_cap;
@@ -2730,7 +2729,6 @@ struct tg3 {
 
 	u32				led_ctrl;
 	u32				phy_otp;
-	u16				pci_cmd;
 
 	char				board_part_number[24];
 #define TG3_VER_SIZE 32
-- 
1.5.6.4


