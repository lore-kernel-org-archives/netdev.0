From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v2 net-next 1/4] net: implement support for
 low latency socket polling
Date: Sun, 19 May 2013 13:25:33 +0300
Message-ID: <20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
References: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	Don Skidmore <donanld.c.skidmore@intel.com>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Dave Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adds a new ndo_ll_poll method and the code that supports and uses it.
This method can be used by low latency applications to busy poll ethernet
device queues directly from the socket code. The ip_low_latency_poll sysctl
entry controls how many cycles to poll. Set to zero to disable.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 Documentation/networking/ip-sysctl.txt |    5 ++
 include/linux/netdevice.h              |    3 +
 include/linux/skbuff.h                 |    8 +++-
 include/net/ll_poll.h                  |   73 ++++++++++++++++++++++++++++++++
 include/net/sock.h                     |    3 +
 net/core/datagram.c                    |    7 +++
 net/core/skbuff.c                      |    4 ++
 net/core/sock.c                        |    6 +++
 net/ipv4/Kconfig                       |   12 +++++
 net/ipv4/sysctl_net_ipv4.c             |   10 ++++
 net/socket.c                           |   25 +++++++++++
 11 files changed, 153 insertions(+), 3 deletions(-)
 create mode 100644 include/net/ll_poll.h

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f98ca63..cfcf0ea 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -19,6 +19,11 @@ ip_no_pmtu_disc - BOOLEAN
 	Disable Path MTU Discovery.
 	default FALSE
 
