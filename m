From: jamal <hadi@cyberus.ca>
Subject: Re: LLTX and netif_stop_queue
Date: 19 Dec 2004 14:54:51 -0500
Message-ID: <1103486090.1047.166.camel@jzny.localdomain>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-WbwKvjCEiZp2XREqtXF+"
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1103484675.1050.158.camel@jzny.localdomain>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


--=-WbwKvjCEiZp2XREqtXF+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2004-12-19 at 14:31, jamal wrote:

> How about releasing the qlock only when the LLTX transmit lock is
> grabbed? That should bring it to par with what it was originally.

Something like two attached patches... one showing how to do it for
e1000. untested (not even compiled)

cheers,
jamal

--=-WbwKvjCEiZp2XREqtXF+
Content-Disposition: attachment; filename=p1
Content-Type: text/plain; name=p1; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/sched/bak.sch_generic.c	2004-12-19 13:46:19.799356432 -0500
+++ b/net/sched/sch_generic.c	2004-12-19 13:49:14.384815408 -0500
@@ -128,12 +128,11 @@
 			}
 			/* Remember that the driver is grabbed by us. */
 			dev->xmit_lock_owner = smp_processor_id();
+			/* And release queue */
+			spin_unlock(&dev->queue_lock);
 		}
 		
 		{
-			/* And release queue */
-			spin_unlock(&dev->queue_lock);
-
 			if (!netif_queue_stopped(dev)) {
 				int ret;
 				if (netdev_nit)
@@ -141,15 +140,14 @@
 
 				ret = dev->hard_start_xmit(skb, dev);
 				if (ret == NETDEV_TX_OK) { 
+					dev->xmit_lock_owner = -1;
 					if (!nolock) {
-						dev->xmit_lock_owner = -1;
 						spin_unlock(&dev->xmit_lock);
 					}
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
 				if (ret == NETDEV_TX_LOCKED && nolock) {
-					spin_lock(&dev->queue_lock);
 					goto collision; 
 				}
 			}

--=-WbwKvjCEiZp2XREqtXF+
Content-Disposition: attachment; filename=p2
Content-Type: text/plain; name=p2; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/drivers/net/e1000/b.e1000_main.c	2004-12-19 13:50:59.481838232 -0500
+++ b/drivers/net/e1000/e1000_main.c	2004-12-19 13:53:34.326298296 -0500
@@ -1809,6 +1809,10 @@
  		return NETDEV_TX_LOCKED; 
  	} 
 
+	/* new from sch_generic for LLTX */
+	spin_unlock(&dev->queue_lock);
+	dev->xmit_lock_owner = smp_processor_id();
+
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {

--=-WbwKvjCEiZp2XREqtXF+
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-WbwKvjCEiZp2XREqtXF+--
