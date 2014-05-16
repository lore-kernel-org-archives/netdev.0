From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] ehea: Introduce the use of the managed version of kzalloc
Date: Fri, 16 May 2014 23:37:25 +0530
Message-ID: <20140516180725.GA12976@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves data allocated using kzalloc to managed data allocated
using devm_kzalloc and cleans now unnecessary kfrees in probe and remove
functions.

The following Coccinelle semantic patch was used for making the change:

@platform@
identifier p, probefn, removefn;
@@
struct platform_driver p = {
  .probe = probefn,
  .remove = removefn,
};

@prb@
identifier platform.probefn, pdev;
expression e, e1, e2;
@@
probefn(struct platform_device *pdev, ...) {
  <+...
- e = kzalloc(e1, e2)
+ e = devm_kzalloc(&pdev->dev, e1, e2)
  ...
?-kfree(e);
  ...+>
}

@rem depends on prb@
identifier platform.removefn;
expression e;
@@
removefn(...) {
  <...
- kfree(e);
  ...>
}

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
Not compile tested due to incompatible architecture.

 drivers/net/ethernet/ibm/ehea/ehea_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 538903b..4dda3d1 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3273,7 +3273,7 @@ static int ehea_probe_adapter(struct platform_device *dev)
 		return -EINVAL;
 	}
 
-	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
+	adapter = devm_kzalloc(&dev->dev, sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
 		ret = -ENOMEM;
 		dev_err(&dev->dev, "no mem for ehea_adapter\n");
@@ -3359,7 +3359,6 @@ out_kill_eq:
 
 out_free_ad:
 	list_del(&adapter->list);
-	kfree(adapter);
 
 out:
 	ehea_update_firmware_handles();
@@ -3386,7 +3385,6 @@ static int ehea_remove(struct platform_device *dev)
 	ehea_destroy_eq(adapter->neq);
 	ehea_remove_adapter_mr(adapter);
 	list_del(&adapter->list);
-	kfree(adapter);
 
 	ehea_update_firmware_handles();
 
-- 
1.9.1
