From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 5/7] caif: Rewritten socket implementation
Date: Wed, 28 Apr 2010 20:54:38 +0200
Message-ID: <1272480880-30672-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-3-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	sjurbr@gmail.com, linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:35420 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756571Ab0D1Sz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:55:28 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00K3ZOKDDG80@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:25 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00MYUOK4Q560@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:25 +0200 (CEST)
In-reply-to: <1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Changes:
 This is a complete re-write of the socket layer. Making the socket
 implementation more aligned with the other socket layers and using more
 of the support functions available in sock.c. Lots of code is copied
 from af_unix (and some from af_irda).
 Non-blocking mode should be working as well.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/linux/caif/caif_socket.h |    5 +-
 net/caif/caif_socket.c           | 2643 ++++++++++++++++++--------------------
 2 files changed, 1255 insertions(+), 1393 deletions(-)
 rewrite net/caif/caif_socket.c (76%)

diff --git a/include/linux/caif/caif_socket.h b/include/linux/caif/caif_socket.h
index 8e5c844..2a61eb1 100644
--- a/include/linux/caif/caif_socket.h
+++ b/include/linux/caif/caif_socket.h
@@ -16,7 +16,6 @@
 #include <sys/socket.h>
 #endif
 
-
 /**
  * enum caif_link_selector -    Physical Link Selection.
  * @CAIF_LINK_HIGH_BANDW:	Physical interface for high-bandwidth
@@ -59,7 +58,7 @@ enum caif_channel_priority {
 /**
  * enum caif_protocol_type  -	CAIF Channel type.
  * @CAIFPROTO_AT:		Classic AT channel.
- * @CAIFPROTO_DATAGRAM:		Datagram channel.
+ * @CAIFPROTO_DATAGRAM:	Datagram channel.
  * @CAIFPROTO_DATAGRAM_LOOP:	Datagram loopback channel, used for testing.
  * @CAIFPROTO_UTIL:		Utility (Psock) channel.
  * @CAIFPROTO_RFM:		Remote File Manager
@@ -87,6 +86,7 @@ enum caif_at_type {
 
 /**
  * struct sockaddr_caif - the sockaddr structure for CAIF sockets.
+ * @family:		     Address family number, must be AF_CAIF.
  * @u:			     Union of address data 'switched' by family.
  * :
  * @u.at:                    Applies when family = CAIFPROTO_AT.
@@ -153,6 +153,7 @@ struct sockaddr_caif {
  *
  *
  * This enum defines the CAIF Socket options to be used on a socket
+ * of type PF_CAIF.
  *
  */
 enum caif_socket_opts {
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
dissimilarity index 76%
index d455375..c3a70c5 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1,1391 +1,1252 @@
-/*
- * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland sjur.brandeland@stericsson.com
- *		Per Sigmond per.sigmond@stericsson.com
- * License terms: GNU General Public License (GPL) version 2
- */
-
-#include <linux/fs.h>
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/sched.h>
-#include <linux/spinlock.h>
-#include <linux/mutex.h>
-#include <linux/list.h>
-#include <linux/wait.h>
-#include <linux/poll.h>
-#include <linux/tcp.h>
-#include <linux/uaccess.h>
-#include <asm/atomic.h>
-
-#include <linux/caif/caif_socket.h>
-#include <net/caif/caif_layer.h>
-#include <net/caif/caif_dev.h>
-#include <net/caif/cfpkt.h>
-
-MODULE_LICENSE("GPL");
-
-#define CHNL_SKT_READ_QUEUE_HIGH 200
-#define CHNL_SKT_READ_QUEUE_LOW 100
-
-static int caif_sockbuf_size = 40000;
-static atomic_t caif_nr_socks = ATOMIC_INIT(0);
-
-#define CONN_STATE_OPEN_BIT	      1
-#define CONN_STATE_PENDING_BIT	      2
-#define CONN_STATE_PEND_DESTROY_BIT   3
-#define CONN_REMOTE_SHUTDOWN_BIT      4
-
-#define TX_FLOW_ON_BIT		      1
-#define RX_FLOW_ON_BIT		      2
-
-#define STATE_IS_OPEN(cf_sk) test_bit(CONN_STATE_OPEN_BIT,\
-				    (void *) &(cf_sk)->conn_state)
-#define STATE_IS_REMOTE_SHUTDOWN(cf_sk) test_bit(CONN_REMOTE_SHUTDOWN_BIT,\
-				    (void *) &(cf_sk)->conn_state)
-#define STATE_IS_PENDING(cf_sk) test_bit(CONN_STATE_PENDING_BIT,\
-				       (void *) &(cf_sk)->conn_state)
-#define STATE_IS_PENDING_DESTROY(cf_sk) test_bit(CONN_STATE_PEND_DESTROY_BIT,\
-				       (void *) &(cf_sk)->conn_state)
-
-#define SET_STATE_PENDING_DESTROY(cf_sk) set_bit(CONN_STATE_PEND_DESTROY_BIT,\
-				    (void *) &(cf_sk)->conn_state)
-#define SET_STATE_OPEN(cf_sk) set_bit(CONN_STATE_OPEN_BIT,\
-				    (void *) &(cf_sk)->conn_state)
-#define SET_STATE_CLOSED(cf_sk) clear_bit(CONN_STATE_OPEN_BIT,\
-					(void *) &(cf_sk)->conn_state)
-#define SET_PENDING_ON(cf_sk) set_bit(CONN_STATE_PENDING_BIT,\
-				    (void *) &(cf_sk)->conn_state)
-#define SET_PENDING_OFF(cf_sk) clear_bit(CONN_STATE_PENDING_BIT,\
-				       (void *) &(cf_sk)->conn_state)
-#define SET_REMOTE_SHUTDOWN(cf_sk) set_bit(CONN_REMOTE_SHUTDOWN_BIT,\
-				    (void *) &(cf_sk)->conn_state)
-
-#define SET_REMOTE_SHUTDOWN_OFF(dev) clear_bit(CONN_REMOTE_SHUTDOWN_BIT,\
-				    (void *) &(dev)->conn_state)
-#define RX_FLOW_IS_ON(cf_sk) test_bit(RX_FLOW_ON_BIT,\
-				    (void *) &(cf_sk)->flow_state)
-#define TX_FLOW_IS_ON(cf_sk) test_bit(TX_FLOW_ON_BIT,\
-				    (void *) &(cf_sk)->flow_state)
-
-#define SET_RX_FLOW_OFF(cf_sk) clear_bit(RX_FLOW_ON_BIT,\
-				       (void *) &(cf_sk)->flow_state)
-#define SET_RX_FLOW_ON(cf_sk) set_bit(RX_FLOW_ON_BIT,\
-				    (void *) &(cf_sk)->flow_state)
-#define SET_TX_FLOW_OFF(cf_sk) clear_bit(TX_FLOW_ON_BIT,\
-				       (void *) &(cf_sk)->flow_state)
-#define SET_TX_FLOW_ON(cf_sk) set_bit(TX_FLOW_ON_BIT,\
-				    (void *) &(cf_sk)->flow_state)
-
-#define SKT_READ_FLAG 0x01
-#define SKT_WRITE_FLAG 0x02
-static struct dentry *debugfsdir;
-#include <linux/debugfs.h>
-
-#ifdef CONFIG_DEBUG_FS
-struct debug_fs_counter {
-	atomic_t num_open;
-	atomic_t num_close;
-	atomic_t num_init;
-	atomic_t num_init_resp;
-	atomic_t num_init_fail_resp;
-	atomic_t num_deinit;
-	atomic_t num_deinit_resp;
-	atomic_t num_remote_shutdown_ind;
-	atomic_t num_tx_flow_off_ind;
-	atomic_t num_tx_flow_on_ind;
-	atomic_t num_rx_flow_off;
-	atomic_t num_rx_flow_on;
-	atomic_t skb_in_use;
-	atomic_t skb_alloc;
-	atomic_t skb_free;
-};
-static struct debug_fs_counter cnt;
-#define	dbfs_atomic_inc(v) atomic_inc(v)
-#define	dbfs_atomic_dec(v) atomic_dec(v)
-#else
-#define	dbfs_atomic_inc(v)
-#define	dbfs_atomic_dec(v)
-#endif
-
-/* The AF_CAIF socket */
-struct caifsock {
-	/* NOTE: sk has to be the first member */
-	struct sock sk;
-	struct cflayer layer;
-	char name[CAIF_LAYER_NAME_SZ];
-	u32 conn_state;
-	u32 flow_state;
-	struct cfpktq *pktq;
-	int file_mode;
-	struct caif_connect_request conn_req;
-	int read_queue_len;
-	/* protect updates of read_queue_len */
-	spinlock_t read_queue_len_lock;
-	struct dentry *debugfs_socket_dir;
-};
-
-static void drain_queue(struct caifsock *cf_sk);
-
-/* Packet Receive Callback function called from CAIF Stack */
-static int caif_sktrecv_cb(struct cflayer *layr, struct cfpkt *pkt)
-{
-	struct caifsock *cf_sk;
-	int read_queue_high;
-	cf_sk = container_of(layr, struct caifsock, layer);
-
-	if (!STATE_IS_OPEN(cf_sk)) {
-		/*FIXME: This should be allowed finally!*/
-		pr_debug("CAIF: %s(): called after close request\n", __func__);
-		cfpkt_destroy(pkt);
-		return 0;
-	}
-	/* NOTE: This function may be called in Tasklet context! */
-
-	/* The queue has its own lock */
-	cfpkt_queue(cf_sk->pktq, pkt, 0);
-
-	spin_lock(&cf_sk->read_queue_len_lock);
-	cf_sk->read_queue_len++;
-
-	read_queue_high = (cf_sk->read_queue_len > CHNL_SKT_READ_QUEUE_HIGH);
-	spin_unlock(&cf_sk->read_queue_len_lock);
-
-	if (RX_FLOW_IS_ON(cf_sk) && read_queue_high) {
-		dbfs_atomic_inc(&cnt.num_rx_flow_off);
-		SET_RX_FLOW_OFF(cf_sk);
-
-		/* Send flow off (NOTE: must not sleep) */
-		pr_debug("CAIF: %s():"
-			" sending flow OFF (queue len = %d)\n",
-			__func__,
-		     cf_sk->read_queue_len);
-		caif_assert(cf_sk->layer.dn);
-		caif_assert(cf_sk->layer.dn->ctrlcmd);
-
-		(void) cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
-					       CAIF_MODEMCMD_FLOW_OFF_REQ);
-	}
-
-	/* Signal reader that data is available. */
-
-	wake_up_interruptible(sk_sleep(&cf_sk->sk));
-
-	return 0;
-}
-
-/* Packet Flow Control Callback function called from CAIF */
-static void caif_sktflowctrl_cb(struct cflayer *layr,
-				enum caif_ctrlcmd flow,
-				int phyid)
-{
-	struct caifsock *cf_sk;
-
-	/* NOTE: This function may be called in Tasklet context! */
-	pr_debug("CAIF: %s(): flowctrl func called: %s.\n",
-		      __func__,
-		      flow == CAIF_CTRLCMD_FLOW_ON_IND ? "ON" :
-		      flow == CAIF_CTRLCMD_FLOW_OFF_IND ? "OFF" :
-		      flow == CAIF_CTRLCMD_INIT_RSP ? "INIT_RSP" :
-		      flow == CAIF_CTRLCMD_DEINIT_RSP ? "DEINIT_RSP" :
-		      flow == CAIF_CTRLCMD_INIT_FAIL_RSP ? "INIT_FAIL_RSP" :
-		      flow ==
-		      CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND ? "REMOTE_SHUTDOWN" :
-		      "UKNOWN CTRL COMMAND");
-
-	if (layr == NULL)
-		return;
-
-	cf_sk = container_of(layr, struct caifsock, layer);
-
-	switch (flow) {
-	case CAIF_CTRLCMD_FLOW_ON_IND:
-		dbfs_atomic_inc(&cnt.num_tx_flow_on_ind);
-		/* Signal reader that data is available. */
-		SET_TX_FLOW_ON(cf_sk);
-		wake_up_interruptible(sk_sleep(&cf_sk->sk));
-		break;
-
-	case CAIF_CTRLCMD_FLOW_OFF_IND:
-		dbfs_atomic_inc(&cnt.num_tx_flow_off_ind);
-		SET_TX_FLOW_OFF(cf_sk);
-		break;
-
-	case CAIF_CTRLCMD_INIT_RSP:
-		dbfs_atomic_inc(&cnt.num_init_resp);
-		/* Signal reader that data is available. */
-		caif_assert(STATE_IS_OPEN(cf_sk));
-		SET_PENDING_OFF(cf_sk);
-		SET_TX_FLOW_ON(cf_sk);
-		wake_up_interruptible(sk_sleep(&cf_sk->sk));
-		break;
-
-	case CAIF_CTRLCMD_DEINIT_RSP:
-		dbfs_atomic_inc(&cnt.num_deinit_resp);
-		caif_assert(!STATE_IS_OPEN(cf_sk));
-		SET_PENDING_OFF(cf_sk);
-		if (!STATE_IS_PENDING_DESTROY(cf_sk)) {
-			if (sk_sleep(&cf_sk->sk) != NULL)
-				wake_up_interruptible(sk_sleep(&cf_sk->sk));
-		}
-		dbfs_atomic_inc(&cnt.num_deinit);
-		sock_put(&cf_sk->sk);
-		break;
-
-	case CAIF_CTRLCMD_INIT_FAIL_RSP:
-		dbfs_atomic_inc(&cnt.num_init_fail_resp);
-		caif_assert(STATE_IS_OPEN(cf_sk));
-		SET_STATE_CLOSED(cf_sk);
-		SET_PENDING_OFF(cf_sk);
-		SET_TX_FLOW_OFF(cf_sk);
-		wake_up_interruptible(sk_sleep(&cf_sk->sk));
-		break;
-
-	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
-		dbfs_atomic_inc(&cnt.num_remote_shutdown_ind);
-		SET_REMOTE_SHUTDOWN(cf_sk);
-		/* Use sk_shutdown to indicate remote shutdown indication */
-		cf_sk->sk.sk_shutdown |= RCV_SHUTDOWN;
-		cf_sk->file_mode = 0;
-		wake_up_interruptible(sk_sleep(&cf_sk->sk));
-		break;
-
-	default:
-		pr_debug("CAIF: %s(): Unexpected flow command %d\n",
-			      __func__, flow);
-	}
-}
-
-static void skb_destructor(struct sk_buff *skb)
-{
-	dbfs_atomic_inc(&cnt.skb_free);
-	dbfs_atomic_dec(&cnt.skb_in_use);
-}
-
-
-static int caif_recvmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *m, size_t buf_len, int flags)
-
-{
-	struct sock *sk = sock->sk;
-	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
-	struct cfpkt *pkt = NULL;
-	size_t len;
-	int result;
-	struct sk_buff *skb;
-	ssize_t ret = -EIO;
-	int read_queue_low;
-
-	if (cf_sk == NULL) {
-		pr_debug("CAIF: %s(): private_data not set!\n",
-			      __func__);
-		ret = -EBADFD;
-		goto read_error;
-	}
-
-	/* Don't do multiple iovec entries yet */
-	if (m->msg_iovlen != 1)
-		return -EOPNOTSUPP;
-
-	if (unlikely(!buf_len))
-		return -EINVAL;
-
-	lock_sock(&(cf_sk->sk));
-
-	caif_assert(cf_sk->pktq);
-
-	if (!STATE_IS_OPEN(cf_sk)) {
-		/* Socket is closed or closing. */
-		if (!STATE_IS_PENDING(cf_sk)) {
-			pr_debug("CAIF: %s(): socket is closed (by remote)\n",
-				 __func__);
-			ret = -EPIPE;
-		} else {
-			pr_debug("CAIF: %s(): socket is closing..\n", __func__);
-			ret = -EBADF;
-		}
-		goto read_error;
-	}
-	/* Socket is open or opening. */
-	if (STATE_IS_PENDING(cf_sk)) {
-		pr_debug("CAIF: %s(): socket is opening...\n", __func__);
-
-		if (flags & MSG_DONTWAIT) {
-			/* We can't block. */
-			pr_debug("CAIF: %s():state pending and MSG_DONTWAIT\n",
-				 __func__);
-			ret = -EAGAIN;
-			goto read_error;
-		}
-
-		/*
-		 * Blocking mode; state is pending and we need to wait
-		 * for its conclusion.
-		 */
-		release_sock(&cf_sk->sk);
-
-		result =
-		    wait_event_interruptible(*sk_sleep(&cf_sk->sk),
-					     !STATE_IS_PENDING(cf_sk));
-
-		lock_sock(&(cf_sk->sk));
-
-		if (result == -ERESTARTSYS) {
-			pr_debug("CAIF: %s(): wait_event_interruptible"
-				 " woken by a signal (1)", __func__);
-			ret = -ERESTARTSYS;
-			goto read_error;
-		}
-	}
-
-	if (STATE_IS_REMOTE_SHUTDOWN(cf_sk) ||
-		!STATE_IS_OPEN(cf_sk) ||
-		STATE_IS_PENDING(cf_sk)) {
-
-		pr_debug("CAIF: %s(): socket closed\n",
-			__func__);
-		ret = -ESHUTDOWN;
-		goto read_error;
-	}
-
-	/*
-	 * Block if we don't have any received buffers.
-	 * The queue has its own lock.
-	 */
-	while ((pkt = cfpkt_qpeek(cf_sk->pktq)) == NULL) {
-
-		if (flags & MSG_DONTWAIT) {
-			pr_debug("CAIF: %s(): MSG_DONTWAIT\n", __func__);
-			ret = -EAGAIN;
-			goto read_error;
-		}
-		trace_printk("CAIF: %s() wait_event\n", __func__);
-
-		/* Let writers in. */
-		release_sock(&cf_sk->sk);
-
-		/* Block reader until data arrives or socket is closed. */
-		if (wait_event_interruptible(*sk_sleep(&cf_sk->sk),
-					cfpkt_qpeek(cf_sk->pktq)
-					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
-					|| !STATE_IS_OPEN(cf_sk)) ==
-		    -ERESTARTSYS) {
-			pr_debug("CAIF: %s():"
-				" wait_event_interruptible woken by "
-				"a signal, signal_pending(current) = %d\n",
-				__func__,
-				signal_pending(current));
-			return -ERESTARTSYS;
-		}
-
-		trace_printk("CAIF: %s() awake\n", __func__);
-		if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
-			pr_debug("CAIF: %s(): "
-				 "received remote_shutdown indication\n",
-				 __func__);
-			ret = -ESHUTDOWN;
-			goto read_error_no_unlock;
-		}
-
-		/* I want to be alone on cf_sk (except status and queue). */
-		lock_sock(&(cf_sk->sk));
-
-		if (!STATE_IS_OPEN(cf_sk)) {
-			/* Someone closed the link, report error. */
-			pr_debug("CAIF: %s(): remote end shutdown!\n",
-				      __func__);
-			ret = -EPIPE;
-			goto read_error;
-		}
-	}
-
-	/* The queue has its own lock. */
-	len = cfpkt_getlen(pkt);
-
-	/* Check max length that can be copied. */
-	if (len <= buf_len)
-		pkt = cfpkt_dequeue(cf_sk->pktq);
-	else {
-		pr_debug("CAIF: %s(): user buffer too small (%ld,%ld)\n",
-			 __func__, (long) len, (long) buf_len);
-		if (sock->type == SOCK_SEQPACKET) {
-			ret = -EMSGSIZE;
-			goto read_error;
-		}
-		len = buf_len;
-	}
-
-
-	spin_lock(&cf_sk->read_queue_len_lock);
-	cf_sk->read_queue_len--;
-	read_queue_low = (cf_sk->read_queue_len < CHNL_SKT_READ_QUEUE_LOW);
-	spin_unlock(&cf_sk->read_queue_len_lock);
-
-	if (!RX_FLOW_IS_ON(cf_sk) && read_queue_low) {
-		dbfs_atomic_inc(&cnt.num_rx_flow_on);
-		SET_RX_FLOW_ON(cf_sk);
-
-		/* Send flow on. */
-		pr_debug("CAIF: %s(): sending flow ON (queue len = %d)\n",
-			 __func__, cf_sk->read_queue_len);
-		caif_assert(cf_sk->layer.dn);
-		caif_assert(cf_sk->layer.dn->ctrlcmd);
-		(void) cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
-					       CAIF_MODEMCMD_FLOW_ON_REQ);
-
-		caif_assert(cf_sk->read_queue_len >= 0);
-	}
-
-	skb = cfpkt_tonative(pkt);
-	result = skb_copy_datagram_iovec(skb, 0, m->msg_iov, len);
-	skb_pull(skb, len);
-
-	if (result) {
-		pr_debug("CAIF: %s(): copy to_iovec failed\n", __func__);
-		cfpkt_destroy(pkt);
-		ret = -EFAULT;
-		goto read_error;
-	}
-
-	/* Free packet and remove from queue */
-	if (skb->len == 0)
-		skb_free_datagram(sk, skb);
-
-	/* Let the others in. */
-	release_sock(&cf_sk->sk);
-	return len;
-
-read_error:
-	release_sock(&cf_sk->sk);
-read_error_no_unlock:
-	return ret;
-}
-
-/* Send a signal as a consequence of sendmsg, sendto or caif_sendmsg. */
-static int caif_sendmsg(struct kiocb *kiocb, struct socket *sock,
-			struct msghdr *msg, size_t len)
-{
-
-	struct sock *sk = sock->sk;
-	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
-	size_t payload_size = msg->msg_iov->iov_len;
-	struct cfpkt *pkt = NULL;
-	struct caif_payload_info info;
-	unsigned char *txbuf;
-	ssize_t ret = -EIO;
-	int result;
-	struct sk_buff *skb;
-	caif_assert(msg->msg_iovlen == 1);
-
-	if (cf_sk == NULL) {
-		pr_debug("CAIF: %s(): private_data not set!\n",
-			      __func__);
-		ret = -EBADFD;
-		goto write_error_no_unlock;
-	}
-
-	if (unlikely(msg->msg_iov->iov_base == NULL)) {
-		pr_warning("CAIF: %s(): Buffer is NULL.\n", __func__);
-		ret = -EINVAL;
-		goto write_error_no_unlock;
-	}
-
-	if (payload_size > CAIF_MAX_PAYLOAD_SIZE) {
-		pr_debug("CAIF: %s(): buffer too long\n", __func__);
-		if (sock->type == SOCK_SEQPACKET) {
-			ret = -EINVAL;
-			goto write_error_no_unlock;
-		}
-		payload_size = CAIF_MAX_PAYLOAD_SIZE;
-	}
-
-	/* I want to be alone on cf_sk (except status and queue) */
-	lock_sock(&(cf_sk->sk));
-
-	caif_assert(cf_sk->pktq);
-
-	if (!STATE_IS_OPEN(cf_sk)) {
-		/* Socket is closed or closing */
-		if (!STATE_IS_PENDING(cf_sk)) {
-			pr_debug("CAIF: %s(): socket is closed (by remote)\n",
-				 __func__);
-			ret = -EPIPE;
-		} else {
-			pr_debug("CAIF: %s(): socket is closing...\n",
-				 __func__);
-			ret = -EBADF;
-		}
-		goto write_error;
-	}
-
-	/* Socket is open or opening */
-	if (STATE_IS_PENDING(cf_sk)) {
-		pr_debug("CAIF: %s(): socket is opening...\n", __func__);
-
-		if (msg->msg_flags & MSG_DONTWAIT) {
-			/* We can't block */
-			trace_printk("CAIF: %s():state pending:"
-				     "state=MSG_DONTWAIT\n", __func__);
-			ret = -EAGAIN;
-			goto write_error;
-		}
-		/* Let readers in */
-		release_sock(&cf_sk->sk);
-
-		/*
-		 * Blocking mode; state is pending and we need to wait
-		 * for its conclusion.
-		 */
-		result =
-		    wait_event_interruptible(*sk_sleep(&cf_sk->sk),
-					     !STATE_IS_PENDING(cf_sk));
-		/* I want to be alone on cf_sk (except status and queue) */
-		lock_sock(&(cf_sk->sk));
-
-		if (result == -ERESTARTSYS) {
-			pr_debug("CAIF: %s(): wait_event_interruptible"
-				 " woken by a signal (1)", __func__);
-			ret = -ERESTARTSYS;
-			goto write_error;
-		}
-	}
-	if (STATE_IS_REMOTE_SHUTDOWN(cf_sk) ||
-		!STATE_IS_OPEN(cf_sk) ||
-		STATE_IS_PENDING(cf_sk)) {
-
-		pr_debug("CAIF: %s(): socket closed\n",
-			__func__);
-		ret = -ESHUTDOWN;
-		goto write_error;
-	}
-
-	if (!TX_FLOW_IS_ON(cf_sk)) {
-
-		/* Flow is off. Check non-block flag */
-		if (msg->msg_flags & MSG_DONTWAIT) {
-			trace_printk("CAIF: %s(): MSG_DONTWAIT and tx flow off",
-				 __func__);
-			ret = -EAGAIN;
-			goto write_error;
-		}
-
-		/* release lock before waiting */
-		release_sock(&cf_sk->sk);
-
-		/* Wait until flow is on or socket is closed */
-		if (wait_event_interruptible(*sk_sleep(&cf_sk->sk),
-					TX_FLOW_IS_ON(cf_sk)
-					|| !STATE_IS_OPEN(cf_sk)
-					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
-					) == -ERESTARTSYS) {
-			pr_debug("CAIF: %s():"
-				 " wait_event_interruptible woken by a signal",
-				 __func__);
-			ret = -ERESTARTSYS;
-			goto write_error_no_unlock;
-		}
-
-		/* I want to be alone on cf_sk (except status and queue) */
-		lock_sock(&(cf_sk->sk));
-
-		if (!STATE_IS_OPEN(cf_sk)) {
-			/* someone closed the link, report error */
-			pr_debug("CAIF: %s(): remote end shutdown!\n",
-				      __func__);
-			ret = -EPIPE;
-			goto write_error;
-		}
-
-		if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
-			pr_debug("CAIF: %s(): "
-				 "received remote_shutdown indication\n",
-				 __func__);
-			ret = -ESHUTDOWN;
-			goto write_error;
-		}
-	}
-
-	pkt = cfpkt_create(payload_size);
-	skb = (struct sk_buff *)pkt;
-	skb->destructor = skb_destructor;
-	skb->sk = sk;
-	dbfs_atomic_inc(&cnt.skb_alloc);
-	dbfs_atomic_inc(&cnt.skb_in_use);
-	if (cfpkt_raw_append(pkt, (void **) &txbuf, payload_size) < 0) {
-		pr_debug("CAIF: %s(): cfpkt_raw_append failed\n", __func__);
-		cfpkt_destroy(pkt);
-		ret = -EINVAL;
-		goto write_error;
-	}
-
-	/* Copy data into buffer. */
-	if (copy_from_user(txbuf, msg->msg_iov->iov_base, payload_size)) {
-		pr_debug("CAIF: %s(): copy_from_user returned non zero.\n",
-			 __func__);
-		cfpkt_destroy(pkt);
-		ret = -EINVAL;
-		goto write_error;
-	}
-	memset(&info, 0, sizeof(info));
-
-	/* Send the packet down the stack. */
-	caif_assert(cf_sk->layer.dn);
-	caif_assert(cf_sk->layer.dn->transmit);
-
-	do {
-		ret = cf_sk->layer.dn->transmit(cf_sk->layer.dn, pkt);
-
-		if (likely((ret >= 0) || (ret != -EAGAIN)))
-			break;
-
-		/* EAGAIN - retry */
-		if (msg->msg_flags & MSG_DONTWAIT) {
-			pr_debug("CAIF: %s(): NONBLOCK and transmit failed,"
-				 " error = %ld\n", __func__, (long) ret);
-			ret = -EAGAIN;
-			goto write_error;
-		}
-
-		/* Let readers in */
-		release_sock(&cf_sk->sk);
-
-		/* Wait until flow is on or socket is closed */
-		if (wait_event_interruptible(*sk_sleep(&cf_sk->sk),
-					TX_FLOW_IS_ON(cf_sk)
-					|| !STATE_IS_OPEN(cf_sk)
-					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
-					) == -ERESTARTSYS) {
-			pr_debug("CAIF: %s(): wait_event_interruptible"
-				 " woken by a signal", __func__);
-			ret = -ERESTARTSYS;
-			goto write_error_no_unlock;
-		}
-
-		/* I want to be alone on cf_sk (except status and queue) */
-		lock_sock(&(cf_sk->sk));
-
-	} while (ret == -EAGAIN);
-
-	if (ret < 0) {
-		cfpkt_destroy(pkt);
-		pr_debug("CAIF: %s(): transmit failed, error = %ld\n",
-			 __func__, (long) ret);
-
-		goto write_error;
-	}
-
-	release_sock(&cf_sk->sk);
-	return payload_size;
-
-write_error:
-	release_sock(&cf_sk->sk);
-write_error_no_unlock:
-	return ret;
-}
-
-static unsigned int caif_poll(struct file *file, struct socket *sock,
-						poll_table *wait)
-{
-	struct sock *sk = sock->sk;
-	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
-	u32 mask = 0;
-	poll_wait(file, sk_sleep(sk), wait);
-	lock_sock(&(cf_sk->sk));
-	if (!STATE_IS_OPEN(cf_sk)) {
-		if (!STATE_IS_PENDING(cf_sk))
-			mask |= POLLHUP;
-	} else {
-		if (cfpkt_qpeek(cf_sk->pktq) != NULL)
-			mask |= (POLLIN | POLLRDNORM);
-		if (TX_FLOW_IS_ON(cf_sk))
-			mask |= (POLLOUT | POLLWRNORM);
-	}
-	release_sock(&cf_sk->sk);
-	trace_printk("CAIF: %s(): poll mask=0x%04x\n",
-		      __func__, mask);
-	return mask;
-}
-
-static void drain_queue(struct caifsock *cf_sk)
-{
-	struct cfpkt *pkt = NULL;
-
-	/* Empty the queue */
-	do {
-		/* The queue has its own lock */
-		if (!cf_sk->pktq)
-			break;
-
-		pkt = cfpkt_dequeue(cf_sk->pktq);
-		if (!pkt)
-			break;
-		pr_debug("CAIF: %s(): freeing packet from read queue\n",
-			 __func__);
-		cfpkt_destroy(pkt);
-
-	} while (1);
-
-	cf_sk->read_queue_len = 0;
-}
-
-static int setsockopt(struct socket *sock,
-			int lvl, int opt, char __user *ov, unsigned int ol)
-{
-	struct sock *sk = sock->sk;
-	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
-	int prio, linksel;
-	struct ifreq ifreq;
-
-	if (STATE_IS_OPEN(cf_sk)) {
-		pr_debug("CAIF: %s(): setsockopt "
-			 "cannot be done on a connected socket\n",
-			 __func__);
-		return -ENOPROTOOPT;
-	}
-	switch (opt) {
-	case CAIFSO_LINK_SELECT:
-		if (ol < sizeof(int)) {
-			pr_debug("CAIF: %s(): setsockopt"
-				 " CAIFSO_CHANNEL_CONFIG bad size\n", __func__);
-			return -EINVAL;
-		}
-		if (lvl != SOL_CAIF)
-			goto bad_sol;
-		if (copy_from_user(&linksel, ov, sizeof(int)))
-			return -EINVAL;
-		lock_sock(&(cf_sk->sk));
-		cf_sk->conn_req.link_selector = linksel;
-		release_sock(&cf_sk->sk);
-		return 0;
-
-	case SO_PRIORITY:
-		if (lvl != SOL_SOCKET)
-			goto bad_sol;
-		if (ol < sizeof(int)) {
-			pr_debug("CAIF: %s(): setsockopt"
-				 " SO_PRIORITY bad size\n", __func__);
-			return -EINVAL;
-		}
-		if (copy_from_user(&prio, ov, sizeof(int)))
-			return -EINVAL;
-		lock_sock(&(cf_sk->sk));
-		cf_sk->conn_req.priority = prio;
-		pr_debug("CAIF: %s(): Setting sockopt priority=%d\n", __func__,
-			cf_sk->conn_req.priority);
-		release_sock(&cf_sk->sk);
-		return 0;
-
-	case SO_BINDTODEVICE:
-		if (lvl != SOL_SOCKET)
-			goto bad_sol;
-		if (ol < sizeof(struct ifreq)) {
-			pr_debug("CAIF: %s(): setsockopt"
-				 " SO_PRIORITY bad size\n", __func__);
-			return -EINVAL;
-		}
-		if (copy_from_user(&ifreq, ov, sizeof(ifreq)))
-			return -EFAULT;
-		lock_sock(&(cf_sk->sk));
-		strncpy(cf_sk->conn_req.link_name, ifreq.ifr_name,
-			sizeof(cf_sk->conn_req.link_name));
-		cf_sk->conn_req.link_name
-			[sizeof(cf_sk->conn_req.link_name)-1] = 0;
-		release_sock(&cf_sk->sk);
-		return 0;
-
-	case CAIFSO_REQ_PARAM:
-		if (lvl != SOL_CAIF)
-			goto bad_sol;
-		if (cf_sk->sk.sk_protocol != CAIFPROTO_UTIL)
-			return -ENOPROTOOPT;
-		if (ol > sizeof(cf_sk->conn_req.param.data))
-			goto req_param_bad_size;
-
-		lock_sock(&(cf_sk->sk));
-		cf_sk->conn_req.param.size = ol;
-		if (copy_from_user(&cf_sk->conn_req.param.data, ov, ol)) {
-			release_sock(&cf_sk->sk);
-req_param_bad_size:
-			pr_debug("CAIF: %s(): setsockopt"
-				 " CAIFSO_CHANNEL_CONFIG bad size\n", __func__);
-			return -EINVAL;
-		}
-
-		release_sock(&cf_sk->sk);
-		return 0;
-
-	default:
-		pr_debug("CAIF: %s(): unhandled option %d\n", __func__, opt);
-		return -EINVAL;
-	}
-
-	return 0;
-bad_sol:
-	pr_debug("CAIF: %s(): setsockopt bad level\n", __func__);
-	return -ENOPROTOOPT;
-
-}
-
-static int caif_connect(struct socket *sock, struct sockaddr *uservaddr,
-	       int sockaddr_len, int flags)
-{
-	struct caifsock *cf_sk = NULL;
-	int result = -1;
-	int mode = 0;
-	int ret = -EIO;
-	struct sock *sk = sock->sk;
-	BUG_ON(sk == NULL);
-
-	cf_sk = container_of(sk, struct caifsock, sk);
-
-	trace_printk("CAIF: %s(): cf_sk=%p OPEN=%d, TX_FLOW=%d, RX_FLOW=%d\n",
-		 __func__, cf_sk,
-		STATE_IS_OPEN(cf_sk),
-		TX_FLOW_IS_ON(cf_sk), RX_FLOW_IS_ON(cf_sk));
-
-
-	if (sock->type == SOCK_SEQPACKET || sock->type == SOCK_STREAM)
-		sock->state	= SS_CONNECTING;
-	else
-		goto out;
-
-	/* I want to be alone on cf_sk (except status and queue) */
-	lock_sock(&(cf_sk->sk));
-
-	if (sockaddr_len != sizeof(struct sockaddr_caif)) {
-		pr_debug("CAIF: %s(): Bad address len (%ld,%lu)\n",
-			 __func__, (long) sockaddr_len,
-			(long unsigned) sizeof(struct sockaddr_caif));
-		ret = -EINVAL;
-		goto open_error;
-	}
-
-	if (uservaddr->sa_family != AF_CAIF) {
-		pr_debug("CAIF: %s(): Bad address family (%d)\n",
-			 __func__, uservaddr->sa_family);
-		ret = -EAFNOSUPPORT;
-		goto open_error;
-	}
-
-	memcpy(&cf_sk->conn_req.sockaddr, uservaddr,
-		sizeof(struct sockaddr_caif));
-
-	dbfs_atomic_inc(&cnt.num_open);
-	mode = SKT_READ_FLAG | SKT_WRITE_FLAG;
-
-	/* If socket is not open, make sure socket is in fully closed state */
-	if (!STATE_IS_OPEN(cf_sk)) {
-		/* Has link close response been received (if we ever sent it)?*/
-		if (STATE_IS_PENDING(cf_sk)) {
-			/*
-			 * Still waiting for close response from remote.
-			 * If opened non-blocking, report "would block"
-			 */
-			if (flags & O_NONBLOCK) {
-				pr_debug("CAIF: %s(): O_NONBLOCK"
-					" && close pending\n", __func__);
-				ret = -EAGAIN;
-				goto open_error;
-			}
-
-			pr_debug("CAIF: %s(): Wait for close response"
-				 " from remote...\n", __func__);
-
-			release_sock(&cf_sk->sk);
-
-			/*
-			 * Blocking mode; close is pending and we need to wait
-			 * for its conclusion.
-			 */
-			result =
-			    wait_event_interruptible(*sk_sleep(&cf_sk->sk),
-						     !STATE_IS_PENDING(cf_sk));
-
-			lock_sock(&(cf_sk->sk));
-			if (result == -ERESTARTSYS) {
-				pr_debug("CAIF: %s(): wait_event_interruptible"
-					 "woken by a signal (1)", __func__);
-				ret = -ERESTARTSYS;
-				goto open_error;
-			}
-		}
-	}
-
-	/* socket is now either closed, pending open or open */
-	if (STATE_IS_OPEN(cf_sk) && !STATE_IS_PENDING(cf_sk)) {
-		/* Open */
-		pr_debug("CAIF: %s(): Socket is already opened (cf_sk=%p)"
-			" check access f_flags = 0x%x file_mode = 0x%x\n",
-			 __func__, cf_sk, mode, cf_sk->file_mode);
-
-	} else {
-		/* We are closed or pending open.
-		 * If closed:	    send link setup
-		 * If pending open: link setup already sent (we could have been
-		 *		    interrupted by a signal last time)
-		 */
-		if (!STATE_IS_OPEN(cf_sk)) {
-			/* First opening of file; connect lower layers: */
-			/* Drain queue (very unlikely) */
-			drain_queue(cf_sk);
-
-			cf_sk->layer.receive = caif_sktrecv_cb;
-			SET_STATE_OPEN(cf_sk);
-			SET_PENDING_ON(cf_sk);
-
-			/* Register this channel. */
-			result =
-				caif_connect_client(&cf_sk->conn_req,
-							&cf_sk->layer);
-			if (result < 0) {
-				pr_debug("CAIF: %s(): can't register channel\n",
-					__func__);
-				ret = -EIO;
-				SET_STATE_CLOSED(cf_sk);
-				SET_PENDING_OFF(cf_sk);
-				goto open_error;
-			}
-			dbfs_atomic_inc(&cnt.num_init);
-		}
-
-		/* If opened non-blocking, report "success".
-		 */
-		if (flags & O_NONBLOCK) {
-			pr_debug("CAIF: %s(): O_NONBLOCK success\n",
-				 __func__);
-			ret = -EINPROGRESS;
-			cf_sk->sk.sk_err = -EINPROGRESS;
-			goto open_error;
-		}
-
-		trace_printk("CAIF: %s(): Wait for connect response\n",
-			     __func__);
-
-		/* release lock before waiting */
-		release_sock(&cf_sk->sk);
-
-		result =
-		    wait_event_interruptible(*sk_sleep(&cf_sk->sk),
-					     !STATE_IS_PENDING(cf_sk));
-
-		lock_sock(&(cf_sk->sk));
-
-		if (result == -ERESTARTSYS) {
-			pr_debug("CAIF: %s(): wait_event_interruptible"
-				 "woken by a signal (2)", __func__);
-			ret = -ERESTARTSYS;
-			goto open_error;
-		}
-
-		if (!STATE_IS_OPEN(cf_sk)) {
-			/* Lower layers said "no" */
-			pr_debug("CAIF: %s(): Closed received\n", __func__);
-			ret = -EPIPE;
-			goto open_error;
-		}
-
-		trace_printk("CAIF: %s(): Connect received\n", __func__);
-	}
-	/* Open is ok */
-	cf_sk->file_mode |= mode;
-
-	trace_printk("CAIF: %s(): Connected - file mode = %x\n",
-		  __func__, cf_sk->file_mode);
-
-	release_sock(&cf_sk->sk);
-	return 0;
-open_error:
-	sock->state	= SS_UNCONNECTED;
-	release_sock(&cf_sk->sk);
-out:
-	return ret;
-}
-
-static int caif_shutdown(struct socket *sock, int how)
-{
-	struct caifsock *cf_sk = NULL;
-	int result = 0;
-	int tx_flow_state_was_on;
-	struct sock *sk = sock->sk;
-
-	trace_printk("CAIF: %s(): enter\n", __func__);
-	pr_debug("f_flags=%x\n", sock->file->f_flags);
-
-	if (how != SHUT_RDWR)
-		return -EOPNOTSUPP;
-
-	cf_sk = container_of(sk, struct caifsock, sk);
-	if (cf_sk == NULL) {
-		pr_debug("CAIF: %s(): COULD NOT FIND SOCKET\n", __func__);
-		return -EBADF;
-	}
-
-	/* I want to be alone on cf_sk (except status queue) */
-	lock_sock(&(cf_sk->sk));
-	sock_hold(&cf_sk->sk);
-
-	/* IS_CLOSED have double meaning:
-	 * 1) Spontanous Remote Shutdown Request.
-	 * 2) Ack on a channel teardown(disconnect)
-	 * Must clear bit in case we previously received
-	 * remote shudown request.
-	 */
-	if (STATE_IS_OPEN(cf_sk) && !STATE_IS_PENDING(cf_sk)) {
-		SET_STATE_CLOSED(cf_sk);
-		SET_PENDING_ON(cf_sk);
-		tx_flow_state_was_on = TX_FLOW_IS_ON(cf_sk);
-		SET_TX_FLOW_OFF(cf_sk);
-
-		/* Hold the socket until DEINIT_RSP is received */
-		sock_hold(&cf_sk->sk);
-		result = caif_disconnect_client(&cf_sk->layer);
-
-		if (result < 0) {
-			pr_debug("CAIF: %s(): "
-					"caif_disconnect_client() failed\n",
-					 __func__);
-			SET_STATE_CLOSED(cf_sk);
-			SET_PENDING_OFF(cf_sk);
-			SET_TX_FLOW_OFF(cf_sk);
-			release_sock(&cf_sk->sk);
-			sock_put(&cf_sk->sk);
-			return -EIO;
-		}
-
-	}
-	if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
-		SET_PENDING_OFF(cf_sk);
-		SET_REMOTE_SHUTDOWN_OFF(cf_sk);
-	}
-
-	/*
-	 * Socket is no longer in state pending close,
-	 * and we can release the reference.
-	 */
-
-	dbfs_atomic_inc(&cnt.num_close);
-	drain_queue(cf_sk);
-	SET_RX_FLOW_ON(cf_sk);
-	cf_sk->file_mode = 0;
-	sock_put(&cf_sk->sk);
-	release_sock(&cf_sk->sk);
-	if (!result && (sock->file->f_flags & O_NONBLOCK)) {
-		pr_debug("nonblocking shutdown returing -EAGAIN\n");
-		return -EAGAIN;
-	} else
-		return result;
-}
-
-static ssize_t caif_sock_no_sendpage(struct socket *sock,
-				     struct page *page,
-				     int offset, size_t size, int flags)
-{
-	return -EOPNOTSUPP;
-}
-
-/* This function is called as part of close. */
-static int caif_release(struct socket *sock)
-{
-	struct sock *sk = sock->sk;
-	struct caifsock *cf_sk = NULL;
-	int res;
-	caif_assert(sk != NULL);
-	cf_sk = container_of(sk, struct caifsock, sk);
-
-	if (cf_sk->debugfs_socket_dir != NULL)
-		debugfs_remove_recursive(cf_sk->debugfs_socket_dir);
-
-	res = caif_shutdown(sock, SHUT_RDWR);
-	if (res && res != -EINPROGRESS)
-		return res;
-
-	/*
-	 * FIXME: Shutdown should probably be possible to do async
-	 * without flushing queues, allowing reception of frames while
-	 * waiting for DEINIT_IND.
-	 * Release should always block, to allow secure decoupling of
-	 * CAIF stack.
-	 */
-	if (!(sock->file->f_flags & O_NONBLOCK)) {
-		res = wait_event_interruptible(*sk_sleep(&cf_sk->sk),
-						!STATE_IS_PENDING(cf_sk));
-
-		if (res == -ERESTARTSYS) {
-			pr_debug("CAIF: %s(): wait_event_interruptible"
-				"woken by a signal (1)", __func__);
-		}
-	}
-	lock_sock(&(cf_sk->sk));
-
-	sock->sk = NULL;
-
-	/* Detach the socket from its process context by making it orphan. */
-	sock_orphan(sk);
-
-	/*
-	 * Setting SHUTDOWN_MASK means that both send and receive are shutdown
-	 * for the socket.
-	 */
-	sk->sk_shutdown = SHUTDOWN_MASK;
-
-	/*
-	 * Set the socket state to closed, the TCP_CLOSE macro is used when
-	 * closing any socket.
-	 */
-
-	/* Flush out this sockets receive queue. */
-	drain_queue(cf_sk);
-
-	/* Finally release the socket. */
-	SET_STATE_PENDING_DESTROY(cf_sk);
-
-	release_sock(&cf_sk->sk);
-
-	sock_put(sk);
-
-	/*
-	 * The rest of the cleanup will be handled from the
-	 * caif_sock_destructor
-	 */
-	return res;
-}
-
-static const struct proto_ops caif_ops = {
-	.family = PF_CAIF,
-	.owner = THIS_MODULE,
-	.release = caif_release,
-	.bind = sock_no_bind,
-	.connect = caif_connect,
-	.socketpair = sock_no_socketpair,
-	.accept = sock_no_accept,
-	.getname = sock_no_getname,
-	.poll = caif_poll,
-	.ioctl = sock_no_ioctl,
-	.listen = sock_no_listen,
-	.shutdown = caif_shutdown,
-	.setsockopt = setsockopt,
-	.getsockopt = sock_no_getsockopt,
-	.sendmsg = caif_sendmsg,
-	.recvmsg = caif_recvmsg,
-	.mmap = sock_no_mmap,
-	.sendpage = caif_sock_no_sendpage,
-};
-
-/* This function is called when a socket is finally destroyed. */
-static void caif_sock_destructor(struct sock *sk)
-{
-	struct caifsock *cf_sk = NULL;
-	cf_sk = container_of(sk, struct caifsock, sk);
-	/* Error checks. */
-	caif_assert(!atomic_read(&sk->sk_wmem_alloc));
-	caif_assert(sk_unhashed(sk));
-	caif_assert(!sk->sk_socket);
-	if (!sock_flag(sk, SOCK_DEAD)) {
-		pr_debug("CAIF: %s(): 0x%p", __func__, sk);
-		return;
-	}
-
-	if (STATE_IS_OPEN(cf_sk)) {
-		pr_debug("CAIF: %s(): socket is opened (cf_sk=%p)"
-			 " file_mode = 0x%x\n", __func__,
-			 cf_sk, cf_sk->file_mode);
-		return;
-	}
-	drain_queue(cf_sk);
-	kfree(cf_sk->pktq);
-
-	trace_printk("CAIF: %s(): caif_sock_destructor: Removing socket %s\n",
-		__func__, cf_sk->name);
-	atomic_dec(&caif_nr_socks);
-}
-
-static int caif_create(struct net *net, struct socket *sock, int protocol,
-		       int kern)
-{
-	struct sock *sk = NULL;
-	struct caifsock *cf_sk = NULL;
-	int result = 0;
-	static struct proto prot = {.name = "PF_CAIF",
-		.owner = THIS_MODULE,
-		.obj_size = sizeof(struct caifsock),
-	};
-
-	/*
-	 * The sock->type specifies the socket type to use.
-	 * in SEQPACKET mode packet boundaries are enforced.
-	 */
-	if (sock->type != SOCK_SEQPACKET && sock->type != SOCK_STREAM)
-		return -ESOCKTNOSUPPORT;
-
-	if (net != &init_net)
-		return -EAFNOSUPPORT;
-
-	if (protocol < 0 || protocol >= CAIFPROTO_MAX)
-		return -EPROTONOSUPPORT;
-	/*
-	 * Set the socket state to unconnected.	 The socket state is really
-	 * not used at all in the net/core or socket.c but the
-	 * initialization makes sure that sock->state is not uninitialized.
-	 */
-	sock->state = SS_UNCONNECTED;
-
-	sk = sk_alloc(net, PF_CAIF, GFP_KERNEL, &prot);
-	if (!sk)
-		return -ENOMEM;
-
-	cf_sk = container_of(sk, struct caifsock, sk);
-
-	/* Store the protocol */
-	sk->sk_protocol = (unsigned char) protocol;
-
-	spin_lock_init(&cf_sk->read_queue_len_lock);
-
-	/* Fill in some information concerning the misc socket. */
-	snprintf(cf_sk->name, sizeof(cf_sk->name), "cf_sk%d",
-		atomic_read(&caif_nr_socks));
-
-	/*
-	 * Lock in order to try to stop someone from opening the socket
-	 * too early.
-	 */
-	lock_sock(&(cf_sk->sk));
-
-	/* Initialize the nozero default sock structure data. */
-	sock_init_data(sock, sk);
-	sock->ops = &caif_ops;
-	sk->sk_destruct = caif_sock_destructor;
-	sk->sk_sndbuf = caif_sockbuf_size;
-	sk->sk_rcvbuf = caif_sockbuf_size;
-
-	cf_sk->pktq = cfpktq_create();
-
-	if (!cf_sk->pktq) {
-		pr_err("CAIF: %s(): queue create failed.\n", __func__);
-		result = -ENOMEM;
-		release_sock(&cf_sk->sk);
-		goto err_failed;
-	}
-	cf_sk->layer.ctrlcmd = caif_sktflowctrl_cb;
-	SET_STATE_CLOSED(cf_sk);
-	SET_PENDING_OFF(cf_sk);
-	SET_TX_FLOW_OFF(cf_sk);
-	SET_RX_FLOW_ON(cf_sk);
-
-	/* Set default options on configuration */
-	cf_sk->conn_req.priority = CAIF_PRIO_NORMAL;
-	cf_sk->conn_req.link_selector = CAIF_LINK_HIGH_BANDW;
-	cf_sk->conn_req.protocol = protocol;
-	/* Increase the number of sockets created. */
-	atomic_inc(&caif_nr_socks);
-	if (!IS_ERR(debugfsdir)) {
-		cf_sk->debugfs_socket_dir =
-			debugfs_create_dir(cf_sk->name, debugfsdir);
-		debugfs_create_u32("conn_state", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir, &cf_sk->conn_state);
-		debugfs_create_u32("flow_state", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir, &cf_sk->flow_state);
-		debugfs_create_u32("read_queue_len", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir,
-				(u32 *) &cf_sk->read_queue_len);
-		debugfs_create_u32("identity", S_IRUSR | S_IWUSR,
-				cf_sk->debugfs_socket_dir,
-				(u32 *) &cf_sk->layer.id);
-	}
-	release_sock(&cf_sk->sk);
-	return 0;
-err_failed:
-	sk_free(sk);
-	return result;
-}
-
-static struct net_proto_family caif_family_ops = {
-	.family = PF_CAIF,
-	.create = caif_create,
-	.owner = THIS_MODULE,
-};
-
-static int af_caif_init(void)
-{
-	int err;
-	err = sock_register(&caif_family_ops);
-
-	if (!err)
-		return err;
-
-	return 0;
-}
-
-static int __init caif_sktinit_module(void)
-{
-	int stat;
-#ifdef CONFIG_DEBUG_FS
-	debugfsdir = debugfs_create_dir("chnl_skt", NULL);
-	if (!IS_ERR(debugfsdir)) {
-		debugfs_create_u32("skb_inuse", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.skb_in_use);
-		debugfs_create_u32("skb_alloc", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.skb_alloc);
-		debugfs_create_u32("skb_free", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.skb_free);
-		debugfs_create_u32("num_sockets", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &caif_nr_socks);
-		debugfs_create_u32("num_open", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_open);
-		debugfs_create_u32("num_close", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_close);
-		debugfs_create_u32("num_init", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_init);
-		debugfs_create_u32("num_init_resp", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_init_resp);
-		debugfs_create_u32("num_init_fail_resp", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_init_fail_resp);
-		debugfs_create_u32("num_deinit", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_deinit);
-		debugfs_create_u32("num_deinit_resp", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_deinit_resp);
-		debugfs_create_u32("num_remote_shutdown_ind",
-				S_IRUSR | S_IWUSR, debugfsdir,
-				(u32 *) &cnt.num_remote_shutdown_ind);
-		debugfs_create_u32("num_tx_flow_off_ind", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_tx_flow_off_ind);
-		debugfs_create_u32("num_tx_flow_on_ind", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_tx_flow_on_ind);
-		debugfs_create_u32("num_rx_flow_off", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_rx_flow_off);
-		debugfs_create_u32("num_rx_flow_on", S_IRUSR | S_IWUSR,
-				debugfsdir,
-				(u32 *) &cnt.num_rx_flow_on);
-	}
-#endif
-	stat = af_caif_init();
-	if (stat) {
-		pr_err("CAIF: %s(): Failed to initialize CAIF socket layer.",
-		       __func__);
-		return stat;
-	}
-	return 0;
-}
-
-static void __exit caif_sktexit_module(void)
-{
-	sock_unregister(PF_CAIF);
-	if (debugfsdir != NULL)
-		debugfs_remove_recursive(debugfsdir);
-}
-
-module_init(caif_sktinit_module);
-module_exit(caif_sktexit_module);
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/poll.h>
+#include <linux/tcp.h>
+#include <linux/uaccess.h>
+#include <linux/mutex.h>
+#include <linux/debugfs.h>
+#include <linux/caif/caif_socket.h>
+#include <asm/atomic.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/caif_dev.h>
+#include <net/caif/cfpkt.h>
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(AF_CAIF);
+
+#define CAIF_DEF_SNDBUF (CAIF_MAX_PAYLOAD_SIZE*10)
+#define CAIF_DEF_RCVBUF (CAIF_MAX_PAYLOAD_SIZE*100)
+
+/*
+ * CAIF state is re-using the TCP socket states.
+ * caif_states stored in sk_state reflect the state as reported by
+ * the CAIF stack, while sk_socket->state is the state of the socket.
+ */
+enum caif_states {
+	CAIF_CONNECTED		= TCP_ESTABLISHED,
+	CAIF_CONNECTING	= TCP_SYN_SENT,
+	CAIF_DISCONNECTED	= TCP_CLOSE
+};
+
+#define TX_FLOW_ON_BIT	1
+#define RX_FLOW_ON_BIT	2
+
+static struct dentry *debugfsdir;
+
+#ifdef CONFIG_DEBUG_FS
+struct debug_fs_counter {
+	atomic_t caif_nr_socks;
+	atomic_t num_connect_req;
+	atomic_t num_connect_resp;
+	atomic_t num_connect_fail_resp;
+	atomic_t num_disconnect;
+	atomic_t num_remote_shutdown_ind;
+	atomic_t num_tx_flow_off_ind;
+	atomic_t num_tx_flow_on_ind;
+	atomic_t num_rx_flow_off;
+	atomic_t num_rx_flow_on;
+};
+struct debug_fs_counter cnt;
+#define	dbfs_atomic_inc(v) atomic_inc(v)
+#define	dbfs_atomic_dec(v) atomic_dec(v)
+#else
+#define	dbfs_atomic_inc(v)
+#define	dbfs_atomic_dec(v)
+#endif
+
+struct caifsock {
+	struct sock sk; /* must be first member */
+	struct cflayer layer;
+	char name[CAIF_LAYER_NAME_SZ]; /* Used for debugging */
+	u32 flow_state;
+	struct caif_connect_request conn_req;
+	struct mutex readlock;
+	struct dentry *debugfs_socket_dir;
+};
+
+static int rx_flow_is_on(struct caifsock *cf_sk)
+{
+	return test_bit(RX_FLOW_ON_BIT,
+			(void *) &cf_sk->flow_state);
+}
+
+static int tx_flow_is_on(struct caifsock *cf_sk)
+{
+	return test_bit(TX_FLOW_ON_BIT,
+			(void *) &cf_sk->flow_state);
+}
+
+static void set_rx_flow_off(struct caifsock *cf_sk)
+{
+	 clear_bit(RX_FLOW_ON_BIT,
+		 (void *) &cf_sk->flow_state);
+}
+
+static void set_rx_flow_on(struct caifsock *cf_sk)
+{
+	 set_bit(RX_FLOW_ON_BIT,
+			(void *) &cf_sk->flow_state);
+}
+
+static void set_tx_flow_off(struct caifsock *cf_sk)
+{
+	 clear_bit(TX_FLOW_ON_BIT,
+		(void *) &cf_sk->flow_state);
+}
+
+static void set_tx_flow_on(struct caifsock *cf_sk)
+{
+	 set_bit(TX_FLOW_ON_BIT,
+		(void *) &cf_sk->flow_state);
+}
+
+static void caif_read_lock(struct sock *sk)
+{
+	struct caifsock *cf_sk;
+	cf_sk = container_of(sk, struct caifsock, sk);
+	mutex_lock(&cf_sk->readlock);
+}
+
+static void caif_read_unlock(struct sock *sk)
+{
+	struct caifsock *cf_sk;
+	cf_sk = container_of(sk, struct caifsock, sk);
+	mutex_unlock(&cf_sk->readlock);
+}
+
+int sk_rcvbuf_lowwater(struct caifsock *cf_sk)
+{
+	/* A quarter of full buffer is used a low water mark */
+	return cf_sk->sk.sk_rcvbuf / 4;
+}
+
+void caif_flow_ctrl(struct sock *sk, int mode)
+{
+	struct caifsock *cf_sk;
+	cf_sk = container_of(sk, struct caifsock, sk);
+	if (cf_sk->layer.dn)
+		cf_sk->layer.dn->modemcmd(cf_sk->layer.dn, mode);
+}
+
+/*
+ * Copied from sock.c:sock_queue_rcv_skb(), but changed so packets are
+ * not dropped, but CAIF is sending flow off instead.
+ */
+int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int err;
+	int skb_len;
+	unsigned long flags;
+	struct sk_buff_head *list = &sk->sk_receive_queue;
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+
+	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
+		(unsigned)sk->sk_rcvbuf && rx_flow_is_on(cf_sk)) {
+		trace_printk("CAIF: %s():"
+			" sending flow OFF (queue len = %d %d)\n",
+			__func__,
+			atomic_read(&cf_sk->sk.sk_rmem_alloc),
+			sk_rcvbuf_lowwater(cf_sk));
+		set_rx_flow_off(cf_sk);
+		if (cf_sk->layer.dn)
+			cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
+						CAIF_MODEMCMD_FLOW_OFF_REQ);
+	}
+
+	err = sk_filter(sk, skb);
+	if (err)
+		return err;
+	if (!sk_rmem_schedule(sk, skb->truesize) && rx_flow_is_on(cf_sk)) {
+		set_rx_flow_off(cf_sk);
+		trace_printk("CAIF: %s():"
+			" sending flow OFF due to rmem_schedule\n",
+			__func__);
+		if (cf_sk->layer.dn)
+			cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
+						CAIF_MODEMCMD_FLOW_OFF_REQ);
+	}
+	skb->dev = NULL;
+	skb_set_owner_r(skb, sk);
+	/* Cache the SKB length before we tack it onto the receive
+	 * queue. Once it is added it no longer belongs to us and
+	 * may be freed by other threads of control pulling packets
+	 * from the queue.
+	 */
+	skb_len = skb->len;
+	spin_lock_irqsave(&list->lock, flags);
+	if (!sock_flag(sk, SOCK_DEAD))
+		__skb_queue_tail(list, skb);
+	spin_unlock_irqrestore(&list->lock, flags);
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk, skb_len);
+	else
+		kfree_skb(skb);
+	return 0;
+}
+
+/* Packet Receive Callback function called from CAIF Stack */
+static int caif_sktrecv_cb(struct cflayer *layr, struct cfpkt *pkt)
+{
+	struct caifsock *cf_sk;
+	struct sk_buff *skb;
+
+	cf_sk = container_of(layr, struct caifsock, layer);
+	skb = cfpkt_tonative(pkt);
+
+	if (unlikely(cf_sk->sk.sk_state != CAIF_CONNECTED)) {
+		cfpkt_destroy(pkt);
+		return 0;
+	}
+	caif_queue_rcv_skb(&cf_sk->sk, skb);
+	return 0;
+}
+
+/* Packet Control Callback function called from CAIF */
+static void caif_ctrl_cb(struct cflayer *layr,
+				enum caif_ctrlcmd flow,
+				int phyid)
+{
+	struct caifsock *cf_sk = container_of(layr, struct caifsock, layer);
+	switch (flow) {
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+		/* OK from modem to start sending again */
+		dbfs_atomic_inc(&cnt.num_tx_flow_on_ind);
+		set_tx_flow_on(cf_sk);
+		cf_sk->sk.sk_state_change(&cf_sk->sk);
+		break;
+
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		/* Modem asks us to shut up */
+		dbfs_atomic_inc(&cnt.num_tx_flow_off_ind);
+		set_tx_flow_off(cf_sk);
+		cf_sk->sk.sk_state_change(&cf_sk->sk);
+		break;
+
+	case CAIF_CTRLCMD_INIT_RSP:
+		/* We're now connected */
+		dbfs_atomic_inc(&cnt.num_connect_resp);
+		cf_sk->sk.sk_state = CAIF_CONNECTED;
+		set_tx_flow_on(cf_sk);
+		cf_sk->sk.sk_state_change(&cf_sk->sk);
+		break;
+
+	case CAIF_CTRLCMD_DEINIT_RSP:
+		/* We're now disconnected */
+		cf_sk->sk.sk_state = CAIF_DISCONNECTED;
+		cf_sk->sk.sk_state_change(&cf_sk->sk);
+		cfcnfg_release_adap_layer(&cf_sk->layer);
+		break;
+
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		/* Connect request failed */
+		dbfs_atomic_inc(&cnt.num_connect_fail_resp);
+		cf_sk->sk.sk_err = ECONNREFUSED;
+		cf_sk->sk.sk_state = CAIF_DISCONNECTED;
+		cf_sk->sk.sk_shutdown = SHUTDOWN_MASK;
+		/*
+		 * Socket "standards" seems to require POLLOUT to
+		 * be set at connect failure.
+		 */
+		set_tx_flow_on(cf_sk);
+		cf_sk->sk.sk_state_change(&cf_sk->sk);
+		break;
+
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		/* Modem has closed this connection, or device is down. */
+		dbfs_atomic_inc(&cnt.num_remote_shutdown_ind);
+		cf_sk->sk.sk_shutdown = SHUTDOWN_MASK;
+		cf_sk->sk.sk_err = ECONNRESET;
+		set_rx_flow_on(cf_sk);
+		cf_sk->sk.sk_error_report(&cf_sk->sk);
+		break;
+
+	default:
+		pr_debug("CAIF: %s(): Unexpected flow command %d\n",
+				__func__, flow);
+	}
+}
+
+static void caif_check_flow_release(struct sock *sk)
+{
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+
+	if (cf_sk->layer.dn == NULL || cf_sk->layer.dn->modemcmd == NULL)
+		return;
+	if (rx_flow_is_on(cf_sk))
+		return;
+
+	if (atomic_read(&sk->sk_rmem_alloc) <= sk_rcvbuf_lowwater(cf_sk)) {
+			dbfs_atomic_inc(&cnt.num_rx_flow_on);
+			set_rx_flow_on(cf_sk);
+			cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
+						CAIF_MODEMCMD_FLOW_ON_REQ);
+	}
+}
+/*
+ * Copied from sock.c:sock_queue_rcv_skb(), and added check that user buffer
+ * has sufficient size.
+ */
+
+static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
+				struct msghdr *m, size_t buf_len, int flags)
+
+{
+	struct sock *sk = sock->sk;
+	struct sk_buff *skb;
+	int ret = 0;
+	int len;
+
+	if (unlikely(!buf_len))
+		return -EINVAL;
+
+	skb = skb_recv_datagram(sk, flags, 0 , &ret);
+	if (!skb)
+		goto read_error;
+
+	len = skb->len;
+
+	if (skb && skb->len > buf_len && !(flags & MSG_PEEK)) {
+		len = buf_len;
+		/*
+		 * Push skb back on receive queue if buffer too small.
+		 * This has a built-in race where multi-threaded receive
+		 * may get packet in wrong order, but multiple read does
+		 * not really guarantee ordered delivery anyway.
+		 * Let's optimize for speed without taking locks.
+		 */
+
+		skb_queue_head(&sk->sk_receive_queue, skb);
+		ret = -EMSGSIZE;
+		goto read_error;
+	}
+
+	ret = skb_copy_datagram_iovec(skb, 0, m->msg_iov, len);
+	if (ret)
+		goto read_error;
+
+	skb_free_datagram(sk, skb);
+
+	caif_check_flow_release(sk);
+
+	return len;
+
+read_error:
+	return ret;
+}
+
+
+/* Copied from unix_stream_wait_data, identical except for lock call. */
+static long caif_stream_data_wait(struct sock *sk, long timeo)
+{
+	DEFINE_WAIT(wait);
+	lock_sock(sk);
+
+	for (;;) {
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+
+		if (!skb_queue_empty(&sk->sk_receive_queue) ||
+			sk->sk_err ||
+			sk->sk_state != CAIF_CONNECTED ||
+			sock_flag(sk, SOCK_DEAD) ||
+			(sk->sk_shutdown & RCV_SHUTDOWN) ||
+			signal_pending(current) ||
+			!timeo)
+			break;
+
+		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		release_sock(sk);
+		timeo = schedule_timeout(timeo);
+		lock_sock(sk);
+		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	}
+
+	finish_wait(sk_sleep(sk), &wait);
+	release_sock(sk);
+	return timeo;
+}
+
+
+/*
+ * Copied from unix_stream_recvmsg, but removed credit checks,
+ * changed locking calls, changed address handling.
+ */
+static int caif_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
+				struct msghdr *msg, size_t size,
+				int flags)
+{
+	struct sock *sk = sock->sk;
+	int copied = 0;
+	int target;
+	int err = 0;
+	long timeo;
+
+	err = -EOPNOTSUPP;
+	if (flags&MSG_OOB)
+		goto out;
+
+	msg->msg_namelen = 0;
+
+	/*
+	 * Lock the socket to prevent queue disordering
+	 * while sleeps in memcpy_tomsg
+	 */
+	err = -EAGAIN;
+	if (sk->sk_state == CAIF_CONNECTING)
+		goto out;
+
+	caif_read_lock(sk);
+	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
+	timeo = sock_rcvtimeo(sk, flags&MSG_DONTWAIT);
+
+	do {
+		int chunk;
+		struct sk_buff *skb;
+
+		lock_sock(sk);
+		skb = skb_dequeue(&sk->sk_receive_queue);
+		caif_check_flow_release(sk);
+
+		if (skb == NULL) {
+			if (copied >= target)
+				goto unlock;
+			/*
+			 *	POSIX 1003.1g mandates this order.
+			 */
+			err = sock_error(sk);
+			if (err)
+				goto unlock;
+			err = -ECONNRESET;
+			if (sk->sk_shutdown & RCV_SHUTDOWN)
+				goto unlock;
+
+			err = -EPIPE;
+			if (sk->sk_state != CAIF_CONNECTED)
+				goto unlock;
+			if (sock_flag(sk, SOCK_DEAD))
+				goto unlock;
+
+			release_sock(sk);
+
+			err = -EAGAIN;
+			if (!timeo)
+				break;
+
+			caif_read_unlock(sk);
+
+			timeo = caif_stream_data_wait(sk, timeo);
+
+			if (signal_pending(current)) {
+				err = sock_intr_errno(timeo);
+				goto out;
+			}
+			caif_read_lock(sk);
+			continue;
+unlock:
+			release_sock(sk);
+			break;
+		}
+		release_sock(sk);
+		chunk = min_t(unsigned int, skb->len, size);
+		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
+			skb_queue_head(&sk->sk_receive_queue, skb);
+			if (copied == 0)
+				copied = -EFAULT;
+			break;
+		}
+		copied += chunk;
+		size -= chunk;
+
+		/* Mark read part of skb as used */
+		if (!(flags & MSG_PEEK)) {
+			skb_pull(skb, chunk);
+
+			/* put the skb back if we didn't use it up. */
+			if (skb->len) {
+				skb_queue_head(&sk->sk_receive_queue, skb);
+				break;
+			}
+			kfree_skb(skb);
+
+		} else {
+			/*
+			 * It is questionable, see note in unix_dgram_recvmsg.
+			 */
+			/* put message back and return */
+			skb_queue_head(&sk->sk_receive_queue, skb);
+			break;
+		}
+	} while (size);
+	caif_read_unlock(sk);
+
+out:
+	return copied ? : err;
+}
+
+/*
+ * Copied from sock.c:sock_wait_for_wmem, but change to wait for
+ * CAIF flow-on and sock_writable.
+ */
+static long caif_wait_for_flow_on(struct caifsock *cf_sk,
+				int wait_writeable, long timeo, int *err)
+{
+	struct sock *sk = &cf_sk->sk;
+	DEFINE_WAIT(wait);
+	for (;;) {
+		*err = 0;
+		if (tx_flow_is_on(cf_sk) &&
+			(!wait_writeable || sock_writeable(&cf_sk->sk)))
+			break;
+		*err = -ETIMEDOUT;
+		if (!timeo)
+			break;
+		*err = -ERESTARTSYS;
+		if (signal_pending(current))
+			break;
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		*err = -ECONNRESET;
+		if (sk->sk_shutdown & SHUTDOWN_MASK)
+			break;
+		*err = -sk->sk_err;
+		if (sk->sk_err)
+			break;
+		*err = -EPIPE;
+		if (cf_sk->sk.sk_state != CAIF_CONNECTED)
+			break;
+		timeo = schedule_timeout(timeo);
+	}
+	finish_wait(sk_sleep(sk), &wait);
+	return timeo;
+}
+
+/*
+ * Transmit a SKB. The device may temporarily request re-transmission
+ * by returning EAGAIN.
+ */
+static int transmit_skb(struct sk_buff *skb, struct caifsock *cf_sk,
+			int noblock, long timeo)
+{
+	struct cfpkt *pkt;
+	int ret, loopcnt = 0;
+
+	pkt = cfpkt_fromnative(CAIF_DIR_OUT, skb);
+	memset(cfpkt_info(pkt), 0, sizeof(struct caif_payload_info));
+	do {
+
+		ret = -ETIMEDOUT;
+
+		/* Slight paranoia, probably not needed. */
+		if (unlikely(loopcnt++ > 1000)) {
+			pr_warning("CAIF: %s(): transmit retries failed,"
+				" error = %d\n", __func__, ret);
+			break;
+		}
+
+		if (cf_sk->layer.dn != NULL)
+			ret = cf_sk->layer.dn->transmit(cf_sk->layer.dn, pkt);
+		if (likely(ret >= 0))
+			break;
+		/* if transmit return -EAGAIN, then retry */
+		if (noblock && ret == -EAGAIN)
+			break;
+		timeo = caif_wait_for_flow_on(cf_sk, 0, timeo, &ret);
+		if (signal_pending(current)) {
+			ret = sock_intr_errno(timeo);
+			break;
+		}
+		if (ret)
+			break;
+		if (cf_sk->sk.sk_state != CAIF_CONNECTED ||
+			sock_flag(&cf_sk->sk, SOCK_DEAD) ||
+			(cf_sk->sk.sk_shutdown & RCV_SHUTDOWN)) {
+			ret = -EPIPE;
+			cf_sk->sk.sk_err = EPIPE;
+			break;
+		}
+	} while (ret == -EAGAIN);
+	return ret;
+}
+
+/* Copied from af_unix:unix_dgram_sendmsg, and adapted to CAIF */
+static int caif_seqpkt_sendmsg(struct kiocb *kiocb, struct socket *sock,
+			struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+	int buffer_size;
+	int ret = 0;
+	struct sk_buff *skb = NULL;
+	int noblock;
+	long timeo;
+	caif_assert(cf_sk);
+	ret = sock_error(sk);
+	if (ret)
+		goto err;
+
+	ret = -EOPNOTSUPP;
+	if (msg->msg_flags&MSG_OOB)
+		goto err;
+
+	ret = -EOPNOTSUPP;
+	if (msg->msg_namelen)
+		goto err;
+
+	ret = -EINVAL;
+	if (unlikely(msg->msg_iov->iov_base == NULL))
+		goto err;
+	noblock = msg->msg_flags & MSG_DONTWAIT;
+
+	buffer_size = len + CAIF_NEEDED_HEADROOM + CAIF_NEEDED_TAILROOM;
+
+	ret = -EMSGSIZE;
+	if (buffer_size > CAIF_MAX_PAYLOAD_SIZE)
+		goto err;
+
+	timeo = sock_sndtimeo(sk, noblock);
+	timeo = caif_wait_for_flow_on(container_of(sk, struct caifsock, sk),
+				1, timeo, &ret);
+
+	ret = -EPIPE;
+	if (cf_sk->sk.sk_state != CAIF_CONNECTED ||
+		sock_flag(sk, SOCK_DEAD) ||
+		(sk->sk_shutdown & RCV_SHUTDOWN))
+		goto err;
+
+	ret = -ENOMEM;
+	skb = sock_alloc_send_skb(sk, buffer_size, noblock, &ret);
+	if (!skb)
+		goto err;
+	skb_reserve(skb, CAIF_NEEDED_HEADROOM);
+
+	ret = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+
+	if (ret)
+		goto err;
+	ret = transmit_skb(skb, cf_sk, noblock, timeo);
+	if (ret < 0)
+		goto err;
+	return len;
+err:
+	kfree_skb(skb);
+	return ret;
+}
+
+/*
+ * Copied from unix_stream_sendmsg and adapted to CAIF:
+ * Changed removed permission handling and added waiting for flow on
+ * and other minor adaptations.
+ */
+static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
+				struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+	int err, size;
+	struct sk_buff *skb;
+	int sent = 0;
+	long timeo;
+
+	err = -EOPNOTSUPP;
+
+	if (unlikely(msg->msg_flags&MSG_OOB))
+		goto out_err;
+
+	if (unlikely(msg->msg_namelen))
+		goto out_err;
+
+	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
+	timeo = caif_wait_for_flow_on(cf_sk, 1, timeo, &err);
+
+	if (unlikely(sk->sk_shutdown & SEND_SHUTDOWN))
+		goto pipe_err;
+
+	while (sent < len) {
+
+		size = len-sent;
+
+		if (size > CAIF_MAX_PAYLOAD_SIZE)
+			size = CAIF_MAX_PAYLOAD_SIZE;
+
+		/* If size is more than half of sndbuf, chop up message */
+		if (size > ((sk->sk_sndbuf >> 1) - 64))
+			size = (sk->sk_sndbuf >> 1) - 64;
+
+		if (size > SKB_MAX_ALLOC)
+			size = SKB_MAX_ALLOC;
+
+		skb = sock_alloc_send_skb(sk,
+					size + CAIF_NEEDED_HEADROOM
+					+ CAIF_NEEDED_TAILROOM,
+					msg->msg_flags&MSG_DONTWAIT,
+					&err);
+		if (skb == NULL)
+			goto out_err;
+
+		skb_reserve(skb, CAIF_NEEDED_HEADROOM);
+		/*
+		 *	If you pass two values to the sock_alloc_send_skb
+		 *	it tries to grab the large buffer with GFP_NOFS
+		 *	(which can fail easily), and if it fails grab the
+		 *	fallback size buffer which is under a page and will
+		 *	succeed. [Alan]
+		 */
+		size = min_t(int, size, skb_tailroom(skb));
+
+		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+		if (err) {
+			kfree_skb(skb);
+			goto out_err;
+		}
+		err = transmit_skb(skb, cf_sk,
+				msg->msg_flags&MSG_DONTWAIT, timeo);
+		if (err < 0) {
+			kfree_skb(skb);
+			goto pipe_err;
+		}
+		sent += size;
+	}
+
+	return sent;
+
+pipe_err:
+	if (sent == 0 && !(msg->msg_flags&MSG_NOSIGNAL))
+		send_sig(SIGPIPE, current, 0);
+	err = -EPIPE;
+out_err:
+	return sent ? : err;
+}
+
+static int setsockopt(struct socket *sock,
+			int lvl, int opt, char __user *ov, unsigned int ol)
+{
+	struct sock *sk = sock->sk;
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+	int prio, linksel;
+	struct ifreq ifreq;
+
+	if (cf_sk->sk.sk_socket->state != SS_UNCONNECTED)
+		return -ENOPROTOOPT;
+
+	switch (opt) {
+	case CAIFSO_LINK_SELECT:
+		if (ol < sizeof(int))
+			return -EINVAL;
+		if (lvl != SOL_CAIF)
+			goto bad_sol;
+		if (copy_from_user(&linksel, ov, sizeof(int)))
+			return -EINVAL;
+		lock_sock(&(cf_sk->sk));
+		cf_sk->conn_req.link_selector = linksel;
+		release_sock(&cf_sk->sk);
+		return 0;
+
+	case SO_PRIORITY:
+		if (lvl != SOL_SOCKET)
+			goto bad_sol;
+		if (ol < sizeof(int))
+			return -EINVAL;
+		if (copy_from_user(&prio, ov, sizeof(int)))
+			return -EINVAL;
+		lock_sock(&(cf_sk->sk));
+		cf_sk->conn_req.priority = prio;
+		release_sock(&cf_sk->sk);
+		return 0;
+
+	case SO_BINDTODEVICE:
+		if (lvl != SOL_SOCKET)
+			goto bad_sol;
+		if (ol < sizeof(struct ifreq))
+			return -EINVAL;
+		if (copy_from_user(&ifreq, ov, sizeof(ifreq)))
+			return -EFAULT;
+		lock_sock(&(cf_sk->sk));
+		strncpy(cf_sk->conn_req.link_name, ifreq.ifr_name,
+			sizeof(cf_sk->conn_req.link_name));
+		cf_sk->conn_req.link_name
+			[sizeof(cf_sk->conn_req.link_name)-1] = 0;
+		release_sock(&cf_sk->sk);
+		return 0;
+
+	case CAIFSO_REQ_PARAM:
+		if (lvl != SOL_CAIF)
+			goto bad_sol;
+		if (cf_sk->sk.sk_protocol != CAIFPROTO_UTIL)
+			return -ENOPROTOOPT;
+		lock_sock(&(cf_sk->sk));
+		cf_sk->conn_req.param.size = ol;
+		if (ol > sizeof(cf_sk->conn_req.param.data) ||
+			copy_from_user(&cf_sk->conn_req.param.data, ov, ol)) {
+			release_sock(&cf_sk->sk);
+			return -EINVAL;
+		}
+		release_sock(&cf_sk->sk);
+		return 0;
+
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	return 0;
+bad_sol:
+	return -ENOPROTOOPT;
+
+}
+
+/*
+ * caif_connect() - Connect a CAIF Socket
+ * Copied and modified af_irda.c:irda_connect().
+ *
+ * Note : by consulting "errno", the user space caller may learn the cause
+ * of the failure. Most of them are visible in the function, others may come
+ * from subroutines called and are listed here :
+ *  o -EAFNOSUPPORT: bad socket family or type.
+ *  o -ESOCKTNOSUPPORT: bad socket type or protocol
+ *  o -EINVAL: bad socket address, or CAIF link type
+ *  o -ECONNREFUSED: remote end refused the connection.
+ *  o -EINPROGRESS: connect request sent but timed out (or non-blocking)
+ *  o -EISCONN: already connected.
+ *  o -ETIMEDOUT: Connection timed out (send timeout)
+ *  o -ENODEV: No link layer to send request
+ *  o -ECONNRESET: Received Shutdown indication or lost link layer
+ *  o -ENOMEM: Out of memory
+ *
+ *  State Strategy:
+ *  o sk_state: holds the CAIF_* protocol state, it's updated by
+ *	caif_ctrl_cb.
+ *  o sock->state: holds the SS_* socket state and is updated by connect and
+ *	disconnect.
+ */
+static int caif_connect(struct socket *sock, struct sockaddr *uaddr,
+			int addr_len, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+	long timeo;
+	int err;
+	lock_sock(sk);
+
+	err = -EAFNOSUPPORT;
+	if (uaddr->sa_family != AF_CAIF)
+		goto out;
+
+	err = -ESOCKTNOSUPPORT;
+	if (unlikely(!(sk->sk_type == SOCK_STREAM &&
+		       cf_sk->sk.sk_protocol == CAIFPROTO_AT) &&
+		       sk->sk_type != SOCK_SEQPACKET))
+		goto out;
+	switch (sock->state) {
+	case SS_UNCONNECTED:
+		/* Normal case, a fresh connect */
+		caif_assert(sk->sk_state == CAIF_DISCONNECTED);
+		break;
+	case SS_CONNECTING:
+		switch (sk->sk_state) {
+		case CAIF_CONNECTED:
+			sock->state = SS_CONNECTED;
+			err = -EISCONN;
+			goto out;
+		case CAIF_DISCONNECTED:
+			/* Reconnect allowed */
+			break;
+		case CAIF_CONNECTING:
+			err = -EALREADY;
+			if (flags & O_NONBLOCK)
+				goto out;
+			goto wait_connect;
+		}
+		break;
+	case SS_CONNECTED:
+		caif_assert(sk->sk_state == CAIF_CONNECTED ||
+				sk->sk_state == CAIF_DISCONNECTED);
+		if (sk->sk_shutdown & SHUTDOWN_MASK) {
+			/* Allow re-connect after SHUTDOWN_IND */
+			caif_disconnect_client(&cf_sk->layer);
+			break;
+		}
+		/* No reconnect on a seqpacket socket */
+		err = -EISCONN;
+		goto out;
+	case SS_DISCONNECTING:
+	case SS_FREE:
+		caif_assert(1); /*Should never happen */
+		break;
+	}
+	sk->sk_state = CAIF_DISCONNECTED;
+	sock->state = SS_UNCONNECTED;
+	sk_stream_kill_queues(&cf_sk->sk);
+
+	err = -EINVAL;
+	if (addr_len != sizeof(struct sockaddr_caif) ||
+		!uaddr)
+		goto out;
+
+	memcpy(&cf_sk->conn_req.sockaddr, uaddr,
+		sizeof(struct sockaddr_caif));
+
+	/* Move to connecting socket, start sending Connect Requests */
+	sock->state = SS_CONNECTING;
+	sk->sk_state = CAIF_CONNECTING;
+
+	dbfs_atomic_inc(&cnt.num_connect_req);
+	cf_sk->layer.receive = caif_sktrecv_cb;
+	err = caif_connect_client(&cf_sk->conn_req,
+				&cf_sk->layer);
+	if (err < 0) {
+		cf_sk->sk.sk_socket->state = SS_UNCONNECTED;
+		cf_sk->sk.sk_state = CAIF_DISCONNECTED;
+		goto out;
+	}
+
+	err = -EINPROGRESS;
+wait_connect:
+
+	if (sk->sk_state != CAIF_CONNECTED && (flags & O_NONBLOCK))
+		goto out;
+
+	timeo = sock_sndtimeo(sk, flags & O_NONBLOCK);
+
+	release_sock(sk);
+	err = wait_event_interruptible_timeout(*sk_sleep(sk),
+			sk->sk_state != CAIF_CONNECTING,
+			timeo);
+	lock_sock(sk);
+	if (err < 0)
+		goto out; /* -ERESTARTSYS */
+	if (err == 0 && sk->sk_state != CAIF_CONNECTED) {
+		err = -ETIMEDOUT;
+		goto out;
+	}
+
+	if (sk->sk_state != CAIF_CONNECTED) {
+		sock->state = SS_UNCONNECTED;
+		err = sock_error(sk);
+		if (!err)
+			err = -ECONNREFUSED;
+		goto out;
+	}
+	sock->state = SS_CONNECTED;
+	err = 0;
+out:
+	release_sock(sk);
+	return err;
+}
+
+
+/*
+ * caif_release() - Disconnect a CAIF Socket
+ * Copied and modified af_irda.c:irda_release().
+ */
+static int caif_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+	int res = 0;
+
+	if (!sk)
+		return 0;
+
+	set_tx_flow_off(cf_sk);
+
+	/*
+	 * Ensure that packets are not queued after this point in time.
+	 * caif_queue_rcv_skb checks SOCK_DEAD holding the queue lock,
+	 * this ensures no packets when sock is dead.
+	 */
+	spin_lock(&sk->sk_receive_queue.lock);
+	sock_set_flag(sk, SOCK_DEAD);
+	spin_unlock(&sk->sk_receive_queue.lock);
+	sock->sk = NULL;
+
+	dbfs_atomic_inc(&cnt.num_disconnect);
+
+	if (cf_sk->debugfs_socket_dir != NULL)
+		debugfs_remove_recursive(cf_sk->debugfs_socket_dir);
+
+	lock_sock(&(cf_sk->sk));
+	sk->sk_state = CAIF_DISCONNECTED;
+	sk->sk_shutdown = SHUTDOWN_MASK;
+
+	if (cf_sk->sk.sk_socket->state == SS_CONNECTED ||
+		cf_sk->sk.sk_socket->state == SS_CONNECTING)
+		res = caif_disconnect_client(&cf_sk->layer);
+
+	cf_sk->sk.sk_socket->state = SS_DISCONNECTING;
+	wake_up_interruptible_poll(sk_sleep(sk), POLLERR|POLLHUP);
+
+	sock_orphan(sk);
+	cf_sk->layer.dn = NULL;
+	sk_stream_kill_queues(&cf_sk->sk);
+	release_sock(sk);
+	sock_put(sk);
+	return res;
+}
+
+/* Copied from af_unix.c:unix_poll(), added CAIF tx_flow handling */
+static unsigned int caif_poll(struct file *file,
+				struct socket *sock, poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	unsigned int mask;
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+
+	sock_poll_wait(file, sk_sleep(sk), wait);
+	mask = 0;
+
+	/* exceptional events? */
+	if (sk->sk_err)
+		mask |= POLLERR;
+	if (sk->sk_shutdown == SHUTDOWN_MASK)
+		mask |= POLLHUP;
+	if (sk->sk_shutdown & RCV_SHUTDOWN)
+		mask |= POLLRDHUP;
+
+	/* readable? */
+	if (!skb_queue_empty(&sk->sk_receive_queue) ||
+		(sk->sk_shutdown & RCV_SHUTDOWN))
+		mask |= POLLIN | POLLRDNORM;
+
+	/* Connection-based need to check for termination and startup */
+	if (sk->sk_state == CAIF_DISCONNECTED)
+		mask |= POLLHUP;
+
+	/*
+	 * we set writable also when the other side has shut down the
+	 * connection. This prevents stuck sockets.
+	 */
+	if (sock_writeable(sk) && tx_flow_is_on(cf_sk))
+		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+
+	return mask;
+}
+
+static const struct proto_ops caif_seqpacket_ops = {
+	.family = PF_CAIF,
+	.owner = THIS_MODULE,
+	.release = caif_release,
+	.bind = sock_no_bind,
+	.connect = caif_connect,
+	.socketpair = sock_no_socketpair,
+	.accept = sock_no_accept,
+	.getname = sock_no_getname,
+	.poll = caif_poll,
+	.ioctl = sock_no_ioctl,
+	.listen = sock_no_listen,
+	.shutdown = sock_no_shutdown,
+	.setsockopt = setsockopt,
+	.getsockopt = sock_no_getsockopt,
+	.sendmsg = caif_seqpkt_sendmsg,
+	.recvmsg = caif_seqpkt_recvmsg,
+	.mmap = sock_no_mmap,
+	.sendpage = sock_no_sendpage,
+};
+
+static const struct proto_ops caif_stream_ops = {
+	.family = PF_CAIF,
+	.owner = THIS_MODULE,
+	.release = caif_release,
+	.bind = sock_no_bind,
+	.connect = caif_connect,
+	.socketpair = sock_no_socketpair,
+	.accept = sock_no_accept,
+	.getname = sock_no_getname,
+	.poll = caif_poll,
+	.ioctl = sock_no_ioctl,
+	.listen = sock_no_listen,
+	.shutdown = sock_no_shutdown,
+	.setsockopt = setsockopt,
+	.getsockopt = sock_no_getsockopt,
+	.sendmsg = caif_stream_sendmsg,
+	.recvmsg = caif_stream_recvmsg,
+	.mmap = sock_no_mmap,
+	.sendpage = sock_no_sendpage,
+};
+
+/* This function is called when a socket is finally destroyed. */
+static void caif_sock_destructor(struct sock *sk)
+{
+	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+	caif_assert(!atomic_read(&sk->sk_wmem_alloc));
+	caif_assert(sk_unhashed(sk));
+	caif_assert(!sk->sk_socket);
+	if (!sock_flag(sk, SOCK_DEAD)) {
+		pr_info("Attempt to release alive CAIF socket: %p\n", sk);
+		return;
+	}
+	sk_stream_kill_queues(&cf_sk->sk);
+	dbfs_atomic_dec(&cnt.caif_nr_socks);
+}
+
+static int caif_create(struct net *net, struct socket *sock, int protocol,
+			int kern)
+{
+	struct sock *sk = NULL;
+	struct caifsock *cf_sk = NULL;
+	static struct proto prot = {.name = "PF_CAIF",
+		.owner = THIS_MODULE,
+		.obj_size = sizeof(struct caifsock),
+	};
+
+	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+	/*
+	 * The sock->type specifies the socket type to use.
+	 * The CAIF socket is a packet stream in the sense
+	 * that it is packet based. CAIF trusts the reliability
+	 * of the link, no resending is implemented.
+	 */
+	if (sock->type == SOCK_SEQPACKET)
+		sock->ops = &caif_seqpacket_ops;
+	else if (sock->type == SOCK_STREAM)
+		sock->ops = &caif_stream_ops;
+	else
+		return -ESOCKTNOSUPPORT;
+
+	if (protocol < 0 || protocol >= CAIFPROTO_MAX)
+		return -EPROTONOSUPPORT;
+	/*
+	 * Set the socket state to unconnected.	 The socket state
+	 * is really not used at all in the net/core or socket.c but the
+	 * initialization makes sure that sock->state is not uninitialized.
+	 */
+	sk = sk_alloc(net, PF_CAIF, GFP_KERNEL, &prot);
+	if (!sk)
+		return -ENOMEM;
+
+	cf_sk = container_of(sk, struct caifsock, sk);
+
+	/* Store the protocol */
+	sk->sk_protocol = (unsigned char) protocol;
+
+	/* Sendbuf dictates the amount of outbound packets not yet sent */
+	sk->sk_sndbuf = CAIF_DEF_SNDBUF;
+	sk->sk_rcvbuf = CAIF_DEF_RCVBUF;
+
+	/*
+	 * Lock in order to try to stop someone from opening the socket
+	 * too early.
+	 */
+	lock_sock(&(cf_sk->sk));
+
+	/* Initialize the nozero default sock structure data. */
+	sock_init_data(sock, sk);
+	sk->sk_destruct = caif_sock_destructor;
+
+	mutex_init(&cf_sk->readlock); /* single task reading lock */
+	cf_sk->layer.ctrlcmd = caif_ctrl_cb;
+	cf_sk->sk.sk_socket->state = SS_UNCONNECTED;
+	cf_sk->sk.sk_state = CAIF_DISCONNECTED;
+
+	set_tx_flow_off(cf_sk);
+	set_rx_flow_on(cf_sk);
+
+	/* Set default options on configuration */
+	cf_sk->conn_req.priority = CAIF_PRIO_NORMAL;
+	cf_sk->conn_req.link_selector = CAIF_LINK_LOW_LATENCY;
+	cf_sk->conn_req.protocol = protocol;
+	/* Increase the number of sockets created. */
+	dbfs_atomic_inc(&cnt.caif_nr_socks);
+#ifdef CONFIG_DEBUG_FS
+	if (!IS_ERR(debugfsdir)) {
+		/* Fill in some information concerning the misc socket. */
+		snprintf(cf_sk->name, sizeof(cf_sk->name), "cfsk%d",
+				atomic_read(&cnt.caif_nr_socks));
+
+		cf_sk->debugfs_socket_dir =
+			debugfs_create_dir(cf_sk->name, debugfsdir);
+		debugfs_create_u32("sk_state", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_socket_dir,
+				(u32 *) &cf_sk->sk.sk_state);
+		debugfs_create_u32("flow_state", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_socket_dir, &cf_sk->flow_state);
+		debugfs_create_u32("sk_rmem_alloc", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_socket_dir,
+				(u32 *) &cf_sk->sk.sk_rmem_alloc);
+		debugfs_create_u32("sk_wmem_alloc", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_socket_dir,
+				(u32 *) &cf_sk->sk.sk_wmem_alloc);
+		debugfs_create_u32("identity", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_socket_dir,
+				(u32 *) &cf_sk->layer.id);
+	}
+#endif
+	release_sock(&cf_sk->sk);
+	return 0;
+}
+
+
+static struct net_proto_family caif_family_ops = {
+	.family = PF_CAIF,
+	.create = caif_create,
+	.owner = THIS_MODULE,
+};
+
+int af_caif_init(void)
+{
+	int err = sock_register(&caif_family_ops);
+	if (!err)
+		return err;
+	return 0;
+}
+
+static int __init caif_sktinit_module(void)
+{
+#ifdef CONFIG_DEBUG_FS
+	debugfsdir = debugfs_create_dir("caif_sk", NULL);
+	if (!IS_ERR(debugfsdir)) {
+		debugfs_create_u32("num_sockets", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.caif_nr_socks);
+		debugfs_create_u32("num_connect_req", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.num_connect_req);
+		debugfs_create_u32("num_connect_resp", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.num_connect_resp);
+		debugfs_create_u32("num_connect_fail_resp", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.num_connect_fail_resp);
+		debugfs_create_u32("num_disconnect", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.num_disconnect);
+		debugfs_create_u32("num_remote_shutdown_ind",
+				S_IRUSR | S_IWUSR, debugfsdir,
+				(u32 *) &cnt.num_remote_shutdown_ind);
+		debugfs_create_u32("num_tx_flow_off_ind", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.num_tx_flow_off_ind);
+		debugfs_create_u32("num_tx_flow_on_ind", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.num_tx_flow_on_ind);
+		debugfs_create_u32("num_rx_flow_off", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.num_rx_flow_off);
+		debugfs_create_u32("num_rx_flow_on", S_IRUSR | S_IWUSR,
+				debugfsdir,
+				(u32 *) &cnt.num_rx_flow_on);
+	}
+#endif
+	return af_caif_init();
+}
+
+static void __exit caif_sktexit_module(void)
+{
+	sock_unregister(PF_CAIF);
+	if (debugfsdir != NULL)
+		debugfs_remove_recursive(debugfsdir);
+}
+module_init(caif_sktinit_module);
+module_exit(caif_sktexit_module);
-- 
1.6.3.3

