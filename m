From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 1/7] Sync with 2.6.19 kernel header about include/linux.
Date: Tue,  5 Dec 2006 19:15:21 +0900
Message-ID: <11653137213434-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:38918 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S937414AbWLEKPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:15:52 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/linux/fib_rules.h                |    3 
 include/linux/genetlink.h                |   18 +
 include/linux/if_addr.h                  |   55 +++
 include/linux/if_link.h                  |  136 ++++++++
 include/linux/inet_diag.h                |   26 +
 include/linux/neighbour.h                |  159 +++++++++
 include/linux/netfilter_ipv4/ip_tables.h |  238 +++++++------
 include/linux/netlink.h                  |  109 ++++++
 include/linux/pkt_cls.h                  |    1 
 include/linux/rtnetlink.h                |  532 ++++++++++--------------------
 include/linux/socket.h                   |   20 +
 include/linux/tcp.h                      |  244 +++++++++++++-
 include/linux/types.h                    |  202 +++++++++++
 include/linux/xfrm.h                     |   55 +++
 14 files changed, 1294 insertions(+), 504 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 8270aac..4418c8d 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -6,7 +6,6 @@ #include <linux/rtnetlink.h>
 
 /* rule is permanent, and cannot be deleted */
 #define FIB_RULE_PERMANENT	1
