From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] remove wext over netlink
Date: Mon, 23 Apr 2007 14:37:34 -0400
Message-ID: <20070423183734.GF5883@tuxdriver.com>
References: <20070423183334.GC5883@tuxdriver.com> <20070423183443.GD5883@tuxdriver.com> <20070423183634.GE5883@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070423183634.GE5883-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

As scheduled, this patch removes the pointless wext over netlink
code.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 Documentation/feature-removal-schedule.txt |   12 -
 include/net/iw_handler.h                   |   10 -
 net/core/rtnetlink.c                       |   31 --
 net/core/wireless.c                        |  735 ----------------------------
 net/wireless/Kconfig                       |   10 -
 5 files changed, 0 insertions(+), 798 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 9817b60..976c8a1 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -285,18 +285,6 @@ Who:	Richard Purdie <rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org>
 
 ---------------------------
 
-What:	Wireless extensions over netlink (CONFIG_NET_WIRELESS_RTNETLINK)
-When:	with the merge of wireless-dev, 2.6.22 or later
-Why:	The option/code is
-	 * not enabled on most kernels
-	 * not required by any userspace tools (except an experimental one,
-	   and even there only for some parts, others use ioctl)
-	 * pointless since wext is no longer evolving and the ioctl
-	   interface needs to be kept
-Who:	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
-
----------------------------
-
 What:	i8xx_tco watchdog driver
 When:	in 2.6.22
 Why:	the i8xx_tco watchdog driver has been replaced by the iTCO_wdt
diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index 8a83018..909ca87 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -440,16 +440,6 @@ extern int dev_get_wireless_info(char * buffer, char **start, off_t offset,
 /* Handle IOCTLs, called in net/core/dev.c */
 extern int wireless_process_ioctl(struct ifreq *ifr, unsigned int cmd);
 
-/* Handle RtNetlink requests, called in net/core/rtnetlink.c */
-extern int wireless_rtnetlink_set(struct net_device *	dev,
-				  char *		data,
-				  int			len);
-extern int wireless_rtnetlink_get(struct net_device *	dev,
-				  char *		data,
-				  int			len,
-				  char **		p_buf,
-				  int *			p_len);
-
 /* Second : functions that may be called by driver modules */
 
 /* Send a single event to user space */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 75cea8e..4fe0f4b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -51,10 +51,6 @@
 #include <net/pkt_sched.h>
 #include <net/fib_rules.h>
 #include <net/rtnetlink.h>
-#ifdef CONFIG_NET_WIRELESS_RTNETLINK
-#include <linux/wireless.h>
-#include <net/iw_handler.h>
-#endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
 struct rtnl_link
 {
@@ -684,17 +680,6 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		modified = 1;
 	}
 
-#ifdef CONFIG_NET_WIRELESS_RTNETLINK
-	if (tb[IFLA_WIRELESS]) {
-		/* Call Wireless Extensions.
-		 * Various stuff checked in there... */
-		err = wireless_rtnetlink_set(dev, nla_data(tb[IFLA_WIRELESS]),
-					     nla_len(tb[IFLA_WIRELESS]));
-		if (err < 0)
-			goto errout_dev;
-	}
-#endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
-
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
 		send_addr_notify = 1;
@@ -758,22 +743,6 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	} else
 		return -EINVAL;
 
