From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4] ppp: Clean up kernel log messages.
Date: Thu, 20 Jan 2011 23:56:01 -0800 (PST)
Message-ID: <20110120.235601.139098188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750786Ab1AUHz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:55:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use netdev_*() and pr_*().

To preserve existing semantics in cases where KERN_DEBUG is indeed
appropriate, use netdev_printk(KERN_DEBUG, ...)

Convert PPPIOCDETACH to pr_warn() because an unexpected file count is
a serious bug and should be logged with KERN_WARN.

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Paul Mackerras <paulus@samba.org>
---
 drivers/net/ppp_generic.c |   86 +++++++++++++++++++++++++-------------------
 1 files changed, 49 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index c7a6c44..3d7a38e 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -592,8 +592,8 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			ppp_release(NULL, file);
 			err = 0;
 		} else
-			printk(KERN_DEBUG "PPPIOCDETACH file->f_count=%ld\n",
-			       atomic_long_read(&file->f_count));
+			pr_warn("PPPIOCDETACH file->f_count=%ld\n",
+				atomic_long_read(&file->f_count));
 		mutex_unlock(&ppp_mutex);
 		return err;
 	}
@@ -630,7 +630,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 	if (pf->kind != INTERFACE) {
 		/* can't happen */
-		printk(KERN_ERR "PPP: not interface or channel??\n");
+		pr_err("PPP: not interface or channel??\n");
 		return -EINVAL;
 	}
 
@@ -704,7 +704,8 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 		vj = slhc_init(val2+1, val+1);
 		if (!vj) {
-			printk(KERN_ERR "PPP: no memory (VJ compressor)\n");
+			netdev_err(ppp->dev,
+				   "PPP: no memory (VJ compressor)\n");
 			err = -ENOMEM;
 			break;
 		}