-#define FIB_RULE_INVERT		2
 
 struct fib_rule_hdr
 {
@@ -35,7 +34,7 @@ enum
 	FRA_UNUSED3,
 	FRA_UNUSED4,
 	FRA_UNUSED5,
-	FRA_FWMARK,	/* mark */
+	FRA_FWMARK,	/* netfilter mark */
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
 	FRA_UNUSED7,
diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 84f12a4..9049dc6 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -16,6 +16,8 @@ struct genlmsghdr {
 
 #define GENL_HDRLEN	NLMSG_ALIGN(sizeof(struct genlmsghdr))
 
+#define GENL_ADMIN_PERM		0x01
+
 /*
  * List of reserved static generic netlink identifiers:
  */
@@ -43,9 +45,25 @@ enum {
 	CTRL_ATTR_UNSPEC,
 	CTRL_ATTR_FAMILY_ID,
 	CTRL_ATTR_FAMILY_NAME,
+	CTRL_ATTR_VERSION,
+	CTRL_ATTR_HDRSIZE,
+	CTRL_ATTR_MAXATTR,
+	CTRL_ATTR_OPS,
 	__CTRL_ATTR_MAX,
 };
 
 #define CTRL_ATTR_MAX (__CTRL_ATTR_MAX - 1)
 
+enum {
+	CTRL_ATTR_OP_UNSPEC,
+	CTRL_ATTR_OP_ID,
+	CTRL_ATTR_OP_FLAGS,
+	CTRL_ATTR_OP_POLICY,
+	CTRL_ATTR_OP_DOIT,
+	CTRL_ATTR_OP_DUMPIT,
+	__CTRL_ATTR_OP_MAX,
+};
+
+#define CTRL_ATTR_OP_MAX (__CTRL_ATTR_OP_MAX - 1)
+
 #endif	/* __LINUX_GENERIC_NETLINK_H */
diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
new file mode 100644
index 0000000..dbe8f61
--- /dev/null
+++ b/include/linux/if_addr.h
@@ -0,0 +1,55 @@
+#ifndef __LINUX_IF_ADDR_H
+#define __LINUX_IF_ADDR_H
+
+#include <linux/netlink.h>
+
+struct ifaddrmsg
+{
+	__u8		ifa_family;
+	__u8		ifa_prefixlen;	/* The prefix length		*/
+	__u8		ifa_flags;	/* Flags			*/
+	__u8		ifa_scope;	/* Address scope		*/
+	__u32		ifa_index;	/* Link index			*/
+};
+
+/*
+ * Important comment:
+ * IFA_ADDRESS is prefix address, rather than local interface address.
+ * It makes no difference for normally configured broadcast interfaces,
+ * but for point-to-point IFA_ADDRESS is DESTINATION address,
+ * local address is supplied in IFA_LOCAL attribute.
+ */
+enum
+{
+	IFA_UNSPEC,
+	IFA_ADDRESS,
+	IFA_LOCAL,
+	IFA_LABEL,
+	IFA_BROADCAST,
+	IFA_ANYCAST,
+	IFA_CACHEINFO,
+	IFA_MULTICAST,
+	__IFA_MAX,
+};
+
+#define IFA_MAX (__IFA_MAX - 1)
+
+/* ifa_flags */
+#define IFA_F_SECONDARY		0x01
+#define IFA_F_TEMPORARY		IFA_F_SECONDARY
+
+#define	IFA_F_NODAD		0x02
+#define	IFA_F_HOMEADDRESS	0x10
+#define IFA_F_DEPRECATED	0x20
+#define IFA_F_TENTATIVE		0x40
+#define IFA_F_PERMANENT		0x80
+
+struct ifa_cacheinfo
+{
+	__u32	ifa_prefered;
+	__u32	ifa_valid;
+	__u32	cstamp; /* created timestamp, hundredths of seconds */
+	__u32	tstamp; /* updated timestamp, hundredths of seconds */
+};
+
+#endif
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
new file mode 100644
index 0000000..e963a07
--- /dev/null
+++ b/include/linux/if_link.h
@@ -0,0 +1,136 @@
+#ifndef _LINUX_IF_LINK_H
+#define _LINUX_IF_LINK_H
+
+#include <linux/netlink.h>
+
+/* The struct should be in sync with struct net_device_stats */
+struct rtnl_link_stats
+{
+	__u32	rx_packets;		/* total packets received	*/
+	__u32	tx_packets;		/* total packets transmitted	*/
+	__u32	rx_bytes;		/* total bytes received 	*/
+	__u32	tx_bytes;		/* total bytes transmitted	*/
+	__u32	rx_errors;		/* bad packets received		*/
+	__u32	tx_errors;		/* packet transmit problems	*/
+	__u32	rx_dropped;		/* no space in linux buffers	*/
+	__u32	tx_dropped;		/* no space available in linux	*/
+	__u32	multicast;		/* multicast packets received	*/
+	__u32	collisions;
+
+	/* detailed rx_errors: */
+	__u32	rx_length_errors;
+	__u32	rx_over_errors;		/* receiver ring buff overflow	*/
+	__u32	rx_crc_errors;		/* recved pkt with crc error	*/
+	__u32	rx_frame_errors;	/* recv'd frame alignment error */
+	__u32	rx_fifo_errors;		/* recv'r fifo overrun		*/
+	__u32	rx_missed_errors;	/* receiver missed packet	*/
+
+	/* detailed tx_errors */
+	__u32	tx_aborted_errors;
+	__u32	tx_carrier_errors;
+	__u32	tx_fifo_errors;
+	__u32	tx_heartbeat_errors;
+	__u32	tx_window_errors;
+
+	/* for cslip etc */
+	__u32	rx_compressed;
+	__u32	tx_compressed;
+};
+
+/* The struct should be in sync with struct ifmap */
+struct rtnl_link_ifmap
+{
+	__u64	mem_start;
+	__u64	mem_end;
+	__u64	base_addr;
+	__u16	irq;
+	__u8	dma;
+	__u8	port;
+};
+
+enum
+{
+	IFLA_UNSPEC,
+	IFLA_ADDRESS,
+	IFLA_BROADCAST,
+	IFLA_IFNAME,
+	IFLA_MTU,
+	IFLA_LINK,
+	IFLA_QDISC,
+	IFLA_STATS,
+	IFLA_COST,
+#define IFLA_COST IFLA_COST
+	IFLA_PRIORITY,
+#define IFLA_PRIORITY IFLA_PRIORITY
+	IFLA_MASTER,
+#define IFLA_MASTER IFLA_MASTER
+	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
+#define IFLA_WIRELESS IFLA_WIRELESS
+	IFLA_PROTINFO,		/* Protocol specific information for a link */
+#define IFLA_PROTINFO IFLA_PROTINFO
+	IFLA_TXQLEN,
+#define IFLA_TXQLEN IFLA_TXQLEN
+	IFLA_MAP,
+#define IFLA_MAP IFLA_MAP
+	IFLA_WEIGHT,
+#define IFLA_WEIGHT IFLA_WEIGHT
+	IFLA_OPERSTATE,
+	IFLA_LINKMODE,
+	__IFLA_MAX
+};
+
+
+#define IFLA_MAX (__IFLA_MAX - 1)
+
+/* ifi_flags.
+
+   IFF_* flags.
+
+   The only change is:
+   IFF_LOOPBACK, IFF_BROADCAST and IFF_POINTOPOINT are
+   more not changeable by user. They describe link media
+   characteristics and set by device driver.
+
+   Comments:
+   - Combination IFF_BROADCAST|IFF_POINTOPOINT is invalid
+   - If neither of these three flags are set;
+     the interface is NBMA.
+
+   - IFF_MULTICAST does not mean anything special:
+   multicasts can be used on all not-NBMA links.
+   IFF_MULTICAST means that this media uses special encapsulation
+   for multicast frames. Apparently, all IFF_POINTOPOINT and
+   IFF_BROADCAST devices are able to use multicasts too.
+ */
+
+/* IFLA_LINK.
+   For usual devices it is equal ifi_index.
+   If it is a "virtual interface" (f.e. tunnel), ifi_link
+   can point to real physical interface (f.e. for bandwidth calculations),
+   or maybe 0, what means, that real media is unknown (usual
+   for IPIP tunnels, when route to endpoint is allowed to change)
+ */
+
+/* Subtype attributes for IFLA_PROTINFO */
+enum
+{
+	IFLA_INET6_UNSPEC,
+	IFLA_INET6_FLAGS,	/* link flags			*/
+	IFLA_INET6_CONF,	/* sysctl parameters		*/
+	IFLA_INET6_STATS,	/* statistics			*/
+	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
+	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
+	__IFLA_INET6_MAX
+};
+
+#define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
+
+struct ifla_cacheinfo
+{
+	__u32	max_reasm_len;
+	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
+	__u32	reachable_time;
+	__u32	retrans_time;
+};
+
+#endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 85d456d..6e8bc54 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -9,10 +9,10 @@ #define INET_DIAG_GETSOCK_MAX 24
 
 /* Socket identity */
 struct inet_diag_sockid {
-	__u16	idiag_sport;
-	__u16	idiag_dport;
-	__u32	idiag_src[4];
-	__u32	idiag_dst[4];
+	__be16	idiag_sport;
+	__be16	idiag_dport;
+	__be32	idiag_src[4];
+	__be32	idiag_dst[4];
 	__u32	idiag_if;
 	__u32	idiag_cookie[2];
 #define INET_DIAG_NOCOOKIE (~0U)
@@ -67,7 +67,7 @@ struct inet_diag_hostcond {
 	__u8	family;
 	__u8	prefix_len;
 	int	port;
-	__u32	addr[0];
+	__be32	addr[0];
 };
 
 /* Base info structure. It contains socket identity (addrs/ports/cookie)
@@ -118,5 +118,21 @@ struct tcpvegas_info {
 	__u32	tcpv_minrtt;
 };
 
+#ifdef __KERNEL__
+struct sock;
+struct inet_hashinfo;
+
+struct inet_diag_handler {
+	struct inet_hashinfo    *idiag_hashinfo;
+	void			(*idiag_get_info)(struct sock *sk,
+						  struct inet_diag_msg *r,
+						  void *info);
+	__u16                   idiag_info_size;
+	__u16                   idiag_type;
+};
+
+extern int  inet_diag_register(const struct inet_diag_handler *handler);
+extern void inet_diag_unregister(const struct inet_diag_handler *handler);
+#endif /* __KERNEL__ */
 
 #endif /* _INET_DIAG_H_ */
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
new file mode 100644
index 0000000..bd3bbf6
--- /dev/null
+++ b/include/linux/neighbour.h
@@ -0,0 +1,159 @@
+#ifndef __LINUX_NEIGHBOUR_H
+#define __LINUX_NEIGHBOUR_H
+
+#include <linux/netlink.h>
+
+struct ndmsg
+{
+	__u8		ndm_family;
+	__u8		ndm_pad1;
+	__u16		ndm_pad2;
+	__s32		ndm_ifindex;
+	__u16		ndm_state;
+	__u8		ndm_flags;
+	__u8		ndm_type;
+};
+
+enum
+{
+	NDA_UNSPEC,
+	NDA_DST,
+	NDA_LLADDR,
+	NDA_CACHEINFO,
+	NDA_PROBES,
+	__NDA_MAX
+};
+
+#define NDA_MAX (__NDA_MAX - 1)
+
+/*
+ *	Neighbor Cache Entry Flags
+ */
+
+#define NTF_PROXY	0x08	/* == ATF_PUBL */
+#define NTF_ROUTER	0x80
+
+/*
+ *	Neighbor Cache Entry States.
+ */
+
+#define NUD_INCOMPLETE	0x01
+#define NUD_REACHABLE	0x02
+#define NUD_STALE	0x04
+#define NUD_DELAY	0x08
+#define NUD_PROBE	0x10
+#define NUD_FAILED	0x20
+
+/* Dummy states */
+#define NUD_NOARP	0x40
+#define NUD_PERMANENT	0x80
+#define NUD_NONE	0x00
+
+/* NUD_NOARP & NUD_PERMANENT are pseudostates, they never change
+   and make no address resolution or NUD.
+   NUD_PERMANENT is also cannot be deleted by garbage collectors.
+ */
+
+struct nda_cacheinfo
+{
+	__u32		ndm_confirmed;
+	__u32		ndm_used;
+	__u32		ndm_updated;
+	__u32		ndm_refcnt;
+};
+
+/*****************************************************************
+ *		Neighbour tables specific messages.
+ *
+ * To retrieve the neighbour tables send RTM_GETNEIGHTBL with the
+ * NLM_F_DUMP flag set. Every neighbour table configuration is
+ * spread over multiple messages to avoid running into message
+ * size limits on systems with many interfaces. The first message
+ * in the sequence transports all not device specific data such as
+ * statistics, configuration, and the default parameter set.
+ * This message is followed by 0..n messages carrying device
+ * specific parameter sets.
+ * Although the ordering should be sufficient, NDTA_NAME can be
+ * used to identify sequences. The initial message can be identified
+ * by checking for NDTA_CONFIG. The device specific messages do
+ * not contain this TLV but have NDTPA_IFINDEX set to the
+ * corresponding interface index.
+ *
+ * To change neighbour table attributes, send RTM_SETNEIGHTBL
+ * with NDTA_NAME set. Changeable attribute include NDTA_THRESH[1-3],
+ * NDTA_GC_INTERVAL, and all TLVs in NDTA_PARMS unless marked
+ * otherwise. Device specific parameter sets can be changed by
+ * setting NDTPA_IFINDEX to the interface index of the corresponding
+ * device.
+ ****/
+
+struct ndt_stats
+{
+	__u64		ndts_allocs;
+	__u64		ndts_destroys;
+	__u64		ndts_hash_grows;
+	__u64		ndts_res_failed;
+	__u64		ndts_lookups;
+	__u64		ndts_hits;
+	__u64		ndts_rcv_probes_mcast;
+	__u64		ndts_rcv_probes_ucast;
+	__u64		ndts_periodic_gc_runs;
+	__u64		ndts_forced_gc_runs;
+};
+
+enum {
+	NDTPA_UNSPEC,
+	NDTPA_IFINDEX,			/* u32, unchangeable */
+	NDTPA_REFCNT,			/* u32, read-only */
+	NDTPA_REACHABLE_TIME,		/* u64, read-only, msecs */
+	NDTPA_BASE_REACHABLE_TIME,	/* u64, msecs */
+	NDTPA_RETRANS_TIME,		/* u64, msecs */
+	NDTPA_GC_STALETIME,		/* u64, msecs */
+	NDTPA_DELAY_PROBE_TIME,		/* u64, msecs */
+	NDTPA_QUEUE_LEN,		/* u32 */
+	NDTPA_APP_PROBES,		/* u32 */
+	NDTPA_UCAST_PROBES,		/* u32 */
+	NDTPA_MCAST_PROBES,		/* u32 */
+	NDTPA_ANYCAST_DELAY,		/* u64, msecs */
+	NDTPA_PROXY_DELAY,		/* u64, msecs */
+	NDTPA_PROXY_QLEN,		/* u32 */
+	NDTPA_LOCKTIME,			/* u64, msecs */
+	__NDTPA_MAX
+};
+#define NDTPA_MAX (__NDTPA_MAX - 1)
+
+struct ndtmsg
+{
+	__u8		ndtm_family;
+	__u8		ndtm_pad1;
+	__u16		ndtm_pad2;
+};
+
+struct ndt_config
+{
+	__u16		ndtc_key_len;
+	__u16		ndtc_entry_size;
+	__u32		ndtc_entries;
+	__u32		ndtc_last_flush;	/* delta to now in msecs */
+	__u32		ndtc_last_rand;		/* delta to now in msecs */
+	__u32		ndtc_hash_rnd;
+	__u32		ndtc_hash_mask;
+	__u32		ndtc_hash_chain_gc;
+	__u32		ndtc_proxy_qlen;
+};
+
+enum {
+	NDTA_UNSPEC,
+	NDTA_NAME,			/* char *, unchangeable */
+	NDTA_THRESH1,			/* u32 */
+	NDTA_THRESH2,			/* u32 */
+	NDTA_THRESH3,			/* u32 */
+	NDTA_CONFIG,			/* struct ndt_config, read-only */
+	NDTA_PARMS,			/* nested TLV NDTPA_* */
+	NDTA_STATS,			/* struct ndt_stats, read-only */
+	NDTA_GC_INTERVAL,		/* u64, msecs */
+	__NDTA_MAX
+};
+#define NDTA_MAX (__NDTA_MAX - 1)
+
+#endif
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 17d8eff..4f06dad 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -15,10 +15,24 @@
 #ifndef _IPTABLES_H
 #define _IPTABLES_H
 
+#ifdef __KERNEL__
+#include <linux/if.h>
+#include <linux/types.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/skbuff.h>
+#endif
+#include <linux/compiler.h>
 #include <linux/netfilter_ipv4.h>
 
-#define IPT_FUNCTION_MAXNAMELEN 30
-#define IPT_TABLE_MAXNAMELEN 32
+#include <linux/netfilter/x_tables.h>
+
+#define IPT_FUNCTION_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
+#define IPT_TABLE_MAXNAMELEN XT_FUNCTION_MAXNAMELEN
+#define ipt_match xt_match
+#define ipt_target xt_target
+#define ipt_table xt_table
+#define ipt_get_revision xt_get_revision
 
 /* Yes, Virginia, you have to zero the padding. */
 struct ipt_ip {
@@ -38,70 +52,16 @@ struct ipt_ip {
 	u_int8_t invflags;
 };
 
-struct ipt_entry_match
-{
-	union {
-		struct {
-			u_int16_t match_size;
-
-			/* Used by userspace */
-			char name[IPT_FUNCTION_MAXNAMELEN-1];
-
-			u_int8_t revision;
-		} user;
-		struct {
-			u_int16_t match_size;
-
-			/* Used inside the kernel */
-			struct ipt_match *match;
-		} kernel;
-
-		/* Total length */
-		u_int16_t match_size;
-	} u;
-
-	unsigned char data[0];
-};
-
-struct ipt_entry_target
-{
-	union {
-		struct {
-			u_int16_t target_size;
-
-			/* Used by userspace */
-			char name[IPT_FUNCTION_MAXNAMELEN-1];
-
-			u_int8_t revision;
-		} user;
-		struct {
-			u_int16_t target_size;
-
-			/* Used inside the kernel */
-			struct ipt_target *target;
-		} kernel;
-
-		/* Total length */
-		u_int16_t target_size;
-	} u;
-
-	unsigned char data[0];
-};
-
-struct ipt_standard_target
-{
-	struct ipt_entry_target target;
-	int verdict;
-};
+#define ipt_entry_match xt_entry_match
+#define ipt_entry_target xt_entry_target
+#define ipt_standard_target xt_standard_target
 
-struct ipt_counters
-{
-	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
-};
+#define ipt_counters xt_counters
 
 /* Values for "flag" field in struct ipt_ip (general ip structure). */
 #define IPT_F_FRAG		0x01	/* Set if rule is a fragment rule */
-#define IPT_F_MASK		0x01	/* All possible flag bits mask. */
+#define IPT_F_GOTO		0x02	/* Set if jump is a goto */
+#define IPT_F_MASK		0x03	/* All possible flag bits mask. */
 
 /* Values for "inv" field in struct ipt_ip. */
 #define IPT_INV_VIA_IN		0x01	/* Invert the sense of IN IFACE. */
@@ -110,7 +70,7 @@ #define IPT_INV_TOS		0x04	/* Invert the 
 #define IPT_INV_SRCIP		0x08	/* Invert the sense of SRC IP. */
 #define IPT_INV_DSTIP		0x10	/* Invert the sense of DST OP. */
 #define IPT_INV_FRAG		0x20	/* Invert the sense of FRAG. */
-#define IPT_INV_PROTO		0x40	/* Invert the sense of PROTO. */
+#define IPT_INV_PROTO		XT_INV_PROTO
 #define IPT_INV_MASK		0x7F	/* All possible flag bits mask. */
 
 /* This structure defines each of the firewall rules.  Consists of 3
@@ -132,7 +92,7 @@ struct ipt_entry
 	unsigned int comefrom;
 
 	/* Packet and byte counters. */
-	struct ipt_counters counters;
+	struct xt_counters counters;
 
 	/* The matches (if any), then the target. */
 	unsigned char elems[0];
@@ -141,8 +101,11 @@ struct ipt_entry
 /*
  * New IP firewall options for [gs]etsockopt at the RAW IP level.
  * Unlike BSD Linux inherits IP options so you don't have to use a raw
- * socket for this. Instead we check rights in the calls. */
-#define IPT_BASE_CTL		64	/* base for firewall socket options */
+ * socket for this. Instead we check rights in the calls.
+ *
+ * ATTENTION: check linux/in.h before adding new number here.
+ */
+#define IPT_BASE_CTL		64
 
 #define IPT_SO_SET_REPLACE	(IPT_BASE_CTL)
 #define IPT_SO_SET_ADD_COUNTERS	(IPT_BASE_CTL + 1)
@@ -154,42 +117,22 @@ #define IPT_SO_GET_REVISION_MATCH	(IPT_B
 #define IPT_SO_GET_REVISION_TARGET	(IPT_BASE_CTL + 3)
 #define IPT_SO_GET_MAX			IPT_SO_GET_REVISION_TARGET
 
-/* CONTINUE verdict for targets */
-#define IPT_CONTINUE 0xFFFFFFFF
-
-/* For standard target */
-#define IPT_RETURN (-NF_MAX_VERDICT - 1)
-
-/* TCP matching stuff */
-struct ipt_tcp
-{
-	u_int16_t spts[2];			/* Source port range. */
-	u_int16_t dpts[2];			/* Destination port range. */
-	u_int8_t option;			/* TCP Option iff non-zero*/
-	u_int8_t flg_mask;			/* TCP flags mask byte */
-	u_int8_t flg_cmp;			/* TCP flags compare byte */
-	u_int8_t invflags;			/* Inverse flags */
-};
+#define IPT_CONTINUE XT_CONTINUE
+#define IPT_RETURN XT_RETURN
 
-/* Values for "inv" field in struct ipt_tcp. */
-#define IPT_TCP_INV_SRCPT	0x01	/* Invert the sense of source ports. */
-#define IPT_TCP_INV_DSTPT	0x02	/* Invert the sense of dest ports. */
-#define IPT_TCP_INV_FLAGS	0x04	/* Invert the sense of TCP flags. */
-#define IPT_TCP_INV_OPTION	0x08	/* Invert the sense of option test. */
-#define IPT_TCP_INV_MASK	0x0F	/* All possible flags. */
+#include <linux/netfilter/xt_tcpudp.h>
+#define ipt_udp xt_udp
+#define ipt_tcp xt_tcp
 
-/* UDP matching stuff */
-struct ipt_udp
-{
-	u_int16_t spts[2];			/* Source port range. */
-	u_int16_t dpts[2];			/* Destination port range. */
-	u_int8_t invflags;			/* Inverse flags */
-};
+#define IPT_TCP_INV_SRCPT	XT_TCP_INV_SRCPT
+#define IPT_TCP_INV_DSTPT	XT_TCP_INV_DSTPT
+#define IPT_TCP_INV_FLAGS	XT_TCP_INV_FLAGS
+#define IPT_TCP_INV_OPTION	XT_TCP_INV_OPTION
+#define IPT_TCP_INV_MASK	XT_TCP_INV_MASK
 
-/* Values for "invflags" field in struct ipt_udp. */
-#define IPT_UDP_INV_SRCPT	0x01	/* Invert the sense of source ports. */
-#define IPT_UDP_INV_DSTPT	0x02	/* Invert the sense of dest ports. */
-#define IPT_UDP_INV_MASK	0x03	/* All possible flags. */
+#define IPT_UDP_INV_SRCPT	XT_UDP_INV_SRCPT
+#define IPT_UDP_INV_DSTPT	XT_UDP_INV_DSTPT
+#define IPT_UDP_INV_MASK	XT_UDP_INV_MASK
 
 /* ICMP matching stuff */
 struct ipt_icmp
@@ -250,25 +193,15 @@ struct ipt_replace
 	/* Information about old entries: */
 	/* Number of counters (must be equal to current number of entries). */
 	unsigned int num_counters;
-
 	/* The old entries' counters. */
-	struct ipt_counters  *counters;
+	struct xt_counters __user *counters;
 
 	/* The entries (hang off end: not really an array). */
 	struct ipt_entry entries[0];
 };
 
 /* The argument to IPT_SO_ADD_COUNTERS. */
-struct ipt_counters_info
-{
-	/* Which table. */
-	char name[IPT_TABLE_MAXNAMELEN];
-
-	unsigned int num_counters;
-
-	/* The counters (actually `number' of these). */
-	struct ipt_counters counters[0];
-};
+#define ipt_counters_info xt_counters_info
 
 /* The argument to IPT_SO_GET_ENTRIES. */
 struct ipt_get_entries
@@ -283,19 +216,10 @@ struct ipt_get_entries
 	struct ipt_entry entrytable[0];
 };
 
-/* The argument to IPT_SO_GET_REVISION_*.  Returns highest revision
- * kernel supports, if >= revision. */
-struct ipt_get_revision
-{
-	char name[IPT_FUNCTION_MAXNAMELEN-1];
-
-	u_int8_t revision;
-};
-
 /* Standard return verdict, or do jump. */
-#define IPT_STANDARD_TARGET ""
+#define IPT_STANDARD_TARGET XT_STANDARD_TARGET
 /* Error verdict. */
-#define IPT_ERROR_TARGET "ERROR"
+#define IPT_ERROR_TARGET XT_ERROR_TARGET
 
 /* Helper functions */
 static __inline__ struct ipt_entry_target *
@@ -343,4 +267,74 @@ ({								\
 /*
  *	Main firewall chains definitions and global var's definitions.
  */
+#ifdef __KERNEL__
+
+#include <linux/init.h>
+extern void ipt_init(void) __init;
+
+#define ipt_register_target(tgt) 	\
+({	(tgt)->family = AF_INET;	\
+ 	xt_register_target(tgt); })
+#define ipt_unregister_target(tgt) xt_unregister_target(tgt)
+
+#define ipt_register_match(mtch) 	\
+({	(mtch)->family = AF_INET;	\
+	xt_register_match(mtch); })
+#define ipt_unregister_match(mtch) xt_unregister_match(mtch)
+
+//#define ipt_register_table(tbl, repl) xt_register_table(AF_INET, tbl, repl)
+//#define ipt_unregister_table(tbl) xt_unregister_table(AF_INET, tbl)
+
+extern int ipt_register_table(struct ipt_table *table,
+			      const struct ipt_replace *repl);
+extern void ipt_unregister_table(struct ipt_table *table);
+
+/* net/sched/ipt.c: Gimme access to your targets!  Gets target->me. */
+extern struct ipt_target *ipt_find_target(const char *name, u8 revision);
+
+/* Standard entry. */
+struct ipt_standard
+{
+	struct ipt_entry entry;
+	struct ipt_standard_target target;
+};
+
+struct ipt_error_target
+{
+	struct ipt_entry_target target;
+	char errorname[IPT_FUNCTION_MAXNAMELEN];
+};
+
+struct ipt_error
+{
+	struct ipt_entry entry;
+	struct ipt_error_target target;
+};
+
+extern unsigned int ipt_do_table(struct sk_buff **pskb,
+				 unsigned int hook,
+				 const struct net_device *in,
+				 const struct net_device *out,
+				 struct ipt_table *table);
+
+#define IPT_ALIGN(s) XT_ALIGN(s)
+
+#ifdef CONFIG_COMPAT
+#include <net/compat.h>
+
+struct compat_ipt_entry
+{
+	struct ipt_ip ip;
+	compat_uint_t nfcache;
+	u_int16_t target_offset;
+	u_int16_t next_offset;
+	compat_uint_t comefrom;
+	struct compat_xt_counters counters;
+	unsigned char elems[0];
+};
+
+#define COMPAT_IPT_ALIGN(s) 	COMPAT_XT_ALIGN(s)
+
+#endif /* CONFIG_COMPAT */
+#endif /*__KERNEL__*/
 #endif /* _IPTABLES_H */
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index a4ad737..6641162 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -21,6 +21,8 @@ #define NETLINK_IP6_FW		13
 #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
 #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
 #define NETLINK_GENERIC		16
+/* leave room for NETLINK_DM (DM Events) */
+#define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
 
 #define MAX_LINKS 32		
 
@@ -130,5 +132,112 @@ #define NLA_ALIGNTO		4
 #define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
 #define NLA_HDRLEN		((int) NLA_ALIGN(sizeof(struct nlattr)))
 
+#ifdef __KERNEL__
+
+#include <linux/capability.h>
+#include <linux/skbuff.h>
+
+struct netlink_skb_parms
+{
+	struct ucred		creds;		/* Skb credentials	*/
+	__u32			pid;
+	__u32			dst_pid;
+	__u32			dst_group;
+	kernel_cap_t		eff_cap;
+	__u32			loginuid;	/* Login (audit) uid */
+	__u32			sid;		/* SELinux security id */
+};
+
+#define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
+#define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
+
+
+extern struct sock *netlink_kernel_create(int unit, unsigned int groups, void (*input)(struct sock *sk, int len), struct module *module);
+extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
+extern int netlink_has_listeners(struct sock *sk, unsigned int group);
+extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
+extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
+			     __u32 group, gfp_t allocation);
+extern void netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
+extern int netlink_register_notifier(struct notifier_block *nb);
+extern int netlink_unregister_notifier(struct notifier_block *nb);
+
+/* finegrained unicast helpers: */
+struct sock *netlink_getsockbyfilp(struct file *filp);
+int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
+		long timeo, struct sock *ssk);
+void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
+int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol);
+
+/*
+ *	skb should fit one page. This choice is good for headerless malloc.
+ */
+#define NLMSG_GOODORDER 0
+#define NLMSG_GOODSIZE (SKB_MAX_ORDER(0, NLMSG_GOODORDER))
+
+
+struct netlink_callback
+{
+	struct sk_buff	*skb;
+	struct nlmsghdr	*nlh;
+	int		(*dump)(struct sk_buff * skb, struct netlink_callback *cb);
+	int		(*done)(struct netlink_callback *cb);
+	int		family;
+	long		args[5];
+};
+
+struct netlink_notify
+{
+	int pid;
+	int protocol;
+};
+
+static __inline__ struct nlmsghdr *
+__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
+{
+	struct nlmsghdr *nlh;
+	int size = NLMSG_LENGTH(len);
+
+	nlh = (struct nlmsghdr*)skb_put(skb, NLMSG_ALIGN(size));
+	nlh->nlmsg_type = type;
+	nlh->nlmsg_len = size;
+	nlh->nlmsg_flags = flags;
+	nlh->nlmsg_pid = pid;
+	nlh->nlmsg_seq = seq;
+	memset(NLMSG_DATA(nlh) + len, 0, NLMSG_ALIGN(size) - size);
+	return nlh;
+}
+
+#define NLMSG_NEW(skb, pid, seq, type, len, flags) \
+({	if (skb_tailroom(skb) < (int)NLMSG_SPACE(len)) \
+		goto nlmsg_failure; \
+	__nlmsg_put(skb, pid, seq, type, len, flags); })
+
+#define NLMSG_PUT(skb, pid, seq, type, len) \
+	NLMSG_NEW(skb, pid, seq, type, len, 0)
+
+#define NLMSG_NEW_ANSWER(skb, cb, type, len, flags) \
+	NLMSG_NEW(skb, NETLINK_CB((cb)->skb).pid, \
+		  (cb)->nlh->nlmsg_seq, type, len, flags)
+
+#define NLMSG_END(skb, nlh) \
+({	(nlh)->nlmsg_len = (skb)->tail - (unsigned char *) (nlh); \
+	(skb)->len; })
+
+#define NLMSG_CANCEL(skb, nlh) \
+({	skb_trim(skb, (unsigned char *) (nlh) - (skb)->data); \
+	-1; })
+
+extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
+			      struct nlmsghdr *nlh,
+			      int (*dump)(struct sk_buff *skb, struct netlink_callback*),
+			      int (*done)(struct netlink_callback*));
+
+
+#define NL_NONROOT_RECV 0x1
+#define NL_NONROOT_SEND 0x2
+extern void netlink_set_nonroot(int protocol, unsigned flag);
+
+#endif /* __KERNEL__ */
 
 #endif	/* __LINUX_NETLINK_H */
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index bd2c5a2..c3f01b3 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -305,6 +305,7 @@ enum
 	TCA_FW_POLICE,
 	TCA_FW_INDEV, /*  used by CONFIG_NET_CLS_IND */
 	TCA_FW_ACT, /* used by CONFIG_NET_CLS_ACT */
