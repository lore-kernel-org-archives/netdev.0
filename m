From: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Subject: [RFC PATCH 1/5] net: implement support for low latency socket polling
Date: Wed, 27 Feb 2013 09:55:55 -0800
Message-ID: <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds a new ndo_ll_poll method and the code that supports and uses it.
This method can be used by low latency applications to busy poll ethernet
device queues directly from the socket code. The ip_low_latency_poll sysctl
entry controls how many cycles to poll. Set to zero to disable.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/linux/netdevice.h  |    3 ++
 include/linux/skbuff.h     |    4 ++
 include/net/ll_poll.h      |   71 ++++++++++++++++++++++++++++++++++++++++++++
 include/net/sock.h         |    3 ++
 net/core/datagram.c        |    6 ++++
 net/core/skbuff.c          |    4 ++
 net/core/sock.c            |    6 ++++
 net/ipv4/Kconfig           |   12 +++++++
 net/ipv4/sysctl_net_ipv4.c |   10 ++++++
 net/socket.c               |   25 +++++++++++++++
 10 files changed, 143 insertions(+), 1 deletions(-)
 create mode 100644 include/net/ll_poll.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b3d00fa..c6f2a9a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -945,6 +945,9 @@ struct net_device_ops {
 						     gfp_t gfp);
 	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
