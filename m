From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 05/13] pcmcia: Pass struct pcmcia_device to pcmcia_release_window()
Date: Wed, 11 Nov 2009 21:38:11 +0100
Message-ID: <1257971899-9274-5-git-send-email-linux@dominikbrodowski.net>
References: <20091111203303.GA7939@comet.dominikbrodowski.net>
Cc: Magnus Damm <damm@opensource.se>, netdev@vger.kernel.org,
	Jiri Kosina <jkosina@suse.cz>,
	Dominik Brodowski <linux@dominikbrodowski.net>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:47651 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758867AbZKKUjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 15:39:00 -0500
In-Reply-To: <20091111203303.GA7939@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@opensource.se>

No logic changes, just pass struct pcmcia_device to pcmcia_release_window().

[linux@dominikbrodowski.net: update to 2.6.31]
CC: netdev@vger.kernel.org
CC: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Magnus Damm <damm@opensource.se>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/char/pcmcia/ipwireless/main.c |   14 +++++++-------
 drivers/mtd/maps/pcmciamtd.c          |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c       |    4 ++--
 drivers/net/pcmcia/ibmtr_cs.c         |    2 +-
 drivers/net/pcmcia/pcnet_cs.c         |    4 ++--
 drivers/net/wireless/ray_cs.c         |    4 ++--
 drivers/pcmcia/pcmcia_resource.c      |    5 +++--
 include/pcmcia/ds.h                   |    2 +-
 8 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 24bffa4..91ca23d 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -168,15 +168,15 @@ static int ipwireless_probe(struct pcmcia_device *p_dev,
 	return 0;
 
 exit3:
-	pcmcia_release_window(ipw->handle_attr_memory);
+	pcmcia_release_window(p_dev, ipw->handle_attr_memory);
 exit2:
 	if (ipw->common_memory) {
 		release_mem_region(ipw->request_common_memory.Base,
 				ipw->request_common_memory.Size);
 		iounmap(ipw->common_memory);
-		pcmcia_release_window(ipw->handle_common_memory);
+		pcmcia_release_window(p_dev, ipw->handle_common_memory);
 	} else
-		pcmcia_release_window(ipw->handle_common_memory);
+		pcmcia_release_window(p_dev, ipw->handle_common_memory);
 exit1:
 	release_resource(io_resource);
 	pcmcia_disable_device(p_dev);
@@ -260,13 +260,13 @@ exit:
 		release_mem_region(ipw->request_attr_memory.Base,
 				ipw->request_attr_memory.Size);
 		iounmap(ipw->attr_memory);
-		pcmcia_release_window(ipw->handle_attr_memory);
+		pcmcia_release_window(link, ipw->handle_attr_memory);
 	}
 	if (ipw->common_memory) {
 		release_mem_region(ipw->request_common_memory.Base,
 				ipw->request_common_memory.Size);
 		iounmap(ipw->common_memory);
-		pcmcia_release_window(ipw->handle_common_memory);
+		pcmcia_release_window(link, ipw->handle_common_memory);
 	}
 	pcmcia_disable_device(link);
 	return -1;
@@ -287,9 +287,9 @@ static void release_ipwireless(struct ipw_dev *ipw)
 		iounmap(ipw->attr_memory);
 	}
 	if (ipw->common_memory)
-		pcmcia_release_window(ipw->handle_common_memory);
+		pcmcia_release_window(ipw->link, ipw->handle_common_memory);
 	if (ipw->attr_memory)
-		pcmcia_release_window(ipw->handle_attr_memory);
+		pcmcia_release_window(ipw->link, ipw->handle_attr_memory);
 
 	/* Break the link with Card Services */
 	pcmcia_disable_device(ipw->link);
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index b698dba..16d9985 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -344,7 +344,7 @@ static void pcmciamtd_release(struct pcmcia_device *link)
 			iounmap(dev->win_base);
 			dev->win_base = NULL;
 		}
-		pcmcia_release_window(link->win);
+		pcmcia_release_window(link, link->win);
 	}
 	pcmcia_disable_device(link);
 }
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index fdec5c3..61726c8 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -599,7 +599,7 @@ static int fmvj18x_get_hwinfo(struct pcmcia_device *link, u_char *node_id)
     }
 
     iounmap(base);
