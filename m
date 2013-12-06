From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] packet: introduce PACKET_QDISC_BYPASS socket option
Date: Fri,  6 Dec 2013 11:36:17 +0100
Message-ID: <1386326177-4483-4-git-send-email-dborkman@redhat.com>
References: <1386326177-4483-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757539Ab3LFKgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 05:36:24 -0500
In-Reply-To: <1386326177-4483-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a PACKET_QDISC_BYPASS socket option, that
allows for using a similar xmit() function as in pktgen instead
of taking the dev_queue_xmit() path. This can be very useful when
PF_PACKET applications are required to be used in a similar
scenario as pktgen, but with full, flexible packet payload that
needs to be provided, for example.

On default, nothing changes in behaviour for normal PF_PACKET
TX users, so everything stays as is for applications. New users,
however, can now set PACKET_QDISC_BYPASS if needed to prevent
own packets from i) reentering packet_rcv() and ii) to directly
push the frame to the driver.

In doing so we can increase pps (here 64 byte packets) for
PF_PACKET a bit:

  # CPUs -- QDISC_BYPASS   -- qdisc path -- qdisc path[**]
  1 CPU  ==  1,509,628 pps --  1,208,708 --  1,247,436
  2 CPUs ==  3,198,659 pps --  2,536,012 --  1,605,779
  3 CPUs ==  4,787,992 pps --  3,788,740 --  1,735,610
  4 CPUs ==  6,173,956 pps --  4,907,799 --  1,909,114
  5 CPUs ==  7,495,676 pps --  5,956,499 --  2,014,422
  6 CPUs ==  9,001,496 pps --  7,145,064 --  2,155,261
  7 CPUs == 10,229,776 pps --  8,190,596 --  2,220,619
  8 CPUs == 11,040,732 pps --  9,188,544 --  2,241,879
  9 CPUs == 12,009,076 pps -- 10,275,936 --  2,068,447
 10 CPUs == 11,380,052 pps -- 11,265,337 --  1,578,689
 11 CPUs == 11,672,676 pps -- 11,845,344 --  1,297,412
 [...]
 20 CPUs == 11,363,192 pps -- 11,014,933 --  1,245,081

 [**]: qdisc path with packet_rcv(), how probably most people
       seem to use it (hopefully not anymore if not needed)

The test was done using a modified trafgen, sending a simple
static 64 bytes packet, on all CPUs.  The trick in the fast
"qdisc path" case, is to avoid reentering packet_rcv() by
setting the RAW socket protocol to zero, like:
socket(PF_PACKET, SOCK_RAW, 0);

Tradeoffs are documented as well in this patch, clearly, if
queues are busy, we will drop more packets, tc disciplines are
ignored, and these packets are not visible to taps anymore. For
a pktgen like scenario, we argue that this is acceptable.

The pointer to the xmit function has been placed in packet
socket structure hole between cached_dev and prot_hook that
is hot anyway as we're working on cached_dev in each send path.

Done in joint work together with Jesper Dangaard Brouer.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 We will send a patch for the man-page after this is accepted.

 Documentation/networking/packet_mmap.txt | 21 ++++++++
 include/uapi/linux/if_packet.h           |  1 +
 net/packet/af_packet.c                   | 91 +++++++++++++++++++++++++++-----
 net/packet/internal.h                    |  1 +
 4 files changed, 102 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 8e48e3b..4288ffa 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -953,6 +953,27 @@ int main(int argc, char **argp)
 }
 
 -------------------------------------------------------------------------------
++ PACKET_QDISC_BYPASS
+-------------------------------------------------------------------------------
+
+If there is a requirement to load the network with many packets in a similar
+fashion as pktgen does, you might set the following option after socket
+creation:
+
+    int one = 1;
+    setsockopt(fd, SOL_PACKET, PACKET_QDISC_BYPASS, &one, sizeof(one));
+
+This has the side-effect, that packets sent through PF_PACKET will bypass the
+kernel's qdisc layer and are forcedly pushed to the driver directly. Meaning,
+packet are not buffered, tc disciplines are ignored, increased loss can occur
+and such packets are also not visible to other PF_PACKET sockets anymore. So,
+you have been warned; generally, this can be useful for stress testing various
+components of a system.
+
+On default, PACKET_QDISC_BYPASS is disabled and needs to be explicitly enabled
+on PF_PACKET sockets.
+
+-------------------------------------------------------------------------------
 + PACKET_TIMESTAMP
 -------------------------------------------------------------------------------
 
diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index dbf0666..1e24aa7 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -51,6 +51,7 @@ struct sockaddr_ll {
 #define PACKET_TIMESTAMP		17
 #define PACKET_FANOUT			18
 #define PACKET_TX_HAS_OFF		19
+#define PACKET_QDISC_BYPASS		20
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index cf09061..2f4af56 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -237,6 +237,48 @@ struct packet_skb_cb {
 static void __fanout_unlink(struct sock *sk, struct packet_sock *po);
 static void __fanout_link(struct sock *sk, struct packet_sock *po);
 
+static int packet_direct_xmit(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	const struct net_device_ops *ops = dev->netdev_ops;
+	netdev_features_t features;
+	struct netdev_queue *txq;
+	u16 queue_map;
+	int ret;
+
+	if (unlikely(!netif_running(dev) ||
+		     !netif_carrier_ok(dev))) {
+		kfree_skb(skb);
+		return NET_XMIT_DROP;
+	}
+
+	features = netif_skb_features(skb);
+	if (skb_needs_linearize(skb, features) &&
+	    __skb_linearize(skb)) {
+		kfree_skb(skb);
+		return NET_XMIT_DROP;
+	}
+
+	queue_map = skb_get_queue_mapping(skb);
+	txq = netdev_get_tx_queue(dev, queue_map);
+
+	__netif_tx_lock_bh(txq);
+	if (unlikely(netif_xmit_frozen_or_stopped(txq))) {
+		ret = NETDEV_TX_BUSY;
+		kfree_skb(skb);
+		goto out;
+	}
+
+	ret = ops->ndo_start_xmit(skb, dev);
+	if (likely(dev_xmit_complete(ret)))
+		txq_trans_update(txq);
+	else
+		kfree_skb(skb);
+out:
+	__netif_tx_unlock_bh(txq);
+	return ret;
+}
+
 static struct net_device *packet_cached_dev_get(struct packet_sock *po)
 {
 	struct net_device *dev;
@@ -261,6 +303,16 @@ static void packet_cached_dev_reset(struct packet_sock *po)
 	RCU_INIT_POINTER(po->cached_dev, NULL);
 }
 
+static bool packet_use_direct_xmit(const struct packet_sock *po)
+{
+	return po->xmit == packet_direct_xmit;
+}
+
+static u16 packet_pick_tx_queue(struct net_device *dev)
+{
+	return (u16) smp_processor_id() % dev->real_num_tx_queues;
+}
+
 /* register_prot_hook must be invoked with the po->bind_lock held,
  * or from a context in which asynchronous accesses to the packet
  * socket is not possible (packet_create()).
@@ -1992,9 +2044,10 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
-	skb_probe_transport_header(skb, 0);
 
-	if (po->tp_tx_has_off) {
+	if (!packet_use_direct_xmit(po))
+		skb_probe_transport_header(skb, 0);
+	if (unlikely(po->tp_tx_has_off)) {
 		int off_min, off_max, off;
 		off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
 		off_max = po->tx_ring.frame_size - tp_len;
@@ -2164,12 +2217,13 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			}
 		}
 
+		skb_set_queue_mapping(skb, packet_pick_tx_queue(dev));
 		skb->destructor = tpacket_destruct_skb;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
 		atomic_inc(&po->tx_ring.pending);
 
 		status = TP_STATUS_SEND_REQUEST;
-		err = dev_queue_xmit(skb);
+		err = po->xmit(skb);
 		if (unlikely(err > 0)) {
 			err = net_xmit_errno(err);
 			if (err && __packet_get_status(po, ph) ==
@@ -2228,8 +2282,7 @@ static struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
 	return skb;
 }
 
-static int packet_snd(struct socket *sock,
-			  struct msghdr *msg, size_t len)
+static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
@@ -2374,6 +2427,7 @@ static int packet_snd(struct socket *sock,
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
+	skb_set_queue_mapping(skb, packet_pick_tx_queue(dev));
 
 	if (po->has_vnet_hdr) {
 		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
@@ -2394,16 +2448,12 @@ static int packet_snd(struct socket *sock,
 		len += vnet_hdr_len;
 	}
 
-	skb_probe_transport_header(skb, reserve);
-
+	if (!packet_use_direct_xmit(po))
+		skb_probe_transport_header(skb, reserve);
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
 
-	/*
-	 *	Now send it
-	 */
-
-	err = dev_queue_xmit(skb);
+	err = po->xmit(skb);
 	if (err > 0 && (err = net_xmit_errno(err)) != 0)
 		goto out_unlock;
 
@@ -2425,6 +2475,7 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
+
 	if (po->tx_ring.pg_vec)
 		return tpacket_snd(po, msg);
 	else
@@ -2639,6 +2690,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	po = pkt_sk(sk);
 	sk->sk_family = PF_PACKET;
 	po->num = proto;
+	po->xmit = dev_queue_xmit;
 
 	packet_cached_dev_reset(po);
 
@@ -3218,6 +3270,18 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		po->tp_tx_has_off = !!val;
 		return 0;
 	}
+	case PACKET_QDISC_BYPASS:
+	{
+		int val;
+
+		if (optlen != sizeof(val))
+			return -EINVAL;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+
+		po->xmit = val ? packet_direct_xmit : dev_queue_xmit;
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -3310,6 +3374,9 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	case PACKET_TX_HAS_OFF:
 		val = po->tp_tx_has_off;
 		break;
+	case PACKET_QDISC_BYPASS:
+		val = packet_use_direct_xmit(po);
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 1035fa2..0a87d7b 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -114,6 +114,7 @@ struct packet_sock {
 	unsigned int		tp_tx_has_off:1;
 	unsigned int		tp_tstamp;
 	struct net_device __rcu	*cached_dev;
+	int			(*xmit)(struct sk_buff *skb);
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
-- 
1.8.3.1
