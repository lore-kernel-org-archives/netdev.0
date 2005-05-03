From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost (take 2)
Date: Wed, 04 May 2005 01:28:24 +0200
Message-ID: <42780918.10001@tpack.net>
References: <4276B13F.2040103@tpack.net> <20050503100306.GB29788@gondor.apana.org.au> <4277FC16.4050307@tpack.net> <20050503231023.GA18323@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060507010509040804020203"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050503231023.GA18323@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060507010509040804020203
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Thanks Tommy.  This version looks good to me.  BTW, you probably
> should add a Signed-off-by line.

Sigh. I remembered on all but the final patch ...
Thanks for helping out.

Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>

--------------060507010509040804020203
Content-Type: text/plain;
 name="carrier-5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="carrier-5.patch"

diff -ru linux-2.6.12-rc3/net/core/link_watch.c linux-2.6.12-work/net/core/link_watch.c
--- linux-2.6.12-rc3/net/core/link_watch.c	2005-03-04 09:55:42.000000000 +0100
+++ linux-2.6.12-work/net/core/link_watch.c	2005-05-02 22:40:59.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/netdevice.h>
 #include <linux/if.h>
 #include <net/sock.h>
+#include <net/pkt_sched.h>
 #include <linux/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
@@ -74,6 +75,12 @@
 		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
 
 		if (dev->flags & IFF_UP) {
+			if (netif_carrier_ok(dev)) {
+				WARN_ON(dev->qdisc_sleeping == &noop_qdisc);
+				dev_activate(dev);
+			} else
+				dev_deactivate(dev);
+
 			netdev_state_change(dev);
 		}
 
diff -ru linux-2.6.12-rc3/net/sched/sch_generic.c linux-2.6.12-work/net/sched/sch_generic.c
--- linux-2.6.12-rc3/net/sched/sch_generic.c	2005-03-04 09:55:44.000000000 +0100
+++ linux-2.6.12-work/net/sched/sch_generic.c	2005-05-04 00:24:55.558105856 +0200
@@ -539,6 +539,10 @@
 		write_unlock_bh(&qdisc_tree_lock);
 	}
 
+	if (!netif_carrier_ok(dev))
+		/* Delay activation until next carrier-on event */
+		return;
+
 	spin_lock_bh(&dev->queue_lock);
 	rcu_assign_pointer(dev->qdisc, dev->qdisc_sleeping);
 	if (dev->qdisc != &noqueue_qdisc) {

--------------060507010509040804020203--
