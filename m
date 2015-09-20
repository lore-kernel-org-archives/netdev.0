From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 2/3] kcm: Kernel Connection Multiplexor module
Date: Sun, 20 Sep 2015 15:29:20 -0700
Message-ID: <1442788161-2626305-3-git-send-email-tom@herbertland.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:3866 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755393AbbITWbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 18:31:07 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t8KJHLjV028432
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 15:31:07 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1x22tp0k7a-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 15:31:07 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 46f1b55c5fe711e5975c0002c992ebde-78dfd240 for <netdev@vger.kernel.org>;	Sun,
 20 Sep 2015 15:31:04 -0700
In-Reply-To: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This module implement the Kernel Connection Multiplexor.

Kernel Connection Multiplexor (KCM) is a facility that provides a
message based interface over TCP for generic application protocols.
With KCM an application can efficiently send and receive application
protocol messages over TCP using datagram sockets.

For more information see the included Documentation/networking/kcm.txt

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 Documentation/networking/kcm.txt |  173 +++++
 include/linux/socket.h           |    6 +-
 include/net/kcm.h                |  109 +++
 include/uapi/linux/errqueue.h    |    1 +
 include/uapi/linux/kcm.h         |   26 +
 net/Kconfig                      |    1 +
 net/Makefile                     |    1 +
 net/kcm/Kconfig                  |   10 +
 net/kcm/Makefile                 |    3 +
 net/kcm/kcmsock.c                | 1566 ++++++++++++++++++++++++++++++++++++++
 10 files changed, 1895 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/kcm.txt
 create mode 100644 include/net/kcm.h
 create mode 100644 include/uapi/linux/kcm.h
 create mode 100644 net/kcm/Kconfig
 create mode 100644 net/kcm/Makefile
 create mode 100644 net/kcm/kcmsock.c

diff --git a/Documentation/networking/kcm.txt b/Documentation/networking/kcm.txt
new file mode 100644
index 0000000..2e0968d
--- /dev/null
+++ b/Documentation/networking/kcm.txt
@@ -0,0 +1,173 @@
+Kernel Connection Mulitplexor
+-----------------------------
+
+Kernel Connection Multiplexor (KCM) is a mechanism that provides a message based
+interface over TCP for generic application protocols. With KCM an application
+can efficiently send and receive application protocol messages over TCP using
+datagram sockets.
+
+KCM implements an NxM multiplexor in the kernel as diagrammed below:
+
++------------+   +------------+   +------------+   +------------+
+| KCM socket |   | KCM socket |   | KCM socket |   | KCM socket |
++------------+   +------------+   +------------+   +------------+
+      |                 |               |                |
+      +-----------+     |               |     +----------+
+                  |     |               |     |
+               +----------------------------------+
+               |           Multiplexor            |
+               +----------------------------------+
+                 |   |           |           |  |
+       +---------+   |           |           |  ------------+
+       |             |           |           |              |
++----------+  +----------+  +----------+  +----------+ +----------+
+|  Psock   |  |  Psock   |  |  Psock   |  |  Psock   | |  Psock   |
++----------+  +----------+  +----------+  +----------+ +----------+
+      |              |           |            |             |
++----------+  +----------+  +----------+  +----------+ +----------+
+| TCP sock |  | TCP sock |  | TCP sock |  | TCP sock | | TCP sock |
++----------+  +----------+  +----------+  +----------+ +----------+
+
+KCM sockets
+-----------
+
+The KCM sockets provide the user interface to the muliplexor. All the KCM sockets
+bound to a multiplexor are considered to have equivalent function, and I/O
+operations in different sockets may be done in parallel without the need for
+synchronization between threads in userspace.
+
+Multiplexor
+-----------
+
+The multiplexor provides the message steering. In the transmit path, messages
+written on a KCM socket are sent atomically on an appropriate TCP socket.
+Similarly, in the receive path, messages are constructed on each TCP socket
+(Psock) and complete messages are steered to a KCM socket which is blocking in
+receive or poll.
+
+TCP sockets & Psocks
+--------------------
+
+TCP sockets may be bound to a KCM multiplexor. A Psock structure is allocacted
+for each bound TCP socket, this structure holds the state for constructing
+messages on receive as well as other connection specific information for KCM.
+
+Connected mode semantics
+------------------------
+
+Each multiplexor assumes that all attached TCP connections are to the same
+destination and can use the different connections for load balancing when
+transmitting. The normal send and recv calls can be used to send and receive
+messages from the KCM socket.
+
+SOCK_DGRAM
+----------
+
+KCM currently support socket type SOCK_DGRAM only.
+
+Message delineation
+-------------------
+
+Messages are sent over a TCP stream with some application protocol message
+format that typically includes a header which encapsulates messages. The length
+of a received message can be deduced from the application protocol header
+(often just a simple length field).
+
+A TCP stream must be parsed to determine message boundaries. Berkeley Packet
+Filter (BPF) is used for this. When attaching a TCP socket to a multiplexor a
+BPF program must be specified. The program is called at the start of receiving
+a new message and is given an skbuff that contains the bytes received so far.
+It parses the message header and returns the length of the message. Given this
+information, KCM will construct the message of the stated length and deliver it
+to a KCM socket.
+
+TCP socket management
+---------------------
+
+When a TCP socket is attached to a KCM multiplexor data ready (POLLIN) and
+write space available (POLLOUT) events are handled by the multiplexor. If there
+is a state change (disconnection) or other error on a TCP socket, an error is
+posted on the socket so that an POLLERR event happens and KCM discontinues using
+the socket. In the case of an error affecting the receive side of the
+connection, any partial message under construction will also be set on the error
+queue for the TCP socket. When the application gets the error notification for a
+TCP socket it should unattach the socket from KCM and then handle the error
+condition (the typical response is to close the socket and create a new
+connection if necessary).
+
+User interface
+==============
+
+Creating a multiplexor
+----------------------
+
+A new multiplexor and initial KCM socket is created by a socket call:
+
+  socket(AF_KCM, type, protocol)
+
+  - type is either SOCK_DGRAM
+  - protocols is either KCMPROTO_CONNECTED
+
+Cloning KCM sockets
+-------------------
+
+After the first KCM socket is created using the socket call as described
+above, additional sockets for the multiplexor can be created by cloning
+a KCM socket. This is accomplished by calling accept on the KCM socket:
+
+   newkcmfd = accept(kcmfd, NULL, 0)
+
+Attach transport sockets
+------------------------
+
+Attaching of transport sockets to a multiplexor is performed by calling on
+ioctl on a KCM socket for the multiplexor. e.g.:
+
+  /* From linux/kcm.h */
+  struct kcm_attach {
+        int fd;
+        int bpf_type;
+        union {
+                int bpf_fd;
+                struct sock_fprog fprog;
+        };
+  };
+
+  struct kcm_attach info;
+
+  memset(&info, 0, sizeof(info));
+
+  info.fd = tcpfd;
+  info.bpf_type = KCM_BPF_TYPE_PROG;
+  info.bpf_fprog = bpf_prog;
+
+  ioctl(kcmfd, SIOCKCMATTACH, &info);
+
+The kcm_attach structure contains:
+  fd: file descriptor for TCP socket being attached
+  bpf_type: type of BPF program to be loaded this is either:
+    KCM_BPF_TYPE_PROG: program load directly for user space
+    KCM_BPF_TYPE_FD: Complied rogram to be load for the specified file
+                     descriptor (see BPF LLVM and Clang)
+  bpf_fprog: contains pointer to user space protocol to load
+  bpf_fd: file descriptor for compiled program download
+
+Unattach transport sockets
+--------------------------
+
+Unattaching a transport socket from a multiplexor is straightforward. An
+"unattach" ioctl is done with the kcm_unattach structure as the argument:
+
+  /* From linux/kcm.h /
+  struct kcm_unattach {
+        int fd;
+  };
+
+  struct kcm_unattach info;
+
+  memset(&info, 0, sizeof(info));
+
+  info.fd = cfd;
+
+  ioctl(fd, SIOCKCMUNATTACH, &info);
+
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5bf59c8..4e1ea53 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -200,7 +200,9 @@ struct ucred {
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
 #define AF_VSOCK	40	/* vSockets			*/
