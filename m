From: frank.blaschka@de.ibm.com
Subject: [patch 08/13] [PATCH] af_iucv: add HiperSockets transport
Date: Mon, 08 Aug 2011 13:33:54 +0200
Message-ID: <20110808113516.138397393@de.ibm.com>
References: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:33055 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201Ab1HHLfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:32 -0400
Content-Disposition: inline; filename=net1117-af_iucv-add-HiperSockets-transport.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The current transport mechanism for af_iucv is the z/VM offered
communications facility IUCV. To provide equivalent support when
running Linux in an LPAR, HiperSockets transport is added to the
AF_IUCV address family. It requires explicit binding of an AF_IUCV
socket to a HiperSockets device. A new packet_type ETH_P_AF_IUCV
is announced. An af_iucv specific transport header is defined
preceding the skb data. A small protocol is implemented for
connecting and for flow control/congestion management.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
---
 include/net/iucv/af_iucv.h |   52 +++
 net/iucv/af_iucv.c         |  749 ++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 729 insertions(+), 72 deletions(-)

--- a/include/net/iucv/af_iucv.h
+++ b/include/net/iucv/af_iucv.h
@@ -14,6 +14,7 @@
 #include <linux/list.h>
 #include <linux/poll.h>
 #include <linux/socket.h>
+#include <net/iucv/iucv.h>
 
 #ifndef AF_IUCV
 #define AF_IUCV		32
@@ -33,6 +34,7 @@ enum {
 };
 
 #define IUCV_QUEUELEN_DEFAULT	65535
+#define IUCV_HIPER_MSGLIM_DEFAULT	128
 #define IUCV_CONN_TIMEOUT	(HZ * 40)
 #define IUCV_DISCONN_TIMEOUT	(HZ * 2)
 #define IUCV_CONN_IDLE_TIMEOUT	(HZ * 60)
@@ -57,8 +59,51 @@ struct sock_msg_q {
 	spinlock_t		lock;
 };
 
+#define AF_IUCV_FLAG_ACK 0x1
+#define AF_IUCV_FLAG_SYN 0x2
+#define AF_IUCV_FLAG_FIN 0x4
+#define AF_IUCV_FLAG_WIN 0x8
+
+struct af_iucv_trans_hdr {
+	u16 magic;
+	u8 version;
+	u8 flags;
+	u16 window;
+	char destNodeID[8];
+	char destUserID[8];
+	char destAppName[16];
+	char srcNodeID[8];
+	char srcUserID[8];
+	char srcAppName[16];             /* => 70 bytes */
+	struct iucv_message iucv_hdr;    /* => 33 bytes */
+	u8 pad;                          /* total 104 bytes */
+} __packed;
+
+enum iucv_tx_notify {
+	/* transmission of skb is completed and was successful */
+	TX_NOTIFY_OK = 0,
+	/* target is unreachable */
+	TX_NOTIFY_UNREACHABLE = 1,
+	/* transfer pending queue full */
+	TX_NOTIFY_TPQFULL = 2,
+	/* general error */
+	TX_NOTIFY_GENERALERROR = 3,
+	/* transmission of skb is pending - may interleave
+	 * with TX_NOTIFY_DELAYED_* */
+	TX_NOTIFY_PENDING = 4,
+	/* transmission of skb was done successfully (delayed) */
+	TX_NOTIFY_DELAYED_OK = 5,
+	/* target unreachable (detected delayed) */
+	TX_NOTIFY_DELAYED_UNREACHABLE = 6,
+	/* general error (detected delayed) */
+	TX_NOTIFY_DELAYED_GENERALERROR = 7,
+};
+
 #define iucv_sk(__sk) ((struct iucv_sock *) __sk)
 
