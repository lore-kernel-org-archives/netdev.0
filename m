From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [NET] Move local_bh_disable back in dev_queue_xmit
Date: Wed, 03 Nov 2004 15:48:49 +0100
Message-ID: <4188EFD1.4050909@tpack.net>
References: <20041102225406.GA13760@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070405050509000708050508"
Cc: "David S. Miller" <davem@davemloft.net>, mingo@elte.hu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041102225406.GA13760@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070405050509000708050508
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Hi Ingo:
> 
> Your recent fix to dev_queue_xmit moved the local_bh_disable to
> include stuff like skb_linearize and skb_checksum_help.  These
> are potentially expensive operations.  Since they don't need to
> run with preempt off, we could simply move the local_bh_enable
> up instead.

No, this breaks the normal return path.

How about this instead?

Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>


--------------070405050509000708050508
Content-Type: text/plain;
 name="dev.c.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dev.c.patch"

--- linux-2.6.10-rc1-bk/net/core/dev.c	Wed Nov  3 15:10:43 2004
+++ linux-2.6.10-rc1-work/net/core/dev.c	Wed Nov  3 15:31:22 2004
@@ -1261,11 +1261,6 @@
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
-	/* Disable soft irqs for various locks below. Also 
-	 * stops preemption for RCU. 
-	 */
-	local_bh_disable(); 
-
 	if (skb_shinfo(skb)->frag_list &&
 	    !(dev->features & NETIF_F_FRAGLIST) &&
 	    __skb_linearize(skb, GFP_ATOMIC))
@@ -1290,6 +1285,11 @@
 	      	if (skb_checksum_help(skb, 0))
 	      		goto out_kfree_skb;
 
+	/* Disable soft irqs for various locks below. Also 
+	 * stops preemption for RCU. 
+	 */
+	local_bh_disable(); 
+
 	/* Updates of qdisc are serialized by queue_lock. 
 	 * The struct Qdisc which is pointed to by qdisc is now a 
 	 * rcu structure - it may be accessed without acquiring 
@@ -1352,7 +1352,6 @@
 			if (net_ratelimit())
 				printk(KERN_CRIT "Virtual device %s asks to "
 				       "queue packet!\n", dev->name);
-			goto out_enetdown;
 		} else {
 			/* Recursion is detected! It is possible,
 			 * unfortunately */
@@ -1361,10 +1360,13 @@
 				       "%s, fix it urgently!\n", dev->name);
 		}
 	}
-out_enetdown:
+
 	rc = -ENETDOWN;
+	local_bh_enable();
+
 out_kfree_skb:
 	kfree_skb(skb);
+	return rc;
 out:
 	local_bh_enable();
 	return rc;

--------------070405050509000708050508--
