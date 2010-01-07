From: "Benjamin Li" <benli@broadcom.com>
Subject: [PATCH net-next] bnx2: Flush the register writes which setup
 the MSI-X table
Date: Wed, 6 Jan 2010 16:07:23 -0800
Message-ID: <1262822843-14700-1-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Li" <benli@broadcom.com>,
	"Kalyan Ram Chintalapati" <kalyanc@vmware.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kalyan Ram Chintalapati" <kalyanc@vmware.com>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3867 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932834Ab0AGAHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 19:07:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MSI-X table size needs to be properly set before pci_enable_msix()
is called.  But on certain machines, the writes are delayed and the
MSI-X table size is incorrectly read.  By reading the
BNX2_PCI_MSIX_CONTROL register, the writes are flushed and now
ensure that the MSI-X table is set correctly before MSI-X
is enable on the device.

This patch was originally diagnosed and authored by
Kalyan Ram Chintalapati <kalyanc@vmware.com>.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Kalyan Ram Chintalapati <kalyanc@vmware.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 65df1de..c7289b5 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6145,6 +6145,10 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 	REG_WR(bp, BNX2_PCI_MSIX_TBL_OFF_BIR, BNX2_PCI_GRC_WINDOW2_BASE);
 	REG_WR(bp, BNX2_PCI_MSIX_PBA_OFF_BIT, BNX2_PCI_GRC_WINDOW3_BASE);
 
+	/*  Need to flush the previous three writes to ensure MSI-X 
+	 *  is setup properly */
+	REG_RD(bp, BNX2_PCI_MSIX_CONTROL);
+
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
 		msix_ent[i].entry = i;
 		msix_ent[i].vector = 0;
-- 
1.6.1.2


