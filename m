From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Thu, 6 Nov 2003 11:58:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5A6B1679.D88C275D-ON88256DD6.006CF971@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@redhat.com, krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Actually, even the original code looks good, and if that panic'd, the
following won't change
that (verified it also).

When unregister_netdev() is called by the driver, it first calls
unregister_netdevice() which
drops it's last ref to the dev, making it zero. unregister_netdev() then
calls rtnl_unlock() which
calls netdev_run_todo(), which calls netdev_wait_allrefs() and only after
that succeeds,
does the driver do a free_netdev(). So the dev should not be freed while
the wait_ref() is
executing, and the original code looks correct.

I don't know if it is some corruption on my system, some hardware problem ?
I will look
some more, also try to get a different machine.

- KK




|---------+---------------------------->
|         |           Stephen Hemminger|
|         |           <shemminger@osdl.|
|         |           org>             |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           11/05/2003 05:09 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       Krishna Kumar/Beaverton/IBM@IBMUS                                                               |
  |       cc:       davem@redhat.com, krkumar@us.ltcfwd.linux.ibm.com, netdev@oss.sgi.com                           |
  |       Subject:  Re: [PATCH] panic during unregister_netdevice()                                                 |
  |                                                                                                                 |
  >-----------------------------------------------------------------------------------------------------------------|




Try this. Instead of dropping the last reference in unregister, it does it
after all other references are gone (sort of like the old 2.4 code).

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c           Wed Nov  5 17:04:57 2003
+++ b/net/core/dev.c           Wed Nov  5 17:04:57 2003
@@ -2743,7 +2743,7 @@
             unsigned long rebroadcast_time, warning_time;

             rebroadcast_time = warning_time = jiffies;
-            while (atomic_read(&dev->refcnt) != 0) {
+            while (atomic_read(&dev->refcnt) > 1) {
                         if (time_after(jiffies, rebroadcast_time + 1 *
HZ)) {
                                     rtnl_shlock();
                                     rtnl_exlock();
@@ -2838,6 +2838,7 @@
                                     dev->reg_state = NETREG_UNREGISTERED;

                                     netdev_wait_allrefs(dev);
+                                    dev_put(dev);

                                     /* paranoia */
                                     BUG_ON(atomic_read(&dev->refcnt));
@@ -2974,7 +2975,6 @@
             /* Finish processing unregister after unlock */
             net_set_todo(dev);

-            dev_put(dev);
             return 0;
 }