+	TCA_FW_MASK,
 	__TCA_FW_MAX
 };
 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 1ee3a56..3a18add 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -2,6 +2,7 @@ #ifndef __LINUX_RTNETLINK_H
 #define __LINUX_RTNETLINK_H
 
 #include <linux/netlink.h>
+#include <linux/if_link.h>
 
 /****
  *		Routing/neighbour discovery messages.
@@ -238,10 +239,8 @@ enum rt_class_t
 	RT_TABLE_DEFAULT=253,
 	RT_TABLE_MAIN=254,
 	RT_TABLE_LOCAL=255,
-	__RT_TABLE_MAX
+	RT_TABLE_MAX=0xFFFFFFFF
 };
-#define RT_TABLE_MAX (__RT_TABLE_MAX - 1)
-
 
 
 /* Routing message attributes */
@@ -384,226 +383,6 @@ struct rta_session
 	} u;
 };
 
-
-/*********************************************************
- *		Interface address.
- ****/
-
-struct ifaddrmsg
-{
-	unsigned char	ifa_family;
-	unsigned char	ifa_prefixlen;	/* The prefix length		*/
-	unsigned char	ifa_flags;	/* Flags			*/
-	unsigned char	ifa_scope;	/* See above			*/
-	int		ifa_index;	/* Link index			*/
-};
-
-enum
-{
-	IFA_UNSPEC,
-	IFA_ADDRESS,
-	IFA_LOCAL,
-	IFA_LABEL,
-	IFA_BROADCAST,
-	IFA_ANYCAST,
-	IFA_CACHEINFO,
-	IFA_MULTICAST,
-	__IFA_MAX
-};
-
-#define IFA_MAX (__IFA_MAX - 1)
-
-/* ifa_flags */
-
-#define IFA_F_SECONDARY		0x01
-#define IFA_F_TEMPORARY		IFA_F_SECONDARY
-
-#define IFA_F_DEPRECATED	0x20
-#define IFA_F_TENTATIVE		0x40
-#define IFA_F_PERMANENT		0x80
-
-struct ifa_cacheinfo
-{
-	__u32	ifa_prefered;
-	__u32	ifa_valid;
-	__u32	cstamp; /* created timestamp, hundredths of seconds */
-	__u32	tstamp; /* updated timestamp, hundredths of seconds */
-};
-
-
-#define IFA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
-#define IFA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
-
-/*
-   Important comment:
-   IFA_ADDRESS is prefix address, rather than local interface address.
-   It makes no difference for normally configured broadcast interfaces,
-   but for point-to-point IFA_ADDRESS is DESTINATION address,
-   local address is supplied in IFA_LOCAL attribute.
- */
-
-/**************************************************************
- *		Neighbour discovery.
- ****/
-
-struct ndmsg
-{
-	unsigned char	ndm_family;
-	unsigned char	ndm_pad1;
-	unsigned short	ndm_pad2;
-	int		ndm_ifindex;	/* Link index			*/
-	__u16		ndm_state;
-	__u8		ndm_flags;
-	__u8		ndm_type;
-};
-
-enum
-{
-	NDA_UNSPEC,
-	NDA_DST,
-	NDA_LLADDR,
-	NDA_CACHEINFO,
-	NDA_PROBES,
-	__NDA_MAX
-};
-
-#define NDA_MAX (__NDA_MAX - 1)
-
-#define NDA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndmsg))))
-#define NDA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndmsg))
-
-/*
- *	Neighbor Cache Entry Flags
- */
-
-#define NTF_PROXY	0x08	/* == ATF_PUBL */
-#define NTF_ROUTER	0x80
-
-/*
- *	Neighbor Cache Entry States.
- */
-
-#define NUD_INCOMPLETE	0x01
-#define NUD_REACHABLE	0x02
-#define NUD_STALE	0x04
-#define NUD_DELAY	0x08
-#define NUD_PROBE	0x10
-#define NUD_FAILED	0x20
-
-/* Dummy states */
-#define NUD_NOARP	0x40
-#define NUD_PERMANENT	0x80
-#define NUD_NONE	0x00
-
-
-struct nda_cacheinfo
-{
-	__u32		ndm_confirmed;
-	__u32		ndm_used;
-	__u32		ndm_updated;
-	__u32		ndm_refcnt;
-};
-
-
-/*****************************************************************
- *		Neighbour tables specific messages.
- *
- * To retrieve the neighbour tables send RTM_GETNEIGHTBL with the
- * NLM_F_DUMP flag set. Every neighbour table configuration is
- * spread over multiple messages to avoid running into message
- * size limits on systems with many interfaces. The first message
- * in the sequence transports all not device specific data such as
- * statistics, configuration, and the default parameter set.
- * This message is followed by 0..n messages carrying device
- * specific parameter sets.
- * Although the ordering should be sufficient, NDTA_NAME can be
- * used to identify sequences. The initial message can be identified
- * by checking for NDTA_CONFIG. The device specific messages do
- * not contain this TLV but have NDTPA_IFINDEX set to the
- * corresponding interface index.
- *
- * To change neighbour table attributes, send RTM_SETNEIGHTBL
- * with NDTA_NAME set. Changeable attribute include NDTA_THRESH[1-3],
- * NDTA_GC_INTERVAL, and all TLVs in NDTA_PARMS unless marked
- * otherwise. Device specific parameter sets can be changed by
- * setting NDTPA_IFINDEX to the interface index of the corresponding
- * device.
- ****/
-
-struct ndt_stats
-{
-	__u64		ndts_allocs;
-	__u64		ndts_destroys;
-	__u64		ndts_hash_grows;
-	__u64		ndts_res_failed;
-	__u64		ndts_lookups;
-	__u64		ndts_hits;
-	__u64		ndts_rcv_probes_mcast;
-	__u64		ndts_rcv_probes_ucast;
-	__u64		ndts_periodic_gc_runs;
-	__u64		ndts_forced_gc_runs;
-};
-
-enum {
-	NDTPA_UNSPEC,
-	NDTPA_IFINDEX,			/* u32, unchangeable */
-	NDTPA_REFCNT,			/* u32, read-only */
-	NDTPA_REACHABLE_TIME,		/* u64, read-only, msecs */
-	NDTPA_BASE_REACHABLE_TIME,	/* u64, msecs */
-	NDTPA_RETRANS_TIME,		/* u64, msecs */
-	NDTPA_GC_STALETIME,		/* u64, msecs */
-	NDTPA_DELAY_PROBE_TIME,		/* u64, msecs */
-	NDTPA_QUEUE_LEN,		/* u32 */
-	NDTPA_APP_PROBES,		/* u32 */
-	NDTPA_UCAST_PROBES,		/* u32 */
-	NDTPA_MCAST_PROBES,		/* u32 */
-	NDTPA_ANYCAST_DELAY,		/* u64, msecs */
-	NDTPA_PROXY_DELAY,		/* u64, msecs */
-	NDTPA_PROXY_QLEN,		/* u32 */
-	NDTPA_LOCKTIME,			/* u64, msecs */
-	__NDTPA_MAX
-};
-#define NDTPA_MAX (__NDTPA_MAX - 1)
-
-struct ndtmsg
-{
-	__u8		ndtm_family;
-	__u8		ndtm_pad1;
-	__u16		ndtm_pad2;
-};
-
-struct ndt_config
-{
-	__u16		ndtc_key_len;
-	__u16		ndtc_entry_size;
-	__u32		ndtc_entries;
-	__u32		ndtc_last_flush;	/* delta to now in msecs */
-	__u32		ndtc_last_rand;		/* delta to now in msecs */
-	__u32		ndtc_hash_rnd;
-	__u32		ndtc_hash_mask;
-	__u32		ndtc_hash_chain_gc;
-	__u32		ndtc_proxy_qlen;
-};
-
-enum {
-	NDTA_UNSPEC,
-	NDTA_NAME,			/* char *, unchangeable */
-	NDTA_THRESH1,			/* u32 */
-	NDTA_THRESH2,			/* u32 */
-	NDTA_THRESH3,			/* u32 */
-	NDTA_CONFIG,			/* struct ndt_config, read-only */
-	NDTA_PARMS,			/* nested TLV NDTPA_* */
-	NDTA_STATS,			/* struct ndt_stats, read-only */
-	NDTA_GC_INTERVAL,		/* u64, msecs */
-	__NDTA_MAX
-};
-#define NDTA_MAX (__NDTA_MAX - 1)
-
-#define NDTA_RTA(r) ((struct rtattr*)(((char*)(r)) + \
-		     NLMSG_ALIGN(sizeof(struct ndtmsg))))
-#define NDTA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndtmsg))
-
-
 /****
  *		General form of address family dependent message.
  ****/
