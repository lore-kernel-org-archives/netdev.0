From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 10:47:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617174717.GA30460@bougret.hpl.hp.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D0D265.3070804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 07:06:13PM -0400, Jeff Garzik wrote:
> 
> It's not Jeff's weird personal preference that iw_handler be killed... 
> type-opaque interfaces cause real problems.  A good C programmer should 
> very, very rarely use type-casting.

	Yes, I know that I am really a perverse mind and I did
designed the API this way only to make your life miserable and to
sabotage the Linux kernel.

	As a matter of fact, I tried the strongly type approach you
advocate and find its kernel overhead not acceptable. Note that people
not using wireless have to suffer from this bloat, and wireless
extensions are used in embeeded platforms such as OpenAP, iPaq and
Zaurus where footprint matters.
	There was additional benefits, such as the ability to use a
single handler for multiple commands (horror !), and I know of a few
driver using this feature.

	Now, it seems that you clearly have not understood my
proposal, so I made a little patch, hopping that it will clear the
obvious miscommunication. Patch is below.
	I hope you will notice that the changes are fairly trivial and
clean. And it's backward compatible.
	I also want you to notice that the code is quasi optimal,
compared to rewritting the API, there is only one additional function
call (plus the backward compatibility). I know you won't believe me,
so verify that yourself. I think this is a small price to pay for
keeping backward compatibility with all those drivers outside the
kernel (see my web page).

> 	Jeff

	Now, I will have to excuse myself, and let you guys argue over
my patch. I have a full time job and a new baby that require my
dedicated attention, plus a huge backlog of Linux stuff (WTool
release, WPA, RtNetlink stuff, IrDA patches...). I don't have the
luxury of having Linux as my primary occupation.
	Have fun...

	Jean

--------------------------------------------------------

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
