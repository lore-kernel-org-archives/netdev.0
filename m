From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] af_packet: add interframe drop cmsg
Date: Wed, 23 Sep 2009 16:32:02 -0400
Message-ID: <20090923203202.GA13805@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52842 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbZIWUcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 16:32:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Add Ancilliary data to better represent loss information
    
    I've had a few requests recently to provide more detail regarding frame loss
    during an AF_PACKET packet capture session.  Specifically the requestors want to
    see where in a packet sequence frames were lost, i.e. they want to see that 40
    frames were lost between frames 302 and 303 in a packet capture file.  In order
    to do this we need:
    
    1) The kernel to export this data to user space
    2) The applications to make use of it
    
    This patch addresses item (1).  It does this by doing the following:
    
    A) attaching ancilliary data to any skb enqueued to a socket recieve queue for
    which frames were lost between it and the previously enqueued frame.  Note I use
    a ring buffer with a correlator value (the skb pointer) to do this.  This was
    done because the skb->cb array is exhausted already for AF_PACKET
    
    B) For any frame dequeued that has ancilliary data in the ring buffer (as
    determined by the correlator value), we add a cmsg structure to the msghdr that
    gets copied to user space, this cmsg structure is of cmsg_level AF_PACKET, and
    cmsg_type PACKET_GAPDATA.  It contains a u32 value which counts the number of
    frames lost between the reception of the frame being currently recevied and the
    frame most recently preceding it.  Note this creates a situation in which if we
    have packet loss followed immediately by a socket close operation we might miss
    some gap information.  This situation is covered by the use of the
    PACKET_AUXINFO socket option, which provides total loss stats (from which the
    final gap can be computed).
    
    I've tested this patch myself, and it works well.
    
    Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/if_packet.h |    2 +
 net/packet/af_packet.c    |   90 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 91 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index dea7d6b..e5d200f 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -48,11 +48,13 @@ struct sockaddr_ll
 #define PACKET_RESERVE			12
 #define PACKET_TX_RING			13
 #define PACKET_LOSS			14
+#define PACKET_GAPDATA			15
 
 struct tpacket_stats
 {
 	unsigned int	tp_packets;
 	unsigned int	tp_drops;
+	unsigned int    tp_gap;
 };
 
 struct tpacket_auxdata
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d3d52c6..b74a91c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -179,6 +179,11 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
 
 static void packet_flush_mclist(struct sock *sk);
 
+struct packet_gap_record {
+		struct sk_buff *skb;
+		__u32 gap;
+};
+
 struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
 	struct sock		sk;
