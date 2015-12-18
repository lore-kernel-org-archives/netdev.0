From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH v2 net] bnx2x: Prevent FW assertion when using Vxlan
Date: Fri, 18 Dec 2015 10:42:12 +0200
Message-ID: <1450428132-16697-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sergei.shtylyov@cogentembedded.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:30193 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932327AbbLRImf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 03:42:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FW has a rare corner case in which a fragmented packet using lots
of frags would not be linearized, causing the FW to assert while trying
to transmit the packet.

To prevent this, we need to make sure the window of fragements containing
MSS worth of data contains 1 BD less than for regular packets due to
the additional parsing BD.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Changes from V1:
  - Corrected indentation [Thanks Sergei].

Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f8d7a2f..3718362 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3430,25 +3430,29 @@ static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 	return rc;
 }
 
-#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
+/* VXLAN: 4 = 1 (for linear data BD) + 3 (2 for PBD and last BD) */
+#define BNX2X_NUM_VXLAN_TSO_WIN_SUB_BDS         4
+
+/* Regular: 3 = 1 (for linear data BD) + 2 (for PBD and last BD) */
+#define BNX2X_NUM_TSO_WIN_SUB_BDS               3
+
+#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - BDS_PER_TX_PKT)
 /* check if packet requires linearization (packet is too fragmented)
    no need to check fragmentation if page size > 8K (there will be no
    violation to FW restrictions) */
 static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
 			     u32 xmit_type)
 {
-	int to_copy = 0;
-	int hlen = 0;
-	int first_bd_sz = 0;
+	int first_bd_sz = 0, num_tso_win_sub = BNX2X_NUM_TSO_WIN_SUB_BDS;
+	int to_copy = 0, hlen = 0;
 
-	/* 3 = 1 (for linear data BD) + 2 (for PBD and last BD) */
-	if (skb_shinfo(skb)->nr_frags >= (MAX_FETCH_BD - 3)) {
+	if (xmit_type & XMIT_GSO_ENC)
+		num_tso_win_sub = BNX2X_NUM_VXLAN_TSO_WIN_SUB_BDS;
 
+	if (skb_shinfo(skb)->nr_frags >= (MAX_FETCH_BD - num_tso_win_sub)) {
 		if (xmit_type & XMIT_GSO) {
 			unsigned short lso_mss = skb_shinfo(skb)->gso_size;
-			/* Check if LSO packet needs to be copied:
-			   3 = 1 (for headers BD) + 2 (for PBD and last BD) */
-			int wnd_size = MAX_FETCH_BD - 3;
+			int wnd_size = MAX_FETCH_BD - num_tso_win_sub;
 			/* Number of windows to check */
 			int num_wnds = skb_shinfo(skb)->nr_frags - wnd_size;
 			int wnd_idx = 0;
-- 
1.9.3
