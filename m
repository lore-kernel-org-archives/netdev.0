From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/2] macvtap: switch to use skb array
Date: Fri, 15 Jul 2016 03:46:31 -0400
Message-ID: <1468568791-30024-2-git-send-email-jasowang@redhat.com>
References: <1468568791-30024-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468568791-30024-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch switch to use skb array instead of sk_receive_queue to
avoid spinlock contentions. Tests shows about 21% improvements for
guest rx pps:

Before: 1472731 pkts/s
After:  1786289 pkts/s

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c | 82 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 71 insertions(+), 11 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 2476923..9204d19 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -21,6 +21,7 @@
 #include <net/rtnetlink.h>
 #include <net/sock.h>
 #include <linux/virtio_net.h>
+#include <linux/skb_array.h>
 
 /*
  * A macvtap queue is the central object of this driver, it connects
@@ -43,6 +44,7 @@ struct macvtap_queue {
 	u16 queue_index;
 	bool enabled;
 	struct list_head next;
+	struct skb_array skb_array;
 };
 
 #define MACVTAP_FEATURES (IFF_VNET_HDR | IFF_MULTI_QUEUE)
@@ -273,6 +275,7 @@ static void macvtap_put_queue(struct macvtap_queue *q)
 	rtnl_unlock();
 
 	synchronize_rcu();
+	skb_array_cleanup(&q->skb_array);
 	sock_put(&q->sk);
 }
 
@@ -366,7 +369,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 	if (!q)
 		return RX_HANDLER_PASS;
 
-	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
+	if (__skb_array_full(&q->skb_array))
 		goto drop;
 
 	skb_push(skb, ETH_HLEN);
@@ -384,7 +387,8 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 			goto drop;
 
 		if (!segs) {
-			skb_queue_tail(&q->sk.sk_receive_queue, skb);
+			if (skb_array_produce(&q->skb_array, skb))
+				goto drop;
 			goto wake_up;
 		}
 
@@ -393,7 +397,11 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 			struct sk_buff *nskb = segs->next;
 
 			segs->next = NULL;
-			skb_queue_tail(&q->sk.sk_receive_queue, segs);
+			if (skb_array_produce(&q->skb_array, segs)) {
+				kfree_skb(segs);
+				kfree_skb_list(nskb);
+				break;
+			}
 			segs = nskb;
 		}
 	} else {
@@ -406,7 +414,8 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 		    !(features & NETIF_F_CSUM_MASK) &&
 		    skb_checksum_help(skb))
 			goto drop;
-		skb_queue_tail(&q->sk.sk_receive_queue, skb);
+		if (skb_array_produce(&q->skb_array, skb))
+			goto drop;
 	}
 
 wake_up:
@@ -523,7 +532,11 @@ static void macvtap_sock_write_space(struct sock *sk)
 
 static void macvtap_sock_destruct(struct sock *sk)
 {
-	skb_queue_purge(&sk->sk_receive_queue);
+	struct macvtap_queue *q = container_of(sk, struct macvtap_queue, sk);
+	struct sk_buff *skb;
+
+	while ((skb = skb_array_consume(&q->skb_array)) != NULL)
+		kfree(skb);
 }
 
 static int macvtap_open(struct inode *inode, struct file *file)
@@ -536,13 +549,13 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	rtnl_lock();
 	dev = dev_get_by_macvtap_minor(iminor(inode));
 	if (!dev)
-		goto out;
+		goto err;
 
 	err = -ENOMEM;
 	q = (struct macvtap_queue *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
 					     &macvtap_proto, 0);
 	if (!q)
-		goto out;
+		goto err;
 
 	RCU_INIT_POINTER(q->sock.wq, &q->wq);
 	init_waitqueue_head(&q->wq.wait);
@@ -566,11 +579,24 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	if ((dev->features & NETIF_F_HIGHDMA) && (dev->features & NETIF_F_SG))
 		sock_set_flag(&q->sk, SOCK_ZEROCOPY);
 
+	err = -ENOMEM;
+	if (skb_array_init(&q->skb_array, dev->tx_queue_len, GFP_KERNEL))
+		goto err_array;
+
 	err = macvtap_set_queue(dev, file, q);
 	if (err)
-		sock_put(&q->sk);
+		goto err_queue;
 
-out:
+	dev_put(dev);
+
+	rtnl_unlock();
+	return err;
+
+err_queue:
+	skb_array_cleanup(&q->skb_array);
+err_array:
+	sock_put(&q->sk);
+err:
 	if (dev)
 		dev_put(dev);
 
@@ -596,7 +622,7 @@ static unsigned int macvtap_poll(struct file *file, poll_table * wait)
 	mask = 0;
 	poll_wait(file, &q->wq.wait, wait);
 
-	if (!skb_queue_empty(&q->sk.sk_receive_queue))
+	if (!skb_array_empty(&q->skb_array))
 		mask |= POLLIN | POLLRDNORM;
 
 	if (sock_writeable(&q->sk) ||
@@ -856,7 +882,7 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
 					TASK_INTERRUPTIBLE);
 
 		/* Read frames from the queue */
-		skb = skb_dequeue(&q->sk.sk_receive_queue);
+		skb = skb_array_consume(&q->skb_array);
 		if (skb)
 			break;
 		if (noblock) {
@@ -1180,10 +1206,18 @@ static int macvtap_recvmsg(struct socket *sock, struct msghdr *m,
 	return ret;
 }
 
+static int macvtap_peek_len(struct socket *sock)
+{
+	struct macvtap_queue *q = container_of(sock, struct macvtap_queue,
+					       sock);
+	return skb_array_peek_len(&q->skb_array);
+}
+
 /* Ops structure to mimic raw sockets with tun */
 static const struct proto_ops macvtap_socket_ops = {
 	.sendmsg = macvtap_sendmsg,
 	.recvmsg = macvtap_recvmsg,
+	.peek_len = macvtap_peek_len,
 };
 
 /* Get an underlying socket object from tun file.  Returns error unless file is
@@ -1202,6 +1236,28 @@ struct socket *macvtap_get_socket(struct file *file)
 }
 EXPORT_SYMBOL_GPL(macvtap_get_socket);
 
+static int macvtap_queue_resize(struct macvlan_dev *vlan)
+{
+	struct net_device *dev = vlan->dev;
+	struct macvtap_queue *q;
+	struct skb_array **arrays;
+	int n = vlan->numqueues;
+	int ret, i = 0;
+
+	arrays = kmalloc(sizeof *arrays * n, GFP_KERNEL);
+	if (!arrays)
+		return -ENOMEM;
+
+	list_for_each_entry(q, &vlan->queue_list, next)
+		arrays[i++] = &q->skb_array;
+
+	ret = skb_array_resize_multiple(arrays, n,
+					dev->tx_queue_len, GFP_KERNEL);
+
+	kfree(arrays);
+	return ret;
+}
+
 static int macvtap_device_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
@@ -1249,6 +1305,10 @@ static int macvtap_device_event(struct notifier_block *unused,
 		device_destroy(&macvtap_class, devt);
 		macvtap_free_minor(vlan);
 		break;
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
+		if (macvtap_queue_resize(vlan))
+			return NOTIFY_BAD;
+		break;
 	}
 
 	return NOTIFY_DONE;
-- 
1.8.3.1
