From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/1][ATM]: [he] when transmit fails, unmap the dma regions
Date: Thu, 07 Sep 2006 17:57:59 -0400
Message-ID: <200609072158.k87Lvx2v022151@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:23523 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1751875AbWIGV6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 17:58:13 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: [he] when transmit fails, unmap the dma regions

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit e2c84ae30cb2dca23afb5e811c108e235f941c3d
tree a4acb86e2e10baa5ac651e566a550e0af0c55507
parent 0d60b74cf4354672e4586ca2bedde6695db43165
author chas williams <chas@relax.cmf.nrl.navy.mil> Thu, 07 Sep 2006 17:04:14 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Thu, 07 Sep 2006 17:04:14 -0400

 drivers/atm/he.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index d369130..dd96123 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2282,6 +2282,8 @@ __enqueue_tpd(struct he_dev *he_dev, str
 				TPDRQ_MASK(he_readl(he_dev, TPDRQ_B_H)));
 
 		if (new_tail == he_dev->tpdrq_head) {
+			int slot;
+
 			hprintk("tpdrq full (cid 0x%x)\n", cid);
 			/*
 			 * FIXME
@@ -2289,6 +2291,13 @@ __enqueue_tpd(struct he_dev *he_dev, str
 			 * after service_tbrq, service the backlog
 			 * for now, we just drop the pdu
 			 */
+			for (slot = 0; slot < TPD_MAXIOV; ++slot) {
+				if (tpd->iovec[slot].addr)
+					pci_unmap_single(he_dev->pci_dev,
+						tpd->iovec[slot].addr,
+						tpd->iovec[slot].len & TPD_LEN_MASK,
+								PCI_DMA_TODEVICE);
+			}
 			if (tpd->skb) {
 				if (tpd->vcc->pop)
 					tpd->vcc->pop(tpd->vcc, tpd->skb);
