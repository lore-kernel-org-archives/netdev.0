From: sunil.kovvuri@gmail.com
Subject: [PATCH net 1/2] net: thunderx: Fix for HW issue while padding TSO packet
Date: Tue, 30 Aug 2016 11:36:26 +0530
Message-ID: <1472537187-21951-2-git-send-email-sunil.kovvuri@gmail.com>
References: <1472537187-21951-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472537187-21951-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

There is a issue in HW where-in while sending GSO sized pkts
as part of TSO, if pkt len falls below configured min packet
size i.e 60, NIC will zero PAD packet and also updates IP total length.
Hence set this value to lessthan min pkt size of MAC + IP + TCP
headers, BGX will anyway do the padding to transmit 64 byte pkt
including FCS.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 16ed203..85cc782 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -251,9 +251,14 @@ static void nic_set_tx_pkt_pad(struct nicpf *nic, int size)
 	int lmac;
 	u64 lmac_cfg;
 
-	/* Max value that can be set is 60 */
-	if (size > 60)
-		size = 60;
+	/* There is a issue in HW where-in while sending GSO sized
+	 * pkts as part of TSO, if pkt len falls below this size
+	 * NIC will zero PAD packet and also updates IP total length.
+	 * Hence set this value to lessthan min pkt size of MAC+IP+TCP
+	 * headers, BGX will do the padding to transmit 64 byte pkt.
+	 */
+	if (size > 52)
+		size = 52;
 
 	for (lmac = 0; lmac < (MAX_BGX_PER_CN88XX * MAX_LMAC_PER_BGX); lmac++) {
 		lmac_cfg = nic_reg_read(nic, NIC_PF_LMAC_0_7_CFG | (lmac << 3));
-- 
2.7.4
