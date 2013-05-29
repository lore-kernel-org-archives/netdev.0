From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v6 net-next 2/5] net: implement support for
 low latency socket polling
Date: Wed, 29 May 2013 09:39:35 +0300
Message-ID: <20130529063935.27486.18610.stgit@ladj378.jer.intel.com>
References: <20130529063916.27486.3841.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, linux-kernel@vger.kernel.org,
	Alex Rosenbaum <alexr@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130529063916.27486.3841.stgit@ladj378.jer.intel.com>
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
This method can be used by low latency applications to busy poll Ethernet
device queues directly from the socket code. The value of sysctl_net_ll_poll
controls how many microseconds to poll. Set to zero to disable.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 Documentation/sysctl/net.txt |    7 ++
 fs/select.c                  |    7 ++
 include/linux/netdevice.h    |    3 +
 include/linux/skbuff.h       |    8 ++-
 include/net/ll_poll.h        |  126 ++++++++++++++++++++++++++++++++++++++++++
 include/net/sock.h           |    4 +
 include/uapi/linux/snmp.h    |    1 
 net/Kconfig                  |   12 ++++
 net/core/datagram.c          |    4 +
 net/core/skbuff.c            |    4 +
 net/core/sock.c              |    6 ++
 net/core/sysctl_net_core.c   |   10 +++
 net/ipv4/proc.c              |    1 
 net/ipv4/udp.c               |    6 ++
 net/ipv6/udp.c               |    6 ++
 net/socket.c                 |   16 +++++
 16 files changed, 216 insertions(+), 5 deletions(-)
 create mode 100644 include/net/ll_poll.h

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index c1f8640..85ab72d 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -50,6 +50,13 @@ The maximum number of packets that kernel can handle on a NAPI interrupt,
 it's a Per-CPU variable.
 Default: 64
 
+low_latency_poll
+----------------
+Low latency busy poll timeout. (needs CONFIG_NET_LL_RX_POLL)
+Approximate time in us to spin waiting for packets on the device queue.
+Recommended value is 50. May increase power usage.
+Default: 0 (off)
+
 rmem_default
 ------------
 
diff --git a/fs/select.c b/fs/select.c
index 8c1c96c..0ef246d 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -27,6 +27,7 @@
 #include <linux/rcupdate.h>
 #include <linux/hrtimer.h>
 #include <linux/sched/rt.h>
+#include <net/ll_poll.h>
 
 #include <asm/uaccess.h>
 
@@ -400,6 +401,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	poll_table *wait;
 	int retval, i, timed_out = 0;
 	unsigned long slack = 0;
+	unsigned long ll_time = ll_end_time();
 
 	rcu_read_lock();
 	retval = max_select_fd(n, fds);
@@ -486,6 +488,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 			break;
 		}
 
+		if (can_poll_ll(ll_time))
+			continue;
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
@@ -750,6 +754,7 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 	ktime_t expire, *to = NULL;
 	int timed_out = 0, count = 0;
 	unsigned long slack = 0;
+	unsigned long ll_time = ll_end_time();
 
 	/* Optimise the no-wait case */
 	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
@@ -795,6 +800,8 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 		if (count || timed_out)
 			break;
 
+		if (can_poll_ll(ll_time))
+			continue;
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 964648e..7acea42 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -972,6 +972,9 @@ struct net_device_ops {
 						     gfp_t gfp);
 	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
