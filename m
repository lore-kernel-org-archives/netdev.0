From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Sat, 30 Apr 2005 10:46:38 +1000
Message-ID: <20050430004638.GA23386@gondor.apana.org.au>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au> <42701FFD.5000505@tpack.net> <20050427234359.GB22238@gondor.apana.org.au> <1114768308.4695.1487.camel@tsc-6.cph.tpack.net> <20050429101836.GA2237@gondor.apana.org.au> <1114777355.4695.1598.camel@tsc-6.cph.tpack.net> <20050429234512.GA22699@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <20050429234512.GA22699@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Tommy:

What if we take a more direct approach and just drop the packets before
it hits hard_start_xmit? This also makes it easy for the drivers to do
TX ring flushing if it's necessary since we're guaranteeing (for drivers
that are not lockless anyway) that once carrier goes off while the xmit
lock is held hard_start_xmit will not be called again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- k/net/core/dev.c  (mode:100644)
+++ l/net/core/dev.c  (mode:100644)
@@ -1312,6 +1312,11 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 			HARD_TX_LOCK(dev, cpu);
 
+			if (unlikely(!netif_carrier_ok(dev))) {
+				HARD_TX_UNLOCK(dev);
+				goto out_no_carrier;
+			}
+
 			if (!netif_queue_stopped(dev)) {
 				if (netdev_nit)
 					dev_queue_xmit_nit(skb, dev);
@@ -1335,6 +1340,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 		}
 	}
 
+out_no_carrier:
 	rc = -ENETDOWN;
 	local_bh_enable();
 
--- k/net/sched/sch_generic.c  (mode:100644)
+++ l/net/sched/sch_generic.c  (mode:100644)
@@ -134,6 +134,11 @@ int qdisc_restart(struct net_device *dev
 			/* And release queue */
 			spin_unlock(&dev->queue_lock);
 
+			if (unlikely(!netif_carrier_ok(dev))) {
+				kfree_skb(skb);
+				goto out_no_carrier;
+			}
+
 			if (!netif_queue_stopped(dev)) {
 				int ret;
 				if (netdev_nit)
@@ -141,6 +146,7 @@ int qdisc_restart(struct net_device *dev
 
 				ret = dev->hard_start_xmit(skb, dev);
 				if (ret == NETDEV_TX_OK) { 
+out_no_carrier:
 					if (!nolock) {
 						dev->xmit_lock_owner = -1;
 						spin_unlock(&dev->xmit_lock);

--wac7ysb48OaltWcw--