@@ -664,138 +443,6 @@ struct prefix_cacheinfo
 	__u32	valid_time;
 };
 
-/* The struct should be in sync with struct net_device_stats */
-struct rtnl_link_stats
-{
-	__u32	rx_packets;		/* total packets received	*/
-	__u32	tx_packets;		/* total packets transmitted	*/
-	__u32	rx_bytes;		/* total bytes received 	*/
-	__u32	tx_bytes;		/* total bytes transmitted	*/
-	__u32	rx_errors;		/* bad packets received		*/
-	__u32	tx_errors;		/* packet transmit problems	*/
-	__u32	rx_dropped;		/* no space in linux buffers	*/
-	__u32	tx_dropped;		/* no space available in linux	*/
-	__u32	multicast;		/* multicast packets received	*/
-	__u32	collisions;
-
-	/* detailed rx_errors: */
-	__u32	rx_length_errors;
-	__u32	rx_over_errors;		/* receiver ring buff overflow	*/
-	__u32	rx_crc_errors;		/* recved pkt with crc error	*/
-	__u32	rx_frame_errors;	/* recv'd frame alignment error */
-	__u32	rx_fifo_errors;		/* recv'r fifo overrun		*/
-	__u32	rx_missed_errors;	/* receiver missed packet	*/
-
-	/* detailed tx_errors */
-	__u32	tx_aborted_errors;
-	__u32	tx_carrier_errors;
-	__u32	tx_fifo_errors;
-	__u32	tx_heartbeat_errors;
-	__u32	tx_window_errors;
-	
-	/* for cslip etc */
-	__u32	rx_compressed;
-	__u32	tx_compressed;
-};
-
-/* The struct should be in sync with struct ifmap */
-struct rtnl_link_ifmap
-{
-	__u64	mem_start;
-	__u64	mem_end;
-	__u64	base_addr;
-	__u16	irq;
-	__u8	dma;
-	__u8	port;
-};
-
-enum
-{
-	IFLA_UNSPEC,
-	IFLA_ADDRESS,
-	IFLA_BROADCAST,
-	IFLA_IFNAME,
-	IFLA_MTU,
-	IFLA_LINK,
-	IFLA_QDISC,
-	IFLA_STATS,
-	IFLA_COST,
-#define IFLA_COST IFLA_COST
-	IFLA_PRIORITY,
-#define IFLA_PRIORITY IFLA_PRIORITY
-	IFLA_MASTER,
-#define IFLA_MASTER IFLA_MASTER
-	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
-#define IFLA_WIRELESS IFLA_WIRELESS
-	IFLA_PROTINFO,		/* Protocol specific information for a link */
-#define IFLA_PROTINFO IFLA_PROTINFO
-	IFLA_TXQLEN,
-#define IFLA_TXQLEN IFLA_TXQLEN
-	IFLA_MAP,
-#define IFLA_MAP IFLA_MAP
-	IFLA_WEIGHT,
-#define IFLA_WEIGHT IFLA_WEIGHT
-	IFLA_OPERSTATE,
-	IFLA_LINKMODE,
-	__IFLA_MAX
-};
-
-
-#define IFLA_MAX (__IFLA_MAX - 1)
-
-#define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
-#define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
-
-/* ifi_flags.
-
-   IFF_* flags.
-
-   The only change is:
-   IFF_LOOPBACK, IFF_BROADCAST and IFF_POINTOPOINT are
-   more not changeable by user. They describe link media
-   characteristics and set by device driver.
-
-   Comments:
-   - Combination IFF_BROADCAST|IFF_POINTOPOINT is invalid
-   - If neither of these three flags are set;
-     the interface is NBMA.
-
-   - IFF_MULTICAST does not mean anything special:
-   multicasts can be used on all not-NBMA links.
-   IFF_MULTICAST means that this media uses special encapsulation
-   for multicast frames. Apparently, all IFF_POINTOPOINT and
-   IFF_BROADCAST devices are able to use multicasts too.
- */
-
-/* IFLA_LINK.
-   For usual devices it is equal ifi_index.
-   If it is a "virtual interface" (f.e. tunnel), ifi_link
-   can point to real physical interface (f.e. for bandwidth calculations),
-   or maybe 0, what means, that real media is unknown (usual
-   for IPIP tunnels, when route to endpoint is allowed to change)
- */
-
-/* Subtype attributes for IFLA_PROTINFO */
-enum
-{
-	IFLA_INET6_UNSPEC,
-	IFLA_INET6_FLAGS,	/* link flags			*/
-	IFLA_INET6_CONF,	/* sysctl parameters		*/
-	IFLA_INET6_STATS,	/* statistics			*/
-	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
-	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
-	__IFLA_INET6_MAX
-};
-
-#define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
-
-struct ifla_cacheinfo
-{
-	__u32	max_reasm_len;
-	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
-	__u32	reachable_time;
-	__u32	retrans_time;
-};
 
 /*****************************************************************
  *		Traffic control messages.
@@ -830,6 +477,7 @@ #define TCA_MAX (__TCA_MAX - 1)
 #define TCA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcmsg))))
 #define TCA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcmsg))
 
+#ifndef __KERNEL__
 /* RTnetlink multicast groups - backwards compatibility for userspace */
 #define RTMGRP_LINK		1
 #define RTMGRP_NOTIFY		2
