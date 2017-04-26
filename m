From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v1 net-next 3/6] net: add new control message for incoming HW-timestamped packets
Date: Wed, 26 Apr 2017 16:50:32 +0200
Message-ID: <20170426145035.25846-4-mlichvar@redhat.com>
References: <20170426145035.25846-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38676 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S3001498AbdDZOup (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 10:50:45 -0400
In-Reply-To: <20170426145035.25846-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SOF_TIMESTAMPING_OPT_PKTINFO option to request a new control message
for incoming packets with hardware timestamps. It contains the index of
the real interface which received the packet and the length of the
packet at layer 2.

The index is useful with bonding, bridges and other interfaces, where
IP_PKTINFO doesn't allow applications to determine which PHC made the
timestamp. With the L2 length (and link speed) it is possible to
transpose preamble timestamps to trailer timestamps, which are used in
the NTP protocol.

While this information could be provided by two new socket options
independently from timestamping, it doesn't look like it would be very
useful. With this option any performance impact is limited to hardware
timestamping.

As skb currently has no field for the original interface index, use
napi_id to look up the device and its index. This limits the option to
kernels with enabled CONFIG_NET_RX_BUSY_POLL and drivers using napi,
which should cover all current MAC drivers that support hardware
timestamping.

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 Documentation/networking/timestamping.txt |  8 ++++++++
 include/linux/netdevice.h                 |  1 +
 include/uapi/asm-generic/socket.h         |  2 ++
 include/uapi/linux/net_tstamp.h           |  9 ++++++++-
 net/core/dev.c                            | 18 ++++++++++++++++++
 net/socket.c                              | 26 +++++++++++++++++++++++++-
 6 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 96f5069..6c07e7c 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -193,6 +193,14 @@ SOF_TIMESTAMPING_OPT_STATS:
   the transmit timestamps, such as how long a certain block of
   data was limited by peer's receiver window.
 
+SOF_TIMESTAMPING_OPT_PKTINFO:
+
+  Enable the SCM_TIMESTAMPING_PKTINFO control message for incoming
+  packets with hardware timestamps. The message contains struct
+  scm_ts_pktinfo, which supplies the index of the real interface
+  which received the packet and its length at layer 2. This option
+  works only if CONFIG_NET_RX_BUSY_POLL is enabled.
+
 New applications are encouraged to pass SOF_TIMESTAMPING_OPT_ID to
 disambiguate timestamps and SOF_TIMESTAMPING_OPT_TSONLY to operate
 regardless of the setting of sysctl net.core.tstamp_allow_data.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8c5c8cd..c7ce189 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2451,6 +2451,7 @@ static inline int dev_recursion_level(void)
 struct net_device *dev_get_by_index(struct net *net, int ifindex);
 struct net_device *__dev_get_by_index(struct net *net, int ifindex);
 struct net_device *dev_get_by_index_rcu(struct net *net, int ifindex);
+struct net_device *dev_get_by_napi_id(unsigned int napi_id);
 int netdev_get_name(struct net *net, char *name, int ifindex);
 int dev_restart(struct net_device *dev);
 int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb);
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 2b48856..a5f6e81 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -100,4 +100,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 0749fb1..8fcae35 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -26,8 +26,9 @@ enum {
 	SOF_TIMESTAMPING_OPT_CMSG = (1<<10),
 	SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
 	SOF_TIMESTAMPING_OPT_STATS = (1<<12),
+	SOF_TIMESTAMPING_OPT_PKTINFO = (1<<13),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_STATS,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_PKTINFO,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
@@ -130,4 +131,10 @@ enum hwtstamp_rx_filters {
 	HWTSTAMP_FILTER_NTP_ALL,
 };
 
+/* SCM_TIMESTAMPING_PKTINFO control message */
+struct scm_ts_pktinfo {
+	int if_index;
+	int pkt_length;
+};
+
 #endif /* _NET_TIMESTAMPING_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 1b3317c..0a78f7f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -160,6 +160,7 @@ static int netif_rx_internal(struct sk_buff *skb);
 static int call_netdevice_notifiers_info(unsigned long val,
 					 struct net_device *dev,
 					 struct netdev_notifier_info *info);
+static struct napi_struct *napi_by_id(unsigned int napi_id);
 
 /*
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
@@ -863,6 +864,23 @@ struct net_device *dev_get_by_index(struct net *net, int ifindex)
 }
 EXPORT_SYMBOL(dev_get_by_index);
 
+struct net_device *dev_get_by_napi_id(unsigned int napi_id)
+{
+	struct net_device *dev = NULL;
+	struct napi_struct *napi;
+
+	rcu_read_lock();
+
+	napi = napi_by_id(napi_id);
+	if (napi)
+		dev = napi->dev;
+
+	rcu_read_unlock();
+
+	return dev;
+}
+EXPORT_SYMBOL(dev_get_by_napi_id);
+
 /**
  *	netdev_get_name - get a netdevice name, knowing its ifindex.
  *	@net: network namespace
diff --git a/net/socket.c b/net/socket.c
index c2564eb..5ea5f29 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -662,6 +662,26 @@ static bool skb_is_err_queue(const struct sk_buff *skb)
 	return skb->pkt_type == PACKET_OUTGOING;
 }
 
+static void put_ts_pktinfo(struct msghdr *msg, struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	struct scm_ts_pktinfo ts_pktinfo;
+	struct net_device *orig_dev;
+
+	if (skb->napi_id < MIN_NAPI_ID || !skb_mac_header_was_set(skb))
+		return;
+
+	orig_dev = dev_get_by_napi_id(skb->napi_id);
+	if (!orig_dev)
+		return;
+
+	ts_pktinfo.if_index = orig_dev->ifindex;
+	ts_pktinfo.pkt_length = skb->len - skb_mac_offset(skb);
+	put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_PKTINFO,
+		 sizeof(ts_pktinfo), &ts_pktinfo);
+#endif
+}
+
 /*
  * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
  */
@@ -699,8 +719,12 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 		empty = 0;
 	if (shhwtstamps &&
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
-	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
+	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
 		empty = 0;
+		if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_PKTINFO) &&
+		    !skb_is_err_queue(skb))
+			put_ts_pktinfo(msg, skb);
+	}
 	if (!empty) {
 		put_cmsg(msg, SOL_SOCKET,
 			 SCM_TIMESTAMPING, sizeof(tss), &tss);
-- 
2.9.3