-#define AF_MAX		41	/* For now.. */
+#define AF_KCM		41	/* Kernel Connection Multiplexor*/
+
+#define AF_MAX		42	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -246,6 +248,7 @@ struct ucred {
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
 #define PF_VSOCK	AF_VSOCK
+#define PF_KCM		AF_KCM
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -322,6 +325,7 @@ struct ucred {
 #define SOL_CAIF	278
 #define SOL_ALG		279
 #define SOL_NFC		280
+#define SOL_KCM		281
 
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/include/net/kcm.h b/include/net/kcm.h
new file mode 100644
index 0000000..55ef56b
--- /dev/null
+++ b/include/net/kcm.h
@@ -0,0 +1,109 @@
+/* Kernel Connection Multiplexor */
+
+#ifndef __NET_KCM_H_
+#define __NET_KCM_H_
+
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <uapi/linux/kcm.h>
+
+#ifdef __KERNEL__
+
+extern unsigned int kcm_net_id;
+
+struct kcm_tx_msg {
+	unsigned int sent;
+	unsigned int fragidx;
+	unsigned int frag_offset;
+	unsigned int msg_flags;
+	struct sk_buff *frag_skb;
+};
+
+struct kcm_rx_msg {
+	int full_len;
+	int accum_len;
+};
+
+/* Socket structure for KCM client sockets */
+struct kcm_sock {
+	struct sock sk;
+	struct kcm_mux *mux;
+	struct list_head kcm_sock_list;
+
+	/* Transmit */
+	struct kcm_psock *tx_psock;
+	struct work_struct tx_work;
+	struct list_head wait_psock_list;
+	u32 tx_wait : 1;
+
+	/* Receive */
+	struct kcm_psock *rx_psock;
+	struct list_head wait_rx_list; /* KCMs waiting for receiving */
+	u32 rx_wait : 1;
+};
+
+struct bpf_prog;
+
+/* Structure for an attached lower socket */
+struct kcm_psock {
+	struct sock *sk;
+	struct kcm_mux *mux;
+
+	u32 tx_stopped : 1;
+	u32 rx_stopped : 1;
+	u32 done : 1;
+	u32 unattaching : 1;
+	u32 bpf_prog_fd : 1;
+
+	void (*save_state_change)(struct sock *sk);
+	void (*save_data_ready)(struct sock *sk);
+	void (*save_write_space)(struct sock *sk);
+
+	struct list_head psock_list;
+
+	/* Receive */
+	struct sk_buff *rx_skb_head;
+	struct sk_buff **rx_skb_nextp;
+	struct sk_buff *ready_rx_msg;
+	struct list_head psock_ready_list;
+	struct work_struct rx_work;
+	struct delayed_work rx_delayed_work;
+	struct bpf_prog *bpf_prog;
+
+	/* Transmit */
+	struct kcm_sock *tx_kcm;
+	struct list_head psock_avail_list;
+};
+
+/* Per net MUX list */
+struct kcm_net {
+	struct mutex mutex;
+	struct list_head mux_list;
+	int count;
+};
+
+/* Structure for a MUX */
+struct kcm_mux {
+	struct list_head kcm_mux_list;
+	struct rcu_head rcu;
+	struct kcm_net *knet;
+
+	spinlock_t  lock;		/* RX and TX locking */
+	struct list_head kcm_socks;	/* All KCM sockets on MUX */
+	int kcm_socks_cnt;		/* Total KCM socket count for MUX */
+	struct list_head psocks;	/* List of all psocks on MUX */
+	int psocks_cnt;		/* Total attached sockets */
+
+	/* Receive */
+	struct list_head kcm_rx_waiters; /* KCMs waiting for receiving */
+	struct kcm_sock *last_rx_kcm;
+	struct list_head psocks_ready;	/* List of psocks with a msg ready */
+
+	/* Transmit */
+	struct list_head psocks_avail;	/* List of available psocks */
+	struct list_head kcm_tx_waiters; /* KCMs waiting for a TX psock */
+};
+
+#endif /* __KERNEL__ */
+
+#endif /* __NET_KCM_H_ */
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 07bdce1..6a8e2f2 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -18,6 +18,7 @@ struct sock_extended_err {
 #define SO_EE_ORIGIN_ICMP	2
 #define SO_EE_ORIGIN_ICMP6	3
 #define SO_EE_ORIGIN_TXSTATUS	4
+#define SO_EE_ORIGIN_KCM	5
 #define SO_EE_ORIGIN_TIMESTAMPING SO_EE_ORIGIN_TXSTATUS
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
diff --git a/include/uapi/linux/kcm.h b/include/uapi/linux/kcm.h
new file mode 100644
index 0000000..196622e
--- /dev/null
+++ b/include/uapi/linux/kcm.h
@@ -0,0 +1,26 @@
+#ifndef KCM_KERNEL_H
+#define KCM_KERNEL_H
+
+struct kcm_attach {
+	int fd;
+	int bpf_type;
+	union {
+		struct sock_fprog bpf_fprog;
+		int bpf_fd;
+	};
+};
+
+#define KCM_BPF_TYPE_PROG	0x1
+#define KCM_BPF_TYPE_FD		0x2
+
+struct kcm_unattach {
+	int fd;
+};
+
+#define SIOCKCMATTACH	(SIOCPROTOPRIVATE + 0)
+#define SIOCKCMUNATTACH	(SIOCPROTOPRIVATE + 1)
+
+#define KCMPROTO_CONNECTED	0
+
+#endif
+
diff --git a/net/Kconfig b/net/Kconfig
index 7021c1b..cc5a020 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -350,6 +350,7 @@ source "net/can/Kconfig"
 source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/rxrpc/Kconfig"
+source "net/kcm/Kconfig"
 
 config FIB_RULES
 	bool
diff --git a/net/Makefile b/net/Makefile
index 3995613..2b5d24d 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_IRDA)		+= irda/
 obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
 obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
+obj-$(CONFIG_AF_KCM)		+= kcm/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_L2TP)		+= l2tp/
 obj-$(CONFIG_DECNET)		+= decnet/
