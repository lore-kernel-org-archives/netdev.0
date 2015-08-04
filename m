From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH v2 net-next 4/4] bnx2fc: Read npiv table from nvram and create vports.
Date: Tue, 4 Aug 2015 09:37:30 +0300
Message-ID: <1438670250-20130-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <James.bottomley@HansenPartnership.com>,
	<linux-scsi-owner@vger.kernel.org>, <chad.dupuis@qlogic.com>,
	<Ariel.Elior@qlogic.com>, Joe Carnuccio <joe.carnuccio@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32691 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753318AbbHDGiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 02:38:00 -0400
In-Reply-To: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Carnuccio <joe.carnuccio@qlogic.com>

Signed-off-by: Joe Carnuccio <joe.carnuccio@qlogic.com>
Signed-off-by: Chad Dupuis <chad.dupuis@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c | 66 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 98d06d1..d5cdc47 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -2051,9 +2051,49 @@ static int bnx2fc_disable(struct net_device *netdev)
 	return rc;
 }
 
+static uint bnx2fc_npiv_create_vports(struct fc_lport *lport,
+				      struct cnic_fc_npiv_tbl *npiv_tbl)
+{
+	struct fc_vport_identifiers vpid;
+	uint i, created = 0;
+
+	if (npiv_tbl->count > MAX_NPIV_ENTRIES) {
+		BNX2FC_HBA_DBG(lport, "Exceeded count max of npiv table\n");
+		goto done;
+	}
+
+	/* Sanity check the first entry to make sure it's not 0 */
+	if (wwn_to_u64(npiv_tbl->wwnn[0]) == 0 &&
+	    wwn_to_u64(npiv_tbl->wwpn[0]) == 0) {
+		BNX2FC_HBA_DBG(lport, "First NPIV table entries invalid.\n");
+		goto done;
+	}
+
+	vpid.roles = FC_PORT_ROLE_FCP_INITIATOR;
+	vpid.vport_type = FC_PORTTYPE_NPIV;
+	vpid.disable = false;
+
+	for (i = 0; i < npiv_tbl->count; i++) {
+		vpid.node_name = wwn_to_u64(npiv_tbl->wwnn[i]);
+		vpid.port_name = wwn_to_u64(npiv_tbl->wwpn[i]);
+		scnprintf(vpid.symbolic_name, sizeof(vpid.symbolic_name),
+		    "NPIV[%u]:%016llx-%016llx",
+		    created, vpid.port_name, vpid.node_name);
+		if (fc_vport_create(lport->host, 0, &vpid))
+			created++;
+		else
+			BNX2FC_HBA_DBG(lport, "Failed to create vport\n");
+	}
+done:
+	return created;
+}
+
 static int __bnx2fc_enable(struct fcoe_ctlr *ctlr)
 {
 	struct bnx2fc_interface *interface = fcoe_ctlr_priv(ctlr);
+	struct bnx2fc_hba *hba;
+	struct cnic_fc_npiv_tbl npiv_tbl;
+	struct fc_lport *lport;
 
 	if (interface->enabled == false) {
 		if (!ctlr->lp) {
@@ -2064,6 +2104,32 @@ static int __bnx2fc_enable(struct fcoe_ctlr *ctlr)
 			interface->enabled = true;
 		}
 	}
+
+	/* Create static NPIV ports if any are contained in NVRAM */
+	hba = interface->hba;
+	lport = ctlr->lp;
+
+	if (!hba)
+		goto done;
+
+	if (!hba->cnic)
+		goto done;
+
+	if (!lport)
+		goto done;
+
+	if (!lport->host)
+		goto done;
+
+	if (!hba->cnic->get_fc_npiv_tbl)
+		goto done;
+
+	memset(&npiv_tbl, 0, sizeof(npiv_tbl));
+	if (hba->cnic->get_fc_npiv_tbl(hba->cnic, &npiv_tbl))
+		goto done;
+
+	bnx2fc_npiv_create_vports(lport, &npiv_tbl);
+done:
 	return 0;
 }
 
-- 
1.7.12.4
