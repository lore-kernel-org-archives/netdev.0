From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] Move local_bh_disable back in dev_queue_xmit
Date: Wed, 3 Nov 2004 09:54:06 +1100
Message-ID: <20041102225406.GA13760@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, mingo@elte.hu, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Ingo:

Your recent fix to dev_queue_xmit moved the local_bh_disable to
include stuff like skb_linearize and skb_checksum_help.  These
are potentially expensive operations.  Since they don't need to
run with preempt off, we could simply move the local_bh_enable
up instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/dev.c 1.171 vs edited =====
--- 1.171/net/core/dev.c	2004-11-02 12:40:59 +11:00
+++ edited/net/core/dev.c	2004-11-03 09:31:09 +11:00
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
@@ -1363,10 +1363,10 @@
 	}
 out_enetdown:
 	rc = -ENETDOWN;
-out_kfree_skb:
-	kfree_skb(skb);
 out:
 	local_bh_enable();
+out_kfree_skb:
+	kfree_skb(skb);
 	return rc;
 }
 

--TB36FDmn/VVEgNH/--
