From: Song Wang <wsonguci@yahoo.com>
Subject: [PATCH 2.6.9-rc1] handle error msg "driver changed  get_stats after register"
Date: Fri, 10 Sep 2004 17:55:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911005507.62262.qmail@web40007.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch is against 2.6.9-rc1.

In net/core/dev.c: dev_open

  if (get_stats_changed(dev) && net_ratelimit()) {
                printk(KERN_ERR "%s: driver changed
get_stats after register\n",
                       dev->name);
        }

static inline int get_stats_changed(struct net_device
*dev)
{
        int changed = dev->last_stats !=
dev->get_stats;
        dev->last_stats = dev->get_stats;
        return changed;
}

get_stats_changed checks if dev->last_stats has been
changed after the registration when opening the net
device. However, the initialization of dev->last_stats
is done in net/core/net-sysfs.c, which is only 
compiled when CONFIG_SYSFS is enabled.

So if we don't enable CONFIG_SYSFS (for example,
embedded system may not need it for saving space.),
all the network device drivers will have an error
message "driver changed get_stats after register"
printed on the console when you try to ifconfig it,
because dev->last_stats is never initialized.

The following patch adds the initialization of
dev->last_stats in register_netdevice function.

-Song

diff -Naur linux-2.6.9-rc1/net/core/dev.c
linux-2.6.9-rc1.mod/net/core/dev.c
--- linux-2.6.9-rc1/net/core/dev.c      2004-08-31
18:51:06.000000000 -0700
+++ linux-2.6.9-rc1.mod/net/core/dev.c  2004-08-31
19:11:35.407452369 -0700
@@ -2872,6 +2872,8 @@

        dev->iflink = -1;

+       dev->last_stats = dev->get_stats;
+
        /* Init, if this function is available */
        if (dev->init) {
                ret = dev->init(dev);






		
__________________________________
Do you Yahoo!?
Yahoo! Mail - 50x more storage than other providers!
http://promotions.yahoo.com/new_mail
