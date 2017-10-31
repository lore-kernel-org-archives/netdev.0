From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 07/14] packet: wire up zerocopy for AF_PACKET V4
Date: Tue, 31 Oct 2017 13:41:38 +0100
Message-ID: <20171031124145.9667-8-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:50928 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753141AbdJaMmq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:46 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

This commits adds support for zerocopy mode. Note that zerocopy mode
requires that the network interface has been bound to the socket using
the bind syscall, and that the corresponding netdev implements the
AF_PACKET V4 ndos.

Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 include/linux/tpacket4.h |  38 +++++
 net/packet/af_packet.c   | 399 +++++++++++++++++++++++++++++++++++++++++++----
 net/packet/internal.h    |   1 +
 3 files changed, 404 insertions(+), 34 deletions(-)

diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index ac6c721294e8..839485108b2d 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -105,6 +105,44 @@ struct tp4_frame_set {
 	u32 end;
 };
 
+enum tp4_netdev_command {
+	/* Enable the AF_PACKET V4 zerocopy support. When this is enabled,
+	 * packets will arrive to the socket without being copied resulting
+	 * in better performance. Note that this also means that no packets
+	 * are sent to the kernel stack after this feature has been enabled.
+	 */
+	TP4_ENABLE,
+	/* Disables the PACKET_ZEROCOPY support. */
+	TP4_DISABLE,
+};
+
+/**
+ * struct tp4_netdev_parms - TP4 netdev parameters for configuration
+ *
+ * @command: netdev command, currently enable or disable
+ * @rx_opaque: an opaque pointer to the rx queue
+ * @tx_opaque: an opaque pointer to the tx queue
+ * @data_ready: function to be called when data is ready in poll mode
+ * @data_ready_opauqe: opaque parameter returned with data_ready
+ * @write_space: called when data needs to be transmitted in poll mode
+ * @write_space_opaque: opaque parameter returned with write_space
+ * @error_report: called when there is an error
+ * @error_report_opaque: opaque parameter returned in error_report
+ * @queue_pair: the queue_pair associated with this zero-copy operation
+ **/
+struct tp4_netdev_parms {
+	enum tp4_netdev_command command;
+	void *rx_opaque;
+	void *tx_opaque;
+	void (*data_ready)(void *);
+	void *data_ready_opaque;
+	void (*write_space)(void *);
+	void *write_space_opaque;
+	void (*error_report)(void *, int);
+	void *error_report_opaque;
+	int queue_pair;
+};
+
 /*************** V4 QUEUE OPERATIONS *******************************/
 
 /**
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 444eb4834362..fbfada773463 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3151,16 +3151,218 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	return err;
 }
 
+static void packet_v4_data_ready_callback(void *data_ready_opaque)
+{
+	struct sock *sk = (struct sock *)data_ready_opaque;
+
+	sk->sk_data_ready(sk);
+}
+
+static void packet_v4_write_space_callback(void *write_space_opaque)
+{
+	struct sock *sk = (struct sock *)write_space_opaque;
+
+	sk->sk_write_space(sk);
+}
+
+static void packet_v4_disable_zerocopy(struct net_device *dev,
+				       struct tp4_netdev_parms *zc)
+{
+	struct tp4_netdev_parms params;
+
+	params = *zc;
+	params.command  = TP4_DISABLE;
+
+	(void)dev->netdev_ops->ndo_tp4_zerocopy(dev, &params);
+}
+
+static int packet_v4_enable_zerocopy(struct net_device *dev,
+				     struct tp4_netdev_parms *zc)
+{
+	return dev->netdev_ops->ndo_tp4_zerocopy(dev, zc);
+}
+
+static void packet_v4_error_report_callback(void *error_report_opaque,
+					    int errno)
+{
+	struct packet_sock *po = error_report_opaque;
+	struct tp4_netdev_parms *zc;
+	struct net_device *dev;
+
+	zc = rtnl_dereference(po->zc);
+	dev = packet_cached_dev_get(po);
+	if (zc && dev) {
+		packet_v4_disable_zerocopy(dev, zc);
+
+		pr_warn("packet v4 zerocopy queue pair %d no longer available! errno=%d\n",
+			zc->queue_pair, errno);
+		dev_put(dev);
+	}
+}
+
+static int packet_v4_get_zerocopy_qp(struct packet_sock *po)
+{
+	struct tp4_netdev_parms *zc;
+	int qp;
+
+	rcu_read_lock();
+	zc = rcu_dereference(po->zc);
+	qp = zc ? zc->queue_pair : -1;
+	rcu_read_unlock();
+
+	return qp;
+}
+
+static int packet_v4_zerocopy(struct sock *sk, int qp)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct socket *sock = sk->sk_socket;
+	struct tp4_netdev_parms *zc = NULL;
+	struct net_device *dev;
+	bool if_up;
+	int ret = 0;
+
+	/* Currently, only RAW sockets are supported.*/
+	if (sock->type != SOCK_RAW)
+		return -EINVAL;
+
+	rtnl_lock();
+	dev = packet_cached_dev_get(po);
+
+	/* Socket needs to be bound to an interface. */
+	if (!dev) {
+		rtnl_unlock();
+		return -EISCONN;
+	}
+
+	/* The device needs to have both the NDOs implemented. */
+	if (!(dev->netdev_ops->ndo_tp4_zerocopy &&
+	      dev->netdev_ops->ndo_tp4_xmit)) {
+		ret = -EOPNOTSUPP;
+		goto out_unlock;
+	}
+
+	if (!(po->rx_ring.pg_vec && po->tx_ring.pg_vec)) {
+		ret = -EOPNOTSUPP;
+		goto out_unlock;
+	}
+
+	if_up = dev->flags & IFF_UP;
+	zc = rtnl_dereference(po->zc);
+
+	/* Disable */
+	if (qp <= 0) {
+		if (!zc)
+			goto out_unlock;
+
+		packet_v4_disable_zerocopy(dev, zc);
+		rcu_assign_pointer(po->zc, NULL);
+
+		if (if_up) {
+			spin_lock(&po->bind_lock);
+			register_prot_hook(sk);
+			spin_unlock(&po->bind_lock);
+		}
+
+		goto out_unlock;
+	}
+
+	/* Enable */
+	if (!zc) {
+		zc = kzalloc(sizeof(*zc), GFP_KERNEL);
+		if (!zc) {
+			ret = -ENOMEM;
+			goto out_unlock;
+		}
+	}
+
+	if (zc->queue_pair >= 0)
+		packet_v4_disable_zerocopy(dev, zc);
+
+	zc->command = TP4_ENABLE;
+	if (po->rx_ring.tp4q.umem)
+		zc->rx_opaque = &po->rx_ring.tp4q;
+	else
+		zc->rx_opaque = NULL;
+	if (po->tx_ring.tp4q.umem)
+		zc->tx_opaque = &po->tx_ring.tp4q;
+	else
+		zc->tx_opaque = NULL;
+	zc->data_ready = packet_v4_data_ready_callback;
+	zc->write_space = packet_v4_write_space_callback;
+	zc->error_report = packet_v4_error_report_callback;
+	zc->data_ready_opaque = (void *)sk;
+	zc->write_space_opaque = (void *)sk;
+	zc->error_report_opaque = po;
+	zc->queue_pair = qp - 1;
+
+	spin_lock(&po->bind_lock);
+	unregister_prot_hook(sk, true);
+	spin_unlock(&po->bind_lock);
+
+	if (if_up) {
+		ret = packet_v4_enable_zerocopy(dev, zc);
+		if (ret) {
+			spin_lock(&po->bind_lock);
+			register_prot_hook(sk);
+			spin_unlock(&po->bind_lock);
+
+			kfree(po->zc);
+			po->zc = NULL;
+			goto out_unlock;
+		}
+	} else {
+		sk->sk_err = ENETDOWN;
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_error_report(sk);
+	}
+
+	rcu_assign_pointer(po->zc, zc);
+	zc = NULL;
+
+out_unlock:
+	if (dev)
+		dev_put(dev);
+	rtnl_unlock();
+	if (zc) {
+		synchronize_rcu();
+		kfree(zc);
+	}
+	return ret;
+}
+
+static int packet_v4_zc_snd(struct packet_sock *po, int qp)
+{
+	struct net_device *dev;
+	int ret = -1;
+
+	/* NOTE: It's a bit unorthodox having an ndo without the RTNL
+	 * lock taken during the call. The ndo_tp4_xmit cannot sleep.
+	 */
+	dev = packet_cached_dev_get(po);
+	if (dev) {
+		ret = dev->netdev_ops->ndo_tp4_xmit(dev, qp);
+		dev_put(dev);
+	}
+
+	return ret;
+}
+
 static int packet_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
