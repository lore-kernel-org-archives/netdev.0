From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 11/11] pcmcia: do not request windows if you don't need to
Date: Sun,  1 Aug 2010 14:59:10 +0200
Message-ID: <1280667550-3040-11-git-send-email-linux@dominikbrodowski.net>
References: <20100801125749.GA2564@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:33782 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754266Ab0HAM7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Aug 2010 08:59:44 -0400
In-Reply-To: <20100801125749.GA2564@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several drivers contained dummy code to request for memory windows,
even though they never made use of it. Remove all such code
snippets.

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/isdn/hisax/sedlbauer_cs.c             |   37 +------------------------
 drivers/net/wireless/airo_cs.c                |   37 +------------------------
 drivers/staging/comedi/drivers/ni_daq_700.c   |   23 +---------------
 drivers/staging/comedi/drivers/ni_daq_dio24.c |   24 +---------------
 drivers/staging/comedi/drivers/ni_labpc_cs.c  |   24 +---------------
 5 files changed, 5 insertions(+), 140 deletions(-)

diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 0b06dbb..a024192 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -171,8 +171,6 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 				  unsigned int vcc,
 				  void *priv_data)
 {
-	win_req_t *req = priv_data;
-
 	if (cfg->index == 0)
 		return -ENODEV;
 
@@ -219,31 +217,6 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 			return -ENODEV;
 	}
 
-	/*
-	  Now set up a common memory window, if needed.  There is room
-	  in the struct pcmcia_device structure for one memory window handle,
-	  but if the base addresses need to be saved, or if multiple
-	  windows are needed, the info should go in the private data
-	  structure for this device.
-
-	  Note that the memory window base is a physical address, and
-	  needs to be mapped to virtual space with ioremap() before it
-	  is used.
-	*/
-	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
-		cistpl_mem_t *mem = (cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-		req->Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM;
-		req->Attributes |= WIN_ENABLE;
-		req->Base = mem->win[0].host_addr;
-		req->Size = mem->win[0].len;
-		req->AccessSpeed = 0;
-		if (pcmcia_request_window(p_dev, req, &p_dev->win) != 0)
-			return -ENODEV;
-
-		if (pcmcia_map_mem_page(p_dev, p_dev->win,
-						mem->win[0].card_addr) != 0)
-			return -ENODEV;
-	}
 	return 0;
 }
 
@@ -251,16 +224,11 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 
 static int __devinit sedlbauer_config(struct pcmcia_device *link)
 {
-    win_req_t *req;
     int ret;
     IsdnCard_t  icard;
 
     dev_dbg(&link->dev, "sedlbauer_config(0x%p)\n", link);
 
-    req = kzalloc(sizeof(win_req_t), GFP_KERNEL);
-    if (!req)
-	    return -ENOMEM;
-
     /*
       In this loop, we scan the CIS for configuration table entries,
       each of which describes a valid card configuration, including
@@ -273,7 +241,7 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
       these things without consulting the CIS, and most client drivers
       will only use the CIS to fill in implementation-defined details.
     */
-    ret = pcmcia_loop_config(link, sedlbauer_config_check, req);
+    ret = pcmcia_loop_config(link, sedlbauer_config_check, NULL);
     if (ret)
 	    goto failed;
 
@@ -297,9 +265,6 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
 	printk(" & %pR", link->resource[0]);
     if (link->resource[1])
 	printk(" & %pR", link->resource[1]);
-    if (link->win)
-	printk(", mem 0x%06lx-0x%06lx", req->Base,
-	       req->Base+req->Size-1);
     printk("\n");
 
     icard.para[0] = link->irq;
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index d47672c..9a121a5 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -154,8 +154,6 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 				unsigned int vcc,
 				void *priv_data)
 {
-	win_req_t *req = priv_data;
-
 	if (cfg->index == 0)
 		return -ENODEV;
 
@@ -194,29 +192,6 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 	if (pcmcia_request_io(p_dev) != 0)
 		return -ENODEV;
 
-	/*
-	  Now set up a common memory window, if needed.  There is room
-	  in the struct pcmcia_device structure for one memory window handle,
-	  but if the base addresses need to be saved, or if multiple
-	  windows are needed, the info should go in the private data
-	  structure for this device.
-
-	  Note that the memory window base is a physical address, and
-	  needs to be mapped to virtual space with ioremap() before it
-	  is used.
-	*/
-	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
-		cistpl_mem_t *mem = (cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-		req->Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM;
-		req->Base = mem->win[0].host_addr;
-		req->Size = mem->win[0].len;
-		req->AccessSpeed = 0;
-		if (pcmcia_request_window(p_dev, req, &p_dev->win) != 0)
-			return -ENODEV;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win,
-						mem->win[0].card_addr) != 0)
-			return -ENODEV;
-	}
 	/* If we got this far, we're cool! */
 	return 0;
 }