-
-#ifdef CONFIG_NET_WIRELESS_RTNETLINK
-	if (tb[IFLA_WIRELESS]) {
-		/* Call Wireless Extensions. We need to know the size before
-		 * we can alloc. Various stuff checked in there... */
-		err = wireless_rtnetlink_get(dev, nla_data(tb[IFLA_WIRELESS]),
-					     nla_len(tb[IFLA_WIRELESS]),
-					     &iw_buf, &iw_buf_len);
-		if (err < 0)
-			goto errout;
-
-		/* Payload is at an offset in buffer */
-		iw = iw_buf + IW_EV_POINT_OFF;
-	}
-#endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
-
 	nskb = nlmsg_new(if_nlmsg_size(iw_buf_len), GFP_KERNEL);
 	if (nskb == NULL) {
 		err = -ENOBUFS;
diff --git a/net/core/wireless.c b/net/core/wireless.c
index 86db63d..fba295e 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -104,12 +104,10 @@
 
 /* Debugging stuff */
 #undef WE_IOCTL_DEBUG		/* Debug IOCTL API */
-#undef WE_RTNETLINK_DEBUG	/* Debug RtNetlink API */
 #undef WE_EVENT_DEBUG		/* Debug Event dispatcher */
 #undef WE_SPY_DEBUG		/* Debug enhanced spy support */
 
 /* Options */
-//CONFIG_NET_WIRELESS_RTNETLINK	/* Wireless requests over RtNetlink */
 #define WE_EVENT_RTNETLINK	/* Propagate events using RtNetlink */
 #define WE_SET_EVENT		/* Generate an event on some set commands */
 
@@ -1145,739 +1143,6 @@ int wireless_process_ioctl(struct ifreq *ifr, unsigned int cmd)
 	return -EINVAL;
 }
 
