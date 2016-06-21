From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 05/19] net: hns: Remove unnecessary device resource
 free
Date: Tue, 21 Jun 2016 11:56:25 +0800
Message-ID: <1466481399-70080-6-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
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

From: Qianqian Xie <xieqianqian@huawei.com>

The driver uses devm_ioremap_resource, it will unmap the map
automatically, remove the unnecessary the resource free.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Reported-by: Kefeng Wang <wangkefeng.wang@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 39 +++-------------------
 1 file changed, 4 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 422f97d..b8b2ff9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -176,7 +176,7 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	    desc_num > HNS_DSAF_MAX_DESC_CNT) {
 		dev_err(dsaf_dev->dev, "get desc-num(%d) fail, ret=%d!\n",
 			desc_num, ret);
-		goto unmap_base_addr;
+		return -EINVAL;
 	}
 	dsaf_dev->desc_num = desc_num;
 
@@ -192,7 +192,7 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	if (ret < 0) {
 		dev_err(dsaf_dev->dev,
 			"get buf-size fail, ret=%d!\r\n", ret);
-		goto unmap_base_addr;
+		return ret;
 	}
 	dsaf_dev->buf_size = buf_size;
 
@@ -200,7 +200,7 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	if (dsaf_dev->buf_size_type < 0) {
 		dev_err(dsaf_dev->dev,
 			"buf_size(%d) is wrong!\n", buf_size);
-		goto unmap_base_addr;
+		return -EINVAL;
 	}
 
 	dsaf_dev->misc_op = hns_misc_op_get(dsaf_dev);
@@ -213,32 +213,6 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 		dev_err(dsaf_dev->dev, "set mask to 64bit fail!\n");
 
 	return 0;
-
-unmap_base_addr:
-	if (dsaf_dev->io_base)
-		iounmap(dsaf_dev->io_base);
-	if (dsaf_dev->ppe_base)
-		iounmap(dsaf_dev->ppe_base);
-	if (dsaf_dev->sds_base)
-		iounmap(dsaf_dev->sds_base);
-	if (dsaf_dev->sc_base)
-		iounmap(dsaf_dev->sc_base);
-	return ret;
-}
-
-static void hns_dsaf_free_cfg(struct dsaf_device *dsaf_dev)
-{
-	if (dsaf_dev->io_base)
-		iounmap(dsaf_dev->io_base);
-
-	if (dsaf_dev->ppe_base)
-		iounmap(dsaf_dev->ppe_base);
-
-	if (dsaf_dev->sds_base)
-		iounmap(dsaf_dev->sds_base);
-
-	if (dsaf_dev->sc_base)
-		iounmap(dsaf_dev->sc_base);
 }
 
 /**
@@ -2645,7 +2619,7 @@ static int hns_dsaf_probe(struct platform_device *pdev)
 
 	ret = hns_dsaf_init(dsaf_dev);
 	if (ret)
-		goto free_cfg;
+		goto free_dev;
 
 	ret = hns_mac_init(dsaf_dev);
 	if (ret)
@@ -2670,9 +2644,6 @@ uninit_mac:
 uninit_dsaf:
 	hns_dsaf_free(dsaf_dev);
 
-free_cfg:
-	hns_dsaf_free_cfg(dsaf_dev);
-
 free_dev:
 	hns_dsaf_free_dev(dsaf_dev);
 
@@ -2695,8 +2666,6 @@ static int hns_dsaf_remove(struct platform_device *pdev)
 
 	hns_dsaf_free(dsaf_dev);
 
-	hns_dsaf_free_cfg(dsaf_dev);
-
 	hns_dsaf_free_dev(dsaf_dev);
 
 	return 0;
-- 
1.9.1
