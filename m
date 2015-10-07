From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bnx2fc: reduce stack usage in __bnx2fc_enable
Date: Wed, 07 Oct 2015 15:11:04 +0200
Message-ID: <5002023.QHmpbQ8s70@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: QLogic-Storage-Upstream@qlogic.com,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joe Carnuccio <joe.carnuccio@qlogic.com>,
	Chad Dupuis <chad.dupuis@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-scsi@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the bnx2fc driver was changed to read the npiv table from
nvram, the stack of the __bnx2fc_enable function gained an
additional 1028 byte structure that gcc rightfully warns about:

drivers/scsi/bnx2fc/bnx2fc_fcoe.c: In function '__bnx2fc_enable':
drivers/scsi/bnx2fc/bnx2fc_fcoe.c:2134:1: warning: the frame size of 1128 bytes is larger than 1024 bytes [-Wframe-larger-than=]

In order to avoid a possible kernel stack overflow and to get rid
of the warning, this changes the function to use a dynamic allocation
of the structure using kzalloc.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 2971ff67bd3 ("bnx2fc: Read npiv table from nvram and create vports.")
---
The original patch was merged through netdev along with the respective
ethernet driver changes, but this should probably go through the scsi
tree, as no ethernet changes are involved.

diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index d5cdc4776707..72ba0dfae3e0 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -2092,7 +2092,7 @@ static int __bnx2fc_enable(struct fcoe_ctlr *ctlr)
 {
 	struct bnx2fc_interface *interface = fcoe_ctlr_priv(ctlr);
 	struct bnx2fc_hba *hba;
-	struct cnic_fc_npiv_tbl npiv_tbl;
+	struct cnic_fc_npiv_tbl *npiv_tbl;
 	struct fc_lport *lport;
 
 	if (interface->enabled == false) {
@@ -2124,11 +2124,16 @@ static int __bnx2fc_enable(struct fcoe_ctlr *ctlr)
 	if (!hba->cnic->get_fc_npiv_tbl)
 		goto done;
 
-	memset(&npiv_tbl, 0, sizeof(npiv_tbl));
-	if (hba->cnic->get_fc_npiv_tbl(hba->cnic, &npiv_tbl))
+	npiv_tbl = kzalloc(sizeof(struct cnic_fc_npiv_tbl), GFP_KERNEL);
+	if (!npiv_tbl)
 		goto done;
 
-	bnx2fc_npiv_create_vports(lport, &npiv_tbl);
+	if (hba->cnic->get_fc_npiv_tbl(hba->cnic, npiv_tbl))
+		goto done_free;
+
+	bnx2fc_npiv_create_vports(lport, npiv_tbl);
+done_free:
+	kfree(npiv_tbl);
 done:
 	return 0;
 }
