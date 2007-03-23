From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6] WE-22 : prevent information leak on 64 bit
Date: Thu, 22 Mar 2007 17:31:16 -0700
Message-ID: <20070323003116.GC2712@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkm@devicescape.com>
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:50302 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934018AbXCWAcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 20:32:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi,

	Johannes Berg discovered that kernel space was leaking to
userspace on 64 bit platform. He made a first patch to fix that. This
is an improved version of his patch.
	This was tested on 2.6.21-rc4. Would you mind pushing that
upstream ?
	Thanks...

	Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/include/linux/wireless.j1.h linux/include/linux/wireless.h
--- linux/include/linux/wireless.j1.h	2007-03-08 10:34:32.000000000 -0800
+++ linux/include/linux/wireless.h	2007-03-21 11:01:14.000000000 -0700
@@ -1,10 +1,10 @@
 /*
  * This file define a set of standard wireless extensions
  *
- * Version :	21	14.3.06
+ * Version :	22	16.3.07
  *
  * Authors :	Jean Tourrilhes - HPL - <jt@hpl.hp.com>
- * Copyright (c) 1997-2006 Jean Tourrilhes, All Rights Reserved.
+ * Copyright (c) 1997-2007 Jean Tourrilhes, All Rights Reserved.
  */
 
 #ifndef _LINUX_WIRELESS_H
@@ -85,7 +85,7 @@
  * (there is some stuff that will be added in the future...)
  * I just plan to increment with each new version.
  */
-#define WIRELESS_EXT	21
+#define WIRELESS_EXT	22
 
 /*
  * Changes :
@@ -221,6 +221,10 @@
  *	- Add IW_RETRY_SHORT/IW_RETRY_LONG retry modifiers
  *	- Power/Retry relative values no longer * 100000
  *	- Add explicit flag to tell stats are in 802.11k RCPI : IW_QUAL_RCPI
+ *
+ * V21 to V22
+ * ----------
+ *	- Prevent leaking of kernel space in stream on 64 bits.
  */
 
 /**************************** CONSTANTS ****************************/
@@ -1085,4 +1089,15 @@ struct iw_event
 #define IW_EV_POINT_LEN	(IW_EV_LCP_LEN + sizeof(struct iw_point) - \
 			 IW_EV_POINT_OFF)
 
+/* Size of the Event prefix when packed in stream */
+#define IW_EV_LCP_PK_LEN	(4)
+/* Size of the various events when packed in stream */
+#define IW_EV_CHAR_PK_LEN	(IW_EV_LCP_PK_LEN + IFNAMSIZ)
+#define IW_EV_UINT_PK_LEN	(IW_EV_LCP_PK_LEN + sizeof(__u32))
+#define IW_EV_FREQ_PK_LEN	(IW_EV_LCP_PK_LEN + sizeof(struct iw_freq))
+#define IW_EV_PARAM_PK_LEN	(IW_EV_LCP_PK_LEN + sizeof(struct iw_param))
+#define IW_EV_ADDR_PK_LEN	(IW_EV_LCP_PK_LEN + sizeof(struct sockaddr))
+#define IW_EV_QUAL_PK_LEN	(IW_EV_LCP_PK_LEN + sizeof(struct iw_quality))
+#define IW_EV_POINT_PK_LEN	(IW_EV_LCP_LEN + 4)
+
 #endif	/* _LINUX_WIRELESS_H */
diff -u -p linux/include/net/iw_handler.j1.h linux/include/net/iw_handler.h
--- linux/include/net/iw_handler.j1.h	2007-03-16 17:36:22.000000000 -0700
+++ linux/include/net/iw_handler.h	2007-03-21 11:01:09.000000000 -0700
@@ -1,10 +1,10 @@
 /*
  * This file define the new driver API for Wireless Extensions
  *
- * Version :	7	18.3.05
+ * Version :	8	16.3.07
  *
  * Authors :	Jean Tourrilhes - HPL - <jt@hpl.hp.com>
- * Copyright (c) 2001-2006 Jean Tourrilhes, All Rights Reserved.
+ * Copyright (c) 2001-2007 Jean Tourrilhes, All Rights Reserved.
  */
 
 #ifndef _IW_HANDLER_H
