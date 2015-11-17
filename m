From: Salil <salil.mehta@huawei.com>
Subject: [PATCH V2 net-next 2/5] net:hns: Add Hip06 "RSS(Receive Side
 Scaling)" support to HNS Driver
Date: Wed, 18 Nov 2015 02:52:24 +0800
Message-ID: <1447786347-147518-3-git-send-email-salil.mehta@huawei.com>
References: <1447786347-147518-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <paul.gortmaker@windriver.com>,
 <ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
 <catalin.marinas@arm.com>, <will.deacon@arm.com>, <arnd@arndb.de>,
 <liguozhu@hisilicon.com>, <yisen.zhuang@huawei.com>,
 <dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
 <huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
 <salil.mehta@huawei.com>, <mehta.salil.lnk@gmail.com>,
 <xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
 <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
 <linuxarm@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1447786347-147518-1-git-send-email-salil.mehta@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>

This patch adds the support of "RSS (Receive Side Scaling)" feature
provided by the Hip06 ethernet hardware to the HNS ethernet
driver.

This feature helps in distributing the different flows (mapped as
hash by hardware using Toeplitz Hash) to different Queues asssociated
with the processor cores. The mapping of flow-hash values to the
different queues is stored in indirection table (which is per Packet-
parse-Engine/PPE). This patch also provides the changes to re-program
the (flow-hash<->Qid) mapping using the ethtool.

PATCH V2:
- Fix for review-comments on PATCH V1 by Yisen.Zhuang(Zhuangyuzeng)
  Link: https://lkml.org/lkml/2015/10/21/1032
- Rework for Internal review comments by Kenneth Lee

PATCH V1:
- Initial version to support RSS and its Ethtool interface on
  Hip06 SoC

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
Reviewed-by: Kenneth Lee <liguozhu@huawei.com>
---
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         |    6 ++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |   53 +++++++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |   61 +++++++++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h |   32 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |   14 ++++
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  |   93 +++++++++++++++++++++
 6 files changed, 249 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index aa53dd3..1ee42cb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -483,6 +483,12 @@ struct hnae_ae_ops {
 			  enum hnae_led_state status);
 	void (*get_regs)(struct hnae_handle *handle, void *data);
 	int (*get_regs_len)(struct hnae_handle *handle);
+	u32	(*get_rss_key_size)(struct hnae_handle *handle);
+	u32	(*get_rss_indir_size)(struct hnae_handle *handle);
+	int	(*get_rss)(struct hnae_handle *handle, u32 *indir, u8 *key,
+			   u8 *hfunc);
+	int	(*set_rss)(struct hnae_handle *handle, const u32 *indir,
+			   const u8 *key, const u8 hfunc);
 };
 
 struct hnae_ae_dev {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index c03bc1e..e5a31bc 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -749,6 +749,53 @@ int hns_ae_get_regs_len(struct hnae_handle *handle)
 	return total_num;
 }
 
