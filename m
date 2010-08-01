From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 08/11] pcmcia: use struct resource for PCMCIA devices, part 2
Date: Sun,  1 Aug 2010 14:59:07 +0200
Message-ID: <1280667550-3040-8-git-send-email-linux@dominikbrodowski.net>
References: <20100801125749.GA2564@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-mtd@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:33795 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755722Ab0HAM7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Aug 2010 08:59:48 -0400
In-Reply-To: <20100801125749.GA2564@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use struct resource * also for iomem resources.

CC: linux-mtd@lists.infradead.org
CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/char/pcmcia/ipwireless/main.c |   13 +-----
 drivers/mtd/maps/pcmciamtd.c          |    1 -
 drivers/net/pcmcia/ibmtr_cs.c         |    1 -
 drivers/net/wireless/b43/pcmcia.c     |    3 +-
 drivers/net/wireless/ray_cs.c         |    8 ----
 drivers/pcmcia/cs_internal.h          |    1 +
 drivers/pcmcia/ds.c                   |    7 ++-
 drivers/pcmcia/pcmcia_resource.c      |   70 ++++++++++++++++++---------------
 include/pcmcia/cs.h                   |   35 +++++++----------
 include/pcmcia/ds.h                   |   15 ++++++-
 10 files changed, 74 insertions(+), 80 deletions(-)

diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 6c4aa4b..67bdb05 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -157,15 +157,12 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	return 0;
 
 exit3:
-	pcmcia_release_window(p_dev, ipw->handle_attr_memory);
 exit2:
 	if (ipw->common_memory) {
 		release_mem_region(ipw->request_common_memory.Base,
 				ipw->request_common_memory.Size);
 		iounmap(ipw->common_memory);
-		pcmcia_release_window(p_dev, ipw->handle_common_memory);
-	} else
-		pcmcia_release_window(p_dev, ipw->handle_common_memory);
+	}
 exit1:
 	release_resource(io_resource);
 	pcmcia_disable_device(p_dev);
@@ -238,13 +235,12 @@ exit:
 		release_mem_region(ipw->request_attr_memory.Base,
 				ipw->request_attr_memory.Size);
 		iounmap(ipw->attr_memory);
-		pcmcia_release_window(link, ipw->handle_attr_memory);
+
 	}
 	if (ipw->common_memory) {
 		release_mem_region(ipw->request_common_memory.Base,
 				ipw->request_common_memory.Size);
 		iounmap(ipw->common_memory);
-		pcmcia_release_window(link, ipw->handle_common_memory);
 	}
 	pcmcia_disable_device(link);
 	return -1;
@@ -262,11 +258,6 @@ static void release_ipwireless(struct ipw_dev *ipw)
 				ipw->request_attr_memory.Size);
 		iounmap(ipw->attr_memory);
 	}
-	if (ipw->common_memory)
-		pcmcia_release_window(ipw->link, ipw->handle_common_memory);
-	if (ipw->attr_memory)
-		pcmcia_release_window(ipw->link, ipw->handle_attr_memory);
-
 	pcmcia_disable_device(ipw->link);
 }
 
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index f97463e..e9ca5ba 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -344,7 +344,6 @@ static void pcmciamtd_release(struct pcmcia_device *link)
 			iounmap(dev->win_base);
 			dev->win_base = NULL;
 		}
-		pcmcia_release_window(link, link->win);
 	}
 	pcmcia_disable_device(link);
 }
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index c0b3cdd..b0d06a3 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -319,7 +319,6 @@ static void ibmtr_release(struct pcmcia_device *link)
 	if (link->win) {
 		struct tok_info *ti = netdev_priv(dev);
 		iounmap(ti->mmio);
-		pcmcia_release_window(link, info->sram_win_handle);
 	}
 	pcmcia_disable_device(link);
 }
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index ffe1f89..dfbc41d 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -76,8 +76,7 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	dev->conf.Attributes = CONF_ENABLE_IRQ;
 	dev->conf.IntType = INT_MEMORY_AND_IO;
 
