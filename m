From: "John W. Linville" <linville@tuxdriver.com>
Subject: [RFC] Alternate WE-21 support (core API)
Date: Wed, 6 Sep 2006 16:55:44 -0400
Message-ID: <20060906205538.GA29767@tuxdriver.com>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157031138.16040.17.camel@ux156> <20060831135112.GA6097@jm.kir.nu> <1157032805.16040.21.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, jt@hpl.hp.com,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:56590 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751491AbWIFVNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 17:13:21 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1157032805.16040.21.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2006 at 04:00:05PM +0200, Johannes Berg wrote:
> On Thu, 2006-08-31 at 06:51 -0700, Jouni Malinen wrote:
> 
> > I don't know about the others, but long/short retry limits have users
> > (e.g., Host AP driver) and these drivers are currently forced to use a
> > hack to do this without this cleanup. Furthermore, this part does not
> > add a new ioctl.
> 
> It does, however, add new parameters and things that'd need to be
> translated in the compat layer later. Hence, even there, I'd prefer to
> add them directly into nl80211. However, the compat code for that
> shouldn't be that bad, so I can see that as a softer target :) But I
> don't want to see new ioctls for sure.

OK, I think we all agree that there are good parts to Jean's WE-21
patch.  Below I've made an attempt to separate the wheat from the chaff
(or to cut the baby in half)...

Is this patch acceptable to the group?  Does it make things better?
Or worse?  Did I leave-out anything that should still go in?  Did I
take too much?

Let me know what you think...?

John

---

This is version 21 of the Wireless Extensions. Changelog :
	o finishes migrating the ESSID API (remove the +1)
	o netdev->get_wireless_stats is no more
	o long/short retry

This is a redacted version of a patch originally submitted by Jean
Tourrilhes.  I removed most of the additions, in order to minimize
future support requirements for nl80211 (or other WE successor).

CC: Jean Tourrilhes <jt@hpl.hp.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 include/linux/netdevice.h |    1 -
 include/linux/wireless.h  |   23 +++++++++++++--
 net/core/net-sysfs.c      |    5 +--
 net/core/wireless.c       |   67 ++++++++++++++++++++++++++++-----------------
 4 files changed, 61 insertions(+), 35 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 50a4719..91dc36c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -334,7 +334,6 @@ #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSU
 
 
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
-	struct iw_statistics*	(*get_wireless_stats)(struct net_device *dev);
 
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
 	 * See <net/iw_handler.h> for details. Jean II */
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index 1358856..7a5860f 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -1,7 +1,7 @@
 /*
  * This file define a set of standard wireless extensions
  *
- * Version :	20	17.2.06
+ * Version :	21	14.3.06
  *
  * Authors :	Jean Tourrilhes - HPL - <jt@hpl.hp.com>
  * Copyright (c) 1997-2006 Jean Tourrilhes, All Rights Reserved.
@@ -69,9 +69,14 @@ #define _LINUX_WIRELESS_H
 
 /***************************** INCLUDES *****************************/
 
+/* This header is used in user-space, therefore need to be sanitised
+ * for that purpose. Those includes are usually not compatible with glibc.
+ * To know which includes to use in user-space, check iwlib.h. */
+#ifdef __KERNEL__
 #include <linux/types.h>		/* for "caddr_t" et al		*/
 #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
 #include <linux/if.h>			/* for IFNAMSIZ and co... */
+#endif	/* __KERNEL__ */
 
 /***************************** VERSION *****************************/
 /*
@@ -80,7 +85,7 @@ #include <linux/if.h>			/* for IFNAMSIZ 
  * (there is some stuff that will be added in the future...)
  * I just plan to increment with each new version.
  */
