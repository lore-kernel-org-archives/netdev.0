From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 3/3] pcmcia pcnet_cs: try setting io_lines to 16 if card setup fails
Date: Wed, 15 Sep 2010 18:25:57 +0200
Message-ID: <1284567957-15709-3-git-send-email-linux@dominikbrodowski.net>
References: <20100915162503.GA15043@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:36624 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752681Ab0IOQaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 12:30:07 -0400
In-Reply-To: <20100915162503.GA15043@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some pcnet_cs compatible cards require an exact 16-lines match
of the ioport areas specified in CIS, but set the "iolines"
value in the CIS incorrectly. We can easily work around this
issue -- same as we do in serial_cs -- by first trying setting
iolines to the CIS-specified value, and then trying a 16-line
match.

Reported-and-tested-by: Wolfram Sang <w.sang@pengutronix.de>
Hardware-supplied-by: Jochen Frieling <j.frieling@pengutronix.de>
CC: netdev@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/pcnet_cs.c |  139 ++++++++++++++++++++++++----------------
 1 files changed, 83 insertions(+), 56 deletions(-)

diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 49279b0..f9b509a 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -508,7 +508,8 @@ static int pcnet_confcheck(struct pcmcia_device *p_dev,
 			   unsigned int vcc,
 			   void *priv_data)
 {
-	int *has_shmem = priv_data;
+	int *priv = priv_data;
+	int try = (*priv & 0x1);
 	int i;
 	cistpl_io_t *io = &cfg->io;
 
@@ -525,77 +526,103 @@ static int pcnet_confcheck(struct pcmcia_device *p_dev,
 		i = p_dev->resource[1]->end = 0;
 	}
 
-	*has_shmem = ((cfg->mem.nwin == 1) &&
-		      (cfg->mem.win[0].len >= 0x4000));
+	*priv &= ((cfg->mem.nwin == 1) &&
+		  (cfg->mem.win[0].len >= 0x4000)) ? 0x10 : ~0x10;
+
 	p_dev->resource[0]->start = io->win[i].base;
 	p_dev->resource[0]->end = io->win[i].len;
-	p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+	if (!try)
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+	else
+		p_dev->io_lines = 16;
 	if (p_dev->resource[0]->end + p_dev->resource[1]->end >= 32)
 		return try_io_port(p_dev);
 
-	return 0;
+	return -EINVAL;
+}
+
+static hw_info_t *pcnet_try_config(struct pcmcia_device *link,
+				   int *has_shmem, int try)
+{
+	struct net_device *dev = link->priv;
+	hw_info_t *local_hw_info;
+	pcnet_dev_t *info = PRIV(dev);
+	int priv = try;
+	int ret;
+
+	ret = pcmcia_loop_config(link, pcnet_confcheck, &priv);
+	if (ret) {
+		dev_warn(&link->dev, "no useable port range found\n");
+		return NULL;
+	}
+	*has_shmem = (priv & 0x10);
+
+	if (!link->irq)
+		return NULL;
+
+	if (resource_size(link->resource[1]) == 8) {
+		link->conf.Attributes |= CONF_ENABLE_SPKR;
+		link->conf.Status = CCSR_AUDIO_ENA;
+	}
+	if ((link->manf_id == MANFID_IBM) &&
+	    (link->card_id == PRODID_IBM_HOME_AND_AWAY))
+		link->conf.ConfigIndex |= 0x10;
+
+	ret = pcmcia_request_configuration(link, &link->conf);
+	if (ret)
+		return NULL;
+
+	dev->irq = link->irq;
+	dev->base_addr = link->resource[0]->start;
+
+	if (info->flags & HAS_MISC_REG) {
+		if ((if_port == 1) || (if_port == 2))
+			dev->if_port = if_port;
+		else
+			dev_notice(&link->dev, "invalid if_port requested\n");
+	} else
+		dev->if_port = 0;
+
+	if ((link->conf.ConfigBase == 0x03c0) &&
+	    (link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
+		dev_info(&link->dev,
+			"this is an AX88190 card - use axnet_cs instead.\n");
+		return NULL;
+	}
+
+	local_hw_info = get_hwinfo(link);
+	if (!local_hw_info)
+		local_hw_info = get_prom(link);
+	if (!local_hw_info)
+		local_hw_info = get_dl10019(link);
+	if (!local_hw_info)
+		local_hw_info = get_ax88190(link);
+	if (!local_hw_info)
+		local_hw_info = get_hwired(link);
+
+	return local_hw_info;
 }
 
 static int pcnet_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     pcnet_dev_t *info = PRIV(dev);
-    int ret, start_pg, stop_pg, cm_offset;
+    int start_pg, stop_pg, cm_offset;
     int has_shmem = 0;
     hw_info_t *local_hw_info;
 
     dev_dbg(&link->dev, "pcnet_config\n");
 
-    ret = pcmcia_loop_config(link, pcnet_confcheck, &has_shmem);
-    if (ret)
-	goto failed;
-
-    if (!link->irq)
-	    goto failed;
-
-    if (resource_size(link->resource[1]) == 8) {
-	link->conf.Attributes |= CONF_ENABLE_SPKR;
-	link->conf.Status = CCSR_AUDIO_ENA;
-    }
-    if ((link->manf_id == MANFID_IBM) &&
-	(link->card_id == PRODID_IBM_HOME_AND_AWAY))
-	link->conf.ConfigIndex |= 0x10;
-
-    ret = pcmcia_request_configuration(link, &link->conf);
-    if (ret)
-	    goto failed;
-    dev->irq = link->irq;
-    dev->base_addr = link->resource[0]->start;
-    if (info->flags & HAS_MISC_REG) {
-	if ((if_port == 1) || (if_port == 2))
-	    dev->if_port = if_port;
-	else
-	    printk(KERN_NOTICE "pcnet_cs: invalid if_port requested\n");
-    } else {
-	dev->if_port = 0;
-    }
-
-    if ((link->conf.ConfigBase == 0x03c0) &&
-	(link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
-	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
-	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
-	goto failed;
-    }
-
-    local_hw_info = get_hwinfo(link);
-    if (local_hw_info == NULL)
-	local_hw_info = get_prom(link);
-    if (local_hw_info == NULL)
-	local_hw_info = get_dl10019(link);
-    if (local_hw_info == NULL)
-	local_hw_info = get_ax88190(link);
-    if (local_hw_info == NULL)
-	local_hw_info = get_hwired(link);
-
-    if (local_hw_info == NULL) {
-	printk(KERN_NOTICE "pcnet_cs: unable to read hardware net"
-	       " address for io base %#3lx\n", dev->base_addr);
-	goto failed;
+    local_hw_info = pcnet_try_config(link, &has_shmem, 0);
+    if (!local_hw_info) {
+	    /* check whether forcing io_lines to 16 helps... */
+	    pcmcia_disable_device(link);
+	    local_hw_info = pcnet_try_config(link, &has_shmem, 1);
+	    if (local_hw_info == NULL) {
+		    dev_notice(&link->dev, "unable to read hardware net"
+			    " address for io base %#3lx\n", dev->base_addr);
+		    goto failed;
+	    }
     }
 
     info->flags = local_hw_info->flags;
-- 
1.7.0.4

