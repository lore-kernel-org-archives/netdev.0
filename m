From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 1/2] be2net: Mark checksum fail for IP fragmented packets
Date: Thu, 30 May 2013 14:25:56 +0530
Message-ID: <506aab59-7a41-4b4f-97e6-35f587fe9705@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8140 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967933Ab3E3I5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 04:57:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW does not compute L4 checksum for IP Fragmented packets.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_hw.h   |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |    7 ++++++-
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index f544b29..0a51068 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -262,6 +262,7 @@ struct be_rx_compl_info {
 	u8 ipv6;
 	u8 vtm;
 	u8 pkt_type;
+	u8 ip_frag;
 };
 
 struct be_rx_obj {
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 3c1099b..8780183 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -356,7 +356,7 @@ struct amap_eth_rx_compl_v0 {
 	u8 ip_version;		/* dword 1 */
 	u8 macdst[6];		/* dword 1 */
 	u8 vtp;			/* dword 1 */
-	u8 rsvd0;		/* dword 1 */
+	u8 ip_frag;		/* dword 1 */
 	u8 fragndx[10];		/* dword 1 */
 	u8 ct[2];		/* dword 1 */
 	u8 sw;			/* dword 1 */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ca2967b..32a6927 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1599,6 +1599,8 @@ static void be_parse_rx_compl_v0(struct be_eth_rx_compl *compl,
 					       compl);
 	}
 	rxcp->port = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, port, compl);
+	rxcp->ip_frag = AMAP_GET_BITS(struct amap_eth_rx_compl_v0,
+				      ip_frag, compl);
 }
 
 static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
@@ -1620,6 +1622,9 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
 	else
 		be_parse_rx_compl_v0(compl, rxcp);
 
+	if (rxcp->ip_frag)
+		rxcp->l4_csum = 0;
+
 	if (rxcp->vlanf) {
 		/* vlanf could be wrongly set in some cards.
 		 * ignore if vtm is not set */
@@ -2168,7 +2173,7 @@ static irqreturn_t be_msix(int irq, void *dev)
 
 static inline bool do_gro(struct be_rx_compl_info *rxcp)
 {
-	return (rxcp->tcpf && !rxcp->err) ? true : false;
+	return (rxcp->tcpf && !rxcp->err && rxcp->l4_csum) ? true : false;
 }
 
 static int be_process_rx(struct be_rx_obj *rxo, struct napi_struct *napi,
-- 
1.6.0.2
