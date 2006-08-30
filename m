From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 support (core API)
Date: Tue, 29 Aug 2006 17:56:55 -0700
Message-ID: <20060830005655.GA8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:39404 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1751480AbWH3BEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 21:04:11 -0400
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi John,

	This is version 21 of the Wireless Extensions. Changelog :
		o finishes migrating the ESSID API (remove the +1)
		o netdev->get_wireless_stats is no more
		o modulation
		o long/short retry
		o relative power saving.
	Only the first item is controversial, but it was agreed on
this list a few months ago. Actually, those patches have been on my
web page for a few months, waiting for users-space chages to propagate
to the distros.

	I've rediffed and retested with 2.6.18-rc5, and also made the
patches for the latest wireless-2.6 git. Core API patch included here,
mandatory driver patches to follow (to reflect API changes), extra
driver patches to be sent to the respective maintainers later. Of
course, out-of-tree drivers need #ifdef not included here...
	Would you mind sending that into Linus's kernel at the next
opportunity, for example for 2.6.19-pre.
        Have fun...

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/include/linux/wireless.20.h linux/include/linux/wireless.h
--- linux/include/linux/wireless.20.h	2006-08-28 15:00:30.000000000 -0700
+++ linux/include/linux/wireless.h	2006-08-28 15:09:59.000000000 -0700
@@ -1,7 +1,7 @@
 /*
  * This file define a set of standard wireless extensions
  *
- * Version :	20	17.2.06
+ * Version :	21	14.3.06
  *
  * Authors :	Jean Tourrilhes - HPL - <jt@hpl.hp.com>
  * Copyright (c) 1997-2006 Jean Tourrilhes, All Rights Reserved.
@@ -69,9 +69,14 @@
 
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
@@ -80,7 +85,7 @@
  * (there is some stuff that will be added in the future...)
  * I just plan to increment with each new version.
  */
-#define WIRELESS_EXT	20
+#define WIRELESS_EXT	21
 
 /*
  * Changes :
@@ -208,6 +213,17 @@
  * V19 to V20
  * ----------
  *	- RtNetlink requests support (SET/GET)
+ *
+ * V20 to V21
+ * ----------
+ *	- Remove (struct net_device *)->get_wireless_stats()
+ *	- Change length in ESSID and NICK to strlen() instead of strlen()+1
+ *	- Add SIOCSIWMODUL/SIOCGIWMODUL for modulation setting
+ *	- Add IW_RETRY_SHORT/IW_RETRY_LONG retry modifiers
+ *	- Add IW_POWER_SAVING power type
+ *	- Power/Retry relative values no longer * 100000
+ *	- Add bitrate flags for unicast/broadcast
+ *	- Add explicit flag to tell stats are in 802.11k RCPI : IW_QUAL_RCPI
  */
 
 /**************************** CONSTANTS ****************************/
@@ -281,6 +297,9 @@
 /* Power saving stuff (power management, unicast and multicast) */
 #define SIOCSIWPOWER	0x8B2C		/* set Power Management settings */
 #define SIOCGIWPOWER	0x8B2D		/* get Power Management settings */
+/* Modulation bitmask */
+#define SIOCSIWMODUL	0x8B2E		/* set Modulations settings */
+#define SIOCGIWMODUL	0x8B2F		/* get Modulations settings */
 
 /* WPA : Generic IEEE 802.11 informatiom element (e.g., for WPA/RSN/WMM).
  * This ioctl uses struct iw_point and data buffer that includes IE id and len
@@ -448,6 +467,7 @@
 #define IW_QUAL_QUAL_INVALID	0x10	/* Driver doesn't provide value */
 #define IW_QUAL_LEVEL_INVALID	0x20
 #define IW_QUAL_NOISE_INVALID	0x40
+#define IW_QUAL_RCPI		0x80	/* Level + Noise are 802.11k RCPI */
 #define IW_QUAL_ALL_INVALID	0x70
 
 /* Frequency flags */
@@ -477,6 +497,7 @@
 #define IW_POWER_TYPE		0xF000	/* Type of parameter */
 #define IW_POWER_PERIOD		0x1000	/* Value is a period/duration of  */
 #define IW_POWER_TIMEOUT	0x2000	/* Value is a timeout (to go asleep) */
+#define IW_POWER_SAVING		0x4000	/* Value is relative (how aggressive)*/
 #define IW_POWER_MODE		0x0F00	/* Power Management mode */
 #define IW_POWER_UNICAST_R	0x0100	/* Receive only unicast messages */
 #define IW_POWER_MULTICAST_R	0x0200	/* Receive only multicast messages */
@@ -500,10 +521,12 @@
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
@@ -621,6 +644,27 @@
 #define IW_EVENT_CAPA_SET(event_capa, cmd) (event_capa[IW_EVENT_CAPA_INDEX(cmd)] |= IW_EVENT_CAPA_MASK(cmd))
 #define IW_EVENT_CAPA_SET_KERNEL(event_capa) {event_capa[0] |= IW_EVENT_CAPA_K_0; event_capa[1] |= IW_EVENT_CAPA_K_1; }
 
