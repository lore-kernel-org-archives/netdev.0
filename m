From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Sat, 11 Sep 2004 01:17:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910231726.GP20088@postel.suug.ch>
References: <20040910195003.GA13912@bougret.hpl.hp.com> <20040910200644.GJ20088@postel.suug.ch> <20040910201302.GA16556@bougret.hpl.hp.com> <20040910202235.GK20088@postel.suug.ch> <20040910203203.GA17078@bougret.hpl.hp.com> <20040910204348.GL20088@postel.suug.ch> <1094857082.1041.19.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1094857082.1041.19.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1094857082.1041.19.camel@jzny.localdomain> 2004-09-10 18:58
> On Fri, 2004-09-10 at 16:43, Thomas Graf wrote:
> > Currently call_netdevice_notifiers is called and sends out a
> > RTM_NEWLINK message with the new interface name to everyone
> > wanting to be notified. However, ifi_change is kept to 0
> > so far, which means you have to look what has changed yourself. I'm
> > not sure if this can be changed without too much troubles but
> > I will look into it.
> 
> I missed the RTM_NEWLINK part. It is easier to just keep it that way and
> make sure it is well documented as so. It may not be trivial (as an
> example all the inetdev name attributes change - look at inetdev_event).
> So suggestion is to leave it to user space to find more details about
> the event.

I agree, most applications will hold a cache of all links, like iproute2
is doing, and just update the cache.

There is one remaining problem, currently, changes via rtnetlink will
result in multiple notifies being sent out because NETDEV_CHANGEMTU
and NETDEV_CHANGENAME are invoked as well and result in a netlink
message. Changing them to not do anything in rtnetlink context
would solve it but we would lose the notify if the change was made
via ioctl.

The patch below would fixes the multiple notifies issue but prevents
notification upon ioctl via rtnetlink.. Any ideas how to work around
this other than not using dev_change_name and dev_set_mtu?

--- linux-2.6.9-rc1-bk15.orig/net/core/rtnetlink.c	2004-09-08 18:33:42.000000000 +0200
+++ linux-2.6.9-rc1-bk15/net/core/rtnetlink.c	2004-09-11 01:06:29.000000000 +0200
@@ -607,6 +626,8 @@
 		break;
 	case NETDEV_CHANGE:
 	case NETDEV_GOING_DOWN:
+	case NETDEV_CHANGEMTU:
+	case NETDEV_CHANGENAME:
 		break;
 	default:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
