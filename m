From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: linux-wireless mailing list
Date: Thu, 4 Mar 2004 20:03:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040305040352.GA16669@bougret.hpl.hp.com>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com> <40469DA1.9090502@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FL5UXtIhxfXey3p5"
Cc: Pavel Roskin <proski@gnu.org>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40469DA1.9090502@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Mar 03, 2004 at 10:08:17PM -0500, Jeff Garzik wrote:
> 
> The wireless extensions are utility -- they work, but are not beautiful. 
>  I am presently writing the driver for the RealTek wireless card, and 
> in the process creating a small wireless driver API.  The ideal is to 
> avoid ioctls, and instead to present extensible, type-safe interfaces. 
> This is what I would like wireless extensions to morph into.

	Just to check if we are on the same page, I dusted an old
patch to add a RtNetlink API to Wireless Extensions. This completely
avoids ioctls, is type safe, and still extensible. The patch is fully
functional and tested but not finished (no support for GET and private
requests).
	Of course, it won't work on drivers using the old API, such as
orinoco.c. Don't blame me, I sent the orinoco patch to David 2 years
ago.
	Please coment on that. If this is what you want, I could
accelerate its release.

	Jean

--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="iw264_api_rtnetlink.diff"

diff -u -p linux/net/core/rtnetlink.j1.c linux/net/core/rtnetlink.c
--- linux/net/core/rtnetlink.j1.c	Thu Mar  4 16:14:02 2004
+++ linux/net/core/rtnetlink.c	Thu Mar  4 19:52:47 2004
@@ -50,6 +50,10 @@
 #include <net/udp.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
+#ifdef CONFIG_NET_RADIO
+#include <linux/wireless.h>		/* Note : will define WIRELESS_EXT */
+#include <net/iw_handler.h>
+#endif	/* CONFIG_NET_RADIO */
 
 DECLARE_MUTEX(rtnl_sem);
 
@@ -269,6 +273,16 @@ static int do_setlink(struct sk_buff *sk
 		memcpy(dev->broadcast, RTA_DATA(ida[IFLA_BROADCAST - 1]),
 		       dev->addr_len);
 	}
+
+#ifdef WIRELESS_EXT
+	if (ida[IFLA_WIRELESS - 1]) {
+		printk(KERN_DEBUG "Calling wireless stuff\n");
+		/* Device validity/presence checked in there */
+		err = wireless_process_rtnetlink(dev, RTA_DATA(ida[IFLA_WIRELESS - 1]), ida[IFLA_WIRELESS - 1]->rta_len);
+		if (err)
+			goto out;
+	}
+#endif	/* WIRELESS_EXT */
 
 	err = 0;
 
diff -u -p linux/net/core/wireless.j1.c linux/net/core/wireless.c
--- linux/net/core/wireless.j1.c	Thu Mar  4 16:13:52 2004
+++ linux/net/core/wireless.c	Thu Mar  4 18:39:49 2004
@@ -75,6 +75,7 @@
 
 /* Debugging stuff */
 #undef WE_IOCTL_DEBUG		/* Debug IOCTL API */
+#define WE_RTNETLINK_DEBUG	/* Debug RtNetlink API */
 #undef WE_EVENT_DEBUG		/* Debug Event dispatcher */
 #undef WE_SPY_DEBUG		/* Debug enhanced spy support */
 
@@ -941,6 +942,199 @@ int wireless_process_ioctl(struct ifreq 
 	}
 	/* Not reached */
 	return -EINVAL;
