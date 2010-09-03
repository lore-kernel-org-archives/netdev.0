From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 02/15] pcmcia: split up modify_configuration() into two fixup functions
Date: Fri,  3 Sep 2010 12:57:01 +0200
Message-ID: <1283511434-21620-2-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-mtd@lists.infradead.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:44053 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757052Ab0ICK5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 06:57:54 -0400
In-Reply-To: <20100903105628.GA21255@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pcmcia_modify_configuration() was only used by two drivers to fix up
one issue each: setting the Vpp to a different value, and reducing
the IO width to 8 bit. Introduce two explicitly named functions
handling these things, and remove one further typedef.

CC: netdev@vger.kernel.org
CC: linux-mtd@lists.infradead.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/mtd/maps/pcmciamtd.c     |    8 +--
 drivers/net/pcmcia/smc91c92_cs.c |    5 +-
 drivers/pcmcia/pcmcia_resource.c |  128 +++++++++++++++++++-------------------
 include/pcmcia/cs.h              |   13 ----
 include/pcmcia/ds.h              |    4 +-
 5 files changed, 69 insertions(+), 89 deletions(-)

diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index fb3c538..31ce404 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -316,15 +316,9 @@ static void pcmciamtd_set_vpp(struct map_info *map, int on)
 {
 	struct pcmciamtd_dev *dev = (struct pcmciamtd_dev *)map->map_priv_1;
 	struct pcmcia_device *link = dev->p_dev;
-	modconf_t mod;
-	int ret;
-
-	mod.Attributes = CONF_VPP1_CHANGE_VALID | CONF_VPP2_CHANGE_VALID;
-	mod.Vcc = 0;
-	mod.Vpp1 = mod.Vpp2 = on ? dev->vpp : 0;
 
 	DEBUG(2, "dev = %p on = %d vpp = %d\n", dev, on, dev->vpp);
-	ret = pcmcia_modify_configuration(link, &mod);
+	pcmcia_fixup_vpp(link, on ? dev->vpp : 0);
 }
 
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index acc6807..395e586 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -816,13 +816,10 @@ static int check_sig(struct pcmcia_device *link)
     }
 
     if (width) {
-	    modconf_t mod = {
-		    .Attributes = CONF_IO_CHANGE_WIDTH,
-	    };
 	    printk(KERN_INFO "smc91c92_cs: using 8-bit IO window.\n");
 
 	    smc91c92_suspend(link);
-	    pcmcia_modify_configuration(link, &mod);
+	    pcmcia_fixup_iowidth(link);
 	    smc91c92_resume(link);
 	    return check_sig(link);
     }
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 3ea2e94..45c1ac4 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -226,90 +226,90 @@ int pcmcia_map_mem_page(struct pcmcia_device *p_dev, struct resource *res,
 EXPORT_SYMBOL(pcmcia_map_mem_page);
 
 
-/** pcmcia_modify_configuration
+/**
+ * pcmcia_fixup_iowidth() - reduce io width to 8bit
  *
- * Modify a locked socket configuration
+ * pcmcia_fixup_iowidth() allows a PCMCIA device driver to reduce the
+ * IO width to 8bit after having called pcmcia_request_configuration()
+ * previously.
  */
-int pcmcia_modify_configuration(struct pcmcia_device *p_dev,
-				modconf_t *mod)
+int pcmcia_fixup_iowidth(struct pcmcia_device *p_dev)
 {
-	struct pcmcia_socket *s;
-	config_t *c;
-	int ret;
-
-	s = p_dev->socket;
+	struct pcmcia_socket *s = p_dev->socket;
+	pccard_io_map io_off = { 0, 0, 0, 0, 1 };
+	pccard_io_map io_on;
+	int i, ret = 0;
 
 	mutex_lock(&s->ops_mutex);
-	c = p_dev->function_config;
 
-	if (!(s->state & SOCKET_PRESENT)) {
-		dev_dbg(&s->dev, "No card present\n");
-		ret = -ENODEV;
-		goto unlock;
-	}
-	if (!(c->state & CONFIG_LOCKED)) {
-		dev_dbg(&s->dev, "Configuration isnt't locked\n");
+	dev_dbg(&p_dev->dev, "fixup iowidth to 8bit\n");
+
+	if (!(s->state & SOCKET_PRESENT) ||
+		!(p_dev->function_config->state & CONFIG_LOCKED)) {
+		dev_dbg(&s->dev, "No card? Config not locked?\n");
 		ret = -EACCES;
 		goto unlock;
 	}
 
-	if (mod->Attributes & (CONF_IRQ_CHANGE_VALID | CONF_VCC_CHANGE_VALID)) {
-		dev_dbg(&s->dev,
-			"changing Vcc or IRQ is not allowed at this time\n");
-		ret = -EINVAL;
-		goto unlock;
-	}
+	io_on.speed = io_speed;
+	for (i = 0; i < MAX_IO_WIN; i++) {
+		if (!s->io[i].res)
+			continue;
+		io_off.map = i;
+		io_on.map = i;
 
-	/* We only allow changing Vpp1 and Vpp2 to the same value */
-	if ((mod->Attributes & CONF_VPP1_CHANGE_VALID) &&
-	    (mod->Attributes & CONF_VPP2_CHANGE_VALID)) {
-		if (mod->Vpp1 != mod->Vpp2) {
-			dev_dbg(&s->dev, "Vpp1 and Vpp2 must be the same\n");
-			ret = -EINVAL;
-			goto unlock;
-		}
-		s->socket.Vpp = mod->Vpp1;
-		if (s->ops->set_socket(s, &s->socket)) {
-			dev_printk(KERN_WARNING, &s->dev,
-				   "Unable to set VPP\n");
-			ret = -EIO;
-			goto unlock;
-		}
-	} else if ((mod->Attributes & CONF_VPP1_CHANGE_VALID) ||
-		   (mod->Attributes & CONF_VPP2_CHANGE_VALID)) {
-		dev_dbg(&s->dev, "changing Vcc is not allowed at this time\n");
-		ret = -EINVAL;
-		goto unlock;
+		io_on.flags = MAP_ACTIVE | IO_DATA_PATH_WIDTH_8;
+		io_on.start = s->io[i].res->start;
+		io_on.stop = s->io[i].res->end;
+
+		s->ops->set_io_map(s, &io_off);
+		mdelay(40);
+		s->ops->set_io_map(s, &io_on);
 	}
+unlock:
+	mutex_unlock(&s->ops_mutex);
 
-	if (mod->Attributes & CONF_IO_CHANGE_WIDTH) {
-		pccard_io_map io_off = { 0, 0, 0, 0, 1 };
-		pccard_io_map io_on;
-		int i;
+	return ret;
+}
+EXPORT_SYMBOL(pcmcia_fixup_iowidth);
 
-		io_on.speed = io_speed;
-		for (i = 0; i < MAX_IO_WIN; i++) {
-			if (!s->io[i].res)
-				continue;
-			io_off.map = i;
-			io_on.map = i;
 
-			io_on.flags = MAP_ACTIVE | IO_DATA_PATH_WIDTH_8;
-			io_on.start = s->io[i].res->start;
-			io_on.stop = s->io[i].res->end;
+/**
+ * pcmcia_fixup_vpp() - set Vpp to a new voltage level
+ *
+ * pcmcia_fixup_vpp() allows a PCMCIA device driver to set Vpp to
+ * a new voltage level between calls to pcmcia_request_configuration()
+ * and pcmcia_disable_device().
+ */
+int pcmcia_fixup_vpp(struct pcmcia_device *p_dev, unsigned char new_vpp)
+{
+	struct pcmcia_socket *s = p_dev->socket;
+	int ret = 0;
 
-			s->ops->set_io_map(s, &io_off);
-			mdelay(40);
-			s->ops->set_io_map(s, &io_on);
-		}
+	mutex_lock(&s->ops_mutex);
+
+	dev_dbg(&p_dev->dev, "fixup Vpp to %d\n", new_vpp);
+
+	if (!(s->state & SOCKET_PRESENT) ||
+		!(p_dev->function_config->state & CONFIG_LOCKED)) {
+		dev_dbg(&s->dev, "No card? Config not locked?\n");
+		ret = -EACCES;
+		goto unlock;
 	}
-	ret = 0;
+
+	s->socket.Vpp = new_vpp;
+	if (s->ops->set_socket(s, &s->socket)) {
+		dev_printk(KERN_WARNING, &s->dev, "Unable to set VPP\n");
+		ret = -EIO;
+		goto unlock;
+	}
+
 unlock:
 	mutex_unlock(&s->ops_mutex);
 
 	return ret;
-} /* modify_configuration */
-EXPORT_SYMBOL(pcmcia_modify_configuration);
+}
+EXPORT_SYMBOL(pcmcia_fixup_vpp);
 
 
 int pcmcia_release_configuration(struct pcmcia_device *p_dev)
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 63cb9bb..e13d0cd 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -19,19 +19,6 @@
 #include <linux/interrupt.h>
 #endif
 
-/* ModifyConfiguration */
-typedef struct modconf_t {
-    u_int	Attributes;
-    u_int	Vcc, Vpp1, Vpp2;
-} modconf_t;
-
-/* Attributes for ModifyConfiguration */
-#define CONF_IRQ_CHANGE_VALID	0x0100
-#define CONF_VCC_CHANGE_VALID	0x0200
-#define CONF_VPP1_CHANGE_VALID	0x0400
-#define CONF_VPP2_CHANGE_VALID	0x0800
-#define CONF_IO_CHANGE_WIDTH	0x1000
-
 /* For RequestConfiguration */
 typedef struct config_req_t {
     u_int	Attributes;
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 6f7cb38..8e307b9 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -212,7 +212,9 @@ int pcmcia_release_window(struct pcmcia_device *p_dev, struct resource *res);
 int pcmcia_map_mem_page(struct pcmcia_device *p_dev, struct resource *res,
 			unsigned int offset);
 
-int pcmcia_modify_configuration(struct pcmcia_device *p_dev, modconf_t *mod);
+int pcmcia_fixup_vpp(struct pcmcia_device *p_dev, unsigned char new_vpp);
+int pcmcia_fixup_iowidth(struct pcmcia_device *p_dev);
+
 void pcmcia_disable_device(struct pcmcia_device *p_dev);
 
 /* IO ports */
-- 
1.7.0.4