+ip_low_latency_poll - INTEGER
+	Low latency busy poll timeout. (needs CONFIG_INET_LL_RX_POLL)
+	Approximate time in ms to spin waiting for packets on the device queue.
+	default 0
+
 min_pmtu - INTEGER
 	default 552 - minimum discovered Path MTU
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a94a5a0..e25f798 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -943,6 +943,9 @@ struct net_device_ops {
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
index 2e0ced1..4047e1e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -384,6 +384,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
+ *      @dev_ref: the NAPI struct this skb came from
  *	@secmark: security marking
  *	@mark: Generic packet mark
  *	@dropcount: total number of sk_receive_queue overflows
@@ -497,8 +498,11 @@ struct sk_buff {
 	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
-#ifdef CONFIG_NET_DMA
-	dma_cookie_t		dma_cookie;
+#if defined CONFIG_NET_DMA || defined CONFIG_INET_LL_RX_POLL
+	union {
+		struct napi_struct	*dev_ref;
+		dma_cookie_t		dma_cookie;
+	};
 #endif
 #ifdef CONFIG_NETWORK_SECMARK
 	__u32			secmark;
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
new file mode 100644
index 0000000..6b5c03f
--- /dev/null
+++ b/include/net/ll_poll.h
@@ -0,0 +1,73 @@
+/*
+ * low latency network device queue flush
+ * Copyright(c) 2013 Intel Corporation.
+ * Author: Eliezer Tamir
+ *
+ * For now this depends on CONFIG_I86_TSC
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
+/* we don't mind a ~2.5% imprecision */
+#define TSC_MHZ (tsc_khz >> 10)
+
+static inline bool sk_valid_ll(struct sock *sk)
+{
+	return sysctl_net_ll_poll && sk->dev_ref &&
+		!need_resched() && !signal_pending(current);
+}
+
+static inline bool sk_poll_ll(struct sock *sk, int nonblock)
+{
+	struct napi_struct *napi = sk->dev_ref;
+	const struct net_device_ops *ops;
+	unsigned long end_time = TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll)
+					+ get_cycles();
+
+	if (!napi->dev->netdev_ops->ndo_ll_poll)
+		return false;
+
+	local_bh_disable();
+
+	ops = napi->dev->netdev_ops;
+	while (skb_queue_empty(&sk->sk_receive_queue) &&
+			!time_after((unsigned long)get_cycles(), end_time)) {
+		if (ops->ndo_ll_poll(napi) == LL_FLUSH_FAILED)
+				break; /* premanent failure */
+		if (nonblock)
+			break;
+	}
+
+	local_bh_enable();
+
+	return !skb_queue_empty(&sk->sk_receive_queue);
+}
+
+static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+{
+	skb->dev_ref = napi;
+}
+
+static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+{
+		sk->dev_ref = skb->dev_ref;
+}
+#else /* CONFIG_INET_LL_RX_FLUSH */
+
+#define sk_valid_ll(sk) 0
+#define sk_poll_ll(sk, nonblock) do {} while (0)
+#define skb_mark_ll(napi, skb) do {} while (0)
+#define sk_mark_ll(sk, skb) do {} while (0)
+
+#endif /* CONFIG_INET_LL_RX_FLUSH */
+#endif /* _LINUX_NET_LL_POLL_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 66772cf..eeabdcd4 100644
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
index b71423d..df3dab8 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -56,6 +56,7 @@
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <trace/events/skb.h>
+#include <net/ll_poll.h>
 
 /*
  *	Is a socket 'connection oriented' ?
@@ -201,12 +202,18 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 			} else
 				__skb_unlink(skb, queue);
 
+			sk_mark_ll(sk, skb);
 			spin_unlock_irqrestore(&queue->lock, cpu_flags);
 			*off = _off;
 			return skb;
 		}
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
 
+#ifdef CONFIG_INET_LL_RX_POLL
+		if (sk_valid_ll(sk) && sk_poll_ll(sk, flags & MSG_DONTWAIT))
+			continue;
+#endif
+
 		/* User doesn't want to wait */
 		error = -EAGAIN;
 		if (!timeo)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index af9185d..4efd230 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -739,6 +739,10 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->vlan_tci		= old->vlan_tci;
 
 	skb_copy_secmark(new, old);
+
+#ifdef CONFIG_INET_LL_RX_POLL
+	new->dev_ref		= old->dev_ref;
+#endif
 }
 
 /*
diff --git a/net/core/sock.c b/net/core/sock.c
index 6ba327d..d8058ce 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -139,6 +139,8 @@
 #include <net/tcp.h>
 #endif
 
+#include <net/ll_poll.h>
+
 static DEFINE_MUTEX(proto_list_mutex);
 static LIST_HEAD(proto_list);
 
@@ -2284,6 +2286,10 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	sk->sk_stamp = ktime_set(-1L, 0);
 
+#ifdef CONFIG_INET_LL_RX_POLL
+	sk->dev_ref	=	NULL;
+#endif
+
 	/*
 	 * Before updating sk_refcnt, we must commit prior changes to memory
 	 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 8603ca8..d209f0f 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -409,6 +409,18 @@ config INET_LRO
 
 	  If unsure, say Y.
 
+config INET_LL_RX_POLL
+	bool "Low Latency Receive Poll"
+	depends on X86_TSC
+	default n
+	---help---
+	  Support Low Latency Receive Queue Poll.
+	  (For network card drivers which support this option.)
+	  When waiting for data in read or poll call directly into the the device driver
+	  to flush packets which may be pending on the device queues into the stack.
+
+	  If unsure, say N.
+
 config INET_DIAG
 	tristate "INET: socket monitoring interface"
 	default y
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index fa2f63f..d0fcaaf 100644
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
index 6b94633..4afe504 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -105,6 +105,12 @@
 #include <linux/sockios.h>
 #include <linux/atalk.h>
 
+#ifdef CONFIG_INET_LL_RX_POLL
+#include <net/ll_poll.h>
+int sysctl_net_ll_poll __read_mostly;
+EXPORT_SYMBOL_GPL(sysctl_net_ll_poll);
+#endif
+
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
@@ -1143,12 +1149,29 @@ EXPORT_SYMBOL(sock_create_lite);
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
+		if (sk_valid_ll(sk) && sk_poll_ll(sk, 1))
+			poll_result = sock->ops->poll(file, sock, wait);
+
+	}
+#endif /* CONFIG_INET_LL_RX_POLL */
+
+	return poll_result;
 }
 
 static int sock_mmap(struct file *file, struct vm_area_struct *vma)


------------------------------------------------------------------------------
AlienVault Unified Security Management (USM) platform delivers complete
security visibility with the essential security capabilities. Easily and
efficiently configure, manage, and operate all of your security controls
from a single console and one unified framework. Download a free trial.
http://p.sf.net/sfu/alienvault_d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