-/********************** RTNETLINK REQUEST API **********************/
-/*
- * The alternate user space API to configure all those Wireless Extensions
- * is through RtNetlink.
- * This API support only the new driver API (iw_handler).
- *
- * This RtNetlink API use the same query/reply model as the ioctl API.
- * Maximum effort has been done to fit in the RtNetlink model, and
- * we support both RtNetlink Set and RtNelink Get operations.
- * On the other hand, we don't offer Dump operations because of the
- * following reasons :
- *	o Large number of parameters, most optional
- *	o Large size of some parameters (> 100 bytes)
- *	o Each parameters need to be extracted from hardware
- *	o Scan requests can take seconds and disable network activity.
- * Because of this high cost/overhead, we want to return only the
- * parameters the user application is really interested in.
- * We could offer partial Dump using the IW_DESCR_FLAG_DUMP flag.
- *
- * The API uses the standard RtNetlink socket. When the RtNetlink code
- * find a IFLA_WIRELESS field in a RtNetlink SET_LINK request,
- * it calls here.
- */
-
-#ifdef CONFIG_NET_WIRELESS_RTNETLINK
-/* ---------------------------------------------------------------- */
-/*
- * Wrapper to call a standard Wireless Extension GET handler.
- * We do various checks and call the handler with the proper args.
- */
-static int rtnetlink_standard_get(struct net_device *	dev,
-				  struct iw_event *	request,
-				  int			request_len,
-				  iw_handler		handler,
-				  char **		p_buf,
-				  int *			p_len)
-{
-	const struct iw_ioctl_description *	descr = NULL;
-	unsigned int				cmd;
-	union iwreq_data *			wrqu;
-	int					hdr_len;
-	struct iw_request_info			info;
-	char *					buffer = NULL;
-	int					buffer_size = 0;
-	int					ret = -EINVAL;
-
-	/* Get the description of the Request */
-	cmd = request->cmd;
-	if ((cmd - SIOCIWFIRST) >= standard_ioctl_num)
-		return -EOPNOTSUPP;
-	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
-
-#ifdef WE_RTNETLINK_DEBUG
-	printk(KERN_DEBUG "%s (WE.r) : Found standard handler for 0x%04X\n",
-	       dev->name, cmd);
-	printk(KERN_DEBUG "%s (WE.r) : Header type : %d, Token type : %d, size : %d, token : %d\n", dev->name, descr->header_type, descr->token_type, descr->token_size, descr->max_tokens);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-	/* Check if wrqu is complete */
-	hdr_len = event_type_size[descr->header_type];
-	if (request_len < hdr_len) {
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG
-		       "%s (WE.r) : Wireless request too short (%d)\n",
-		       dev->name, request_len);
-#endif	/* WE_RTNETLINK_DEBUG */
-		return -EINVAL;
-	}
-
-	/* Prepare the call */
-	info.cmd = cmd;
-	info.flags = 0;
-
-	/* Check if we have extra data in the reply or not */
-	if (descr->header_type != IW_HEADER_TYPE_POINT) {
-
-		/* Create the kernel buffer that we will return.
-		 * It's at an offset to match the TYPE_POINT case... */
-		buffer_size = request_len + IW_EV_POINT_OFF;
-		buffer = kmalloc(buffer_size, GFP_KERNEL);
-		if (buffer == NULL) {
-			return -ENOMEM;
-		}
-		/* Copy event data */
-		memcpy(buffer + IW_EV_POINT_OFF, request, request_len);
-		/* Use our own copy of wrqu */
-		wrqu = (union iwreq_data *) (buffer + IW_EV_POINT_OFF
-					     + IW_EV_LCP_PK_LEN);
-
-		/* No extra arguments. Trivial to handle */
-		ret = handler(dev, &info, wrqu, NULL);
-
-	} else {
-		union iwreq_data	wrqu_point;
-		char *			extra = NULL;
-		int			extra_size = 0;
-
-		/* Get a temp copy of wrqu (skip pointer) */
-		memcpy(((char *) &wrqu_point) + IW_EV_POINT_OFF,
-		       ((char *) request) + IW_EV_LCP_PK_LEN,
-		       IW_EV_POINT_LEN - IW_EV_LCP_PK_LEN);
-
-		/* Calculate space needed by arguments. Always allocate
-		 * for max space. Easier, and won't last long... */
-		extra_size = descr->max_tokens * descr->token_size;
-		/* Support for very large requests */
-		if ((descr->flags & IW_DESCR_FLAG_NOMAX) &&
-		   (wrqu_point.data.length > descr->max_tokens))
-			extra_size = (wrqu_point.data.length
-				      * descr->token_size);
-		buffer_size = extra_size + IW_EV_POINT_PK_LEN + IW_EV_POINT_OFF;
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG "%s (WE.r) : Malloc %d bytes (%d bytes)\n",
-		       dev->name, extra_size, buffer_size);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-		/* Create the kernel buffer that we will return */
-		buffer = kmalloc(buffer_size, GFP_KERNEL);
-		if (buffer == NULL) {
-			return -ENOMEM;
-		}
-
-		/* Put wrqu in the right place (just before extra).
-		 * Leave space for IWE header and dummy pointer...
-		 * Note that IW_EV_LCP_PK_LEN==4 bytes, so it's still aligned.
-		 */
-		memcpy(buffer + IW_EV_LCP_PK_LEN + IW_EV_POINT_OFF,
-		       ((char *) &wrqu_point) + IW_EV_POINT_OFF,
-		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		wrqu = (union iwreq_data *) (buffer + IW_EV_LCP_PK_LEN);
-
-		/* Extra comes logically after that. Offset +12 bytes. */
-		extra = buffer + IW_EV_POINT_OFF + IW_EV_POINT_PK_LEN;
-
-		/* Call the handler */
-		ret = handler(dev, &info, wrqu, extra);
-
-		/* Calculate real returned length */
-		extra_size = (wrqu->data.length * descr->token_size);
-		/* Re-adjust reply size */
-		request->len = extra_size + IW_EV_POINT_PK_LEN;
-
-		/* Put the iwe header where it should, i.e. scrap the
-		 * dummy pointer. */
-		memcpy(buffer + IW_EV_POINT_OFF, request, IW_EV_LCP_PK_LEN);
-
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG "%s (WE.r) : Reply 0x%04X, hdr_len %d, tokens %d, extra_size %d, buffer_size %d\n", dev->name, cmd, hdr_len, wrqu->data.length, extra_size, buffer_size);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-		/* Check if there is enough buffer up there */
-		if (wrqu_point.data.length < wrqu->data.length)
-			ret = -E2BIG;
-	}
-
-	/* Return the buffer to the caller */
-	if (!ret) {
-		*p_buf = buffer;
-		*p_len = request->len;
-	} else {
-		/* Cleanup */
-		if (buffer)
-			kfree(buffer);
-	}
-
-	return ret;
-}
-
-/* ---------------------------------------------------------------- */
-/*
- * Wrapper to call a standard Wireless Extension SET handler.
- * We do various checks and call the handler with the proper args.
- */
-static inline int rtnetlink_standard_set(struct net_device *	dev,
-					 struct iw_event *	request,
-					 int			request_len,
-					 iw_handler		handler)
-{
-	const struct iw_ioctl_description *	descr = NULL;
-	unsigned int				cmd;
-	union iwreq_data *			wrqu;
-	union iwreq_data			wrqu_point;
-	int					hdr_len;
-	char *					extra = NULL;
-	int					extra_size = 0;
-	struct iw_request_info			info;
-	int					ret = -EINVAL;
-
-	/* Get the description of the Request */
-	cmd = request->cmd;
-	if ((cmd - SIOCIWFIRST) >= standard_ioctl_num)
-		return -EOPNOTSUPP;
-	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
-
-#ifdef WE_RTNETLINK_DEBUG
-	printk(KERN_DEBUG "%s (WE.r) : Found standard SET handler for 0x%04X\n",
-	       dev->name, cmd);
-	printk(KERN_DEBUG "%s (WE.r) : Header type : %d, Token type : %d, size : %d, token : %d\n", dev->name, descr->header_type, descr->token_type, descr->token_size, descr->max_tokens);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-	/* Extract fixed header from request. This is properly aligned. */
-	wrqu = (union iwreq_data *) (((char *) request) + IW_EV_LCP_PK_LEN);
-
-	/* Check if wrqu is complete */
-	hdr_len = event_type_pk_size[descr->header_type];
-	if (request_len < hdr_len) {
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG
-		       "%s (WE.r) : Wireless request too short (%d)\n",
-		       dev->name, request_len);
-#endif	/* WE_RTNETLINK_DEBUG */
-		return -EINVAL;
-	}
-
-	/* Prepare the call */
-	info.cmd = cmd;
-	info.flags = 0;
-
-	/* Check if we have extra data in the request or not */
-	if (descr->header_type != IW_HEADER_TYPE_POINT) {
-
-		/* No extra arguments. Trivial to handle */
-		ret = handler(dev, &info, wrqu, NULL);
-
-	} else {
-		int	extra_len;
-
-		/* Put wrqu in the right place (skip pointer) */
-		memcpy(((char *) &wrqu_point) + IW_EV_POINT_OFF,
-		       wrqu, IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		/* Don't forget about the event code... */
-		wrqu = &wrqu_point;
-
-		/* Check if number of token fits within bounds */
-		if (wrqu_point.data.length > descr->max_tokens)
-			return -E2BIG;
-		if (wrqu_point.data.length < descr->min_tokens)
-			return -EINVAL;
-
-		/* Real length of payload */
-		extra_len = wrqu_point.data.length * descr->token_size;
-
-		/* Check if request is self consistent */
-		if ((request_len - hdr_len) < extra_len) {
-#ifdef WE_RTNETLINK_DEBUG
-			printk(KERN_DEBUG "%s (WE.r) : Wireless request data too short (%d)\n",
-			       dev->name, extra_size);
-#endif	/* WE_RTNETLINK_DEBUG */
-			return -EINVAL;
-		}
-
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG "%s (WE.r) : Malloc %d bytes\n",
-		       dev->name, extra_size);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-		/* Always allocate for max space. Easier, and won't last
-		 * long... */
-		extra_size = descr->max_tokens * descr->token_size;
-		extra = kmalloc(extra_size, GFP_KERNEL);
-		if (extra == NULL)
-			return -ENOMEM;
-
-		/* Copy extra in aligned buffer */
-		memcpy(extra, ((char *) request) + hdr_len, extra_len);
-
-		/* Call the handler */
-		ret = handler(dev, &info, &wrqu_point, extra);
-	}
-
-#ifdef WE_SET_EVENT
-	/* Generate an event to notify listeners of the change */
-	if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
-	   ((ret == 0) || (ret == -EIWCOMMIT))) {
-		if (descr->flags & IW_DESCR_FLAG_RESTRICT)
-			/* If the event is restricted, don't
-			 * export the payload */
-			wireless_send_event(dev, cmd, wrqu, NULL);
-		else
-			wireless_send_event(dev, cmd, wrqu, extra);
-	}
-#endif	/* WE_SET_EVENT */
-
-	/* Cleanup - I told you it wasn't that long ;-) */
-	if (extra)
-		kfree(extra);
-
-	/* Call commit handler if needed and defined */
-	if (ret == -EIWCOMMIT)
-		ret = call_commit_handler(dev);
-
-	return ret;
-}
-
-/* ---------------------------------------------------------------- */
-/*
- * Wrapper to call a private Wireless Extension GET handler.
- * Same as above...
- * It's not as nice and slimline as the standard wrapper. The cause
- * is struct iw_priv_args, which was not really designed for the
- * job we are going here.
- *
- * IMPORTANT : This function prevent to set and get data on the same
- * IOCTL and enforce the SET/GET convention. Not doing it would be
- * far too hairy...
- * If you need to set and get data at the same time, please don't use
- * a iw_handler but process it in your ioctl handler (i.e. use the
- * old driver API).
- */
-static inline int rtnetlink_private_get(struct net_device *	dev,
-					struct iw_event *	request,
-					int			request_len,
-					iw_handler		handler,
-					char **			p_buf,
-					int *			p_len)
-{
-	const struct iw_priv_args *	descr = NULL;
-	unsigned int			cmd;
-	union iwreq_data *		wrqu;
-	int				hdr_len;
-	struct iw_request_info		info;
-	int				extra_size = 0;
-	int				i;
-	char *				buffer = NULL;
-	int				buffer_size = 0;
-	int				ret = -EINVAL;
-
-	/* Get the description of the Request */
-	cmd = request->cmd;
-	for (i = 0; i < dev->wireless_handlers->num_private_args; i++)
-		if (cmd == dev->wireless_handlers->private_args[i].cmd) {
-			descr = &(dev->wireless_handlers->private_args[i]);
-			break;
-		}
-	if (descr == NULL)
-		return -EOPNOTSUPP;
-
-#ifdef WE_RTNETLINK_DEBUG
-	printk(KERN_DEBUG "%s (WE.r) : Found private handler for 0x%04X\n",
-	       dev->name, cmd);
-	printk(KERN_DEBUG "%s (WE.r) : Name %s, set %X, get %X\n",
-	       dev->name, descr->name, descr->set_args, descr->get_args);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-	/* Compute the max size of the get arguments */
-	extra_size = get_priv_size(descr->get_args);
-
-	/* Does it fits in wrqu ? */
-	if ((descr->get_args & IW_PRIV_SIZE_FIXED) &&
-	   (extra_size <= IFNAMSIZ)) {
-		hdr_len = extra_size;
-		extra_size = 0;
-	} else {
-		hdr_len = IW_EV_POINT_PK_LEN;
-	}
-
-	/* Check if wrqu is complete */
-	if (request_len < hdr_len) {
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG
-		       "%s (WE.r) : Wireless request too short (%d)\n",
-		       dev->name, request_len);
-#endif	/* WE_RTNETLINK_DEBUG */
-		return -EINVAL;
-	}
-
-	/* Prepare the call */
-	info.cmd = cmd;
-	info.flags = 0;
-
-	/* Check if we have a pointer to user space data or not. */
-	if (extra_size == 0) {
-
-		/* Create the kernel buffer that we will return.
-		 * It's at an offset to match the TYPE_POINT case... */
-		buffer_size = request_len + IW_EV_POINT_OFF;
-		buffer = kmalloc(buffer_size, GFP_KERNEL);
-		if (buffer == NULL) {
-			return -ENOMEM;
-		}
-		/* Copy event data */
-		memcpy(buffer + IW_EV_POINT_OFF, request, request_len);
-		/* Use our own copy of wrqu */
-		wrqu = (union iwreq_data *) (buffer + IW_EV_POINT_OFF
-					     + IW_EV_LCP_PK_LEN);
-
-		/* No extra arguments. Trivial to handle */
-		ret = handler(dev, &info, wrqu, (char *) wrqu);
-
-	} else {
-		char *	extra;
-
-		/* Buffer for full reply */
-		buffer_size = extra_size + IW_EV_POINT_PK_LEN + IW_EV_POINT_OFF;
-
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG "%s (WE.r) : Malloc %d bytes (%d bytes)\n",
-		       dev->name, extra_size, buffer_size);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-		/* Create the kernel buffer that we will return */
-		buffer = kmalloc(buffer_size, GFP_KERNEL);
-		if (buffer == NULL) {
-			return -ENOMEM;
-		}
-
-		/* Put wrqu in the right place (just before extra).
-		 * Leave space for IWE header and dummy pointer...
-		 * Note that IW_EV_LCP_PK_LEN==4 bytes, so it's still aligned.
-		 */
-		memcpy(buffer + IW_EV_LCP_PK_LEN + IW_EV_POINT_OFF,
-		       ((char *) request) + IW_EV_LCP_PK_LEN,
-		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		wrqu = (union iwreq_data *) (buffer + IW_EV_LCP_PK_LEN);
-
-		/* Extra comes logically after that. Offset +12 bytes. */
-		extra = buffer + IW_EV_POINT_OFF + IW_EV_POINT_PK_LEN;
-
-		/* Call the handler */
-		ret = handler(dev, &info, wrqu, extra);
-
-		/* Adjust for the actual length if it's variable,
-		 * avoid leaking kernel bits outside. */
-		if (!(descr->get_args & IW_PRIV_SIZE_FIXED))
-			extra_size = adjust_priv_size(descr->get_args, wrqu);
-		/* Re-adjust reply size */
-		request->len = extra_size + IW_EV_POINT_PK_LEN;
-
-		/* Put the iwe header where it should, i.e. scrap the
-		 * dummy pointer. */
-		memcpy(buffer + IW_EV_POINT_OFF, request, IW_EV_LCP_PK_LEN);
-
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG "%s (WE.r) : Reply 0x%04X, hdr_len %d, tokens %d, extra_size %d, buffer_size %d\n", dev->name, cmd, hdr_len, wrqu->data.length, extra_size, buffer_size);
-#endif	/* WE_RTNETLINK_DEBUG */
-	}
-
-	/* Return the buffer to the caller */
-	if (!ret) {
-		*p_buf = buffer;
-		*p_len = request->len;
-	} else {
-		/* Cleanup */
-		if (buffer)
-			kfree(buffer);
-	}
-
-	return ret;
-}
-
-/* ---------------------------------------------------------------- */
-/*
- * Wrapper to call a private Wireless Extension SET handler.
- * Same as above...
- * It's not as nice and slimline as the standard wrapper. The cause
- * is struct iw_priv_args, which was not really designed for the
- * job we are going here.
- *
- * IMPORTANT : This function prevent to set and get data on the same
- * IOCTL and enforce the SET/GET convention. Not doing it would be
- * far too hairy...
- * If you need to set and get data at the same time, please don't use
- * a iw_handler but process it in your ioctl handler (i.e. use the
- * old driver API).
- */
-static inline int rtnetlink_private_set(struct net_device *	dev,
-					struct iw_event *	request,
-					int			request_len,
-					iw_handler		handler)
-{
-	const struct iw_priv_args *	descr = NULL;
-	unsigned int			cmd;
-	union iwreq_data *		wrqu;
-	union iwreq_data		wrqu_point;
-	int				hdr_len;
-	char *				extra = NULL;
-	int				extra_size = 0;
-	int				offset = 0;	/* For sub-ioctls */
-	struct iw_request_info		info;
-	int				i;
-	int				ret = -EINVAL;
-
-	/* Get the description of the Request */
-	cmd = request->cmd;
-	for (i = 0; i < dev->wireless_handlers->num_private_args; i++)
-		if (cmd == dev->wireless_handlers->private_args[i].cmd) {
-			descr = &(dev->wireless_handlers->private_args[i]);
-			break;
-		}
-	if (descr == NULL)
-		return -EOPNOTSUPP;
-
-#ifdef WE_RTNETLINK_DEBUG
-	printk(KERN_DEBUG "%s (WE.r) : Found private handler for 0x%04X\n",
-	       ifr->ifr_name, cmd);
-	printk(KERN_DEBUG "%s (WE.r) : Name %s, set %X, get %X\n",
-	       dev->name, descr->name, descr->set_args, descr->get_args);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-	/* Compute the size of the set arguments */
-	/* Check for sub-ioctl handler */
-	if (descr->name[0] == '\0')
-		/* Reserve one int for sub-ioctl index */
-		offset = sizeof(__u32);
-
-	/* Size of set arguments */
-	extra_size = get_priv_size(descr->set_args);
-
-	/* Does it fits in wrqu ? */
-	if ((descr->set_args & IW_PRIV_SIZE_FIXED) &&
-	   (extra_size <= IFNAMSIZ)) {
-		hdr_len = IW_EV_LCP_PK_LEN + extra_size;
-		extra_size = 0;
-	} else {
-		hdr_len = IW_EV_POINT_PK_LEN;
-	}
-
-	/* Extract fixed header from request. This is properly aligned. */
-	wrqu = (union iwreq_data *) (((char *) request) + IW_EV_LCP_PK_LEN);
-
-	/* Check if wrqu is complete */
-	if (request_len < hdr_len) {
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG
-		       "%s (WE.r) : Wireless request too short (%d)\n",
-		       dev->name, request_len);
-#endif	/* WE_RTNETLINK_DEBUG */
-		return -EINVAL;
-	}
-
-	/* Prepare the call */
-	info.cmd = cmd;
-	info.flags = 0;
-
-	/* Check if we have a pointer to user space data or not. */
-	if (extra_size == 0) {
-
-		/* No extra arguments. Trivial to handle */
-		ret = handler(dev, &info, wrqu, (char *) wrqu);
-
-	} else {
-		int	extra_len;
-
-		/* Put wrqu in the right place (skip pointer) */
-		memcpy(((char *) &wrqu_point) + IW_EV_POINT_OFF,
-		       wrqu, IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-
-		/* Does it fits within bounds ? */
-		if (wrqu_point.data.length > (descr->set_args &
-					     IW_PRIV_SIZE_MASK))
-			return -E2BIG;
-
-		/* Real length of payload */
-		extra_len = adjust_priv_size(descr->set_args, &wrqu_point);
-
-		/* Check if request is self consistent */
-		if ((request_len - hdr_len) < extra_len) {
-#ifdef WE_RTNETLINK_DEBUG
-			printk(KERN_DEBUG "%s (WE.r) : Wireless request data too short (%d)\n",
-			       dev->name, extra_size);
-#endif	/* WE_RTNETLINK_DEBUG */
-			return -EINVAL;
-		}
-
-#ifdef WE_RTNETLINK_DEBUG
-		printk(KERN_DEBUG "%s (WE.r) : Malloc %d bytes\n",
-		       dev->name, extra_size);
-#endif	/* WE_RTNETLINK_DEBUG */
-
-		/* Always allocate for max space. Easier, and won't last
-		 * long... */
-		extra = kmalloc(extra_size, GFP_KERNEL);
-		if (extra == NULL)
-			return -ENOMEM;
-
-		/* Copy extra in aligned buffer */
-		memcpy(extra, ((char *) request) + hdr_len, extra_len);
-
-		/* Call the handler */
-		ret = handler(dev, &info, &wrqu_point, extra);
-
-		/* Cleanup - I told you it wasn't that long ;-) */
-		kfree(extra);
-	}
-
-	/* Call commit handler if needed and defined */
-	if (ret == -EIWCOMMIT)
-		ret = call_commit_handler(dev);
-
-	return ret;
-}
-
-/* ---------------------------------------------------------------- */
-/*
- * Main RtNetlink dispatcher. Called from the main networking code
- * (do_getlink() in net/core/rtnetlink.c).
- * Check the type of Request and call the appropriate wrapper...
- */
-int wireless_rtnetlink_get(struct net_device *	dev,
-			   char *		data,
-			   int			len,
-			   char **		p_buf,
-			   int *		p_len)
-{
-	struct iw_event *	request = (struct iw_event *) data;
-	iw_handler		handler;
-
-	/* Check length */
-	if (len < IW_EV_LCP_PK_LEN) {
-		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request too short (%d)\n",
-		       dev->name, len);
-		return -EINVAL;
-	}
-
-	/* ReCheck length (len may have padding) */
-	if (request->len > len) {
-		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request len invalid (%d-%d)\n",
-		       dev->name, request->len, len);
-		return -EINVAL;
-	}
-
-	/* Only accept GET requests in here */
-	if (!IW_IS_GET(request->cmd))
-		return -EOPNOTSUPP;
-
-	/* If command is `get the encoding parameters', check if
-	 * the user has the right to do it */
-	if (request->cmd == SIOCGIWENCODE ||
-	    request->cmd == SIOCGIWENCODEEXT) {
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-	}
-
-	/* Special cases */
-	if (request->cmd == SIOCGIWSTATS)
-		/* Get Wireless Stats */
-		return rtnetlink_standard_get(dev,
-					      request,
-					      request->len,
-					      &iw_handler_get_iwstats,
-					      p_buf, p_len);
-	if (request->cmd == SIOCGIWPRIV) {
-		/* Check if we have some wireless handlers defined */
-		if (dev->wireless_handlers == NULL)
-			return -EOPNOTSUPP;
-		/* Get Wireless Stats */
-		return rtnetlink_standard_get(dev,
-					      request,
-					      request->len,
-					      &iw_handler_get_private,
-					      p_buf, p_len);
-	}
-
-	/* Basic check */
-	if (!netif_device_present(dev))
-		return -ENODEV;
-
-	/* Try to find the handler */
-	handler = get_handler(dev, request->cmd);
-	if (handler != NULL) {
-		/* Standard and private are not the same */
-		if (request->cmd < SIOCIWFIRSTPRIV)
-			return rtnetlink_standard_get(dev,
-						      request,
-						      request->len,
-						      handler,
-						      p_buf, p_len);
-		else
-			return rtnetlink_private_get(dev,
-						     request,
-						     request->len,
-						     handler,
-						     p_buf, p_len);
-	}
-
-	return -EOPNOTSUPP;
-}
-
-/* ---------------------------------------------------------------- */
-/*
- * Main RtNetlink dispatcher. Called from the main networking code
- * (do_setlink() in net/core/rtnetlink.c).
- * Check the type of Request and call the appropriate wrapper...
- */
-int wireless_rtnetlink_set(struct net_device *	dev,
-			   char *		data,
-			   int			len)
-{
-	struct iw_event *	request = (struct iw_event *) data;
-	iw_handler		handler;
-
-	/* Check length */
-	if (len < IW_EV_LCP_PK_LEN) {
-		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request too short (%d)\n",
-		       dev->name, len);
-		return -EINVAL;
-	}
-
-	/* ReCheck length (len may have padding) */
-	if (request->len > len) {
-		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request len invalid (%d-%d)\n",
-		       dev->name, request->len, len);
-		return -EINVAL;
-	}
-
-	/* Only accept SET requests in here */
-	if (!IW_IS_SET(request->cmd))
-		return -EOPNOTSUPP;
-
-	/* Basic check */
-	if (!netif_device_present(dev))
-		return -ENODEV;
-
-	/* New driver API : try to find the handler */
-	handler = get_handler(dev, request->cmd);
-	if (handler != NULL) {
-		/* Standard and private are not the same */
-		if (request->cmd < SIOCIWFIRSTPRIV)
-			return rtnetlink_standard_set(dev,
-						      request,
-						      request->len,
-						      handler);
-		else
-			return rtnetlink_private_set(dev,
-						     request,
-						     request->len,
-						     handler);
-	}
-
-	return -EOPNOTSUPP;
-}
-#endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
-
 
 /************************* EVENT PROCESSING *************************/
 /*
diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index 1863c0b..a228d56 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -14,13 +14,3 @@ config WIRELESS_EXT
 
 	  Say N (if you can) unless you know you need wireless
 	  extensions for external modules.
-
-config NET_WIRELESS_RTNETLINK
-	bool "Wireless Extension API over RtNetlink"
-	depends on WIRELESS_EXT
-	---help---
-	  Support the Wireless Extension API over the RtNetlink socket
-	  in addition to the traditional ioctl interface (selected above).
-
-	  For now, few tools use this facility, but it might grow in the
-	  future. The only downside is that it adds 4.5 kB to your kernel.
-- 
1.5.0.6

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
