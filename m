From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/8) pc300 hdlc_device conversion
Date: Tue, 2 Dec 2003 14:02:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202140226.266abaac.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halas <khc@pm.waw.pl>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1496  -> 1.1497 
#	drivers/net/wan/pc300.h	1.3     -> 1.4    
#	drivers/net/wan/pc300_drv.c	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/26	shemminger@osdl.org	1.1497
# Convert for hdlc_device without embedded net_device.
# This device was overriding dev->priv to be the pc300 device, this
# breaks the hdlc_device interface's assumptions. 
# Make hdlc_device private pointer be pc300 device and adjust to fix. 
# --------------------------------------------
#
diff -Nru a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
--- a/drivers/net/wan/pc300.h	Wed Nov 26 12:35:58 2003
+++ b/drivers/net/wan/pc300.h	Wed Nov 26 12:35:58 2003
@@ -391,7 +391,7 @@
 typedef struct pc300ch {
 	struct pc300 *card;
 	int channel;
-	pc300dev_t d;
+	pc300dev_t *d;
 	pc300chconf_t conf;
 	ucchar tx_first_bd;	/* First TX DMA block descr. w/ data */
 	ucchar tx_next_bd;	/* Next free TX DMA block descriptor */
diff -Nru a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
--- a/drivers/net/wan/pc300_drv.c	Wed Nov 26 12:35:58 2003
+++ b/drivers/net/wan/pc300_drv.c	Wed Nov 26 12:35:58 2003
@@ -615,7 +615,7 @@
 	while (cpc_readb(falcbase + F_REG(SIS, ch)) & SIS_CEC) {
 		if (i++ >= PC300_FALC_MAXLOOP) {
 			printk("%s: FALC command locked(cmd=0x%x).\n",
-			       card->chan[ch].d.name, cmd);
+			       card->chan[ch].d->name, cmd);
 			break;
 		}
 	}
