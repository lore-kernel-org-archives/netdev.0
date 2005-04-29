From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [patch/RFC]: Asynchronous IPsec processing.
Date: Fri, 29 Apr 2005 14:41:03 +0400
Message-ID: <20050429144103.A23268@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I've created POC code to perform asynchronous IPsec [ESP]
processing. Please comment about bugs in the following patch.
It of course very dirty - but it is only begining, 
I just want to know if approach is right.
Patch was tested with several ssh session and some 
traffic like find / and tcpdump over them.

Thank you.

diff -ru ../linux-2.6-orig/net/ipv4/esp4.c ./net/ipv4/esp4.c
--- ../linux-2.6-orig/net/ipv4/esp4.c	2005-04-25 15:41:39.000000000 +0400
+++ ./net/ipv4/esp4.c	2005-04-29 14:34:10.000000000 +0400
@@ -7,6 +7,7 @@
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
 #include <linux/random.h>
+#include <linux/timer.h>
 #include <net/icmp.h>
 #include <net/udp.h>
 
@@ -17,6 +18,95 @@
 	__u8		proto;
 };
 
+static int esp_output(struct xfrm_state *x, struct sk_buff *skb);
+
+struct esp_async {
+	struct timer_list	tm;
+	struct sk_buff		*skb;
+	struct xfrm_state	*x;
+	struct dst_entry	*dst;
+};
+
+static void esp4_callback(unsigned long data)
+{
+	struct esp_async *ea = (struct esp_async *)data;
+	struct sk_buff *skb = ea->skb; 
+	struct dst_entry *dst = ea->dst;
+	struct xfrm_state *x = ea->x;
+	int err;
+
+	printk("%s: skb=%p, skb->users=%d.\n", __func__, skb, atomic_read(&skb->users));
+	printk("%s: dst=%p, skb->dst=%p.\n", __func__, dst, skb->dst);
+	printk("%s: xfrm=%p, skb->dst->xfrm=%p.\n", __func__, x, (skb->dst)?skb->dst->xfrm:NULL);
+
+	spin_lock_bh(&x->lock);
+	err = esp_output(x, skb);
+	spin_unlock_bh(&x->lock);
+
+	printk("%s: Data has been processed: err=%d.\n", __func__, err);
+	
+	if (err)
+		goto err_out;
+
+	skb->dst = dst_pop(dst);
+	printk("%s: pop has been finished: skb->dst=%p, dst=%p, skb->users=%d.\n", 
+			__func__, skb->dst, dst, atomic_read(&skb->users));
+	if (!skb->dst)
+		goto err_out;
+	
+	dst_output(skb);
+
+out:
+	kfree(ea);
+	return;
+
+err_out:
+	kfree_skb(skb);
+	goto out;
+}
+
+static int esp_output_async(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct esp_async *ea;
+	struct dst_entry *child;
+
+	printk("%s: enter. Child list: ", __func__);
+	for (child = skb->dst; child; child = child->child)
+		printk("%p [%s] [%d] -> ", child, child->dev->name, atomic_read(&child->__refcnt));
+	printk("\n");
+	
+	ea = kmalloc(sizeof(*ea), GFP_ATOMIC);
+	if (!ea)
+		return -ENOMEM;
+
+	memset(ea, 0, sizeof(*ea));
+
+	skb = skb_clone(skb, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+	dst_hold(skb->dst);
+	
+	ea->skb = skb;
+	ea->x = x;
+	ea->dst = skb->dst;
+
+	printk("%s: x=%p, skb=%p, skb->dst=%p, skb->dst->xfrm=%p.\n",
+			__func__, x, skb, skb->dst, skb->dst->xfrm);
+
+	init_timer(&ea->tm);
+	ea->tm.function = &esp4_callback;
+	ea->tm.data = (unsigned long)ea;
+	ea->tm.expires = jiffies;
+
+	add_timer(&ea->tm);
+
+	printk("%s: timer added: skb->users=%d.\n", __func__, atomic_read(&skb->users));
+
+	return 0;
+
+}
+
+
 static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
@@ -465,7 +555,7 @@
 	.get_max_size	= esp4_get_max_size,
 	.input		= esp_input,
 	.post_input	= esp_post_input,
-	.output		= esp_output
+	.output		= esp_output_async
 };
 
 static struct net_protocol esp4_protocol = {
diff -ru ../linux-2.6-orig/net/ipv4/xfrm4_output.c ./net/ipv4/xfrm4_output.c
--- ../linux-2.6-orig/net/ipv4/xfrm4_output.c	2005-04-25 15:41:40.000000000 +0400
+++ ./net/ipv4/xfrm4_output.c	2005-04-29 12:13:41.000000000 +0400
@@ -124,12 +124,6 @@
 	x->curlft.packets++;
 
 	spin_unlock_bh(&x->lock);
-	
-	if (!(skb->dst = dst_pop(dst))) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
-	err = NET_XMIT_BYPASS;
 
 out_exit:
 	return err;


-- 
	Evgeniy Polyakov
