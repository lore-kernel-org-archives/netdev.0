From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 31 Jan 2005 00:39:25 +0100
Message-ID: <41FD702D.2060403@tpack.net>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>	 <1104895169.1117.63.camel@jzny.localdomain>  <41DC0931.80603@tpack.net>	 <1105019912.2314.20.camel@jzny.localdomain>	 <1105023972.3462.48.camel@tsc-6.cph.tpack.net>	 <1105104757.1046.63.camel@jzny.localdomain>	 <1105111605.3462.101.camel@tsc-6.cph.tpack.net>	 <1105363092.1041.146.camel@jzny.localdomain> <1105917038.1091.1041.camel@jzny.localdomain> <41EC3067.6050104@tpack.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030807080405060200010500"
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <41EC3067.6050104@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030807080405060200010500
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Tommy Christensen wrote:
> jamal wrote:
> 
>> Didnt see anymore discussion on this - have we given up on it?
> 
> 
> It is not forgotten - just stalled ...
> I'll try to look at it some more.

Sorry for the long delay.

Jamal, do you think something like this could work?

Flushing of the DMA ring could be added if the need arises.
e1000 does this already in the driver on link-down.

-Tommy


--------------030807080405060200010500
Content-Type: text/plain;
 name="carrier.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="carrier.patch"

diff -ur linux-2.6.11-rc2-bk8/net/core/link_watch.c linux-2.6.11-work/net/core/link_watch.c
--- linux-2.6.11-rc2-bk8/net/core/link_watch.c	2005-01-30 22:08:44.000000000 +0100
+++ linux-2.6.11-work/net/core/link_watch.c	2005-01-31 00:17:45.716039247 +0100
@@ -16,6 +16,7 @@
 #include <linux/netdevice.h>
 #include <linux/if.h>
 #include <net/sock.h>
+#include <net/pkt_sched.h>
 #include <linux/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
@@ -74,6 +75,9 @@
 		clear_bit(__LINK_STATE_LINKWATCH_PENDING, &dev->state);
 
 		if (dev->flags & IFF_UP) {
+			if (netif_carrier_ok(dev) &&
+			    dev->qdisc_sleeping != &noop_qdisc)
+				dev_activate(dev);
 			netdev_state_change(dev);
 		}
 
diff -ur linux-2.6.11-rc2-bk8/net/sched/sch_generic.c linux-2.6.11-work/net/sched/sch_generic.c
--- linux-2.6.11-rc2-bk8/net/sched/sch_generic.c	2005-01-30 22:11:50.458216314 +0100
+++ linux-2.6.11-work/net/sched/sch_generic.c	2005-01-31 00:06:47.609769835 +0100
@@ -185,6 +185,7 @@
 static void dev_watchdog(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
+	int check_carrier = 0;
 
 	spin_lock(&dev->xmit_lock);
 	if (dev->qdisc != &noop_qdisc) {
@@ -198,10 +199,23 @@
 			}
 			if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
 				dev_hold(dev);
-		}
+		} else
+			check_carrier = 1;
 	}
 	spin_unlock(&dev->xmit_lock);
 
+	if (check_carrier) {
+		spin_lock(&dev->queue_lock);
+		if (!netif_carrier_ok(dev) && netif_queue_stopped(dev)) {
+			struct Qdisc *qdisc;
+
+			qdisc = dev->qdisc;
+			dev->qdisc = &noop_qdisc;
+			qdisc_reset(qdisc);
+		}
+		spin_unlock(&dev->queue_lock);
+	}
+
 	dev_put(dev);
 }
 

--------------030807080405060200010500--