-    j = pcmcia_release_window(link->win);
+    j = pcmcia_release_window(link, link->win);
     return (i != 0x200) ? 0 : -1;
 
 } /* fmvj18x_get_hwinfo */
@@ -666,7 +666,7 @@ static void fmvj18x_release(struct pcmcia_device *link)
 	tmp = lp->base;
 	lp->base = NULL;    /* set NULL before iounmap */
 	iounmap(tmp);
-	j = pcmcia_release_window(link->win);
+	j = pcmcia_release_window(link, link->win);
     }
 
     pcmcia_disable_device(link);
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 0d914f3..7a985ca 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -328,7 +328,7 @@ static void ibmtr_release(struct pcmcia_device *link)
 	if (link->win) {
 		struct tok_info *ti = netdev_priv(dev);
 		iounmap(ti->mmio);
-		pcmcia_release_window(info->sram_win_handle);
+		pcmcia_release_window(link, info->sram_win_handle);
 	}
 	pcmcia_disable_device(link);
 }
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 80ab9de..4156a6c 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -337,7 +337,7 @@ static hw_info_t *get_hwinfo(struct pcmcia_device *link)
     }
 
     iounmap(virt);
-    j = pcmcia_release_window(link->win);
+    j = pcmcia_release_window(link, link->win);
     return (i < NR_INFO) ? hw_info+i : NULL;
 } /* get_hwinfo */
 
@@ -1513,7 +1513,7 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     pcnet_reset_8390(dev);
     if (i != (TX_PAGES<<8)) {
 	iounmap(info->base);
-	pcmcia_release_window(link->win);
+	pcmcia_release_window(link, link->win);
 	info->base = NULL; link->win = NULL;
 	goto failed;
     }
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 28db791..ed32875 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -820,10 +820,10 @@ static void ray_release(struct pcmcia_device *link)
 	iounmap(local->rmem);
 	iounmap(local->amem);
 	/* Do bother checking to see if these succeed or not */
-	i = pcmcia_release_window(local->amem_handle);
+	i = pcmcia_release_window(link, local->amem_handle);
 	if (i != 0)
 		dev_dbg(&link->dev, "ReleaseWindow(local->amem) ret = %x\n", i);
-	i = pcmcia_release_window(local->rmem_handle);
+	i = pcmcia_release_window(link, local->rmem_handle);
 	if (i != 0)
 		dev_dbg(&link->dev, "ReleaseWindow(local->rmem) ret = %x\n", i);
 	pcmcia_disable_device(link);
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index cda48ea..820a6e5 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -442,9 +442,10 @@ static int pcmcia_release_irq(struct pcmcia_device *p_dev, irq_req_t *req)
 } /* pcmcia_release_irq */
 
 
-int pcmcia_release_window(window_handle_t win)
+int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t wh)
 {
 	struct pcmcia_socket *s;
+	window_handle_t win = wh;
 
 	if ((win == NULL) || (win->magic != WINDOW_MAGIC))
 		return -EINVAL;
@@ -891,7 +892,7 @@ void pcmcia_disable_device(struct pcmcia_device *p_dev) {
 	pcmcia_release_io(p_dev, &p_dev->io);
 	pcmcia_release_irq(p_dev, &p_dev->irq);
 	if (p_dev->win)
-		pcmcia_release_window(p_dev->win);
+		pcmcia_release_window(p_dev, p_dev->win);
 }
 EXPORT_SYMBOL(pcmcia_disable_device);
 
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index d82392d..40b098d 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -201,7 +201,7 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 
 int pcmcia_request_window(struct pcmcia_device **p_dev, win_req_t *req,
 			  window_handle_t *wh);
-int pcmcia_release_window(window_handle_t win);
+int pcmcia_release_window(struct pcmcia_device *p_dev, window_handle_t win);
 
 int pcmcia_get_mem_page(window_handle_t win, memreq_t *req);
 int pcmcia_map_mem_page(window_handle_t win, memreq_t *req);
-- 
1.6.0.4