+	int zc_qp;
 
 	if (po->tx_ring.pg_vec) {
 		if (po->tp_version != TPACKET_V4)
 			return tpacket_snd(po, msg);
 
-		return packet_v4_snd(po, msg);
+		zc_qp = packet_v4_get_zerocopy_qp(po);
+		if (zc_qp < 0)
+			return packet_v4_snd(po, msg);
+
+		return packet_v4_zc_snd(po, zc_qp);
 	}
 
 	return packet_snd(sock, msg, len);
@@ -3318,7 +3520,9 @@ static void packet_clear_ring(struct sock *sk, int tx_ring)
 
 static int packet_release(struct socket *sock)
 {
+	struct tp4_netdev_parms *zc;
 	struct sock *sk = sock->sk;
+	struct net_device *dev;
 	struct packet_sock *po;
 	struct packet_fanout *f;
 	struct net *net;
@@ -3337,6 +3541,20 @@ static int packet_release(struct socket *sock)
 	sock_prot_inuse_add(net, sk->sk_prot, -1);
 	preempt_enable();
 
+	rtnl_lock();
+	zc = rtnl_dereference(po->zc);
+	dev = packet_cached_dev_get(po);
+	if (zc && dev)
+		packet_v4_disable_zerocopy(dev, zc);
+	if (dev)
+		dev_put(dev);
+	rtnl_unlock();
+
+	if (zc) {
+		synchronize_rcu();
+		kfree(zc);
+	}
+
 	spin_lock(&po->bind_lock);
 	unregister_prot_hook(sk, false);
 	packet_cached_dev_reset(po);
@@ -3381,6 +3599,54 @@ static int packet_release(struct socket *sock)
 	return 0;
 }
 
