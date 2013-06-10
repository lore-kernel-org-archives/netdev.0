From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v10 net-next 2/6] net: add low latency socket
	poll
Date: Mon, 10 Jun 2013 11:39:50 +0300
Message-ID: <20130610083950.6955.9813.stgit@ladj378.jer.intel.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Eliezer Tamir <eliezer@tamir.org.il>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adds an ndo_ll_poll method and the code that supports it.
This method can be used by low latency applications to busy-poll
Ethernet device queues directly from the socket code.
sysctl_net_ll_poll controls how many microseconds to poll.
Default is zero (disabled).
Individual protocol support will be added by subsequent patches.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 Documentation/sysctl/net.txt |    7 ++
 include/linux/netdevice.h    |    3 +
 include/linux/skbuff.h       |    8 ++
 include/net/ll_poll.h        |  148 ++++++++++++++++++++++++++++++++++++++++++
 include/net/sock.h           |    4 +
 include/uapi/linux/snmp.h    |    1 
 net/Kconfig                  |   12 +++
 net/core/skbuff.c            |    4 +
 net/core/sock.c              |    6 ++
 net/core/sysctl_net_core.c   |   10 +++
 net/ipv4/proc.c              |    1 
 net/socket.c                 |    6 ++
 12 files changed, 208 insertions(+), 2 deletions(-)
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
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 39bbd46..2ecb96d 100644
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
index 9995834..400d82a 100644
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
index 0000000..bc262f8
--- /dev/null
+++ b/include/net/ll_poll.h
@@ -0,0 +1,148 @@
+/*
+ * Low Latency Sockets
+ * Copyright(c) 2013 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Author: Eliezer Tamir
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ */
+
+/*
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
+extern unsigned long sysctl_net_ll_poll __read_mostly;
+
+/* return values from ndo_ll_poll */
+#define LL_FLUSH_FAILED		-1
+#define LL_FLUSH_BUSY		-2
+
+/* we don't mind a ~2.5% imprecision */
+#define TSC_MHZ (tsc_khz >> 10)
+
+static inline cycles_t ll_end_time(void)
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
+static inline bool can_poll_ll(cycles_t end_time)
+{
+	return !time_after((unsigned long)get_cycles(),
+			    (unsigned long)end_time);
+}
+
+static inline bool sk_poll_ll(struct sock *sk, int nonblock)
+{
+	cycles_t end_time = ll_end_time();
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
+/* used in the NIC receive handler to mark the skb */
+static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+{
+	skb->napi_id = napi->napi_id;
+}
+
+/* used in the protocol hanlder to propagate the napi_id to the socket */
+static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+{
+	sk->sk_napi_id = skb->napi_id;
+}
+
+#else /* CONFIG_NET_LL_RX_POLL */
+
+static inline cycles_t ll_end_time(void)
+{
+	return 0;
+}
+
+static inline bool sk_valid_ll(struct sock *sk)
+{
+	return false;
+}
+
+static inline bool sk_poll_ll(struct sock *sk, int nonblock)
+{
+	return false;
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
+static inline bool can_poll_ll(cycles_t end_time)
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
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 73f57a0..4a4181e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -733,6 +733,10 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->vlan_tci		= old->vlan_tci;
 
 	skb_copy_secmark(new, old);
+
+#ifdef CONFIG_NET_LL_RX_POLL
+	new->napi_id	= old->napi_id;
+#endif
 }
 
 /*
diff --git a/net/core/sock.c b/net/core/sock.c
index 88868a9..788c0da 100644
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
index 741db5fc..4b48f39 100644
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
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax
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
 
diff --git a/net/socket.c b/net/socket.c
index 3ebdcb8..21fd29f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -104,6 +104,12 @@
 #include <linux/route.h>
 #include <linux/sockios.h>
 #include <linux/atalk.h>
+#include <net/ll_poll.h>
+
+#ifdef CONFIG_NET_LL_RX_POLL
+unsigned long sysctl_net_ll_poll __read_mostly;
+EXPORT_SYMBOL_GPL(sysctl_net_ll_poll);
+#endif
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,


------------------------------------------------------------------------------
How ServiceNow helps IT people transform IT departments:
1. A cloud service to automate IT design, transition and operations
2. Dashboards that offer high-level views of enterprise services
3. A single system of record for all IT processes
http://p.sf.net/sfu/servicenow-d2d-j
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
