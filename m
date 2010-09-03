From: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Subject: [PATCH 05/15] pcmcia: simplify Status, ExtStatus register access
Date: Fri,  3 Sep 2010 12:57:04 +0200
Message-ID: <1283511434-21620-5-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100903105628.GA21255-S7uyTPAaJ/sb6pqDj42GsMgv3T4z79SOrE5yTffgRl4@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Status (CISREG_CCSR) and ExtStatus (CISREG_ESR) registers were
only accessed to enable audio output for some drivers and IRQ for
serial_cs.c. The former also required setting config_req_t.Attributes
to CONF_ENABLE_SPKR; the latter can be simplified to setting this
field to CONF_ENABLE_ESR.

CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
---
 drivers/isdn/hisax/sedlbauer_cs.c             |    4 +--
 drivers/net/pcmcia/axnet_cs.c                 |    4 +--
 drivers/net/pcmcia/pcnet_cs.c                 |    5 +--
 drivers/net/pcmcia/smc91c92_cs.c              |    2 -
 drivers/net/pcmcia/xirc2ps_cs.c               |    5 +--
 drivers/net/wireless/airo_cs.c                |    4 +--
 drivers/net/wireless/atmel_cs.c               |    4 +--
 drivers/net/wireless/hostap/hostap_cs.c       |    4 +--
 drivers/pcmcia/cs_internal.h                  |    2 +-
 drivers/pcmcia/pcmcia_resource.c              |   28 +++++++++++++++++--------
 drivers/scsi/pcmcia/nsp_cs.c                  |    4 +--
 drivers/serial/serial_cs.c                    |   11 +++------
 drivers/staging/comedi/drivers/ni_daq_700.c   |    4 +--
 drivers/staging/comedi/drivers/ni_daq_dio24.c |    4 +--
 drivers/staging/comedi/drivers/ni_labpc_cs.c  |    4 +--
 include/pcmcia/cs.h                           |    2 +-
 16 files changed, 38 insertions(+), 53 deletions(-)

diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index ad07d61..40001ad 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -175,10 +175,8 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
 		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
-		p_dev->conf.Status = CCSR_AUDIO_ENA;
-	}
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 5f05ffb..8734ed8 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -334,10 +334,8 @@ static int axnet_config(struct pcmcia_device *link)
     if (!link->irq)
 	    goto failed;
     
-    if (resource_size(link->resource[1]) == 8) {
+    if (resource_size(link->resource[1]) == 8)
 	link->conf.Attributes |= CONF_ENABLE_SPKR;
-	link->conf.Status = CCSR_AUDIO_ENA;
-    }
     
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 15e80ea..1dd0dfa 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -553,10 +553,9 @@ static int pcnet_config(struct pcmcia_device *link)
     if (!link->irq)
 	    goto failed;
 
-    if (resource_size(link->resource[1]) == 8) {
+    if (resource_size(link->resource[1]) == 8)
 	link->conf.Attributes |= CONF_ENABLE_SPKR;
-	link->conf.Status = CCSR_AUDIO_ENA;
-    }
+
     if ((link->manf_id == MANFID_IBM) &&
 	(link->card_id == PRODID_IBM_HOME_AND_AWAY))
 	link->conf.ConfigIndex |= 0x10;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 395e586..2031a27 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -446,7 +446,6 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     int i;
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
-    link->conf.Status = CCSR_AUDIO_ENA;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[1]->end = 8;
 
@@ -640,7 +639,6 @@ static int osi_config(struct pcmcia_device *link)
     int i, j;
 
     link->conf.Attributes |= CONF_ENABLE_SPKR;
-    link->conf.Status = CCSR_AUDIO_ENA;
     link->resource[0]->end = 64;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->resource[1]->end = 8;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 4308bda..59398a6 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -812,10 +812,9 @@ xirc2ps_config(struct pcmcia_device * link)
     if (local->modem) {
 	int pass;
 
-	if (do_sound) {
+	if (do_sound)
 	    link->conf.Attributes |= CONF_ENABLE_SPKR;
-	    link->conf.Status |= CCSR_AUDIO_ENA;
-	}
+
 	link->resource[1]->end = 8;
 	link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	if (local->dingo) {
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 488e7b4..ab60f10 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -158,10 +158,8 @@ static int airo_cs_config_check(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
 		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
-		p_dev->conf.Status = CCSR_AUDIO_ENA;
-	}
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 479f508..d6d585c 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -175,10 +175,8 @@ static int atmel_config_check(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
 		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
-		p_dev->conf.Status = CCSR_AUDIO_ENA;
-	}
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 3f35dd4..3fa285b 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -484,10 +484,8 @@ static int prism2_config_check(struct pcmcia_device *p_dev,
 	       "(default 0x%02X)\n", cfg->index, dflt->index);
 
 	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
 		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
-		p_dev->conf.Status = CCSR_AUDIO_ENA;
-	}
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
diff --git a/drivers/pcmcia/cs_internal.h b/drivers/pcmcia/cs_internal.h
index 9487340..7ef464d 100644
--- a/drivers/pcmcia/cs_internal.h
+++ b/drivers/pcmcia/cs_internal.h
@@ -36,7 +36,7 @@ typedef struct config_t {
 	unsigned int	Attributes;
 	unsigned int	IntType;
 	unsigned int	ConfigBase;
-	unsigned char	Status, Option, ExtStatus;
+	unsigned char	Option;
 	unsigned int	CardValues;
 
 	struct resource io[MAX_IO_WIN]; /* io ports */
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index e431567..e119663 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -441,6 +441,8 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 	struct pcmcia_socket *s = p_dev->socket;
 	config_t *c;
 	pccard_io_map iomap;
+	unsigned char status = 0;
+	unsigned char ext_status = 0;
 
 	if (!(s->state & SOCKET_PRESENT))
 		return -ENODEV;
@@ -476,12 +478,21 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 		s->socket.flags |= SS_ZVCARD | SS_IOCARD;
 	if (req->Attributes & CONF_ENABLE_DMA)
 		s->socket.flags |= SS_DMA_MODE;
-	if (req->Attributes & CONF_ENABLE_SPKR)
+	if (req->Attributes & CONF_ENABLE_SPKR) {
 		s->socket.flags |= SS_SPKR_ENA;
+		status = CCSR_AUDIO_ENA;
+		if (!(req->Present & PRESENT_STATUS))
+			dev_warn(&p_dev->dev, "speaker requested, but "
+					      "PRESENT_STATUS not set!\n");
+	}
 	if (req->Attributes & CONF_ENABLE_IRQ)
 		s->socket.io_irq = s->pcmcia_irq;
 	else
 		s->socket.io_irq = 0;
+	if (req->Attributes & CONF_ENABLE_ESR) {
+		req->Present |= PRESENT_EXT_STATUS;
+		ext_status = ESR_REQ_ATTN_ENA;
+	}
 	s->ops->set_socket(s, &s->socket);
 	s->lock_count++;
 
@@ -513,14 +524,13 @@ int pcmcia_request_configuration(struct pcmcia_device *p_dev,
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_COR)>>1, 1, &c->Option);
 		mdelay(40);
 	}
