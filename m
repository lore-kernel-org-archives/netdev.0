From: Weilong Chen <chenweilong@huawei.com>
Subject: [PATCH net-next] ixgbevf: fix 'Etherleak' in ixgbevf
Date: Thu, 15 Dec 2016 19:40:34 +0800
Message-ID: <1481802034-77729-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nessus report the vf appears to leak memory in network packets.
Fix this by padding all small packets manually.

And the CVE-2003-0001.
https://ofirarkin.files.wordpress.com/2008/11/atstake_etherleak_report.pdf

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 6d4bef5..137a154 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3654,6 +3654,13 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
+	/* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
+	 * packets may get corrupted during padding by HW.
+	 * To WA this issue, pad all small packets manually.
+	 */
+	if (eth_skb_pad(skb))
+		return NETDEV_TX_OK;
+
 	tx_ring = adapter->tx_ring[skb->queue_mapping];
 
 	/* need: 1 descriptor per page * PAGE_SIZE/IXGBE_MAX_DATA_PER_TXD,
-- 
1.7.12