-#define WIRELESS_EXT	20
+#define WIRELESS_EXT	21
 
 /*
  * Changes :
@@ -208,6 +213,13 @@ #define WIRELESS_EXT	20
  * V19 to V20
  * ----------
  *	- RtNetlink requests support (SET/GET)
+ *
+ * V20 to V21
+ * ----------
+ *	- Remove (struct net_device *)->get_wireless_stats()
+ *	- Change length in ESSID and NICK to strlen() instead of strlen()+1
+ *	- Add IW_RETRY_SHORT/IW_RETRY_LONG retry modifiers
+ *	- Add explicit flag to tell stats are in 802.11k RCPI : IW_QUAL_RCPI
  */
 
 /**************************** CONSTANTS ****************************/
@@ -448,6 +460,7 @@ #define IW_QUAL_DBM		0x08	/* Level + Noi
 #define IW_QUAL_QUAL_INVALID	0x10	/* Driver doesn't provide value */
 #define IW_QUAL_LEVEL_INVALID	0x20
 #define IW_QUAL_NOISE_INVALID	0x40
+#define IW_QUAL_RCPI		0x80	/* Level + Noise are 802.11k RCPI */
 #define IW_QUAL_ALL_INVALID	0x70
 
 /* Frequency flags */
@@ -500,10 +513,12 @@ #define IW_RETRY_ON		0x0000	/* No detail
 #define IW_RETRY_TYPE		0xF000	/* Type of parameter */
 #define IW_RETRY_LIMIT		0x1000	/* Maximum number of retries*/
 #define IW_RETRY_LIFETIME	0x2000	/* Maximum duration of retries in us */
-#define IW_RETRY_MODIFIER	0x000F	/* Modify a parameter */
+#define IW_RETRY_MODIFIER	0x00FF	/* Modify a parameter */
 #define IW_RETRY_MIN		0x0001	/* Value is a minimum  */
 #define IW_RETRY_MAX		0x0002	/* Value is a maximum */
 #define IW_RETRY_RELATIVE	0x0004	/* Value is not in seconds/ms/us */
+#define IW_RETRY_SHORT		0x0010	/* Value is for short packets  */
+#define IW_RETRY_LONG		0x0020	/* Value is for long packets */
 
 /* Scanning request flags */
 #define IW_SCAN_DEFAULT		0x0000	/* Default scan of the driver */
@@ -1017,7 +1032,7 @@ struct	iw_range
 	/* Note : this frequency list doesn't need to fit channel numbers,
 	 * because each entry contain its channel index */
 
-	__u32		enc_capa; /* IW_ENC_CAPA_* bit field */
+	__u32		enc_capa;	/* IW_ENC_CAPA_* bit field */
 };
 
 /*
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1347276..f47f319 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -344,8 +344,6 @@ static ssize_t wireless_show(struct clas
 		if(dev->wireless_handlers &&
 		   dev->wireless_handlers->get_wireless_stats)
 			iw = dev->wireless_handlers->get_wireless_stats(dev);
-		else if (dev->get_wireless_stats)
-			iw = dev->get_wireless_stats(dev);
 		if (iw != NULL)
 			ret = (*format)(iw, buf);
 	}
@@ -465,8 +463,7 @@ int netdev_register_sysfs(struct net_dev
 		*groups++ = &netstat_group;
 
 #ifdef WIRELESS_EXT
-	if (net->get_wireless_stats
-	    || (net->wireless_handlers && net->wireless_handlers->get_wireless_stats))
+	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
 		*groups++ = &wireless_group;
 #endif
 
diff --git a/net/core/wireless.c b/net/core/wireless.c
index de0bde4..61457d8 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -68,6 +68,14 @@
  *
  * v8 - 17.02.06 - Jean II
  *	o RtNetlink requests support (SET/GET)
+ *
+ * v8b - 03.08.06 - Herbert Xu
+ *	o Fix Wireless Event locking issues.
+ *
+ * v9 - 14.3.06 - Jean II
+ *	o Change length in ESSID and NICK to strlen() instead of strlen()+1
+ *	o Make standard_ioctl_num and standard_event_num unsigned
+ *	o Remove (struct net_device *)->get_wireless_stats()
  */
 
 /***************************** INCLUDES *****************************/
