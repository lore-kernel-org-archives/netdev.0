From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Sun, 12 Sep 2004 00:06:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911220614.GF21181@postel.suug.ch>
References: <20040910200644.GJ20088@postel.suug.ch> <20040910201302.GA16556@bougret.hpl.hp.com> <20040910202235.GK20088@postel.suug.ch> <20040910203203.GA17078@bougret.hpl.hp.com> <20040910204348.GL20088@postel.suug.ch> <1094857082.1041.19.camel@jzny.localdomain> <20040910231726.GP20088@postel.suug.ch> <1094868070.1042.77.camel@jzny.localdomain> <20040911134409.GA21181@postel.suug.ch> <1094932793.2344.82.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1094932793.2344.82.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1094932793.2344.82.camel@jzny.localdomain> 2004-09-11 15:59
> So my suggestion is making your code the exception.
> i.e something along the lines of:
> 
> addrchg = 1;
> 
> if (mtu/weight/name related)
> 	addrchng = 0;
> if (!err & addrchang)
> 	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);

OK, however I'd prefer to invert the concept. See patch
below. This would send out the following updates:

ififlags - NETDEV_(UP|DOWN) if IFF_UP has changed
IFLA_MAP - none
IFLA_ADDRESS|IFLA_BROADCAST - NETDEV_CHANGEADDR
IFLA_MTU - NETDEV_CHANGEMTU
IFLA_WEIGHT - none
IFLA_IFNAME - NETDEVCHANGENAME

PATCH:
Only send NETDEV_CHANGEADDR notifies for address and broadcast changes.
Notify is also sent out if only one of the 2 changes is successful.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc1-bk18.orig/net/core/rtnetlink.c	2004-09-11 16:30:30.000000000 +0200
+++ linux-2.6.9-rc1-bk18/net/core/rtnetlink.c	2004-09-11 23:30:05.000000000 +0200
@@ -265,7 +265,7 @@
 	struct ifinfomsg  *ifm = NLMSG_DATA(nlh);
 	struct rtattr    **ida = arg;
 	struct net_device *dev;
-	int err;
+	int err, send_addr_notify = 0;
 
 	dev = dev_get_by_index(ifm->ifi_index);
 	if (!dev)
@@ -312,6 +312,7 @@
 		err = dev->set_mac_address(dev, RTA_DATA(ida[IFLA_ADDRESS - 1]));
 		if (err)
 			goto out;
+		send_addr_notify = 1;
 	}
 
 	if (ida[IFLA_BROADCAST - 1]) {
@@ -319,6 +320,7 @@
 			goto out;
 		memcpy(dev->broadcast, RTA_DATA(ida[IFLA_BROADCAST - 1]),
 		       dev->addr_len);
+		send_addr_notify = 1;
 	}
 
 	if (ida[IFLA_MTU - 1]) {
@@ -365,7 +367,7 @@
 	err = 0;
 
 out:
-	if (!err)
+	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 
 	dev_put(dev);


> Also note, the semantics of netlink are all-or-nothing transaction. i.e
> if one of the things requested for fails then you undo the rest. We can
> probably loosely say that unles the ATOMIC flag is set you dont need to
> undo that .. something to think about (summary is you probably dont want
> to send progress update to user space unless the transaction is
> successful; you however want to report progress of where failure happens
> - as we are discussing at the moment in the error code thread).

Agreed, I think undo should happen from user space though. In the
example of do_setlink, you can see that while it would be quite easy to
do the sanity checks before actually doing something you can't catch
all errors if you don't want to implement the name/mtu/addr change
routines yourself. Keeping in mind that those sanity checks will
probably only fail during the development of a application it doesn't
really help. That's why I implemented it this way.

I'm experimenting with a commit/fallback netlink library which basically
fetches the subject of change and stores the netlink message to be used
in case of fallback. NLM_F_ATOMIC makes it even more useable but is
quite expensive. A netlink change daemon would probably solve the
problem better.