-	win.Attributes = WIN_ADDR_SPACE_MEM | WIN_MEMORY_TYPE_CM |
-			 WIN_ENABLE | WIN_DATA_WIDTH_16 |
+	win.Attributes =  WIN_ENABLE | WIN_DATA_WIDTH_16 |
 			 WIN_USE_WAIT;
 	win.Base = 0;
 	win.Size = SSB_CORE_SIZE;
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 7eb339a..a860bce 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -785,7 +785,6 @@ static void ray_release(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 	ray_dev_t *local = netdev_priv(dev);
-	int i;
 
 	dev_dbg(&link->dev, "ray_release\n");
 
@@ -794,13 +793,6 @@ static void ray_release(struct pcmcia_device *link)
 	iounmap(local->sram);
 	iounmap(local->rmem);
 	iounmap(local->amem);
-	/* Do bother checking to see if these succeed or not */
-	i = pcmcia_release_window(link, local->amem_handle);
-	if (i != 0)
-		dev_dbg(&link->dev, "ReleaseWindow(local->amem) ret = %x\n", i);
-	i = pcmcia_release_window(link, local->rmem_handle);
-	if (i != 0)
-		dev_dbg(&link->dev, "ReleaseWindow(local->rmem) ret = %x\n", i);
 	pcmcia_disable_device(link);
 
 	dev_dbg(&link->dev, "ray_release ending\n");
diff --git a/drivers/pcmcia/cs_internal.h b/drivers/pcmcia/cs_internal.h
index 511ac75..37d38b5 100644
--- a/drivers/pcmcia/cs_internal.h
+++ b/drivers/pcmcia/cs_internal.h
@@ -40,6 +40,7 @@ typedef struct config_t {
 	unsigned int	CardValues;
 
 	struct resource io[MAX_IO_WIN]; /* io ports */
+	struct resource mem[MAX_WIN];   /* mem areas */
 
 	struct {
 		u_int	Attributes;
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index 7ddd19a..61de128 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -552,13 +552,16 @@ static struct pcmcia_device *pcmcia_device_add(struct pcmcia_socket *s,
 		}
 		p_dev->function_config = c;
 		kref_init(&c->ref);
-		for (i = 0; i < MAX_IO_WIN; i++) {
+		for (i = 0; i < (MAX_IO_WIN + MAX_WIN); i++) {
 			c->io[i].name = dev_name(&p_dev->dev);
-			c->io[i].flags = IORESOURCE_IO;
+			c->io[i].flags = i < MAX_IO_WIN ? IORESOURCE_IO :
+				IORESOURCE_MEM;
 		}
 	}
 	for (i = 0; i < MAX_IO_WIN; i++)
 		p_dev->resource[i] = &p_dev->function_config->io[i];
+	for (; i < (MAX_IO_WIN + MAX_WIN); i++)
+		p_dev->resource[i] = &p_dev->function_config->mem[i-MAX_IO_WIN];
 
 	mutex_unlock(&s->ops_mutex);
 
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 975baaa..01f8e56 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -196,15 +196,17 @@ int pcmcia_map_mem_page(struct pcmcia_device *p_dev, window_handle_t wh,
 			unsigned int offset)
 {
 	struct pcmcia_socket *s = p_dev->socket;
+	struct resource *res = wh;
+	unsigned int w;
 	int ret;
 
-	wh--;
-	if (wh >= MAX_WIN)
+	w = ((res->flags & IORESOURCE_BITS & WIN_FLAGS_REQ) >> 2) - 1;
+	if (w >= MAX_WIN)
 		return -EINVAL;
 
 	mutex_lock(&s->ops_mutex);
-	s->win[wh].card_start = offset;
-	ret = s->ops->set_mem_map(s, &s->win[wh]);
+	s->win[w].card_start = offset;
+	ret = s->ops->set_mem_map(s, &s->win[w]);
 	if (ret)
 		dev_warn(&s->dev, "failed to set_mem_map\n");
 	mutex_unlock(&s->ops_mutex);
@@ -371,19 +373,22 @@ out:
 } /* pcmcia_release_io */
 
 
-int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t wh)
+int pcmcia_release_window(struct pcmcia_device *p_dev, struct resource *res)
 {
 	struct pcmcia_socket *s = p_dev->socket;
 	pccard_mem_map *win;
+	unsigned int w;
 
-	wh--;
-	if (wh >= MAX_WIN)
+	dev_dbg(&p_dev->dev, "releasing window %pR\n", res);
+
+	w = ((res->flags & IORESOURCE_BITS & WIN_FLAGS_REQ) >> 2) - 1;
+	if (w >= MAX_WIN)
 		return -EINVAL;
 
 	mutex_lock(&s->ops_mutex);
-	win = &s->win[wh];
+	win = &s->win[w];
 
-	if (!(p_dev->_win & CLIENT_WIN_REQ(wh))) {
+	if (!(p_dev->_win & CLIENT_WIN_REQ(w))) {
 		dev_dbg(&s->dev, "not releasing unknown window\n");
 		mutex_unlock(&s->ops_mutex);
 		return -EINVAL;
@@ -392,7 +397,7 @@ int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t wh)
 	/* Shut down memory window */
 	win->flags &= ~MAP_ACTIVE;
 	s->ops->set_mem_map(s, win);
-	s->state &= ~SOCKET_WIN_REQ(wh);
+	s->state &= ~SOCKET_WIN_REQ(w);
 
 	/* Release system memory */
 	if (win->res) {
@@ -400,7 +405,7 @@ int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t wh)
 		kfree(win->res);
 		win->res = NULL;
 	}
-	p_dev->_win &= ~CLIENT_WIN_REQ(wh);
+	p_dev->_win &= ~CLIENT_WIN_REQ(w);
 	mutex_unlock(&s->ops_mutex);
 
 	return 0;
@@ -775,23 +780,18 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 	struct pcmcia_socket *s = p_dev->socket;
 	pccard_mem_map *win;
 	u_long align;
+	struct resource *res;
 	int w;
 
 	if (!(s->state & SOCKET_PRESENT)) {
 		dev_dbg(&s->dev, "No card present\n");
 		return -ENODEV;
 	}
-	if (req->Attributes & (WIN_PAGED | WIN_SHARED)) {
-		dev_dbg(&s->dev, "bad attribute setting for iomem region\n");
-		return -EINVAL;
-	}
 
 	/* Window size defaults to smallest available */
 	if (req->Size == 0)
 		req->Size = s->map_size;
-	align = (((s->features & SS_CAP_MEM_ALIGN) ||
-		  (req->Attributes & WIN_STRICT_ALIGN)) ?
-		 req->Size : s->map_size);
+	align = (s->features & SS_CAP_MEM_ALIGN) ? req->Size : s->map_size;
 	if (req->Size & (s->map_size-1)) {
 		dev_dbg(&s->dev, "invalid map size\n");
 		return -EINVAL;
@@ -805,20 +805,21 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 		align = 0;
 
 	/* Allocate system memory window */
+	mutex_lock(&s->ops_mutex);
 	for (w = 0; w < MAX_WIN; w++)
 		if (!(s->state & SOCKET_WIN_REQ(w)))
 			break;
 	if (w == MAX_WIN) {
 		dev_dbg(&s->dev, "all windows are used already\n");
+		mutex_unlock(&s->ops_mutex);
 		return -EINVAL;
 	}
 
-	mutex_lock(&s->ops_mutex);
 	win = &s->win[w];
 
 	if (!(s->features & SS_CAP_STATIC_MAP)) {
 		win->res = pcmcia_find_mem_region(req->Base, req->Size, align,
-						      (req->Attributes & WIN_MAP_BELOW_1MB), s);
+						0, s);
 		if (!win->res) {
 			dev_dbg(&s->dev, "allocating mem region failed\n");
 			mutex_unlock(&s->ops_mutex);
@@ -829,16 +830,8 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 
 	/* Configure the socket controller */
 	win->map = w+1;
-	win->flags = 0;
+	win->flags = req->Attributes;
 	win->speed = req->AccessSpeed;
-	if (req->Attributes & WIN_MEMORY_TYPE)
-		win->flags |= MAP_ATTRIB;
-	if (req->Attributes & WIN_ENABLE)
-		win->flags |= MAP_ACTIVE;
-	if (req->Attributes & WIN_DATA_WIDTH_16)
-		win->flags |= MAP_16BIT;
-	if (req->Attributes & WIN_USE_WAIT)
-		win->flags |= MAP_USE_WAIT;
 	win->card_start = 0;
 
 	if (s->ops->set_mem_map(s, win) != 0) {
@@ -854,8 +847,16 @@ int pcmcia_request_window(struct pcmcia_device *p_dev, win_req_t *req, window_ha
 	else
 		req->Base = win->res->start;
 
+	/* convert to new-style resources */
+	res = p_dev->resource[w + MAX_IO_WIN];
+	res->start = req->Base;
+	res->end = req->Base + req->Size - 1;
+	res->flags &= ~IORESOURCE_BITS;
+	res->flags |= (req->Attributes & WIN_FLAGS_MAP) | (win->map << 2);
+	dev_dbg(&s->dev, "request_window results in %pR\n", res);
+
 	mutex_unlock(&s->ops_mutex);
-	*wh = w + 1;
+	*wh = res;
 
 	return 0;
 } /* pcmcia_request_window */
@@ -863,13 +864,18 @@ EXPORT_SYMBOL(pcmcia_request_window);
 
 void pcmcia_disable_device(struct pcmcia_device *p_dev)
 {
+	int i;
+	for (i = 0; i < MAX_WIN; i++) {
+		struct resource *res = p_dev->resource[MAX_IO_WIN + i];
+		if (res->flags & WIN_FLAGS_REQ)
+			pcmcia_release_window(p_dev, res);
+	}
+
 	pcmcia_release_configuration(p_dev);
 	pcmcia_release_io(p_dev);
 	if (p_dev->_irq) {
 		free_irq(p_dev->irq, p_dev->priv);
 		p_dev->_irq = 0;
 	}
-	if (p_dev->win)
-		pcmcia_release_window(p_dev, p_dev->win);
 }
 EXPORT_SYMBOL(pcmcia_disable_device);
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index e4faf44..68d8bde 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -77,26 +77,19 @@ typedef struct win_req_t {
 } win_req_t;
 
 /* Attributes for RequestWindow */
-#define WIN_ADDR_SPACE		0x0001
-#define WIN_ADDR_SPACE_MEM	0x0000
-#define WIN_ADDR_SPACE_IO	0x0001
-#define WIN_MEMORY_TYPE		0x0002
-#define WIN_MEMORY_TYPE_CM	0x0000
-#define WIN_MEMORY_TYPE_AM	0x0002
-#define WIN_ENABLE		0x0004
-#define WIN_DATA_WIDTH		0x0018
-#define WIN_DATA_WIDTH_8	0x0000
-#define WIN_DATA_WIDTH_16	0x0008
-#define WIN_DATA_WIDTH_32	0x0010
-#define WIN_PAGED		0x0020
-#define WIN_SHARED		0x0040
-#define WIN_FIRST_SHARED	0x0080
-#define WIN_USE_WAIT		0x0100
-#define WIN_STRICT_ALIGN	0x0200
-#define WIN_MAP_BELOW_1MB	0x0400
-#define WIN_PREFETCH		0x0800
-#define WIN_CACHEABLE		0x1000
-#define WIN_BAR_MASK		0xe000
-#define WIN_BAR_SHIFT		13
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
 
 #endif /* _LINUX_CS_H */
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index a2bf3a7..70c58ed 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -36,7 +36,7 @@ struct pcmcia_device;
 struct config_t;
 struct net_device;
 
-typedef unsigned long window_handle_t;
+typedef struct resource *window_handle_t;
 
 /* dynamic device IDs for PCMCIA device drivers. See
  * Documentation/pcmcia/driver.txt for details.
@@ -63,6 +63,17 @@ struct pcmcia_driver {
 int pcmcia_register_driver(struct pcmcia_driver *driver);
 void pcmcia_unregister_driver(struct pcmcia_driver *driver);
 
+/* for struct resource * array embedded in struct pcmcia_device */
+enum {
+	PCMCIA_IOPORT_0,
+	PCMCIA_IOPORT_1,
+	PCMCIA_IOMEM_0,
+	PCMCIA_IOMEM_1,
+	PCMCIA_IOMEM_2,
+	PCMCIA_IOMEM_3,
+	PCMCIA_NUM_RESOURCES,
+};
+
 struct pcmcia_device {
 	/* the socket and the device_no [for multifunction devices]
 	   uniquely define a pcmcia_device */
@@ -85,7 +96,7 @@ struct pcmcia_device {
 
 	/* device setup */
 	unsigned int		irq;
-	struct resource		*resource[MAX_IO_WIN];
+	struct resource		*resource[PCMCIA_NUM_RESOURCES];
 
 	unsigned int		io_lines; /* number of I/O lines */
 
-- 
1.7.0.4