@@ -898,17 +899,17 @@ static int __init ppp_init(void)
 {
 	int err;
 
-	printk(KERN_INFO "PPP generic driver version " PPP_VERSION "\n");
+	pr_info("PPP generic driver version " PPP_VERSION "\n");
 
 	err = register_pernet_device(&ppp_net_ops);
 	if (err) {
-		printk(KERN_ERR "failed to register PPP pernet device (%d)\n", err);
+		pr_err("failed to register PPP pernet device (%d)\n", err);
 		goto out;
 	}
 
 	err = register_chrdev(PPP_MAJOR, "ppp", &ppp_device_fops);
 	if (err) {
-		printk(KERN_ERR "failed to register PPP device (%d)\n", err);
+		pr_err("failed to register PPP device (%d)\n", err);
 		goto out_net;
 	}
 
@@ -1078,7 +1079,7 @@ pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
 	new_skb = alloc_skb(new_skb_size, GFP_ATOMIC);
 	if (!new_skb) {
 		if (net_ratelimit())
-			printk(KERN_ERR "PPP: no memory (comp pkt)\n");
+			netdev_err(ppp->dev, "PPP: no memory (comp pkt)\n");
 		return NULL;
 	}
 	if (ppp->dev->hard_header_len > PPP_HDRLEN)
@@ -1108,7 +1109,7 @@ pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
 		 * the same number.
 		 */
 		if (net_ratelimit())
-			printk(KERN_ERR "ppp: compressor dropped pkt\n");
+			netdev_err(ppp->dev, "ppp: compressor dropped pkt\n");
 		kfree_skb(skb);
 		kfree_skb(new_skb);
 		new_skb = NULL;
@@ -1138,7 +1139,9 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 		if (ppp->pass_filter &&
 		    sk_run_filter(skb, ppp->pass_filter) == 0) {
 			if (ppp->debug & 1)
-				printk(KERN_DEBUG "PPP: outbound frame not passed\n");
+				netdev_printk(KERN_DEBUG, ppp->dev,
+					      "PPP: outbound frame "
+					      "not passed\n");
 			kfree_skb(skb);
 			return;
 		}
@@ -1164,7 +1167,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 		new_skb = alloc_skb(skb->len + ppp->dev->hard_header_len - 2,
 				    GFP_ATOMIC);
 		if (!new_skb) {
-			printk(KERN_ERR "PPP: no memory (VJ comp pkt)\n");
+			netdev_err(ppp->dev, "PPP: no memory (VJ comp pkt)\n");
 			goto drop;
 		}
 		skb_reserve(new_skb, ppp->dev->hard_header_len - 2);
@@ -1202,7 +1205,9 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 	    proto != PPP_LCP && proto != PPP_CCP) {
 		if (!(ppp->flags & SC_CCP_UP) && (ppp->flags & SC_MUST_COMP)) {
 			if (net_ratelimit())
-				printk(KERN_ERR "ppp: compression required but down - pkt dropped.\n");
+				netdev_err(ppp->dev,
+					   "ppp: compression required but "
+					   "down - pkt dropped.\n");
 			goto drop;
 		}
 		skb = pad_compress_skb(ppp, skb);
@@ -1505,7 +1510,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
  noskb:
 	spin_unlock_bh(&pch->downl);
 	if (ppp->debug & 1)
-		printk(KERN_ERR "PPP: no memory (fragment)\n");
+		netdev_err(ppp->dev, "PPP: no memory (fragment)\n");
 	++ppp->dev->stats.tx_errors;
 	++ppp->nxseq;
 	return 1;	/* abandon the frame */
@@ -1686,7 +1691,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 			/* copy to a new sk_buff with more tailroom */
 			ns = dev_alloc_skb(skb->len + 128);
 			if (!ns) {
-				printk(KERN_ERR"PPP: no memory (VJ decomp)\n");
+				netdev_err(ppp->dev, "PPP: no memory "
+					   "(VJ decomp)\n");
 				goto err;
 			}
 			skb_reserve(ns, 2);
@@ -1699,7 +1705,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 
 		len = slhc_uncompress(ppp->vj, skb->data + 2, skb->len - 2);
 		if (len <= 0) {
-			printk(KERN_DEBUG "PPP: VJ decompression error\n");
+			netdev_printk(KERN_DEBUG, ppp->dev,
+				      "PPP: VJ decompression error\n");
 			goto err;
 		}
 		len += 2;
@@ -1721,7 +1728,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 			goto err;
 
 		if (slhc_remember(ppp->vj, skb->data + 2, skb->len - 2) <= 0) {
-			printk(KERN_ERR "PPP: VJ uncompressed error\n");
+			netdev_err(ppp->dev, "PPP: VJ uncompressed error\n");
 			goto err;
 		}
 		proto = PPP_IP;
@@ -1762,8 +1769,9 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 			if (ppp->pass_filter &&
 			    sk_run_filter(skb, ppp->pass_filter) == 0) {
 				if (ppp->debug & 1)
-					printk(KERN_DEBUG "PPP: inbound frame "
-					       "not passed\n");
+					netdev_printk(KERN_DEBUG, ppp->dev,
+						      "PPP: inbound frame "
+						      "not passed\n");
 				kfree_skb(skb);
 				return;
 			}
@@ -1821,7 +1829,8 @@ ppp_decompress_frame(struct ppp *ppp, struct sk_buff *skb)
 
 		ns = dev_alloc_skb(obuff_size);
 		if (!ns) {
-			printk(KERN_ERR "ppp_decompress_frame: no memory\n");
+			netdev_err(ppp->dev, "ppp_decompress_frame: "
+				   "no memory\n");
 			goto err;
 		}
 		/* the decompressor still expects the A/C bytes in the hdr */
@@ -2002,8 +2011,9 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		next = p->next;
 		if (seq_before(PPP_MP_CB(p)->sequence, seq)) {
 			/* this can't happen, anyway ignore the skb */
-			printk(KERN_ERR "ppp_mp_reconstruct bad seq %u < %u\n",
-			       PPP_MP_CB(p)->sequence, seq);
+			netdev_err(ppp->dev, "ppp_mp_reconstruct bad "
+				   "seq %u < %u\n",
+				   PPP_MP_CB(p)->sequence, seq);
 			head = next;
 			continue;
 		}
@@ -2042,8 +2052,9 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		    (PPP_MP_CB(head)->BEbits & B)) {
 			if (len > ppp->mrru + 2) {
 				++ppp->dev->stats.rx_length_errors;
-				printk(KERN_DEBUG "PPP: reconstructed packet"
-				       " is too long (%d)\n", len);
+				netdev_printk(KERN_DEBUG, ppp->dev,
+					      "PPP: reconstructed packet"
+					      " is too long (%d)\n", len);
 			} else if (p == head) {
 				/* fragment is complete packet - reuse skb */
 				tail = p;
@@ -2051,8 +2062,9 @@ ppp_mp_reconstruct(struct ppp *ppp)
 				break;
 			} else if ((skb = dev_alloc_skb(len)) == NULL) {
 				++ppp->dev->stats.rx_missed_errors;
-				printk(KERN_DEBUG "PPP: no memory for "
-				       "reconstructed packet");
+				netdev_printk(KERN_DEBUG, ppp->dev,
+					      "PPP: no memory for "
+					      "reconstructed packet");
 			} else {
 				tail = p;
 				break;
@@ -2077,9 +2089,10 @@ ppp_mp_reconstruct(struct ppp *ppp)
 		   signal a receive error. */
 		if (PPP_MP_CB(head)->sequence != ppp->nextseq) {
 			if (ppp->debug & 1)
-				printk(KERN_DEBUG "  missed pkts %u..%u\n",
-				       ppp->nextseq,
-				       PPP_MP_CB(head)->sequence-1);
+				netdev_printk(KERN_DEBUG, ppp->dev,
+					      "  missed pkts %u..%u\n",
+					      ppp->nextseq,
+					      PPP_MP_CB(head)->sequence-1);
 			++ppp->dev->stats.rx_dropped;
 			ppp_receive_error(ppp);
 		}
@@ -2617,8 +2630,8 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 	ret = register_netdev(dev);
 	if (ret != 0) {
 		unit_put(&pn->units_idr, unit);
-		printk(KERN_ERR "PPP: couldn't register device %s (%d)\n",
-		       dev->name, ret);
+		netdev_err(ppp->dev, "PPP: couldn't register device %s (%d)\n",
+			   dev->name, ret);
 		goto out2;
 	}
 
@@ -2690,9 +2703,9 @@ static void ppp_destroy_interface(struct ppp *ppp)
 
 	if (!ppp->file.dead || ppp->n_channels) {
 		/* "can't happen" */
-		printk(KERN_ERR "ppp: destroying ppp struct %p but dead=%d "
-		       "n_channels=%d !\n", ppp, ppp->file.dead,
-		       ppp->n_channels);
+		netdev_err(ppp->dev, "ppp: destroying ppp struct %p "
+			   "but dead=%d n_channels=%d !\n",
+			   ppp, ppp->file.dead, ppp->n_channels);
 		return;
 	}
 
@@ -2834,8 +2847,7 @@ static void ppp_destroy_channel(struct channel *pch)
 
 	if (!pch->file.dead) {
 		/* "can't happen" */
-		printk(KERN_ERR "ppp: destroying undead channel %p !\n",
-		       pch);
+		pr_err("ppp: destroying undead channel %p !\n", pch);
 		return;
 	}
 	skb_queue_purge(&pch->file.xq);
@@ -2847,7 +2859,7 @@ static void __exit ppp_cleanup(void)
 {
 	/* should never happen */
 	if (atomic_read(&ppp_unit_count) || atomic_read(&channel_count))
-		printk(KERN_ERR "PPP: removing module but units remain!\n");
+		pr_err("PPP: removing module but units remain!\n");
 	unregister_chrdev(PPP_MAJOR, "ppp");
 	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
 	class_destroy(ppp_class);
@@ -2865,7 +2877,7 @@ static int __unit_alloc(struct idr *p, void *ptr, int n)
 
 again:
 	if (!idr_pre_get(p, GFP_KERNEL)) {
-		printk(KERN_ERR "PPP: No free memory for idr\n");
+		pr_err("PPP: No free memory for idr\n");
 		return -ENOMEM;
 	}
 
-- 
1.7.3.4

