From: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Subject: [PATCH net-next] change nfqueue failopen to apply also to receive
 message buffer in addition to queue size
Date: Mon, 21 Mar 2016 11:23:43 +0000
Message-ID: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Florian Westphal (fw@strlen.de)" <fw@strlen.de>
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-8.cisco.com ([173.37.142.95]:48479 "EHLO
	alln-iport-8.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbcCULXq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 07:23:46 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yigal Reiss <yreiss@cisco.com>
---

NOTE: this is a re-send after being bounced by the test robot for a compiler warning. I hope I'm doing the right thing in resubmitting rather than replying to the original message. Recompiled w/o warnings and re-tested. 

This is follow-up on http://marc.info/?l=netfilter-devel&m=145765526817347&w=2 

Existing fail-open mechanism for nfqueue only applies for message that cannot be sent due to queue size (queue_maxlen). It does not apply when the failure is due to socket receive buffer size. This seems to be quite arbitrary since different packet sizes for the same queue and buffer sizes yield failure for different reasons.

This patch makes both behave the same. 

There is also a change in the proc file (/proc/net/netfilter/nfnetlink_queue) to account for the fail-opened packets.

One change to existing behavior which I would like to stress is in the function netlink_unicast (now in netlink_unicast_nofree). In case where a call to sk_filter() returned non-zero value, netlink_unicast would set its returned error value to skb->len. I don't see how this ever made sense and I couldn't find anyone looking at this value. I changed this in order to have a consistent (err<0) return value on errors which was required for my changes. If anyone sees a problem with this change I'd like to know.  


 include/linux/netfilter/nfnetlink.h |  2 ++
 include/linux/netlink.h             |  3 +++
 net/netfilter/nfnetlink.c           |  7 +++++++
 net/netfilter/nfnetlink_queue.c     | 25 ++++++++++++++++++-------
 net/netlink/af_netlink.c            | 37 +++++++++++++++++++++++++------------
 5 files changed, 55 insertions(+), 19 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index ba0d978..eb477d4 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -39,6 +39,8 @@ struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
 int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
 		   unsigned int group, int echo, gfp_t flags);
 int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error);
+int nfnetlink_unicast_nofree(struct sk_buff *skb, struct net *net, u32 portid,
+                             int flags);
 int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
 		      int flags);
 
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 0b41959..9f7a819 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -79,6 +79,7 @@ netlink_alloc_skb(struct sock *ssk, unsigned int size, u32 dst_portid,
 	return __netlink_alloc_skb(ssk, size, 0, dst_portid, gfp_mask);
 }
 
+extern int netlink_unicast_nofree(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
 			     __u32 group, gfp_t allocation);
@@ -92,6 +93,8 @@ extern int netlink_unregister_notifier(struct notifier_block *nb);
 
 /* finegrained unicast helpers: */
 struct sock *netlink_getsockbyfilp(struct file *filp);
+int netlink_attachskb_nofree(struct sock *sk, struct sk_buff *skb,
+		      long *timeo, struct sock *ssk);
 int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		      long *timeo, struct sock *ssk);
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 857ae89..28f7e2d 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -154,6 +154,13 @@ int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
 }
 EXPORT_SYMBOL_GPL(nfnetlink_unicast);
 
+int nfnetlink_unicast_nofree(struct sk_buff *skb, struct net *net, u32 portid,
+                      int flags)
+{
+    return netlink_unicast_nofree(net->nfnl, skb, portid, flags);
+}
+EXPORT_SYMBOL_GPL(nfnetlink_unicast_nofree);
+
 /* Process one complete nfnetlink message. */
 static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 1d39365..3d32153 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -60,7 +60,8 @@ struct nfqnl_instance {
 	unsigned int copy_range;
 	unsigned int queue_dropped;
 	unsigned int queue_user_dropped;
-
+        unsigned int queue_failopened;
+        unsigned int nobuf_failopened;
 
 	u_int16_t queue_num;			/* number of this queue */
 	u_int8_t copy_mode;
@@ -551,6 +552,7 @@ nla_put_failure:
 	return NULL;
 }
 
+
 static int
 __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 			struct nf_queue_entry *entry)
