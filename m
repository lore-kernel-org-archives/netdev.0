From: Petar Penkov <peterpenkov96@gmail.com>
Subject: [PATCH,net-next,1/2] tun: enable NAPI for TUN/TAP driver
Date: Tue, 19 Sep 2017 00:34:01 -0700
Message-ID: <20170919073402.2292-2-peterpenkov96@gmail.com>
References: <20170919073402.2292-1-peterpenkov96@gmail.com>
Cc: Petar Penkov <peterpenkov96@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
        ppenkov@stanford.edu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34899 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdISHeJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 03:34:09 -0400
Received: by mail-pf0-f194.google.com with SMTP id i23so1182489pfi.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 00:34:09 -0700 (PDT)
In-Reply-To: <20170919073402.2292-1-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes TUN driver to use napi_gro_receive() upon receiving packets
rather than netif_rx_ni(). Adds flag CONFIG_TUN_NAPI that enables
these changes and operation is not affected if the flag is disabled.
SKBs are constructed upon packet arrival and are queued to be
processed later.

The new path was evaluated with a benchmark with the following setup:
Open two tap devices and a receiver thread that reads in a loop for
each device. Start one sender thread and pin all threads to different
CPUs. Send 1M minimum UDP packets to each device and measure sending
time for each of the sending methods:
	napi_gro_receive():	4.90s
	netif_rx_ni():		4.90s
	netif_receive_skb():	7.20s

Signed-off-by: Petar Penkov <peterpenkov96@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: davem@davemloft.net
Cc: ppenkov@stanford.edu
---
 drivers/net/Kconfig |   8 ++++
 drivers/net/tun.c   | 120 +++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 118 insertions(+), 10 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index aba0d652095b..0176264b1e70 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -307,6 +307,14 @@ config TAP
 	  This option is selected by any driver implementing tap user space
 	  interface for a virtual interface to re-use core tap functionality.
 
+config TUN_NAPI
+	bool "NAPI support on tx path for TUN/TAP driver"
+	default n
+	depends on TUN
+	---help---
+	  This option allows the TUN/TAP driver to use NAPI to pass packets to
+	  the kernel when receiving packets from user space via write()/send().
+
 config TUN_VNET_CROSS_LE
 	bool "Support for cross-endian vnet headers on little-endian kernels"
 	default n
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3c9985f29950..46cca1094c91 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -172,6 +172,7 @@ struct tun_file {
 		u16 queue_index;
 		unsigned int ifindex;
 	};
+	struct napi_struct napi;
 	struct list_head next;
 	struct tun_struct *detached;
 	struct skb_array tx_array;
@@ -229,6 +230,67 @@ struct tun_struct {
 	struct bpf_prog __rcu *xdp_prog;
 };
 