+}
+
+/************************ RTNETLINK SUPPORT ************************/
+/*
+ * The alternate user space API to configure all those Wireless Extensions
+ * is through RtNEtlink.
+ * This API support only the new driver API (iw_handler).
+ * This is still experimental.
+ */
+
+/* ---------------------------------------------------------------- */
+/*
+ * Wrapper to call a standard Wireless Extension handler.
+ * We do various checks and also take care of moving data between
+ * user space and kernel space.
+ */
+static inline int rtnetlink_standard_call(struct net_device *	dev,
+					  struct iw_event *	request,
+					  int			request_len,
+					  iw_handler		handler)
+{
+	const struct iw_ioctl_description *	descr = NULL;
+	unsigned int				cmd;
+	union iwreq_data *			wrqu;
+	int					hdr_len;
+	struct iw_request_info			info;
+	int					ret = -EINVAL;
+
+	/* Get the description of the IOCTL */
+	cmd = request->cmd;
+	if((cmd - SIOCIWFIRST) >= standard_ioctl_num)
+		return -EOPNOTSUPP;
+	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
+
+#ifdef WE_RTNETLINK_DEBUG
+	printk(KERN_DEBUG "%s (WE) : Found standard handler for 0x%04X\n",
+	       dev->name, cmd);
+	printk(KERN_DEBUG "%s (WE) : Header type : %d, Token type : %d, size : %d, token : %d\n", dev->name, descr->header_type, descr->token_type, descr->token_size, descr->max_tokens);
+#endif	/* WE_IOCTL_DEBUG */
+
+	/* Extract fixed header from request */
+	wrqu = (union iwreq_data *) &request->u;
+
+	/* Prepare the call */
+	info.cmd = cmd;
+	info.flags = 0;
+
+	/* Check if wrqu is complete */
+	hdr_len = event_type_size[descr->header_type];
+	if(request_len < hdr_len) {
+#ifdef WE_RTNETLINK_DEBUG
+		printk(KERN_DEBUG "%s (WE) : Wireless request too short (%d)\n",
+		       dev->name, request_len);
+		return -EINVAL;
+#endif	/* WE_RTNETLINK_DEBUG */
+	}
+
+	/* Check if we have extra data in the request or not */
+	if(descr->header_type != IW_HEADER_TYPE_POINT) {
+
+		/* No extra arguments. Trivial to handle */
+		ret = handler(dev, &info, wrqu, NULL);
+
+#ifdef WE_SET_EVENT
+		/* Generate an event to notify listeners of the change */
+		if((descr->flags & IW_DESCR_FLAG_EVENT) &&
+		   ((ret == 0) || (ret == -EIWCOMMIT)))
+			wireless_send_event(dev, cmd, wrqu, NULL);
+#endif	/* WE_SET_EVENT */
+	} else {
+		char *	extra;
+		int	extra_len;
+
+		/* Check what user space is giving us */
+		if(IW_IS_SET(cmd)) {
+			/* Check if number of token fits within bounds */
+			if(wrqu->data.length > descr->max_tokens)
+				return -E2BIG;
+			if(wrqu->data.length < descr->min_tokens)
+				return -EINVAL;
+		}
+
+#ifdef WE_RTNETLINK_DEBUG
+		printk(KERN_DEBUG "%s (WE) : Malloc %d bytes\n",
+		       dev->name, descr->max_tokens * descr->token_size);
+#endif	/* WE_IOCTL_DEBUG */
+
+		/* Always allocate for max space. Easier, and won't last
+		 * long... */
+		extra = kmalloc(descr->max_tokens * descr->token_size,
+				GFP_KERNEL);
+		if (extra == NULL) {
+			return -ENOMEM;
+		}
+
+		/* If it is a SET, copy data to the aligned buffer */
+		if(IW_IS_SET(cmd) && (wrqu->data.length != 0)) {
+
+			/* Length of extra (what's after the fixed header) */
+			extra_len = request_len - hdr_len;
+
+			/* Check if we have enough of it */
+			if(extra_len < (wrqu->data.length *
+					descr->token_size)) {
+#ifdef WE_RTNETLINK_DEBUG
+				printk(KERN_DEBUG "%s (WE) : Wireless request data too short (%d)\n",
+				       dev->name, extra_len);
+				return -EINVAL;
+#endif	/* WE_RTNETLINK_DEBUG */
+			}
+
+			memcpy(extra, ((char *) request) + hdr_len,
+			       extra_len);
+		}
+
+		/* Call the handler */
+		ret = handler(dev, &info, wrqu, extra);
+
+		/* If we have something to return to the user */
+		if (!ret && IW_IS_GET(cmd)) {
+			// TODO
+		}
+
+#ifdef WE_SET_EVENT
+		/* Generate an event to notify listeners of the change */
+		if((descr->flags & IW_DESCR_FLAG_EVENT) &&
+		   ((ret == 0) || (ret == -EIWCOMMIT))) {
+			if(descr->flags & IW_DESCR_FLAG_RESTRICT)
+				/* If the event is restricted, don't
+				 * export the payload */
+				wireless_send_event(dev, cmd, wrqu, NULL);
+			else
+				wireless_send_event(dev, cmd, wrqu,
+						    extra);
+		}
+#endif	/* WE_SET_EVENT */
+
+		/* Cleanup - I told you it wasn't that long ;-) */
+		kfree(extra);
+	}
+
+	/* Call commit handler if needed and defined */
+	if(ret == -EIWCOMMIT)
+		ret = call_commit_handler(dev);
+
+	return ret;
+}
+
+/* ---------------------------------------------------------------- */
+/*
+ * Main RtNetlink dispatcher. Called from the main networking code
+ * (do_setlink() in net/core/rtnetlink.c).
+ * Check the type of Request and call the appropriate wrapper...
+ */
+int wireless_process_rtnetlink(struct net_device *	dev,
+			       char *			data,
+			       int			len)
+{
+	struct iw_event *	request = (struct iw_event *) data;
+	iw_handler		handler;
+
+	/* Check length */
+	if(len < IW_EV_LCP_LEN) {
+		printk(KERN_DEBUG "%s (WE) : RtNetlink request too short (%d)\n",
+		       dev->name, len);
+		return -EINVAL;
+	}
+
+	/* ReCheck length (len may have padding) */
+	if(request->len > len) {
+		printk(KERN_DEBUG "%s (WE) : RtNetlink request len invalid (%d-%d)\n",
+		       dev->name, request->len, len);
+		return -EINVAL;
+	}
+
+	// TODO : Handle special cases
+
+	/* Basic check */
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	/* New driver API : try to find the handler */
+	handler = get_handler(dev, request->cmd);
+	if(handler != NULL) {
+		/* Standard and private are not the same */
+		if(request->cmd < SIOCIWFIRSTPRIV)
+			return rtnetlink_standard_call(dev,
+						       request,
+						       request->len,
+						       handler);
+		// TODO : support for Private Requests
+	}
+	return -EOPNOTSUPP;
 }
 
 /************************* EVENT PROCESSING *************************/

--FL5UXtIhxfXey3p5--