@@ -569,6 +571,7 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 
 	if (queue->queue_total >= queue->queue_maxlen) {
 		if (queue->flags & NFQA_CFG_F_FAIL_OPEN) {
+		        queue->queue_failopened++;
 			failopen = 1;
 			err = 0;
 		} else {
@@ -582,10 +585,17 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 	*packet_id_ptr = htonl(entry->id);
 
 	/* nfnetlink_unicast will either free the nskb or add it to a socket */
-	err = nfnetlink_unicast(nskb, net, queue->peer_portid, MSG_DONTWAIT);
+	err = nfnetlink_unicast_nofree(nskb, net, queue->peer_portid, MSG_DONTWAIT);
 	if (err < 0) {
-		queue->queue_user_dropped++;
-		goto err_out_unlock;
+		if (queue->flags & NFQA_CFG_F_FAIL_OPEN) {
+		        queue->nobuf_failopened++;
+		        failopen = 1;
+			err = 0;
+		}
+		else {
+		    queue->queue_user_dropped++;
+		}
+		goto err_out_free_nskb;
 	}
 
 	__enqueue_entry(queue, entry);
@@ -595,7 +605,6 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 
 err_out_free_nskb:
 	kfree_skb(nskb);
-err_out_unlock:
 	spin_unlock_bh(&queue->lock);
 	if (failopen)
 		nf_reinject(entry, NF_ACCEPT);
@@ -1327,12 +1336,14 @@ static int seq_show(struct seq_file *s, void *v)
 {
 	const struct nfqnl_instance *inst = v;
 
-	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %2d\n",
+	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %5u %5u %2d\n",
 		   inst->queue_num,
 		   inst->peer_portid, inst->queue_total,
 		   inst->copy_mode, inst->copy_range,
 		   inst->queue_dropped, inst->queue_user_dropped,
-		   inst->id_sequence, 1);
+		   inst->id_sequence,
+		   inst->queue_failopened, inst->nobuf_failopened,
+		   2);
 	return 0;
 }
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index f1ffb34..0191cdf 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1710,17 +1710,26 @@ static struct sk_buff *netlink_alloc_large_skb(unsigned int size,
 	return skb;
 }
 
+int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
+			     long *timeo, struct sock *ssk)
+{
+    int ret = netlink_attachskb_nofree(sk, skb, timeo, ssk);
+    if (ret < 0)
+	kfree_skb(skb);
+    return ret;
+}
+
 /*
  * Attach a skb to a netlink socket.
  * The caller must hold a reference to the destination socket. On error, the
  * reference is dropped. The skb is not send to the destination, just all
  * all error checks are performed and memory in the queue is reserved.
  * Return values:
- * < 0: error. skb freed, reference to sock dropped.
+ * < 0: error. reference to sock dropped.
  * 0: continue
  * 1: repeat lookup - reference dropped while waiting for socket memory.
  */
-int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
+int netlink_attachskb_nofree(struct sock *sk, struct sk_buff *skb,
 		      long *timeo, struct sock *ssk)
 {
 	struct netlink_sock *nlk;
@@ -1735,7 +1744,6 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 			if (!ssk || netlink_is_kernel(ssk))
 				netlink_overrun(sk);
 			sock_put(sk);
-			kfree_skb(skb);
 			return -EAGAIN;
 		}
 
@@ -1752,7 +1760,6 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		sock_put(sk);
 
 		if (signal_pending(current)) {
-			kfree_skb(skb);
 			return sock_intr_errno(*timeo);
 		}
 		return 1;
@@ -1833,8 +1840,6 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 		netlink_deliver_tap_kernel(sk, ssk, skb);
 		nlk->netlink_rcv(skb);
 		consume_skb(skb);
-	} else {
-		kfree_skb(skb);
 	}
 	sock_put(sk);
 	return ret;
@@ -1843,6 +1848,16 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
 		    u32 portid, int nonblock)
 {
+    int ret = netlink_unicast_nofree(ssk, skb, portid, nonblock);
+    if (ret < 0)
+	kfree_skb(skb);
+    return ret;
+}
+EXPORT_SYMBOL(netlink_unicast);
+
+int netlink_unicast_nofree(struct sock *ssk, struct sk_buff *skb,
+			   u32 portid, int nonblock)
+{
 	struct sock *sk;
 	int err;
 	long timeo;
@@ -1853,20 +1868,18 @@ int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
 retry:
 	sk = netlink_getsockbyportid(ssk, portid);
 	if (IS_ERR(sk)) {
-		kfree_skb(skb);
 		return PTR_ERR(sk);
 	}
 	if (netlink_is_kernel(sk))
 		return netlink_unicast_kernel(sk, skb, ssk);
 
-	if (sk_filter(sk, skb)) {
-		err = skb->len;
-		kfree_skb(skb);
+	err = sk_filter(sk, skb);
+	if (err) {
 		sock_put(sk);
 		return err;
 	}
 
-	err = netlink_attachskb(sk, skb, &timeo, ssk);
+	err = netlink_attachskb_nofree(sk, skb, &timeo, ssk);
 	if (err == 1)
 		goto retry;
 	if (err)
@@ -1874,7 +1887,7 @@ retry:
 
 	return netlink_sendskb(sk, skb);
 }
-EXPORT_SYMBOL(netlink_unicast);
+EXPORT_SYMBOL(netlink_unicast_nofree);
 
 struct sk_buff *__netlink_alloc_skb(struct sock *ssk, unsigned int size,
 				    unsigned int ldiff, u32 dst_portid,
-- 
1.9.1
