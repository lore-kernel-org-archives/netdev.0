From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Allow channels 1-11 for unrecognised regulatory domains
Date: Sun,  1 Jul 2007 18:21:49 +0100 (BST)
Message-ID: <20070701172149.C23DD7B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Zen Kato's device has a regulatory domain value of 0x49, which is not an
IEEE 802.11 code and is not even identified in the vendor driver.

Recent versions of the vendor driver don't even look at the regdomain
value any more, and just allow channels 1-11 everywhere. This patch
brings us more in line with that behaviour, by allowing channels 1-11
for regdomains which we don't know about.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_mac.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -113,11 +113,14 @@ int zd_mac_init_hw(struct zd_mac *mac, u
 	if (r)
 		goto disable_int;
 	if (!zd_regdomain_supported(default_regdomain)) {
-		dev_dbg_f(zd_mac_dev(mac),
-			  "Regulatory Domain %#04x is not supported.\n",
-		          default_regdomain);
-		r = -EINVAL;
-		goto disable_int;
+		/* The vendor driver overrides the regulatory domain and
+		 * allowed channel registers and unconditionally restricts
+		 * available channels to 1-11 everywhere. Match their
+		 * questionable behaviour only for regdomains which we don't
+		 * recognise. */
+		dev_warn(zd_mac_dev(mac),  "Unrecognised regulatory domain: "
+			"%#04x. Defaulting to FCC.\n", default_regdomain);
+		default_regdomain = ZD_REGDOMAIN_FCC;
 	}
 	spin_lock_irq(&mac->lock);
 	mac->regdomain = mac->default_regdomain = default_regdomain;
