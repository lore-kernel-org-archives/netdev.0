From: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Subject: [PATCH 01/15] pcmcia: do not use win_req_t when calling pcmcia_request_window()
Date: Fri,  3 Sep 2010 12:57:00 +0200
Message-ID: <1283511434-21620-1-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100903105628.GA21255-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOrE5yTffgRl4@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Instead of win_req_t, drivers are now requested to fill out
struct pcmcia_device *p_dev->resource[2,3,4,5] for up to four iomem
ranges. After a call to pcmcia_request_window(), the windows found there
are reserved and may be used until pcmcia_release_window() is called.

CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
CC: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
CC: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
---
 Documentation/pcmcia/driver-changes.txt |    7 +++
 drivers/char/pcmcia/ipwireless/main.c   |   87 +++++++++++++------------------
 drivers/char/pcmcia/ipwireless/main.h   |    4 --
 drivers/mtd/maps/pcmciamtd.c            |   53 ++++++++++---------
 drivers/net/pcmcia/fmvj18x_cs.c         |   29 ++++------
 drivers/net/pcmcia/ibmtr_cs.c           |   42 +++++++--------
 drivers/net/pcmcia/pcnet_cs.c           |   44 ++++++++--------
 drivers/net/pcmcia/smc91c92_cs.c        |   15 +++---
 drivers/net/pcmcia/xirc2ps_cs.c         |   16 +++---
 drivers/net/wireless/b43/pcmcia.c       |   14 ++---
 drivers/net/wireless/ray_cs.c           |   44 +++++++--------
 drivers/net/wireless/ray_cs.h           |    2 -
 drivers/pcmcia/pcmcia_resource.c        |   60 ++++++++++++----------
 drivers/scsi/pcmcia/nsp_cs.c            |   47 ++++++----------
 include/pcmcia/cs.h                     |   24 ---------
 include/pcmcia/ds.h                     |   28 +++++++---
 16 files changed, 240 insertions(+), 276 deletions(-)

diff --git a/Documentation/pcmcia/driver-changes.txt b/Documentation/pcmcia/driver-changes.txt
index 26c0f9c..86e0f49 100644
--- a/Documentation/pcmcia/driver-changes.txt
+++ b/Documentation/pcmcia/driver-changes.txt
@@ -1,4 +1,11 @@
 This file details changes in 2.6 which affect PCMCIA card driver authors:
+* pcmcia_request_window changes (as of 2.6.36)
+   Instead of win_req_t, drivers are now requested to fill out
+   struct pcmcia_device *p_dev->resource[2,3,4,5] for up to four ioport
+   ranges. After a call to pcmcia_request_window(), the regions found there
+   are reserved and may be used immediately -- until pcmcia_release_window()
+   is called.
+
 * pcmcia_request_io changes (as of 2.6.36)
    Instead of io_req_t, drivers are now requested to fill out
    struct pcmcia_device *p_dev->resource[0,1] for up to two ioport
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 67bdb05..8d2b86a 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -105,62 +105,54 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	if (cfg->mem.nwin == 0)
 		return 0;
 
-	ipw->request_common_memory.Attributes =
+	p_dev->resource[2]->flags |=
 		WIN_DATA_WIDTH_16 | WIN_MEMORY_TYPE_CM | WIN_ENABLE;
-	ipw->request_common_memory.Base = cfg->mem.win[0].host_addr;
-	ipw->request_common_memory.Size = cfg->mem.win[0].len;
-	if (ipw->request_common_memory.Size < 0x1000)
-		ipw->request_common_memory.Size = 0x1000;
-	ipw->request_common_memory.AccessSpeed = 0;
-
-	ret = pcmcia_request_window(p_dev, &ipw->request_common_memory,
-				&ipw->handle_common_memory);
+	p_dev->resource[2]->start = cfg->mem.win[0].host_addr;
+	p_dev->resource[2]->end = cfg->mem.win[0].len;
+	if (p_dev->resource[2]->end < 0x1000)
+		p_dev->resource[2]->end = 0x1000;
 
+	ret = pcmcia_request_window(p_dev, p_dev->resource[2], 0);
 	if (ret != 0)
 		goto exit1;
 
-	ret = pcmcia_map_mem_page(p_dev, ipw->handle_common_memory,
+	ret = pcmcia_map_mem_page(p_dev, p_dev->resource[2],
 				cfg->mem.win[0].card_addr);
-
 	if (ret != 0)
 		goto exit2;
 
 	ipw->is_v2_card = cfg->mem.win[0].len == 0x100;
 
-	ipw->common_memory = ioremap(ipw->request_common_memory.Base,
-				ipw->request_common_memory.Size);
-	request_mem_region(ipw->request_common_memory.Base,
-			ipw->request_common_memory.Size,
+	ipw->attr_memory = ioremap(p_dev->resource[2]->start,
+				resource_size(p_dev->resource[2]));
+	request_mem_region(p_dev->resource[2]->start,
+			resource_size(p_dev->resource[2]),
 			IPWIRELESS_PCCARD_NAME);
 
-	ipw->request_attr_memory.Attributes =
-		WIN_DATA_WIDTH_16 | WIN_MEMORY_TYPE_AM | WIN_ENABLE;
-	ipw->request_attr_memory.Base = 0;
-	ipw->request_attr_memory.Size = 0;	/* this used to be 0x1000 */
-	ipw->request_attr_memory.AccessSpeed = 0;
-
-	ret = pcmcia_request_window(p_dev, &ipw->request_attr_memory,
-				&ipw->handle_attr_memory);
-
+	p_dev->resource[3]->flags |= WIN_DATA_WIDTH_16 | WIN_MEMORY_TYPE_AM |
+					WIN_ENABLE;
+	p_dev->resource[3]->end = 0; /* this used to be 0x1000 */
+	ret = pcmcia_request_window(p_dev, p_dev->resource[3], 0);
 	if (ret != 0)
 		goto exit2;
 
-	ret = pcmcia_map_mem_page(p_dev, ipw->handle_attr_memory, 0);
+	ret = pcmcia_map_mem_page(p_dev, p_dev->resource[3], 0);
 	if (ret != 0)
 		goto exit3;
 
-	ipw->attr_memory = ioremap(ipw->request_attr_memory.Base,
-				ipw->request_attr_memory.Size);
-	request_mem_region(ipw->request_attr_memory.Base,
-			ipw->request_attr_memory.Size, IPWIRELESS_PCCARD_NAME);
+	ipw->attr_memory = ioremap(p_dev->resource[3]->start,
+				resource_size(p_dev->resource[3]));
+	request_mem_region(p_dev->resource[3]->start,
+			resource_size(p_dev->resource[3]),
+			IPWIRELESS_PCCARD_NAME);
 
 	return 0;
 
 exit3:
 exit2:
 	if (ipw->common_memory) {
-		release_mem_region(ipw->request_common_memory.Base,
-				ipw->request_common_memory.Size);
+		release_mem_region(p_dev->resource[2]->start,
+				resource_size(p_dev->resource[2]));
 		iounmap(ipw->common_memory);
 	}
 exit1:
@@ -201,13 +193,9 @@ static int config_ipwireless(struct ipw_dev *ipw)
 			(unsigned int) link->irq);
 	if (ipw->attr_memory && ipw->common_memory)
 		printk(KERN_INFO IPWIRELESS_PCCARD_NAME
-			": attr memory 0x%08lx-0x%08lx, common memory 0x%08lx-0x%08lx\n",
-			ipw->request_attr_memory.Base,
-			ipw->request_attr_memory.Base
-			+ ipw->request_attr_memory.Size - 1,
-			ipw->request_common_memory.Base,
-			ipw->request_common_memory.Base
-			+ ipw->request_common_memory.Size - 1);
+			": attr memory %pR, common memory %pR\n",
+			link->resource[3],
+			link->resource[2]);
 
 	ipw->network = ipwireless_network_create(ipw->hardware);
 	if (!ipw->network)
