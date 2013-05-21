From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v4 net-next 1/4] net: implement support for low latency socket
 polling
Date: Tue, 21 May 2013 17:26:50 +0300
Message-ID: <20130521142650.18498.71715.stgit@ladj378.jer.intel.com>
References: <20130521142641.18498.52856.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Dave Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130521142641.18498.52856.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
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

 Documentation/networking/ip-sysctl.txt |    6 ++
 include/linux/netdevice.h              |    3 +
 include/linux/skbuff.h                 |   13 +++-
 include/net/ll_poll.h                  |  117 ++++++++++++++++++++++++++++++++
 include/net/sock.h                     |    4 +
 include/uapi/linux/snmp.h              |    1 
 net/core/datagram.c                    |    7 ++
 net/core/skbuff.c                      |    4 +
 net/core/sock.c                        |    6 ++
 net/ipv4/Kconfig                       |   12 +++
 net/ipv4/proc.c                        |    1 
 net/ipv4/sysctl_net_ipv4.c             |   10 +++
 net/socket.c                           |   26 +++++++
 13 files changed, 206 insertions(+), 4 deletions(-)
 create mode 100644 include/net/ll_poll.h

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f98ca63..16a36b3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -19,6 +19,12 @@ ip_no_pmtu_disc - BOOLEAN
 	Disable Path MTU Discovery.
 	default FALSE
 
+ip_low_latency_poll - INTEGER
+	Low latency busy poll timeout. (needs CONFIG_INET_LL_RX_POLL)
+	Approximate time in ms to spin waiting for packets on the device queue.
+	Recommended value is 50. May increase power usage.
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
index 2e0ced1..0a61a6e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -384,6 +384,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
+  *	@dev_ref: the NAPI struct this skb came from
  *	@secmark: security marking
  *	@mark: Generic packet mark
  *	@dropcount: total number of sk_receive_queue overflows
@@ -494,11 +495,17 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
+#ifdef CONFIG_INET_LL_RX_POLL
+	__u8			ll_gen_id:7;
+#endif
+	/* 0-2 bit hole (depending on ndisc_nodetype and ll_gen_id) */
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
index 0000000..a31b2b4
--- /dev/null
+++ b/include/net/ll_poll.h
@@ -0,0 +1,117 @@
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
+
+#ifdef CONFIG_INET_LL_RX_POLL
+#include <linux/netdevice.h>
+#include <net/ip.h>
+
+struct napi_struct;
+extern int sysctl_net_ll_poll __read_mostly;
+extern unsigned int ll_global_gen_id __read_mostly;
+
+/* we only have room for 7 bits of generation id in the skb */
+#define SKB_LL_GEN_MASK	0x7FF
+#define SKB_LL_GEN(id)		(id & SKB_LL_GEN_MASK)
+
+/* return values from ndo_ll_poll */
+#define LL_FLUSH_FAILED		-1
+#define LL_FLUSH_BUSY		-2
+
+/* we don't mind a ~2.5% imprecision */
+#define TSC_MHZ (tsc_khz >> 10)
+
+static inline bool sk_valid_ll(struct sock *sk)
+{
+	return sysctl_net_ll_poll && sk->dev_ref &&
+		sk->ll_gen_id == ll_global_gen_id &&
+		!need_resched() && !signal_pending(current);
+}
+
+static inline bool sk_poll_ll(struct sock *sk, int nonblock)
+{
+	unsigned long end_time = TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll)
+					+ get_cycles();
+	struct napi_struct *napi = sk->dev_ref;
+	const struct net_device_ops *ops;
+	int rc;
+
+	if (!napi->dev->netdev_ops->ndo_ll_poll)
+		return false;
+
+	local_bh_disable();
+
+	ops = napi->dev->netdev_ops;
+	while (skb_queue_empty(&sk->sk_receive_queue) &&
+			!time_after((unsigned long)get_cycles(), end_time)) {
+		rc = ops->ndo_ll_poll(napi);
+
+		if (rc == LL_FLUSH_FAILED)
+			break; /* premanent failure */
+
+		if (rc > 0)
+			/* local bh are disabled so it is ok to use _BH */
+			NET_ADD_STATS_BH(sock_net(sk),
+				LINUX_MIB_LOWLATENCYRXPACKETS, rc);
+		if (nonblock)
+			break;
+	}
+
+	local_bh_enable();
+
+	return !skb_queue_empty(&sk->sk_receive_queue);
+}
+
+/* should be called when destroying a napi struct */
+static inline void inc_ll_gen_id(void)
+{
+	ll_global_gen_id++;
+}
+
+static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+{
+	skb->dev_ref = napi;
+	skb->ll_gen_id = SKB_LL_GEN(ll_global_gen_id);
+}
+
+static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+{
+	if (skb->dev_ref && skb->ll_gen_id == SKB_LL_GEN(ll_global_gen_id)) {
+		sk->dev_ref = skb->dev_ref;
+		sk->ll_gen_id = ll_global_gen_id;
+	} else
+		sk->dev_ref = NULL; /* clear expired ref */
+}
+
+#else /* CONFIG_INET_LL_RX_FLUSH */
+
+static inline bool sk_valid_ll(struct sock *sk)
+{
+	return 0;
+}
+
+static inline bool sk_poll_ll(struct sock *sk, int nonblock)
+{
+	return 0;
+}
+
+static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+{
+}
+
+static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+{
+}
+
+static inline void inc_ll_gen_id(void)
+{
+}
+#endif /* CONFIG_INET_LL_RX_FLUSH */
+#endif /* _LINUX_NET_LL_POLL_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 66772cf..1ccf1e6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -399,6 +399,10 @@ struct sock {
 	int			(*sk_backlog_rcv)(struct sock *sk,
 						  struct sk_buff *skb);
 	void                    (*sk_destruct)(struct sock *sk);