@@ -197,6 +202,11 @@ struct packet_sock {
 	int			ifindex;	/* bound device		*/
 	__be16			num;
 	struct packet_mclist	*mclist;
+	struct packet_gap_record *gaps;
+	unsigned int gap_head;
+	unsigned int gap_tail;
+	unsigned int gap_list_size;
+
 #ifdef CONFIG_PACKET_MMAP
 	atomic_t		mapped;
 	enum tpacket_versions	tp_version;
@@ -524,6 +534,55 @@ static inline unsigned int run_filter(struct sk_buff *skb, struct sock *sk,
 }
 
 /*
+ * If we've lost frames since the last time we queued one to the
+ * sk_receive_queue, we need to record it here.
+ * This must be called under the protection of the socket lock
+ * to prevent racing with other softirqs and user space
+ */
+static void record_packet_gap(struct sk_buff *skb, struct packet_sock *po)
+{
+	/*
+	 * do nothing if there is no gap
+	 */
+	if (!po->stats.tp_gap)
+		return;
+
+	/*
+	 * If there is, check the gap list tail to make sure we
+	 * have an open entry
+	 */
+	if (po->gaps[po->gap_tail].skb != NULL) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "packet socket gap list is full!\n");
+		return;
+	}
+
+	/*
+	 * We have a free entry, record it
+	 */
+	po->gaps[po->gap_tail].skb = skb;
+	po->gaps[po->gap_tail].gap = po->stats.tp_gap;
+	po->gap_tail = (po->gap_tail+1) % po->gap_list_size;
+	po->stats.tp_gap = 0;
+	return;
+
+}
+
+static __u32 check_packet_gap(struct sk_buff *skb, struct packet_sock *po)
+{
+	__u32 gap = 0;
+
+	if (po->gaps[po->gap_head].skb != skb)
+		return 0;
+
+	gap = po->gaps[po->gap_head].gap;
+	po->gaps[po->gap_head].skb = NULL;
+	po->gap_head = (po->gap_head + 1) % po->gap_list_size;
+	return gap;
+}
+
+
+/*
    This function makes lazy skb cloning in hope that most of packets
    are discarded by BPF.
 
@@ -626,6 +685,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.tp_packets++;
+	record_packet_gap(skb, po);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	spin_unlock(&sk->sk_receive_queue.lock);
 	sk->sk_data_ready(sk, skb->len);
@@ -634,6 +694,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 drop_n_acct:
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.tp_drops++;
+	po->stats.tp_gap++;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 drop_n_restore:
@@ -811,6 +872,7 @@ drop:
 
 ring_is_full:
 	po->stats.tp_drops++;
+	po->stats.tp_gap++;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 	sk->sk_data_ready(sk, 0);
@@ -1223,6 +1285,8 @@ static int packet_release(struct socket *sock)
 	skb_queue_purge(&sk->sk_receive_queue);
 	sk_refcnt_debug_release(sk);
 
+	kfree(po->gaps);
+
 	sock_put(sk);
 	return 0;
 }
@@ -1350,6 +1414,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 	struct packet_sock *po;
 	__be16 proto = (__force __be16)protocol; /* weird, but documented */
 	int err;
+	unsigned int num_records = PAGE_SIZE/sizeof(struct packet_gap_record);
 
 	if (!capable(CAP_NET_RAW))
 		return -EPERM;
@@ -1360,6 +1425,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 	sock->state = SS_UNCONNECTED;
 
 	err = -ENOBUFS;
+
 	sk = sk_alloc(net, PF_PACKET, GFP_KERNEL, &packet_proto);
 	if (sk == NULL)
 		goto out;
@@ -1374,6 +1440,19 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 	sk->sk_family = PF_PACKET;
 	po->num = proto;
 
+	err = -ENOMEM;
+	po->gaps = kmalloc(sizeof(struct packet_gap_record)*num_records,
+				GFP_KERNEL);
+	if (!po->gaps)
+		goto out_free;
+	po->gap_tail = po->gap_head = 0;
+	po->gap_list_size = num_records;
+
+	for (num_records = 0; num_records < po->gap_list_size; num_records++) {
+		po->gaps[num_records].skb = NULL;
+		po->gaps[num_records].gap = 0;
+	}
+
 	sk->sk_destruct = packet_sock_destruct;
 	sk_refcnt_debug_inc(sk);
 
@@ -1402,6 +1481,9 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 	sock_prot_inuse_add(net, &packet_proto, 1);
 	write_unlock_bh(&net->packet.sklist_lock);
 	return 0;
+
+out_free:
+	sk_free(sk);
 out:
 	return err;
 }
@@ -1418,6 +1500,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int copied, err;
 	struct sockaddr_ll *sll;
+	__u32 gap;
 
 	err = -EINVAL;
 	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
@@ -1492,10 +1575,15 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_mac = 0;
 		aux.tp_net = skb_network_offset(skb);
 		aux.tp_vlan_tci = skb->vlan_tci;
-
 		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
 	}
 
+	lock_sock(sk);
+	gap = check_packet_gap(skb, pkt_sk(sk));
+	release_sock(sk);
+	if (gap)
+		put_cmsg(msg, SOL_PACKET, PACKET_GAPDATA, sizeof(u32), &gap);
+
 	/*
 	 *	Free or return the buffer as appropriate. Again this
 	 *	hides all the races and re-entrancy issues from us.
