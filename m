From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 10/13] tg3: Increase the PCI MRRS
Date: Fri, 09 Nov 2007 16:39:01 -0800
Message-ID: <1194655141.5745.272.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2629 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752829AbXKJAjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previous devices hardcoded the PCI Maximum Read Request Size to 4K.  To
better comply with the PCI spec, the hardware now defaults the MRRS to
512 bytes.  This will yield poor driver performance if left untouched.
This patch increases the MRRS to 4K on driver initialization.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ecd64a2..72db78b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5098,12 +5098,15 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 
 	pci_write_config_word(tp->pdev, PCI_COMMAND, tp->pci_cmd);
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
+	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)
+		pcie_set_readrq(tp->pdev, 4096);
+	else {
 		pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
 				      tp->pci_cacheline_sz);
 		pci_write_config_byte(tp->pdev, PCI_LATENCY_TIMER,
 				      tp->pci_lat_timer);
 	}
+
 	/* Make sure PCI-X relaxed ordering bit is clear. */
 	if (tp->pcix_cap) {
 		u16 pcix_cmd;
@@ -11215,6 +11218,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
 	if (pcie_cap != 0) {
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
+
+		pcie_set_readrq(tp->pdev, 4096);
+
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			u16 lnkctl;
 


