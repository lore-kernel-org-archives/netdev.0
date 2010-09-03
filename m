From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 03/15] pcmcia: move Vpp setup to struct pcmcia_device
Date: Fri,  3 Sep 2010 12:57:02 +0200
Message-ID: <1283511434-21620-3-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-mtd@lists.infradead.org,
	linux-wireless@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:44126 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757889Ab0ICK6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 06:58:15 -0400
In-Reply-To: <20100903105628.GA21255@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers prefer to explicitly set Vpp. Instead of passing the
voltage inside config_req_t, store it in struct pcmcia_device.

CC: linux-ide@vger.kernel.org
CC: netdev@vger.kernel.org
CC: linux-bluetooth@vger.kernel.org
CC: linux-mtd@lists.infradead.org
CC: linux-wireless@vger.kernel.org
CC: linux-serial@vger.kernel.org
CC: linux-usb@vger.kernel.org
CC: linux-scsi@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/ata/pata_pcmcia.c                  |    4 ++--
 drivers/bluetooth/bt3c_cs.c                |    2 +-
 drivers/bluetooth/btuart_cs.c              |    2 +-
 drivers/ide/ide-cs.c                       |    6 +++---
 drivers/isdn/hisax/sedlbauer_cs.c          |    8 ++++----
 drivers/mtd/maps/pcmciamtd.c               |    4 ++--
 drivers/net/wireless/airo_cs.c             |    8 ++++----
 drivers/net/wireless/atmel_cs.c            |    4 ++--
 drivers/net/wireless/hostap/hostap_cs.c    |   10 +++++-----
 drivers/net/wireless/orinoco/orinoco_cs.c  |    4 ++--
 drivers/net/wireless/orinoco/spectrum_cs.c |    4 ++--
 drivers/pcmcia/pcmcia_resource.c           |    3 ++-
 drivers/scsi/pcmcia/nsp_cs.c               |    8 ++++----
 drivers/serial/serial_cs.c                 |    2 +-
 drivers/usb/host/sl811_cs.c                |    8 ++++----
 include/pcmcia/cs.h                        |    1 -
 include/pcmcia/ds.h                        |    1 +
 17 files changed, 40 insertions(+), 39 deletions(-)

diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index e944aa0..12cdc9f 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -194,9 +194,9 @@ static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 	}
 
 	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		pdev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		pdev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		pdev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		pdev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 7ab8f29..2c8d981 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -686,7 +686,7 @@ static int bt3c_check_config(struct pcmcia_device *p_dev,
 	p_dev->io_lines = (try == 0) ? 16 : cf->io.flags & CISTPL_IO_LINES_MASK;
 
 	if (cf->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		p_dev->vpp = cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	if ((cf->io.nwin > 0) && (cf->io.win[0].len == 8) &&
 	    (cf->io.win[0].base != 0)) {
 		p_dev->resource[0]->start = cf->io.win[0].base;
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 1c4f5e8..7ea6fa4 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -615,7 +615,7 @@ static int btuart_check_config(struct pcmcia_device *p_dev,
 	p_dev->io_lines = (try == 0) ? 16 : cf->io.flags & CISTPL_IO_LINES_MASK;
 
 	if (cf->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		p_dev->vpp = cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	if ((cf->io.nwin > 0) && (cf->io.win[0].len == 8) &&
 	    (cf->io.win[0].base != 0)) {
 		p_dev->resource[0]->start = cf->io.win[0].base;
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 2a4cb9c..82690e4 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -221,9 +221,9 @@ static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 	}
 
 	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		pdev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		pdev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		pdev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		pdev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
@@ -311,7 +311,7 @@ static int ide_config(struct pcmcia_device *link)
     info->host = host;
     dev_info(&link->dev, "ide-cs: hd%c: Vpp = %d.%d\n",
 	    'a' + host->ports[0]->index * 2,
-	    link->conf.Vpp / 10, link->conf.Vpp % 10);
+	    link->vpp / 10, link->vpp % 10);
 
     kfree(stk);
     return 0;
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index a024192..ad07d61 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -191,9 +191,9 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 	}
 
 	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
+		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
+		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
@@ -257,8 +257,8 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
     /* Finally, report what we've done */
     dev_info(&link->dev, "index 0x%02x:",
 	   link->conf.ConfigIndex);
-    if (link->conf.Vpp)
-	printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
+    if (link->vpp)
+	printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	printk(", irq %d", link->irq);
     if (link->resource[0])
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index 31ce404..ab94c8a 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -570,9 +570,9 @@ static int pcmciamtd_config(struct pcmcia_device *link)
 	dev->vpp = (vpp) ? vpp : link->socket->socket.Vpp;
 	link->conf.Attributes = 0;
 	if(setvpp == 2) {
-		link->conf.Vpp = dev->vpp;
+		link->vpp = dev->vpp;
 	} else {
-		link->conf.Vpp = 0;
+		link->vpp = 0;
 	}
 
 	link->conf.IntType = INT_MEMORY;
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 9a121a5..488e7b4 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -166,9 +166,9 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
 	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
+		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
+		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
@@ -244,8 +244,8 @@ static int airo_config(struct pcmcia_device *link)
 	/* Finally, report what we've done */
 	dev_info(&link->dev, "index 0x%02x: ",
 	       link->conf.ConfigIndex);
-	if (link->conf.Vpp)
-		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
+	if (link->vpp)
+		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
 	printk(", irq %d", link->irq);
 	if (link->resource[0])
 		printk(" & %pR", link->resource[0]);
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 3b63216..479f508 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -183,9 +183,9 @@ static int atmel_config_check(struct pcmcia_device *p_dev,
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
 	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
+		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
+		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
 
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index ba54d1b..3f35dd4 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -508,9 +508,9 @@ static int prism2_config_check(struct pcmcia_device *p_dev,
 	}
 
 	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	/* Do we need to allocate an interrupt? */
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
@@ -605,9 +605,9 @@ static int prism2_config(struct pcmcia_device *link)
 	/* Finally, report what we've done */
 	printk(KERN_INFO "%s: index 0x%02x: ",
 	       dev_info, link->conf.ConfigIndex);
-	if (link->conf.Vpp)
-		printk(", Vpp %d.%d", link->conf.Vpp / 10,
-		       link->conf.Vpp % 10);
+	if (link->vpp)
+		printk(", Vpp %d.%d", link->vpp / 10,
+		       link->vpp % 10);
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		printk(", irq %d", link->irq);
 	if (link->resource[0])
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index ef46a2d..f7e3fa6 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -181,10 +181,10 @@ static int orinoco_cs_config_check(struct pcmcia_device *p_dev,
 	}
 
 	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp =
+		p_dev->vpp =
 			cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp =
+		p_dev->vpp =
 			dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	/* Do we need to allocate an interrupt? */
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 873877e..1bbad10 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -243,10 +243,10 @@ static int spectrum_cs_config_check(struct pcmcia_device *p_dev,
 	}
 
 	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp =
+		p_dev->vpp =
 			cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp =
+		p_dev->vpp =
 			dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	/* Do we need to allocate an interrupt? */
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 45c1ac4..fb28178 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -303,6 +303,7 @@ int pcmcia_fixup_vpp(struct pcmcia_device *p_dev, unsigned char new_vpp)
 		ret = -EIO;
 		goto unlock;
 	}
+	p_dev->vpp = new_vpp;
 
 unlock:
 	mutex_unlock(&s->ops_mutex);
@@ -458,7 +459,7 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	}
 
 	/* Do power control.  We don't allow changes in Vcc. */
-	s->socket.Vpp = req->Vpp;
+	s->socket.Vpp = p_dev->vpp;
 	if (s->ops->set_socket(s, &s->socket)) {
 		mutex_unlock(&s->ops_mutex);
 		dev_printk(KERN_WARNING, &s->dev,
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index c65ed6e..e475ec5 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1624,10 +1624,10 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 		}
 
 		if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM)) {
-			p_dev->conf.Vpp =
+			p_dev->vpp =
 				cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 		} else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM)) {
-			p_dev->conf.Vpp =
+			p_dev->vpp =
 				dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 		}
 
