From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch v2] b43: N-PHY: fix gain in
 b43_nphy_get_gain_ctl_workaround_ent()
Date: Fri, 18 Jan 2013 16:36:58 +0300
Message-ID: <20130118133658.GA31186@elgon.mountain>
References: <50F84AF3.5070901@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50F84AF3.5070901-fPG8STNUNVg@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

There were no break statements in this switch statement so everything
used the default settings.  Per Walter Harms's suggestion, I've replaced
the switch statement and done a little cleanup.

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
v2: Additional cleanups.

diff --git a/drivers/net/wireless/b43/tables_nphy.c b/drivers/net/wireless/b43/tables_nphy.c
index 97d4e27..99567db 100644
--- a/drivers/net/wireless/b43/tables_nphy.c
+++ b/drivers/net/wireless/b43/tables_nphy.c
@@ -3226,8 +3226,6 @@ struct nphy_gain_ctl_workaround_entry *b43_nphy_get_gain_ctl_workaround_ent(
 {
 	struct nphy_gain_ctl_workaround_entry *e;
 	u8 phy_idx;
-	u8 tr_iso = ghz5 ? dev->dev->bus_sprom->fem.ghz5.tr_iso :
-			   dev->dev->bus_sprom->fem.ghz2.tr_iso;
 
 	if (!ghz5 && dev->phy.rev >= 6 && dev->phy.radio_rev == 11)
 		return &nphy_gain_ctl_wa_phy6_radio11_ghz2;
@@ -3249,6 +3247,10 @@ struct nphy_gain_ctl_workaround_entry *b43_nphy_get_gain_ctl_workaround_ent(
 		    !b43_channel_type_is_40mhz(dev->phy.channel_type))
 			e->cliplo_gain = 0x2d;
 	} else if (!ghz5 && dev->phy.rev >= 5) {
+		int gain_data[] = {0x0062, 0x0064, 0x006a, 0x106a, 0x106c,
+				   0x1074, 0x107c, 0x207c};
+		u8 tr_iso = dev->dev->bus_sprom->fem.ghz2.tr_iso;
+
 		if (ext_lna) {
 			e->rfseq_init[0] &= ~0x4000;
 			e->rfseq_init[1] &= ~0x4000;
@@ -3256,26 +3258,10 @@ struct nphy_gain_ctl_workaround_entry *b43_nphy_get_gain_ctl_workaround_ent(
 			e->rfseq_init[3] &= ~0x4000;
 			e->init_gain &= ~0x4000;
 		}
-		switch (tr_iso) {
-		case 0:
-			e->cliplo_gain = 0x0062;
-		case 1:
-			e->cliplo_gain = 0x0064;
-		case 2:
-			e->cliplo_gain = 0x006a;
-		case 3:
-			e->cliplo_gain = 0x106a;
-		case 4:
-			e->cliplo_gain = 0x106c;
-		case 5:
-			e->cliplo_gain = 0x1074;
-		case 6:
-			e->cliplo_gain = 0x107c;
-		case 7:
-			e->cliplo_gain = 0x207c;
-		default:
-			e->cliplo_gain = 0x106a;
-		}
+		if (tr_iso > 7)
+			tr_iso = 3;
+		e->cliplo_gain = gain_data[tr_iso];
+
 	} else if (ghz5 && dev->phy.rev == 4 && ext_lna) {
 		e->rfseq_init[0] &= ~0x4000;
 		e->rfseq_init[1] &= ~0x4000;