@@ -850,6 +498,7 @@ #define RTMGRP_DECnet_IFADDR    0x1000
 #define RTMGRP_DECnet_ROUTE     0x4000
 
 #define RTMGRP_IPV6_PREFIX	0x20000
+#endif
 
 /* RTnetlink multicast groups */
 enum rtnetlink_groups {
@@ -884,10 +533,13 @@ #define RTNLGRP_DECnet_IFADDR	RTNLGRP_DE
 	RTNLGRP_NOP2,
 	RTNLGRP_DECnet_ROUTE,
 #define RTNLGRP_DECnet_ROUTE	RTNLGRP_DECnet_ROUTE
-	RTNLGRP_NOP3,
+	RTNLGRP_DECnet_RULE,
+#define RTNLGRP_DECnet_RULE	RTNLGRP_DECnet_RULE
 	RTNLGRP_NOP4,
 	RTNLGRP_IPV6_PREFIX,
 #define RTNLGRP_IPV6_PREFIX	RTNLGRP_IPV6_PREFIX
+	RTNLGRP_IPV6_RULE,
+#define RTNLGRP_IPV6_RULE	RTNLGRP_IPV6_RULE
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
@@ -906,6 +558,174 @@ #define TCAA_MAX 1
 
 /* End of information exported to user level */
 
+#ifdef __KERNEL__
+
+#include <linux/mutex.h>
+
+extern size_t rtattr_strlcpy(char *dest, const struct rtattr *rta, size_t size);
+static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
+{
+	int len = strlen(str) + 1;
+	return len > rta->rta_len || memcmp(RTA_DATA(rta), str, len);
+}
+
+extern int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len);
+
+#define rtattr_parse_nested(tb, max, rta) \
+	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
+
+struct rtnetlink_link
+{
+	int (*doit)(struct sk_buff *, struct nlmsghdr*, void *attr);
+	int (*dumpit)(struct sk_buff *, struct netlink_callback *cb);
+};
+
+extern struct rtnetlink_link * rtnetlink_links[NPROTO];
+extern int rtnetlink_send(struct sk_buff *skb, u32 pid, u32 group, int echo);
+extern int rtnl_unicast(struct sk_buff *skb, u32 pid);
+extern int rtnl_notify(struct sk_buff *skb, u32 pid, u32 group,
+		       struct nlmsghdr *nlh, gfp_t flags);
+extern void rtnl_set_sk_err(u32 group, int error);
+extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
+
+extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
+
+#define RTA_PUT(skb, attrtype, attrlen, data) \
+({	if (unlikely(skb_tailroom(skb) < (int)RTA_SPACE(attrlen))) \
+		 goto rtattr_failure; \
+   	__rta_fill(skb, attrtype, attrlen, data); }) 
+
+#define RTA_APPEND(skb, attrlen, data) \
+({	if (unlikely(skb_tailroom(skb) < (int)(attrlen))) \
+		goto rtattr_failure; \
+	memcpy(skb_put(skb, attrlen), data, attrlen); })
+
+#define RTA_PUT_NOHDR(skb, attrlen, data) \
+({	RTA_APPEND(skb, RTA_ALIGN(attrlen), data); \
+	memset(skb->tail - (RTA_ALIGN(attrlen) - attrlen), 0, \
+	       RTA_ALIGN(attrlen) - attrlen); })
+
+#define RTA_PUT_U8(skb, attrtype, value) \
+({	u8 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u8), &_tmp); })
+
+#define RTA_PUT_U16(skb, attrtype, value) \
+({	u16 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u16), &_tmp); })
+
+#define RTA_PUT_U32(skb, attrtype, value) \
+({	u32 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u32), &_tmp); })
+
+#define RTA_PUT_U64(skb, attrtype, value) \
+({	u64 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u64), &_tmp); })
+
+#define RTA_PUT_SECS(skb, attrtype, value) \
+	RTA_PUT_U64(skb, attrtype, (value) / HZ)
+
+#define RTA_PUT_MSECS(skb, attrtype, value) \
+	RTA_PUT_U64(skb, attrtype, jiffies_to_msecs(value))
+
+#define RTA_PUT_STRING(skb, attrtype, value) \
+	RTA_PUT(skb, attrtype, strlen(value) + 1, value)
+
+#define RTA_PUT_FLAG(skb, attrtype) \
+	RTA_PUT(skb, attrtype, 0, NULL);
+
+#define RTA_NEST(skb, type) \
+({	struct rtattr *__start = (struct rtattr *) (skb)->tail; \
+	RTA_PUT(skb, type, 0, NULL); \
+	__start;  })
+
+#define RTA_NEST_END(skb, start) \
+({	(start)->rta_len = ((skb)->tail - (unsigned char *) (start)); \
+	(skb)->len; })
+
+#define RTA_NEST_CANCEL(skb, start) \
+({	if (start) \
+		skb_trim(skb, (unsigned char *) (start) - (skb)->data); \
+	-1; })
+
+#define RTA_GET_U8(rta) \
+({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u8)) \
+		goto rtattr_failure; \
+	*(u8 *) RTA_DATA(rta); })
+
+#define RTA_GET_U16(rta) \
+({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u16)) \
+		goto rtattr_failure; \
+	*(u16 *) RTA_DATA(rta); })
+
+#define RTA_GET_U32(rta) \
+({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u32)) \
+		goto rtattr_failure; \
+	*(u32 *) RTA_DATA(rta); })
+
+#define RTA_GET_U64(rta) \
+({	u64 _tmp; \
+	if (!rta || RTA_PAYLOAD(rta) < sizeof(u64)) \
+		goto rtattr_failure; \
+	memcpy(&_tmp, RTA_DATA(rta), sizeof(_tmp)); \
+	_tmp; })
+
+#define RTA_GET_FLAG(rta) (!!(rta))
+
+#define RTA_GET_SECS(rta) ((unsigned long) RTA_GET_U64(rta) * HZ)
+#define RTA_GET_MSECS(rta) (msecs_to_jiffies((unsigned long) RTA_GET_U64(rta)))
+		
+static inline struct rtattr *
+__rta_reserve(struct sk_buff *skb, int attrtype, int attrlen)
+{
+	struct rtattr *rta;
+	int size = RTA_LENGTH(attrlen);
+
+	rta = (struct rtattr*)skb_put(skb, RTA_ALIGN(size));
+	rta->rta_type = attrtype;
+	rta->rta_len = size;
+	memset(RTA_DATA(rta) + attrlen, 0, RTA_ALIGN(size) - size);
+	return rta;
+}
+
+#define __RTA_PUT(skb, attrtype, attrlen) \
+({ 	if (unlikely(skb_tailroom(skb) < (int)RTA_SPACE(attrlen))) \
+		goto rtattr_failure; \
+   	__rta_reserve(skb, attrtype, attrlen); })
+
+extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
+
+/* RTNL is used as a global lock for all changes to network configuration  */
+extern void rtnl_lock(void);
+extern void rtnl_unlock(void);
+extern int rtnl_trylock(void);
+
+extern void rtnetlink_init(void);
+extern void __rtnl_unlock(void);
+
+#define ASSERT_RTNL() do { \
+	if (unlikely(rtnl_trylock())) { \
+		rtnl_unlock(); \
+		printk(KERN_ERR "RTNL: assertion failed at %s (%d)\n", \
+		       __FILE__,  __LINE__); \
+		dump_stack(); \
+	} \
+} while(0)
+
+#define BUG_TRAP(x) do { \
+	if (unlikely(!(x))) { \
+		printk(KERN_ERR "KERNEL: assertion (%s) failed at %s (%d)\n", \
+			#x,  __FILE__ , __LINE__); \
+	} \
+} while(0)
+
+static inline u32 rtm_get_table(struct rtattr **rta, u8 table)
+{
+	return RTA_GET_U32(rta[RTA_TABLE-1]);
+rtattr_failure:
+	return table;
+}
+
+#endif /* __KERNEL__ */
 
 
 #endif	/* __LINUX_RTNETLINK_H */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 33bfe70..3614090 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -103,7 +103,9 @@ #define CMSG_OK(mhdr, cmsg) ((cmsg)->cms
  *	This mess will go away with glibc
  */
  