@@ -1749,8 +1749,8 @@ static int nsp_cs_config(struct pcmcia_device *link)
 	/* Finally, report what we've done */
 	printk(KERN_INFO "nsp_cs: index 0x%02x: ",
 	       link->conf.ConfigIndex);
-	if (link->conf.Vpp) {
-		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
+	if (link->vpp) {
+		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
 	}
 	if (link->conf.Attributes & CONF_ENABLE_IRQ) {
 		printk(", irq %d", link->irq);
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index dd0fa12..b851c1f 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -419,7 +419,7 @@ static int simple_config_check(struct pcmcia_device *p_dev,
 	int *try = priv_data;
 
 	if (cf->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp =
+		p_dev->vpp =
 			cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 
 	p_dev->io_lines = ((*try & 0x1) == 0) ?
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 0e13a00..8e84752 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -152,10 +152,10 @@ static int sl811_cs_config_check(struct pcmcia_device *p_dev,
 		}
 
 	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp =
+		p_dev->vpp =
 			cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
 	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->conf.Vpp =
+		p_dev->vpp =
 			dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
 
 	/* we need an interrupt */
@@ -201,8 +201,8 @@ static int sl811_cs_config(struct pcmcia_device *link)
 
 	dev_info(&link->dev, "index 0x%02x: ",
 		link->conf.ConfigIndex);
-	if (link->conf.Vpp)
-		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
+	if (link->vpp)
+		printk(", Vpp %d.%d", link->vpp/10, link->vpp%10);
 	printk(", irq %d", link->irq);
 	printk(", io %pR", link->resource[0]);
 	printk("\n");
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index e13d0cd..ccb8e6e 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -22,7 +22,6 @@
 /* For RequestConfiguration */
 typedef struct config_req_t {
     u_int	Attributes;
-    u_int	Vpp; /* both Vpp1 and Vpp2 */
     u_int	IntType;
     u_int	ConfigBase;
     u_char	Status, Pin, Copy, ExtStatus;
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 8e307b9..6137fbc 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -94,6 +94,7 @@ struct pcmcia_device {
 	/* device setup */
 	unsigned int		irq;
 	struct resource		*resource[PCMCIA_NUM_RESOURCES];
+	unsigned int		vpp;
 
 	unsigned int		io_lines; /* number of I/O lines */
 
-- 
1.7.0.4

