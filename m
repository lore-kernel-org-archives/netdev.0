From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Thu, 6 Nov 2003 13:07:57 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311061305550.1296-100000@DYN318430BLD.beaverton.ibm.com>
References: <20031106115935.0cd56745.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Krishna Kumar <kumarkr@us.ibm.com>, <shemminger@osdl.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031106115935.0cd56745.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I think I found the problem in the link event code. linkwatch_event()
calls rtnl_unlock() when it gets an event (UNREGISTER) for the device
going down. But this gets called before the device unregister gets called,
via the rmmod/pci_device_remove), and frees up the dev. Later the device
unregister code panics the system.

I also noticed that this panic happens for e100 but not for the 3com
driver. 3com doesn't generate events for up/down using the linkwatch.

I tested with the following patch, and the panic disappeared (the
device shutdown properly). Dave, any need for rtnl_unlock() in this
code ?

Thanks,

- KK

diff -ruN linux-2.6.0-test9-bk9/net/core/link_watch.c linux-2.6.0-test9-bk9.new/net/core/link_watch.c
--- linux-2.6.0-test9-bk9/net/core/link_watch.c	2003-11-06 12:26:30.000000000 -0800
+++ linux-2.6.0-test9-bk9.new/net/core/link_watch.c	2003-11-06 12:25:41.000000000 -0800
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/if.h>
+#include <net/sock.h>
 #include <linux/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
@@ -89,9 +90,11 @@
 	linkwatch_nextevent = jiffies + HZ;
 	clear_bit(LW_RUNNING, &linkwatch_flags);

-	rtnl_lock();
+	rtnl_shlock();
+	rtnl_exlock();
 	linkwatch_run_queue();
-	rtnl_unlock();
+	rtnl_exunlock();
+	rtnl_shunlock();
 }



On Thu, 6 Nov 2003, David S. Miller wrote:

> On Thu, 6 Nov 2003 11:58:24 -0800
> Krishna Kumar <kumarkr@us.ibm.com> wrote:
>
> > When unregister_netdev() is called by the driver, it first calls
> > unregister_netdevice() which
> > drops it's last ref to the dev, making it zero. unregister_netdev() then
> > calls rtnl_unlock() which
> > calls netdev_run_todo(), which calls netdev_wait_allrefs() and only after
> > that succeeds,
> > does the driver do a free_netdev(). So the dev should not be freed while
> > the wait_ref() is
> > executing, and the original code looks correct.
>
> That's correct.
>
> > I don't know if it is some corruption on my system, some hardware problem ?
> > I will look
> > some more, also try to get a different machine.
>
> It could be some 'user after free' or similar issue.
> Just an idea of something else to look for.
>
> My earlier comments about "putting to zero multiple times" were
> misguided, I forgot that these days dev_put() just decrements the
> count and does not do anything special when the count reaches zero.
>
>