@@ -207,7 +207,7 @@
  * will be needed...
  * I just plan to increment with each new version.
  */
-#define IW_HANDLER_VERSION	7
+#define IW_HANDLER_VERSION	8
 
 /*
  * Changes :
@@ -239,6 +239,10 @@
  *	- Remove (struct iw_point *)->pointer from events and streams
  *	- Remove spy_offset from struct iw_handler_def
  *	- Add "check" version of event macros for ieee802.11 stack
+ *
+ * V7 to V8
+ * ----------
+ *	- Prevent leaking of kernel space in stream on 64 bits.
  */
 
 /**************************** CONSTANTS ****************************/
@@ -500,7 +504,11 @@ iwe_stream_add_event(char *	stream,		/* 
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
-		memcpy(stream, (char *) iwe, event_len);
+		/* Beware of alignement issues on 64 bits */
+		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
+		memcpy(stream + IW_EV_LCP_LEN,
+		       ((char *) iwe) + IW_EV_LCP_LEN,
+		       event_len - IW_EV_LCP_LEN);
 		stream += event_len;
 	}
 	return stream;
@@ -521,10 +529,10 @@ iwe_stream_add_point(char *	stream,		/* 
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
-		memcpy(stream, (char *) iwe, IW_EV_LCP_LEN);
+		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
 		memcpy(stream + IW_EV_LCP_LEN,
 		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
-		       IW_EV_POINT_LEN - IW_EV_LCP_LEN);
+		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
 		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
 		stream += event_len;
 	}
@@ -574,7 +582,11 @@ iwe_stream_check_add_event(char *	stream
 	/* Check if it's possible, set error if not */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
-		memcpy(stream, (char *) iwe, event_len);
+		/* Beware of alignement issues on 64 bits */
+		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
+		memcpy(stream + IW_EV_LCP_LEN,
+		       ((char *) iwe) + IW_EV_LCP_LEN,
+		       event_len - IW_EV_LCP_LEN);
 		stream += event_len;
 	} else
 		*perr = -E2BIG;
