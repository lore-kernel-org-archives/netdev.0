From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v3] b43: N-PHY: fix gain in
 b43_nphy_get_gain_ctl_workaround_ent()
Date: Sun, 20 Jan 2013 19:31:30 +0300
Message-ID: <20130120163130.GA7730@elgon.mountain>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7118@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>,
	kernel-janitors@vger.kernel.org
To: Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45837 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290Ab3ATQcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 11:32:08 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7118@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were no break statements in this switch statement so everything
used the default settings.  Per Walter Harms's suggestion, I've replaced
the switch statement and done a little cleanup.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: Make additional style fixes as well while we're messing with the
    function.
v3: Make the array static const int.

diff --git a/drivers/net/wireless/b43/tables_nphy.c b/drivers/net/wireless/b43/tables_nphy.c
index 97d4e27..aaca60c 100644
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
+		static const int gain_data[] = {0x0062, 0x0064, 0x006a, 0x106a,
+						0x106c, 0x1074, 0x107c, 0x207c};
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
