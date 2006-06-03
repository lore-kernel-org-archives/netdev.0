From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC ] [3 of 4] IEEE802.11 Regulatory/Geographical Support for drivers
 - Patches for ieee80211
Date: Sat, 03 Jun 2006 17:45:54 -0500
Message-ID: <44821122.5080909@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:60551 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751820AbWFCWpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 18:45:55 -0400
To: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains the patch to add routine ieee80211_init_geo to the kernel, and a new flag 
definition for the IEEE80211 codes. Note: I know that my mailer has messed up the white space by 
converting all the tabs to spaces. The original files are OK. Larry

=====================================================================================
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index d5926bf..8a5dc0f 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -965,6 +965,7 @@ #define IEEE80211_52GHZ_CHANNELS (IEEE80

  enum {
         IEEE80211_CH_PASSIVE_ONLY = (1 << 0),
+       IEEE80211_CH_80211H_RULES = (1 << 1),
         IEEE80211_CH_B_ONLY = (1 << 2),
         IEEE80211_CH_NO_IBSS = (1 << 3),
         IEEE80211_CH_UNIFORM_SPREADING = (1 << 4),
@@ -973,10 +974,10 @@ enum {
  };

  struct ieee80211_channel {
-       u32 freq;
+       u32 freq;       /* in MHz */
         u8 channel;
         u8 flags;
-       u8 max_power;
+       u8 max_power;   /* in dBm */
  };

  struct ieee80211_geo {
@@ -1260,6 +1261,9 @@ extern const struct ieee80211_geo *ieee8
  extern int ieee80211_set_geo(struct ieee80211_device *ieee,
                              const struct ieee80211_geo *geo);

+extern int ieee80211_init_geo(struct ieee80211_device *ieee,
+                             char * country, u8 outdoor);
+
  extern int ieee80211_is_valid_channel(struct ieee80211_device *ieee,
                                       u8 channel);
  extern int ieee80211_channel_to_index(struct ieee80211_device *ieee,
diff --git a/net/ieee80211/ieee80211_geo.c b/net/ieee80211/ieee80211_geo.c
index 192243a..2e4806b 100644
--- a/net/ieee80211/ieee80211_geo.c
+++ b/net/ieee80211/ieee80211_geo.c
@@ -41,6 +41,7 @@ #include <linux/types.h>
  #include <linux/wireless.h>
  #include <linux/etherdevice.h>
  #include <asm/uaccess.h>
+#include <linux/delay.h>

  #include <net/ieee80211.h>

@@ -133,6 +134,136 @@ int ieee80211_set_geo(struct ieee80211_d
         return 0;
  }

+static char ieee80211_country[10];
+static uint ieee80211_outdoor;
+static struct proc_dir_entry *ieee80211_geo_proc;
+static uint ieee80211_data_back;
+struct ieee80211_geo *geo;
+static uint bytes_xfer;
+
+static int show_geo_country(char *page, char **start, off_t offset,
+                           int count, int *eof, void *data)
+{
+       return snprintf(page, count, "%s %d\n", ieee80211_country, ieee80211_outdoor);
+}
+
+static int store_geo_data(struct file *file, const char __user * buffer,
+                             unsigned long count, void *data)
+{
+       unsigned long len = min((unsigned long)sizeof(struct ieee80211_geo) , count);
+       int i;
+
+       if (copy_from_user((geo + bytes_xfer), buffer, len)) {
+               IEEE80211_ERROR( "Error return from copy_from_user.\n");
+               return -EFAULT;
+       }
+       bytes_xfer += len;
+       if (bytes_xfer == sizeof(struct ieee80211_geo)) {
+               IEEE80211_DEBUG_INFO( "All data has been received.\n");
+               if (!geo->bg_channels && !geo->a_channels) {  /* if no channels specified - error */
+                       IEEE80211_DEBUG_INFO( "No bg or a/h channels specified.\n");
+                       return count;
+               }
+               if (geo->bg_channels > IEEE80211_24GHZ_CHANNELS) { /* too many bg channels */
+                       IEEE80211_DEBUG_INFO( "Too many bg channels specified.\n");
+                       return count;
+               }
+               if (geo->a_channels > IEEE80211_52GHZ_CHANNELS) { /* too many a channels */
+                       IEEE80211_DEBUG_INFO( "Too many a/h channels specified.\n");
+                       return count;
+               }
+               for (i=0; i<geo->a_channels; i++) {
+                       if (geo->a[i].channel < IEEE80211_52GHZ_MIN_CHANNEL ||
+                           geo->a[i].channel > IEEE80211_52GHZ_MAX_CHANNEL)
+                               return count;    /* here if channel out of range */
+               }
+               for (i=0; i<geo->bg_channels; i++) {
+                       if (geo->bg[i].channel < IEEE80211_24GHZ_MIN_CHANNEL ||
+                           geo->bg[i].channel > IEEE80211_24GHZ_MAX_CHANNEL)
+                               return count;    /* here if channel out of range */
+               }
+               IEEE80211_DEBUG_INFO( "Data passed sanity checks.\n"); /* data seems to be correct */
+               ieee80211_data_back = 0;
+       }
+       return count;
+}
+
+int ieee80211_init_geo(struct ieee80211_device *ieee,
+                       char *country, u8 outdoor)
+{
+       int ret;
+       struct proc_dir_entry *e1, *e2;
+
+       static const struct ieee80211_geo ieee80211_geos[] = {
+        {  /* Default parameters to be returned if daemon not running or other error */
+        "---",
+        .a_channels = 0,
+        .bg_channels = 11,
+        .bg = {{.freq = 2412, .channel = 1, .max_power = 20},
+               {.freq = 2417, .channel = 2, .max_power = 20},
+               {.freq = 2422, .channel = 3, .max_power = 20},
+               {.freq = 2427, .channel = 4, .max_power = 20},
+               {.freq = 2432, .channel = 5, .max_power = 20},
+               {.freq = 2437, .channel = 6, .max_power = 20},
+               {.freq = 2442, .channel = 7, .max_power = 20},
+               {.freq = 2447, .channel = 8, .max_power = 20},
+               {.freq = 2452, .channel = 9, .max_power = 20},
+               {.freq = 2457, .channel = 10, .max_power = 20},
+               {.freq = 2462, .channel = 11, .max_power = 20}
+               },
+        },
+       };
+
+       IEEE80211_DEBUG_INFO( "Country Code: %s, Outdoor: %d\n", country, outdoor);
+       memcpy(ieee80211_country, country, strlen(country));
+       ieee80211_outdoor = outdoor;
+       ieee80211_geo_proc = proc_mkdir("ieee80211_geo", proc_net);
+       (void)ieee80211_set_geo( ieee, ieee80211_geos); /* load default data in case of error */
+       if (ieee80211_geo_proc == NULL) {
+               IEEE80211_ERROR( "Unable to create ieee80211_geo"
+                       " proc directory - default geo data loaded\n");
+               return -EIO;
+       }
+       geo = kzalloc(sizeof(struct ieee80211_geo), GFP_KERNEL);
+       if (!geo) {
+               ret = -ENOMEM;
+               goto cleanup;
+       }
+       e1 = create_proc_entry("geo_country", S_IFREG | S_IRUSR | S_IWUSR,
+                             ieee80211_geo_proc);
+       e1->read_proc = show_geo_country;
+       e2 = create_proc_entry("geo_data", S_IWUSR | S_IWGRP | S_IWOTH,
+                             ieee80211_geo_proc);
+       ieee80211_data_back = 1;
+       bytes_xfer = 0;
+       e2->write_proc = store_geo_data;
+
+       if (!e1 || !e2 ) {
+               IEEE80211_ERROR( "Unable to create files in ieee80211_geo"
+                       " - default data loaded.\n");
+               ret = -EIO;
+               goto free_geo;
+       }
+       for (ret=0; ret<1000; ret++) {
+               if (!ieee80211_data_back)
+                       break;
+               udelay(1000);
+       }
+       if (ret == 1000) {
+               ret = -EIO;
+               IEEE80211_DEBUG_INFO( "ieee80211_geo daemon not running - default data loaded.\n");
+               goto free_geo;  /* daemon not running */
+       }
+       ret = ieee80211_set_geo( ieee, geo);
+free_geo:
+       kfree(geo);
+cleanup:
+       remove_proc_entry("geo_country", ieee80211_geo_proc);
+       remove_proc_entry("geo_data", ieee80211_geo_proc);
+       remove_proc_entry("ieee80211_geo", proc_net);
+       return ret;
+}
+
  const struct ieee80211_geo *ieee80211_get_geo(struct ieee80211_device *ieee)
  {
         return &ieee->geo;
@@ -177,4 +308,5 @@ EXPORT_SYMBOL(ieee80211_is_valid_channel
  EXPORT_SYMBOL(ieee80211_freq_to_channel);
  EXPORT_SYMBOL(ieee80211_channel_to_index);
  EXPORT_SYMBOL(ieee80211_set_geo);
+EXPORT_SYMBOL(ieee80211_init_geo);
  EXPORT_SYMBOL(ieee80211_get_geo);