@@ -234,24 +242,24 @@ static const struct iw_ioctl_description
 	[SIOCSIWESSID	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 		.flags		= IW_DESCR_FLAG_EVENT,
 	},
 	[SIOCGIWESSID	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
 	[SIOCSIWNICKN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 	},
 	[SIOCGIWNICKN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 	},
 	[SIOCSIWRATE	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
@@ -338,8 +346,8 @@ static const struct iw_ioctl_description
 		.max_tokens	= sizeof(struct iw_pmksa),
 	},
 };
-static const int standard_ioctl_num = (sizeof(standard_ioctl) /
-				       sizeof(struct iw_ioctl_description));
+static const unsigned standard_ioctl_num = (sizeof(standard_ioctl) /
+					    sizeof(struct iw_ioctl_description));
 
 /*
  * Meta-data about all the additional standard Wireless Extension events
@@ -389,8 +397,8 @@ static const struct iw_ioctl_description
 		.max_tokens	= sizeof(struct iw_pmkid_cand),
 	},
 };
-static const int standard_event_num = (sizeof(standard_event) /
-				       sizeof(struct iw_ioctl_description));
+static const unsigned standard_event_num = (sizeof(standard_event) /
+					    sizeof(struct iw_ioctl_description));
 
 /* Size (in bytes) of the various private data types */
 static const char iw_priv_type_size[] = {
@@ -465,17 +473,6 @@ static inline struct iw_statistics *get_
 	   (dev->wireless_handlers->get_wireless_stats != NULL))
 		return dev->wireless_handlers->get_wireless_stats(dev);
 
-	/* Old location, field to be removed in next WE */
-	if(dev->get_wireless_stats) {
-		static int printed_message;
-
-		if (!printed_message++)
-			printk(KERN_DEBUG "%s (WE) : Driver using old /proc/net/wireless support, please fix driver !\n",
-				dev->name);
-
-		return dev->get_wireless_stats(dev);
-	}
-
 	/* Not found */
 	return (struct iw_statistics *) NULL;
 }
@@ -1843,8 +1840,33 @@ #endif	/* CONFIG_NET_WIRELESS_RTNETLINK 
  */
 
 #ifdef WE_EVENT_RTNETLINK
+/* ---------------------------------------------------------------- */
+/*
+ * Locking...
+ * ----------
+ *
+ * Thanks to Herbert Xu <herbert@gondor.apana.org.au> for fixing
+ * the locking issue in here and implementing this code !
+ *
+ * The issue : wireless_send_event() is often called in interrupt context,
+ * while the Netlink layer can never be called in interrupt context.
+ * The fully formed RtNetlink events are queued, and then a tasklet is run
+ * to feed those to Netlink.
+ * The skb_queue is interrupt safe, and its lock is not held while calling
+ * Netlink, so there is no possibility of dealock.
+ * Jean II
+ */
+
 static struct sk_buff_head wireless_nlevent_queue;
 
+static int __init wireless_nlevent_init(void)
+{
+	skb_queue_head_init(&wireless_nlevent_queue);
+	return 0;
+}
+
+subsys_initcall(wireless_nlevent_init);
+
 static void wireless_nlevent_process(unsigned long data)
 {
 	struct sk_buff *skb;
@@ -1921,13 +1943,6 @@ static inline void rtmsg_iwinfo(struct n
 	tasklet_schedule(&wireless_nlevent_tasklet);
 }
 
-static int __init wireless_nlevent_init(void)
-{
-	skb_queue_head_init(&wireless_nlevent_queue);
-	return 0;
-}
-
-subsys_initcall(wireless_nlevent_init);
 #endif	/* WE_EVENT_RTNETLINK */
 
 /* ---------------------------------------------------------------- */
-- 
1.4.2.GIT

-- 
John W. Linville
linville@tuxdriver.com
