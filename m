From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH net-next] net: sxgbe: fix potential null dereference
Date: Fri, 28 Mar 2014 10:57:44 -0700
Message-ID: <031c01cf4aaf$3a4227a0$aec676e0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'kbuild test robot' <fengguang.wu@intel.com>,
	'Girish K S' <ks.giri@samsung.com>,
	'Siva Reddy' <siva.kallam@samsung.com>,
	'Vipul Pandya' <vipul.pandya@samsung.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>

This fixes following:

drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:1828 sxgbe_hw_init()
error: potential null dereference 'priv->hw'.  (kmalloc returns null)

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index ee1fd3c..a72688e 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -2039,11 +2039,13 @@ static void sxgbe_get_ops(struct sxgbe_ops * const ops_ptr)
  *  Description: this function checks the HW capability
  *  (if supported) and sets the driver's features.
  */
-static void sxgbe_hw_init(struct sxgbe_priv_data * const priv)
+static int sxgbe_hw_init(struct sxgbe_priv_data * const priv)
 {
 	u32 ctrl_ids;
 
 	priv->hw = kmalloc(sizeof(*priv->hw), GFP_KERNEL);
+	if(!priv->hw)
+		return -ENOMEM;
 
 	/* get the hardware ops */
 	sxgbe_get_ops(priv->hw);
@@ -2064,6 +2066,8 @@ static void sxgbe_hw_init(struct sxgbe_priv_data * const priv)
 
 	if (priv->hw_cap.rx_csum_offload)
 		pr_info("RX Checksum offload supported\n");
+
+	return 0;
 }
 
 /**
@@ -2102,7 +2106,9 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 	sxgbe_verify_args();
 
 	/* Init MAC and get the capabilities */
-	sxgbe_hw_init(priv);
+	ret = sxgbe_hw_init(priv);
+	if (ret)
+		goto error_free_netdev;
 
 	/* allocate memory resources for Descriptor rings */
 	ret = txring_mem_alloc(priv);
-- 
1.7.10.4
