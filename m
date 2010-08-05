From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 13/18] pcmcia: remove memreq_t
Date: Fri,  6 Aug 2010 00:06:49 +0200
Message-ID: <1281046014-7585-13-git-send-email-linux@dominikbrodowski.net>
References: <20100805220511.GA7040@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-usb@vger.kernel.org,
	laforge@gnumonks.org, linux-mtd@lists.infradead.org,
	linux-bluetooth@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-serial@vger.kernel.org, Michael Buesch <mb@bu3sch.de>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20100805220511.GA7040@comet.dominikbrodowski.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Page already had to be set to 0; Offset can easily be passed as
parameter to pcmcia_map_mem_page.

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-ide@vger.kernel.org
CC: linux-usb@vger.kernel.org
CC: laforge@gnumonks.org
CC: linux-mtd@lists.infradead.org
CC: linux-bluetooth@vger.kernel.org
CC: alsa-devel@alsa-project.org
CC: linux-serial@vger.kernel.org
CC: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/char/pcmcia/ipwireless/main.c         |   14 ++------------
 drivers/isdn/hisax/sedlbauer_cs.c             |    7 +++----
 drivers/mtd/maps/pcmciamtd.c                  |   13 ++++++-------
 drivers/net/pcmcia/fmvj18x_cs.c               |   10 ++--------
 drivers/net/pcmcia/ibmtr_cs.c                 |   11 +++--------
 drivers/net/pcmcia/pcnet_cs.c                 |   14 ++++----------
 drivers/net/pcmcia/smc91c92_cs.c              |    9 +++------
 drivers/net/pcmcia/xirc2ps_cs.c               |    5 +----
 drivers/net/wireless/airo_cs.c                |    6 ++----
 drivers/net/wireless/b43/pcmcia.c             |    5 +----
 drivers/net/wireless/ray_cs.c                 |   13 +++----------
 drivers/pcmcia/pcmcia_resource.c              |    9 +++------
 drivers/scsi/pcmcia/nsp_cs.c                  |    5 ++---
 drivers/staging/comedi/drivers/ni_daq_700.c   |    6 ++----
 drivers/staging/comedi/drivers/ni_daq_dio24.c |    6 ++----
 drivers/staging/comedi/drivers/ni_labpc_cs.c  |    6 ++----
 include/pcmcia/cs.h                           |    6 ------
 include/pcmcia/ds.h                           |    2 +-
 18 files changed, 42 insertions(+), 105 deletions(-)

diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 5f87b9f..6c4aa4b 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -84,8 +84,6 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 {
 	struct ipw_dev *ipw = priv_data;
 	struct resource *io_resource;
-	memreq_t memreq_attr_memory;
-	memreq_t memreq_common_memory;
 	int ret;
 
 	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
@@ -121,11 +119,8 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	if (ret != 0)
 		goto exit1;
 
-	memreq_common_memory.CardOffset = cfg->mem.win[0].card_addr;
-	memreq_common_memory.Page = 0;
-
 	ret = pcmcia_map_mem_page(p_dev, ipw->handle_common_memory,
-				&memreq_common_memory);
+				cfg->mem.win[0].card_addr);
 
 	if (ret != 0)
 		goto exit2;
@@ -150,12 +145,7 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	if (ret != 0)
 		goto exit2;
 