+#define AF_IUCV_TRANS_IUCV 0
+#define AF_IUCV_TRANS_HIPER 1
+
 struct iucv_sock {
 	struct sock		sk;
 	char			src_user_id[8];
@@ -75,6 +120,13 @@ struct iucv_sock {
 	unsigned int		send_tag;
 	u8			flags;
 	u16			msglimit;
+	u16			msglimit_peer;
+	atomic_t		msg_sent;
+	atomic_t		msg_recv;
+	atomic_t		pendings;
+	int			transport;
+	void                    (*sk_txnotify)(struct sk_buff *skb,
+					       enum iucv_tx_notify n);
 };
 
 /* iucv socket options (SOL_IUCV) */
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -27,10 +27,9 @@
 #include <asm/cpcmd.h>
 #include <linux/kmod.h>
 
-#include <net/iucv/iucv.h>
 #include <net/iucv/af_iucv.h>
 
-#define VERSION "1.1"
+#define VERSION "1.2"
 
 static char iucv_userid[80];
 
@@ -92,6 +91,12 @@ do {									\
 static void iucv_sock_kill(struct sock *sk);
 static void iucv_sock_close(struct sock *sk);
 
+static int afiucv_hs_rcv(struct sk_buff *skb, struct net_device *dev,
+	struct packet_type *pt, struct net_device *orig_dev);
+static int afiucv_hs_send(struct iucv_message *imsg, struct sock *sock,
+		   struct sk_buff *skb, u8 flags);
+static void afiucv_hs_callback_txnotify(struct sk_buff *, enum iucv_tx_notify);
+
 /* Call Back functions */
 static void iucv_callback_rx(struct iucv_path *, struct iucv_message *);
 static void iucv_callback_txdone(struct iucv_path *, struct iucv_message *);
@@ -296,7 +301,11 @@ static inline int iucv_below_msglim(stru
 
 	if (sk->sk_state != IUCV_CONNECTED)
 		return 1;
-	return (skb_queue_len(&iucv->send_skb_q) < iucv->path->msglim);
+	if (iucv->transport == AF_IUCV_TRANS_IUCV)
+		return (skb_queue_len(&iucv->send_skb_q) < iucv->path->msglim);
+	else
+		return ((atomic_read(&iucv->msg_sent) < iucv->msglimit_peer) &&
+			(atomic_read(&iucv->pendings) <= 0));
 }
 
 /**
@@ -314,6 +323,79 @@ static void iucv_sock_wake_msglim(struct
 	rcu_read_unlock();
 }
 
+/**
+ * afiucv_hs_send() - send a message through HiperSockets transport
+ */
+static int afiucv_hs_send(struct iucv_message *imsg, struct sock *sock,
+		   struct sk_buff *skb, u8 flags)
+{
+	struct net *net = sock_net(sock);
+	struct iucv_sock *iucv = iucv_sk(sock);
+	struct af_iucv_trans_hdr *phs_hdr;
+	struct sk_buff *nskb;
+	int err, confirm_recv = 0;
+
+	memset(skb->head, 0, ETH_HLEN);
+	phs_hdr = (struct af_iucv_trans_hdr *)skb_push(skb,
+					sizeof(struct af_iucv_trans_hdr));
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	skb_push(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+	memset(phs_hdr, 0, sizeof(struct af_iucv_trans_hdr));
+
+	phs_hdr->magic = ETH_P_AF_IUCV;
+	phs_hdr->version = 1;
+	phs_hdr->flags = flags;
+	if (flags == AF_IUCV_FLAG_SYN)
+		phs_hdr->window = iucv->msglimit;
+	else if ((flags == AF_IUCV_FLAG_WIN) || !flags) {
+		confirm_recv = atomic_read(&iucv->msg_recv);
+		phs_hdr->window = confirm_recv;
+		if (confirm_recv)
+			phs_hdr->flags = phs_hdr->flags | AF_IUCV_FLAG_WIN;
+	}
+	memcpy(phs_hdr->destUserID, iucv->dst_user_id, 8);
+	memcpy(phs_hdr->destAppName, iucv->dst_name, 8);
+	memcpy(phs_hdr->srcUserID, iucv->src_user_id, 8);
+	memcpy(phs_hdr->srcAppName, iucv->src_name, 8);
+	ASCEBC(phs_hdr->destUserID, sizeof(phs_hdr->destUserID));
+	ASCEBC(phs_hdr->destAppName, sizeof(phs_hdr->destAppName));
+	ASCEBC(phs_hdr->srcUserID, sizeof(phs_hdr->srcUserID));
+	ASCEBC(phs_hdr->srcAppName, sizeof(phs_hdr->srcAppName));
+	if (imsg)
+		memcpy(&phs_hdr->iucv_hdr, imsg, sizeof(struct iucv_message));
+
+	rcu_read_lock();
+	skb->dev = dev_get_by_index_rcu(net, sock->sk_bound_dev_if);
+	rcu_read_unlock();
+	if (!skb->dev)
+		return -ENODEV;
+	if (!(skb->dev->flags & IFF_UP))
+		return -ENETDOWN;
+	if (skb->len > skb->dev->mtu) {
+		if (sock->sk_type == SOCK_SEQPACKET)
+			return -EMSGSIZE;
+		else
+			skb_trim(skb, skb->dev->mtu);
+	}
+	skb->protocol = ETH_P_AF_IUCV;
+	skb_shinfo(skb)->tx_flags |= SKBTX_DRV_NEEDS_SK_REF;
+	nskb = skb_clone(skb, GFP_ATOMIC);
+	if (!nskb)
+		return -ENOMEM;
+	skb_queue_tail(&iucv->send_skb_q, nskb);
+	err = dev_queue_xmit(skb);
+	if (err) {
+		skb_unlink(nskb, &iucv->send_skb_q);
+		kfree_skb(nskb);
+	} else {
+		atomic_sub(confirm_recv, &iucv->msg_recv);
+		WARN_ON(atomic_read(&iucv->msg_recv) < 0);
+	}
+	return err;
+}
+
 /* Timers */
 static void iucv_sock_timeout(unsigned long arg)
 {
@@ -382,6 +464,8 @@ static void iucv_sock_close(struct sock 
 	unsigned char user_data[16];
 	struct iucv_sock *iucv = iucv_sk(sk);
 	unsigned long timeo;
+	int err, blen;
+	struct sk_buff *skb;
 
 	iucv_sock_clear_timer(sk);
 	lock_sock(sk);
@@ -392,6 +476,20 @@ static void iucv_sock_close(struct sock 
 		break;
 
 	case IUCV_CONNECTED:
+		if (iucv->transport == AF_IUCV_TRANS_HIPER) {
+			/* send fin */
+			blen = sizeof(struct af_iucv_trans_hdr) + ETH_HLEN;
+			skb = sock_alloc_send_skb(sk, blen, 1, &err);
+			if (skb) {
+				skb_reserve(skb,
+					sizeof(struct af_iucv_trans_hdr) +
+					ETH_HLEN);
+				err = afiucv_hs_send(NULL, sk, skb,
+						     AF_IUCV_FLAG_FIN);
+			}
+			sk->sk_state = IUCV_DISCONN;
+			sk->sk_state_change(sk);
+		}
 	case IUCV_DISCONN:
 		sk->sk_state = IUCV_CLOSING;
 		sk->sk_state_change(sk);
@@ -461,10 +559,18 @@ static struct sock *iucv_sock_alloc(stru
 	spin_lock_init(&iucv->message_q.lock);
 	skb_queue_head_init(&iucv->backlog_skb_q);
 	iucv->send_tag = 0;
+	atomic_set(&iucv->pendings, 0);
 	iucv->flags = 0;
-	iucv->msglimit = IUCV_QUEUELEN_DEFAULT;
+	iucv->msglimit = 0;
+	atomic_set(&iucv->msg_sent, 0);
+	atomic_set(&iucv->msg_recv, 0);
 	iucv->path = NULL;
+	iucv->sk_txnotify = afiucv_hs_callback_txnotify;
 	memset(&iucv->src_user_id , 0, 32);
+	if (pr_iucv)
+		iucv->transport = AF_IUCV_TRANS_IUCV;
+	else
+		iucv->transport = AF_IUCV_TRANS_HIPER;
 
 	sk->sk_destruct = iucv_sock_destruct;
 	sk->sk_sndtimeo = IUCV_CONN_TIMEOUT;
@@ -595,7 +701,9 @@ static int iucv_sock_bind(struct socket 
 	struct sockaddr_iucv *sa = (struct sockaddr_iucv *) addr;
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv;
-	int err;
+	int err = 0;
+	struct net_device *dev;
+	char uid[9];
 
 	/* Verify the input sockaddr */
 	if (!addr || addr->sa_family != AF_IUCV)
@@ -614,19 +722,46 @@ static int iucv_sock_bind(struct socket 
 		err = -EADDRINUSE;
 		goto done_unlock;
 	}
-	if (iucv->path) {
-		err = 0;
+	if (iucv->path)
 		goto done_unlock;
-	}
 
 	/* Bind the socket */
-	memcpy(iucv->src_name, sa->siucv_name, 8);
 
-	/* Copy the user id */
-	memcpy(iucv->src_user_id, iucv_userid, 8);
-	sk->sk_state = IUCV_BOUND;
-	err = 0;
+	if (pr_iucv)
+		if (!memcmp(sa->siucv_user_id, iucv_userid, 8))
+			goto vm_bind; /* VM IUCV transport */
 
+	/* try hiper transport */
+	memcpy(uid, sa->siucv_user_id, sizeof(uid));
+	ASCEBC(uid, 8);
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
+		if (!memcmp(dev->perm_addr, uid, 8)) {
+			memcpy(iucv->src_name, sa->siucv_name, 8);
+			memcpy(iucv->src_user_id, sa->siucv_user_id, 8);
+			sock->sk->sk_bound_dev_if = dev->ifindex;
+			sk->sk_state = IUCV_BOUND;
+			iucv->transport = AF_IUCV_TRANS_HIPER;
+			if (!iucv->msglimit)
+				iucv->msglimit = IUCV_HIPER_MSGLIM_DEFAULT;
+			rcu_read_unlock();
+			goto done_unlock;
+		}
+	}
+	rcu_read_unlock();
+vm_bind:
+	if (pr_iucv) {
+		/* use local userid for backward compat */
+		memcpy(iucv->src_name, sa->siucv_name, 8);
+		memcpy(iucv->src_user_id, iucv_userid, 8);
+		sk->sk_state = IUCV_BOUND;
+		iucv->transport = AF_IUCV_TRANS_IUCV;
+		if (!iucv->msglimit)
+			iucv->msglimit = IUCV_QUEUELEN_DEFAULT;
+		goto done_unlock;
+	}
+	/* found no dev to bind */
+	err = -ENODEV;
 done_unlock:
 	/* Release the socket list lock */
 	write_unlock_bh(&iucv_sk_list.lock);
@@ -662,12 +797,33 @@ static int iucv_sock_autobind(struct soc
 
 	memcpy(&iucv->src_name, name, 8);
 
+	if (!iucv->msglimit)
+		iucv->msglimit = IUCV_QUEUELEN_DEFAULT;
+
 	return err;
 }
 
-/* Connect an unconnected socket */
-static int iucv_sock_connect(struct socket *sock, struct sockaddr *addr,
-			     int alen, int flags)
+static int afiucv_hs_connect(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct sk_buff *skb;
+	int blen = sizeof(struct af_iucv_trans_hdr) + ETH_HLEN;
+	int err = 0;
+
+	/* send syn */
+	skb = sock_alloc_send_skb(sk, blen, 1, &err);
+	if (!skb) {
+		err = -ENOMEM;
+		goto done;
+	}
+	skb->dev = NULL;
+	skb_reserve(skb, blen);
+	err = afiucv_hs_send(NULL, sk, skb, AF_IUCV_FLAG_SYN);
+done:
+	return err;
+}
+
+static int afiucv_path_connect(struct socket *sock, struct sockaddr *addr)
 {
 	struct sockaddr_iucv *sa = (struct sockaddr_iucv *) addr;
 	struct sock *sk = sock->sk;
@@ -675,27 +831,6 @@ static int iucv_sock_connect(struct sock
 	unsigned char user_data[16];
 	int err;
 
-	if (addr->sa_family != AF_IUCV || alen < sizeof(struct sockaddr_iucv))
-		return -EINVAL;
-
-	if (sk->sk_state != IUCV_OPEN && sk->sk_state != IUCV_BOUND)
-		return -EBADFD;
-
-	if (sk->sk_type != SOCK_STREAM && sk->sk_type != SOCK_SEQPACKET)
-		return -EINVAL;
-
-	if (sk->sk_state == IUCV_OPEN) {
-		err = iucv_sock_autobind(sk);
-		if (unlikely(err))
-			return err;
-	}
-
-	lock_sock(sk);
-
-	/* Set the destination information */
-	memcpy(iucv->dst_user_id, sa->siucv_user_id, 8);
-	memcpy(iucv->dst_name, sa->siucv_name, 8);
-
 	high_nmcpy(user_data, sa->siucv_name);
 	low_nmcpy(user_data, iucv->src_name);
 	ASCEBC(user_data, sizeof(user_data));
@@ -728,20 +863,61 @@ static int iucv_sock_connect(struct sock
 			err = -ECONNREFUSED;
 			break;
 		}
-		goto done;
 	}
+done:
+	return err;
+}
 
-	if (sk->sk_state != IUCV_CONNECTED) {
+/* Connect an unconnected socket */
+static int iucv_sock_connect(struct socket *sock, struct sockaddr *addr,
+			     int alen, int flags)
+{
+	struct sockaddr_iucv *sa = (struct sockaddr_iucv *) addr;
+	struct sock *sk = sock->sk;
+	struct iucv_sock *iucv = iucv_sk(sk);
+	int err;
+
+	if (addr->sa_family != AF_IUCV || alen < sizeof(struct sockaddr_iucv))
+		return -EINVAL;
+
+	if (sk->sk_state != IUCV_OPEN && sk->sk_state != IUCV_BOUND)
+		return -EBADFD;
+
+	if (sk->sk_state == IUCV_OPEN &&
+	    iucv->transport == AF_IUCV_TRANS_HIPER)
+		return -EBADFD; /* explicit bind required */
+
+	if (sk->sk_type != SOCK_STREAM && sk->sk_type != SOCK_SEQPACKET)
+		return -EINVAL;
+
+	if (sk->sk_state == IUCV_OPEN) {
+		err = iucv_sock_autobind(sk);
+		if (unlikely(err))
+			return err;
+	}
+
+	lock_sock(sk);
+
+	/* Set the destination information */
+	memcpy(iucv->dst_user_id, sa->siucv_user_id, 8);
+	memcpy(iucv->dst_name, sa->siucv_name, 8);
+
+	if (iucv->transport == AF_IUCV_TRANS_HIPER)
+		err = afiucv_hs_connect(sock);
+	else
+		err = afiucv_path_connect(sock, addr);
+	if (err)
+		goto done;
+
+	if (sk->sk_state != IUCV_CONNECTED)
 		err = iucv_sock_wait(sk, iucv_sock_in_state(sk, IUCV_CONNECTED,
 							    IUCV_DISCONN),
 				     sock_sndtimeo(sk, flags & O_NONBLOCK));
-	}
 
-	if (sk->sk_state == IUCV_DISCONN) {
+	if (sk->sk_state == IUCV_DISCONN || sk->sk_state == IUCV_CLOSED)
 		err = -ECONNREFUSED;
-	}
 
-	if (err) {
+	if (err && iucv->transport == AF_IUCV_TRANS_IUCV) {
 		pr_iucv->path_sever(iucv->path, NULL);
 		iucv_path_free(iucv->path);
 		iucv->path = NULL;
@@ -965,9 +1141,16 @@ static int iucv_sock_sendmsg(struct kioc
 	 * this is fine for SOCK_SEQPACKET (unless we want to support
 	 * segmented records using the MSG_EOR flag), but
 	 * for SOCK_STREAM we might want to improve it in future */
-	skb = sock_alloc_send_skb(sk, len, noblock, &err);
+	if (iucv->transport == AF_IUCV_TRANS_HIPER)
+		skb = sock_alloc_send_skb(sk,
+			len + sizeof(struct af_iucv_trans_hdr) + ETH_HLEN,
+			noblock, &err);
+	else
+		skb = sock_alloc_send_skb(sk, len, noblock, &err);
 	if (!skb)
 		goto out;
+	if (iucv->transport == AF_IUCV_TRANS_HIPER)
+		skb_reserve(skb, sizeof(struct af_iucv_trans_hdr) + ETH_HLEN);
 	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
 		err = -EFAULT;
 		goto fail;
@@ -988,6 +1171,15 @@ static int iucv_sock_sendmsg(struct kioc
 	/* increment and save iucv message tag for msg_completion cbk */
 	txmsg.tag = iucv->send_tag++;
 	memcpy(CB_TAG(skb), &txmsg.tag, CB_TAG_LEN);
+	if (iucv->transport == AF_IUCV_TRANS_HIPER) {
+		atomic_inc(&iucv->msg_sent);
+		err = afiucv_hs_send(&txmsg, sk, skb, 0);
+		if (err) {
+			atomic_dec(&iucv->msg_sent);
+			goto fail;
+		}
+		goto release;
+	}
 	skb_queue_tail(&iucv->send_skb_q, skb);
 
 	if (((iucv->path->flags & IUCV_IPRMDATA) & iucv->flags)
@@ -1028,6 +1220,7 @@ static int iucv_sock_sendmsg(struct kioc
 		goto fail;
 	}
 
+release:
 	release_sock(sk);
 	return len;
 
@@ -1160,7 +1353,8 @@ static int iucv_sock_recvmsg(struct kioc
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
 	unsigned int copied, rlen;
-	struct sk_buff *skb, *rskb, *cskb;
+	struct sk_buff *skb, *rskb, *cskb, *sskb;
+	int blen;
 	int err = 0;
 
 	if ((sk->sk_state == IUCV_DISCONN || sk->sk_state == IUCV_SEVERED) &&
@@ -1185,7 +1379,7 @@ static int iucv_sock_recvmsg(struct kioc
 	copied = min_t(unsigned int, rlen, len);
 
 	cskb = skb;
-	if (memcpy_toiovec(msg->msg_iov, cskb->data, copied)) {
+	if (skb_copy_datagram_iovec(cskb, 0, msg->msg_iov, copied)) {
 		if (!(flags & MSG_PEEK))
 			skb_queue_head(&sk->sk_receive_queue, skb);
 		return -EFAULT;
@@ -1223,6 +1417,7 @@ static int iucv_sock_recvmsg(struct kioc
 		}
 
 		kfree_skb(skb);
+		atomic_inc(&iucv->msg_recv);
 
 		/* Queue backlog skbs */
 		spin_lock_bh(&iucv->message_q.lock);
@@ -1239,6 +1434,24 @@ static int iucv_sock_recvmsg(struct kioc
 		if (skb_queue_empty(&iucv->backlog_skb_q)) {
 			if (!list_empty(&iucv->message_q.list))
 				iucv_process_message_q(sk);
+			if (atomic_read(&iucv->msg_recv) >=
+							iucv->msglimit / 2) {
+				/* send WIN to peer */
+				blen = sizeof(struct af_iucv_trans_hdr) +
+					ETH_HLEN;
+				sskb = sock_alloc_send_skb(sk, blen, 1, &err);
+				if (sskb) {
+					skb_reserve(sskb,
+						sizeof(struct af_iucv_trans_hdr)
+						+ ETH_HLEN);
+					err = afiucv_hs_send(NULL, sk, sskb,
+							     AF_IUCV_FLAG_WIN);
+				}
+				if (err) {
+					sk->sk_state = IUCV_DISCONN;
+					sk->sk_state_change(sk);
+				}
+			}
 		}
 		spin_unlock_bh(&iucv->message_q.lock);
 	}
@@ -1698,6 +1911,389 @@ static void iucv_callback_shutdown(struc
 	bh_unlock_sock(sk);
 }
 
+/***************** HiperSockets transport callbacks ********************/
+static void afiucv_swap_src_dest(struct sk_buff *skb)
+{
+	struct af_iucv_trans_hdr *trans_hdr =
+				(struct af_iucv_trans_hdr *)skb->data;
+	char tmpID[8];
+	char tmpName[8];
+
+	ASCEBC(trans_hdr->destUserID, sizeof(trans_hdr->destUserID));
+	ASCEBC(trans_hdr->destAppName, sizeof(trans_hdr->destAppName));
+	ASCEBC(trans_hdr->srcUserID, sizeof(trans_hdr->srcUserID));
+	ASCEBC(trans_hdr->srcAppName, sizeof(trans_hdr->srcAppName));
+	memcpy(tmpID, trans_hdr->srcUserID, 8);
+	memcpy(tmpName, trans_hdr->srcAppName, 8);
+	memcpy(trans_hdr->srcUserID, trans_hdr->destUserID, 8);
+	memcpy(trans_hdr->srcAppName, trans_hdr->destAppName, 8);
+	memcpy(trans_hdr->destUserID, tmpID, 8);
+	memcpy(trans_hdr->destAppName, tmpName, 8);
+	skb_push(skb, ETH_HLEN);
+	memset(skb->data, 0, ETH_HLEN);
+}
+
+/**
+ * afiucv_hs_callback_syn - react on received SYN
+ **/
+static int afiucv_hs_callback_syn(struct sock *sk, struct sk_buff *skb)
+{
+	struct sock *nsk;
+	struct iucv_sock *iucv, *niucv;
+	struct af_iucv_trans_hdr *trans_hdr;
+	int err;
+
+	iucv = iucv_sk(sk);
+	trans_hdr = (struct af_iucv_trans_hdr *)skb->data;
+	if (!iucv) {
+		/* no sock - connection refused */
+		afiucv_swap_src_dest(skb);
+		trans_hdr->flags = AF_IUCV_FLAG_SYN | AF_IUCV_FLAG_FIN;
+		err = dev_queue_xmit(skb);
+		goto out;
+	}
+
+	nsk = iucv_sock_alloc(NULL, sk->sk_type, GFP_ATOMIC);
+	bh_lock_sock(sk);
+	if ((sk->sk_state != IUCV_LISTEN) ||
+	    sk_acceptq_is_full(sk) ||
+	    !nsk) {
+		/* error on server socket - connection refused */
+		if (nsk)
+			sk_free(nsk);
+		afiucv_swap_src_dest(skb);
+		trans_hdr->flags = AF_IUCV_FLAG_SYN | AF_IUCV_FLAG_FIN;
+		err = dev_queue_xmit(skb);
+		bh_unlock_sock(sk);
+		goto out;
+	}
+
+	niucv = iucv_sk(nsk);
+	iucv_sock_init(nsk, sk);
+	niucv->transport = AF_IUCV_TRANS_HIPER;
+	niucv->msglimit = iucv->msglimit;
+	if (!trans_hdr->window)
+		niucv->msglimit_peer = IUCV_HIPER_MSGLIM_DEFAULT;
+	else
+		niucv->msglimit_peer = trans_hdr->window;
+	memcpy(niucv->dst_name, trans_hdr->srcAppName, 8);
+	memcpy(niucv->dst_user_id, trans_hdr->srcUserID, 8);
+	memcpy(niucv->src_name, iucv->src_name, 8);
+	memcpy(niucv->src_user_id, iucv->src_user_id, 8);
+	nsk->sk_bound_dev_if = sk->sk_bound_dev_if;
+	afiucv_swap_src_dest(skb);
+	trans_hdr->flags = AF_IUCV_FLAG_SYN | AF_IUCV_FLAG_ACK;
+	trans_hdr->window = niucv->msglimit;
+	/* if receiver acks the xmit connection is established */
+	err = dev_queue_xmit(skb);
+	if (!err) {
+		iucv_accept_enqueue(sk, nsk);
+		nsk->sk_state = IUCV_CONNECTED;
+		sk->sk_data_ready(sk, 1);
+	} else
+		iucv_sock_kill(nsk);
+	bh_unlock_sock(sk);
+
+out:
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * afiucv_hs_callback_synack() - react on received SYN-ACK
+ **/
+static int afiucv_hs_callback_synack(struct sock *sk, struct sk_buff *skb)
+{
+	struct iucv_sock *iucv = iucv_sk(sk);
+	struct af_iucv_trans_hdr *trans_hdr =
+					(struct af_iucv_trans_hdr *)skb->data;
+
+	if (!iucv)
+		goto out;
+	if (sk->sk_state != IUCV_BOUND)
+		goto out;
+	bh_lock_sock(sk);
+	iucv->msglimit_peer = trans_hdr->window;
+	sk->sk_state = IUCV_CONNECTED;
+	sk->sk_state_change(sk);
+	bh_unlock_sock(sk);
+out:
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * afiucv_hs_callback_synfin() - react on received SYN_FIN
+ **/
+static int afiucv_hs_callback_synfin(struct sock *sk, struct sk_buff *skb)
+{
+	struct iucv_sock *iucv = iucv_sk(sk);
+
+	if (!iucv)
+		goto out;
+	if (sk->sk_state != IUCV_BOUND)
+		goto out;
+	bh_lock_sock(sk);
+	sk->sk_state = IUCV_DISCONN;
+	sk->sk_state_change(sk);
+	bh_unlock_sock(sk);
+out:
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * afiucv_hs_callback_fin() - react on received FIN
+ **/
+static int afiucv_hs_callback_fin(struct sock *sk, struct sk_buff *skb)
+{
+	struct iucv_sock *iucv = iucv_sk(sk);
+
+	/* other end of connection closed */
+	if (iucv) {
+		bh_lock_sock(sk);
+		if (!list_empty(&iucv->accept_q))
+			sk->sk_state = IUCV_SEVERED;
+		else
+			sk->sk_state = IUCV_DISCONN;
+		sk->sk_state_change(sk);
+		bh_unlock_sock(sk);
+	}
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * afiucv_hs_callback_win() - react on received WIN
+ **/
+static int afiucv_hs_callback_win(struct sock *sk, struct sk_buff *skb)
+{
+	struct iucv_sock *iucv = iucv_sk(sk);
+	struct af_iucv_trans_hdr *trans_hdr =
+					(struct af_iucv_trans_hdr *)skb->data;
+
+	if (!iucv)
+		return NET_RX_SUCCESS;
+
+	if (sk->sk_state != IUCV_CONNECTED)
+		return NET_RX_SUCCESS;
+
+	atomic_sub(trans_hdr->window, &iucv->msg_sent);
+	iucv_sock_wake_msglim(sk);
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * afiucv_hs_callback_rx() - react on received data
+ **/
+static int afiucv_hs_callback_rx(struct sock *sk, struct sk_buff *skb)
+{
+	struct iucv_sock *iucv = iucv_sk(sk);
+
+	if (!iucv) {
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+
+	if (sk->sk_state != IUCV_CONNECTED) {
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+
+		/* write stuff from iucv_msg to skb cb */
+	if (skb->len <= sizeof(struct af_iucv_trans_hdr)) {
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+	skb_pull(skb, sizeof(struct af_iucv_trans_hdr));
+	skb_reset_transport_header(skb);
+	skb_reset_network_header(skb);
+	spin_lock(&iucv->message_q.lock);
+	if (skb_queue_empty(&iucv->backlog_skb_q)) {
+		if (sock_queue_rcv_skb(sk, skb)) {
+			/* handle rcv queue full */
+			skb_queue_tail(&iucv->backlog_skb_q, skb);
+		}
+	} else
+		skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, skb);
+	spin_unlock(&iucv->message_q.lock);
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * afiucv_hs_rcv() - base function for arriving data through HiperSockets
+ *                   transport
+ *                   called from netif RX softirq
+ **/
+static int afiucv_hs_rcv(struct sk_buff *skb, struct net_device *dev,
+	struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct hlist_node *node;
+	struct sock *sk;
+	struct iucv_sock *iucv;
+	struct af_iucv_trans_hdr *trans_hdr;
+	char nullstring[8];
+	int err = 0;
+
+	skb_pull(skb, ETH_HLEN);
+	trans_hdr = (struct af_iucv_trans_hdr *)skb->data;
+	EBCASC(trans_hdr->destAppName, sizeof(trans_hdr->destAppName));
+	EBCASC(trans_hdr->destUserID, sizeof(trans_hdr->destUserID));
+	EBCASC(trans_hdr->srcAppName, sizeof(trans_hdr->srcAppName));
+	EBCASC(trans_hdr->srcUserID, sizeof(trans_hdr->srcUserID));
+	memset(nullstring, 0, sizeof(nullstring));
+	iucv = NULL;
+	sk = NULL;
+	read_lock(&iucv_sk_list.lock);
+	sk_for_each(sk, node, &iucv_sk_list.head) {
+		if (trans_hdr->flags == AF_IUCV_FLAG_SYN) {
+			if ((!memcmp(&iucv_sk(sk)->src_name,
+				     trans_hdr->destAppName, 8)) &&
+			    (!memcmp(&iucv_sk(sk)->src_user_id,
+				     trans_hdr->destUserID, 8)) &&
+			    (!memcmp(&iucv_sk(sk)->dst_name, nullstring, 8)) &&
+			    (!memcmp(&iucv_sk(sk)->dst_user_id,
+				     nullstring, 8))) {
+				iucv = iucv_sk(sk);
+				break;
+			}
+		} else {
+			if ((!memcmp(&iucv_sk(sk)->src_name,
+				     trans_hdr->destAppName, 8)) &&
+			    (!memcmp(&iucv_sk(sk)->src_user_id,
+				     trans_hdr->destUserID, 8)) &&
+			    (!memcmp(&iucv_sk(sk)->dst_name,
+				     trans_hdr->srcAppName, 8)) &&
+			    (!memcmp(&iucv_sk(sk)->dst_user_id,
+				     trans_hdr->srcUserID, 8))) {
+				iucv = iucv_sk(sk);
+				break;
+			}
+		}
+	}
+	read_unlock(&iucv_sk_list.lock);
+	if (!iucv)
+		sk = NULL;
+
+	/* no sock
+	how should we send with no sock
+	1) send without sock no send rc checking?
+	2) introduce default sock to handle this cases
+
+	 SYN -> send SYN|ACK in good case, send SYN|FIN in bad case
+	 data -> send FIN
+	 SYN|ACK, SYN|FIN, FIN -> no action? */
+
+	switch (trans_hdr->flags) {
+	case AF_IUCV_FLAG_SYN:
+		/* connect request */
+		err = afiucv_hs_callback_syn(sk, skb);
+		break;
+	case (AF_IUCV_FLAG_SYN | AF_IUCV_FLAG_ACK):
+		/* connect request confirmed */
+		err = afiucv_hs_callback_synack(sk, skb);
+		break;
+	case (AF_IUCV_FLAG_SYN | AF_IUCV_FLAG_FIN):
+		/* connect request refused */
+		err = afiucv_hs_callback_synfin(sk, skb);
+		break;
+	case (AF_IUCV_FLAG_FIN):
+		/* close request */
+		err = afiucv_hs_callback_fin(sk, skb);
+		break;
+	case (AF_IUCV_FLAG_WIN):
+		err = afiucv_hs_callback_win(sk, skb);
+		if (skb->len > sizeof(struct af_iucv_trans_hdr))
+			err = afiucv_hs_callback_rx(sk, skb);
+		else
+			kfree(skb);
+		break;
+	case 0:
+		/* plain data frame */
+		err = afiucv_hs_callback_rx(sk, skb);
+		break;
+	default:
+		;
+	}
+
+	return err;
+}
+
+/**
+ * afiucv_hs_callback_txnotify() - handle send notifcations from HiperSockets
+ *                                 transport
+ **/
+static void afiucv_hs_callback_txnotify(struct sk_buff *skb,
+					enum iucv_tx_notify n)
+{
+	struct sock *isk = skb->sk;
+	struct sock *sk = NULL;
+	struct iucv_sock *iucv = NULL;
+	struct sk_buff_head *list;
+	struct sk_buff *list_skb;
+	struct sk_buff *this = NULL;
+	unsigned long flags;
+	struct hlist_node *node;
+
+	read_lock(&iucv_sk_list.lock);
+	sk_for_each(sk, node, &iucv_sk_list.head)
+		if (sk == isk) {
+			iucv = iucv_sk(sk);
+			break;
+		}
+	read_unlock(&iucv_sk_list.lock);
+
+	if (!iucv)
+		return;
+
+	bh_lock_sock(sk);
+	list = &iucv->send_skb_q;
+	list_skb = list->next;
+	if (skb_queue_empty(list))
+		goto out_unlock;
+
+	spin_lock_irqsave(&list->lock, flags);
+	while (list_skb != (struct sk_buff *)list) {
+		if (skb_shinfo(list_skb) == skb_shinfo(skb)) {
+			this = list_skb;
+			switch (n) {
+			case TX_NOTIFY_OK:
+				__skb_unlink(this, list);
+				iucv_sock_wake_msglim(sk);
+				kfree_skb(this);
+				break;
+			case TX_NOTIFY_PENDING:
+				atomic_inc(&iucv->pendings);
+				break;
+			case TX_NOTIFY_DELAYED_OK:
+				__skb_unlink(this, list);
+				atomic_dec(&iucv->pendings);
+				if (atomic_read(&iucv->pendings) <= 0)
+					iucv_sock_wake_msglim(sk);
+				kfree_skb(this);
+				break;
+			case TX_NOTIFY_UNREACHABLE:
+			case TX_NOTIFY_DELAYED_UNREACHABLE:
+			case TX_NOTIFY_TPQFULL: /* not yet used */
+			case TX_NOTIFY_GENERALERROR:
+			case TX_NOTIFY_DELAYED_GENERALERROR:
+				__skb_unlink(this, list);
+				kfree_skb(this);
+				if (!list_empty(&iucv->accept_q))
+					sk->sk_state = IUCV_SEVERED;
+				else
+					sk->sk_state = IUCV_DISCONN;
+				sk->sk_state_change(sk);
+				break;
+			}
+			break;
+		}
+		list_skb = list_skb->next;
+	}
+	spin_unlock_irqrestore(&list->lock, flags);
+
+out_unlock:
+	bh_unlock_sock(sk);
+}
 static const struct proto_ops iucv_sock_ops = {
 	.family		= PF_IUCV,
 	.owner		= THIS_MODULE,
@@ -1724,7 +2320,12 @@ static const struct net_proto_family iuc
 	.create	= iucv_sock_create,
 };
 
-static int __init afiucv_iucv_init(void)
+static struct packet_type iucv_packet_type = {
+	.type = cpu_to_be16(ETH_P_AF_IUCV),
+	.func = afiucv_hs_rcv,
+};
+
+static int afiucv_iucv_init(void)
 {
 	int err;
 
@@ -1763,24 +2364,22 @@ static int __init afiucv_init(void)
 {
 	int err;
 
-	if (!MACHINE_IS_VM) {
-		pr_err("The af_iucv module cannot be loaded"
-		       " without z/VM\n");
-		err = -EPROTONOSUPPORT;
-		goto out;
-	}
-	cpcmd("QUERY USERID", iucv_userid, sizeof(iucv_userid), &err);
-	if (unlikely(err)) {
-		WARN_ON(err);
-		err = -EPROTONOSUPPORT;
-		goto out;
-	}
+	if (MACHINE_IS_VM) {
+		cpcmd("QUERY USERID", iucv_userid, sizeof(iucv_userid), &err);
+		if (unlikely(err)) {
+			WARN_ON(err);
+			err = -EPROTONOSUPPORT;
+			goto out;
+		}
 
-	pr_iucv = try_then_request_module(symbol_get(iucv_if), "iucv");
-	if (!pr_iucv) {
-		printk(KERN_WARNING "iucv_if lookup failed\n");
-		err = -EPROTONOSUPPORT;
-		goto out;
+		pr_iucv = try_then_request_module(symbol_get(iucv_if), "iucv");
+		if (!pr_iucv) {
+			printk(KERN_WARNING "iucv_if lookup failed\n");
+			memset(&iucv_userid, 0, sizeof(iucv_userid));
+		}
+	} else {
+		memset(&iucv_userid, 0, sizeof(iucv_userid));
+		pr_iucv = NULL;
 	}
 
 	err = proto_register(&iucv_proto, 0);
@@ -1790,10 +2389,12 @@ static int __init afiucv_init(void)
 	if (err)
 		goto out_proto;
 
-	err = afiucv_iucv_init();
-	if (err)
-		goto out_sock;
-
+	if (pr_iucv) {
+		err = afiucv_iucv_init();
+		if (err)
+			goto out_sock;
+	}
+	dev_add_pack(&iucv_packet_type);
 	return 0;
 
 out_sock:
@@ -1808,10 +2409,13 @@ out:
 
 static void __exit afiucv_exit(void)
 {
-	device_unregister(af_iucv_dev);
-	driver_unregister(&af_iucv_driver);
-	pr_iucv->iucv_unregister(&af_iucv_handler, 0);
-	symbol_put(iucv_if);
+	if (pr_iucv) {
+		device_unregister(af_iucv_dev);
+		driver_unregister(&af_iucv_driver);
+		pr_iucv->iucv_unregister(&af_iucv_handler, 0);
+		symbol_put(iucv_if);
+	}
+	dev_remove_pack(&iucv_packet_type);
 	sock_unregister(PF_IUCV);
 	proto_unregister(&iucv_proto);
 }
@@ -1824,3 +2428,4 @@ MODULE_DESCRIPTION("IUCV Sockets ver " V
 MODULE_VERSION(VERSION);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_NETPROTO(PF_IUCV);
+