@@ -231,17 +219,16 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	return 0;
 
 exit:
-	if (ipw->attr_memory) {
-		release_mem_region(ipw->request_attr_memory.Base,
-				ipw->request_attr_memory.Size);
-		iounmap(ipw->attr_memory);
-
-	}
 	if (ipw->common_memory) {
-		release_mem_region(ipw->request_common_memory.Base,
-				ipw->request_common_memory.Size);
+		release_mem_region(link->resource[2]->start,
+				resource_size(link->resource[2]));
 		iounmap(ipw->common_memory);
 	}
+	if (ipw->attr_memory) {
+		release_mem_region(link->resource[3]->start,
+				resource_size(link->resource[3]));
+		iounmap(ipw->attr_memory);
+	}
 	pcmcia_disable_device(link);
 	return -1;
 }
@@ -249,13 +236,13 @@ exit:
 static void release_ipwireless(struct ipw_dev *ipw)
 {
 	if (ipw->common_memory) {
-		release_mem_region(ipw->request_common_memory.Base,
-				ipw->request_common_memory.Size);
+		release_mem_region(ipw->link->resource[2]->start,
+				resource_size(ipw->link->resource[2]));
 		iounmap(ipw->common_memory);
 	}
 	if (ipw->attr_memory) {
-		release_mem_region(ipw->request_attr_memory.Base,
-				ipw->request_attr_memory.Size);
+		release_mem_region(ipw->link->resource[3]->start,
+				resource_size(ipw->link->resource[3]));
 		iounmap(ipw->attr_memory);
 	}
 	pcmcia_disable_device(ipw->link);
diff --git a/drivers/char/pcmcia/ipwireless/main.h b/drivers/char/pcmcia/ipwireless/main.h
index c207be8..9040219 100644
--- a/drivers/char/pcmcia/ipwireless/main.h
+++ b/drivers/char/pcmcia/ipwireless/main.h
@@ -45,13 +45,9 @@ struct ipw_dev {
 	struct pcmcia_device *link;
 	int is_v2_card;
 
-	window_handle_t handle_attr_memory;
 	void __iomem *attr_memory;
-	win_req_t request_attr_memory;
 
-	window_handle_t handle_common_memory;
 	void __iomem *common_memory;
-	win_req_t request_common_memory;
 
 	/* Reference to attribute memory, containing CIS data */
 	void *attribute_memory;
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index e9ca5ba..fb3c538 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -101,7 +101,7 @@ MODULE_PARM_DESC(mem_type, "Set Memory type (0=Flash, 1=RAM, 2=ROM, default=0)")
 static caddr_t remap_window(struct map_info *map, unsigned long to)
 {
 	struct pcmciamtd_dev *dev = (struct pcmciamtd_dev *)map->map_priv_1;
-	window_handle_t win = (window_handle_t)map->map_priv_2;
+	struct resource *win = (struct resource *) map->map_priv_2;
 	unsigned int offset;
 	int ret;
 
@@ -339,7 +339,7 @@ static void pcmciamtd_release(struct pcmcia_device *link)
 
 	DEBUG(3, "link = 0x%p", link);
 
-	if (link->win) {
+	if (link->resource[2]->end) {
 		if(dev->win_base) {
 			iounmap(dev->win_base);
 			dev->win_base = NULL;
@@ -491,9 +491,8 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 {
 	struct pcmciamtd_dev *dev = link->priv;
 	struct mtd_info *mtd = NULL;
-	win_req_t req;
 	int ret;
-	int i;
+	int i, j = 0;
 	static char *probes[] = { "jedec_probe", "cfi_probe" };
 	int new_name = 0;
 
@@ -520,28 +519,34 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 	 * smaller windows until we succeed
 	 */
 
-	req.Attributes =  WIN_MEMORY_TYPE_CM | WIN_ENABLE;
-	req.Attributes |= (dev->pcmcia_map.bankwidth == 1) ? WIN_DATA_WIDTH_8 : WIN_DATA_WIDTH_16;
-	req.Base = 0;
-	req.AccessSpeed = mem_speed;
-	link->win = (window_handle_t)link;
-	req.Size = (force_size) ? force_size << 20 : MAX_PCMCIA_ADDR;
+	link->resource[2]->flags |=  WIN_MEMORY_TYPE_CM | WIN_ENABLE;
+	link->resource[2]->flags |= (dev->pcmcia_map.bankwidth == 1) ?
+					WIN_DATA_WIDTH_8 : WIN_DATA_WIDTH_16;
+	link->resource[2]->start = 0;
+	link->resource[2]->end = (force_size) ? force_size << 20 :
+					MAX_PCMCIA_ADDR;
 	dev->win_size = 0;
 
 	do {
 		int ret;
-		DEBUG(2, "requesting window with size = %dKiB memspeed = %d",
-		      req.Size >> 10, req.AccessSpeed);
-		ret = pcmcia_request_window(link, &req, &link->win);
+		DEBUG(2, "requesting window with size = %luKiB memspeed = %d",
+			(unsigned long) resource_size(link->resource[2]) >> 10,
+			mem_speed);
+		ret = pcmcia_request_window(link, link->resource[2], mem_speed);
 		DEBUG(2, "ret = %d dev->win_size = %d", ret, dev->win_size);
 		if(ret) {
-			req.Size >>= 1;
+			j++;
+			link->resource[2]->start = 0;
+			link->resource[2]->end = (force_size) ?
+					force_size << 20 : MAX_PCMCIA_ADDR;
+			link->resource[2]->end >>= j;
 		} else {
-			DEBUG(2, "Got window of size %dKiB", req.Size >> 10);
-			dev->win_size = req.Size;
+			DEBUG(2, "Got window of size %luKiB", (unsigned long)
+				resource_size(link->resource[2]) >> 10);
+			dev->win_size = resource_size(link->resource[2]);
 			break;
 		}
-	} while(req.Size >= 0x1000);
+	} while (link->resource[2]->end >= 0x1000);
 
 	DEBUG(2, "dev->win_size = %d", dev->win_size);
 
@@ -553,20 +558,20 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 	DEBUG(1, "Allocated a window of %dKiB", dev->win_size >> 10);
 
 	/* Get write protect status */
-	DEBUG(2, "window handle = 0x%8.8lx", (unsigned long)link->win);
-	dev->win_base = ioremap(req.Base, req.Size);
+	dev->win_base = ioremap(link->resource[2]->start,
+				resource_size(link->resource[2]));
 	if(!dev->win_base) {
-		dev_err(&dev->p_dev->dev, "ioremap(%lu, %u) failed\n",
-			req.Base, req.Size);
+		dev_err(&dev->p_dev->dev, "ioremap(%pR) failed\n",
+			link->resource[2]);
 		pcmciamtd_release(link);
 		return -ENODEV;
 	}
-	DEBUG(1, "mapped window dev = %p req.base = 0x%lx base = %p size = 0x%x",
-	      dev, req.Base, dev->win_base, req.Size);
+	DEBUG(1, "mapped window dev = %p @ %pR, base = %p",
+	      dev, link->resource[2], dev->win_base);
 
 	dev->offset = 0;
 	dev->pcmcia_map.map_priv_1 = (unsigned long)dev;
-	dev->pcmcia_map.map_priv_2 = (unsigned long)link->win;
+	dev->pcmcia_map.map_priv_2 = (unsigned long)link->resource[2];
 
 	dev->vpp = (vpp) ? vpp : link->socket->socket.Vpp;
 	link->conf.Attributes = 0;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 98fffb0..dfd3284 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -544,20 +544,18 @@ failed:
 
 static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
 {
-    win_req_t req;
     u_char __iomem *base;
     int i, j;
 
     /* Allocate a small memory window */
-    req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
-    req.Base = 0; req.Size = 0;
-    req.AccessSpeed = 0;
-    i = pcmcia_request_window(link, &req, &link->win);
+    link->resource[2]->flags |= WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
+    link->resource[2]->start = 0; link->resource[2]->end = 0;
+    i = pcmcia_request_window(link, link->resource[2], 0);
     if (i != 0)
 	return -1;
 
-    base = ioremap(req.Base, req.Size);
-    pcmcia_map_mem_page(link, link->win, 0);
+    base = ioremap(link->resource[2]->start, resource_size(link->resource[2]));
+    pcmcia_map_mem_page(link, link->resource[2], 0);
 
     /*
      *  MBH10304 CISTPL_FUNCE_LAN_NODE_ID format
@@ -582,7 +580,7 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
     }
 
     iounmap(base);
-    j = pcmcia_release_window(link, link->win);
+    j = pcmcia_release_window(link, link->resource[2]);
     return (i != 0x200) ? 0 : -1;
 
 } /* fmvj18x_get_hwinfo */
@@ -590,27 +588,26 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
 
 static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 {
-    win_req_t req;
     int i;
     struct net_device *dev = link->priv;
     unsigned int ioaddr;
     local_info_t *lp = netdev_priv(dev);
 
     /* Allocate a small memory window */
-    req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
-    req.Base = 0; req.Size = 0;
-    req.AccessSpeed = 0;
-    i = pcmcia_request_window(link, &req, &link->win);
+    link->resource[3]->flags = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
+    link->resource[3]->start = link->resource[3]->end = 0;
+    i = pcmcia_request_window(link, link->resource[3], 0);
     if (i != 0)
 	return -1;
 
-    lp->base = ioremap(req.Base, req.Size);
+    lp->base = ioremap(link->resource[3]->start,
+		       resource_size(link->resource[3]));
     if (lp->base == NULL) {
 	printk(KERN_NOTICE "fmvj18x_cs: ioremap failed\n");
 	return -1;
     }
 
-    i = pcmcia_map_mem_page(link, link->win, 0);
+    i = pcmcia_map_mem_page(link, link->resource[3], 0);
     if (i != 0) {
 	iounmap(lp->base);
 	lp->base = NULL;
@@ -638,7 +635,6 @@ static void fmvj18x_release(struct pcmcia_device *link)
     struct net_device *dev = link->priv;
     local_info_t *lp = netdev_priv(dev);
     u_char __iomem *tmp;
-    int j;
 
     dev_dbg(&link->dev, "fmvj18x_release\n");
 
@@ -646,7 +642,6 @@ static void fmvj18x_release(struct pcmcia_device *link)
 	tmp = lp->base;
 	lp->base = NULL;    /* set NULL before iounmap */
 	iounmap(tmp);
-	j = pcmcia_release_window(link, link->win);
     }
 
     pcmcia_disable_device(link);
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index b0d06a3..dbdea7f 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -102,9 +102,8 @@ static void ibmtr_detach(struct pcmcia_device *p_dev);
 
 typedef struct ibmtr_dev_t {
 	struct pcmcia_device	*p_dev;
-    struct net_device	*dev;
-    window_handle_t     sram_win_handle;
-    struct tok_info	*ti;
+	struct net_device	*dev;
+	struct tok_info		*ti;
 } ibmtr_dev_t;
 
 static void netdev_get_drvinfo(struct net_device *dev,
@@ -210,7 +209,6 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     ibmtr_dev_t *info = link->priv;
     struct net_device *dev = info->dev;
     struct tok_info *ti = netdev_priv(dev);
-    win_req_t req;
     int i, ret;
 
     dev_dbg(&link->dev, "ibmtr_config\n");
@@ -240,37 +238,37 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     ti->global_int_enable=GLOBAL_INT_ENABLE+((dev->irq==9) ? 2 : dev->irq);
 
     /* Allocate the MMIO memory window */
-    req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
-    req.Attributes |= WIN_USE_WAIT;
-    req.Base = 0; 
-    req.Size = 0x2000;
-    req.AccessSpeed = 250;
-    ret = pcmcia_request_window(link, &req, &link->win);
+    link->resource[2]->flags |= WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
+    link->resource[2]->flags |= WIN_USE_WAIT;
+    link->resource[2]->start = 0;
+    link->resource[2]->end = 0x2000;
+    ret = pcmcia_request_window(link, link->resource[2], 250);
     if (ret)
 	    goto failed;
 
-    ret = pcmcia_map_mem_page(link, link->win, mmiobase);
+    ret = pcmcia_map_mem_page(link, link->resource[2], mmiobase);
     if (ret)
 	    goto failed;
-    ti->mmio = ioremap(req.Base, req.Size);
+    ti->mmio = ioremap(link->resource[2]->start,
+		    resource_size(link->resource[2]));
 
     /* Allocate the SRAM memory window */
-    req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
-    req.Attributes |= WIN_USE_WAIT;
-    req.Base = 0;
-    req.Size = sramsize * 1024;
-    req.AccessSpeed = 250;
-    ret = pcmcia_request_window(link, &req, &info->sram_win_handle);
+    link->resource[3]->flags = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
+    link->resource[3]->flags |= WIN_USE_WAIT;
+    link->resource[3]->start = 0;
+    link->resource[3]->end = sramsize * 1024;
+    ret = pcmcia_request_window(link, link->resource[3], 250);
     if (ret)
 	    goto failed;
 
-    ret = pcmcia_map_mem_page(link, info->sram_win_handle, srambase);
+    ret = pcmcia_map_mem_page(link, link->resource[3], srambase);
     if (ret)
 	    goto failed;
 
     ti->sram_base = srambase >> 12;
-    ti->sram_virt = ioremap(req.Base, req.Size);
-    ti->sram_phys = req.Base;
+    ti->sram_virt = ioremap(link->resource[3]->start,
+		    resource_size(link->resource[3]));
+    ti->sram_phys = link->resource[3]->start;
 
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
@@ -316,7 +314,7 @@ static void ibmtr_release(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "ibmtr_release\n");
 
-	if (link->win) {
+	if (link->resource[2]->end) {
 		struct tok_info *ti = netdev_priv(dev);
 		iounmap(ti->mmio);
 	}
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index c3edfe4..15e80ea 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -300,22 +300,22 @@ static void pcnet_detach(struct pcmcia_device *link)
 static hw_info_t *get_hwinfo(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    win_req_t req;
     u_char __iomem *base, *virt;
     int i, j;
 
     /* Allocate a small memory window */
-    req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
-    req.Base = 0; req.Size = 0;
-    req.AccessSpeed = 0;
-    i = pcmcia_request_window(link, &req, &link->win);
+    link->resource[2]->flags |= WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
+    link->resource[2]->start = 0; link->resource[2]->end = 0;
+    i = pcmcia_request_window(link, link->resource[2], 0);
     if (i != 0)
 	return NULL;
 
-    virt = ioremap(req.Base, req.Size);
+    virt = ioremap(link->resource[2]->start,
+	    resource_size(link->resource[2]));
     for (i = 0; i < NR_INFO; i++) {
-	pcmcia_map_mem_page(link, link->win, hw_info[i].offset & ~(req.Size-1));
-	base = &virt[hw_info[i].offset & (req.Size-1)];
+	pcmcia_map_mem_page(link, link->resource[2],
+		hw_info[i].offset & ~(resource_size(link->resource[2])-1));
+	base = &virt[hw_info[i].offset & (resource_size(link->resource[2])-1)];
 	if ((readb(base+0) == hw_info[i].a0) &&
 	    (readb(base+2) == hw_info[i].a1) &&
 	    (readb(base+4) == hw_info[i].a2)) {
@@ -326,7 +326,7 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
     }
 
     iounmap(virt);
-    j = pcmcia_release_window(link, link->win);
+    j = pcmcia_release_window(link, link->resource[2]);
     return (i < NR_INFO) ? hw_info+i : NULL;
 } /* get_hwinfo */
 
@@ -1459,7 +1459,6 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
 {
     struct net_device *dev = link->priv;
     pcnet_dev_t *info = PRIV(dev);
-    win_req_t req;
     int i, window_size, offset, ret;
 
     window_size = (stop_pg - start_pg) << 8;
@@ -1470,22 +1469,22 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     window_size = roundup_pow_of_two(window_size);
 
     /* Allocate a memory window */
-    req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
-    req.Attributes |= WIN_USE_WAIT;
-    req.Base = 0; req.Size = window_size;
-    req.AccessSpeed = mem_speed;
-    ret = pcmcia_request_window(link, &req, &link->win);
+    link->resource[3]->flags |= WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM|WIN_ENABLE;
+    link->resource[3]->flags |= WIN_USE_WAIT;
+    link->resource[3]->start = 0; link->resource[3]->end = window_size;
+    ret = pcmcia_request_window(link, link->resource[3], mem_speed);
     if (ret)
 	    goto failed;
 
     offset = (start_pg << 8) + cm_offset;
     offset -= offset % window_size;
-    ret = pcmcia_map_mem_page(link, link->win, offset);
+    ret = pcmcia_map_mem_page(link, link->resource[3], offset);
     if (ret)
 	    goto failed;
 
     /* Try scribbling on the buffer */
-    info->base = ioremap(req.Base, window_size);
+    info->base = ioremap(link->resource[3]->start,
+			resource_size(link->resource[3]));
     for (i = 0; i < (TX_PAGES<<8); i += 2)
 	__raw_writew((i>>1), info->base+offset+i);
     udelay(100);
@@ -1494,19 +1493,20 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     pcnet_reset_8390(dev);
     if (i != (TX_PAGES<<8)) {
 	iounmap(info->base);
-	pcmcia_release_window(link, link->win);
-	info->base = NULL; link->win = 0;
+	pcmcia_release_window(link, link->resource[3]);
+	info->base = NULL;
 	goto failed;
     }
 
     ei_status.mem = info->base + offset;
-    ei_status.priv = req.Size;
+    ei_status.priv = resource_size(link->resource[3]);
     dev->mem_start = (u_long)ei_status.mem;
-    dev->mem_end = dev->mem_start + req.Size;
+    dev->mem_end = dev->mem_start + resource_size(link->resource[3]);
 
     ei_status.tx_start_page = start_pg;
     ei_status.rx_start_page = start_pg + TX_PAGES;
-    ei_status.stop_page = start_pg + ((req.Size - offset) >> 8);
+    ei_status.stop_page = start_pg + (
+	    (resource_size(link->resource[3]) - offset) >> 8);
 
     /* set up block i/o functions */
     ei_status.get_8390_hdr = &shmem_get_8390_hdr;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 377367d..acc6807 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -442,7 +442,6 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     struct smc_private *smc = netdev_priv(dev);
-    win_req_t req;
     unsigned int offset;
     int i;
 
@@ -459,16 +458,16 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     dev->base_addr = link->resource[0]->start;
 
     /* Allocate a memory window, for accessing the ISR */
-    req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
-    req.Base = req.Size = 0;
-    req.AccessSpeed = 0;
-    i = pcmcia_request_window(link, &req, &link->win);
+    link->resource[2]->flags = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
+    link->resource[2]->start = link->resource[2]->end = 0;
+    i = pcmcia_request_window(link, link->resource[2], 0);
     if (i != 0)
 	    return -ENODEV;
 
-    smc->base = ioremap(req.Base, req.Size);
+    smc->base = ioremap(link->resource[2]->start,
+		    resource_size(link->resource[2]));
     offset = (smc->manfid == MANFID_MOTOROLA) ? link->conf.ConfigBase : 0;
-    i = pcmcia_map_mem_page(link, link->win, offset);
+    i = pcmcia_map_mem_page(link, link->resource[2], offset);
     if ((i == 0) &&
 	(smc->manfid == MANFID_MEGAHERTZ) &&
 	(smc->cardid == PRODID_MEGAHERTZ_EM3288))
@@ -999,7 +998,7 @@ config_failed:
 static void smc91c92_release(struct pcmcia_device *link)
 {
 	dev_dbg(&link->dev, "smc91c92_release\n");
-	if (link->win) {
+	if (link->resource[2]->end) {
 		struct net_device *dev = link->priv;
 		struct smc_private *smc = netdev_priv(dev);
 		iounmap(smc->base);
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index f581952..4308bda 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -869,8 +869,6 @@ xirc2ps_config(struct pcmcia_device * link)
 	goto config_error;
 
     if (local->dingo) {
-	win_req_t req;
-
 	/* Reset the modem's BAR to the correct value
 	 * This is necessary because in the RequestConfiguration call,
 	 * the base address of the ethernet port (BasePort1) is written
@@ -890,14 +888,14 @@ xirc2ps_config(struct pcmcia_device * link)
 	 * is at 0x0800. So we allocate a window into the attribute
 	 * memory and write direct to the CIS registers
 	 */
-	req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
-	req.Base = req.Size = 0;
-	req.AccessSpeed = 0;
-	if ((err = pcmcia_request_window(link, &req, &link->win)))
+	link->resource[2]->flags = WIN_DATA_WIDTH_8 | WIN_MEMORY_TYPE_AM |
+					WIN_ENABLE;
+	link->resource[2]->start = link->resource[2]->end = 0;
+	if ((err = pcmcia_request_window(link, link->resource[2], 0)))
 	    goto config_error;
 
-	local->dingo_ccr = ioremap(req.Base,0x1000) + 0x0800;
-	if ((err = pcmcia_map_mem_page(link, link->win, 0)))
+	local->dingo_ccr = ioremap(link->resource[2]->start, 0x1000) + 0x0800;
+	if ((err = pcmcia_map_mem_page(link, link->resource[2], 0)))
 	    goto config_error;
 
 	/* Setup the CCRs; there are no infos in the CIS about the Ethernet
@@ -988,7 +986,7 @@ xirc2ps_release(struct pcmcia_device *link)
 {
 	dev_dbg(&link->dev, "release\n");
 
-	if (link->win) {
+	if (link->resource[2]->end) {
 		struct net_device *dev = link->priv;
 		local_info_t *local = netdev_priv(dev);
 		if (local->dingo)
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index dfbc41d..618d9b5 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -63,7 +63,6 @@ static int b43_pcmcia_resume(struct pcmcia_device *dev)
 static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 {
 	struct ssb_bus *ssb;
-	win_req_t win;
 	int err = -ENOMEM;
 	int res = 0;
 
@@ -76,16 +75,15 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	dev->conf.Attributes = CONF_ENABLE_IRQ;
 	dev->conf.IntType = INT_MEMORY_AND_IO;
 
-	win.Attributes =  WIN_ENABLE | WIN_DATA_WIDTH_16 |
+	dev->resource[2]->flags |=  WIN_ENABLE | WIN_DATA_WIDTH_16 |
 			 WIN_USE_WAIT;
-	win.Base = 0;
-	win.Size = SSB_CORE_SIZE;
-	win.AccessSpeed = 250;
-	res = pcmcia_request_window(dev, &win, &dev->win);
+	dev->resource[2]->start = 0;
+	dev->resource[2]->end = SSB_CORE_SIZE;
+	res = pcmcia_request_window(dev, dev->resource[2], 250);
 	if (res != 0)
 		goto err_kfree_ssb;
 
-	res = pcmcia_map_mem_page(dev, dev->win, 0);
+	res = pcmcia_map_mem_page(dev, dev->resource[2], 0);
 	if (res != 0)
 		goto err_disable;
 
@@ -96,7 +94,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	if (res != 0)
 		goto err_disable;
 
-	err = ssb_bus_pcmciabus_register(ssb, dev, win.Base);
+	err = ssb_bus_pcmciabus_register(ssb, dev, dev->resource[2]->start);
 	if (err)
 		goto err_disable;
 	dev->priv = ssb;
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 88560d0..ab34cb8 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -391,7 +391,6 @@ static int ray_config(struct pcmcia_device *link)
 {
 	int ret = 0;
 	int i;
-	win_req_t req;
 	struct net_device *dev = (struct net_device *)link->priv;
 	ray_dev_t *local = netdev_priv(dev);
 
@@ -420,46 +419,45 @@ static int ray_config(struct pcmcia_device *link)
 		goto failed;
 
 /*** Set up 32k window for shared memory (transmit and control) ************/
-	req.Attributes =
-	    WIN_DATA_WIDTH_8 | WIN_MEMORY_TYPE_CM | WIN_ENABLE | WIN_USE_WAIT;
-	req.Base = 0;
-	req.Size = 0x8000;
-	req.AccessSpeed = ray_mem_speed;
-	ret = pcmcia_request_window(link, &req, &link->win);
+	link->resource[2]->flags |= WIN_DATA_WIDTH_8 | WIN_MEMORY_TYPE_CM | WIN_ENABLE | WIN_USE_WAIT;
+	link->resource[2]->start = 0;
+	link->resource[2]->end = 0x8000;
+	ret = pcmcia_request_window(link, link->resource[2], ray_mem_speed);
 	if (ret)
 		goto failed;
-	ret = pcmcia_map_mem_page(link, link->win, 0);
+	ret = pcmcia_map_mem_page(link, link->resource[2], 0);
 	if (ret)
 		goto failed;
-	local->sram = ioremap(req.Base, req.Size);
+	local->sram = ioremap(link->resource[2]->start,
+			resource_size(link->resource[2]));
 
 /*** Set up 16k window for shared memory (receive buffer) ***************/
-	req.Attributes =
+	link->resource[3]->flags |=
 	    WIN_DATA_WIDTH_8 | WIN_MEMORY_TYPE_CM | WIN_ENABLE | WIN_USE_WAIT;
-	req.Base = 0;
-	req.Size = 0x4000;
-	req.AccessSpeed = ray_mem_speed;
-	ret = pcmcia_request_window(link, &req, &local->rmem_handle);
+	link->resource[3]->start = 0;
+	link->resource[3]->end = 0x4000;
+	ret = pcmcia_request_window(link, link->resource[3], ray_mem_speed);
 	if (ret)
 		goto failed;
-	ret = pcmcia_map_mem_page(link, local->rmem_handle, 0x8000);
+	ret = pcmcia_map_mem_page(link, link->resource[3], 0x8000);
 	if (ret)
 		goto failed;
-	local->rmem = ioremap(req.Base, req.Size);
+	local->rmem = ioremap(link->resource[3]->start,
+			resource_size(link->resource[3]));
 
 /*** Set up window for attribute memory ***********************************/
-	req.Attributes =
+	link->resource[4]->flags |=
 	    WIN_DATA_WIDTH_8 | WIN_MEMORY_TYPE_AM | WIN_ENABLE | WIN_USE_WAIT;
-	req.Base = 0;
-	req.Size = 0x1000;
-	req.AccessSpeed = ray_mem_speed;
-	ret = pcmcia_request_window(link, &req, &local->amem_handle);
+	link->resource[4]->start = 0;
+	link->resource[4]->end = 0x1000;
+	ret = pcmcia_request_window(link, link->resource[4], ray_mem_speed);
 	if (ret)
 		goto failed;
-	ret = pcmcia_map_mem_page(link, local->amem_handle, 0);
+	ret = pcmcia_map_mem_page(link, link->resource[4], 0);
 	if (ret)
 		goto failed;
-	local->amem = ioremap(req.Base, req.Size);
+	local->amem = ioremap(link->resource[4]->start,
+			resource_size(link->resource[4]));
 
 	dev_dbg(&link->dev, "ray_config sram=%p\n", local->sram);
 	dev_dbg(&link->dev, "ray_config rmem=%p\n", local->rmem);
diff --git a/drivers/net/wireless/ray_cs.h b/drivers/net/wireless/ray_cs.h
index 9f01ddb..e79848f 100644
--- a/drivers/net/wireless/ray_cs.h
+++ b/drivers/net/wireless/ray_cs.h
@@ -25,8 +25,6 @@ struct beacon_rx {
 typedef struct ray_dev_t {
     int card_status;
     int authentication_state;
-    window_handle_t amem_handle;   /* handle to window for attribute memory  */
-    window_handle_t rmem_handle;   /* handle to window for rx buffer on card */
     void __iomem *sram;            /* pointer to beginning of shared RAM     */
     void __iomem *amem;            /* pointer to attribute mem window        */
     void __iomem *rmem;            /* pointer to receive buffer window       */
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 54aa1c2..3ea2e94 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -204,11 +204,10 @@ int pcmcia_write_config_byte(struct pcmcia_device *p_dev, off_t where, u8 val)
 EXPORT_SYMBOL(pcmcia_write_config_byte);
 
 
-int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t wh,
+int pcmcia_map_mem_page(struct pcmcia_device *p_dev, struct resource *res,
 			unsigned int offset)
 {
 	struct pcmcia_socket *s = p_dev->socket;
-	struct resource *res = wh;
 	unsigned int w;
 	int ret;
 
@@ -384,7 +383,12 @@ out:
 	return ret;
 } /* pcmcia_release_io */
 
-
+/**
+ * pcmcia_release_window() - release reserved iomem for PCMCIA devices
+ *
+ * pcmcia_release_window() releases struct resource *res which was
+ * previously reserved by calling pcmcia_request_window().
+ */
 int pcmcia_release_window(struct pcmcia_device *p_dev, struct resource *res)
 {
 	struct pcmcia_socket *s = p_dev->socket;
@@ -418,6 +422,8 @@ int pcmcia_release_window(struct pcmcia_device *p_dev, struct resource *res)
 		kfree(win->res);
 		win->res = NULL;
 	}
+	res->start = res->end = 0;
+	res->flags = IORESOURCE_MEM;
 	p_dev->_win &= ~CLIENT_WIN_REQ(w);
 	mutex_unlock(&s->ops_mutex);
 
@@ -786,17 +792,21 @@ int pcmcia_setup_irq(struct pcmcia_device *p_dev)
 }
 
 
-/** pcmcia_request_window
+/**
+ * pcmcia_request_window() - attempt to reserve iomem for PCMCIA devices
  *
- * Request_window() establishes a mapping between card memory space
- * and system memory space.
+ * pcmcia_request_window() attepts to reserve an iomem ranges specified in
+ * struct resource *res pointing to one of the entries in
+ * struct pcmcia_device *p_dev->resource[2..5]. The "start" value is the
+ * requested start of the IO mem resource; "end" reflects the size
+ * requested.
  */
-int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_handle_t *wh)
+int pcmcia_request_window(struct pcmcia_device *p_dev, struct resource *res,
+			unsigned int speed)
 {
 	struct pcmcia_socket *s = p_dev->socket;
 	pccard_mem_map *win;
 	u_long align;
-	struct resource *res;
 	int w;
 
 	if (!(s->state & SOCKET_PRESENT)) {
@@ -805,19 +815,19 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 	}
 
 	/* Window size defaults to smallest available */
-	if (req->Size == 0)
-		req->Size = s->map_size;
-	align = (s->features & SS_CAP_MEM_ALIGN) ? req->Size : s->map_size;
-	if (req->Size & (s->map_size-1)) {
+	if (res->end == 0)
+		res->end = s->map_size;
+	align = (s->features & SS_CAP_MEM_ALIGN) ? res->end : s->map_size;
+	if (res->end & (s->map_size-1)) {
 		dev_dbg(&s->dev, "invalid map size\n");
 		return -EINVAL;
 	}
-	if ((req->Base && (s->features & SS_CAP_STATIC_MAP)) ||
-	    (req->Base & (align-1))) {
+	if ((res->start && (s->features & SS_CAP_STATIC_MAP)) ||
+	    (res->start & (align-1))) {
 		dev_dbg(&s->dev, "invalid base address\n");
 		return -EINVAL;
 	}
-	if (req->Base)
+	if (res->start)
 		align = 0;
 
 	/* Allocate system memory window */
@@ -834,7 +844,7 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 	win = &s->win[w];
 
 	if (!(s->features & SS_CAP_STATIC_MAP)) {
-		win->res = pcmcia_find_mem_region(req->Base, req->Size, align,
+		win->res = pcmcia_find_mem_region(res->start, res->end, align,
 						0, s);
 		if (!win->res) {
 			dev_dbg(&s->dev, "allocating mem region failed\n");
@@ -846,8 +856,8 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 
 	/* Configure the socket controller */
 	win->map = w+1;
-	win->flags = req->Attributes;
-	win->speed = req->AccessSpeed;
+	win->flags = res->flags & WIN_FLAGS_MAP;
+	win->speed = speed;
 	win->card_start = 0;
 
 	if (s->ops->set_mem_map(s, win) != 0) {
@@ -859,17 +869,14 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 
 	/* Return window handle */
 	if (s->features & SS_CAP_STATIC_MAP)
-		req->Base = win->static_start;
+		res->start = win->static_start;
 	else
-		req->Base = win->res->start;
+		res->start = win->res->start;
 
 	/* convert to new-style resources */
-	res = p_dev->resource[w + MAX_IO_WIN];
-	res->start = req->Base;
-	res->end = req->Base + req->Size - 1;
-	res->flags &= ~IORESOURCE_BITS;
-	res->flags |= (req->Attributes & WIN_FLAGS_MAP) | (win->map << 2);
-	res->flags |= IORESOURCE_MEM;
+	res->end += res->start - 1;
+	res->flags &= ~WIN_FLAGS_REQ;
+	res->flags |= (win->map << 2) | IORESOURCE_MEM;
 	res->parent = win->res;
 	if (win->res)
 		request_resource(&iomem_resource, res);
@@ -877,7 +884,6 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 	dev_dbg(&s->dev, "request_window results in %pR\n", res);
 
 	mutex_unlock(&s->ops_mutex);
-	*wh = res;
 
 	return 0;
 } /* pcmcia_request_window */
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index dd9b403..c65ed6e 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1596,18 +1596,13 @@ static void nsp_cs_detach(struct pcmcia_device *link)
     ethernet device available to the system.
 ======================================================================*/
 
-struct nsp_cs_configdata {
-	nsp_hw_data		*data;
-	win_req_t		req;
-};
-
 static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cfg,
 			       cistpl_cftable_entry_t *dflt,
 			       unsigned int vcc,
 			       void *priv_data)
 {
-	struct nsp_cs_configdata *cfg_mem = priv_data;
+	struct nsp_hw_data		*data = priv_data;
 
 	if (cfg->index == 0)
 		return -ENODEV;
@@ -1663,21 +1658,24 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 		if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
 			cistpl_mem_t	*mem =
 				(cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-			cfg_mem->req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM;
-			cfg_mem->req.Attributes |= WIN_ENABLE;
-			cfg_mem->req.Base = mem->win[0].host_addr;
-			cfg_mem->req.Size = mem->win[0].len;
-			if (cfg_mem->req.Size < 0x1000)
-				cfg_mem->req.Size = 0x1000;
-			cfg_mem->req.AccessSpeed = 0;
-			if (pcmcia_request_window(p_dev, &cfg_mem->req, &p_dev->win) != 0)
+			p_dev->resource[2]->flags |= (WIN_DATA_WIDTH_16 |
+						WIN_MEMORY_TYPE_CM |
+						WIN_ENABLE);
+			p_dev->resource[2]->start = mem->win[0].host_addr;
+			p_dev->resource[2]->end = mem->win[0].len;
+			if (p_dev->resource[2]->end < 0x1000)
+				p_dev->resource[2]->end = 0x1000;
+			if (pcmcia_request_window(p_dev, p_dev->resource[2],
+							0) != 0)
 				goto next_entry;
-			if (pcmcia_map_mem_page(p_dev, p_dev->win,
+			if (pcmcia_map_mem_page(p_dev, p_dev->resource[2],
 					mem->win[0].card_addr) != 0)
 				goto next_entry;
 
-			cfg_mem->data->MmioAddress = (unsigned long) ioremap_nocache(cfg_mem->req.Base, cfg_mem->req.Size);
-			cfg_mem->data->MmioLength  = cfg_mem->req.Size;
+			data->MmioAddress = (unsigned long)
+				ioremap_nocache(p_dev->resource[2]->start,
+					resource_size(p_dev->resource[2]));
+			data->MmioLength  = resource_size(p_dev->resource[2]);
 		}
 		/* If we got this far, we're cool! */
 		return 0;
@@ -1693,18 +1691,12 @@ static int nsp_cs_config(struct pcmcia_device *link)
 {
 	int		  ret;
 	scsi_info_t	 *info	 = link->priv;
-	struct nsp_cs_configdata *cfg_mem;
 	struct Scsi_Host *host;
 	nsp_hw_data      *data = &nsp_data_base;
 
 	nsp_dbg(NSP_DEBUG_INIT, "in");
 
-	cfg_mem = kzalloc(sizeof(*cfg_mem), GFP_KERNEL);
-	if (!cfg_mem)
-		return -ENOMEM;
-	cfg_mem->data = data;
-
-	ret = pcmcia_loop_config(link, nsp_cs_config_check, cfg_mem);
+	ret = pcmcia_loop_config(link, nsp_cs_config_check, data);
 	if (ret)
 		goto cs_failed;
 
@@ -1767,18 +1759,15 @@ static int nsp_cs_config(struct pcmcia_device *link)
 		printk(", io %pR", link->resource[0]);
 	if (link->resource[1])
 		printk(" & %pR", link->resource[1]);
-	if (link->win)
-		printk(", mem 0x%06lx-0x%06lx", cfg_mem->req.Base,
-		       cfg_mem->req.Base+cfg_mem->req.Size-1);
+	if (link->resource[1])
+		printk(", mem %pR", link->resource[2]);
 	printk("\n");
 
-	kfree(cfg_mem);
 	return 0;
 
  cs_failed:
 	nsp_dbg(NSP_DEBUG_INIT, "config fail");
 	nsp_cs_release(link);
-	kfree(cfg_mem);
 
 	return -ENODEV;
 } /* nsp_cs_config */
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 68d8bde..63cb9bb 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -68,28 +68,4 @@ typedef struct config_req_t {
 #define PRESENT_IOBASE_3	0x100
 #define PRESENT_IOSIZE		0x200
 
-/* For RequestWindow */
-typedef struct win_req_t {
-    u_int	Attributes;
-    u_long	Base;
-    u_int	Size;
-    u_int	AccessSpeed;
-} win_req_t;
-
-/* Attributes for RequestWindow */
-#define WIN_MEMORY_TYPE_CM	0x00 /* default */
-#define WIN_MEMORY_TYPE_AM	0x20 /* MAP_ATTRIB */
-#define WIN_DATA_WIDTH_8	0x00 /* default */
-#define WIN_DATA_WIDTH_16	0x02 /* MAP_16BIT */
-#define WIN_ENABLE		0x01 /* MAP_ACTIVE */
-#define WIN_USE_WAIT		0x40 /* MAP_USE_WAIT */
-
-#define WIN_FLAGS_MAP		0x63 /* MAP_ATTRIB | MAP_16BIT | MAP_ACTIVE |
-					MAP_USE_WAIT */
-#define WIN_FLAGS_REQ		0x1c /* mapping to socket->win[i]:
-					0x04 -> 0
-					0x08 -> 1
-					0x0c -> 2
-					0x10 -> 3 */
-
 #endif /* _LINUX_CS_H */
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 70c58ed..6f7cb38 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -36,8 +36,6 @@ struct pcmcia_device;
 struct config_t;
 struct net_device;
 
-typedef struct resource *window_handle_t;
-
 /* dynamic device IDs for PCMCIA device drivers. See
  * Documentation/pcmcia/driver.txt for details.
 */
@@ -92,7 +90,6 @@ struct pcmcia_device {
 
 	/* deprecated, will be cleaned up soon */
 	config_req_t		conf;
-	window_handle_t		win;
 
 	/* device setup */
 	unsigned int		irq;
@@ -209,10 +206,10 @@ int __must_check pcmcia_request_irq(struct pcmcia_device *p_dev,
 int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 				 config_req_t *req);
 
-int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req,
-			  window_handle_t *wh);
-int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t win);
-int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t win,
+int pcmcia_request_window(struct pcmcia_device *p_dev, struct resource *res,
+			unsigned int speed);
+int pcmcia_release_window(struct pcmcia_device *p_dev, struct resource *res);
+int pcmcia_map_mem_page(struct pcmcia_device *p_dev, struct resource *res,
 			unsigned int offset);
 
 int pcmcia_modify_configuration(struct pcmcia_device *p_dev, modconf_t *mod);
@@ -234,6 +231,23 @@ static inline int pcmcia_io_cfg_data_width(unsigned int flags)
 	return IO_DATA_PATH_WIDTH_AUTO;
 }
 
+/* IO memory */
+#define WIN_MEMORY_TYPE_CM	0x00 /* default */
+#define WIN_MEMORY_TYPE_AM	0x20 /* MAP_ATTRIB */
+#define WIN_DATA_WIDTH_8	0x00 /* default */
+#define WIN_DATA_WIDTH_16	0x02 /* MAP_16BIT */
+#define WIN_ENABLE		0x01 /* MAP_ACTIVE */
+#define WIN_USE_WAIT		0x40 /* MAP_USE_WAIT */
+
+#define WIN_FLAGS_MAP		0x63 /* MAP_ATTRIB | MAP_16BIT | MAP_ACTIVE |
+					MAP_USE_WAIT */
+#define WIN_FLAGS_REQ		0x1c /* mapping to socket->win[i]:
+					0x04 -> 0
+					0x08 -> 1
+					0x0c -> 2
+					0x10 -> 3 */
+
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_DS_H */
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