@@ -598,10 +610,10 @@ iwe_stream_check_add_point(char *	stream
 	/* Check if it's possible */
 	if(likely((stream + event_len) < ends)) {
 		iwe->len = event_len;
-		memcpy(stream, (char *) iwe, IW_EV_LCP_LEN);
+		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
 		memcpy(stream + IW_EV_LCP_LEN,
 		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
-		       IW_EV_POINT_LEN - IW_EV_LCP_LEN);
+		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
 		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
 		stream += event_len;
 	} else
diff -u -p linux/net/core/rtnetlink.j1.c linux/net/core/rtnetlink.c
--- linux/net/core/rtnetlink.j1.c	2007-03-21 10:59:07.000000000 -0700
+++ linux/net/core/rtnetlink.c	2007-03-21 11:00:27.000000000 -0700
@@ -621,7 +621,8 @@ static int rtnl_getlink(struct sk_buff *
 		if (err < 0)
 			goto errout;
 
-		iw += IW_EV_POINT_OFF;
+		/* Payload is at an offset in buffer */
+		iw = iw_buf + IW_EV_POINT_OFF;
 	}
 #endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
diff -u -p linux/net/core/wireless.j1.c linux/net/core/wireless.c
--- linux/net/core/wireless.j1.c	2007-03-08 14:20:22.000000000 -0800
+++ linux/net/core/wireless.c	2007-03-16 18:29:33.000000000 -0700
@@ -2,7 +2,7 @@
  * This file implement the Wireless Extensions APIs.
  *
  * Authors :	Jean Tourrilhes - HPL - <jt@hpl.hp.com>
- * Copyright (c) 1997-2006 Jean Tourrilhes, All Rights Reserved.
+ * Copyright (c) 1997-2007 Jean Tourrilhes, All Rights Reserved.
  *
  * (As all part of the Linux kernel, this file is GPL)
  */
@@ -76,6 +76,9 @@
  *	o Change length in ESSID and NICK to strlen() instead of strlen()+1
  *	o Make standard_ioctl_num and standard_event_num unsigned
  *	o Remove (struct net_device *)->get_wireless_stats()
+ *
+ * v10 - 16.3.07 - Jean II
+ *	o Prevent leaking of kernel space in stream on 64 bits.
  */
 
 /***************************** INCLUDES *****************************/
@@ -427,6 +430,21 @@ static const int event_type_size[] = {
 	IW_EV_QUAL_LEN,			/* IW_HEADER_TYPE_QUAL */
 };
 
+/* Size (in bytes) of various events, as packed */
+static const int event_type_pk_size[] = {
+	IW_EV_LCP_PK_LEN,		/* IW_HEADER_TYPE_NULL */
+	0,
+	IW_EV_CHAR_PK_LEN,		/* IW_HEADER_TYPE_CHAR */
+	0,
+	IW_EV_UINT_PK_LEN,		/* IW_HEADER_TYPE_UINT */
+	IW_EV_FREQ_PK_LEN,		/* IW_HEADER_TYPE_FREQ */
+	IW_EV_ADDR_PK_LEN,		/* IW_HEADER_TYPE_ADDR */
+	0,
+	IW_EV_POINT_PK_LEN,		/* Without variable payload */
+	IW_EV_PARAM_PK_LEN,		/* IW_HEADER_TYPE_PARAM */
+	IW_EV_QUAL_PK_LEN,		/* IW_HEADER_TYPE_QUAL */
+};
+
 /************************ COMMON SUBROUTINES ************************/
 /*
  * Stuff that may be used in various place or doesn't fit in one
@@ -1217,7 +1235,7 @@ static int rtnetlink_standard_get(struct
 		memcpy(buffer + IW_EV_POINT_OFF, request, request_len);
 		/* Use our own copy of wrqu */
 		wrqu = (union iwreq_data *) (buffer + IW_EV_POINT_OFF
-					     + IW_EV_LCP_LEN);
+					     + IW_EV_LCP_PK_LEN);
 
 		/* No extra arguments. Trivial to handle */
 		ret = handler(dev, &info, wrqu, NULL);
@@ -1229,8 +1247,8 @@ static int rtnetlink_standard_get(struct
 
 		/* Get a temp copy of wrqu (skip pointer) */
 		memcpy(((char *) &wrqu_point) + IW_EV_POINT_OFF,
-		       ((char *) request) + IW_EV_LCP_LEN,
-		       IW_EV_POINT_LEN - IW_EV_LCP_LEN);
+		       ((char *) request) + IW_EV_LCP_PK_LEN,
+		       IW_EV_POINT_LEN - IW_EV_LCP_PK_LEN);
 
 		/* Calculate space needed by arguments. Always allocate
 		 * for max space. Easier, and won't last long... */
@@ -1240,7 +1258,7 @@ static int rtnetlink_standard_get(struct
 		   (wrqu_point.data.length > descr->max_tokens))
 			extra_size = (wrqu_point.data.length
 				      * descr->token_size);
-		buffer_size = extra_size + IW_EV_POINT_LEN + IW_EV_POINT_OFF;
+		buffer_size = extra_size + IW_EV_POINT_PK_LEN + IW_EV_POINT_OFF;
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG "%s (WE.r) : Malloc %d bytes (%d bytes)\n",
 		       dev->name, extra_size, buffer_size);
