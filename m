From: Eric Lemoine <Eric.Lemoine@Sun.COM>
Subject: simple change to qdisc_restart()
Date: Tue, 20 May 2003 10:22:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520082217.GC978@udine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Eric.Lemoine@Sun.COM
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Any comments regarding the following patch?

Thx.


--- sch_generic.c.old   Tue May 20 09:11:25 2003
+++ sch_generic.c       Tue May 20 10:16:11 2003
@@ -77,6 +77,7 @@
 int qdisc_restart(struct net_device *dev)
 {
        struct Qdisc *q = dev->qdisc;
+       int sched_flag = 1;
        struct sk_buff *skb;

        /* Dequeue packet */
@@ -120,6 +121,12 @@
                                        printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
                                return -1;
                        }
+
+                       /* At this point we know for sure that someone 
+                        * is taking care of this Qdisc for us so we 
+                        * do not need to schedule tx softirq.
+                        */
+                       sched_flag = 0;
                        netdev_rx_stat[smp_processor_id()].cpu_collision++;
                }

@@ -134,7 +141,8 @@
                 */

                q->ops->requeue(skb, q);
-               netif_schedule(dev);
+               if (sched_flag)
+                       netif_schedule(dev);
                return 1;
        }
        return q->q.qlen
-- 
Eric