diff --git a/net/kcm/Kconfig b/net/kcm/Kconfig
new file mode 100644
index 0000000..5ee5294
--- /dev/null
+++ b/net/kcm/Kconfig
@@ -0,0 +1,10 @@
+
+config AF_KCM
+	tristate "KCM sockets"
+	depends on INET
+	select BPF_SYSCALL
+	---help---
+	  KCM (Kernel Connection Multiplexer) sockets provide a method
+	  for multiplexing a messages based user space protocol over
+	  kernel connectons (e.g. TCP connections).
+
diff --git a/net/kcm/Makefile b/net/kcm/Makefile
new file mode 100644
index 0000000..cb525f7
--- /dev/null
+++ b/net/kcm/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_AF_KCM) += kcm.o
+
+kcm-y := kcmsock.o
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
new file mode 100644
index 0000000..0240ce3
--- /dev/null
+++ b/net/kcm/kcmsock.c
@@ -0,0 +1,1566 @@
+#include <linux/bpf.h>
+#include <linux/errno.h>
+#include <linux/errqueue.h>
+#include <linux/file.h>
+#include <linux/in.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/poll.h>
+#include <linux/rculist.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/uaccess.h>
+#include <linux/workqueue.h>
+#include <net/kcm.h>
+#include <net/netns/generic.h>
+#include <net/sock.h>
+#include <net/tcp.h>
+#include <uapi/linux/kcm.h>
+
+unsigned int kcm_net_id;
+
+static struct kmem_cache *kcm_psockp __read_mostly;
+static struct kmem_cache *kcm_muxp __read_mostly;
+static struct workqueue_struct *kcm_wq;
+
+static inline struct kcm_sock *kcm_sk(const struct sock *sk)
+{
+	return (struct kcm_sock *)sk;
+}
+
+static inline struct kcm_tx_msg *kcm_tx_msg(struct sk_buff *skb)
+{
+	return (struct kcm_tx_msg *)skb->cb;
+}
+
+static inline struct kcm_rx_msg *kcm_rx_msg(struct sk_buff *skb)
+{
+	return (struct kcm_rx_msg *)skb->cb;
+}
+
+/* Lower socket locked */
+static void kcm_abort_rx_psock(struct kcm_psock *psock, int err,
+			       struct sk_buff *skb)
+{
+	struct sock_exterr_skb *serr;
+	struct sock *csk = psock->sk;
+
+	/* Unrecoverable error in receive */
+
+	if (psock->rx_stopped)
+		return;
+
+	psock->rx_stopped = 1;
+
+	if (!skb)
+		return;
+
+	/* Put the offending skb data on transport socket's error queue with
+	 * the error number.
+	 */
+	serr = SKB_EXT_ERR(skb);
+
+	memset(serr, 0, sizeof(*serr));
+	serr->ee.ee_errno = err;
+	serr->ee.ee_origin = SO_EE_ORIGIN_KCM;
+
+	/* Note sock_queue_err_skb calls sk_data_ready which still points to
+	 * the psock_tcp_data_ready, this should not be a problem since we've
+	 * set rx_stopped to that kcm_data_ready will just return.
+	 */
+
+	sock_queue_err_skb(csk, skb);
+
+	/* Wake up transport socket */
+	psock->save_data_ready(csk);
+}
+
+static void kcm_abort_tx_psock(struct kcm_psock *psock, int err,
+			       bool wakeup_kcm, bool report_transport)
+{
+	struct sock *csk = psock->sk;
+	struct kcm_mux *mux = psock->mux;
+
+	/* Unrecoverable error in transmit */
+
+	spin_lock_bh(&mux->lock);
+
+	if (psock->tx_stopped) {
+		spin_unlock_bh(&mux->lock);
+		return;
+	}
+
+	psock->tx_stopped = 1;
+
+	if (!psock->tx_kcm) {
+		/* Take off psocks_avail list */
+		list_del(&psock->psock_avail_list);
+	} else if (wakeup_kcm) {
+		/* In this case psock is being aborted while outside of
+		 * write_msgs and psock is reserved. Schedule tx_work
+		 * to handle the failure there.
+		 */
+		queue_work(kcm_wq, &psock->tx_kcm->tx_work);
+	}
+
+	spin_unlock_bh(&mux->lock);
+
+	if (report_transport) {
+		/* Report error on lower socket */
+
+		lock_sock(csk);
+		csk->sk_err = err;
+		csk->sk_error_report(csk);
+		release_sock(csk);
+	}
+}
+
+static void kcm_abort_psock(struct kcm_psock *psock, int err,
+			    bool wakeup_kcm, bool report_transport)
+{
+	/* Lower socket pretty much dead */
+
+	kcm_abort_rx_psock(psock, err, NULL);
+	kcm_abort_tx_psock(psock, err, wakeup_kcm, report_transport);
+}
+
+/* Process a new message. If there is no KCM socket waiting for a message
+ * hold it in the psock. Returns true if message is held this way, false
+ * otherwise.
+ */
+static bool new_rx_msg(struct kcm_psock *psock, struct sk_buff *head)
+{
+	struct kcm_mux *mux = psock->mux;
+	struct kcm_sock *kcm = NULL;
+	struct sock *sk;
+
+	spin_lock_bh(&mux->lock);
+
+	if (WARN_ON(psock->ready_rx_msg)) {
+		spin_unlock_bh(&mux->lock);
+		kfree_skb(head);
+		return false;
+	}
+
+	if (list_empty(&mux->kcm_rx_waiters)) {
+		psock->ready_rx_msg = head;
+
+		list_add_tail(&psock->psock_ready_list,
+			      &mux->psocks_ready);
+
+		spin_unlock_bh(&mux->lock);
+		return true;
+	}
+
+	kcm = list_first_entry(&mux->kcm_rx_waiters,
+			       struct kcm_sock, wait_rx_list);
+	WARN_ON(!kcm->rx_wait);
+
+	list_del(&kcm->wait_rx_list);
+	kcm->rx_wait = 0;
+
+	spin_unlock_bh(&mux->lock);
+
+	sk = &kcm->sk;
+
+	skb_queue_tail(&sk->sk_receive_queue, head);
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk);
+
+	return false;
+}
+
+/* Receive a message to a kcm socket from a psock that is on the ready list
+ * Mux lock is held here.
+ */
+static bool queue_ready_msg_to_kcm(struct kcm_mux *mux, struct kcm_sock *kcm)
+{
+	struct sock *sk = &kcm->sk;
+	struct kcm_psock *psock;
+	struct sk_buff *skb;
+
+	if (list_empty(&mux->psocks_ready))
+		return false;
+
+	psock = list_first_entry(&mux->psocks_ready,
+				 struct kcm_psock, psock_ready_list);
+
+	skb = psock->ready_rx_msg;
+	list_del(&psock->psock_ready_list);
+
+	psock->ready_rx_msg = NULL;
+
+	/* Read more */
+	queue_work(kcm_wq, &psock->rx_work);
+
+	if (WARN_ON(!skb))
+		return false;
+
+	skb_set_owner_r(skb, sk);
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+
+	return true;
+}
+
+/* A state change on a connected socket means it's dying or dead. */
+static void
+psock_tcp_state_change(struct sock *sk)
+{
+	struct kcm_psock *psock = (struct kcm_psock *)sk->sk_user_data;
+	int err = sk->sk_err ? : EPIPE;
+
+	if (WARN_ON(!psock))
+		return;
+
+	/* Abort the psock, report as an EPIPE error on original socket */
+	kcm_abort_psock(psock, err, true, false);
+
+	/* Report an EPIPE error on the socket. We do this here instead of in
+	 * kcm_tx_abort_sock since we already hold the socket lock.
+	 */
+	sk->sk_err = err;
+	sk->sk_error_report(sk);
+}
+
+/* Macro to invoke filter function. */
+#define KCM_RUN_FILTER(prog, ctx) \
+	(*prog->bpf_func)(ctx, prog->insnsi)
+
+static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
+			unsigned int offset, size_t orig_len)
+{
+	struct kcm_psock *psock = (struct kcm_psock *)desc->arg.data;
+	struct kcm_rx_msg *rxm;
+	struct sk_buff *head, *skb;
+	size_t eaten = 0;
+	ssize_t extra;
+	int err;
+
+	if (WARN_ON(psock->rx_stopped))
+		return 0;
+
+	if (psock->ready_rx_msg)
+		return 0;
+
+	head = psock->rx_skb_head;
+	if (head && !psock->rx_skb_nextp) {
+		int err;
+
+		/* We are going to append to the frags_list of head. Need to
+		 * unshare the skbuf data as wells as all the skbs on the
+		 * frag_list (if there are any). We deferred this work in hopes
+		 * that orignal skbuff was consumed by the stack so that there
+		 * is less work needed here.
+		 */
+		if (unlikely(skb_shinfo(head)->frag_list)) {
+			if (WARN_ON(head->next)) {
+				desc->error = -EINVAL;
+				return 0;
+			}
+
+			skb = alloc_skb(0, GFP_ATOMIC);
+			if (!skb) {
+				desc->error = -ENOMEM;
+				return 0;
+			}
+			skb->len = head->len;
+			skb->data_len = head->len;
+			skb->truesize = head->truesize;
+			*kcm_rx_msg(skb) = *kcm_rx_msg(head);
+			psock->rx_skb_nextp = &head->next;
+			skb_shinfo(skb)->frag_list = head;
+			psock->rx_skb_head = skb;
+			head = skb;
+		} else {
+			err = skb_unclone(head, GFP_ATOMIC);
+			if (err) {
+				desc->error = err;
+				return 0;
+			}
+			psock->rx_skb_nextp =
+			    &skb_shinfo(head)->frag_list;
+		}
+	}
+
+	while (eaten < orig_len) {
+		/* Always clone since we will consume something */
+		skb = skb_clone(orig_skb, GFP_ATOMIC);
+		if (!skb) {
+			desc->error = -ENOMEM;
+			break;
+		}
+
+		if (!pskb_pull(skb, offset + eaten)) {
+			kfree_skb(skb);
+			desc->error = -ENOMEM;
+			break;
+		}
+
+		if (WARN_ON(skb->len < orig_len - eaten)) {
+			kfree_skb(skb);
+			desc->error = -EINVAL;
+			break;
+		}
+
+		/* Need to trim should be rare */
+		err = pskb_trim(skb, orig_len - eaten);
+		if (err) {
+			kfree_skb(skb);
+			desc->error = err;
+			break;
+		}
+
+		/* Preliminary */
+		eaten += skb->len;
+
+		head = psock->rx_skb_head;
+		if (!head) {
+			head = skb;
+			psock->rx_skb_head = head;
+			/* Will set rx_skb_nextp on next packet if needed */
+			psock->rx_skb_nextp = NULL;
+			rxm = kcm_rx_msg(head);
+			memset(rxm, 0, sizeof(*rxm));
+			rxm->accum_len = head->len;
+		} else {
+			rxm = kcm_rx_msg(head);
+			*psock->rx_skb_nextp = skb;
+			psock->rx_skb_nextp = &skb->next;
+			rxm->accum_len += skb->len;
+			head->data_len += skb->len;
+			head->len += skb->len;
+			head->truesize += skb->truesize;
+		}
+
+		if (!rxm->full_len) {
+			ssize_t len;
+
+			len = KCM_RUN_FILTER(psock->bpf_prog, head);
+
+			if (!len) {
+				/* Need more header to determine length */
+				break;
+			} else if (len <= head->len - skb->len) {
+				/* Length must be into new skb (and also
+				 * greater than zero)
+				 */
+				desc->error = -EPROTO;
+				psock->rx_skb_head = NULL;
+				kcm_abort_rx_psock(psock, EPROTO, head);
+				break;
+			}
+
+			rxm->full_len = len;
+		}
+
+		extra = (ssize_t)rxm->accum_len - rxm->full_len;
+
+		if (extra < 0) {
+			/* Message not complete yet. */
+			break;
+		} else if (extra > 0) {
+			/* More bytes than needed for the message */
+
+			WARN_ON(extra > skb->len);
+
+			/* We don't bother calling pskb_trim here. The skbuff
+			 * holds the full message size which is used to
+			 * copy data out.
+			 */
+
+			eaten -= extra;
+		}
+
+		/* Hurray, we have a new message! */
+		psock->rx_skb_head = NULL;
+
+		if (new_rx_msg(psock, head)) {
+			/* Message was held at psock */
+			break;
+		}
+	}
+
+	return eaten;
+}
+
+static int psock_tcp_read_sock(struct kcm_psock *psock)
+{
+	read_descriptor_t desc;
+
+	desc.arg.data = psock;
+	desc.error = 0;
+	desc.count = 1; /* give more than one skb per call */
+
+	/* sk should be locked here, so okay to do tcp_read_sock */
+	tcp_read_sock(psock->sk, &desc, kcm_tcp_recv);
+
+	return desc.error;
+}
+
+static void psock_tcp_data_ready(struct sock *sk)
+{
+	struct kcm_psock *psock = (struct kcm_psock *)sk->sk_user_data;
+
+	if (unlikely(psock->rx_stopped))
+		return;
+
+	read_lock_bh(&sk->sk_callback_lock);
+
+	if (psock->ready_rx_msg)
+		goto out;
+
+	if (psock_tcp_read_sock(psock) == -ENOMEM)
+		queue_delayed_work(kcm_wq, &psock->rx_delayed_work, 0);
+
+out:
+	read_unlock_bh(&sk->sk_callback_lock);
+}
+
+static void do_psock_rx_work(struct kcm_psock *psock)
+{
+	read_descriptor_t rd_desc;
+	struct sock *csk = psock->sk;
+
+	/* Lock sock */
+	lock_sock(csk);
+
+	if (unlikely(psock->rx_stopped)) {
+		release_sock(csk);
+		return;
+	}
+
+	read_lock_bh(&csk->sk_callback_lock);
+
+	if (psock->ready_rx_msg) {
+		/* Already have a message pending, no work to do */
+		read_unlock_bh(&csk->sk_callback_lock);
+		release_sock(psock->sk);
+		return;
+	}
+
+	rd_desc.arg.data = psock;
+
+	if (psock_tcp_read_sock(psock) == -ENOMEM)
+		queue_delayed_work(kcm_wq, &psock->rx_delayed_work, 0);
+
+	read_unlock_bh(&csk->sk_callback_lock);
+	release_sock(psock->sk);
+}
+
+static void psock_rx_work(struct work_struct *w)
+{
+	do_psock_rx_work(container_of(w, struct kcm_psock, rx_work));
+}
+
+static void psock_rx_delayed_work(struct work_struct *w)
+{
+	do_psock_rx_work(container_of(w, struct kcm_psock,
+				      rx_delayed_work.work));
+}
+
+static void psock_tcp_write_space(struct sock *sk)
+{
+	struct kcm_psock *psock = (struct kcm_psock *)sk->sk_user_data;
+	struct kcm_mux *mux = psock->mux;
+	struct kcm_sock *kcm;
+
+	if (WARN_ON(!psock))
+		return;
+
+	spin_lock_bh(&mux->lock);
+
+	/* Check if the socket is reserved so someone is waiting for sending. */
+	kcm = psock->tx_kcm;
+	if (kcm)
+		queue_work(kcm_wq, &kcm->tx_work);
+
+	spin_unlock_bh(&mux->lock);
+}
+
+/* Assumes kcm sock is locked. */
+static struct kcm_psock *reserve_psock(struct kcm_sock *kcm,
+				       bool wait, int *ret_err)
+{
+	struct kcm_mux *mux = kcm->mux;
+	struct kcm_psock *psock = NULL;
+	int err = 0;
+
+	if (kcm->tx_psock)
+		return kcm->tx_psock;
+
+	spin_lock_bh(&mux->lock);
+
+	/* Check again under lock to see if psock was reserved for this
+	 * psock via psock_unreserve.
+	 */
+	if (kcm->tx_psock) {
+		spin_unlock_bh(&mux->lock);
+		return kcm->tx_psock;
+	}
+
+	if (!list_empty(&mux->psocks_avail)) {
+		psock = list_first_entry(&mux->psocks_avail,
+					 struct kcm_psock,
+					 psock_avail_list);
+		list_del(&psock->psock_avail_list);
+		if (kcm->tx_wait) {
+			list_del(&kcm->wait_psock_list);
+			kcm->tx_wait = 0;
+		}
+		kcm->tx_psock = psock;
+		psock->tx_kcm = kcm;
+	} else if (kcm->tx_wait) {
+		err = -EAGAIN;
+	} else {
+		if (mux->psocks_cnt && wait) {
+			list_add_tail(&kcm->wait_psock_list,
+				      &mux->kcm_tx_waiters);
+			kcm->tx_wait = 1;
+			err = -EAGAIN;
+		} else {
+			err = -EPIPE;
+		}
+	}
+
+	spin_unlock_bh(&mux->lock);
+
+	*ret_err = err;
+	return psock;
+}
+
+/* mux lock held */
+static void psock_now_avail(struct kcm_psock *psock)
+{
+	struct kcm_mux *mux = psock->mux;
+	struct kcm_sock *kcm;
+
+	if (list_empty(&mux->kcm_tx_waiters)) {
+		list_add_tail(&psock->psock_avail_list,
+			      &mux->psocks_avail);
+	} else {
+		kcm = list_first_entry(&mux->kcm_tx_waiters,
+				       struct kcm_sock,
+				       wait_psock_list);
+		list_del(&kcm->wait_psock_list);
+		kcm->tx_wait = 0;
+		kcm->tx_psock = psock;
+		psock->tx_kcm = kcm;
+		queue_work(kcm_wq, &kcm->tx_work);
+	}
+}
+
+/* Assumes kcm sock is locked. */
+static void unreserve_psock(struct kcm_sock *kcm)
+{
+	struct kcm_psock *psock = kcm->tx_psock;
+	struct kcm_mux *mux = kcm->mux;
+
+	if (WARN_ON(!psock))
+		return;
+
+	spin_lock_bh(&mux->lock);
+
+	WARN_ON(kcm->tx_wait);
+
+	kcm->tx_psock = NULL;
+	psock->tx_kcm = NULL;
+
+	if (unlikely(psock->done || psock->tx_stopped)) {
+		if (psock->done) {
+			/* Deferred free */
+			list_del(&psock->psock_list);
+			mux->psocks_cnt--;
+			sock_put(psock->sk);
+			fput(psock->sk->sk_socket->file);
+			kmem_cache_free(kcm_psockp, psock);
+		}
+
+		/* Don't put back on available list */
+
+		spin_unlock_bh(&mux->lock);
+
+		return;
+	}
+
+	psock_now_avail(psock);
+
+	spin_unlock_bh(&mux->lock);
+}
+
+/* Write any messages ready on the kcm socket.  Called with kcm sock lock
+ * held.  Return bytes actually sent or error.
+ */
+static int kcm_write_msgs(struct kcm_sock *kcm)
+{
+	struct sock *sk = &kcm->sk;
+	struct kcm_psock *psock;
+	struct sk_buff *skb, *head;
+	struct kcm_tx_msg *txm;
+	unsigned short fragidx, frag_offset;
+	unsigned int sent, total_sent = 0;
+	int ret = 0;
+
+	if (WARN_ON(skb_queue_empty(&sk->sk_write_queue)))
+		return 0;
+
+	head = skb_peek(&sk->sk_write_queue);
+
+	psock = kcm->tx_psock;
+	txm = kcm_tx_msg(head);
+
+	if (unlikely(psock && psock->tx_stopped)) {
+		/* A reserved psock was aborted asynchronously. Unreserve
+		 * it and we'll retry the message.
+		 */
+		unreserve_psock(kcm);
+		txm->sent = 0;
+	} else if (txm->sent) {
+		/* Send of first skbuff in queue already in progress */
+		if (WARN_ON(!psock)) {
+			ret = -EINVAL;
+			goto out;
+		}
+		sent = txm->sent;
+		frag_offset = txm->frag_offset;
+		fragidx = txm->fragidx;
+		skb = txm->frag_skb;
+
+		goto do_frag;
+	}
+
+try_again:
+	psock = reserve_psock(kcm, true, &ret);
+	if (!psock) {
+		if (ret == -EAGAIN)
+			ret = 0;
+		goto out;
+	}
+
+	do {
+		skb = head;
+		txm = kcm_tx_msg(head);
+		sent = 0;
+
+do_frag_list:
+		if (WARN_ON(!skb_shinfo(skb)->nr_frags)) {
+			ret = -EINVAL;
+			goto out;
+		}
+
+		for (fragidx = 0; fragidx < skb_shinfo(skb)->nr_frags;
+		     fragidx++) {
+			skb_frag_t *frag;
+
+			frag_offset = 0;
+do_frag:
+			frag = &skb_shinfo(skb)->frags[fragidx];
+			if (WARN_ON(!frag->size)) {
+				ret = -EINVAL;
+				goto out;
+			}
+
+			ret = kernel_sendpage(psock->sk->sk_socket,
+					      frag->page.p,
+					      frag->page_offset + frag_offset,
+					      frag->size - frag_offset,
+					      MSG_DONTWAIT);
+			if (ret <= 0) {
+				if (ret == -EAGAIN) {
+					/* Save state to try again when there's
+					 * write space on the socket
+					 */
+					txm->sent = sent;
+					txm->frag_offset = frag_offset;
+					txm->fragidx = fragidx;
+					txm->frag_skb = skb;
+
+					ret = 0;
+					goto out;
+				}
+
+				/* Hard failure in sending message, abort this
+				 * psock since it has lost framing
+				 * synchonization and retry sending the
+				 * message from the beginning.
+				 */
+				kcm_abort_tx_psock(psock, -ret, true, false);
+				unreserve_psock(kcm);
+
+				txm->sent = 0;
+
+				goto try_again;
+			}
+
+			sent += ret;
+			frag_offset += ret;
+			if (frag_offset < frag->size) {
+				/* Not finished with this frag */
+				goto do_frag;
+			}
+		}
+
+		if (skb == head) {
+			if (skb_has_frag_list(skb)) {
+				skb = skb_shinfo(skb)->frag_list;
+				goto do_frag_list;
+			}
+		} else if (skb->next) {
+			skb = skb->next;
+			goto do_frag_list;
+		}
+
+		/* Successfully sent the whole packet, account for it. */
+		skb_dequeue(&sk->sk_write_queue);
+		kfree_skb(head);
+		sk->sk_wmem_queued -= sent;
+		total_sent += sent;
+	} while ((head = skb_peek(&sk->sk_write_queue)));
+out:
+	if (!head) {
+		/* Done with all queue messages. */
+		WARN_ON(!skb_queue_empty(&sk->sk_write_queue));
+		WARN_ON(sk->sk_wmem_queued);
+		unreserve_psock(kcm);
+	}
+
+	/* Check if write space is available */
+	sk->sk_write_space(sk);
+
+	return total_sent ? : ret;
+}
+
+static void kcm_tx_work(struct work_struct *w)
+{
+	struct kcm_sock *kcm = container_of(w, struct kcm_sock, tx_work);
+	struct sock *sk = &kcm->sk;
+	int ret;
+
+	lock_sock(sk);
+
+	/* For SOCK_DGRAM socket */
+	if (!skb_queue_empty(&sk->sk_write_queue)) {
+		ret = kcm_write_msgs(kcm);
+		if (ret < 0 && ret != -EAGAIN) {
+			/* Hard failure in write, report error on KCM socket */
+			struct sk_buff *skb = skb_peek(&sk->sk_write_queue);
+
+			sk_stream_error(sk, kcm_tx_msg(skb)->msg_flags, ret);
+		}
+	}
+
+	release_sock(sk);
+}
+
+static unsigned int kcm_poll(struct file *file, struct socket *sock,
+			     poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	struct kcm_sock *kcm = kcm_sk(sk);
+	unsigned int mask = 0;
+
+	sock_poll_wait(file, sk_sleep(sk), wait);
+
+	/* Note that we don't need to lock the socket, as the upper poll layers
+	 * take care of normal races (between the test and the event) and we
+	 * don't go look at any of the socket buffers directly.
+	 */
+	if (sk->sk_err)
+		mask = POLLERR;
+
+	if (!skb_queue_empty(&sk->sk_receive_queue)) {
+		mask |= POLLIN | POLLRDNORM;
+	} else {
+		/* Assume the caller is interested in receiving. */
+		lock_sock(sk);
+		spin_lock_bh(&kcm->mux->lock);
+		if (queue_ready_msg_to_kcm(kcm->mux, kcm)) {
+			/* Found a message waiting on a psock */
+			mask |= POLLIN | POLLRDNORM;
+		} else if (!kcm->rx_wait) {
+			list_add_tail(&kcm->wait_rx_list,
+				      &kcm->mux->kcm_rx_waiters);
+			kcm->rx_wait = 1;
+		}
+		spin_unlock_bh(&kcm->mux->lock);
+		release_sock(sk);
+	}
+
+	if (sk_stream_memory_free(sk)) {
+		mask |= POLLOUT | POLLWRNORM;
+	} else {
+		set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+		set_bit(SOCK_NOSPACE, &sock->flags);
+
+		/* Race breaker. If space is freed after wmem test
+		 * but before the flags are set, IO signal will be lost.
+		 */
+		smp_mb__after_atomic();
+		if (sk_stream_is_writeable(sk))
+			mask |= POLLOUT | POLLWRNORM;
+	}
+
+	return mask;
+}
+
+static int kcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct kcm_sock *kcm = kcm_sk(sk);
+	struct sk_buff *skb, **nextp;
+	int err;
+	bool not_busy;
+	long timeo;
+	size_t tlen, total_len = len;
+
+	lock_sock(sk);
+
+	/* Per tcp_sendmsg this should be in poll */
+	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+
+	if (sk->sk_err)
+		goto out_error;
+
+	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
+
+	/* Call the sk_stream functions to manage the sndbuf mem. */
+	if (!sk_stream_memory_free(sk)) {
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		err = sk_stream_wait_memory(sk, &timeo);
+		if (err)
+			goto out_error;
+	}
+
+	/* Put all data into frags since we will be calling kernel_sendpage
+	 * for everything.
+	 */
+	tlen = min_t(size_t, len, MAX_SKB_FRAGS * PAGE_SIZE);
+
+	skb = alloc_skb_with_frags(0, tlen, PAGE_ALLOC_COSTLY_ORDER, &err,
+				   GFP_KERNEL);
+
+	if (!skb)
+		goto out_error;
+
+	skb->data_len = tlen;
+	skb->len = tlen;
+
+	kcm_tx_msg(skb)->msg_flags = msg->msg_flags;
+
+	len -= tlen;
+
+	nextp = &skb_shinfo(skb)->frag_list;
+	while (len) {
+		struct sk_buff *tskb;
+		size_t tlen;
+
+		/* Need a frag_list */
+
+		tlen = min_t(size_t, len, MAX_SKB_FRAGS * PAGE_SIZE);
+
+		tskb = alloc_skb_with_frags(0, tlen, PAGE_ALLOC_COSTLY_ORDER,
+					    &err, GFP_KERNEL);
+		if (!tskb) {
+			kfree_skb(skb);
+			goto out_error;
+		}
+
+		tskb->data_len = tlen;
+		tskb->len = tlen;
+		skb->data_len += tlen;
+		skb->len += tlen;
+		*nextp = tskb;
+		nextp = &tskb->next;
+
+		len -= tlen;
+	}
+
+	err = skb_copy_datagram_from_iter(skb, 0, &msg->msg_iter, total_len);
+	if (err) {
+		kfree_skb(skb);
+		goto out_error;
+	}
+
+	not_busy = !skb_peek(&sk->sk_write_queue);
+
+	__skb_queue_tail(&sk->sk_write_queue, skb);
+	sk->sk_wmem_queued += total_len;
+
+	if (not_busy) {
+		err = kcm_write_msgs(kcm);
+		if (err < 0 && err != -EAGAIN) {
+			/* We got a hard error in write_msgs but have already
+			 * queued this message. Report an error in the socket,
+			 * but return success here.
+			 */
+			sk_stream_error(sk, msg->msg_flags, err);
+		}
+	}
+
+	/* Everything seems okay */
+
+	release_sock(sk);
+	return total_len;
+
+out_error:
+	err = sk_stream_error(sk, msg->msg_flags, err);
+	/* make sure we wake any epoll edge trigger waiter */
+	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 && err == -EAGAIN))
+		sk->sk_write_space(sk);
+
+	release_sock(sk);
+	return err;
+}
+
+static int kcm_recvmsg(struct socket *sock,
+		       struct msghdr *msg, size_t len, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct kcm_sock *kcm = kcm_sk(sk);
+	int err = 0;
+	long timeo;
+	struct kcm_rx_msg *rxm;
+	int copied = 0;
+	struct sk_buff *skb;
+
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+
+	lock_sock(sk);
+
+	while (!(skb = skb_peek(&sk->sk_receive_queue))) {
+		spin_lock_bh(&kcm->mux->lock);
+		if (queue_ready_msg_to_kcm(kcm->mux, kcm)) {
+			spin_unlock_bh(&kcm->mux->lock);
+
+			/* Found a message waiting on a psock */
+			skb = skb_peek(&sk->sk_receive_queue);
+
+			if (WARN_ON(!skb)) {
+				err = -EINVAL;
+				goto out;
+			}
+			break;
+		}
+
+		if (!kcm->rx_wait) {
+			list_add_tail(&kcm->wait_rx_list,
+				      &kcm->mux->kcm_rx_waiters);
+			kcm->rx_wait = 1;
+		}
+		spin_unlock_bh(&kcm->mux->lock);
+
+		if (sk->sk_err) {
+			err = sock_error(sk);
+			goto out;
+		}
+
+		if (sock_flag(sk, SOCK_DONE))
+			goto out;
+
+		if ((flags & MSG_DONTWAIT) || !timeo) {
+			err = -EAGAIN;
+			goto out;
+		}
+
+		sk_wait_data(sk, &timeo, NULL);
+
+		/* Handle signals */
+		if (signal_pending(current)) {
+			err = sock_intr_errno(timeo);
+			goto out;
+		}
+	}
+
+	/* Okay, have a message on the receive queue */
+
+	rxm = kcm_rx_msg(skb);
+
+	if (len > rxm->full_len)
+		len = rxm->full_len;
+
+	err = skb_copy_datagram_msg(skb, 0, msg, len);
+	if (err < 0)
+		goto out;
+
+	copied = len;
+	if (likely(!(flags & MSG_PEEK))) {
+		/* Finished with message */
+		skb_unlink(skb, &sk->sk_receive_queue);
+		kfree_skb(skb);
+	}
+
+out:
+	release_sock(sk);
+
+	if (copied > 0)
+		return copied;
+	else
+		return err;
+}
+
+static inline void init_kcm_sock(struct kcm_sock *kcm, struct kcm_mux *mux)
+{
+	/* Add to mux's kcm sockets list */
+	kcm->mux = mux;
+	spin_lock_bh(&mux->lock);
+	list_add_tail(&kcm->kcm_sock_list, &mux->kcm_socks);
+	mux->kcm_socks_cnt++;
+	spin_unlock_bh(&mux->lock);
+
+	INIT_WORK(&kcm->tx_work, kcm_tx_work);
+	kcm->tx_wait = 0;
+}
+
+static int kcm_attach(struct socket *sock, struct socket *csock,
+		      struct bpf_prog *prog, int bpf_type)
+{
+	struct kcm_sock *kcm = kcm_sk(sock->sk);
+	struct kcm_mux *mux = kcm->mux;
+	struct sock *csk;
+	struct kcm_psock *psock = NULL;
+
+	if (csock->ops->family != PF_INET)
+		return -EINVAL;
+
+	csk = csock->sk;
+	if (!csk)
+		return -EINVAL;
+
+	/* Only support TCP for now */
+	if (csk->sk_protocol != IPPROTO_TCP)
+		return -EINVAL;
+
+	psock = kmem_cache_zalloc(kcm_psockp, GFP_KERNEL);
+	if (!psock)
+		return -ENOMEM;
+
+	psock->mux = mux;
+	psock->sk = csk;
+	psock->bpf_prog = prog;
+	psock->bpf_prog_fd = !!(bpf_type == KCM_BPF_TYPE_FD);
+	INIT_WORK(&psock->rx_work, psock_rx_work);
+	INIT_DELAYED_WORK(&psock->rx_delayed_work, psock_rx_delayed_work);
+
+	sock_hold(csk);
+
+	write_lock_bh(&csk->sk_callback_lock);
+	psock->save_state_change = csk->sk_state_change;
+	psock->save_data_ready = csk->sk_data_ready;
+	psock->save_write_space = csk->sk_write_space;
+
+	csk->sk_user_data = psock;
+	csk->sk_state_change = psock_tcp_state_change;
+	csk->sk_data_ready = psock_tcp_data_ready;
+	csk->sk_write_space = psock_tcp_write_space;
+	write_unlock_bh(&csk->sk_callback_lock);
+
+	/* Finished initialization, now add the psock to the MUX. */
+	spin_lock_bh(&mux->lock);
+	list_add_tail(&psock->psock_list, &mux->psocks);
+	mux->psocks_cnt++;
+	psock_now_avail(psock);
+	spin_unlock_bh(&mux->lock);
+
+	/* Schedule RX work in case there are already bytes queued */
+	queue_work(kcm_wq, &psock->rx_work);
+
+	return 0;
+}
+
+static int kcm_attach_ioctl(struct socket *sock, struct kcm_attach *info)
+{
+	struct socket *csock;
+	struct bpf_prog *prog;
+	int err;
+
+	csock = sockfd_lookup(info->fd, &err);
+	if (!csock)
+		return -ENOENT;
+
+	switch (info->bpf_type) {
+	case KCM_BPF_TYPE_FD:
+		prog = bpf_prog_get(info->bpf_fd);
+		if (IS_ERR(prog)) {
+			err = PTR_ERR(prog);
+			goto out;
+		}
+
+		if (prog->type != BPF_PROG_TYPE_SOCKET_FILTER) {
+			bpf_prog_put(prog);
+			err = -EINVAL;
+			goto out;
+		}
+		break;
+	case KCM_BPF_TYPE_PROG:
+		err = bpf_prog_create_from_user(&prog, &info->bpf_fprog, NULL);
+		if (err)
+			goto out;
+		break;
+	default:
+		err = -EINVAL;
+		goto out;
+	}
+
+	err = kcm_attach(sock, csock, prog, info->bpf_type);
+	if (err) {
+		if (info->bpf_type == KCM_BPF_TYPE_PROG)
+			__bpf_prog_free(prog);
+		else
+			bpf_prog_put(prog);
+		goto out;
+	}
+
+	/* Keep reference on file also */
+
+	return 0;
+out:
+	fput(csock->file);
+	return err;
+}
+
+/* Under csk sock lock. */
+static void kcm_unattach(struct kcm_psock *psock)
+{
+	struct sock *csk = psock->sk;
+	struct kcm_mux *mux = psock->mux;
+
+	if (psock->done)
+		return;
+
+	/* Stop getting callbacks from TCP socket. */
+	write_lock_bh(&csk->sk_callback_lock);
+	csk->sk_user_data = NULL;
+	csk->sk_state_change = psock->save_state_change;
+	csk->sk_data_ready = psock->save_data_ready;
+	csk->sk_write_space = psock->save_write_space;
+	write_unlock_bh(&csk->sk_callback_lock);
+
+	cancel_work_sync(&psock->rx_work);
+	cancel_delayed_work_sync(&psock->rx_delayed_work);
+
+	if (psock->bpf_prog_fd)
+		bpf_prog_put(psock->bpf_prog);
+	else
+		__bpf_prog_free(psock->bpf_prog);
+
+	kfree_skb(psock->rx_skb_head);
+	psock->rx_skb_head = NULL;
+
+	spin_lock_bh(&mux->lock);
+
+	if (psock->ready_rx_msg) {
+		list_del(&psock->psock_ready_list);
+		kfree_skb(psock->ready_rx_msg);
+		psock->ready_rx_msg = NULL;
+	}
+
+	if (psock->tx_kcm) {
+		/* psock was reserved.  Just mark it finished and we will clean
+		 * up in the kcm paths, we need kcm lock which can not be
+		 * acquired here.
+		 */
+		psock->done = 1;
+		spin_unlock_bh(&mux->lock);
+		kcm_abort_tx_psock(psock, EPIPE, true, true);
+	} else {
+		if (!psock->tx_stopped)
+			list_del(&psock->psock_avail_list);
+		list_del(&psock->psock_list);
+		mux->psocks_cnt--;
+		spin_unlock_bh(&mux->lock);
+
+		sock_put(csk);
+		fput(csk->sk_socket->file);
+		kmem_cache_free(kcm_psockp, psock);
+	}
+}
+
+static int kcm_unattach_ioctl(struct socket *sock, struct kcm_unattach *info)
+{
+	struct kcm_sock *kcm = kcm_sk(sock->sk);
+	struct kcm_mux *mux = kcm->mux;
+	struct kcm_psock *psock;
+	struct socket *csock;
+	struct sock *csk;
+	int err;
+
+	csock = sockfd_lookup(info->fd, &err);
+	if (!csock)
+		return -ENOENT;
+
+	csk = csock->sk;
+	if (!csk) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	err = -ENOENT;
+
+	spin_lock_bh(&mux->lock);
+
+	list_for_each_entry(psock, &mux->psocks, psock_list) {
+		if (psock->sk != csk)
+			continue;
+
+		/* Found the matching psock */
+
+		if (psock->unattaching || WARN_ON(psock->done)) {
+			err = -EALREADY;
+			break;
+		}
+
+		psock->unattaching = 1;
+
+		spin_unlock_bh(&mux->lock);
+
+		kcm_unattach(psock);
+
+		err = 0;
+		goto out;
+	}
+
+	spin_unlock_bh(&mux->lock);
+
+out:
+	fput(csock->file);
+	return err;
+}
+
+static int kcm_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	int err;
+
+	switch (cmd) {
+	case SIOCKCMATTACH: {
+		struct kcm_attach info;
+
+		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
+			err = -EFAULT;
+
+		err = kcm_attach_ioctl(sock, &info);
+
+		break;
+	}
+	case SIOCKCMUNATTACH: {
+		struct kcm_unattach info;
+
+		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
+			err = -EFAULT;
+
+		err = kcm_unattach_ioctl(sock, &info);
+
+		break;
+	}
+	default:
+		err = -ENOIOCTLCMD;
+		break;
+	}
+
+	return err;
+}
+
+static void free_mux(struct rcu_head *rcu)
+{
+	struct kcm_mux *mux = container_of(rcu,
+	    struct kcm_mux, rcu);
+
+	kmem_cache_free(kcm_muxp, mux);
+}
+
+static void release_mux(struct kcm_mux *mux)
+{
+	struct kcm_net *knet = mux->knet;
+	struct kcm_psock *psock, *tmp_psock;
+
+	/* Release psocks */
+	list_for_each_entry_safe(psock, tmp_psock,
+				 &mux->psocks, psock_list)
+		kcm_unattach(psock);
+
+	if (WARN_ON(mux->psocks_cnt))
+		return;
+
+	mutex_lock(&knet->mutex);
+	list_del_rcu(&mux->kcm_mux_list);
+	knet->count--;
+	mutex_unlock(&knet->mutex);
+
+	call_rcu(&mux->rcu, free_mux);
+}
+
+/* Called by kcm_release to close a KCM socket.
+ * If this is the last KCM socket on the MUX, destroy the MUX.
+ */
+static int kcm_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct kcm_sock *kcm = kcm_sk(sk);
+	struct kcm_mux *mux = kcm->mux;
+	struct kcm_psock *psock;
+	int socks_cnt;
+
+	sock_orphan(sk);
+
+	lock_sock(sk);
+	/* Purge queue under lock to avoid race condition with tx_work trying
+	 * to act when queue is nonempty. If tx_work runs after this point
+	 * it will just return.
+	 */
+	__skb_queue_purge(&sk->sk_write_queue);
+	release_sock(sk);
+
+	spin_lock_bh(&mux->lock);
+	if (kcm->tx_wait) {
+		/* Take of tx_wait list, after this point there should be no way
+		 * that a psock will be assigned to this kcm.
+		 */
+		list_del(&kcm->wait_psock_list);
+		kcm->tx_wait = 0;
+	}
+	spin_unlock_bh(&mux->lock);
+
+	psock = kcm->tx_psock;
+	if (psock) {
+		/* A psock was reserved, so we need to kill it since it
+		 * may already have some bytes queued from a message. We
+		 * need to do this after removing kcm from tx_wait list.
+		 */
+		kcm_abort_tx_psock(psock, EINTR, false, true);
+		unreserve_psock(kcm);
+	}
+
+	/* Cancel work. After this point there should be no outside references
+	 * to the kcm socket.
+	 */
+	cancel_work_sync(&kcm->tx_work);
+
+	/* Detach from MUX */
+	spin_lock_bh(&mux->lock);
+
+	list_del(&kcm->kcm_sock_list);
+	mux->kcm_socks_cnt--;
+	if (kcm->rx_wait) {
+		list_del(&kcm->wait_rx_list);
+		kcm->rx_wait = 0;
+	}
+	if (mux->last_rx_kcm == kcm)
+		mux->last_rx_kcm = NULL;
+	socks_cnt = mux->kcm_socks_cnt;
+
+	spin_unlock_bh(&mux->lock);
+
+	if (!socks_cnt) {
+		/* We are done with the mux now. */
+		release_mux(mux);
+	}
+
+	/* Free anything in recv queue */
+	__skb_queue_purge(&sk->sk_receive_queue);
+
+	sock->sk = NULL;
+	sock_put(&kcm->sk);
+
+	return 0;
+}
+
+static struct proto kcm_proto = {
+	.name	= "KCM",
+	.owner	= THIS_MODULE,
+	.obj_size = sizeof(struct kcm_sock),
+};
+
+/* Clone a kcm socket. Overloads accept proto operation */
+static int kcm_accept(struct socket *osock, struct socket *newsock, int flags)
+{
+	struct sock *newsk;
+
+	newsk = sk_alloc(sock_net(osock->sk), PF_KCM, GFP_KERNEL,
+			 &kcm_proto, true);
+	if (!newsk)
+		return -ENOMEM;
+
+	newsock->ops = osock->ops;
+
+	sock_init_data(newsock, newsk);
+	init_kcm_sock(kcm_sk(newsk), kcm_sk(osock->sk)->mux);
+
+	return 0;
+}
+
+static const struct proto_ops kcm_dgram_ops = {
+	.family =	PF_KCM,
+	.owner =	THIS_MODULE,
+	.release =	kcm_release,
+	.bind =		sock_no_bind,
+	.connect =	sock_no_connect,
+	.socketpair =	sock_no_socketpair,
+	.accept =	kcm_accept,
+	.getname =	sock_no_getname,
+	.poll =		kcm_poll,
+	.ioctl =	kcm_ioctl,
+	.listen =	sock_no_listen,
+	.shutdown =	sock_no_shutdown,
+	.setsockopt =	sock_no_setsockopt,
+	.getsockopt =	sock_no_getsockopt,
+	.sendmsg =	kcm_sendmsg,
+	.recvmsg =	kcm_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
+};
+
+/* Create proto operation for kcm sockets */
+static int kcm_create(struct net *net, struct socket *sock,
+		      int protocol, int kern)
+{
+	struct kcm_net *knet = net_generic(net, kcm_net_id);
+	struct sock *sk;
+	struct kcm_mux *mux;
+
+	switch (sock->type) {
+	case SOCK_DGRAM:
+		sock->ops = &kcm_dgram_ops;
+		break;
+	default:
+		return -ESOCKTNOSUPPORT;
+	}
+
+	if (protocol != KCMPROTO_CONNECTED)
+		return -EPROTONOSUPPORT;
+
+	sk = sk_alloc(net, PF_KCM, GFP_KERNEL, &kcm_proto, kern);
+	if (!sk)
+		return -ENOMEM;
+
+	/* Allocate a kcm mux, shared between KCM sockets */
+	mux = kmem_cache_zalloc(kcm_muxp, GFP_KERNEL);
+	if (!mux) {
+		sk_free(sk);
+		return -ENOMEM;
+	}
+
+	spin_lock_init(&mux->lock);
+	INIT_LIST_HEAD(&mux->kcm_socks);
+	INIT_LIST_HEAD(&mux->kcm_rx_waiters);
+	INIT_LIST_HEAD(&mux->kcm_tx_waiters);
+
+	INIT_LIST_HEAD(&mux->psocks);
+	INIT_LIST_HEAD(&mux->psocks_ready);
+	INIT_LIST_HEAD(&mux->psocks_avail);
+
+	mux->knet = knet;
+
+	/* Add new MUX to list */
+	mutex_lock(&knet->mutex);
+	list_add_rcu(&mux->kcm_mux_list, &knet->mux_list);
+	knet->count++;
+	mutex_unlock(&knet->mutex);
+
+	/* Init KCM socket */
+	sock_init_data(sock, sk);
+	init_kcm_sock(kcm_sk(sk), mux);
+
+	return 0;
+}
+
+static struct net_proto_family kcm_family_ops = {
+	.family = PF_KCM,
+	.create = kcm_create,
+	.owner  = THIS_MODULE,
+};
+
+static __net_init int kcm_init_net(struct net *net)
+{
+	struct kcm_net *knet = net_generic(net, kcm_net_id);
+
+	INIT_LIST_HEAD_RCU(&knet->mux_list);
+	mutex_init(&knet->mutex);
+
+	return 0;
+}
+
+static __net_exit void kcm_exit_net(struct net *net)
+{
+	struct kcm_net *knet = net_generic(net, kcm_net_id);
+
+	/* All KCM sockets should be closed at this point, which should mean
+	 * that all multiplexors and psocks have been destroyed.
+	 */
+	WARN_ON(!list_empty(&knet->mux_list));
+}
+
+static struct pernet_operations kcm_net_ops = {
+	.init = kcm_init_net,
+	.exit = kcm_exit_net,
+	.id   = &kcm_net_id,
+	.size = sizeof(struct kcm_net),
+};
+
+static int __init kcm_init(void)
+{
+	int err = -ENOMEM;
+
+	kcm_muxp = kmem_cache_create("kcm_mux_cache",
+				     sizeof(struct kcm_mux), 0,
+				     SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	if (!kcm_muxp)
+		goto fail;
+
+	kcm_psockp = kmem_cache_create("kcm_psock_cache",
+				       sizeof(struct kcm_psock), 0,
+					SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	if (!kcm_psockp)
+		goto fail;
+
+	kcm_wq = create_singlethread_workqueue("kkcmd");
+	if (!kcm_wq)
+		goto fail;
+
+	err = proto_register(&kcm_proto, 1);
+	if (err)
+		goto fail;
+
+	err = sock_register(&kcm_family_ops);
+	if (err)
+		goto sock_register_fail;
+
+	err = register_pernet_device(&kcm_net_ops);
+	if (err)
+		goto net_ops_fail;
+
+	return 0;
+
+net_ops_fail:
+	sock_unregister(PF_KCM);
+
+sock_register_fail:
+	proto_unregister(&kcm_proto);
+
+fail:
+	kmem_cache_destroy(kcm_muxp);
+	kmem_cache_destroy(kcm_psockp);
+
+	if (kcm_wq)
+		destroy_workqueue(kcm_wq);
+
+	return err;
+}
+
+static void __exit kcm_exit(void)
+{
+	unregister_pernet_device(&kcm_net_ops);
+	sock_unregister(PF_KCM);
+	proto_unregister(&kcm_proto);
+	destroy_workqueue(kcm_wq);
+
+	kmem_cache_destroy(kcm_muxp);
+	kmem_cache_destroy(kcm_psockp);
+}
+
+module_init(kcm_init);
+module_exit(kcm_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_KCM);
+
-- 
1.8.1
