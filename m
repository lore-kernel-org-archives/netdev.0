From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 4/4] net: hns: fix device reference leaks
Date: Thu,  3 Nov 2016 18:40:22 +0100
Message-ID: <1478194822-29545-5-git-send-email-johan@kernel.org>
References: <1478194822-29545-1-git-send-email-johan@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478194822-29545-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by class_find_device() in
hnae_get_handle() on errors and when later releasing the handle.

Fixes: 6fe6611ff275 ("net: add Hisilicon Network Subsystem...")
Cc: Yisen Zhuang <yisen.zhuang@huawei.com>
Cc: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/hisilicon/hns/hnae.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index c54c6fac0d1d..b6ed818f78ff 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -332,8 +332,10 @@ struct hnae_handle *hnae_get_handle(struct device *owner_dev,
 		return ERR_PTR(-ENODEV);
 
 	handle = dev->ops->get_handle(dev, port_id);
-	if (IS_ERR(handle))
+	if (IS_ERR(handle)) {
+		put_device(&dev->cls_dev);
 		return handle;
+	}
 
 	handle->dev = dev;
 	handle->owner_dev = owner_dev;
@@ -356,6 +358,8 @@ struct hnae_handle *hnae_get_handle(struct device *owner_dev,
 	for (j = i - 1; j >= 0; j--)
 		hnae_fini_queue(handle->qs[j]);
 
+	put_device(&dev->cls_dev);
+
 	return ERR_PTR(-ENOMEM);
 }
 EXPORT_SYMBOL(hnae_get_handle);
@@ -377,6 +381,8 @@ void hnae_put_handle(struct hnae_handle *h)
 		dev->ops->put_handle(h);
 
 	module_put(dev->owner);
+
+	put_device(&dev->cls_dev);
 }
 EXPORT_SYMBOL(hnae_put_handle);
 
-- 
2.7.3