@@ -1254,15 +1272,15 @@ static int rtnetlink_standard_get(struct
 
 		/* Put wrqu in the right place (just before extra).
 		 * Leave space for IWE header and dummy pointer...
-		 * Note that IW_EV_LCP_LEN==4 bytes, so it's still aligned...
+		 * Note that IW_EV_LCP_PK_LEN==4 bytes, so it's still aligned.
 		 */
-		memcpy(buffer + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
+		memcpy(buffer + IW_EV_LCP_PK_LEN + IW_EV_POINT_OFF,
 		       ((char *) &wrqu_point) + IW_EV_POINT_OFF,
-		       IW_EV_POINT_LEN - IW_EV_LCP_LEN);
-		wrqu = (union iwreq_data *) (buffer + IW_EV_LCP_LEN);
+		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
+		wrqu = (union iwreq_data *) (buffer + IW_EV_LCP_PK_LEN);
 
 		/* Extra comes logically after that. Offset +12 bytes. */
-		extra = buffer + IW_EV_POINT_OFF + IW_EV_POINT_LEN;
+		extra = buffer + IW_EV_POINT_OFF + IW_EV_POINT_PK_LEN;
 
 		/* Call the handler */
 		ret = handler(dev, &info, wrqu, extra);
@@ -1270,11 +1288,11 @@ static int rtnetlink_standard_get(struct
 		/* Calculate real returned length */
 		extra_size = (wrqu->data.length * descr->token_size);
 		/* Re-adjust reply size */
-		request->len = extra_size + IW_EV_POINT_LEN;
+		request->len = extra_size + IW_EV_POINT_PK_LEN;
 
 		/* Put the iwe header where it should, i.e. scrap the
 		 * dummy pointer. */
-		memcpy(buffer + IW_EV_POINT_OFF, request, IW_EV_LCP_LEN);
+		memcpy(buffer + IW_EV_POINT_OFF, request, IW_EV_LCP_PK_LEN);
 
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG "%s (WE.r) : Reply 0x%04X, hdr_len %d, tokens %d, extra_size %d, buffer_size %d\n", dev->name, cmd, hdr_len, wrqu->data.length, extra_size, buffer_size);
@@ -1331,10 +1349,10 @@ static inline int rtnetlink_standard_set
 #endif	/* WE_RTNETLINK_DEBUG */
 
 	/* Extract fixed header from request. This is properly aligned. */
-	wrqu = &request->u;
+	wrqu = (union iwreq_data *) (((char *) request) + IW_EV_LCP_PK_LEN);
 
 	/* Check if wrqu is complete */
-	hdr_len = event_type_size[descr->header_type];
+	hdr_len = event_type_pk_size[descr->header_type];
 	if(request_len < hdr_len) {
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG
@@ -1359,7 +1377,7 @@ static inline int rtnetlink_standard_set
 
 		/* Put wrqu in the right place (skip pointer) */
 		memcpy(((char *) &wrqu_point) + IW_EV_POINT_OFF,
-		       wrqu, IW_EV_POINT_LEN - IW_EV_LCP_LEN);
+		       wrqu, IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
 		/* Don't forget about the event code... */
 		wrqu = &wrqu_point;
 
@@ -1483,7 +1501,7 @@ static inline int rtnetlink_private_get(
 		hdr_len = extra_size;
 		extra_size = 0;
 	} else {
-		hdr_len = IW_EV_POINT_LEN;
+		hdr_len = IW_EV_POINT_PK_LEN;
 	}
 
 	/* Check if wrqu is complete */
@@ -1514,7 +1532,7 @@ static inline int rtnetlink_private_get(
 		memcpy(buffer + IW_EV_POINT_OFF, request, request_len);
 		/* Use our own copy of wrqu */
 		wrqu = (union iwreq_data *) (buffer + IW_EV_POINT_OFF
-					     + IW_EV_LCP_LEN);
+					     + IW_EV_LCP_PK_LEN);
 
 		/* No extra arguments. Trivial to handle */
 		ret = handler(dev, &info, wrqu, (char *) wrqu);
@@ -1523,7 +1541,7 @@ static inline int rtnetlink_private_get(
 		char *	extra;
 
 		/* Buffer for full reply */
-		buffer_size = extra_size + IW_EV_POINT_LEN + IW_EV_POINT_OFF;
+		buffer_size = extra_size + IW_EV_POINT_PK_LEN + IW_EV_POINT_OFF;
 
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG "%s (WE.r) : Malloc %d bytes (%d bytes)\n",
@@ -1538,15 +1556,15 @@ static inline int rtnetlink_private_get(
 
 		/* Put wrqu in the right place (just before extra).
 		 * Leave space for IWE header and dummy pointer...
-		 * Note that IW_EV_LCP_LEN==4 bytes, so it's still aligned...
+		 * Note that IW_EV_LCP_PK_LEN==4 bytes, so it's still aligned.
 		 */
-		memcpy(buffer + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
-		       ((char *) request) + IW_EV_LCP_LEN,
-		       IW_EV_POINT_LEN - IW_EV_LCP_LEN);
-		wrqu = (union iwreq_data *) (buffer + IW_EV_LCP_LEN);
+		memcpy(buffer + IW_EV_LCP_PK_LEN + IW_EV_POINT_OFF,
+		       ((char *) request) + IW_EV_LCP_PK_LEN,
+		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
+		wrqu = (union iwreq_data *) (buffer + IW_EV_LCP_PK_LEN);
 
 		/* Extra comes logically after that. Offset +12 bytes. */
-		extra = buffer + IW_EV_POINT_OFF + IW_EV_POINT_LEN;
+		extra = buffer + IW_EV_POINT_OFF + IW_EV_POINT_PK_LEN;
 
 		/* Call the handler */
 		ret = handler(dev, &info, wrqu, extra);
@@ -1556,11 +1574,11 @@ static inline int rtnetlink_private_get(
 		if (!(descr->get_args & IW_PRIV_SIZE_FIXED))
 			extra_size = adjust_priv_size(descr->get_args, wrqu);
 		/* Re-adjust reply size */
-		request->len = extra_size + IW_EV_POINT_LEN;
+		request->len = extra_size + IW_EV_POINT_PK_LEN;
 
 		/* Put the iwe header where it should, i.e. scrap the
 		 * dummy pointer. */
-		memcpy(buffer + IW_EV_POINT_OFF, request, IW_EV_LCP_LEN);
+		memcpy(buffer + IW_EV_POINT_OFF, request, IW_EV_LCP_PK_LEN);
 
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG "%s (WE.r) : Reply 0x%04X, hdr_len %d, tokens %d, extra_size %d, buffer_size %d\n", dev->name, cmd, hdr_len, wrqu->data.length, extra_size, buffer_size);
@@ -1641,14 +1659,14 @@ static inline int rtnetlink_private_set(
 	/* Does it fits in wrqu ? */
 	if((descr->set_args & IW_PRIV_SIZE_FIXED) &&
 	   (extra_size <= IFNAMSIZ)) {
-		hdr_len = IW_EV_LCP_LEN + extra_size;
+		hdr_len = IW_EV_LCP_PK_LEN + extra_size;
 		extra_size = 0;
 	} else {
-		hdr_len = IW_EV_POINT_LEN;
+		hdr_len = IW_EV_POINT_PK_LEN;
 	}
 
 	/* Extract fixed header from request. This is properly aligned. */
-	wrqu = &request->u;
+	wrqu = (union iwreq_data *) (((char *) request) + IW_EV_LCP_PK_LEN);
 
 	/* Check if wrqu is complete */
 	if(request_len < hdr_len) {
@@ -1675,7 +1693,7 @@ static inline int rtnetlink_private_set(
 
 		/* Put wrqu in the right place (skip pointer) */
 		memcpy(((char *) &wrqu_point) + IW_EV_POINT_OFF,
-		       wrqu, IW_EV_POINT_LEN - IW_EV_LCP_LEN);
+		       wrqu, IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
 
 		/* Does it fits within bounds ? */
 		if(wrqu_point.data.length > (descr->set_args &
@@ -1738,7 +1756,7 @@ int wireless_rtnetlink_get(struct net_de
 	iw_handler		handler;
 
 	/* Check length */
-	if(len < IW_EV_LCP_LEN) {
+	if(len < IW_EV_LCP_PK_LEN) {
 		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request too short (%d)\n",
 		       dev->name, len);
 		return -EINVAL;
@@ -1822,7 +1840,7 @@ int wireless_rtnetlink_set(struct net_de
 	iw_handler		handler;
 
 	/* Check length */
-	if(len < IW_EV_LCP_LEN) {
+	if(len < IW_EV_LCP_PK_LEN) {
 		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request too short (%d)\n",
 		       dev->name, len);
 		return -EINVAL;
