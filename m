From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC ] [4 of 4] IEEE802.11 Regulatory/Geographical Support for drivers
 - Patches for bcm43xx to use new ieee80211 routine
Date: Sat, 03 Jun 2006 17:46:14 -0500
Message-ID: <44821136.8000003@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:22664 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751822AbWFCWqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 18:46:15 -0400
To: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message shows the patch needed to convert the bcm43xx driver to use the new ieee80211_init_geo 
routine. Note: I know my mailer has butchered the white space by changing all the tabs into spaces. 
The original source is OK.  Larry
===================================================================================================

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c \
  b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 7ed18ca..eb88a4e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -87,9 +87,15 @@ static int modparam_long_retry = BCM43xx
  module_param_named(long_retry, modparam_long_retry, int, 0444);
  MODULE_PARM_DESC(long_retry, "Long-Retry-Limit (0 - 15)");

-static int modparam_locale = -1;
-module_param_named(locale, modparam_locale, int, 0444);
-MODULE_PARM_DESC(country, "Select LocaleCode 0-11 (For travelers)");
+static char modparam_locale[] = "  ";
+static char country[3];
+
+module_param_string(country, modparam_locale, 3, 0444);
+MODULE_PARM_DESC(country, "Two character ISO Country Name (For Travelers)");
+
+static int modparam_outdoor;
+module_param_named(outdoor, modparam_outdoor, int, 0444);
+MODULE_PARM_DESC(outdoor, "Set to 1 if interface to be used outdoors");

  static int modparam_noleds;
  module_param_named(noleds, modparam_noleds, int, 0444);
@@ -621,38 +627,6 @@ static const char * bcm43xx_locale_iso(u
         return "  ";
  }

-static const char * bcm43xx_locale_string(u8 locale)
-{
-       switch (locale) {
-       case BCM43xx_LOCALE_WORLD:
-               return "World";
-       case BCM43xx_LOCALE_THAILAND:
-               return "Thailand";
-       case BCM43xx_LOCALE_ISRAEL:
-               return "Israel";
-       case BCM43xx_LOCALE_JORDAN:
-               return "Jordan";
-       case BCM43xx_LOCALE_CHINA:
-               return "China";
-       case BCM43xx_LOCALE_JAPAN:
-               return "Japan";
-       case BCM43xx_LOCALE_USA_CANADA_ANZ:
-               return "USA/Canada/ANZ";
-       case BCM43xx_LOCALE_EUROPE:
-               return "Europe";
-       case BCM43xx_LOCALE_USA_LOW:
-               return "USAlow";
-       case BCM43xx_LOCALE_JAPAN_HIGH:
-               return "JapanHigh";
-       case BCM43xx_LOCALE_ALL:
-               return "All";
-       case BCM43xx_LOCALE_NONE:
-               return "None";
-       }
-       assert(0);
-       return "";
-}
-
  static inline u8 bcm43xx_crc8(u8 crc, u8 data)
  {
         static const u8 t[] = {
@@ -860,17 +834,12 @@ #endif
         bcm->sprom.locale = (value & 0x0F00) >> 8;
         bcm->sprom.antennas_aphy = (value & 0x3000) >> 12;
         bcm->sprom.antennas_bgphy = (value & 0xC000) >> 14;
-       if (modparam_locale != -1) {
-               if (modparam_locale >= 0 && modparam_locale <= 11) {
-                       bcm->sprom.locale = modparam_locale;
-                       printk(KERN_WARNING PFX "Operating with modified "
-                                               "LocaleCode %u (%s)\n",
-                              bcm->sprom.locale,
-                              bcm43xx_locale_string(bcm->sprom.locale));
-               } else {
-                       printk(KERN_WARNING PFX "Module parameter \"locale\" "
-                                               "invalid value. (0 - 11)\n");
-               }
+       if (strcmp(modparam_locale, "  ")) {
+               printk(KERN_WARNING PFX "Operating with modified Country "
+                                       "Code %s\n", modparam_locale);
+               strcpy(country, modparam_locale);
+       } else {
+               strcpy(country, bcm43xx_locale_iso(bcm->sprom.locale));
         }

         /* pa0b* */
@@ -939,69 +908,6 @@ #endif
         return 0;
  }

-static int bcm43xx_geo_init(struct bcm43xx_private *bcm)
-{
-       struct ieee80211_geo *geo;
-       struct ieee80211_channel *chan;
-       int have_a = 0, have_bg = 0;
-       int i;
-       u8 channel;
-       struct bcm43xx_phyinfo *phy;
-       const char *iso_country;
-
-       geo = kzalloc(sizeof(*geo), GFP_KERNEL);
-       if (!geo)
-               return -ENOMEM;
-
-       for (i = 0; i < bcm->nr_80211_available; i++) {
-               phy = &(bcm->core_80211_ext[i].phy);
-               switch (phy->type) {
-               case BCM43xx_PHYTYPE_B:
-               case BCM43xx_PHYTYPE_G:
-                       have_bg = 1;
-                       break;
-               case BCM43xx_PHYTYPE_A:
-                       have_a = 1;
-                       break;
-               default:
-                       assert(0);
-               }
-       }
-       iso_country = bcm43xx_locale_iso(bcm->sprom.locale);
-
-       if (have_a) {
-               for (i = 0, channel = IEEE80211_52GHZ_MIN_CHANNEL;
-                     channel <= IEEE80211_52GHZ_MAX_CHANNEL; channel++) {
-                       chan = &geo->a[i++];
-                       chan->freq = bcm43xx_channel_to_freq_a(channel);
-                       chan->channel = channel;
-               }
-               geo->a_channels = i;
-       }
-       if (have_bg) {
-               for (i = 0, channel = IEEE80211_24GHZ_MIN_CHANNEL;
-                     channel <= IEEE80211_24GHZ_MAX_CHANNEL; channel++) {
-                       chan = &geo->bg[i++];
-                       chan->freq = bcm43xx_channel_to_freq_bg(channel);
-                       chan->channel = channel;
-               }
-               geo->bg_channels = i;
-       }
-       memcpy(geo->name, iso_country, 2);
-       if (0 /*TODO: Outdoor use only */)
-               geo->name[2] = 'O';
-       else if (0 /*TODO: Indoor use only */)
-               geo->name[2] = 'I';
-       else
-               geo->name[2] = ' ';
-       geo->name[3] = '\0';
-
-       ieee80211_set_geo(bcm->ieee, geo);
-       kfree(geo);
-
-       return 0;
-}
-
  /* DummyTransmission function, as documented on
   * http://bcm-specs.sipsolutions.net/DummyTransmission
   */
@@ -3486,13 +3392,15 @@ static int bcm43xx_attach_board(struct b

                 bcm43xx_radio_turn_off(bcm);
                 err = bcm43xx_phy_init_tssi2dbm_table(bcm);
+               bcm43xx_wireless_core_disable(bcm);
                 if (err)
                         goto err_80211_unwind;
-               bcm43xx_wireless_core_disable(bcm);
         }
-       err = bcm43xx_geo_init(bcm);
+       printk(KERN_INFO PFX "Country Code = %s, Outdoor code = %d\n", country, modparam_outdoor);
+       err = ieee80211_init_geo(bcm->ieee, country, modparam_outdoor);
         if (err)
                 goto err_80211_unwind;
+
         bcm43xx_pctl_set_crystal(bcm, 0);

         /* Set the MAC address in the networking subsystem */