@@ -225,17 +200,12 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 static int airo_config(struct pcmcia_device *link)
 {
 	local_info_t *dev;
-	win_req_t *req;
 	int ret;
 
 	dev = link->priv;
 
 	dev_dbg(&link->dev, "airo_config\n");
 
-	req = kzalloc(sizeof(win_req_t), GFP_KERNEL);
-	if (!req)
-		return -ENOMEM;
-
 	/*
 	 * In this loop, we scan the CIS for configuration table
 	 * entries, each of which describes a valid card
@@ -250,7 +220,7 @@ static int airo_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
-	ret = pcmcia_loop_config(link, airo_cs_config_check, req);
+	ret = pcmcia_loop_config(link, airo_cs_config_check, NULL);
 	if (ret)
 		goto failed;
 
@@ -281,16 +251,11 @@ static int airo_config(struct pcmcia_device *link)
 		printk(" & %pR", link->resource[0]);
 	if (link->resource[1])
 		printk(" & %pR", link->resource[1]);
-	if (link->win)
-		printk(", mem 0x%06lx-0x%06lx", req->Base,
-		       req->Base+req->Size-1);
 	printk("\n");
-	kfree(req);
 	return 0;
 
  failed:
 	airo_release(link);
-	kfree(req);
 	return -ENODEV;
 } /* airo_config */
 
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index abaa40b..bf2e84a 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -555,8 +555,6 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				unsigned int vcc,
 				void *priv_data)
 {
-	win_req_t *req = priv_data;
-
 	if (cfg->index == 0)
 		return -ENODEV;
 
@@ -589,22 +587,6 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 			return -ENODEV;
 	}
 
-	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
-		cistpl_mem_t *mem =
-			(cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-		req->Attributes = WIN_DATA_WIDTH_16 | WIN_MEMORY_TYPE_CM;
-		req->Attributes |= WIN_ENABLE;
-		req->Base = mem->win[0].host_addr;
-		req->Size = mem->win[0].len;
-		if (req->Size < 0x1000)
-			req->Size = 0x1000;
-		req->AccessSpeed = 0;
-		if (pcmcia_request_window(p_dev, req, &p_dev->win))
-			return -ENODEV;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win,
-				mem->win[0].card_addr))
-			return -ENODEV;
-	}
 	/* If we got this far, we're cool! */
 	return 0;
 }
@@ -618,7 +600,7 @@ static void dio700_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "dio700_config\n");
 
-	ret = pcmcia_loop_config(link, dio700_pcmcia_config_loop, &req);
+	ret = pcmcia_loop_config(link, dio700_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
 		goto failed;
@@ -644,9 +626,6 @@ static void dio700_config(struct pcmcia_device *link)
 		printk(", io %pR", link->resource[0]);
 	if (link->resource[1])
 		printk(" & %pR", link->resource[1]);
-	if (link->win)
-		printk(", mem 0x%06lx-0x%06lx", req.Base,
-		       req.Base + req.Size - 1);
 	printk("\n");
 
 	return;
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index caccece..9112e70 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -307,8 +307,6 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				unsigned int vcc,
 				void *priv_data)
 {
-	win_req_t *req = priv_data;
-
 	if (cfg->index == 0)
 		return -ENODEV;
 
@@ -341,22 +339,6 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 			return -ENODEV;
 	}
 