+static u32 hns_ae_get_rss_key_size(struct hnae_handle *handle)
+{
+	return HNS_PPEV2_RSS_KEY_SIZE;
+}
+
+static u32 hns_ae_get_rss_indir_size(struct hnae_handle *handle)
+{
+	return HNS_PPEV2_RSS_IND_TBL_SIZE;
+}
+
+static int hns_ae_get_rss(struct hnae_handle *handle, u32 *indir, u8 *key,
+			  u8 *hfunc)
+{
+	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
+
+	/* currently we support only one type of hash function i.e. Toep hash */
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	/* get the RSS Key required by the user */
+	if (key)
+		memcpy(key, ppe_cb->rss_key, HNS_PPEV2_RSS_KEY_SIZE);
+
+	/* update the current hash->queue mappings from the shadow RSS table */
+	memcpy(indir, ppe_cb->rss_indir_table, HNS_PPEV2_RSS_IND_TBL_SIZE);
+
+	return 0;
+}
+
+static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
+			  const u8 *key, const u8 hfunc)
+{
+	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
+
+	/* set the RSS Hash Key if specififed by the user */
+	if (key)
+		hns_ppe_set_rss_key(ppe_cb, (int *)key);
+
+	/* update the shadow RSS table with user specified qids */
+	memcpy(ppe_cb->rss_indir_table, indir, HNS_PPEV2_RSS_IND_TBL_SIZE);
+
+	/* now update the hardware */
+	hns_ppe_set_indir_table(ppe_cb, ppe_cb->rss_indir_table);
+
+	return 0;
+}
+
 static struct hnae_ae_ops hns_dsaf_ops = {
 	.get_handle = hns_ae_get_handle,
 	.put_handle = hns_ae_put_handle,
@@ -783,7 +830,11 @@ static struct hnae_ae_ops hns_dsaf_ops = {
 	.update_led_status = hns_ae_update_led_status,
 	.set_led_id = hns_ae_cpld_set_led_id,
 	.get_regs = hns_ae_get_regs,
-	.get_regs_len = hns_ae_get_regs_len
+	.get_regs_len = hns_ae_get_regs_len,
+	.get_rss_key_size = hns_ae_get_rss_key_size,
+	.get_rss_indir_size = hns_ae_get_rss_indir_size,
+	.get_rss = hns_ae_get_rss,
+	.set_rss = hns_ae_set_rss
 };
 
 int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 9531992..824fe50 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -19,6 +19,43 @@
 
 #include "hns_dsaf_ppe.h"
 
+void hns_ppe_set_rss_key(struct hns_ppe_cb *ppe_cb,
+			 const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM])
+{
+	int key_item = 0;
+
+	for (key_item = 0; key_item < HNS_PPEV2_RSS_KEY_NUM; key_item++)
+		dsaf_write_dev(ppe_cb, PPEV2_RSS_KEY_REG + key_item * 0x4,
+			       rss_key[key_item]);
+}
+
+void hns_ppe_set_indir_table(struct hns_ppe_cb *ppe_cb,
+			     const u32 rss_tab[HNS_PPEV2_RSS_IND_TBL_SIZE])
+{
+	int i;
+	int reg_value;
+
+	for (i = 0; i < (HNS_PPEV2_RSS_IND_TBL_SIZE / 4); i++) {
+		reg_value = dsaf_read_dev(ppe_cb,
+					  PPEV2_INDRECTION_TBL_REG + i * 0x4);
+
+		dsaf_set_field(reg_value, PPEV2_CFG_RSS_TBL_4N0_M,
+			       PPEV2_CFG_RSS_TBL_4N0_S,
+			       rss_tab[i * 4 + 0] & 0x1F);
+		dsaf_set_field(reg_value, PPEV2_CFG_RSS_TBL_4N1_M,
+			       PPEV2_CFG_RSS_TBL_4N1_S,
+				rss_tab[i * 4 + 1] & 0x1F);
+		dsaf_set_field(reg_value, PPEV2_CFG_RSS_TBL_4N2_M,
+			       PPEV2_CFG_RSS_TBL_4N2_S,
+				rss_tab[i * 4 + 2] & 0x1F);
+		dsaf_set_field(reg_value, PPEV2_CFG_RSS_TBL_4N3_M,
+			       PPEV2_CFG_RSS_TBL_4N3_S,
+				rss_tab[i * 4 + 3] & 0x1F);
+		dsaf_write_dev(
+			ppe_cb, PPEV2_INDRECTION_TBL_REG + i * 0x4, reg_value);
+	}
+}
+
 static void __iomem *hns_ppe_common_get_ioaddr(
 	struct ppe_common_cb *ppe_common)
 {
@@ -266,13 +303,26 @@ static void hns_ppe_exc_irq_en(struct hns_ppe_cb *ppe_cb, int en)
 
 /**
  * ppe_init_hw - init ppe
- * @ppe_device: ppe device
+ * @ppe_cb: ppe device
  */
 static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 {
 	struct ppe_common_cb *ppe_common_cb = ppe_cb->ppe_common_cb;
 	u32 port = ppe_cb->port;
 	struct dsaf_device *dsaf_dev = ppe_common_cb->dsaf_dev;
+	int i;
+	/* Set default RSS key and indrection table*/
+	const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM] = {
+		0x6d5a56da, 0x255b0ec2,
+		0x4167253d, 0x43a38fb0,
+		0xd0ca2bcb, 0xae7b30b4,
+		0x77cb2da3, 0x8030f20c,
+		0x6a42b73b, 0xbeac01fa,
+	};
+
+	/* set default RSS key and remember it */
+	for (i = 0; i < HNS_PPEV2_RSS_KEY_NUM; i++)
+		ppe_cb->rss_key[i]  = rss_key[i];
 
 	hns_ppe_srst_by_port(dsaf_dev, port, 0);
 	mdelay(10);
@@ -285,8 +335,17 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 		hns_ppe_set_port_mode(ppe_cb, PPE_MODE_GE);
 	else
 		hns_ppe_set_port_mode(ppe_cb, PPE_MODE_XGE);
+
 	hns_ppe_checksum_hw(ppe_cb, 0xffffffff);
 	hns_ppe_cnt_clr_ce(ppe_cb);
+
+	if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		hns_ppe_set_rss_key(ppe_cb, rss_key);
+
+		for (i = 0; i < HNS_PPEV2_RSS_IND_TBL_SIZE; i++)
+			ppe_cb->rss_indir_table[i] = i;
+		hns_ppe_set_indir_table(ppe_cb, ppe_cb->rss_indir_table);
+	}
 }
 
 /**
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
index 4894f9a..dac8532 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
@@ -25,15 +25,24 @@
 
 #define ETH_PPE_DUMP_NUM 576
 #define ETH_PPE_STATIC_NUM 12
+
+#define HNS_PPEV2_RSS_IND_TBL_SIZE 256
+#define HNS_PPEV2_RSS_KEY_SIZE 40 /* in bytes or 320 bits */
+#define HNS_PPEV2_RSS_KEY_NUM (HNS_PPEV2_RSS_KEY_SIZE / sizeof(u32))
+
 enum ppe_qid_mode {
-	PPE_QID_MODE0 = 0,	/* fixed queue id mode */
-	PPE_QID_MODE1,		/* switch:128VM non switch:6Port/4VM/4TC */
-	PPE_QID_MODE2,		/* switch:32VM/4TC non switch:6Port/16VM */
-	PPE_QID_MODE3,		/* switch:4TC/8TAG non switch:2Port/64VM */
-	PPE_QID_MODE4,		/* switch:8VM/16TAG non switch:2Port/16VM/4TC */
-	PPE_QID_MODE5,		/* non switch:6Port/16TAG */
-	PPE_QID_MODE6,		/* non switch:6Port/2VM/8TC */
-	PPE_QID_MODE7,		/* non switch:2Port/8VM/8TC */
+	PPE_QID_MODE0 = 0, /* fixed queue id mode */
+	PPE_QID_MODE1,	   /* switch:128VM non switch:6Port/4VM/4TC */
+	PPE_QID_MODE2,	   /* switch:32VM/4TC non switch:6Port/16VM */
+	PPE_QID_MODE3,	   /* switch:4TC/8RSS non switch:2Port/64VM */
+	PPE_QID_MODE4,	   /* switch:8VM/16RSS non switch:2Port/16VM/4TC */
+	PPE_QID_MODE5,	   /* switch:16VM/8TC non switch:6Port/16RSS */
+	PPE_QID_MODE6,	   /* switch:32VM/4RSS non switch:6Port/2VM/8TC */
+	PPE_QID_MODE7,	   /* switch:32RSS non switch:2Port/8VM/8TC */
+	PPE_QID_MODE8,	   /* switch:6VM/4TC/4RSS non switch:2Port/16VM/4RSS */
+	PPE_QID_MODE9,	   /* non switch:2Port/32VM/2RSS */
+	PPE_QID_MODE10,	   /* non switch:2Port/32RSS */
+	PPE_QID_MODE11,	   /* non switch:2Port/4TC/16RSS */
 };
 
 enum ppe_port_mode {
@@ -72,6 +81,8 @@ struct hns_ppe_cb {
 	u8 port;			 /* port id in dsaf  */
 	void __iomem *io_base;
 	int virq;
+	u32 rss_indir_table[HNS_PPEV2_RSS_IND_TBL_SIZE]; /*shadow indir tab */
+	u32 rss_key[HNS_PPEV2_RSS_KEY_NUM]; /* rss hash key */
 };
 
 struct ppe_common_cb {
@@ -102,4 +113,9 @@ void hns_ppe_get_regs(struct hns_ppe_cb *ppe_cb, void *data);
 
 void hns_ppe_get_strings(struct hns_ppe_cb *ppe_cb, int stringset, u8 *data);
 void hns_ppe_get_stats(struct hns_ppe_cb *ppe_cb, u64 *data);
+
+void hns_ppe_set_rss_key(struct hns_ppe_cb *ppe_cb,
+			 const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM]);
+void hns_ppe_set_indir_table(struct hns_ppe_cb *ppe_cb,
+			     const u32 rss_tab[HNS_PPEV2_RSS_IND_TBL_SIZE]);
 #endif /* _HNS_DSAF_PPE_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index cb0e9e1..b070d57 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -349,6 +349,8 @@
 #define PPE_ECO0_REG				0x32C
 #define PPE_ECO1_REG				0x330
 #define PPE_ECO2_REG				0x334
+#define PPEV2_INDRECTION_TBL_REG		0x800
+#define PPEV2_RSS_KEY_REG			0x900
 
 #define RCB_COM_CFG_ENDIAN_REG			0x0
 #define RCB_COM_CFG_SYS_FSH_REG			0xC
@@ -839,6 +841,18 @@
 #define PPE_CFG_QID_MODE_CF_QID_MODE_S	8
 #define PPE_CFG_QID_MODE_CF_QID_MODE_M	(0x7 << PPE_CFG_QID_MODE_CF_QID_MODE_S)
 
+#define PPEV2_CFG_RSS_TBL_4N0_S	0
+#define PPEV2_CFG_RSS_TBL_4N0_M	(((1UL << 5) - 1) << PPEV2_CFG_RSS_TBL_4N0_S)
+
+#define PPEV2_CFG_RSS_TBL_4N1_S	8
+#define PPEV2_CFG_RSS_TBL_4N1_M	(((1UL << 5) - 1) << PPEV2_CFG_RSS_TBL_4N1_S)
+
+#define PPEV2_CFG_RSS_TBL_4N2_S	16
+#define PPEV2_CFG_RSS_TBL_4N2_M	(((1UL << 5) - 1) << PPEV2_CFG_RSS_TBL_4N2_S)
+
+#define PPEV2_CFG_RSS_TBL_4N3_S	24
+#define PPEV2_CFG_RSS_TBL_4N3_M	(((1UL << 5) - 1) << PPEV2_CFG_RSS_TBL_4N3_S)
+
 #define PPE_CNT_CLR_CE_B	0
 #define PPE_CNT_CLR_SNAP_EN_B	1
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 9df63ae..3b23417 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -1187,6 +1187,95 @@ static int hns_nic_nway_reset(struct net_device *netdev)
 	return ret;
 }
 