+#ifdef CONFIG_NET_LL_RX_POLL
+	int			(*ndo_ll_poll)(struct napi_struct *dev);
+#endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
 						  int queue, u8 *mac);
 	int			(*ndo_set_vf_vlan)(struct net_device *dev,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8f2b830..77f0a14 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -386,6 +386,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
+  *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
  *	@mark: Generic packet mark
  *	@dropcount: total number of sk_receive_queue overflows
@@ -500,8 +501,11 @@ struct sk_buff {
 	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
-#ifdef CONFIG_NET_DMA
-	dma_cookie_t		dma_cookie;
+#if defined CONFIG_NET_DMA || defined CONFIG_NET_LL_RX_POLL
+	union {
+		unsigned int	napi_id;
+		dma_cookie_t	dma_cookie;
+	};
 #endif
 #ifdef CONFIG_NETWORK_SECMARK
 	__u32			secmark;
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
new file mode 100644
index 0000000..9e1c972
--- /dev/null
+++ b/include/net/ll_poll.h
@@ -0,0 +1,126 @@
+/*
+ * low latency network device queue flush
+ * Copyright(c) 2013 Intel Corporation.
+ * Author: Eliezer Tamir
+ *
+ * For now this depends on CONFIG_X86_TSC
+ */
+
+#ifndef _LINUX_NET_LL_POLL_H
+#define _LINUX_NET_LL_POLL_H
+
+#include <linux/netdevice.h>
+#include <net/ip.h>
+
+#ifdef CONFIG_NET_LL_RX_POLL
+
+struct napi_struct;
+extern int sysctl_net_ll_poll __read_mostly;
+
+/* return values from ndo_ll_poll */
+#define LL_FLUSH_FAILED		-1
+#define LL_FLUSH_BUSY		-2
+
+/* we don't mind a ~2.5% imprecision */
+#define TSC_MHZ (tsc_khz >> 10)
+
+static inline unsigned long ll_end_time(void)
+{
+	return TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll) + get_cycles();
+}
+
+static inline bool sk_valid_ll(struct sock *sk)
+{
+	return sysctl_net_ll_poll && sk->sk_napi_id &&
+	       !need_resched() && !signal_pending(current);
+}
+
+static inline bool can_poll_ll(unsigned long end_time)
+{
+	return !time_after((unsigned long)get_cycles(), end_time);
+}
+
+static inline bool sk_poll_ll(struct sock *sk, int nonblock)
+{
+	unsigned long end_time = ll_end_time();
+	const struct net_device_ops *ops;
+	struct napi_struct *napi;
+	int rc = false;
+
+	/*
+	 * rcu read lock for napi hash
+	 * bh so we don't race with net_rx_action
+	 */
+	rcu_read_lock_bh();
+
+	napi = napi_by_id(sk->sk_napi_id);
+	if (!napi)
+		goto out;
+
+	ops = napi->dev->netdev_ops;
+	if (!ops->ndo_ll_poll)
+		goto out;
+
+	do {
+
+		rc = ops->ndo_ll_poll(napi);
+
+		if (rc == LL_FLUSH_FAILED)
+			break; /* permanent failure */
+
+		if (rc > 0)
+			/* local bh are disabled so it is ok to use _BH */
+			NET_ADD_STATS_BH(sock_net(sk),
+					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
+
+	} while (skb_queue_empty(&sk->sk_receive_queue)
+			&& can_poll_ll(end_time) && !nonblock);
+
+	rc = !skb_queue_empty(&sk->sk_receive_queue);
+out:
+	rcu_read_unlock_bh();
+	return rc;
+}
+
+static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+{
+	skb->napi_id = napi->napi_id;
+}
+
+static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+{
+	sk->sk_napi_id = skb->napi_id;
+}
+
+#else /* CONFIG_NET_LL_RX_POLL */
+
+static inline unsigned long ll_end_time(void)
+{
+	return 0;
+}
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
+static inline bool can_poll_ll(unsigned long end_time)
+{
+	return false;
+}
+
+#endif /* CONFIG_NET_LL_RX_POLL */
+#endif /* _LINUX_NET_LL_POLL_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 66772cf..ac8e181 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -229,6 +229,7 @@ struct cg_proto;
   *	@sk_omem_alloc: "o" is "option" or "other"
   *	@sk_wmem_queued: persistent queue size
   *	@sk_forward_alloc: space allocated forward
+  *	@sk_napi_id: id of the last napi context to receive data for sk
   *	@sk_allocation: allocation mode
   *	@sk_sndbuf: size of send buffer in bytes
   *	@sk_flags: %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
@@ -325,6 +326,9 @@ struct sock {
 #ifdef CONFIG_RPS
 	__u32			sk_rxhash;
 #endif
+#ifdef CONFIG_NET_LL_RX_POLL
+	unsigned int		sk_napi_id;
+#endif
 	atomic_t		sk_drops;
 	int			sk_rcvbuf;
 
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
 
diff --git a/net/Kconfig b/net/Kconfig
index 523e43e..d6a9ce6 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -243,6 +243,18 @@ config NETPRIO_CGROUP
 	  Cgroup subsystem for use in assigning processes to network priorities on
 	  a per-interface basis
 
+config NET_LL_RX_POLL
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
 config BQL
 	boolean
 	depends on SYSFS
diff --git a/net/core/datagram.c b/net/core/datagram.c
index b71423d..9cbaba9 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -56,6 +56,7 @@
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <trace/events/skb.h>
+#include <net/ll_poll.h>
 
 /*
  *	Is a socket 'connection oriented' ?
@@ -207,6 +208,9 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 		}
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
 
+		if (sk_valid_ll(sk) && sk_poll_ll(sk, flags & MSG_DONTWAIT))
+			continue;
+
 		/* User doesn't want to wait */
 		error = -EAGAIN;
 		if (!timeo)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f45de07..674bcde 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -739,6 +739,10 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->vlan_tci		= old->vlan_tci;
 
 	skb_copy_secmark(new, old);
+
+#ifdef CONFIG_NET_LL_RX_POLL
+	new->napi_id	= old->napi_id;
+#endif
 }
 
 /*
diff --git a/net/core/sock.c b/net/core/sock.c
index 6ba327d..804fd5b 100644
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
 
+#ifdef CONFIG_NET_LL_RX_POLL
+	sk->sk_napi_id		=	0;
+#endif
+
 	/*
 	 * Before updating sk_refcnt, we must commit prior changes to memory
 	 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 741db5fc..4ca5702 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -19,6 +19,7 @@
 #include <net/ip.h>
 #include <net/sock.h>
 #include <net/net_ratelimit.h>
+#include <net/ll_poll.h>
 
 static int one = 1;
 
@@ -284,6 +285,15 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= flow_limit_table_len_sysctl
 	},
 #endif /* CONFIG_NET_FLOW_LIMIT */
+#ifdef CONFIG_NET_LL_RX_POLL
+	{
+		.procname	= "low_latency_poll",
+		.data		= &sysctl_net_ll_poll,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+#endif
 #endif /* CONFIG_NET */
 	{
 		.procname	= "netdev_budget",
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
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index aa5eff4..e7ab9c8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -109,6 +109,7 @@
 #include <trace/events/udp.h>
 #include <linux/static_key.h>
 #include <trace/events/skb.h>
+#include <net/ll_poll.h>
 #include "udp_impl.h"
 
 struct udp_table udp_table __read_mostly;
@@ -1709,7 +1710,10 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 
 	if (sk != NULL) {
-		int ret = udp_queue_rcv_skb(sk, skb);
+		int ret;
+
+		sk_mark_ll(sk, skb);
+		ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
 		/* a return value > 0 means to resubmit the input, but
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 42923b1..4035997 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -46,6 +46,7 @@
 #include <net/ip6_checksum.h>
 #include <net/xfrm.h>
 #include <net/inet6_hashtables.h>
+#include <net/ll_poll.h>
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -841,7 +842,10 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	 */
 	sk = __udp6_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 	if (sk != NULL) {
-		int ret = udpv6_queue_rcv_skb(sk, skb);
+		int ret;
+
+		sk_mark_ll(sk, skb);
+		ret = udpv6_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
 		/* a return value > 0 means to resubmit the input, but
diff --git a/net/socket.c b/net/socket.c
index 6b94633..c3725eb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -104,6 +104,12 @@
 #include <linux/route.h>
 #include <linux/sockios.h>
 #include <linux/atalk.h>
+#include <net/ll_poll.h>
+
+#ifdef CONFIG_NET_LL_RX_POLL
+int sysctl_net_ll_poll __read_mostly;
+EXPORT_SYMBOL_GPL(sysctl_net_ll_poll);
+#endif
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -1142,13 +1148,21 @@ EXPORT_SYMBOL(sock_create_lite);
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
+	if (!(poll_result & (POLLRDNORM | POLLERR | POLLRDHUP | POLLHUP)) &&
+		sk_valid_ll(sock->sk) && sk_poll_ll(sock->sk, 1))
+			poll_result = sock->ops->poll(file, sock, NULL);
+
+	return poll_result;
 }
 
 static int sock_mmap(struct file *file, struct vm_area_struct *vma)


------------------------------------------------------------------------------
Introducing AppDynamics Lite, a free troubleshooting tool for Java/.NET
Get 100% visibility into your production application - at no cost.
Code-level diagnostics for performance bottlenecks with <2% overhead
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