-#if    defined(__GNUC__) 
+#ifdef __KERNEL__
+#define __KINLINE static inline
+#elif  defined(__GNUC__) 
 #define __KINLINE static __inline__
 #elif defined(__cplusplus)
 #define __KINLINE static inline
@@ -283,5 +285,21 @@ #define SOL_TIPC	271
 /* IPX options */
 #define IPX_TYPE	1
 
+#ifdef __KERNEL__
+extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
+extern int memcpy_fromiovecend(unsigned char *kdata, struct iovec *iov, 
+				int offset, int len);
+extern int csum_partial_copy_fromiovecend(unsigned char *kdata, 
+					  struct iovec *iov, 
+					  int offset, 
+					  unsigned int len, int *csump);
+
+extern int verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode);
+extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
+extern int move_addr_to_user(void *kaddr, int klen, void __user *uaddr, int __user *ulen);
+extern int move_addr_to_kernel(void __user *uaddr, int ulen, void *kaddr);
+extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
+
+#endif
 #endif /* not kernel and not glibc */
 #endif /* _LINUX_SOCKET_H */
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b4d74eb..2d36f6d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -21,10 +21,10 @@ #include <linux/types.h>
 #include <asm/byteorder.h>
 
 struct tcphdr {
-	__u16	source;
-	__u16	dest;
-	__u32	seq;
-	__u32	ack_seq;
+	__be16	source;
+	__be16	dest;
+	__be32	seq;
+	__be32	ack_seq;
 #if defined(__LITTLE_ENDIAN_BITFIELD)
 	__u16	res1:4,
 		doff:4,
@@ -50,9 +50,9 @@ #elif defined(__BIG_ENDIAN_BITFIELD)
 #else
 #error	"Adjust your <asm/byteorder.h> defines"
 #endif	
-	__u16	window;
-	__u16	check;
-	__u16	urg_ptr;
+	__be16	window;
+	__be16	check;
+	__be16	urg_ptr;
 };
 
 /*
@@ -62,7 +62,7 @@ #endif	
  */
 union tcp_word_hdr { 
 	struct tcphdr hdr;
-	__u32 		  words[5];
+	__be32 		  words[5];
 }; 
 
 #define tcp_flag_word(tp) ( ((union tcp_word_hdr *)(tp))->words [3]) 
@@ -157,5 +157,233 @@ struct tcp_info
 	__u32	tcpi_total_retrans;
 };
 