+static u32
+hns_get_rss_key_size(struct net_device *netdev)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_ae_ops *ops;
+	u32 ret;
+
+	if (AE_IS_VER1(priv->enet_ver)) {
+		netdev_err(netdev,
+			   "RSS feature is not supported on this hardware\n");
+		return -EOPNOTSUPP;
+	}
+
+	ops = priv->ae_handle->dev->ops;
+	ret = ops->get_rss_key_size(priv->ae_handle);
+
+	return ret;
+}
+
+static u32
+hns_get_rss_indir_size(struct net_device *netdev)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_ae_ops *ops;
+	u32 ret;
+
+	if (AE_IS_VER1(priv->enet_ver)) {
+		netdev_err(netdev,
+			   "RSS feature is not supported on this hardware\n");
+		return -EOPNOTSUPP;
+	}
+
+	ops = priv->ae_handle->dev->ops;
+	ret = ops->get_rss_indir_size(priv->ae_handle);
+
+	return ret;
+}
+
+static int
+hns_get_rss(struct net_device *netdev, u32 *indir, u8 *key, u8 *hfunc)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_ae_ops *ops;
+	int ret;
+
+	if (AE_IS_VER1(priv->enet_ver)) {
+		netdev_err(netdev,
+			   "RSS feature is not supported on this hardware\n");
+		return -EOPNOTSUPP;
+	}
+
+	ops = priv->ae_handle->dev->ops;
+
+	if (!indir)
+		return 0;
+
+	ret = ops->get_rss(priv->ae_handle, indir, key, hfunc);
+
+	return 0;
+}
+
+static int
+hns_set_rss(struct net_device *netdev, const u32 *indir, const u8 *key,
+	    const u8 hfunc)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_ae_ops *ops;
+	int ret;
+
+	if (AE_IS_VER1(priv->enet_ver)) {
+		netdev_err(netdev,
+			   "RSS feature is not supported on this hardware\n");
+		return -EOPNOTSUPP;
+	}
+
+	ops = priv->ae_handle->dev->ops;
+
+	/* currently hfunc can only be Toeplitz hash */
+	if (key ||
+	    (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP))
+		return -EOPNOTSUPP;
+	if (!indir)
+		return 0;
+
+	ret = ops->set_rss(priv->ae_handle, indir, key, hfunc);
+
+	return 0;
+}
+
 static struct ethtool_ops hns_ethtool_ops = {
 	.get_drvinfo = hns_nic_get_drvinfo,
 	.get_link  = hns_nic_get_link,
@@ -1206,6 +1295,10 @@ static struct ethtool_ops hns_ethtool_ops = {
 	.get_regs_len = hns_get_regs_len,
 	.get_regs = hns_get_regs,
 	.nway_reset = hns_nic_nway_reset,
+	.get_rxfh_key_size = hns_get_rss_key_size,
+	.get_rxfh_indir_size = hns_get_rss_indir_size,
+	.get_rxfh = hns_get_rss,
+	.set_rxfh = hns_set_rss,
 };
 
 void hns_ethtool_set_ops(struct net_device *ndev)
-- 
1.7.9.5
