From: akpm@osdl.org
Subject: [patch 5/9] WAN/pc300: handle, propagate minor errors
Date: Fri, 20 Oct 2006 14:43:15 -0700
Message-ID: <200610202143.k9KLhFNL003798@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jeff@garzik.org,
	khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4997 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992762AbWJTVoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:44:19 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>

- move definition of 'tmc' and 'br' locals closer to usage

- handle clock_rate_calc() error

- propagate errors back to upper level open routine

Signed-off-by: Jeff Garzik <jeff@garzik.org>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/wan/pc300_drv.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff -puN drivers/net/wan/pc300_drv.c~wan-pc300-handle-propagate-minor-errors drivers/net/wan/pc300_drv.c
--- a/drivers/net/wan/pc300_drv.c~wan-pc300-handle-propagate-minor-errors
+++ a/drivers/net/wan/pc300_drv.c
@@ -2867,7 +2867,6 @@ static int ch_config(pc300dev_t * d)
 	uclong clktype = chan->conf.phys_settings.clock_type;
 	ucshort encoding = chan->conf.proto_settings.encoding;
 	ucshort parity = chan->conf.proto_settings.parity;   
-	int tmc, br;
 	ucchar md0, md2;
     
 	/* Reset the channel */
@@ -2940,8 +2939,12 @@ static int ch_config(pc300dev_t * d)
 		case PC300_RSV:
 		case PC300_X21:
 			if (clktype == CLOCK_INT || clktype == CLOCK_TXINT) {
+				int tmc, br;
+
 				/* Calculate the clkrate parameters */
 				tmc = clock_rate_calc(clkrate, card->hw.clock, &br);
+				if (tmc < 0)
+					return -EIO;
 				cpc_writeb(scabase + M_REG(TMCT, ch), tmc);
 				cpc_writeb(scabase + M_REG(TXS, ch),
 					   (TXS_DTRXC | TXS_IBRG | br));
@@ -3097,14 +3100,16 @@ static int cpc_attach(struct net_device 
 	return 0;
 }
 
-static void cpc_opench(pc300dev_t * d)
+static int cpc_opench(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	int ch = chan->channel;
+	int ch = chan->channel, rc;
 	void __iomem *scabase = card->hw.scabase;
 
-	ch_config(d);
+	rc = ch_config(d);
+	if (rc)
+		return rc;
 
 	rx_config(d);
 
@@ -3113,6 +3118,8 @@ static void cpc_opench(pc300dev_t * d)
 	/* Assert RTS and DTR */
 	cpc_writeb(scabase + M_REG(CTL, ch),
 		   cpc_readb(scabase + M_REG(CTL, ch)) & ~(CTL_RTS | CTL_DTR));
+
+	return 0;
 }
 
 static void cpc_closech(pc300dev_t * d)
@@ -3168,9 +3175,16 @@ int cpc_open(struct net_device *dev)
 	}
 
 	sprintf(ifr.ifr_name, "%s", dev->name);
-	cpc_opench(d);
+	result = cpc_opench(d);
+	if (result)
+		goto err_out;
+
 	netif_start_queue(dev);
 	return 0;
+
+err_out:
+	hdlc_close(dev);
+	return result;
 }
 
 static int cpc_close(struct net_device *dev)
_
