From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 12:13:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617191338.GD32216@bougret.hpl.hp.com>
References: <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <40D1E24C.8090802@pobox.com> <20040617185815.GB32216@bougret.hpl.hp.com> <40D1EAD9.6090403@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Gertjan van Wingerde <gwingerde@home.nl>,
        sfeldma@pobox.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D1EAD9.6090403@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 03:02:49PM -0400, Jeff Garzik wrote:
> Jean Tourrilhes wrote:
> >On Thu, Jun 17, 2004 at 02:26:20PM -0400, Jeff Garzik wrote:
> >
> >>Note that the above is only a first step.  Through the standard Linux 
> >>development process -- evolution -- each hook can be pared down to 
> >>precisely what each call needs.  The above allows for a quick transition 
> >>of drivers, while keeping them working.
> >>
> >>	Jeff
> >
> >
> >	Have you looked at the patch I sent you ? In which way does it
> >fails to meet your need ?
> 
> 
> The three major problems I listed in a previous email are still 
> present...

	Are we talking of the same patch ? I'm talking of this patch :
http://marc.theaimsgroup.com/?l=linux-netdev&m=108749580004668&w=2
	I reattached the patch below. It's short enough.

>  Also there is a fourth -- WE doesn't work 100% when you have 
> a 32-bit userland and a 64-bit kernel.

	Since when ? What made you change your mind ?
	Please check :
http://marc.theaimsgroup.com/?l=linux-netdev&m=107894322418086&w=2

> 	Jeff

	Jean

-----------------------------------------------------------

--- linux/include/net/iw_handler.j1.h	Thu Jun 17 10:16:22 2004
+++ linux/include/net/iw_handler.h	Thu Jun 17 10:17:24 2004
@@ -301,6 +301,9 @@ typedef int (*iw_handler)(struct net_dev
  */
 struct iw_handler_def
 {
+	/* Wireless Ops definitions */
+	struct wireless_ops *	wireless_ops;
+
 	/* Number of handlers defined (more precisely, index of the
 	 * last defined handler + 1) */
 	__u16			num_standard;
--- linux/net/core/wireless.j1.c	Thu Jun 17 10:08:45 2004
+++ linux/net/core/wireless.c	Thu Jun 17 10:28:59 2004
@@ -343,8 +343,14 @@ static inline iw_handler get_handler(str
 	if(dev->wireless_handlers == NULL)
 		return NULL;
 
-	/* Try as a standard command */
 	index = cmd - SIOCIWFIRST;
+
+	/* Try as wireless_ops */
+	if((index < (SIOCIWFIRSTPRIV - SIOCIWFIRST)) &&
+	   (dev->wireless_handlers->wireless_ops != NULL))
+		return &iw_process_wireless_ops;
+
+	/* Try as a standard command */
 	if(index < dev->wireless_handlers->num_standard)
 		return dev->wireless_handlers->standard[index];
 
@@ -1372,3 +1378,41 @@ EXPORT_SYMBOL(iw_handler_set_spy);
 EXPORT_SYMBOL(iw_handler_set_thrspy);
 EXPORT_SYMBOL(wireless_send_event);
 EXPORT_SYMBOL(wireless_spy_update);
+
+/*********************** WIRELESS OPS SUPPORT ***********************/
+/*
+ * Documentation to be added by Jeff ;-)
+ */
+
+/*------------------------------------------------------------------*/
+/*
+ * Generic Wireless Handler to process Wireless Ops
+ */
+int iw_process_wireless_ops(struct net_device *	dev,
+			    struct iw_request_info *info,
+			    union iwreq_data *	wrqu,
+			    char *		extra)
+{
+	struct wireless_ops *	ops;
+
+	/* Already verified != NULL in get_handler() */
+	ops = dev->wireless_handlers->wireless_ops;
+
+	/* Just do it */
+	switch(info->cmd)
+	{
+	case SIOCSIWESSID:
+		/* Set ESSID */
+		if(ops->set_essid != NULL)
+			return ops->set_essid(dev, extra, wrqu->essid.length,
+					      wrqu->essid.flags);
+	case SIOCGIWESSID:
+		/* Get ESSID */
+		if(ops->get_essid != NULL)
+			return ops->get_essid(dev, extra, &wrqu->essid.length,
+					      &wrqu->essid.flags);
+	default:
+	}
+	return -EOPNOTSUPP;
+}
+