+#ifdef __KERNEL__
+
+#include <linux/skbuff.h>
+#include <linux/dmaengine.h>
+#include <net/sock.h>
+#include <net/inet_connection_sock.h>
+#include <net/inet_timewait_sock.h>
+
+/* This defines a selective acknowledgement block. */
+struct tcp_sack_block_wire {
+	__be32	start_seq;
+	__be32	end_seq;
+};
+
+struct tcp_sack_block {
+	__u32	start_seq;
+	__u32	end_seq;
+};
+
+struct tcp_options_received {
+/*	PAWS/RTTM data	*/
+	long	ts_recent_stamp;/* Time we stored ts_recent (for aging) */
+	__u32	ts_recent;	/* Time stamp to echo next		*/
+	__u32	rcv_tsval;	/* Time stamp value             	*/
+	__u32	rcv_tsecr;	/* Time stamp echo reply        	*/
+	__u16 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
+		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
+		dsack : 1,	/* D-SACK is scheduled			*/
+		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
+		sack_ok : 4,	/* SACK seen on SYN packet		*/
+		snd_wscale : 4,	/* Window scaling received from sender	*/
+		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
+/*	SACKs data	*/
+	__u8	eff_sacks;	/* Size of SACK array to send with next packet */
+	__u8	num_sacks;	/* Number of SACK blocks		*/
+	__u16	user_mss;  	/* mss requested by user in ioctl */
+	__u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
+};
+
+struct tcp_request_sock {
+	struct inet_request_sock req;
+	__u32			 rcv_isn;
+	__u32			 snt_isn;
+};
+
+static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
+{
+	return (struct tcp_request_sock *)req;
+}
+
+struct tcp_sock {
+	/* inet_connection_sock has to be the first member of tcp_sock */
+	struct inet_connection_sock	inet_conn;
+	int	tcp_header_len;	/* Bytes of tcp header to send		*/
+
+/*
+ *	Header prediction flags
+ *	0x5?10 << 16 + snd_wnd in net byte order
+ */
+	__be32	pred_flags;
+
+/*
+ *	RFC793 variables by their proper names. This means you can
+ *	read the code and the spec side by side (and laugh ...)
+ *	See RFC793 and RFC1122. The RFC writes these in capitals.
+ */
+ 	__u32	rcv_nxt;	/* What we want to receive next 	*/
+ 	__u32	snd_nxt;	/* Next sequence we send		*/
+
+ 	__u32	snd_una;	/* First byte we want an ack for	*/
+ 	__u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
+	__u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
+	__u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
+
+	/* Data for direct copy to user */
+	struct {
+		struct sk_buff_head	prequeue;
+		struct task_struct	*task;
+		struct iovec		*iov;
+		int			memory;
+		int			len;
+#ifdef CONFIG_NET_DMA
+		/* members for async copy */
+		struct dma_chan		*dma_chan;
+		int			wakeup;
+		struct dma_pinned_list	*pinned_list;
+		dma_cookie_t		dma_cookie;
+#endif
+	} ucopy;
+
+	__u32	snd_wl1;	/* Sequence for window update		*/
+	__u32	snd_wnd;	/* The window we expect to receive	*/
+	__u32	max_window;	/* Maximal window ever seen from peer	*/
+	__u32	mss_cache;	/* Cached effective mss, not including SACKS */
+	__u16	xmit_size_goal;	/* Goal for segmenting output packets	*/
+	/* XXX Two bytes hole, try to pack */
+
+	__u32	window_clamp;	/* Maximal window to advertise		*/
+	__u32	rcv_ssthresh;	/* Current window clamp			*/
+
+	__u32	frto_highmark;	/* snd_nxt when RTO occurred */
+	__u8	reordering;	/* Packet reordering metric.		*/
+	__u8	frto_counter;	/* Number of new acks after RTO */
+	__u8	nonagle;	/* Disable Nagle algorithm?             */
+	__u8	keepalive_probes; /* num of allowed keep alive probes	*/
+
+/* RTT measurement */
+	__u32	srtt;		/* smoothed round trip time << 3	*/
+	__u32	mdev;		/* medium deviation			*/
+	__u32	mdev_max;	/* maximal mdev for the last rtt period	*/
+	__u32	rttvar;		/* smoothed mdev_max			*/
+	__u32	rtt_seq;	/* sequence number to update rttvar	*/
+
+	__u32	packets_out;	/* Packets which are "in flight"	*/
+	__u32	left_out;	/* Packets which leaved network	*/
+	__u32	retrans_out;	/* Retransmitted packets out		*/
+/*
+ *      Options received (usually on last packet, some only on SYN packets).
+ */
+	struct tcp_options_received rx_opt;
+
+/*
+ *	Slow start and congestion control (see also Nagle, and Karn & Partridge)
+ */
+ 	__u32	snd_ssthresh;	/* Slow start size threshold		*/
+ 	__u32	snd_cwnd;	/* Sending congestion window		*/
+ 	__u16	snd_cwnd_cnt;	/* Linear increase counter		*/
+	__u16	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
+	__u32	snd_cwnd_used;
+	__u32	snd_cwnd_stamp;
+
+	struct sk_buff_head	out_of_order_queue; /* Out of order segments go here */
+
+ 	__u32	rcv_wnd;	/* Current receiver window		*/
+	__u32	rcv_wup;	/* rcv_nxt on last window update sent	*/
+	__u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
+	__u32	pushed_seq;	/* Last pushed seq, required to talk to windows */
+	__u32	copied_seq;	/* Head of yet unread data		*/
+
+/*	SACKs data	*/
+	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */
+	struct tcp_sack_block selective_acks[4]; /* The SACKS themselves*/
+
+	struct tcp_sack_block recv_sack_cache[4];
+
+	/* from STCP, retrans queue hinting */
+	struct sk_buff* lost_skb_hint;
+
+	struct sk_buff *scoreboard_skb_hint;
+	struct sk_buff *retransmit_skb_hint;
+	struct sk_buff *forward_skb_hint;
+	struct sk_buff *fastpath_skb_hint;
+
+	int     fastpath_cnt_hint;
+	int     lost_cnt_hint;
+	int     retransmit_cnt_hint;
+	int     forward_cnt_hint;
+
+	__u16	advmss;		/* Advertised MSS			*/
+	__u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
+	__u32	lost_out;	/* Lost packets			*/
+	__u32	sacked_out;	/* SACK'd packets			*/
+	__u32	fackets_out;	/* FACK'd packets			*/
+	__u32	high_seq;	/* snd_nxt at onset of congestion	*/
+
+	__u32	retrans_stamp;	/* Timestamp of the last retransmit,
+				 * also used in SYN-SENT to remember stamp of
+				 * the first SYN. */
+	__u32	undo_marker;	/* tracking retrans started here. */
+	int	undo_retrans;	/* number of undoable retransmissions. */
+	__u32	urg_seq;	/* Seq of received urgent pointer */
+	__u16	urg_data;	/* Saved octet of OOB data and control flags */
+	__u8	urg_mode;	/* In urgent mode		*/
+	__u8	ecn_flags;	/* ECN status bits.			*/
+	__u32	snd_up;		/* Urgent pointer		*/
+
+	__u32	total_retrans;	/* Total retransmits for entire connection */
+	__u32	bytes_acked;	/* Appropriate Byte Counting - RFC3465 */
+
+	unsigned int		keepalive_time;	  /* time before keep alive takes place */
+	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
+	int			linger2;
+
+	unsigned long last_synq_overflow; 
+
+	__u32	tso_deferred;
+
+/* Receiver side RTT estimation */
+	struct {
+		__u32	rtt;
+		__u32	seq;
+		__u32	time;
+	} rcv_rtt_est;
+
+/* Receiver queue space */
+	struct {
+		int	space;
+		__u32	seq;
+		__u32	time;
+	} rcvq_space;
+
+/* TCP-specific MTU probe information. */
+	struct {
+		__u32		  probe_seq_start;
+		__u32		  probe_seq_end;
+	} mtu_probe;
+};
+
+static inline struct tcp_sock *tcp_sk(const struct sock *sk)
+{
+	return (struct tcp_sock *)sk;
+}
+
+struct tcp_timewait_sock {
+	struct inet_timewait_sock tw_sk;
+	__u32			  tw_rcv_nxt;
+	__u32			  tw_snd_nxt;
+	__u32			  tw_rcv_wnd;
+	__u32			  tw_ts_recent;
+	long			  tw_ts_recent_stamp;
+};
+
+static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
+{
+	return (struct tcp_timewait_sock *)sk;
+}
+
+#endif
 
 #endif	/* _LINUX_TCP_H */