+static int packet_v4_rehook_zerocopy(struct sock *sk,
+				     struct net_device *dev_prev,
+				     struct net_device *dev)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct tp4_netdev_parms *zc;
+	bool dev_up;
+	int ret = 0;
+
+	rtnl_lock();
+	dev_up = (dev && (dev->flags & IFF_UP));
+	zc = rtnl_dereference(po->zc);
+	/* Recheck */
+	if (!zc) {
+		if (dev_up) {
+			spin_lock(&po->bind_lock);
+			register_prot_hook(sk);
+			spin_unlock(&po->bind_lock);
+			rtnl_unlock();
+
+			return 0;
+		}
+
+		sk->sk_err = ENETDOWN; /* XXX something else? */
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_error_report(sk);
+
+		goto out;
+	}
+
+	if (dev_prev)
+		packet_v4_disable_zerocopy(dev_prev, zc);
+	if (dev_up) {
+		ret = packet_v4_enable_zerocopy(dev, zc);
+		if (ret) {
+			/* XXX re-enable hook? */
+			sk->sk_err = ENETDOWN; /* XXX something else? */
+			if (!sock_flag(sk, SOCK_DEAD))
+				sk->sk_error_report(sk);
+		}
+	}
+
+out:
+	rtnl_unlock();
+
+	return ret;
+}
+
 /*
  *	Attach a packet hook.
  */
