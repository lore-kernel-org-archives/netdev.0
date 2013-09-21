From: Roger Luethi <rl@hellgate.ch>
Subject: [PATCH] via-rhine: fix VLAN priority field (PCP, IEEE 802.1p)
Date: Sat, 21 Sep 2013 14:24:11 +0200
Message-ID: <20130921122411.GA25499@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Peter =?iso-8859-1?Q?Bostr=F6m?= <peter.bostrom@netrounds.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zhbdzmsp-smta17.bluewin.ch ([195.186.99.133]:47428 "EHLO
	zhbdzmsp-smta17.bluewin.ch" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751721Ab3IUMbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 08:31:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Roger Luethi <rl@hellgate.ch>

Outgoing packets sent by via-rhine have their VLAN PCP field off by one
(when hardware acceleration is enabled). The TX descriptor expects only=
 VID
and PCP (without a CFI/DEI bit).

Peter Bostr=F6m noticed and reported the bug.

Signed-off-by: Roger Luethi <rl@hellgate.ch>
Cc: Peter Bostr=F6m <peter.bostrom@netrounds.com>
---
 drivers/net/ethernet/via/via-rhine.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/etherne=
t/via/via-rhine.c
index c8f088a..bdf697b 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -32,7 +32,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
=20
 #define DRV_NAME	"via-rhine"
-#define DRV_VERSION	"1.5.0"
+#define DRV_VERSION	"1.5.1"
 #define DRV_RELDATE	"2010-10-09"
=20
 #include <linux/types.h>
@@ -1704,7 +1704,12 @@ static netdev_tx_t rhine_start_tx(struct sk_buff=
 *skb,
 		cpu_to_le32(TXDESC | (skb->len >=3D ETH_ZLEN ? skb->len : ETH_ZLEN))=
;
=20
 	if (unlikely(vlan_tx_tag_present(skb))) {
-		rp->tx_ring[entry].tx_status =3D cpu_to_le32((vlan_tx_tag_get(skb)) =
<< 16);
+		u16 vid_pcp =3D vlan_tx_tag_get(skb);
+
+		/* drop CFI/DEI bit, register needs VID and PCP */
+		vid_pcp =3D (vid_pcp & VLAN_VID_MASK) |
+			  ((vid_pcp & VLAN_PRIO_MASK) >> 1);
+		rp->tx_ring[entry].tx_status =3D cpu_to_le32((vid_pcp) << 16);
 		/* request tagging */
 		rp->tx_ring[entry].desc_length |=3D cpu_to_le32(0x020000);
 	}