+/* Modulations bitmasks */
+#define IW_MODUL_ALL		0x00000000	/* Everything supported */
+#define IW_MODUL_FH		0x00000001	/* Frequency Hopping */
+#define IW_MODUL_DS		0x00000002	/* Original Direct Sequence */
+#define IW_MODUL_CCK		0x00000004	/* 802.11b : 5.5 + 11 Mb/s */
+#define IW_MODUL_11B		(IW_MODUL_DS | IW_MODUL_CCK)
+#define IW_MODUL_PBCC		0x00000008	/* TI : 5.5 + 11 + 22 Mb/s */
+#define IW_MODUL_OFDM_A		0x00000010	/* 802.11a : 54 Mb/s */
+#define IW_MODUL_11A		(IW_MODUL_OFDM_A)
+#define IW_MODUL_11AB		(IW_MODUL_11B | IW_MODUL_11A)
+#define IW_MODUL_OFDM_G		0x00000020	/* 802.11g : 54 Mb/s */
+#define IW_MODUL_11G		(IW_MODUL_11B | IW_MODUL_OFDM_G)
+#define IW_MODUL_11AG		(IW_MODUL_11G | IW_MODUL_11A)
+#define IW_MODUL_TURBO		0x00000040	/* ATH : bonding, 108 Mb/s */
+/* In here we should define MIMO stuff. Later... */
+#define IW_MODUL_CUSTOM		0x40000000	/* Driver specific */
+
+/* Bitrate flags available */
+#define IW_BITRATE_TYPE		0x00FF	/* Type of value */
+#define IW_BITRATE_UNICAST	0x0001	/* Maximum/Fixed unicast bitrate */
+#define IW_BITRATE_BROADCAST	0x0002	/* Fixed broadcast bitrate */
 
 /****************************** TYPES ******************************/
 
@@ -1017,7 +1061,18 @@ struct	iw_range
 	/* Note : this frequency list doesn't need to fit channel numbers,
 	 * because each entry contain its channel index */
 
-	__u32		enc_capa; /* IW_ENC_CAPA_* bit field */
+	__u32		enc_capa;	/* IW_ENC_CAPA_* bit field */
+
+	/* More power management stuff */
+	__s32		min_pms;	/* Minimal PM saving */
+	__s32		max_pms;	/* Maximal PM saving */
+	__u16		pms_flags;	/* How to decode max/min PM saving */
+
+	/* All available modulations for driver (hw may support less) */
+	__s32		modul_capa;	/* IW_MODUL_* bit field */
+
+	/* More bitrate stuff */
+	__u32		bitrate_capa;	/* Types of bitrates supported */
 };
 
 /*
diff -u -p linux/include/linux/netdevice.20.h linux/include/linux/netdevice.h
--- linux/include/linux/netdevice.20.h	2006-08-28 15:00:45.000000000 -0700
+++ linux/include/linux/netdevice.h	2006-08-28 15:01:21.000000000 -0700
@@ -334,7 +334,6 @@ struct net_device
 
 
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
-	struct iw_statistics*	(*get_wireless_stats)(struct net_device *dev);
 
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
 	 * See <net/iw_handler.h> for details. Jean II */
diff -u -p linux/net/core/net-sysfs.20.c linux/net/core/net-sysfs.c
--- linux/net/core/net-sysfs.20.c	2006-08-28 15:00:55.000000000 -0700
+++ linux/net/core/net-sysfs.c	2006-08-28 15:04:15.000000000 -0700
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
 
diff -u -p linux/net/core/wireless.20.c linux/net/core/wireless.c
--- linux/net/core/wireless.20.c	2006-08-28 14:31:33.000000000 -0700
+++ linux/net/core/wireless.c	2006-08-28 15:02:30.000000000 -0700
@@ -68,6 +68,15 @@
  *
  * v8 - 17.02.06 - Jean II
  *	o RtNetlink requests support (SET/GET)
+ *
+ * v8b - 03.08.06 - Herbert Xu
+ *	o Fix Wireless Event locking issues.
+ *
+ * v9 - 14.3.06 - Jean II
+ *	o Change length in ESSID and NICK to strlen() instead of strlen()+1
+ *	o Add SIOCSIWMODUL/SIOCGIWMODUL for modulation setting
+ *	o Make standard_ioctl_num and standard_event_num unsigned
+ *	o Remove (struct net_device *)->get_wireless_stats()
  */
 
 /***************************** INCLUDES *****************************/
@@ -234,24 +243,24 @@ static const struct iw_ioctl_description
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
@@ -301,6 +310,12 @@ static const struct iw_ioctl_description
 	[SIOCGIWPOWER	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
+	[SIOCSIWMODUL	- SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_PARAM,
+	},
+	[SIOCGIWMODUL	- SIOCIWFIRST] = {
+		.header_type	= IW_HEADER_TYPE_PARAM,
+	},
 	[SIOCSIWGENIE	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
@@ -338,8 +353,8 @@ static const struct iw_ioctl_description
 		.max_tokens	= sizeof(struct iw_pmksa),
 	},
 };
-static const int standard_ioctl_num = (sizeof(standard_ioctl) /
-				       sizeof(struct iw_ioctl_description));
+static const unsigned standard_ioctl_num = (sizeof(standard_ioctl) /
+					    sizeof(struct iw_ioctl_description));
 
 /*
  * Meta-data about all the additional standard Wireless Extension events
@@ -389,8 +404,8 @@ static const struct iw_ioctl_description
 		.max_tokens	= sizeof(struct iw_pmkid_cand),
 	},
 };
-static const int standard_event_num = (sizeof(standard_event) /
-				       sizeof(struct iw_ioctl_description));
+static const unsigned standard_event_num = (sizeof(standard_event) /
+					    sizeof(struct iw_ioctl_description));
 
 /* Size (in bytes) of the various private data types */
 static const char iw_priv_type_size[] = {
@@ -465,17 +480,6 @@ static inline struct iw_statistics *get_
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
@@ -1843,8 +1847,33 @@ int wireless_rtnetlink_set(struct net_de
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
@@ -1921,13 +1950,6 @@ static inline void rtmsg_iwinfo(struct n
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
