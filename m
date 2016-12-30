From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3 3/3] tun: rx batching
Date: Fri, 30 Dec 2016 13:20:51 +0800
Message-ID: <1483075251-6889-4-git-send-email-jasowang@redhat.com>
References: <1483075251-6889-1-git-send-email-jasowang@redhat.com>
Cc: wexu@redhat.com, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59504 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752188AbcL3FVI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Dec 2016 00:21:08 -0500
In-Reply-To: <1483075251-6889-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can only process 1 packet at one time during sendmsg(). This often
lead bad cache utilization under heavy load. So this patch tries to do
some batching during rx before submitting them to host network
stack. This is done through accepting MSG_MORE as a hint from
sendmsg() caller, if it was set, batch the packet temporarily in a
linked list and submit them all once MSG_MORE were cleared.

Tests were done by pktgen (burst=128) in guest over mlx4(noqueue) on host:

                  Mpps  -+%
    rx_batched=0  0.90  +0%
    rx_batched=4  0.97  +7.8%
    rx_batched=8  0.97  +7.8%
    rx_batched=16 0.98  +8.9%
    rx_batched=32 1.03  +14.4%
    rx_batched=48 1.09  +21.1%
    rx_batched=64 1.02  +13.3%

The maximum number of batched packets were specified through a module
parameter.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 50 ++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 44 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index cd8e02c..a268ed9 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -75,6 +75,10 @@
 
 #include <linux/uaccess.h>
 
+static int rx_batched;
+module_param(rx_batched, int, 0444);
+MODULE_PARM_DESC(rx_batched, "Number of packets batched in rx");
+
 /* Uncomment to enable debugging */
 /* #define TUN_DEBUG 1 */
 
@@ -522,6 +526,7 @@ static void tun_queue_purge(struct tun_file *tfile)
 	while ((skb = skb_array_consume(&tfile->tx_array)) != NULL)
 		kfree_skb(skb);
 
+	skb_queue_purge(&tfile->sk.sk_write_queue);
 	skb_queue_purge(&tfile->sk.sk_error_queue);
 }
 
@@ -1140,10 +1145,36 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
 	return skb;
 }
 
+static void tun_rx_batched(struct tun_file *tfile, struct sk_buff *skb,
+			   int more)
+{
+	struct sk_buff_head *queue = &tfile->sk.sk_write_queue;
+	struct sk_buff_head process_queue;
+	int qlen;
+	bool rcv = false;
+
+	spin_lock(&queue->lock);
+	qlen = skb_queue_len(queue);
+	__skb_queue_tail(queue, skb);
+	if (!more || qlen == rx_batched) {
+		__skb_queue_head_init(&process_queue);
+		skb_queue_splice_tail_init(queue, &process_queue);
+		rcv = true;
+	}
+	spin_unlock(&queue->lock);
+
+	if (rcv) {
+		local_bh_disable();
+		while ((skb = __skb_dequeue(&process_queue)))
+			netif_receive_skb(skb);
+		local_bh_enable();
+	}
+}
+
 /* Get packet from user space buffer */
 static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 			    void *msg_control, struct iov_iter *from,
-			    int noblock)
+			    int noblock, bool more)
 {
 	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
@@ -1283,10 +1314,15 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	skb_probe_transport_header(skb, 0);
 
 	rxhash = skb_get_hash(skb);
+
 #ifndef CONFIG_4KSTACKS
-	local_bh_disable();
-	netif_receive_skb(skb);
-	local_bh_enable();
+	if (!rx_batched) {
+		local_bh_disable();
+		netif_receive_skb(skb);
+		local_bh_enable();
+	} else {
+		tun_rx_batched(tfile, skb, more);
+	}
 #else
 	netif_rx_ni(skb);
 #endif
@@ -1312,7 +1348,8 @@ static ssize_t tun_chr_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (!tun)
 		return -EBADFD;
 
-	result = tun_get_user(tun, tfile, NULL, from, file->f_flags & O_NONBLOCK);
+	result = tun_get_user(tun, tfile, NULL, from,
+			      file->f_flags & O_NONBLOCK, false);
 
 	tun_put(tun);
 	return result;
@@ -1570,7 +1607,8 @@ static int tun_sendmsg(struct socket *sock, struct msghdr *m, size_t total_len)
 		return -EBADFD;
 
 	ret = tun_get_user(tun, tfile, m->msg_control, &m->msg_iter,
-			   m->msg_flags & MSG_DONTWAIT);
+			   m->msg_flags & MSG_DONTWAIT,
+			   m->msg_flags & MSG_MORE);
 	tun_put(tun);
 	return ret;
 }
-- 
2.7.4
