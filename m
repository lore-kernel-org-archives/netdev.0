From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Sat, 11 Sep 2004 15:44:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911134409.GA21181@postel.suug.ch>
References: <20040910195003.GA13912@bougret.hpl.hp.com> <20040910200644.GJ20088@postel.suug.ch> <20040910201302.GA16556@bougret.hpl.hp.com> <20040910202235.GK20088@postel.suug.ch> <20040910203203.GA17078@bougret.hpl.hp.com> <20040910204348.GL20088@postel.suug.ch> <1094857082.1041.19.camel@jzny.localdomain> <20040910231726.GP20088@postel.suug.ch> <1094868070.1042.77.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1094868070.1042.77.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1094868070.1042.77.camel@jzny.localdomain> 2004-09-10 22:01
> On Fri, 2004-09-10 at 19:17, Thomas Graf wrote:
> 
> > There is one remaining problem, currently, changes via rtnetlink will
> > result in multiple notifies being sent out because NETDEV_CHANGEMTU
> > and NETDEV_CHANGENAME are invoked as well and result in a netlink
> > message. Changing them to not do anything in rtnetlink context
> > would solve it but we would lose the notify if the change was made
> > via ioctl.
> > 
> Are you changing MTU and NAME at the same time?

Possibly, I change everything the user requests me to do.

> Valid to receive the two updates i would think in that case.

That's not the problem, the problem is that you may receive
more updates than requested changes. Let's assume you're changing
the MTU using IFLA_MTU and it succeeds. dev_set_mtu will send
out the first update, at the end the do_setlink will send
out another update.

Changing MTU and ifname would result in 3 updates:

 1) RTM_NEWLINK with updated mtu (old name)
 2) RTM_NEWLINK with mtu and name updated
 3) same again as 2)

I personally have no problem with the current behaviour but maybe
we should clean this up a bit.

Suggestion:
 Send out a notify for every change we make. This can result
 in 7 updates being sent out. It would allow the application
 to see how far the kernel was successful quite easly or
 do a revision control and switch back to older configurations.

Something like this:

--- linux-2.6.9-rc1-bk15.orig/net/core/rtnetlink.c	2004-09-11 15:39:06.000000000 +0200
+++ linux-2.6.9-rc1-bk15/net/core/rtnetlink.c	2004-09-11 15:39:37.000000000 +0200
@@ -295,6 +295,7 @@
 
 		if (err)
 			goto out;
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	}
 
 	if (ida[IFLA_ADDRESS - 1]) {
@@ -312,6 +313,7 @@
 		err = dev->set_mac_address(dev, RTA_DATA(ida[IFLA_ADDRESS - 1]));
 		if (err)
 			goto out;
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	}
 
 	if (ida[IFLA_BROADCAST - 1]) {
@@ -319,6 +321,7 @@
 			goto out;
 		memcpy(dev->broadcast, RTA_DATA(ida[IFLA_BROADCAST - 1]),
 		       dev->addr_len);
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	}
 
 	if (ida[IFLA_MTU - 1]) {
@@ -336,6 +339,7 @@
 			goto out;
 
 		dev->tx_queue_len = *((u32 *) RTA_DATA(ida[IFLA_TXQLEN - 1]));
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	}
 
 	if (ida[IFLA_WEIGHT - 1]) {
@@ -343,6 +347,7 @@
 			goto out;
 
 		dev->weight = *((u32 *) RTA_DATA(ida[IFLA_WEIGHT - 1]));
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 	}
 
 	if (ida[IFLA_IFNAME - 1]) {
@@ -365,8 +370,6 @@
 	err = 0;
 
 out:
-	if (!err)
-		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 
 	dev_put(dev);
 	return err;
