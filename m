From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: software iwarp stack update
Date: Sat, 18 Jun 2011 18:35:42 +0200
Message-ID: <BANLkTi=L057TZug2=nrFZTYdNoHLMvmBRA@mail.gmail.com>
References: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com>
 <OFB7458EEB.BFB8A4EE-ONC12578B1.004026D1-C12578B1.0041190E@ch.ibm.com> <BANLkTi=2woNzF=GL3cT3NB_hye5JHfodMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTi=2woNzF=GL3cT3NB_hye5JHfodMA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2011 at 7:20 PM, Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org> wrote:
> It does seem we are missing an IB_MANDATORY_FUNC
> entry for modify_port in ib_device_check_mandatory; or on
> the flip side we are missing a check of modify_port and a
> -ENOSYS return... I guess modify_port does not really make
> sense for iWARP so probably the second option is better.

There seems to be disagreement about whether to return 0, -ENOSYS or
-EOPNOTSUPP for not supported functionality. Does the patch below make sense ?
Note: I don't have all the hardware necessary to test the patch below.

diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 4007f72..e711de4 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -627,6 +627,9 @@ int ib_modify_device(struct ib_device *device,
 		     int device_modify_mask,
 		     struct ib_device_modify *device_modify)
 {
+	if (!device->modify_device)
+		return -ENOSYS;
+
 	return device->modify_device(device, device_modify_mask,
 				     device_modify);
 }