-	memreq_attr_memory.CardOffset = 0;
-	memreq_attr_memory.Page = 0;
-
-	ret = pcmcia_map_mem_page(p_dev, ipw->handle_attr_memory,
-				&memreq_attr_memory);
-
+	ret = pcmcia_map_mem_page(p_dev, ipw->handle_attr_memory, 0);
 	if (ret != 0)
 		goto exit3;
 
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 4755eb4..0b06dbb 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -232,7 +232,6 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 	*/
 	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
 		cistpl_mem_t *mem = (cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-		memreq_t map;
 		req->Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM;
 		req->Attributes |= WIN_ENABLE;
 		req->Base = mem->win[0].host_addr;
@@ -240,9 +239,9 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 		req->AccessSpeed = 0;
 		if (pcmcia_request_window(p_dev, req, &p_dev->win) != 0)
 			return -ENODEV;
-		map.Page = 0;
-		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map) != 0)
+
+		if (pcmcia_map_mem_page(p_dev, p_dev->win,
+						mem->win[0].card_addr) != 0)
 			return -ENODEV;
 	}
 	return 0;
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index 7948816..f97463e 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -102,7 +102,7 @@ static caddr_t remap_window(struct map_info *map, unsigned long to)
 {
 	struct pcmciamtd_dev *dev = (struct pcmciamtd_dev *)map->map_priv_1;
 	window_handle_t win = (window_handle_t)map->map_priv_2;
-	memreq_t mrq;
+	unsigned int offset;
 	int ret;
 
 	if (!pcmcia_dev_present(dev->p_dev)) {
@@ -110,15 +110,14 @@ static caddr_t remap_window(struct map_info *map, unsigned long to)
 		return 0;
 	}
 
-	mrq.CardOffset = to & ~(dev->win_size-1);
-	if(mrq.CardOffset != dev->offset) {
+	offset = to & ~(dev->win_size-1);
+	if (offset != dev->offset) {
 		DEBUG(2, "Remapping window from 0x%8.8x to 0x%8.8x",
-		      dev->offset, mrq.CardOffset);
-		mrq.Page = 0;
-		ret = pcmcia_map_mem_page(dev->p_dev, win, &mrq);
+		      dev->offset, offset);
+		ret = pcmcia_map_mem_page(dev->p_dev, win, offset);
 		if (ret != 0)
 			return NULL;
-		dev->offset = mrq.CardOffset;
+		dev->offset = offset;
 	}
 	return dev->win_base + (to & (dev->win_size-1));
 }
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 6993044..98fffb0 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -545,7 +545,6 @@ failed:
 static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
 {
     win_req_t req;
-    memreq_t mem;
     u_char __iomem *base;
     int i, j;
 
@@ -558,9 +557,7 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
 	return -1;
 
     base = ioremap(req.Base, req.Size);
-    mem.Page = 0;
-    mem.CardOffset = 0;
-    pcmcia_map_mem_page(link, link->win, &mem);
+    pcmcia_map_mem_page(link, link->win, 0);
 
     /*
      *  MBH10304 CISTPL_FUNCE_LAN_NODE_ID format
@@ -594,7 +591,6 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
 static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 {
     win_req_t req;
-    memreq_t mem;
     int i;
     struct net_device *dev = link->priv;
     unsigned int ioaddr;
@@ -614,9 +610,7 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 	return -1;
     }
 
-    mem.Page = 0;
-    mem.CardOffset = 0;
-    i = pcmcia_map_mem_page(link, link->win, &mem);
+    i = pcmcia_map_mem_page(link, link->win, 0);
     if (i != 0) {
 	iounmap(lp->base);
 	lp->base = NULL;
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 3fd8595..c0b3cdd 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -211,7 +211,6 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     struct net_device *dev = info->dev;
     struct tok_info *ti = netdev_priv(dev);
     win_req_t req;
-    memreq_t mem;
     int i, ret;
 
     dev_dbg(&link->dev, "ibmtr_config\n");
@@ -250,9 +249,7 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    mem.CardOffset = mmiobase;
-    mem.Page = 0;
-    ret = pcmcia_map_mem_page(link, link->win, &mem);
+    ret = pcmcia_map_mem_page(link, link->win, mmiobase);
     if (ret)
 	    goto failed;
     ti->mmio = ioremap(req.Base, req.Size);
@@ -267,13 +264,11 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    mem.CardOffset = srambase;
-    mem.Page = 0;
-    ret = pcmcia_map_mem_page(link, info->sram_win_handle, &mem);
+    ret = pcmcia_map_mem_page(link, info->sram_win_handle, srambase);
     if (ret)
 	    goto failed;
 
-    ti->sram_base = mem.CardOffset >> 12;
+    ti->sram_base = srambase >> 12;
     ti->sram_virt = ioremap(req.Base, req.Size);
     ti->sram_phys = req.Base;
 
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 9c5fc9d..c3edfe4 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -301,7 +301,6 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     win_req_t req;
-    memreq_t mem;
     u_char __iomem *base, *virt;
     int i, j;
 
@@ -314,10 +313,8 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
 	return NULL;
 
     virt = ioremap(req.Base, req.Size);
-    mem.Page = 0;
     for (i = 0; i < NR_INFO; i++) {
-	mem.CardOffset = hw_info[i].offset & ~(req.Size-1);
-	pcmcia_map_mem_page(link, link->win, &mem);
+	pcmcia_map_mem_page(link, link->win, hw_info[i].offset & ~(req.Size-1));
 	base = &virt[hw_info[i].offset & (req.Size-1)];
 	if ((readb(base+0) == hw_info[i].a0) &&
 	    (readb(base+2) == hw_info[i].a1) &&
@@ -1463,7 +1460,6 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     struct net_device *dev = link->priv;
     pcnet_dev_t *info = PRIV(dev);
     win_req_t req;
-    memreq_t mem;
     int i, window_size, offset, ret;
 
     window_size = (stop_pg - start_pg) << 8;
@@ -1482,11 +1478,9 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     if (ret)
 	    goto failed;
 
-    mem.CardOffset = (start_pg << 8) + cm_offset;
-    offset = mem.CardOffset % window_size;
-    mem.CardOffset -= offset;
-    mem.Page = 0;
-    ret = pcmcia_map_mem_page(link, link->win, &mem);
+    offset = (start_pg << 8) + cm_offset;
+    offset -= offset % window_size;
+    ret = pcmcia_map_mem_page(link, link->win, offset);
     if (ret)
 	    goto failed;
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index a5e4779..377367d 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -443,7 +443,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     struct net_device *dev = link->priv;
     struct smc_private *smc = netdev_priv(dev);
     win_req_t req;
-    memreq_t mem;
+    unsigned int offset;
     int i;
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
@@ -467,11 +467,8 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 	    return -ENODEV;
 
     smc->base = ioremap(req.Base, req.Size);
-    mem.CardOffset = mem.Page = 0;
-    if (smc->manfid == MANFID_MOTOROLA)
-	mem.CardOffset = link->conf.ConfigBase;
-    i = pcmcia_map_mem_page(link, link->win, &mem);
-
+    offset = (smc->manfid == MANFID_MOTOROLA) ? link->conf.ConfigBase : 0;
+    i = pcmcia_map_mem_page(link, link->win, offset);
     if ((i == 0) &&
 	(smc->manfid == MANFID_MEGAHERTZ) &&
 	(smc->cardid == PRODID_MEGAHERTZ_EM3288))
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 8fb0eb1..4eb6f98 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -870,7 +870,6 @@ xirc2ps_config(struct pcmcia_device * link)
 
     if (local->dingo) {
 	win_req_t req;
-	memreq_t mem;
 
 	/* Reset the modem's BAR to the correct value
 	 * This is necessary because in the RequestConfiguration call,
@@ -898,9 +897,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	    goto config_error;
 
 	local->dingo_ccr = ioremap(req.Base,0x1000) + 0x0800;
-	mem.CardOffset = 0x0;
-	mem.Page = 0;
-	if ((err = pcmcia_map_mem_page(link, link->win, &mem)))
+	if ((err = pcmcia_map_mem_page(link, link->win, 0)))
 	    goto config_error;
 
 	/* Setup the CCRs; there are no infos in the CIS about the Ethernet
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index d241b4a..d47672c 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -207,16 +207,14 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 	*/
 	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
 		cistpl_mem_t *mem = (cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-		memreq_t map;
 		req->Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM;
 		req->Base = mem->win[0].host_addr;
 		req->Size = mem->win[0].len;
 		req->AccessSpeed = 0;
 		if (pcmcia_request_window(p_dev, req, &p_dev->win) != 0)
 			return -ENODEV;
-		map.Page = 0;
-		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map) != 0)
+		if (pcmcia_map_mem_page(p_dev, p_dev->win,
+						mem->win[0].card_addr) != 0)
 			return -ENODEV;
 	}
 	/* If we got this far, we're cool! */
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 7c9af82..ffe1f89 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -64,7 +64,6 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 {
 	struct ssb_bus *ssb;
 	win_req_t win;
-	memreq_t mem;
 	int err = -ENOMEM;
 	int res = 0;
 
@@ -87,9 +86,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	if (res != 0)
 		goto err_kfree_ssb;
 
-	mem.CardOffset = 0;
-	mem.Page = 0;
-	res = pcmcia_map_mem_page(dev, dev->win, &mem);
+	res = pcmcia_map_mem_page(dev, dev->win, 0);
 	if (res != 0)
 		goto err_disable;
 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index b83d5ef..7eb339a 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -393,7 +393,6 @@ static int ray_config(struct pcmcia_device *link)
 	int ret = 0;
 	int i;
 	win_req_t req;
-	memreq_t mem;
 	struct net_device *dev = (struct net_device *)link->priv;
 	ray_dev_t *local = netdev_priv(dev);
 
@@ -430,9 +429,7 @@ static int ray_config(struct pcmcia_device *link)
 	ret = pcmcia_request_window(link, &req, &link->win);
 	if (ret)
 		goto failed;
-	mem.CardOffset = 0x0000;
-	mem.Page = 0;
-	ret = pcmcia_map_mem_page(link, link->win, &mem);
+	ret = pcmcia_map_mem_page(link, link->win, 0);
 	if (ret)
 		goto failed;
 	local->sram = ioremap(req.Base, req.Size);
@@ -446,9 +443,7 @@ static int ray_config(struct pcmcia_device *link)
 	ret = pcmcia_request_window(link, &req, &local->rmem_handle);
 	if (ret)
 		goto failed;
-	mem.CardOffset = 0x8000;
-	mem.Page = 0;
-	ret = pcmcia_map_mem_page(link, local->rmem_handle, &mem);
+	ret = pcmcia_map_mem_page(link, local->rmem_handle, 0x8000);
 	if (ret)
 		goto failed;
 	local->rmem = ioremap(req.Base, req.Size);
@@ -462,9 +457,7 @@ static int ray_config(struct pcmcia_device *link)
 	ret = pcmcia_request_window(link, &req, &local->amem_handle);
 	if (ret)
 		goto failed;
-	mem.CardOffset = 0x0000;
-	mem.Page = 0;
-	ret = pcmcia_map_mem_page(link, local->amem_handle, &mem);
+	ret = pcmcia_map_mem_page(link, local->amem_handle, 0);
 	if (ret)
 		goto failed;
 	local->amem = ioremap(req.Base, req.Size);
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index a48d4a9..975baaa 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -193,7 +193,7 @@ EXPORT_SYMBOL(pcmcia_write_config_byte);
 
 
 int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t wh,
-			memreq_t *req)
+			unsigned int offset)
 {
 	struct pcmcia_socket *s = p_dev->socket;
 	int ret;
@@ -201,12 +201,9 @@ int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t wh,
 	wh--;
 	if (wh >= MAX_WIN)
 		return -EINVAL;
-	if (req->Page != 0) {
-		dev_dbg(&s->dev, "failure: requested page is zero\n");
-		return -EINVAL;
-	}
+
 	mutex_lock(&s->ops_mutex);
-	s->win[wh].card_start = req->CardOffset;
+	s->win[wh].card_start = offset;
 	ret = s->ops->set_mem_map(s, &s->win[wh]);
 	if (ret)
 		dev_warn(&s->dev, "failed to set_mem_map\n");
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 8bb598b..dd9b403 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1661,7 +1661,6 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 		}
 
 		if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
