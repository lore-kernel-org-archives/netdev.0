From: Kyle McMartin <kyle-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [HOSTAP] Make debug a run-time option
Date: Wed, 14 Mar 2007 12:03:56 -0400
Message-ID: <20070314160356.GA16337@athena.road.mcmartin.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hostap-I1pBevtZXGcAvxtiuMwx3w@public.gmane.org, j@w1.fi
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Build-time debugging isn't overly useful for distro kernel folks, nor is
enabling huge amounts of debug spew by default. Provide the option of
enabling debugging with module parameters.

Signed-off-by: Kyle McMartin <kyle-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
diff --git a/drivers/net/wireless/hostap/hostap_info.c b/drivers/net/wireless/hostap/hostap_info.c
index b6a02a0..6eb8d88 100644
--- a/drivers/net/wireless/hostap/hostap_info.c
+++ b/drivers/net/wireless/hostap/hostap_info.c
@@ -96,7 +96,6 @@ static void prism2_info_commtallies(local_info_t *local, unsigned char *buf,
 
 
 #ifndef PRISM2_NO_STATION_MODES
-#ifndef PRISM2_NO_DEBUG
 static const char* hfa384x_linkstatus_str(u16 linkstatus)
 {
 	switch (linkstatus) {
@@ -116,7 +115,6 @@ static const char* hfa384x_linkstatus_str(u16 linkstatus)
 		return "Unknown";
 	}
 }
-#endif /* PRISM2_NO_DEBUG */
 
 
 /* Called only as a tasklet (software IRQ) */
@@ -362,9 +360,7 @@ void hostap_info_process(local_info_t *local, struct sk_buff *skb)
 	struct hfa384x_info_frame *info;
 	unsigned char *buf;
 	int left;
-#ifndef PRISM2_NO_DEBUG
 	int i;
-#endif /* PRISM2_NO_DEBUG */
 
 	info = (struct hfa384x_info_frame *) skb->data;
 	buf = skb->data + sizeof(*info);
@@ -389,16 +385,16 @@ void hostap_info_process(local_info_t *local, struct sk_buff *skb)
 		break;
 #endif /* PRISM2_NO_STATION_MODES */
 
-#ifndef PRISM2_NO_DEBUG
 	default:
-		PDEBUG(DEBUG_EXTRA, "%s: INFO - len=%d type=0x%04x\n",
-		       local->dev->name, info->len, info->type);
-		PDEBUG(DEBUG_EXTRA, "Unknown info frame:");
-		for (i = 0; i < (left < 100 ? left : 100); i++)
-			PDEBUG2(DEBUG_EXTRA, " %02x", buf[i]);
-		PDEBUG2(DEBUG_EXTRA, "\n");
+		if (hostap_debug) {
+			PDEBUG(DEBUG_EXTRA, "%s: INFO - len=%d type=0x%04x\n",
+			       local->dev->name, info->len, info->type);
+			PDEBUG(DEBUG_EXTRA, "Unknown info frame:");
+			for (i = 0; i < (left < 100 ? left : 100); i++)
+				PDEBUG2(DEBUG_EXTRA, " %02x", buf[i]);
+			PDEBUG2(DEBUG_EXTRA, "\n");
+		}
 		break;
-#endif /* PRISM2_NO_DEBUG */
 	}
 }
 
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 9077e6e..2015ab3 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -46,6 +46,14 @@ MODULE_VERSION(PRISM2_VERSION);
 /* FIX: */
 #define PRISM2_MAX_MTU (PRISM2_MAX_FRAME_SIZE - (6 /* LLC */ + 8 /* WEP */))
 
+unsigned int hostap_debug = 0;
+module_param(hostap_debug, uint, 0644);
+MODULE_PARM_DESC(hostap_debug, "Enable verbose debugging output");
+EXPORT_SYMBOL(hostap_debug);
+
+unsigned int hostap_debug_mask = DEBUG_MASK;
+module_param(hostap_debug_mask, uint, 0644);
+EXPORT_SYMBOL(hostap_debug_mask);
 
 struct net_device * hostap_add_interface(struct local_info *local,
 					 int type, int rtnl_locked,
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index 87a54aa..e318f26 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -923,8 +923,6 @@ struct hostap_skb_tx_data {
 };
 
 
-#ifndef PRISM2_NO_DEBUG
-
 #define DEBUG_FID BIT(0)
 #define DEBUG_PS BIT(1)
 #define DEBUG_FLOW BIT(2)
@@ -935,16 +933,12 @@ struct hostap_skb_tx_data {
 #define DEBUG_PS2 BIT(7)
 #define DEBUG_MASK (DEBUG_PS | DEBUG_AP | DEBUG_HW | DEBUG_EXTRA)
 #define PDEBUG(n, args...) \
-do { if ((n) & DEBUG_MASK) printk(KERN_DEBUG args); } while (0)
+do { if (hostap_debug && ((n) & hostap_debug_mask)) printk(KERN_DEBUG args); } while (0)
 #define PDEBUG2(n, args...) \
-do { if ((n) & DEBUG_MASK) printk(args); } while (0)
-
-#else /* PRISM2_NO_DEBUG */
-
-#define PDEBUG(n, args...)
-#define PDEBUG2(n, args...)
+do { if (hostap_debug && ((n) & hostap_debug_mask)) printk(args); } while (0)
 
-#endif /* PRISM2_NO_DEBUG */
+extern unsigned int hostap_debug;
+extern unsigned int hostap_debug_mask;
 
 enum { BAP0 = 0, BAP1 = 1 };
 
