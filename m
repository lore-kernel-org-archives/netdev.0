From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 17:20:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5FCB025A.8A78EF16-ON88256DD6.0006FAFE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@redhat.com, krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





So how will this guarantee that the dev is valid after the dev_put() long
enough to do the
BUG_ON() and dev->destructor code ? Won't the same panic happen ?

Any idea how the dev gets freed up ? I was still in the old 2.4 kernel mode
thinking that
dev_put does it, but it seems to be done by using the class/object stuff in
free_netdev().

Won't a driver doing a unregister followed by a free_netdev still panic the
system if we
reference the dev at a later stage (even with the put at this place) ?

thanks,

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