@@ -647,6 +650,9 @@ int ib_modify_port(struct ib_device *device,
 		   u8 port_num, int port_modify_mask,
 		   struct ib_port_modify *port_modify)
 {
+	if (!device->modify_port)
+		return -ENOSYS;
+
 	if (port_num < start_port(device) || port_num > end_port(device))
 		return -EINVAL;

diff --git a/drivers/infiniband/hw/amso1100/c2_provider.c
b/drivers/infiniband/hw/amso1100/c2_provider.c
index aeebc4d..f101bb7 100644
--- a/drivers/infiniband/hw/amso1100/c2_provider.c
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c
@@ -99,14 +99,6 @@ static int c2_query_port(struct ib_device *ibdev,
 	return 0;
 }

-static int c2_modify_port(struct ib_device *ibdev,
-			  u8 port, int port_modify_mask,
-			  struct ib_port_modify *props)
-{
-	pr_debug("%s:%u\n", __func__, __LINE__);
-	return 0;
-}
-
 static int c2_query_pkey(struct ib_device *ibdev,
 			 u8 port, u16 index, u16 * pkey)
 {
@@ -817,7 +809,6 @@ int c2_register_device(struct c2_dev *dev)
 	dev->ibdev.dma_device = &dev->pcidev->dev;
 	dev->ibdev.query_device = c2_query_device;
 	dev->ibdev.query_port = c2_query_port;
-	dev->ibdev.modify_port = c2_modify_port;
 	dev->ibdev.query_pkey = c2_query_pkey;
 	dev->ibdev.query_gid = c2_query_gid;
 	dev->ibdev.alloc_ucontext = c2_alloc_ucontext;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c
b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index 2e27413..c7d9411 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -61,13 +61,6 @@
 #include "iwch_user.h"
 #include "common.h"

-static int iwch_modify_port(struct ib_device *ibdev,
-			    u8 port, int port_modify_mask,
-			    struct ib_port_modify *props)
-{
-	return -ENOSYS;
-}
-
 static struct ib_ah *iwch_ah_create(struct ib_pd *pd,
 				    struct ib_ah_attr *ah_attr)
 {
@@ -1392,7 +1385,6 @@ int iwch_register_device(struct iwch_dev *dev)
 	dev->ibdev.dma_device = &(dev->rdev.rnic_info.pdev->dev);
 	dev->ibdev.query_device = iwch_query_device;
 	dev->ibdev.query_port = iwch_query_port;
-	dev->ibdev.modify_port = iwch_modify_port;
 	dev->ibdev.query_pkey = iwch_query_pkey;
 	dev->ibdev.query_gid = iwch_query_gid;
 	dev->ibdev.alloc_ucontext = iwch_alloc_ucontext;
diff --git a/drivers/infiniband/hw/cxgb4/provider.c
b/drivers/infiniband/hw/cxgb4/provider.c
index 5b9e422..247fe70 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -58,13 +58,6 @@ static int fastreg_support = 1;
 module_param(fastreg_support, int, 0644);
 MODULE_PARM_DESC(fastreg_support, "Advertise fastreg support (default=1)");

-static int c4iw_modify_port(struct ib_device *ibdev,
-			    u8 port, int port_modify_mask,
-			    struct ib_port_modify *props)
-{
-	return -ENOSYS;
-}
-
 static struct ib_ah *c4iw_ah_create(struct ib_pd *pd,
 				    struct ib_ah_attr *ah_attr)
 {
@@ -456,7 +449,6 @@ int c4iw_register_device(struct c4iw_dev *dev)
 	dev->ibdev.dma_device = &(dev->rdev.lldi.pdev->dev);
 	dev->ibdev.query_device = c4iw_query_device;
 	dev->ibdev.query_port = c4iw_query_port;
-	dev->ibdev.modify_port = c4iw_modify_port;
 	dev->ibdev.query_pkey = c4iw_query_pkey;
 	dev->ibdev.query_gid = c4iw_query_gid;
 	dev->ibdev.alloc_ucontext = c4iw_alloc_ucontext;
diff --git a/drivers/infiniband/hw/nes/nes_verbs.c
b/drivers/infiniband/hw/nes/nes_verbs.c
index 95ca93c..9f2f7d4 100644
--- a/drivers/infiniband/hw/nes/nes_verbs.c
+++ b/drivers/infiniband/hw/nes/nes_verbs.c
@@ -605,16 +605,6 @@ static int nes_query_port(struct ib_device
*ibdev, u8 port, struct ib_port_attr


 /**
- * nes_modify_port
- */
-static int nes_modify_port(struct ib_device *ibdev, u8 port,
-		int port_modify_mask, struct ib_port_modify *props)
-{
-	return 0;
-}
-
-
-/**
  * nes_query_pkey
  */
 static int nes_query_pkey(struct ib_device *ibdev, u8 port, u16
index, u16 *pkey)
@@ -3882,7 +3872,6 @@ struct nes_ib_device *nes_init_ofa_device(struct
net_device *netdev)
 	nesibdev->ibdev.dev.parent = &nesdev->pcidev->dev;
 	nesibdev->ibdev.query_device = nes_query_device;
 	nesibdev->ibdev.query_port = nes_query_port;
-	nesibdev->ibdev.modify_port = nes_modify_port;
 	nesibdev->ibdev.query_pkey = nes_query_pkey;
 	nesibdev->ibdev.query_gid = nes_query_gid;
 	nesibdev->ibdev.alloc_ucontext = nes_alloc_ucontext;
diff --git a/drivers/infiniband/hw/siw/siw_main.c
b/drivers/infiniband/hw/siw/siw_main.c
index b2b7bea..d2346fe 100644
--- a/drivers/infiniband/hw/siw/siw_main.c
+++ b/drivers/infiniband/hw/siw/siw_main.c
@@ -216,13 +216,6 @@ static struct device_attribute *siw_dev_attributes[] = {
 	&dev_attr_cep
 };

-static int siw_modify_port(struct ib_device *ofa_dev, u8 port, int mask,
-			   struct ib_port_modify *props)
-{
-	return -EOPNOTSUPP;
-}
-
-
 static int siw_register_device(struct siw_dev *dev)
 {
 	struct ib_device *ibdev = &dev->ofa_dev;
@@ -284,7 +277,6 @@ static int siw_register_device(struct siw_dev *dev)
 	ibdev->query_device = siw_query_device;
 	ibdev->query_port = siw_query_port;
 	ibdev->query_qp = siw_query_qp;
-	ibdev->modify_port = siw_modify_port;
 	ibdev->query_pkey = siw_query_pkey;
 	ibdev->query_gid = siw_query_gid;
 	ibdev->alloc_ucontext = siw_alloc_ucontext;
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
