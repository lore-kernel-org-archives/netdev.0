From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [kbuild] [net-next:master 5/11] drivers/net/macvlan.c:262:23-26:
 ERROR: skb is NULL but dereferenced.
Date: Tue, 22 Apr 2014 17:15:34 +0800
Message-ID: <20140422091533.GA22971@gondor.apana.org.au>
References: <20140422084934.GU4963@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild@01.org, Julia Lawall <julia.lawall@lip6.fr>,
	netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43682 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbaDVJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 05:15:52 -0400
Content-Disposition: inline
In-Reply-To: <20140422084934.GU4963@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 22, 2014 at 11:49:35AM +0300, Dan Carpenter wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   86fd14ad1e8c4b8f5e9a7a27b26bdade91dd4bd0
> commit: 412ca1550cbecb2cbed6086df51af08aa3452c86 [5/11] macvlan: Move broadcasts into a work queue
> 
> >> drivers/net/macvlan.c:262:23-26: ERROR: skb is NULL but dereferenced.

Thanks for catching this.

macvlan: Fix leak and NULL dereference on error path

The recent patch that moved broadcasts to process context added
a couple of bugs on the error path where we may dereference NULL
or leak an skb.  This patch fixes them.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 8b8220f..cfb27c8 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -239,25 +239,28 @@ static void macvlan_process_broadcast(struct work_struct *w)
 static void macvlan_broadcast_enqueue(struct macvlan_port *port,
 				      struct sk_buff *skb)
 {
+	struct sk_buff *nskb;
 	int err = -ENOMEM;
 
-	skb = skb_clone(skb, GFP_ATOMIC);
-	if (!skb)
+	nskb = skb_clone(skb, GFP_ATOMIC);
+	if (!nskb)
 		goto err;
 
 	spin_lock(&port->bc_queue.lock);
 	if (skb_queue_len(&port->bc_queue) < skb->dev->tx_queue_len) {
-		__skb_queue_tail(&port->bc_queue, skb);
+		__skb_queue_tail(&port->bc_queue, nskb);
 		err = 0;
 	}
 	spin_unlock(&port->bc_queue.lock);
 
 	if (err)
-		goto err;
+		goto free_nskb;
 
 	schedule_work(&port->bc_work);
 	return;
 
+free_nskb:
+	kfree_skb(nskb);
 err:
 	atomic_long_inc(&skb->dev->rx_dropped);
 }

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