-			memreq_t	map;
 			cistpl_mem_t	*mem =
 				(cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
 			cfg_mem->req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM;
@@ -1673,8 +1672,8 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 			cfg_mem->req.AccessSpeed = 0;
 			if (pcmcia_request_window(p_dev, &cfg_mem->req, &p_dev->win) != 0)
 				goto next_entry;
-			map.Page = 0; map.CardOffset = mem->win[0].card_addr;
-			if (pcmcia_map_mem_page(p_dev, p_dev->win, &map) != 0)
+			if (pcmcia_map_mem_page(p_dev, p_dev->win,
+					mem->win[0].card_addr) != 0)
 				goto next_entry;
 
 			cfg_mem->data->MmioAddress = (unsigned long) ioremap_nocache(cfg_mem->req.Base, cfg_mem->req.Size);
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 7e41ad9..abaa40b 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -556,7 +556,6 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				void *priv_data)
 {
 	win_req_t *req = priv_data;
-	memreq_t map;
 
 	if (cfg->index == 0)
 		return -ENODEV;
@@ -602,9 +601,8 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		req->AccessSpeed = 0;
 		if (pcmcia_request_window(p_dev, req, &p_dev->win))
 			return -ENODEV;
-		map.Page = 0;
-		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map))
+		if (pcmcia_map_mem_page(p_dev, p_dev->win,
+				mem->win[0].card_addr))
 			return -ENODEV;
 	}
 	/* If we got this far, we're cool! */
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index b2483f8..caccece 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -308,7 +308,6 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				void *priv_data)
 {
 	win_req_t *req = priv_data;
-	memreq_t map;
 
 	if (cfg->index == 0)
 		return -ENODEV;
@@ -354,9 +353,8 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		req->AccessSpeed = 0;
 		if (pcmcia_request_window(p_dev, req, &p_dev->win))
 			return -ENODEV;
-		map.Page = 0;
-		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map))
+		if (pcmcia_map_mem_page(p_dev, p_dev->win,
+						mem->win[0].card_addr))
 			return -ENODEV;
 	}
 	/* If we got this far, we're cool! */
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index c1444b4..94d9f7f 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -286,7 +286,6 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				void *priv_data)
 {
 	win_req_t *req = priv_data;
-	memreq_t map;
 
 	if (cfg->index == 0)
 		return -ENODEV;
@@ -332,9 +331,8 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		req->AccessSpeed = 0;
 		if (pcmcia_request_window(p_dev, req, &p_dev->win))
 			return -ENODEV;
-		map.Page = 0;
-		map.CardOffset = mem->win[0].card_addr;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win, &map))
+		if (pcmcia_map_mem_page(p_dev, p_dev->win,
+						mem->win[0].card_addr))
 			return -ENODEV;
 	}
 	/* If we got this far, we're cool! */
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 583a4e3..e4faf44 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -68,12 +68,6 @@ typedef struct config_req_t {
 #define PRESENT_IOBASE_3	0x100
 #define PRESENT_IOSIZE		0x200
 
-/* For GetMemPage, MapMemPage */
-typedef struct memreq_t {
-    u_int	CardOffset;
-    u_short	Page;
-} memreq_t;
-
 /* For RequestWindow */
 typedef struct win_req_t {
     u_int	Attributes;
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 0748bec..a2bf3a7 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -202,7 +202,7 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req,
 			  window_handle_t *wh);
 int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t win);
 int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t win,
-			memreq_t *req);
+			unsigned int offset);
 
 int pcmcia_modify_configuration(struct pcmcia_device *p_dev, modconf_t *mod);
 void pcmcia_disable_device(struct pcmcia_device *p_dev);
-- 
1.7.0.4

