From: Jason Lunz <lunz@falooley.org>
Subject: Re: iwlwifi initial bugs/thanks
Date: Tue, 13 Feb 2007 14:13:13 -0500
Message-ID: <20070213191313.GA2427@metaxa.reflex>
References: <1171382436.12035.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ipw3945-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Ben Gamari <ben@mw0.ath.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:39345 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbXBMUD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 15:03:59 -0500
Content-Disposition: inline
In-Reply-To: <1171382436.12035.38.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 04:00:36PM +0000, Ben Gamari wrote:
> That being said, now come the problems. When I first loaded the driver,
> I found that it had created two interfaces as mentioned in earlier
> threads. On my machine these are named eth1 and wlan0_rename (can
> someone confirm what the names are supposed to be and which interface
> does what?). Strangely, it appears that wlan0_rename is the actual
> wireless adapter as evidenced by the attached console session. In that

The "_rename" suffix is an indication that you have udev rules that are
attempting to assign the same name to two different netdevs. Try to
disable udev device renaming, or make the rules more specific.

The attached kernel patch makes it easier to figure out what udev is
trying to do in situations like yours. It keeps getting rejected from
linux upstream, but that could change with enough encouragement.

Jason


---

Keep track about which network interface names were renamed after the
network device driver printed its banner.

Signed-off-by: Olaf Hering <olaf@aepfle.de>

---
 net/core/dev.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6.20-uml/net/core/dev.c
===================================================================
--- linux-2.6.20-uml.orig/net/core/dev.c
+++ linux-2.6.20-uml/net/core/dev.c
@@ -754,7 +754,11 @@
 	else if (__dev_get_by_name(newname))
 		return -EEXIST;
 	else
+	{
+		if (strncmp(newname, dev->name, IFNAMSIZ))
+			printk(KERN_INFO "%s renamed to %s\n", dev->name, newname);
 		strlcpy(dev->name, newname, IFNAMSIZ);
+	}
 
 	err = class_device_rename(&dev->class_dev, dev->name);
 	if (!err) {