-	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
-		cistpl_mem_t *mem =
-			(cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-		req->Attributes = WIN_DATA_WIDTH_16 | WIN_MEMORY_TYPE_CM;
-		req->Attributes |= WIN_ENABLE;
-		req->Base = mem->win[0].host_addr;
-		req->Size = mem->win[0].len;
-		if (req->Size < 0x1000)
-			req->Size = 0x1000;
-		req->AccessSpeed = 0;
-		if (pcmcia_request_window(p_dev, req, &p_dev->win))
-			return -ENODEV;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win,
-						mem->win[0].card_addr))
-			return -ENODEV;
-	}
 	/* If we got this far, we're cool! */
 	return 0;
 }
@@ -364,13 +346,12 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 static void dio24_config(struct pcmcia_device *link)
 {
 	int ret;
-	win_req_t req;
 
 	printk(KERN_INFO "ni_daq_dio24: HOLA SOY YO! - config\n");
 
 	dev_dbg(&link->dev, "dio24_config\n");
 
-	ret = pcmcia_loop_config(link, dio24_pcmcia_config_loop, &req);
+	ret = pcmcia_loop_config(link, dio24_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
 		goto failed;
@@ -396,9 +377,6 @@ static void dio24_config(struct pcmcia_device *link)
 		printk(" & %pR", link->resource[0]);
 	if (link->resource[1])
 		printk(" & %pR", link->resource[1]);
-	if (link->win)
-		printk(", mem 0x%06lx-0x%06lx", req.Base,
-		       req.Base + req.Size - 1);
 	printk("\n");
 
 	return;
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 94d9f7f..f204961 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -285,8 +285,6 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				unsigned int vcc,
 				void *priv_data)
 {
-	win_req_t *req = priv_data;
-
 	if (cfg->index == 0)
 		return -ENODEV;
 
@@ -319,22 +317,6 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 			return -ENODEV;
 	}
 
-	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
-		cistpl_mem_t *mem =
-			(cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-		req->Attributes = WIN_DATA_WIDTH_16 | WIN_MEMORY_TYPE_CM;
-		req->Attributes |= WIN_ENABLE;
-		req->Base = mem->win[0].host_addr;
-		req->Size = mem->win[0].len;
-		if (req->Size < 0x1000)
-			req->Size = 0x1000;
-		req->AccessSpeed = 0;
-		if (pcmcia_request_window(p_dev, req, &p_dev->win))
-			return -ENODEV;
-		if (pcmcia_map_mem_page(p_dev, p_dev->win,
-						mem->win[0].card_addr))
-			return -ENODEV;
-	}
 	/* If we got this far, we're cool! */
 	return 0;
 }
@@ -343,11 +325,10 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 static void labpc_config(struct pcmcia_device *link)
 {
 	int ret;
-	win_req_t req;
 
 	dev_dbg(&link->dev, "labpc_config\n");
 
-	ret = pcmcia_loop_config(link, labpc_pcmcia_config_loop, &req);
+	ret = pcmcia_loop_config(link, labpc_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
 		goto failed;
@@ -373,9 +354,6 @@ static void labpc_config(struct pcmcia_device *link)
 		printk(" & %pR", link->resource[0]);
 	if (link->resource[1])
 		printk(" & %pR", link->resource[1]);
-	if (link->win)
-		printk(", mem 0x%06lx-0x%06lx", req.Base,
-		       req.Base + req.Size - 1);
 	printk("\n");
 
 	return;
-- 
1.7.0.4

