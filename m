From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Wed, 05 Jan 2005 16:35:13 +0100
Message-ID: <41DC0931.80603@tpack.net>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com> <1104895169.1117.63.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040400030706040102090604"
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104895169.1117.63.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040400030706040102090604
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

jamal wrote:
> On Tue, 2005-01-04 at 18:28, Jeff Garzik wrote:
> 
>>jamal wrote:
>>
>>>The change is simple if theres consensus to go this path.
>>
>>Can you resend your patch?
> 
> 
> I didnt send any patch - but heres one that looks right - havent tried
> compiling it.

Thank you for diving into this, Jamal.

For the patch to have much effect, we need to check the carrier before
calling hard_start_xmit(). Like in the modified patch below.

>>My main objection was that any change should be made in the core, not in 
>>individual net drivers.
> 
> 
> Attached patch resolves that concern

Except for the drivers that call netif_stop_queue() on link-down. These
calls (and the corresponding netif_wake_queue) would have to be removed.


-Tommy

--------------040400030706040102090604
Content-Type: text/plain;
 name="sch_generic.c.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sch_generic.c.patch"

--- linux-2.6.10-bk7/net/sched/sch_generic.c	Wed Jan  5 16:27:13 2005
+++ linux-2.6.10-work/net/sched/sch_generic.c	Wed Jan  5 16:28:53 2005
@@ -134,7 +134,7 @@
 			/* And release queue */
 			spin_unlock(&dev->queue_lock);
 
-			if (!netif_queue_stopped(dev)) {
+			if (!netif_queue_stopped(dev) && netif_carrier_ok(dev)) {
 				int ret;
 				if (netdev_nit)
 					dev_queue_xmit_nit(skb, dev);
@@ -162,6 +162,11 @@
 			} 
 			spin_lock(&dev->queue_lock);
 			q = dev->qdisc;
+			if (!netif_carrier_ok(dev)) {
+				kfree_skb(skb);
+				q->qstats.drops++;
+				return -1;
+			}
 		}
 
 		/* Device kicked us out :(

--------------040400030706040102090604--