@@ -3388,11 +3654,10 @@ static int packet_release(struct socket *sock)
 static int packet_do_bind(struct sock *sk, const char *name, int ifindex,
 			  __be16 proto)
 {
+	struct net_device *dev_curr = NULL, *dev = NULL;
 	struct packet_sock *po = pkt_sk(sk);
-	struct net_device *dev_curr;
 	__be16 proto_curr;
 	bool need_rehook;
-	struct net_device *dev = NULL;
 	int ret = 0;
 	bool unlisted = false;
 
@@ -3443,6 +3708,7 @@ static int packet_do_bind(struct sock *sk, const char *name, int ifindex,
 
 		if (unlikely(unlisted)) {
 			dev_put(dev);
+			dev = NULL;
 			po->prot_hook.dev = NULL;
 			po->ifindex = -1;
 			packet_cached_dev_reset(po);
@@ -3452,14 +3718,13 @@ static int packet_do_bind(struct sock *sk, const char *name, int ifindex,
 			packet_cached_dev_assign(po, dev);
 		}
 	}
-	if (dev_curr)
-		dev_put(dev_curr);
 
 	if (proto == 0 || !need_rehook)
 		goto out_unlock;
 
 	if (!unlisted && (!dev || (dev->flags & IFF_UP))) {
-		register_prot_hook(sk);
+		if (!rcu_dereference(po->zc))
+			register_prot_hook(sk);
 	} else {
 		sk->sk_err = ENETDOWN;
 		if (!sock_flag(sk, SOCK_DEAD))
@@ -3470,6 +3735,12 @@ static int packet_do_bind(struct sock *sk, const char *name, int ifindex,
 	rcu_read_unlock();
 	spin_unlock(&po->bind_lock);
 	release_sock(sk);
+
+	if (!ret && need_rehook)
+		ret = packet_v4_rehook_zerocopy(sk, dev_curr, dev);
+	if (dev_curr)
+		dev_put(dev_curr);
+
 	return ret;
 }
 
@@ -4003,6 +4274,19 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 			return packet_set_ring(sk, &req_u, 0,
 					       optname == PACKET_TX_RING);
 	}
+	case PACKET_ZEROCOPY:
+	{
+		int qp; /* <=0 disable, 1..n is queue pair index */
+
+		if (optlen != sizeof(qp))
+			return -EINVAL;
+		if (copy_from_user(&qp, optval, sizeof(qp)))
+			return -EFAULT;
+
+		if (po->tp_version == TPACKET_V4)
+			return packet_v4_zerocopy(sk, qp);
+		return -EOPNOTSUPP;
+	}
 	case PACKET_COPY_THRESH:
 	{
 		int val;
@@ -4311,6 +4595,12 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	case PACKET_QDISC_BYPASS:
 		val = packet_use_direct_xmit(po);
 		break;
+	case PACKET_ZEROCOPY:
+		if (po->tp_version == TPACKET_V4) {
+			val = packet_v4_get_zerocopy_qp(po) + 1;
+			break;
+		}
+		return -ENOPROTOOPT;
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -4346,6 +4636,71 @@ static int compat_packet_setsockopt(struct socket *sock, int level, int optname,
 }
 #endif
 
+static void packet_notifier_down(struct sock *sk, struct net_device *dev,
+				 bool unregister)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct tp4_netdev_parms *zc;
+	bool report = false;
+
+	if (unregister && po->mclist)
+		packet_dev_mclist_delete(dev, &po->mclist);
+
+	if (dev->ifindex == po->ifindex) {
+		spin_lock(&po->bind_lock);
+		if (po->running) {
+			__unregister_prot_hook(sk, false);
+			report = true;
+		}
+
+		zc = rtnl_dereference(po->zc);
+		if (zc) {
+			packet_v4_disable_zerocopy(dev, zc);
+			report = true;
+		}
+
+		if (report) {
+			sk->sk_err = ENETDOWN;
+			if (!sock_flag(sk, SOCK_DEAD))
+				sk->sk_error_report(sk);
+		}
+
+		if (unregister) {
+			packet_cached_dev_reset(po);
+			po->ifindex = -1;
+			if (po->prot_hook.dev)
+				dev_put(po->prot_hook.dev);
+			po->prot_hook.dev = NULL;
+		}
+		spin_unlock(&po->bind_lock);
+	}
+}
+
+static void packet_notifier_up(struct sock *sk, struct net_device *dev)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct tp4_netdev_parms *zc;
+	int ret;
+
+	if (dev->ifindex == po->ifindex) {
+		spin_lock(&po->bind_lock);
+		if (po->num) {
+			zc = rtnl_dereference(po->zc);
+			if (zc) {
+				ret = packet_v4_enable_zerocopy(dev, zc);
+				if (ret) {
+					sk->sk_err = ENETDOWN;
+					if (!sock_flag(sk, SOCK_DEAD))
+						sk->sk_error_report(sk);
+				}
+			} else {
+				register_prot_hook(sk);
+			}
+		}
+		spin_unlock(&po->bind_lock);
+	}
+}
+
 static int packet_notifier(struct notifier_block *this,
 			   unsigned long msg, void *ptr)
 {
@@ -4355,44 +4710,20 @@ static int packet_notifier(struct notifier_block *this,
 
 	rcu_read_lock();
 	sk_for_each_rcu(sk, &net->packet.sklist) {
-		struct packet_sock *po = pkt_sk(sk);
-
 		switch (msg) {
 		case NETDEV_UNREGISTER:
-			if (po->mclist)
-				packet_dev_mclist_delete(dev, &po->mclist);
 			/* fallthrough */
-
 		case NETDEV_DOWN:
-			if (dev->ifindex == po->ifindex) {
-				spin_lock(&po->bind_lock);
-				if (po->running) {
-					__unregister_prot_hook(sk, false);
-					sk->sk_err = ENETDOWN;
-					if (!sock_flag(sk, SOCK_DEAD))
-						sk->sk_error_report(sk);
-				}
-				if (msg == NETDEV_UNREGISTER) {
-					packet_cached_dev_reset(po);
-					po->ifindex = -1;
-					if (po->prot_hook.dev)
-						dev_put(po->prot_hook.dev);
-					po->prot_hook.dev = NULL;
-				}
-				spin_unlock(&po->bind_lock);
-			}
+			packet_notifier_down(sk, dev,
+					     msg == NETDEV_UNREGISTER);
 			break;
 		case NETDEV_UP:
-			if (dev->ifindex == po->ifindex) {
-				spin_lock(&po->bind_lock);
-				if (po->num)
-					register_prot_hook(sk);
-				spin_unlock(&po->bind_lock);
-			}
+			packet_notifier_up(sk, dev);
 			break;
 		}
 	}
 	rcu_read_unlock();
+
 	return NOTIFY_DONE;
 }
 
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 3eedab29e4d7..1551cbe7b47b 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -116,6 +116,7 @@ struct packet_sock {
 	struct packet_ring_buffer	tx_ring;
 
 	struct tp4_umem			*umem;
+	struct tp4_netdev_parms __rcu	*zc;
 
 	int			copy_thresh;
 	spinlock_t		bind_lock;
-- 
2.11.0