@@ -1361,7 +1361,7 @@
 	    pfalc->loss_mfa || pfalc->blue_alarm) {
 		if (pfalc->sync) {
 			pfalc->sync = 0;
-			chan->d.line_off++;
+			chan->d->line_off++;
 			cpc_writeb(falcbase + card->hw.cpld_reg2,
 				   cpc_readb(falcbase + card->hw.cpld_reg2) &
 				   ~(CPLD_REG2_FALC_LED2 << (2 * ch)));
@@ -1369,7 +1369,7 @@
 	} else {
 		if (!pfalc->sync) {
 			pfalc->sync = 1;
-			chan->d.line_on++;
+			chan->d->line_on++;
 			cpc_writeb(falcbase + card->hw.cpld_reg2,
 				   cpc_readb(falcbase + card->hw.cpld_reg2) |
 				   (CPLD_REG2_FALC_LED2 << (2 * ch)));
@@ -1771,7 +1771,8 @@
 
 void cpc_tx_timeout(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	hdlc_device *hdlc = dev->priv;
+	pc300dev_t *d = hdlc->dev_data;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	struct net_device_stats *stats = &d->hdlc->stats;
@@ -1799,7 +1800,8 @@
 
 int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	hdlc_device *hdlc = dev->priv;
+	pc300dev_t *d = hdlc->dev_data;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	struct net_device_stats *stats = &d->hdlc->stats;
@@ -1883,7 +1885,7 @@
 void cpc_net_rx(hdlc_device * hdlc)
 {
 	struct net_device *dev = hdlc_to_dev(hdlc);
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = hdlc->dev_data;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	struct net_device_stats *stats = &d->hdlc->stats;
@@ -2016,7 +2018,7 @@
 	while ((status = cpc_readl(scabase + ISR0)) != 0) {
 		for (ch = 0; ch < card->hw.nchan; ch++) {
 			pc300ch_t *chan = &card->chan[ch];
-			pc300dev_t *d = &chan->d;
+			pc300dev_t *d = chan->d;
 			hdlc_device *hdlc = d->hdlc;
 			struct net_device *dev = hdlc_to_dev(hdlc);
 
@@ -2162,7 +2164,7 @@
 						netif_carrier_off(dev);
 
 #endif
-						card->chan[ch].d.line_off++;
+						card->chan[ch].d->line_off++;
 					} else {	/* DCD = 1 */
 						printk ("%s: DCD is ON. Going administrative up.\n",
 							 dev->name);
@@ -2171,7 +2173,7 @@
 							/* verify if driver is not TTY */
 #endif
 							netif_carrier_on(dev);
-						card->chan[ch].d.line_on++;
+						card->chan[ch].d->line_on++;
 					}
 				}
 			}
@@ -2536,7 +2538,7 @@
 int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = hdlc->dev_data;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	pc300conf_t conf_aux;
@@ -2616,8 +2618,8 @@
 
 					memset(&pc300stats, 0, sizeof(pc300stats_t));
 					pc300stats.hw_type = card->hw.type;
-					pc300stats.line_on = card->chan[ch].d.line_on;
-					pc300stats.line_off = card->chan[ch].d.line_off;
+					pc300stats.line_on = card->chan[ch].d->line_on;
+					pc300stats.line_off = card->chan[ch].d->line_off;
 					memcpy(&pc300stats.gen_stats, &hdlc->stats,
 					       sizeof(struct net_device_stats));
 					if (card->hw.type == PC300_TE)
@@ -2818,7 +2820,8 @@
 
 static struct net_device_stats *cpc_get_stats(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	hdlc_device *hdlc = dev->priv;
+	pc300dev_t *d = hdlc->dev_data;
 
 	if (d)
 		return &d->hdlc->stats;
@@ -3067,8 +3070,7 @@
 static int cpc_attach(hdlc_device * hdlc, unsigned short encoding,
 		      unsigned short parity)
 {
-	struct net_device * dev = hdlc_to_dev(hdlc);
-	pc300dev_t *d = (pc300dev_t *)dev->priv;
+	pc300dev_t *d = hdlc->dev_data;
 	pc300ch_t *chan = (pc300ch_t *)d->chan;
 	pc300_t *card = (pc300_t *)chan->card;
 	pc300chconf_t *conf = (pc300chconf_t *)&chan->conf;
@@ -3145,7 +3147,7 @@
 int cpc_open(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = hdlc->dev_data;
 	struct ifreq ifr;
 	int result;
 
@@ -3158,9 +3160,6 @@
 	}
 
 	result = hdlc_open(hdlc);
-	if (hdlc->proto.id == IF_PROTO_PPP) {
-		dev->priv = d;
-	}
 	if (result) {
 		return result;
 	}
@@ -3174,7 +3173,7 @@
 int cpc_close(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300dev_t *d = hdlc->dev_data;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	uclong flags;
@@ -3316,10 +3315,17 @@
 
 	for (i = 0; i < card->hw.nchan; i++) {
 		pc300ch_t *chan = &card->chan[i];
-		pc300dev_t *d = &chan->d;
+		pc300dev_t *d;
 		hdlc_device *hdlc;
 		struct net_device *dev;
 
+		hdlc = alloc_hdlc_device(sizeof(*d));
+		if (hdlc == NULL)
+			continue;
+		d = hdlc->dev_data;
+		d->hdlc = hdlc;
+		dev = hdlc_to_dev(hdlc);
+
 		chan->card = card;
 		chan->channel = i;
 		chan->conf.phys_settings.clock_rate = 0;
@@ -3358,12 +3364,6 @@
 		d->line_on = 0;
 		d->line_off = 0;
 
-		d->hdlc = (hdlc_device *) kmalloc(sizeof(hdlc_device), GFP_KERNEL);
-		if (d->hdlc == NULL)
-			continue;
-		memset(d->hdlc, 0, sizeof(hdlc_device));
-
-		hdlc = d->hdlc;
 		hdlc->xmit = cpc_queue_xmit;
 		hdlc->attach = cpc_attach;
 
@@ -3387,7 +3387,6 @@
 		dev->do_ioctl = cpc_ioctl;
 
 		if (register_hdlc_device(hdlc) == 0) {
-			dev->priv = d;	/* We need 'priv', hdlc doesn't */
 			printk("%s: Cyclades-PC300/", dev->name);
 			switch (card->hw.type) {
 				case PC300_TE:
@@ -3647,7 +3646,9 @@
 			   cpc_readw(card->hw.plxbase + card->hw.intctl_reg) & ~(0x0040));
 
 		for (i = 0; i < card->hw.nchan; i++) {
-			unregister_hdlc_device(card->chan[i].d.hdlc);
+			hdlc_device *hdlc = card->chan[i].d->hdlc;
+			unregister_hdlc_device(hdlc);
+			free_hdlc_device(hdlc);
 		}
 		iounmap((void *) card->hw.plxbase);
 		iounmap((void *) card->hw.scabase);
