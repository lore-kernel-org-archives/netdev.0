From: kaber@trash.net
Subject: [PATCH 09/17] netfilter: ip6_queue: rwlock to spinlock conversion
Date: Tue, 15 Jun 2010 17:38:35 +0200
Message-ID: <1276616323-20880-10-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

Converts queue_lock rwlock to a spinlock.

(readlocked part can be changed by reads of integer values)

One atomic operation instead of four per ipq_enqueue_packet() call.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/ip6_queue.c |   57 +++++++++++++++++----------------------
 1 files changed, 25 insertions(+), 32 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 8c20174..413ab07 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -43,7 +43,7 @@ typedef int (*ipq_cmpfn)(struct nf_queue_entry *, unsigned long);
 
 static unsigned char copy_mode __read_mostly = IPQ_COPY_NONE;
 static unsigned int queue_maxlen __read_mostly = IPQ_QMAX_DEFAULT;
-static DEFINE_RWLOCK(queue_lock);
+static DEFINE_SPINLOCK(queue_lock);
 static int peer_pid __read_mostly;
 static unsigned int copy_range __read_mostly;
 static unsigned int queue_total;
@@ -73,10 +73,10 @@ __ipq_set_mode(unsigned char mode, unsigned int range)
 		break;
 
 	case IPQ_COPY_PACKET:
-		copy_mode = mode;
+		if (range > 0xFFFF)
+			range = 0xFFFF;
 		copy_range = range;
-		if (copy_range > 0xFFFF)
-			copy_range = 0xFFFF;
+		copy_mode = mode;
 		break;
 
 	default:
@@ -102,7 +102,7 @@ ipq_find_dequeue_entry(unsigned long id)
 {
 	struct nf_queue_entry *entry = NULL, *i;
 
-	write_lock_bh(&queue_lock);
+	spin_lock_bh(&queue_lock);
 
 	list_for_each_entry(i, &queue_list, list) {
 		if ((unsigned long)i == id) {
@@ -116,7 +116,7 @@ ipq_find_dequeue_entry(unsigned long id)
 		queue_total--;
 	}
 
-	write_unlock_bh(&queue_lock);
+	spin_unlock_bh(&queue_lock);
 	return entry;
 }
 
@@ -137,9 +137,9 @@ __ipq_flush(ipq_cmpfn cmpfn, unsigned long data)
 static void
 ipq_flush(ipq_cmpfn cmpfn, unsigned long data)
 {
-	write_lock_bh(&queue_lock);
+	spin_lock_bh(&queue_lock);
 	__ipq_flush(cmpfn, data);
-	write_unlock_bh(&queue_lock);
+	spin_unlock_bh(&queue_lock);
 }
 
 static struct sk_buff *
@@ -153,9 +153,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 	struct nlmsghdr *nlh;
 	struct timeval tv;
 
-	read_lock_bh(&queue_lock);
-
-	switch (copy_mode) {
+	switch (ACCESS_ONCE(copy_mode)) {
 	case IPQ_COPY_META:
 	case IPQ_COPY_NONE:
 		size = NLMSG_SPACE(sizeof(*pmsg));
@@ -163,26 +161,21 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 
 	case IPQ_COPY_PACKET:
 		if (entry->skb->ip_summed == CHECKSUM_PARTIAL &&
-		    (*errp = skb_checksum_help(entry->skb))) {
-			read_unlock_bh(&queue_lock);
+		    (*errp = skb_checksum_help(entry->skb)))
 			return NULL;
-		}
-		if (copy_range == 0 || copy_range > entry->skb->len)
+
+		data_len = ACCESS_ONCE(copy_range);
+		if (data_len == 0 || data_len > entry->skb->len)
 			data_len = entry->skb->len;
-		else
-			data_len = copy_range;
 
 		size = NLMSG_SPACE(sizeof(*pmsg) + data_len);
 		break;
 
 	default:
 		*errp = -EINVAL;
-		read_unlock_bh(&queue_lock);
 		return NULL;
 	}
 
-	read_unlock_bh(&queue_lock);
-
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb)
 		goto nlmsg_failure;
@@ -242,7 +235,7 @@ ipq_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	if (nskb == NULL)
 		return status;
 
-	write_lock_bh(&queue_lock);
+	spin_lock_bh(&queue_lock);
 
 	if (!peer_pid)
 		goto err_out_free_nskb;
@@ -266,14 +259,14 @@ ipq_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 
 	__ipq_enqueue_entry(entry);
 
-	write_unlock_bh(&queue_lock);
+	spin_unlock_bh(&queue_lock);
 	return status;
 
 err_out_free_nskb:
 	kfree_skb(nskb);
 
 err_out_unlock:
-	write_unlock_bh(&queue_lock);
+	spin_unlock_bh(&queue_lock);
 	return status;
 }
 
@@ -342,9 +335,9 @@ ipq_set_mode(unsigned char mode, unsigned int range)
 {
 	int status;
 
-	write_lock_bh(&queue_lock);
+	spin_lock_bh(&queue_lock);
 	status = __ipq_set_mode(mode, range);
-	write_unlock_bh(&queue_lock);
+	spin_unlock_bh(&queue_lock);
 	return status;
 }
 
@@ -441,11 +434,11 @@ __ipq_rcv_skb(struct sk_buff *skb)
 	if (security_netlink_recv(skb, CAP_NET_ADMIN))
 		RCV_SKB_FAIL(-EPERM);
 
-	write_lock_bh(&queue_lock);
+	spin_lock_bh(&queue_lock);
 
 	if (peer_pid) {
 		if (peer_pid != pid) {
-			write_unlock_bh(&queue_lock);
+			spin_unlock_bh(&queue_lock);
 			RCV_SKB_FAIL(-EBUSY);
 		}
 	} else {
@@ -453,7 +446,7 @@ __ipq_rcv_skb(struct sk_buff *skb)
 		peer_pid = pid;
 	}
 
-	write_unlock_bh(&queue_lock);
+	spin_unlock_bh(&queue_lock);
 
 	status = ipq_receive_peer(NLMSG_DATA(nlh), type,
 				  nlmsglen - NLMSG_LENGTH(0));
@@ -498,10 +491,10 @@ ipq_rcv_nl_event(struct notifier_block *this,
 	struct netlink_notify *n = ptr;
 
 	if (event == NETLINK_URELEASE && n->protocol == NETLINK_IP6_FW) {
-		write_lock_bh(&queue_lock);
+		spin_lock_bh(&queue_lock);
 		if ((net_eq(n->net, &init_net)) && (n->pid == peer_pid))
 			__ipq_reset();
-		write_unlock_bh(&queue_lock);
+		spin_unlock_bh(&queue_lock);
 	}
 	return NOTIFY_DONE;
 }
@@ -528,7 +521,7 @@ static ctl_table ipq_table[] = {
 #ifdef CONFIG_PROC_FS
 static int ip6_queue_show(struct seq_file *m, void *v)
 {
-	read_lock_bh(&queue_lock);
+	spin_lock_bh(&queue_lock);
 
 	seq_printf(m,
 		      "Peer PID          : %d\n"
@@ -546,7 +539,7 @@ static int ip6_queue_show(struct seq_file *m, void *v)
 		      queue_dropped,
 		      queue_user_dropped);
 
-	read_unlock_bh(&queue_lock);
+	spin_unlock_bh(&queue_lock);
 	return 0;
 }
 
-- 
1.7.0.4

