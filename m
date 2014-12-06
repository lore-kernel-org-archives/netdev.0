From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 16/16] i40e: Reduce stack in i40e_dbg_dump_desc
Date: Sat,  6 Dec 2014 05:02:13 -0800
Message-ID: <1417870933-17248-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691AbaLFNDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:03:00 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>

Reduce stack use by using kmemdup and not using a very
large struct on stack.

In function =E2=80=98i40e_dbg_dump_desc=E2=80=99:
warning: the frame size of 8192 bytes is larger than 2048 bytes [-Wfram=
e-larger-than=3D]

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 30 +++++++++++++++---=
--------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/n=
et/ethernet/intel/i40e/i40e_debugfs.c
index 16ac3f8..433a558 100644
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
--=20
1.9.3
