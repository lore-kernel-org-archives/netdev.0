From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] network device renaming sysfs fix
Date: Fri, 15 Aug 2003 09:37:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815093724.519779e6.shemminger@osdl.org>
References: <20030815111514.GA5228@callisto.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Net-Dev <netdev@oss.sgi.com>, Mark Huth <mhuth@mvista.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Aloni <da-x@gmx.net>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030815111514.GA5228@callisto.yi.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Aug 2003 14:15:14 +0300
Dan Aloni <da-x@gmx.net> wrote:

> (repost, now will hopefully reach the mailing list)
> 
> I believe this is a better approach for fixing the sysfs renaming
> discrepancy. Later I'll also look into fixing the same issue 
> with sysctl.
> 

Yes, this is a better fix because it won't break when unregister and free are split
into seperate steps (coming soon).

But, do we really need the debug message?  
Why return an error if you already committed the change? If you get an error,
then don't rename the network device.

The class_dev kobject name is 20 chars and IFNAMSIZ is 16, so the solution
needs to truncate if new_name is not null terminated (all 16 chars long).

This seems like the best approach:

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Fri Aug 15 09:34:11 2003
+++ b/net/core/dev.c	Fri Aug 15 09:34:11 2003
@@ -2343,14 +2343,18 @@
 		case SIOCSIFNAME:
 			if (dev->flags & IFF_UP)
 				return -EBUSY;
+			ifr->ifr_newname[IFNAMSIZ-1] = '\0';
 			if (__dev_get_by_name(ifr->ifr_newname))
 				return -EEXIST;
-			memcpy(dev->name, ifr->ifr_newname, IFNAMSIZ);
-			dev->name[IFNAMSIZ - 1] = 0;
-			strlcpy(dev->class_dev.class_id, dev->name, BUS_ID_SIZE);
-			notifier_call_chain(&netdev_chain,
-					    NETDEV_CHANGENAME, dev);
-			return 0;
+			err = class_device_rename(&dev->class_dev, 
+						  ifr->ifr_newname);
+			if (!err) {
+				strlcpy(dev->name, ifr->ifr_newname, IFNAMSIZ);
+
+				notifier_call_chain(&netdev_chain,
+						    NETDEV_CHANGENAME, dev);
+			}
+			return err;
 
 		/*
 		 *	Unknown or private ioctl