-	if (req->Present & PRESENT_STATUS) {
-		c->Status = req->Status;
-		pcmcia_write_cis_mem(s, 1, (base + CISREG_CCSR)>>1, 1, &c->Status);
-	}
-	if (req->Present & PRESENT_EXT_STATUS) {
-		c->ExtStatus = req->ExtStatus;
-		pcmcia_write_cis_mem(s, 1, (base + CISREG_ESR)>>1, 1, &c->ExtStatus);
-	}
+	if (req->Present & PRESENT_STATUS)
+		pcmcia_write_cis_mem(s, 1, (base + CISREG_CCSR)>>1, 1, &status);
+
+	if (req->Present & PRESENT_EXT_STATUS)
+		pcmcia_write_cis_mem(s, 1, (base + CISREG_ESR)>>1, 1,
+					&ext_status);
+
 	if (req->Present & PRESENT_IOBASE_0) {
 		u8 b = c->io[0].start & 0xff;
 		pcmcia_write_cis_mem(s, 1, (base + CISREG_IOBASE_0)>>1, 1, &b);
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index e475ec5..e14fcd1 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1608,10 +1608,8 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
 		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
-		p_dev->conf.Status = CCSR_AUDIO_ENA;
-	}
 
 	/* Use power settings for Vcc and Vpp if present */
 	/*  Note that the CIS values need to be rescaled */
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index b851c1f..8035f1e 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -183,10 +183,8 @@ static void quirk_config_socket(struct pcmcia_device *link)
 {
 	struct serial_info *info = link->priv;
 
-	if (info->multi) {
-		link->conf.Present |= PRESENT_EXT_STATUS;
-		link->conf.ExtStatus = ESR_REQ_ATTN_ENA;
-	}
+	if (info->multi)
+		link->conf.Attributes |= CONF_ENABLE_ESR;
 }
 
 static const struct serial_quirk quirks[] = {
@@ -336,10 +334,9 @@ static int serial_probe(struct pcmcia_device *link)
 	link->priv = info;
 
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	if (do_sound) {
+	if (do_sound)
 		link->conf.Attributes |= CONF_ENABLE_SPKR;
-		link->conf.Status = CCSR_AUDIO_ENA;
-	}
+
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	return serial_config(link);
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index cc15666..8cf56cb 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -550,10 +550,8 @@ static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
 		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
-		p_dev->conf.Status = CCSR_AUDIO_ENA;
-	}
 
 	/* Do we need to allocate an interrupt? */
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 773ae20..ba69343 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -302,10 +302,8 @@ static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
 		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
-		p_dev->conf.Status = CCSR_AUDIO_ENA;
-	}
 
 	/* Do we need to allocate an interrupt? */
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 68c4ecb..5d5f11f 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -281,10 +281,8 @@ static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 		return -ENODEV;
 
 	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
 		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
-		p_dev->conf.Status = CCSR_AUDIO_ENA;
-	}
 
 	/* Do we need to allocate an interrupt? */
 	p_dev->conf.Attributes |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index e656abe..29d693f 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -24,7 +24,6 @@ typedef struct config_req_t {
     u_int	Attributes;
     u_int	IntType;
     u_int	ConfigBase;
-    u_char	Status, ExtStatus;
     u_char	ConfigIndex;
     u_int	Present;
 } config_req_t;
@@ -34,6 +33,7 @@ typedef struct config_req_t {
 #define CONF_ENABLE_DMA		0x02
 #define CONF_ENABLE_SPKR	0x04
 #define CONF_ENABLE_PULSE_IRQ	0x08
+#define CONF_ENABLE_ESR		0x10
 #define CONF_VALID_CLIENT	0x100
 
 /* IntType field */
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