+static int tun_napi_receive(struct napi_struct *napi, int budget)
+{
+	struct tun_file *tfile = container_of(napi, struct tun_file, napi);
+	struct sk_buff_head *queue = &tfile->sk.sk_write_queue;
+	struct sk_buff_head process_queue;
+	struct sk_buff *skb;
+	int received = 0;
+
+	__skb_queue_head_init(&process_queue);
+
+	spin_lock(&queue->lock);
+	skb_queue_splice_tail_init(queue, &process_queue);
+	spin_unlock(&queue->lock);
+
+	while (received < budget && (skb = __skb_dequeue(&process_queue))) {
+		napi_gro_receive(napi, skb);
+		++received;
+	}
+
+	if (!skb_queue_empty(&process_queue)) {
+		spin_lock(&queue->lock);
+		skb_queue_splice(&process_queue, queue);
+		spin_unlock(&queue->lock);
+	}
+
+	return received;
+}
+
+static int tun_napi_poll(struct napi_struct *napi, int budget)
+{
+	unsigned int received;
+
+	received = tun_napi_receive(napi, budget);
+
+	if (received < budget)
+		napi_complete_done(napi, received);
+
+	return received;
+}
+
+static void tun_napi_init(struct tun_struct *tun, struct tun_file *tfile)
+{
+	if (IS_ENABLED(CONFIG_TUN_NAPI)) {
+		netif_napi_add(tun->dev, &tfile->napi, tun_napi_poll,
+			       NAPI_POLL_WEIGHT);
+		napi_enable(&tfile->napi);
+	}
+}
+
+static void tun_napi_disable(struct tun_file *tfile)
+{
+	if (IS_ENABLED(CONFIG_TUN_NAPI))
+		napi_disable(&tfile->napi);
+}
+
+static void tun_napi_del(struct tun_file *tfile)
+{
+	if (IS_ENABLED(CONFIG_TUN_NAPI))
+		netif_napi_del(&tfile->napi);
+}
+
 #ifdef CONFIG_TUN_VNET_CROSS_LE
 static inline bool tun_legacy_is_little_endian(struct tun_struct *tun)
 {
@@ -541,6 +603,11 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 
 	tun = rtnl_dereference(tfile->tun);
 
+	if (tun && clean) {
+		tun_napi_disable(tfile);
+		tun_napi_del(tfile);
+	}
+
 	if (tun && !tfile->detached) {
 		u16 index = tfile->queue_index;
 		BUG_ON(index >= tun->numqueues);
@@ -598,6 +665,7 @@ static void tun_detach_all(struct net_device *dev)
 	for (i = 0; i < n; i++) {
 		tfile = rtnl_dereference(tun->tfiles[i]);
 		BUG_ON(!tfile);
+		tun_napi_disable(tfile);
 		tfile->socket.sk->sk_shutdown = RCV_SHUTDOWN;
 		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
 		RCU_INIT_POINTER(tfile->tun, NULL);
@@ -613,6 +681,7 @@ static void tun_detach_all(struct net_device *dev)
 	synchronize_net();
 	for (i = 0; i < n; i++) {
 		tfile = rtnl_dereference(tun->tfiles[i]);
+		tun_napi_del(tfile);
 		/* Drop read queue */
 		tun_queue_purge(tfile);
 		sock_put(&tfile->sk);
@@ -677,10 +746,12 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
 	tun->numqueues++;
 
-	if (tfile->detached)
+	if (tfile->detached) {
 		tun_enable_queue(tfile);
-	else
+	} else {
 		sock_hold(&tfile->sk);
+		tun_napi_init(tun, tfile);
+	}
 
 	tun_set_real_num_queues(tun);
 
@@ -956,13 +1027,28 @@ static void tun_poll_controller(struct net_device *dev)
 	 * Tun only receives frames when:
 	 * 1) the char device endpoint gets data from user space
 	 * 2) the tun socket gets a sendmsg call from user space
-	 * Since both of those are synchronous operations, we are guaranteed
-	 * never to have pending data when we poll for it
-	 * so there is nothing to do here but return.
+	 * If NAPI is not enabled, since both of those are synchronous
+	 * operations, we are guaranteed never to have pending data when we poll
+	 * for it so there is nothing to do here but return.
 	 * We need this though so netpoll recognizes us as an interface that
 	 * supports polling, which enables bridge devices in virt setups to
 	 * still use netconsole
+	 * If NAPI is enabled, however, we need to schedule polling for all
+	 * queues.
 	 */
+
+	if (IS_ENABLED(CONFIG_TUN_NAPI)) {
+		struct tun_struct *tun = netdev_priv(dev);
+		struct tun_file *tfile;
+		int i;
+
+		rcu_read_lock();
+		for (i = 0; i < tun->numqueues; i++) {
+			tfile = rcu_dereference(tun->tfiles[i]);
+			napi_schedule(&tfile->napi);
+		}
+		rcu_read_unlock();
+	}
 	return;
 }
 #endif
@@ -1549,11 +1635,25 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	rxhash = __skb_get_hash_symmetric(skb);
-#ifndef CONFIG_4KSTACKS
-	tun_rx_batched(tun, tfile, skb, more);
-#else
-	netif_rx_ni(skb);
-#endif
+
+	if (IS_ENABLED(CONFIG_TUN_NAPI)) {
+		struct sk_buff_head *queue = &tfile->sk.sk_write_queue;
+		int queue_len;
+
+		spin_lock_bh(&queue->lock);
+		__skb_queue_tail(queue, skb);
+		queue_len = skb_queue_len(queue);
+		spin_unlock(&queue->lock);
+
+		if (!more || queue_len > NAPI_POLL_WEIGHT)
+			napi_schedule(&tfile->napi);
+
+		local_bh_enable();
+	} else if (!IS_ENABLED(CONFIG_4KSTACKS)) {
+		tun_rx_batched(tun, tfile, skb, more);
+	} else {
+		netif_rx_ni(skb);
+	}
 
 	stats = get_cpu_ptr(tun->pcpu_stats);
 	u64_stats_update_begin(&stats->syncp);
-- 
2.11.0