+#ifdef CONFIG_INET_LL_RX_POLL
+	int			(*ndo_ll_poll)(struct napi_struct *dev);
+#endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
 						  int queue, u8 *mac);
 	int			(*ndo_set_vf_vlan)(struct net_device *dev,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 821c7f4..d1d1016 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -408,6 +408,10 @@ struct sk_buff {
 	struct sock		*sk;
 	struct net_device	*dev;
 
+#ifdef CONFIG_INET_LL_RX_POLL
+	struct napi_struct	*dev_ref; /* where this skb came from */
+#endif
+
 	/*
 	 * This is the control buffer. It is free to use for every
 	 * layer. Please put your private variables there. If you
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
new file mode 100644
index 0000000..3c7bcec
--- /dev/null
+++ b/include/net/ll_poll.h
@@ -0,0 +1,71 @@
+/*
+ * low latency device queue flush
+ */
+
+#ifndef _LINUX_NET_LL_POLL_H
+#define _LINUX_NET_LL_POLL_H
+#ifdef CONFIG_INET_LL_RX_POLL
+#include <linux/netdevice.h>
+struct napi_struct;
+extern int sysctl_net_ll_poll __read_mostly;
+
+/* return values from ndo_ll_poll */
+#define LL_FLUSH_DONE		0
+#define LL_FLUSH_FAILED		1
+#define LL_FLUSH_BUSY		2
+
+static inline int sk_valid_ll(struct sock *sk)
+{
+	return sysctl_net_ll_poll && sk->dev_ref &&
+		!need_resched() && !signal_pending(current);
+}
+
+/*
+ * TODO: how do we know that we have a working get_cycles?
+ * do we limit this by a configure dependacy?
+ * TODO: this is not safe when the device can be removed,
+ * but simple refcounting may prevent removal indefinatly
+ */
+static inline int sk_poll_ll(struct sock *sk)
+{
+	struct napi_struct *napi = sk->dev_ref;
+	const struct net_device_ops *ops;
+	unsigned long end_time = sysctl_net_ll_poll + get_cycles();
+
+	if (!napi->dev || !napi->dev->netdev_ops ||
+	    !napi->dev->netdev_ops->ndo_ll_poll)
+		return false;
+
+	local_bh_disable();
+
+	ops = napi->dev->netdev_ops;
+	while (skb_queue_empty(&sk->sk_receive_queue) &&
+			!time_after((unsigned long)get_cycles(), end_time))
+		if (ops->ndo_ll_poll(napi) == LL_FLUSH_FAILED)
+				break; /* premanent failure */
+
+	local_bh_enable();
+
+	return !skb_queue_empty(&sk->sk_receive_queue);
+}
+
+static inline void skb_mark_ll(struct napi_struct *napi, struct sk_buff *skb)
+{
+	skb->dev_ref = napi;
+}
+
+static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+{
+	if (skb->dev_ref)
+		sk->dev_ref = skb->dev_ref;
+
+}
+#else /* CONFIG_INET_LL_RX_FLUSH */
+
+#define sk_valid_ll(sk) 0
+#define sk_poll_ll(sk) do {} while (0)
+#define skb_mark_ll(napi, skb) do {} while (0)
+#define sk_mark_ll(sk, skb) do {} while (0)
+
+#endif /* CONFIG_INET_LL_RX_FLUSH */
+#endif /* _LINUX_NET_LL_POLL_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index a66caa2..13dd743 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -399,6 +399,9 @@ struct sock {
 	int			(*sk_backlog_rcv)(struct sock *sk,
 						  struct sk_buff *skb);
 	void                    (*sk_destruct)(struct sock *sk);
+#ifdef CONFIG_INET_LL_RX_POLL
+	struct napi_struct	*dev_ref;
+#endif
 };
 
 /*
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 368f9c3..14ad733 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -56,6 +56,7 @@
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <trace/events/skb.h>
+#include <net/ll_poll.h>
 
 /*
  *	Is a socket 'connection oriented' ?
@@ -196,11 +197,16 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 			} else
 				__skb_unlink(skb, queue);
 
+			sk_mark_ll(sk, skb);
 			spin_unlock_irqrestore(&queue->lock, cpu_flags);
 			return skb;
 		}
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
 
+#ifdef CONFIG_INET_LL_RX_POLL
+		if (sk_valid_ll(sk) && sk_poll_ll(sk))
+			continue;
+#endif
 		/* User doesn't want to wait */
 		error = -EAGAIN;
 		if (!timeo)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 33245ef..3fa650e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -709,6 +709,10 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->vlan_tci		= old->vlan_tci;
 
 	skb_copy_secmark(new, old);
+
+#ifdef CONFIG_INET_LL_RX_POLL
+	new->dev_ref		= old->dev_ref;
+#endif
 }
 
 /*
diff --git a/net/core/sock.c b/net/core/sock.c
index b261a79..e752670 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -139,6 +139,8 @@
 #include <net/tcp.h>
 #endif
 
+#include <net/ll_poll.h>
+
 static DEFINE_MUTEX(proto_list_mutex);
 static LIST_HEAD(proto_list);
 
@@ -2290,6 +2292,10 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	sk->sk_stamp = ktime_set(-1L, 0);
 
+#ifdef CONFIG_INET_LL_RX_POLL
+	sk->dev_ref	=	NULL;
+#endif
+
 	/*
 	 * Before updating sk_refcnt, we must commit prior changes to memory
 	 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 7944df7..e52f011 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -402,6 +402,18 @@ config INET_LRO
 
 	  If unsure, say Y.
 
+config INET_LL_RX_POLL
+	bool "Low Latency Receive Poll"
+	default n
+	---help---
+	  Support Low Latency Receive Queue Poll.
+	  (For network card drivers which support this option.)
+	  When waiting for data in read or poll call directly into the the device driver
+	  to flush packets which may be pending on the device queues into the stack.
+
+
+	  If unsure, say N.
+
 config INET_DIAG
 	tristate "INET: socket monitoring interface"
 	default y
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 960fd29..0c060c6 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -25,6 +25,7 @@
 #include <net/inet_frag.h>
 #include <net/ping.h>
 #include <net/tcp_memcontrol.h>
+#include <net/ll_poll.h>
 
 static int zero;
 static int one = 1;
@@ -326,6 +327,15 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+#ifdef CONFIG_INET_LL_RX_POLL
+	{
+		.procname	= "ip_low_latency_poll",
+		.data		= &sysctl_net_ll_poll,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+#endif
 	{
 		.procname	= "tcp_syn_retries",
 		.data		= &sysctl_tcp_syn_retries,
diff --git a/net/socket.c b/net/socket.c
index ee0d029..86da082 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -105,6 +105,12 @@
 #include <linux/sockios.h>
 #include <linux/atalk.h>
 
+#ifdef CONFIG_INET_LL_RX_POLL
+#include <net/ll_poll.h>
+int sysctl_net_ll_poll __read_mostly = 150000;
+EXPORT_SYMBOL_GPL(sysctl_net_ll_poll);
+#endif
+
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
@@ -1157,12 +1163,29 @@ EXPORT_SYMBOL(sock_create_lite);
 static unsigned int sock_poll(struct file *file, poll_table *wait)
 {
 	struct socket *sock;
+	unsigned int poll_result;
 
 	/*
 	 *      We can't return errors to poll, so it's either yes or no.
 	 */
 	sock = file->private_data;
-	return sock->ops->poll(file, sock, wait);
+
+	poll_result = sock->ops->poll(file, sock, wait);
+
+#ifdef CONFIG_INET_LL_RX_POLL
+	if (wait &&
+	    !(poll_result & (POLLRDNORM | POLLERR | POLLRDHUP | POLLHUP))) {
+
+		struct sock *sk = sock->sk;
+
+		/* only try once per poll */
+		if (sk_valid_ll(sk) && sk_poll_ll(sk))
+			poll_result = sock->ops->poll(file, sock, wait);
+
+	}
+#endif /* CONFIG_INET_LL_RX_POLL */
+
+	return poll_result;
 }
 
 static int sock_mmap(struct file *file, struct vm_area_struct *vma)