diff --git a/include/linux/types.h b/include/linux/types.h
new file mode 100644
index 0000000..750f085
--- /dev/null
+++ b/include/linux/types.h
@@ -0,0 +1,202 @@
+#ifndef _LINUX_TYPES_H
+#define _LINUX_TYPES_H
+
+#ifdef	__KERNEL__
+
+#define BITS_TO_LONGS(bits) \
+	(((bits)+BITS_PER_LONG-1)/BITS_PER_LONG)
+#define DECLARE_BITMAP(name,bits) \
+	unsigned long name[BITS_TO_LONGS(bits)]
+
+#define BITS_PER_BYTE 8
+#endif
+
+#include <linux/posix_types.h>
+#include <asm/types.h>
+
+#ifndef __KERNEL_STRICT_NAMES
+
+typedef __u32 __kernel_dev_t;
+
+typedef __kernel_fd_set		fd_set;
+typedef __kernel_dev_t		dev_t;
+typedef __kernel_ino_t		ino_t;
+typedef __kernel_mode_t		mode_t;
+typedef __kernel_nlink_t	nlink_t;
+typedef __kernel_off_t		off_t;
+typedef __kernel_pid_t		pid_t;
+typedef __kernel_daddr_t	daddr_t;
+typedef __kernel_key_t		key_t;
+typedef __kernel_suseconds_t	suseconds_t;
+typedef __kernel_timer_t	timer_t;
+typedef __kernel_clockid_t	clockid_t;
+typedef __kernel_mqd_t		mqd_t;
+
+#ifdef __KERNEL__
+typedef _Bool			bool;
+
+typedef __kernel_uid32_t	uid_t;
+typedef __kernel_gid32_t	gid_t;
+typedef __kernel_uid16_t        uid16_t;
+typedef __kernel_gid16_t        gid16_t;
+
+#ifdef CONFIG_UID16
+/* This is defined by include/asm-{arch}/posix_types.h */
+typedef __kernel_old_uid_t	old_uid_t;
+typedef __kernel_old_gid_t	old_gid_t;
+#endif /* CONFIG_UID16 */
+
+/* libc5 includes this file to define uid_t, thus uid_t can never change
+ * when it is included by non-kernel code
+ */
+#else
+typedef __kernel_uid_t		uid_t;
+typedef __kernel_gid_t		gid_t;
+#endif /* __KERNEL__ */
+
+#if defined(__GNUC__) && !defined(__STRICT_ANSI__)
+typedef __kernel_loff_t		loff_t;
+#endif
+
+/*
+ * The following typedefs are also protected by individual ifdefs for
+ * historical reasons:
+ */
+#ifndef _SIZE_T
+#define _SIZE_T
+typedef __kernel_size_t		size_t;
+#endif
+
+#ifndef _SSIZE_T
+#define _SSIZE_T
+typedef __kernel_ssize_t	ssize_t;
+#endif
+
+#ifndef _PTRDIFF_T
+#define _PTRDIFF_T
+typedef __kernel_ptrdiff_t	ptrdiff_t;
+#endif
+
+#ifndef _TIME_T
+#define _TIME_T
+typedef __kernel_time_t		time_t;
+#endif
+
+#ifndef _CLOCK_T
+#define _CLOCK_T
+typedef __kernel_clock_t	clock_t;
+#endif
+
+#ifndef _CADDR_T
+#define _CADDR_T
+typedef __kernel_caddr_t	caddr_t;
+#endif
+
+/* bsd */
+typedef unsigned char		u_char;
+typedef unsigned short		u_short;
+typedef unsigned int		u_int;
+typedef unsigned long		u_long;
+
+/* sysv */
+typedef unsigned char		unchar;
+typedef unsigned short		ushort;
+typedef unsigned int		uint;
+typedef unsigned long		ulong;
+
+#ifndef __BIT_TYPES_DEFINED__
+#define __BIT_TYPES_DEFINED__
+
+typedef		__u8		u_int8_t;
+typedef		__s8		int8_t;
+typedef		__u16		u_int16_t;
+typedef		__s16		int16_t;
+typedef		__u32		u_int32_t;
+typedef		__s32		int32_t;
+
+#endif /* !(__BIT_TYPES_DEFINED__) */
+
+typedef		__u8		uint8_t;
+typedef		__u16		uint16_t;
+typedef		__u32		uint32_t;
+
+#if defined(__GNUC__) && !defined(__STRICT_ANSI__)
+typedef		__u64		uint64_t;
+typedef		__u64		u_int64_t;
+typedef		__s64		int64_t;
+#endif
+
+/* this is a special 64bit data type that is 8-byte aligned */
+#define aligned_u64 unsigned long long __attribute__((aligned(8)))
+
+/**
+ * The type used for indexing onto a disc or disc partition.
+ *
+ * Linux always considers sectors to be 512 bytes long independently
+ * of the devices real block size.
+ *
+ * If required, asm/types.h can override it and define
+ * HAVE_SECTOR_T
+ */
+#ifndef HAVE_SECTOR_T
+typedef unsigned long sector_t;
+#endif
+
+#ifndef HAVE_BLKCNT_T
+typedef unsigned long blkcnt_t;
+#endif
+
+/*
+ * The type of an index into the pagecache.  Use a #define so asm/types.h
+ * can override it.
+ */
+#ifndef pgoff_t
+#define pgoff_t unsigned long
+#endif
+
+#endif /* __KERNEL_STRICT_NAMES */
+
+/*
+ * Below are truly Linux-specific types that should never collide with
+ * any application/library that wants linux/types.h.
+ */
+
+#ifdef __CHECKER__
+#define __bitwise__ __attribute__((bitwise))
+#else
+#define __bitwise__
+#endif
+#ifdef __CHECK_ENDIAN__
+#define __bitwise __bitwise__
+#else
+#define __bitwise
+#endif
+
+typedef __u16 __bitwise __le16;
+typedef __u16 __bitwise __be16;
+typedef __u32 __bitwise __le32;
+typedef __u32 __bitwise __be32;
+#if defined(__GNUC__) && !defined(__STRICT_ANSI__)
+typedef __u64 __bitwise __le64;
+typedef __u64 __bitwise __be64;
+#endif
+
+#ifdef __KERNEL__
+typedef unsigned __bitwise__ gfp_t;
+
+#ifdef CONFIG_RESOURCES_64BIT
+typedef u64 resource_size_t;
+#else
+typedef u32 resource_size_t;
+#endif
+
+#endif	/* __KERNEL__ */
+
+struct ustat {
+	__kernel_daddr_t	f_tfree;
+	__kernel_ino_t		f_tinode;
+	char			f_fname[6];
+	char			f_fpack[6];
+};
+
+#endif /* _LINUX_TYPES_H */
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 86c6f44..8ae7f74 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -12,8 +12,8 @@ #include <linux/types.h>
  */
 typedef union
 {
-	__u32		a4;
-	__u32		a6[4];
+	__be32		a4;
+	__be32		a6[4];
 } xfrm_address_t;
 
 /* Ident of a specific xfrm_state. It is used on input to lookup
@@ -23,7 +23,7 @@ typedef union
 struct xfrm_id
 {
 	xfrm_address_t	daddr;
-	__u32		spi;
+	__be32		spi;
 	__u8		proto;
 };
 
@@ -49,10 +49,10 @@ struct xfrm_selector
 {
 	xfrm_address_t	daddr;
 	xfrm_address_t	saddr;
-	__u16	dport;
-	__u16	dport_mask;
-	__u16	sport;
-	__u16	sport_mask;
+	__be16	dport;
+	__be16	dport_mask;
+	__be16	sport;
+	__be16	sport_mask;
 	__u16	family;
 	__u8	prefixlen_d;
 	__u8	prefixlen_s;
@@ -104,6 +104,13 @@ struct xfrm_stats {
 
 enum
 {
+	XFRM_POLICY_TYPE_MAIN	= 0,
+	XFRM_POLICY_TYPE_SUB	= 1,
+	XFRM_POLICY_TYPE_MAX	= 2
+};
+
+enum
+{
 	XFRM_POLICY_IN	= 0,
 	XFRM_POLICY_OUT	= 1,
 	XFRM_POLICY_FWD	= 2,
@@ -120,7 +127,10 @@ enum
 
 #define XFRM_MODE_TRANSPORT 0
 #define XFRM_MODE_TUNNEL 1
-#define XFRM_MODE_MAX 2
+#define XFRM_MODE_ROUTEOPTIMIZATION 2
+#define XFRM_MODE_IN_TRIGGER 3
+#define XFRM_MODE_BEET 4
+#define XFRM_MODE_MAX 5
 
 /* Netlink configuration messages.  */
 enum {
@@ -164,6 +174,10 @@ #define XFRM_MSG_FLUSHPOLICY XFRM_MSG_FL
 #define XFRM_MSG_NEWAE XFRM_MSG_NEWAE
 	XFRM_MSG_GETAE,
 #define XFRM_MSG_GETAE XFRM_MSG_GETAE
+
+	XFRM_MSG_REPORT,
+#define XFRM_MSG_REPORT XFRM_MSG_REPORT
+
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -217,6 +231,12 @@ enum xfrm_ae_ftype_t {
 #define XFRM_AE_MAX (__XFRM_AE_MAX - 1)
 };
 
+struct xfrm_userpolicy_type {
+	__u8		type;
+	__u16		reserved1;
+	__u8		reserved2;
+};
+
 /* Netlink message attributes.  */
 enum xfrm_attr_type_t {
 	XFRMA_UNSPEC,
@@ -232,6 +252,10 @@ enum xfrm_attr_type_t {
 	XFRMA_REPLAY_VAL,
 	XFRMA_REPLAY_THRESH,
 	XFRMA_ETIMER_THRESH,
+	XFRMA_SRCADDR,		/* xfrm_address_t */
+	XFRMA_COADDR,		/* xfrm_address_t */
+	XFRMA_LASTUSED,
+	XFRMA_POLICY_TYPE,	/* struct xfrm_userpolicy_type */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -247,17 +271,18 @@ struct xfrm_usersa_info {
 	__u32				seq;
 	__u32				reqid;
 	__u16				family;
-	__u8				mode; /* 0=transport,1=tunnel */
+	__u8				mode;		/* XFRM_MODE_xxx */
 	__u8				replay_window;
 	__u8				flags;
 #define XFRM_STATE_NOECN	1
 #define XFRM_STATE_DECAP_DSCP	2
 #define XFRM_STATE_NOPMTUDISC	4
+#define XFRM_STATE_WILDRECV	8
 };
 
 struct xfrm_usersa_id {
 	xfrm_address_t			daddr;
-	__u32				spi;
+	__be32				spi;
 	__u16				family;
 	__u8				proto;
 };
@@ -319,11 +344,19 @@ struct xfrm_usersa_flush {
 	__u8				proto;
 };
 
+struct xfrm_user_report {
+	__u8				proto;
+	struct xfrm_selector		sel;
+};
+
+#ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
 #define XFRMGRP_SA		4
 #define XFRMGRP_POLICY		8
+#define XFRMGRP_REPORT		0x10
+#endif
 
 enum xfrm_nlgroups {
 	XFRMNLGRP_NONE,
@@ -338,6 +371,8 @@ #define XFRMNLGRP_SA		XFRMNLGRP_SA
 #define XFRMNLGRP_POLICY	XFRMNLGRP_POLICY
 	XFRMNLGRP_AEVENTS,
 #define XFRMNLGRP_AEVENTS	XFRMNLGRP_AEVENTS
+	XFRMNLGRP_REPORT,
+#define XFRMNLGRP_REPORT	XFRMNLGRP_REPORT
 	__XFRMNLGRP_MAX
 };
 #define XFRMNLGRP_MAX	(__XFRMNLGRP_MAX - 1)
-- 
1.4.2

