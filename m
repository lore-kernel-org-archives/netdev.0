From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] i40e: Reduce stack in i40e_dbg_dump_desc
Date: Sun, 16 Nov 2014 14:12:48 -0800
Message-ID: <1416175968.24600.1.camel@perches.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5467C3BA.6090003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0026.hostedemail.com ([216.40.44.26]:48962 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751432AbaKPWMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 17:12:51 -0500
In-Reply-To: <5467C3BA.6090003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce stack use by using kmemdup and not using a very
large struct on stack.

In function =E2=80=98i40e_dbg_dump_desc=E2=80=99:
warning: the frame size of 8192 bytes is larger than 2048 bytes [-Wfram=
e-larger-than=3D]

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 30 +++++++++++++++---=
--------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/n=
et/ethernet/intel/i40e/i40e_debugfs.c
index a03f459..232783d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -773,7 +773,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_sei=
d, int ring_id, int desc_n,
 {
 	struct i40e_tx_desc *txd;
 	union i40e_rx_desc *rxd;
-	struct i40e_ring ring;
+	struct i40e_ring *ring;
 	struct i40e_vsi *vsi;
 	int i;
=20
@@ -792,29 +792,32 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_s=
eid, int ring_id, int desc_n,
 			 vsi_seid);
 		return;
 	}
-	if (is_rx_ring)
-		ring =3D *vsi->rx_rings[ring_id];
-	else
-		ring =3D *vsi->tx_rings[ring_id];
+
+	ring =3D kmemdup(is_rx_ring
+		       ? vsi->rx_rings[ring_id] : vsi->tx_rings[ring_id],
+		       sizeof(*ring), GFP_KERNEL);
+	if (!ring)
+		return;
+
 	if (cnt =3D=3D 2) {
 		dev_info(&pf->pdev->dev, "vsi =3D %02i %s ring =3D %02i\n",
 			 vsi_seid, is_rx_ring ? "rx" : "tx", ring_id);
-		for (i =3D 0; i < ring.count; i++) {
+		for (i =3D 0; i < ring->count; i++) {
 			if (!is_rx_ring) {
-				txd =3D I40E_TX_DESC(&ring, i);
+				txd =3D I40E_TX_DESC(ring, i);
 				dev_info(&pf->pdev->dev,
 					 "   d[%03i] =3D 0x%016llx 0x%016llx\n",
 					 i, txd->buffer_addr,
 					 txd->cmd_type_offset_bsz);
 			} else if (sizeof(union i40e_rx_desc) =3D=3D
 				   sizeof(union i40e_16byte_rx_desc)) {
-				rxd =3D I40E_RX_DESC(&ring, i);
+				rxd =3D I40E_RX_DESC(ring, i);
 				dev_info(&pf->pdev->dev,
 					 "   d[%03i] =3D 0x%016llx 0x%016llx\n",
 					 i, rxd->read.pkt_addr,
 					 rxd->read.hdr_addr);
 			} else {
-				rxd =3D I40E_RX_DESC(&ring, i);
+				rxd =3D I40E_RX_DESC(ring, i);
 				dev_info(&pf->pdev->dev,
 					 "   d[%03i] =3D 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
 					 i, rxd->read.pkt_addr,
@@ -823,26 +826,26 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_s=
eid, int ring_id, int desc_n,
 			}
 		}
 	} else if (cnt =3D=3D 3) {
-		if (desc_n >=3D ring.count || desc_n < 0) {
+		if (desc_n >=3D ring->count || desc_n < 0) {
 			dev_info(&pf->pdev->dev,
 				 "descriptor %d not found\n", desc_n);
 			return;
 		}
 		if (!is_rx_ring) {
-			txd =3D I40E_TX_DESC(&ring, desc_n);
+			txd =3D I40E_TX_DESC(ring, desc_n);
 			dev_info(&pf->pdev->dev,
 				 "vsi =3D %02i tx ring =3D %02i d[%03i] =3D 0x%016llx 0x%016llx\n"=
,
 				 vsi_seid, ring_id, desc_n,
 				 txd->buffer_addr, txd->cmd_type_offset_bsz);
 		} else if (sizeof(union i40e_rx_desc) =3D=3D
 			   sizeof(union i40e_16byte_rx_desc)) {
-			rxd =3D I40E_RX_DESC(&ring, desc_n);
+			rxd =3D I40E_RX_DESC(ring, desc_n);
 			dev_info(&pf->pdev->dev,
 				 "vsi =3D %02i rx ring =3D %02i d[%03i] =3D 0x%016llx 0x%016llx\n"=
,
 				 vsi_seid, ring_id, desc_n,
 				 rxd->read.pkt_addr, rxd->read.hdr_addr);
 		} else {
-			rxd =3D I40E_RX_DESC(&ring, desc_n);
+			rxd =3D I40E_RX_DESC(ring, desc_n);
 			dev_info(&pf->pdev->dev,
 				 "vsi =3D %02i rx ring =3D %02i d[%03i] =3D 0x%016llx 0x%016llx 0x=
%016llx 0x%016llx\n",
 				 vsi_seid, ring_id, desc_n,
@@ -852,6 +855,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_sei=
d, int ring_id, int desc_n,
 	} else {
 		dev_info(&pf->pdev->dev, "dump desc rx/tx <vsi_seid> <ring_id> [<des=
c_n>]\n");
 	}
+	kfree(ring);
 }
=20
 /**