+#ifdef CONFIG_INET_LL_RX_POLL
+	struct napi_struct	*dev_ref;
+	unsigned int		ll_gen_id;
+#endif
 };
 
 /*
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index df2e8b4..26cbf76 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -253,6 +253,7 @@ enum
 	LINUX_MIB_TCPFASTOPENLISTENOVERFLOW,	/* TCPFastOpenListenOverflow */
 	LINUX_MIB_TCPFASTOPENCOOKIEREQD,	/* TCPFastOpenCookieReqd */
 	LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES, /* TCPSpuriousRtxHostQueues */
+	LINUX_MIB_LOWLATENCYRXPACKETS,		/* LowLatencyRxPackets */
 	__LINUX_MIB_MAX
 };
 
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
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 2a5bf86..6577a11 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -273,6 +273,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPFastOpenListenOverflow", LINUX_MIB_TCPFASTOPENLISTENOVERFLOW),
 	SNMP_MIB_ITEM("TCPFastOpenCookieReqd", LINUX_MIB_TCPFASTOPENCOOKIEREQD),
 	SNMP_MIB_ITEM("TCPSpuriousRtxHostQueues", LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES),
+	SNMP_MIB_ITEM("LowLatencyRxPackets", LINUX_MIB_LOWLATENCYRXPACKETS),
 	SNMP_MIB_SENTINEL
 };
 
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
index 6b94633..626f6f7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -105,6 +105,14 @@
 #include <linux/sockios.h>
 #include <linux/atalk.h>
 
+#ifdef CONFIG_INET_LL_RX_POLL
+#include <net/ll_poll.h>
+int sysctl_net_ll_poll __read_mostly;
+EXPORT_SYMBOL_GPL(sysctl_net_ll_poll);
+unsigned int ll_global_gen_id __read_mostly;
+EXPORT_SYMBOL_GPL(ll_global_gen_id);
+#endif
+
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
@@ -1142,13 +1150,29 @@ EXPORT_SYMBOL(sock_create_lite);
 /* No kernel lock held - perfect */
 static unsigned int sock_poll(struct file *file, poll_table *wait)
 {
+	unsigned int poll_result;
 	struct socket *sock;
 
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
