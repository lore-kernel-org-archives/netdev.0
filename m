From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] Change PHY initialization to match updated clean-room specs
Date: Sun, 10 Sep 2006 21:20:34 -0500
Message-ID: <4504C7F2.5040400@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Broadcom Linux <bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

John,

Please apply this patch to wireless-2.6. It arises due to an updating
of the PHY initialization routines.

Michael - the same changes will be needed for bcm43xx-d80211.

Thanks,

Larry

===================================================

This patch updates the PHY initialization code for bcm43xx-softmac to
conform with recent changes in the clean-room specs at
http://bcm-specs.sipsolutions.net. Mostly, these changes implement the sequence
needed for chips with GPHY revision 8; however, the patch also corrects
a typo in one address, and some parts that were missing from the spec when
the initial coding was done.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -361,7 +361,7 @@ static void bcm43xx_phy_setupg(struct bc
  	if (phy->rev <= 2)
  		for (i = 0; i < BCM43xx_ILT_NOISESCALEG_SIZE; i++)
  			bcm43xx_ilt_write(bcm, 0x1400 + i, bcm43xx_ilt_noisescaleg1[i]);
-	else if ((phy->rev == 7) && (bcm43xx_phy_read(bcm, 0x0449) & 0x0200))
+	else if ((phy->rev >= 7) && (bcm43xx_phy_read(bcm, 0x0449) & 0x0200))
  		for (i = 0; i < BCM43xx_ILT_NOISESCALEG_SIZE; i++)
  			bcm43xx_ilt_write(bcm, 0x1400 + i, bcm43xx_ilt_noisescaleg3[i]);
  	else
@@ -371,7 +371,7 @@ static void bcm43xx_phy_setupg(struct bc
  	if (phy->rev == 2)
  		for (i = 0; i < BCM43xx_ILT_SIGMASQR_SIZE; i++)
  			bcm43xx_ilt_write(bcm, 0x5000 + i, bcm43xx_ilt_sigmasqr1[i]);
-	else if ((phy->rev > 2) && (phy->rev <= 7))
+	else if ((phy->rev > 2) && (phy->rev <= 8))
  		for (i = 0; i < BCM43xx_ILT_SIGMASQR_SIZE; i++)
  			bcm43xx_ilt_write(bcm, 0x5000 + i, bcm43xx_ilt_sigmasqr2[i]);
  	
@@ -1197,7 +1197,7 @@ static void bcm43xx_phy_initg(struct bcm

  	if (phy->rev == 1)
  		bcm43xx_phy_initb5(bcm);
-	else if (phy->rev >= 2 && phy->rev <= 7)
+	else
  		bcm43xx_phy_initb6(bcm);
  	if (phy->rev >= 2 || phy->connected)
  		bcm43xx_phy_inita(bcm);
@@ -1241,23 +1241,22 @@ static void bcm43xx_phy_initg(struct bcm
  		bcm43xx_phy_lo_g_measure(bcm);
  	} else {
  		if (radio->version == 0x2050 && radio->revision == 8) {
-			//FIXME
+			bcm43xx_radio_write16(bcm, 0x0052,
+					      (radio->txctl1 << 4) | radio->txctl2);
  		} else {
  			bcm43xx_radio_write16(bcm, 0x0052,
  					      (bcm43xx_radio_read16(bcm, 0x0052)
  					       & 0xFFF0) | radio->txctl1);
  		}
  		if (phy->rev >= 6) {
-			/*
  			bcm43xx_phy_write(bcm, 0x0036,
  					  (bcm43xx_phy_read(bcm, 0x0036)
-					   & 0xF000) | (FIXME << 12));
-			*/
+					   & 0xF000) | (radio->txctl2 << 12));
  		}
  		if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL)
  			bcm43xx_phy_write(bcm, 0x002E, 0x8075);
  		else
-			bcm43xx_phy_write(bcm, 0x003E, 0x807F);
+			bcm43xx_phy_write(bcm, 0x002E, 0x807F);
  		if (phy->rev < 2)
  			bcm43xx_phy_write(bcm, 0x002F, 0x0101);
  		else




==============================================
