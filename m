From: stefani@seibold.net
Subject: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 10:29:45 +0100
Message-ID: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Cc: stefani@seibold.net
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefani Seibold <stefani@seibold.net>

UDPCP is a communication protocol specified by the Open Base Station
Architecture Initiative Special Interest Group (OBSAI SIG). The
protocol is based on UDP and is designed to meet the needs of "Mobile
Communcation Base Station" internal communications. It is widely used by
the major networks infrastructure supplier.

The UDPCP communication service supports the following features:

-Connectionless communication for serial mode data transfer
-Acknowledged and unacknowledged transfer modes
-Retransmissions Algorithm
-Checksum Algorithm using Adler32
-Fragmentation of long messages (disassembly/reassembly) to match to the MTU
 during transport:
-Broadcasting and multicasting messages to multiple peers in unacknowledged
 transfer mode

UDPCP supports application level messages up to 64 KBytes (limited by 16-bit
packet data length field). Messages that are longer than the MTU will be
fragmented to the MTU.

UDPCP provides a reliable transport service that will perform message
retransmissions in case transport failures occur.

The code is also a nice example how to implement a UDP based protocol as
a kernel socket modules.

Due the nature of UDPCP which has no sliding windows support, the latency has a
huge impact. The perfomance increase by implementing as a kernel module is
about the factor 10, because there are no context switches and data packets or
ACKs will be handled in the interrupt service.

There are no side effects to the network subsystems so i ask for merge it
into linux-next. Hope you like it.

Wish a happy new year. Keep on hacking.

- Stefani

Signed-off-by: Stefani Seibold <stefani@seibold.net>
---
 include/linux/socket.h |    5 +-
 include/net/udpcp.h    |   47 +
 net/Kconfig            |    1 +
 net/Makefile           |    1 +
 net/ipv4/ip_output.c   |    2 +
 net/ipv4/ip_sockglue.c |    2 +
 net/ipv4/udp.c         |    2 +-
 net/udpcp/Kconfig      |   34 +
 net/udpcp/Makefile     |    5 +
 net/udpcp/udpcp.c      | 2883 ++++++++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 2980 insertions(+), 2 deletions(-)
 create mode 100644 include/net/udpcp.h
 create mode 100644 net/udpcp/Kconfig
 create mode 100644 net/udpcp/Makefile
 create mode 100644 net/udpcp/udpcp.c

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 86b652f..624c5ed 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -193,7 +193,8 @@ struct ucred {
 #define AF_PHONET	35	/* Phonet sockets		*/
 #define AF_IEEE802154	36	/* IEEE802154 sockets		*/
 #define AF_CAIF		37	/* CAIF sockets			*/
-#define AF_MAX		38	/* For now.. */
+#define	AF_UDPCP	38	/* UDPCP sockets		*/
+#define AF_MAX		39	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -234,6 +235,7 @@ struct ucred {
 #define PF_PHONET	AF_PHONET
 #define PF_IEEE802154	AF_IEEE802154
 #define PF_CAIF		AF_CAIF
+#define	PF_UDPCP	AF_UDPCP
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -307,6 +309,7 @@ struct ucred {
 #define SOL_RDS		276
 #define SOL_IUCV	277
 #define SOL_CAIF	278
+#define SOL_UDPCP	279
 
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/include/net/udpcp.h b/include/net/udpcp.h
new file mode 100644
index 0000000..ba199b9
--- /dev/null
+++ b/include/net/udpcp.h
@@ -0,0 +1,47 @@
+/* Definitions for UDPCP sockets. */
+
+#ifndef __LINUX_IF_UDPCP
+#define __LINUX_IF_UDPCP
+
+#include "linux/ioctl.h"
+
+#define UDPCP_MAX_MSGSIZE	65487
+
+#define	UDPCP_MAX_WAIT_SEC	60
+
+#define UDPCP_OPT_TRANSFER_MODE		0
+#define UDPCP_OPT_CHECKSUM_MODE		1
+#define UDPCP_OPT_TX_TIMEOUT		2
+#define UDPCP_OPT_RX_TIMEOUT		3
+#define UDPCP_OPT_MAXTRY		4
+#define	UDPCP_OPT_OUTSTANDING_ACKS	5
+
+#define	UDPCP_NOACK		0
+#define	UDPCP_ACK		1
+#define	UDPCP_SINGLE_ACK	2
+#define	UDPCP_NOCHECKSUM	3
+#define	UDPCP_CHECKSUM		4
+
+#define UDPCP_IOC_MAGIC  251
+
+#define UDPCP_IOCTL_GET_STATISTICS \
+	_IOR(UDPCP_IOC_MAGIC, 0x01, struct udpcp_statistics *)
+#define UDPCP_IOCTL_RESET_STATISTICS \
+	_IO(UDPCP_IOC_MAGIC, 0x02)
+#define UDPCP_IOCTL_SYNC \
+	_IOR(UDPCP_IOC_MAGIC, 0x03, unsigned long)
+
+struct udpcp_statistics {
+	unsigned int txMsgs;		/* Num of transmitted messages */
+	unsigned int rxMsgs;		/* Num of received messages */
+	unsigned int txNodes;		/* Num of receiver nodes */
+	unsigned int rxNodes;		/* Num of transmitter nodes */
+	unsigned int txTimeout;		/* Num of unsuccessful transmissions */
+	unsigned int rxTimeout;		/* Num of partial message receptions */
+	unsigned int txRetries;		/* Num of resends */
+	unsigned int rxDiscardedFrags;	/* Num of discarded fragments */
+	unsigned int crcErrors;		/* Num of crc errors detected */
+};
+
+#endif
+
diff --git a/net/Kconfig b/net/Kconfig
index 55fd82e..4a206fc 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -294,6 +294,7 @@ source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
 source "net/caif/Kconfig"
 source "net/ceph/Kconfig"
+source "net/udpcp/Kconfig"
 
 
 endif   # if NET
diff --git a/net/Makefile b/net/Makefile
index 6b7bfd7..a17ae27 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -69,3 +69,4 @@ endif
 obj-$(CONFIG_WIMAX)		+= wimax/
 obj-$(CONFIG_DNS_RESOLVER)	+= dns_resolver/
 obj-$(CONFIG_CEPH_LIB)		+= ceph/
+obj-$(CONFIG_UDPCP)		+= udpcp/
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 439d2a3..55b2d0c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1085,6 +1085,7 @@ error:
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
+EXPORT_SYMBOL(ip_append_data);
 
 ssize_t	ip_append_page(struct sock *sk, struct page *page,
 		       int offset, size_t size, int flags)
@@ -1341,6 +1342,7 @@ error:
 	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
 	goto out;
 }
+EXPORT_SYMBOL(ip_push_pending_frames);
 
 /*
  *	Throw away all pending data on the socket.
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 3948c86..310369c 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -226,6 +226,7 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(ip_cmsg_send);
 
 
 /* Special input handler for packets caught by router alert option.
@@ -369,6 +370,7 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 port, u32 inf
 	if (sock_queue_err_skb(sk, skb))
 		kfree_skb(skb);
 }
+EXPORT_SYMBOL(ip_local_error);
 
 /*
  *	Handle MSG_ERRQUEUE
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2d3ded4..f9890a2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1310,7 +1310,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (inet_sk(sk)->inet_daddr)
 		sock_rps_save_rxhash(sk, skb->rxhash);
 
-	rc = ip_queue_rcv_skb(sk, skb);
+	rc = sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
 
diff --git a/net/udpcp/Kconfig b/net/udpcp/Kconfig
new file mode 100644
index 0000000..a58c1b0
--- /dev/null
+++ b/net/udpcp/Kconfig
@@ -0,0 +1,34 @@
+#
+# UDPCP protocol
+#
+
+config UDPCP
+	tristate "UDPCP Communication Protocol"
+	depends on INET
+	---help---
+	  UDPCP is a communication protocol specified by the Open Base Station
+	  Architecture Initiative Special Interest Group (OBSAI SIG). The
+	  protocol is based on UDP and is designed to meet the needs of "Mobile
+	  Communcation Base Station" internal communications.
+
+	  The UDPCP communication service supports the following features:
+
+          -Connectionless communication for serial mode data transfer
+          -Acknowledged and unacknowledged transfer modes
+          -Retransmissions Algorithm
+          -Checksum Algorithm using Adler32
+          -Fragmentation of long messages (disassembly/reassembly) to
+           match to the MTU during transport:
+          -Broadcasting and multicasting messages to multiple peers in
+           unacknowledged transfer mode
+
+          UDPCP supports application level messages up to 64 KBytes (limited
+          by 16-bit packet data length field). Messages that are longer than the
+          MTU will be fragmented to the MTU.
+
+          UDPCP provides a reliable transport service that will perform message
+          retransmissions in case transport failures occur.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called udpcp.
+
diff --git a/net/udpcp/Makefile b/net/udpcp/Makefile
new file mode 100644
index 0000000..37f87c5
--- /dev/null
+++ b/net/udpcp/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for UDPCP support code.
+#
+
+obj-$(CONFIG_UDPCP) += udpcp.o
diff --git a/net/udpcp/udpcp.c b/net/udpcp/udpcp.c
new file mode 100644
index 0000000..c75f7aa
--- /dev/null
+++ b/net/udpcp/udpcp.c
@@ -0,0 +1,2883 @@
+/*
+ * UDPCP communication protocol
+ *
+ * Copyright (C) 2010 Stefani Seibold <stefani@seibold.net>
+ * in order of NSN Ulm/Germany
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ */
+
+#include <net/xfrm.h>
+#include <net/protocol.h>
+#include <net/ip.h>
+#include <net/udp.h>
+#include <net/udplite.h>
+#include <net/inet_common.h>
+#include <linux/zutil.h>
+#include <linux/module.h>
+#include <linux/proc_fs.h>
+#include <linux/spinlock.h>
+#include <linux/errqueue.h>
+
+#include <net/udpcp.h>
+
+#define	VERSION	"0.67"
+
+/*
+ * UDPCP Protocol default parameters
+ */
+#define	UDPCP_TX_TIMEOUT	100	/* milliseconds */
+#define	UDPCP_RX_TIMEOUT	1000	/* milliseconds */
+#define	UDPCP_TX_MAXTRY		5
+#define	UDPCP_OUTSTANDING_ACKS	1
+
+/*
+ * UDPCP Protocol definitions
+ */
+#define	UDPCP_MSG_TYPE_BIT		14
+#define	UDPCP_PROTOCOL_VERSION_BIT	11
+#define	UDPCP_NO_ACK_BIT		10
+#define	UDPCP_CHECKSUM_BIT		9
+#define	UDPCP_SINGLE_ACK_BIT		8
+#define	UDPCP_DUPLICATE_BIT		7
+
+#define	UDPCP_MSG_TYPE_MASK		(3 << UDPCP_MSG_TYPE_BIT)
+#define	UDPCP_PROTOCOL_MASK		(7 << UDPCP_PROTOCOL_VERSION_BIT)
+
+#define	UDPCP_MSG_TYPE_DATA		(1 << UDPCP_MSG_TYPE_BIT)
+#define	UDPCP_MSG_TYPE_ACK		(2 << UDPCP_MSG_TYPE_BIT)
+#define	UDPCP_PROTOCOL_VERSION_2	(2 << UDPCP_PROTOCOL_VERSION_BIT)
+
+#define	UDPCP_NO_ACK_FLAG		(1 << UDPCP_NO_ACK_BIT)
+#define	UDPCP_CHECKSUM_FLAG		(1 << UDPCP_CHECKSUM_BIT)
+#define	UDPCP_SINGLE_ACK_FLAG		(1 << UDPCP_SINGLE_ACK_BIT)
+#define	UDPCP_DUPLICATE_FLAG		(1 << UDPCP_DUPLICATE_BIT)
+
+/*
+ * helper macros
+ */
+#define	list_to_udpcpdest(d) container_of(d, struct udpcp_dest, list)
+#define	list_to_udpcpsock(d) container_of(d, struct udpcp_sock, udpcplist)
+
+#define	UDPCP_HDRSIZE	(sizeof(struct udpcphdr)-sizeof(struct udphdr))
+
+#define	RX_NODE	1
+#define	TX_NODE	2
+
+/*
+ * name of the /proc entry
+ */
+#define	UDPCP_PROC	"driver/udpcp"
+
+/*
+ * UDPCP message header
+ */
+struct __attribute__ ((packed)) udpcphdr {
+	struct udphdr udphdr;
+	__be32 chksum;
+	__be16 msginfo;
+	u8 fragamount;
+	u8 fragnum;
+	__be16 msgid;
+	__be16 length;
+};
+
+/*
+ * UDPCP destination descriptor
+ *
+ * For each communication address an individual destination descriptor will
+ * be create.
+ *
+ * The fields has the following meanings:
+ *
+ * list:		link list: part of udpcp_sock.destlist
+ * xmit:		messages fragments to be transmit
+ * tx_time:		timestamp of the last transmitted message fragment
+ * rx_time:		timestamp ot the last received message fragment
+ * txTimeout:		statistic use only: number of transmit timeout
+ * rxTimeout:		statistic use only: number of receive timeout
+ * txRetries:		statistic use only: number of transmit retries
+ * rxDiscardedFrags:	statistic use only: number of discarded messages
+ * xmit_wait:		message fragment which is waiting for an ACK
+ * xmit_last:		last fragment transmitted
+ * recv_msg:		first fragment of the received message
+ * recv_last:		last fragment of the received message
+ * lastmsg:		last messages fragment header received
+ * ipc:			linux internal ipc cookie
+ * fl:			flow/routing information
+ * rt:			routing entry currently used for this destination
+ * addr:		ipv4 destination address
+ * port:		destination port number
+ * msgid:		current message id for outgoing data messages
+ * use_flag:		statistic use only: flag for dest using TX and/or RX
+ * insync:		flag for protocol synchronization
+ * ackmode;		ack mode for the current assembled message
+ * chkmode;		checksum mode for the current assembled message
+ * try:			current number of retries xmit_wait message
+ * acks:		number of outstandig ack's
+ */
+struct udpcp_dest {
+	struct list_head list;
+	struct sk_buff_head xmit;
+	unsigned long tx_time;
+	unsigned long rx_time;
+	u32 txTimeout;
+	u32 rxTimeout;
+	u32 txRetries;
+	u32 rxDiscardedFrags;
+	struct sk_buff *xmit_wait;
+	struct sk_buff *xmit_last;
+	struct sk_buff *recv_msg;
+	struct sk_buff *recv_last;
+	struct udpcphdr lastmsg;
+	struct ipcm_cookie ipc;
+	struct flowi fl;
+	struct rtable *rt;
+	__be32 addr;
+	__be16 port;
+	u16 msgid;
+	u8 use_flag;
+	u8 insync;
+	u8 ackmode;
+	u8 chkmode;
+	u8 try;
+	u8 acks;
+};
+
+/*
+ * UDPCP socket descriptor
+ *
+ * For each opened socket individual socket descriptor will
+ * be created
+ *
+ * The fields has the following meanings:
+ *
+ * udpsock:		UDP socket has to be the first member of udpcp_sock
+ * assembly:		messages fragments currently assembled
+ * assembly_len:	current length of the assembled message
+ * assembly_dest:	current destination assembled
+ * wq:			wait queue for UDPCP_IOCTL_SYNC
+ * destlist:		head of destination descriptors link list
+ * udpcplist:		link list: part of udpcp_list
+ * timer:		timeout handler
+ * stat:		statistics for this socket
+ * pending:		number of pending messages fragment in the queues
+ * tx_timeout:		transmit timeout in jiffies
+ * rx_timeout:		receive timeout in jiffies
+ * udp_data_ready:	original data_ready handler for this socket
+ * ackmode:		default ack mode
+ * chkmode:		default checksum mode
+ * maxtry:		max. number of resends
+ * acks:		max. number of outstandig ack's
+ * timeout:		flag for unhandled timeout
+ */
+struct udpcp_sock {
+	struct udp_sock udpsock;
+	struct sk_buff_head assembly;
+	u32 assembly_len;
+	struct udpcp_dest *assembly_dest;
+	wait_queue_head_t wq;
+	struct list_head destlist;
+	struct list_head udpcplist;
+	struct timer_list timer;
+	struct udpcp_statistics stat;
+	u32 pending;
+	unsigned long tx_timeout;
+	unsigned long rx_timeout;
+	void (*udp_data_ready) (struct sock *sk, int bytes);
+	u8 ackmode;
+	u8 chkmode;
+	u8 maxtry;
+	u8 acks;
+	u8 timeout;
+};
+
+/* overall UDPCP statistics */
+static struct udpcp_statistics udpcp_stat;
+
+/* head of struct udpcp_sock.udpcplist link list */
+static struct list_head udpcp_list;
+
+/* spinlock for race free access to the static variables */
+static spinlock_t spinlock;
+
+/* debug flag, set != 0 to enable debug */
+static int debug;
+
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug enabled or not");
+
+#ifdef CONFIG_PROC_FS
+/*
+ * Handle /proc/driver/udpcp
+ *
+ * Show the statistics information
+ */
+static int udpcp_proc(char *page, char **start, off_t off, int count, int *eof,
+		      void *data)
+{
+	int len;
+	struct udpcp_statistics curr_stat;
+	unsigned long flags;
+
+	spin_lock_irqsave(&spinlock, flags);
+	curr_stat = udpcp_stat;
+	spin_unlock_irqrestore(&spinlock, flags);
+
+	len = snprintf(page, count,
+		       "txMsgs:          %u\n"
+		       "rxMsgs:          %u\n"
+		       "txNodes:         %u\n"
+		       "rxNodes:         %u\n"
+		       "txTimeout:       %u\n"
+		       "rxTimeout:       %u\n"
+		       "txRetries:       %u\n"
+		       "rxDiscaredFrags: %u\n"
+		       "crcErrors:       %u\n",
+		       curr_stat.txMsgs,
+		       curr_stat.rxMsgs,
+		       curr_stat.txNodes,
+		       curr_stat.rxNodes,
+		       curr_stat.txTimeout,
+		       curr_stat.rxTimeout,
+		       curr_stat.txRetries,
+		       curr_stat.rxDiscardedFrags, curr_stat.crcErrors);
+
+	if (len <= off)
+		return 0;
+
+	len -= off;
+
+	if (len > count)
+		return count;
+
+	return len;
+}
+#endif
+
+/*
+ * Helper for the UDPCP header from a socket buffer
+ */
+static inline struct udpcphdr *udpcp_hdr(const struct sk_buff *skb)
+{
+	return (struct udpcphdr *)skb_transport_header(skb);
+}
+
+/*
+ * Helper for conversion a basic socket into a UDPCP socket
+ */
+static inline struct udpcp_sock *udpcp_sk(const struct sock *sk)
+{
+	return (struct udpcp_sock *)sk;
+}
+
+/*
+ * Dump the transport data of a socket buffer
+ */
+static inline void dump_data(struct sk_buff *skb, unsigned int max)
+{
+	unsigned int i;
+	unsigned char *data;
+	int data_len;
+
+	data = skb_transport_header(skb) + sizeof(struct udpcphdr);
+	data_len = skb_tail_pointer(skb) - data;
+
+	pr_debug(" data: ");
+
+	if (!data_len) {
+		pr_cont("<none>\n");
+		return;
+	}
+
+	if (max > data_len)
+		max = data_len;
+
+	for (i = 0; i < max; i++)
+		pr_cont("%02x ", data[i]);
+
+	if (data_len > max)
+		pr_cont("...");
+	pr_cont("\n");
+}
+
+/*
+ * Dump and decode a msginfo value
+ */
+static inline void dump_msginfo(u16 msginfo)
+{
+	pr_debug(" msginfo:0x%04x (", msginfo);
+
+	pr_cont("PCKT:");
+	switch (msginfo & UDPCP_MSG_TYPE_MASK) {
+	case UDPCP_MSG_TYPE_DATA:
+		pr_cont("DATA");
+		break;
+	case UDPCP_MSG_TYPE_ACK:
+		pr_cont("ACK");
+		break;
+	default:
+		pr_cont("UNKNOWN");
+		break;
+	}
+	pr_cont(" VER:%d",
+	       (msginfo & UDPCP_PROTOCOL_MASK) >> UDPCP_PROTOCOL_VERSION_BIT);
+
+	if (msginfo & UDPCP_NO_ACK_FLAG)
+		pr_cont(" NO_ACK");
+	if (msginfo & UDPCP_CHECKSUM_FLAG)
+		pr_cont(" CHECKSUM");
+	if (msginfo & UDPCP_SINGLE_ACK_FLAG)
+		pr_cont(" SINGLE_ACK");
+	if (msginfo & UDPCP_DUPLICATE_FLAG)
+		pr_cont(" DUPLICATE");
+	pr_cont(")\n");
+}
+
+/*
+ * Dump and decode a UDPCP message fragment
+ */
+static void dump_msg(const char *action, struct sk_buff *skb, __be32 saddr,
+		     __be32 daddr)
+{
+	struct udpcphdr *uh = udpcp_hdr(skb);
+
+	pr_debug("udpcp: %s (%lu)\n", action, jiffies);
+
+	pr_debug(" src:0x%08x:%d dst:0x%08x:%d fraglen:%d\n",
+	       saddr, uh->udphdr.source, daddr, uh->udphdr.dest, skb->len);
+
+	pr_debug(" fragamount:%u fragnum:%u msgid:%u%s"
+		 " length:%u checksum:0x%08x\n",
+	       uh->fragamount, uh->fragnum, ntohs(uh->msgid),
+	       (!uh->msgid) ? "(Sync)" : "", ntohs(uh->length),
+	       ntohl(uh->chksum)
+	    );
+
+	dump_msginfo(ntohs(uh->msginfo));
+	dump_data(skb, 16);
+}
+
+/*
+ * Create a new destination descriptor for the given IPV4 address and port
+ */
+static struct udpcp_dest *new_dest(struct sock *sk, __be32 addr, __be16 port)
+{
+	struct udpcp_dest *dest;
+	struct udpcp_sock *usk = udpcp_sk(sk);
+
+	dest = kzalloc(sizeof(*dest), sk->sk_allocation);
+
+	if (dest) {
+		skb_queue_head_init(&dest->xmit);
+		dest->addr = addr;
+		dest->port = port;
+		dest->ackmode = UDPCP_ACK;
+		list_add_tail(&dest->list, &usk->destlist);
+	}
+
+	return dest;
+}
+
+/*
+ * Lookup for a destination descriptor for the given IPV4 address and port
+ */
+static struct udpcp_dest *__find_dest(struct sock *sk, __be32 addr, __be16 port)
+{
+	struct udpcp_dest *dest;
+	struct list_head *p;
+	struct udpcp_sock *usk = udpcp_sk(sk);
+
+	list_for_each(p, &usk->destlist) {
+		dest = list_to_udpcpdest(p);
+
+		if ((dest->addr == addr) && (dest->port == port))
+			return dest;
+	}
+	return NULL;
+}
+
+/*
+ * Lookup for a destination descriptor and create a new one if no
+ * descriptor was found.
+ */
+static struct udpcp_dest *find_dest(struct sock *sk, __be32 addr, __be16 port)
+{
+	struct udpcp_dest *dest;
+
+	dest = __find_dest(sk, addr, port);
+
+	if (!dest)
+		dest = new_dest(sk, addr, port);
+
+	return dest;
+}
+
+/*
+ * Calculate udp checksum, mostly stolen from udp stack
+ */
+static void udpcp_do_csum(struct sock *sk, struct sk_buff *skb,
+			  struct udpcp_dest *dest)
+{
+	struct flowi *fl = &dest->fl;
+	struct udphdr *uh = udp_hdr(skb);
+	__wsum csum = 0;
+	unsigned short len = ntohs(uh->len);
+
+	if (IS_UDPLITE(sk)) {
+		int cscov = udplite_sender_cscov(udp_sk(sk), uh);
+		int off = skb_transport_offset(skb);
+		int n = skb->len - off;
+
+		skb->ip_summed = CHECKSUM_NONE;
+		csum = skb_checksum(skb, off, (cscov > n) ? n : cscov, csum);
+	} else {
+		if (sk->sk_no_check == UDP_CSUM_NOXMIT) {
+			skb->ip_summed = CHECKSUM_NONE;
+			return;
+		}
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			/* UDP hardware csum */
+			skb->csum_start = skb_transport_header(skb) - skb->head;
+			skb->csum_offset = offsetof(struct udphdr, check);
+			uh->check =
+			    ~csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst, len,
+					       sk->sk_protocol, 0);
+			return;
+		}
+		csum = csum_partial(uh, sizeof(struct udpcphdr), 0);
+		csum = csum_add(csum, skb->csum);
+	}
+
+	/* add protocol-dependent pseudo-header */
+	uh->check =
+	    csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst, len, sk->sk_protocol,
+			      csum);
+	if (uh->check == 0)
+		uh->check = CSUM_MANGLED_0;
+}
+
+/*
+ * Fetch data from kernel space and fill in checksum if needed.
+ */
+static int ip_reply_glue_bits(void *dptr, char *to, int offset,
+			      int len, int odd, struct sk_buff *skb)
+{
+	__wsum csum;
+
+	csum = csum_partial_copy_nocheck(dptr+offset, to, len, 0);
+	skb->csum = csum_block_add(skb->csum, csum, odd);
+	return 0;
+}
+
+/*
+ * Send an ack for a received data message fragment
+ *
+ * If the argument duplicate is true a ACK with UDPCP_DUPLICATE_FLAG set will
+ * be send
+ */
+static void udpcp_send_ack(struct sock *sk, struct sk_buff *skb,
+			   struct udpcp_dest *dest, int duplicate)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct udpcphdr *uh = udpcp_hdr(skb);
+	struct rtable *rt = skb_rtable(skb);
+	__wsum csum;
+	struct ipcm_cookie ipc;
+	struct udpcphdr rep;
+
+	memset(&rep, 0, sizeof(rep));
+
+	/* Swap the send and the receive ports. */
+	rep.udphdr.source = uh->udphdr.dest;
+	rep.udphdr.dest = uh->udphdr.source;
+	rep.udphdr.len = htons(sizeof(struct udpcphdr));
+
+	rep.msginfo = htons(UDPCP_MSG_TYPE_ACK |
+			    UDPCP_NO_ACK_FLAG |
+			    UDPCP_SINGLE_ACK_FLAG | UDPCP_PROTOCOL_VERSION_2);
+	if (duplicate)
+		rep.msginfo |= htons(UDPCP_DUPLICATE_FLAG);
+	else
+		memcpy(&dest->lastmsg, uh, sizeof(dest->lastmsg));
+	rep.msgid = uh->msgid;
+	rep.fragamount = uh->fragamount;
+	rep.fragnum = uh->fragnum;
+	rep.length = 0;
+	rep.chksum = 0;
+	if (ntohs(uh->msginfo) & UDPCP_CHECKSUM_FLAG) {
+		u8 *data;
+		u32 data_len;
+
+		data = (u8 *) &rep + sizeof(struct udphdr);
+		data_len = sizeof(struct udpcphdr)-sizeof(struct udphdr);
+
+		rep.msginfo |= htons(UDPCP_CHECKSUM_FLAG);
+		rep.chksum = htonl(zlib_adler32(1, data, data_len));
+	}
+
+	if (debug) {
+		struct sk_buff tmp;
+
+		tmp.len = ntohs(rep.udphdr.len);
+		tmp.head = tmp.transport_header = tmp.data = (void *)&rep;
+		tmp.tail = tmp.head + tmp.len;
+
+		dump_msg("ack msg", &tmp, ip_hdr(skb)->daddr,
+			 ip_hdr(skb)->saddr);
+	}
+
+	csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
+				      ip_hdr(skb)->saddr,
+				      sizeof(rep), sk->sk_protocol, 0);
+
+	ipc.addr = rt->rt_src;
+	ipc.opt = NULL;
+	ipc.tx_flags = 0;
+
+	{
+		struct flowi fl = {
+			.nl_u = { .ip4_u = {
+						.daddr = ipc.addr,
+						.saddr = rt->rt_spec_dst,
+						.tos = RT_TOS(ip_hdr(skb)->tos)
+					      }
+			},
+			.uli_u = { .ports = {
+						.sport = udp_hdr(skb)->dest,
+						.dport = udp_hdr(skb)->source
+				       }
+			},
+			.proto = sk->sk_protocol,
+		};
+		security_skb_classify_flow(skb, &fl);
+		if (ip_route_output_key(sock_net(sk), &rt, &fl))
+			return;
+	}
+
+	inet->tos = ip_hdr(skb)->tos;
+	sk->sk_priority = skb->priority;
+	sk->sk_protocol = ip_hdr(skb)->protocol;
+	sk->sk_bound_dev_if = 0;
+	ip_append_data(sk, ip_reply_glue_bits, &rep, sizeof(rep),
+				0, &ipc, &rt, MSG_DONTWAIT);
+	skb = skb_peek(&sk->sk_write_queue);
+	if (skb) {
+		*((__sum16 *)skb_transport_header(skb) +
+		  offsetof(struct udphdr, check) / 2) =
+			csum_fold(csum_add(skb->csum, csum));
+		skb->ip_summed = CHECKSUM_NONE;
+		ip_push_pending_frames(sk);
+	}
+
+	ip_rt_put(rt);
+
+	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_OUTDATAGRAMS, IS_UDPLITE(sk));
+}
+
+/*
+ * Pass a UDPCP skb buffer to the ip stack and send it
+ */
+static int udpcp_send_skb(struct sock *sk, struct sk_buff *skb,
+			  struct udpcp_dest *dest, struct ip_options *opt)
+{
+	int err;
+
+	skb_dst_set(skb, dst_clone(&dest->rt->dst));
+
+	err = ip_build_and_send_pkt(skb, sk, dest->fl.fl4_src,
+					dest->fl.fl4_dst, opt);
+
+	if (!err)
+		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_OUTDATAGRAMS,
+				   IS_UDPLITE(sk));
+	return err;
+}
+
+/*
+ * Release a routing table entry if no packed will be assembled
+ */
+static void udpcp_dst_release(struct udpcp_sock *usk, struct udpcp_dest *dest)
+{
+	if (usk->assembly_dest != dest) {
+		dst_release(&dest->rt->dst);
+		dest->rt = NULL;
+	}
+}
+
+/*
+ * Return true it the passed skb socket buffer is the last in the list
+ */
+static inline bool skb_is_eoq(const struct sk_buff_head *list,
+			      const struct sk_buff *skb)
+{
+	return (skb->next == (struct sk_buff *)list);
+}
+
+/*
+ * Arm the timeout handler for the socket
+ */
+static void udpcp_timer(struct sock *sk, unsigned long timeout)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+
+	mod_timer(&usk->timer, timeout);
+}
+
+/*
+ * Decrement the socket pending counter and wakeup a waiting UDPCP_IOCTL_SYNC
+ */
+static inline void udpcp_dec_pending(struct sock *sk)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+
+	if (!--usk->pending) {
+		if (waitqueue_active(&usk->wq))
+			wake_up_interruptible(&usk->wq);
+	}
+}
+
+/*
+ * Returns true is the passed message fragment is the last fragment
+ */
+static inline int udpcp_is_last_frag(struct udpcphdr *uh)
+{
+	return uh->fragamount == uh->fragnum + 1;
+}
+
+/*
+ * Transmit data message fragments
+ */
+static int _udpcp_xmit(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	struct sk_buff *skb = NULL;
+	struct sk_buff *skbc;
+	struct udpcphdr *uh;
+	int err = 0;
+
+	if (dest->acks >= usk->acks)
+		goto out;
+
+	if (!dest->xmit_last) {
+		/*
+		 * handle data message fragments without an ack
+		 */
+		while ((skb = skb_peek(&dest->xmit))) {
+			uh = udpcp_hdr(skb);
+
+			if (!(ntohs(uh->msginfo) & UDPCP_NO_ACK_FLAG))
+				break;
+			if (udpcp_is_last_frag(uh)) {
+				unsigned long flags;
+
+				usk->stat.txMsgs++;
+				spin_lock_irqsave(&spinlock, flags);
+				udpcp_stat.txMsgs++;
+				spin_unlock_irqrestore(&spinlock, flags);
+			}
+			skb_unlink(skb, &dest->xmit);
+			udpcp_dec_pending(sk);
+			if (debug)
+				dump_msg("send msg", skb, dest->fl.fl4_src,
+					 dest->fl.fl4_dst);
+			err = udpcp_send_skb(sk, skb, dest,
+						(struct ip_options *)skb->cb);
+			if (err) {
+				kfree_skb(skb);
+				skb = NULL;
+				break;
+			}
+		}
+		dest->xmit_wait = skb;
+	} else {
+		/*
+		 * handle next data message fragment waiting for an ack
+		 */
+		uh = udpcp_hdr(dest->xmit_last);
+
+		if (udpcp_is_last_frag(uh))
+			goto out;
+
+		/*
+		 * get next data message fragment
+		 */
+		skb = dest->xmit_last->next;
+	}
+
+	/*
+	 * send all data message fragment till the first which must be acked
+	 */
+	while (skb) {
+		skbc = skb_clone(skb, sk->sk_allocation);
+
+		if (!skbc)
+			break;
+
+		if (debug)
+			dump_msg("send msg", skbc, dest->fl.fl4_src,
+				 dest->fl.fl4_dst);
+		err = udpcp_send_skb(sk, skbc, dest,
+					(struct ip_options *)skb->cb);
+		if (err) {
+			kfree_skb(skbc);
+			break;
+		}
+
+		uh = udpcp_hdr(skb);
+
+		if (!(ntohs(uh->msginfo) & UDPCP_SINGLE_ACK_FLAG)
+		    || udpcp_is_last_frag(uh)) {
+			dest->xmit_last = skb;
+
+			if (++dest->acks >= usk->acks || udpcp_is_last_frag(uh))
+				break;
+		}
+
+		skb = skb_is_eoq(&dest->xmit, skb) ? NULL : skb->next;
+	}
+
+out:
+	if (skb_queue_empty(&dest->xmit))
+		udpcp_dst_release(usk, dest);
+
+	return err;
+}
+
+/*
+ * Transmit data message fragments and rearm the timeout handler if necessary
+ */
+static int udpcp_xmit(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	int ret;
+
+	ret = _udpcp_xmit(sk, dest);
+
+	if (dest->xmit_wait) {
+		dest->tx_time = jiffies;
+
+		if (!timer_pending(&usk->timer))
+			udpcp_timer(sk, dest->tx_time + usk->tx_timeout);
+	}
+	return ret;
+}
+
+/*
+ * Queue the assembled message fragment into the transmit queue
+ */
+static void udpcp_queue_xmit(struct sock *sk, struct udpcp_dest *dest,
+			     u8 ackmode, u8 chkmode)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	struct udpcphdr *uh;
+	struct sk_buff *skb;
+	u8 fragamount;
+	u8 fragnum;
+	unsigned short msginfo;
+	struct flowi *fl = &dest->fl;
+
+	msginfo = UDPCP_MSG_TYPE_DATA | UDPCP_PROTOCOL_VERSION_2;
+	switch (ackmode) {
+	case UDPCP_NOACK:
+		msginfo |= UDPCP_NO_ACK_FLAG;
+		break;
+	case UDPCP_SINGLE_ACK:
+		msginfo |= UDPCP_SINGLE_ACK_FLAG;
+		break;
+	case UDPCP_ACK:
+	default:
+		break;
+	}
+	switch (chkmode) {
+	case UDPCP_NOCHECKSUM:
+		break;
+	case UDPCP_CHECKSUM:
+	default:
+		msginfo |= UDPCP_CHECKSUM_FLAG;
+		break;
+	}
+
+	fragamount = skb_queue_len(&usk->assembly);
+
+	udpcp_sk(sk)->pending += fragamount;
+
+	for (fragnum = 0; fragnum != fragamount; fragnum++) {
+		unsigned char *data;
+		int data_len;
+
+		skb = skb_dequeue(&usk->assembly);
+		uh = udpcp_hdr(skb);
+
+		/*
+		 * setup a UDPCP header
+		 */
+		uh->chksum = 0;
+		uh->msginfo = htons(msginfo);
+		uh->fragnum = fragnum;
+		uh->fragamount = fragamount;
+		uh->msgid = htons(dest->msgid);
+		uh->length = htons(usk->assembly_len);
+
+		data = skb_transport_header(skb) + sizeof(struct udphdr);
+		data_len = skb_tail_pointer(skb) - data;
+
+		if (chkmode == UDPCP_CHECKSUM)
+			uh->chksum = htonl(zlib_adler32(1, data, data_len));
+		/*
+		 * create a UDP header
+		 */
+		uh->udphdr.source = fl->fl_ip_sport;
+		uh->udphdr.dest = fl->fl_ip_dport;
+		uh->udphdr.len = htons(sizeof(struct udphdr) + data_len);
+		uh->udphdr.check = 0;
+
+		/*
+		 * create UDP checksum
+		 */
+		udpcp_do_csum(sk, skb, dest);
+
+		/*
+		 * add to xmit queue
+		 */
+		skb_queue_tail(&dest->xmit, skb);
+	}
+
+	dest->msgid++;
+	usk->assembly_len = 0;
+	usk->assembly_dest = NULL;
+}
+
+/*
+ * Remove all data message fragments of the first message from the transmit
+ * queue all fragments will be merged together
+ */
+static struct sk_buff *udpcp_dequeue_msg(struct sock *sk,
+					 struct udpcp_dest *dest)
+{
+	struct sk_buff *msg;
+	struct sk_buff *skb;
+	struct sk_buff **next;
+	struct udpcphdr *uh;
+
+	msg = skb_dequeue(&dest->xmit);
+	if (!msg)
+		return NULL;
+	skb_orphan(msg);
+
+	uh = udpcp_hdr(msg);
+	if (!uh->msgid) {
+		/*
+		 * sync message
+		 */
+		kfree_skb(msg);
+		return NULL;
+	}
+
+	skb_pull(msg, sizeof(struct udpcphdr));
+	if (udpcp_is_last_frag(uh))
+		return msg;
+
+	next = &skb_shinfo(msg)->frag_list;
+	for (;;) {
+		skb = skb_dequeue(&dest->xmit);
+		if (!skb)
+			break;
+		skb_orphan(skb);
+		uh = udpcp_hdr(skb);
+		skb_pull(msg, sizeof(struct udpcphdr));
+		msg->len += skb->len;
+		msg->data_len += skb->len;
+		*next = skb;
+		if (udpcp_is_last_frag(uh))
+			break;
+		next = &skb->next;
+	}
+	return msg;
+}
+
+static void udpcp_flush_err(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct udpcp_sock *usk = udpcp_sk(sk);
+
+	if (!inet->recverr)
+		skb_queue_purge(&dest->xmit);
+	else {
+		struct sock_exterr_skb *serr;
+		struct iphdr *iph;
+		struct sk_buff *skb;
+
+		while (!skb_queue_empty(&dest->xmit)) {
+			skb = udpcp_dequeue_msg(sk, dest);
+			if (!skb)
+				continue;
+
+			if (debug)
+				dump_msg("flush outgoing message", skb,
+					 dest->fl.fl4_src, dest->fl.fl4_dst);
+
+			skb_push(skb, sizeof(struct iphdr));
+			skb_reset_network_header(skb);
+			iph = ip_hdr(skb);
+			iph->daddr = dest->rt->rt_dst;
+
+			serr = SKB_EXT_ERR(skb);
+			serr->ee.ee_errno = EPROTO;
+			serr->ee.ee_origin = SO_EE_ORIGIN_LOCAL;
+			serr->ee.ee_type = 0;
+			serr->ee.ee_code = 0;
+			serr->ee.ee_pad = 0;
+			serr->ee.ee_info = 0;
+			serr->ee.ee_data = 0;
+			serr->addr_offset = (u8 *) &iph->daddr -
+						skb_network_header(skb);
+			serr->port = dest->fl.fl_ip_dport;
+
+			skb_reset_transport_header(skb);
+			skb_pull(skb, sizeof(struct iphdr));
+
+			/*
+			 * set a flag for UDPCP message
+			 */
+			skb->cb[sizeof(struct udp_skb_cb)] = 1;
+
+			/*
+			 * pass the dequeued message to the error queue of the
+			 * socket
+			 */
+			skb_set_owner_r(skb, sk);
+			skb_queue_tail(&sk->sk_error_queue, skb);
+			if (!sock_flag(sk, SOCK_DEAD)) {
+				if (usk->udp_data_ready)
+					usk->udp_data_ready(sk, skb->len);
+			}
+		}
+	}
+
+	dest->xmit_wait = 0;
+	dest->xmit_last = 0;
+	dest->try = 0;
+	dest->acks = 0;
+
+	usk->pending = 0;
+	if (waitqueue_active(&usk->wq))
+		wake_up_interruptible(&usk->wq);
+}
+
+/*
+ * Purge the current incoming data message
+ */
+static void udpcp_purge_incoming(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+
+	if (dest->recv_last) {
+		unsigned long flags;
+		u32 fragnum = udpcp_hdr(dest->recv_last)->fragnum + 1;
+
+		dest->rxDiscardedFrags += fragnum;
+		usk->stat.rxDiscardedFrags += fragnum;
+		spin_lock_irqsave(&spinlock, flags);
+		udpcp_stat.rxDiscardedFrags += fragnum;
+		spin_unlock_irqrestore(&spinlock, flags);
+
+		dest->lastmsg.msgid = 0;
+
+		if (debug)
+			dump_msg("purge incoming message", dest->recv_msg,
+				 dest->fl.fl4_src, dest->fl.fl4_dst);
+	}
+
+	kfree_skb(dest->recv_msg);
+	dest->recv_msg = 0;
+	dest->recv_last = 0;
+}
+
+/*
+ * Resend all data message fragments to the one which is currently waiting for
+ * an ack
+ */
+static int udpcp_resend(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct sk_buff *skb;
+	struct sk_buff *skbc;
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	int err;
+	unsigned long flags;
+
+	if (++dest->try >= usk->maxtry) {
+		dest->insync = 0;
+		udpcp_flush_err(sk, dest);
+		udpcp_purge_incoming(sk, dest);
+		udpcp_dst_release(usk, dest);
+		return 0;
+	}
+
+	dest->txRetries++;
+	usk->stat.txRetries++;
+	spin_lock_irqsave(&spinlock, flags);
+	udpcp_stat.txRetries++;
+	spin_unlock_irqrestore(&spinlock, flags);
+
+	if (!dest->xmit_last)
+		_udpcp_xmit(sk, dest);
+	else {
+		skb = dest->xmit_wait;
+
+		for (;;) {
+			skbc = skb_clone(skb, sk->sk_allocation);
+
+			if (skbc == NULL)
+				break;
+
+			if (debug)
+				dump_msg("resend msg", skbc, dest->fl.fl4_src,
+					 dest->fl.fl4_dst);
+			err = udpcp_send_skb(sk, skbc, dest,
+						(struct ip_options *)skb->cb);
+			if (err) {
+				kfree_skb(skbc);
+				break;
+			}
+
+			if (skb == dest->xmit_last) {
+				_udpcp_xmit(sk, dest);
+				break;
+			}
+
+			skb = skb->next;
+		}
+	}
+	dest->tx_time = jiffies;
+
+	return 1;
+}
+
+/*
+ * Handle udpcp timeout
+ */
+static void udpcp_handle_timeout(struct sock *sk)
+{
+	struct udpcp_dest *dest;
+	struct list_head *p;
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	int wflag = 0;
+	unsigned long t = jiffies + UDPCP_MAX_WAIT_SEC * HZ + 1;
+	unsigned long flags;
+
+	usk->timeout = 0;
+
+	/*
+	 * walk through all destinations
+	 */
+	list_for_each(p, &usk->destlist) {
+		dest = list_to_udpcpdest(p);
+
+		if (dest->xmit_wait) {
+			if (time_is_before_eq_jiffies
+			    (dest->tx_time + usk->tx_timeout)) {
+				/*
+				 * transmit timeout expired
+				 */
+				if (debug)
+					dump_msg("send timeout",
+						 dest->xmit_wait,
+						 dest->fl.fl4_src,
+						 dest->fl.fl4_dst);
+				if (udpcp_resend(sk, dest) == 0) {
+					dest->txTimeout++;
+					usk->stat.txTimeout++;
+					spin_lock_irqsave(&spinlock, flags);
+					udpcp_stat.txTimeout++;
+					spin_unlock_irqrestore(&spinlock,
+							       flags);
+					goto check_incoming;
+				}
+				wflag = 1;
+			}
+			if (time_before(dest->tx_time + usk->tx_timeout, t)) {
+				/*
+				 * calculate new timeout timer value
+				 */
+				t = dest->tx_time + usk->tx_timeout;
+				wflag = 1;
+			}
+		}
+check_incoming:
+		if (dest->recv_msg) {
+			if (time_is_before_eq_jiffies
+			    (dest->rx_time + usk->rx_timeout)) {
+				/*
+				 * receive timeout occurred
+				 */
+				if (debug)
+					dump_msg("receive timeout",
+						 dest->recv_last,
+						 dest->fl.fl4_src,
+						 dest->fl.fl4_dst);
+				udpcp_purge_incoming(sk, dest);
+				dest->rxTimeout++;
+				usk->stat.rxTimeout++;
+				spin_lock_irqsave(&spinlock, flags);
+				udpcp_stat.rxTimeout++;
+				spin_unlock_irqrestore(&spinlock, flags);
+			} else
+			if (time_before(dest->rx_time + usk->rx_timeout, t)) {
+				/*
+				 * calculate new timeout timer value
+				 */
+				t = dest->rx_time + usk->rx_timeout;
+				wflag = 1;
+			}
+		}
+	}
+	/*
+	 * restart timer if necessary
+	 */
+	if (wflag)
+		udpcp_timer(sk, t);
+}
+
+/*
+ * Timeout function
+ */
+static void udpcp_timeout(unsigned long data)
+{
+	struct sock *sk = (struct sock *)data;
+	struct udpcp_sock *usk = udpcp_sk(sk);
+
+	bh_lock_sock(sk);
+	if (!sock_owned_by_user(sk))
+		udpcp_handle_timeout(sk);
+	else {
+		/*
+		 * bad, cannot handle the timeout because the socket is in use
+		 * set flag for unhandled timeout and rearm the timer
+		 */
+		usk->timeout = 1;
+		udpcp_timer(sk, jiffies + 1);
+	}
+	bh_unlock_sock(sk);
+}
+
+/*
+ * Handle timeout if an the unhandled timeout flag is set
+ */
+static inline void check_timeout(struct sock *sk)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+
+	while (usk->timeout) {
+		lock_sock(sk);
+		if (usk->timeout)
+			udpcp_handle_timeout(sk);
+		release_sock(sk);
+	}
+}
+
+/*
+ * Release the socket lock and test for unhandled timeouts
+ */
+static inline void udpcp_release_sock(struct sock *sk)
+{
+	release_sock(sk);
+	check_timeout(sk);
+}
+
+/*
+ * Parse sendmsg() control message
+ */
+static int udpcp_cmsg_send(struct msghdr *msg, u8 * ackmode, u8 * chkmode)
+{
+	struct cmsghdr *cmsg;
+
+	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+		if (cmsg->cmsg_level != SOL_UDPCP)
+			continue;
+		switch (cmsg->cmsg_type) {
+		case UDPCP_NOACK:
+		case UDPCP_ACK:
+		case UDPCP_SINGLE_ACK:
+			*ackmode = cmsg->cmsg_type;
+			break;
+		case UDPCP_CHECKSUM:
+		case UDPCP_NOCHECKSUM:
+			*chkmode = cmsg->cmsg_type;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+/*
+ * Validate a skb buffer
+ */
+static int udpcp_validate_skb(struct sk_buff *skb)
+{
+	if (skb->next) {
+		pr_err("udpcp: unexpected skb_buff->next != NULL\n");
+		BUG();
+		return 1;
+	}
+	if (skb_shinfo(skb)->frag_list) {
+		pr_err("udpcp: unexpected skb_shinfo(skb)->frag_list != NULL\n");
+		BUG();
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * Split a message into fragments and store it into the assemble queue
+ * mostly stolen from UDP stack
+ */
+static int udpcp_data(struct sock *sk, struct udpcp_dest *dest,
+		      int getfrag(void *from, char *to, int offset, int len,
+				  int odd, struct sk_buff *skb),
+		      struct iovec *from, int length, unsigned int flags)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
+	struct sk_buff *skb;
+	struct ipcm_cookie *ipc = &dest->ipc;
+	struct ip_options *opt = ipc->opt;
+	int hh_len;
+	int exthdrlen;
+	int mtu;
+	int copy;
+	int err;
+	int offset = 0;
+	unsigned int maxfraglen, fragheaderlen;
+	int csummode = CHECKSUM_NONE;
+	int transhdrlen = sizeof(struct udpcphdr);
+	struct rtable *rt = dest->rt;
+
+	if (opt && sizeof(skb->cb) < optlength(opt)) {
+		err = -EFAULT;
+		goto error;
+	}
+
+	usk->assembly_len += length;
+	usk->assembly_dest = dest;
+
+	if (usk->assembly_len > UDPCP_MAX_MSGSIZE) {
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, dest->fl.fl_ip_dport,
+				usk->assembly_len);
+		err = -EMSGSIZE;
+		goto error;
+	}
+
+	mtu = (inet->pmtudisc == IP_PMTUDISC_PROBE) ?
+		rt->dst.dev->mtu : dst_mtu(rt->dst.path);
+	sk->sk_sndmsg_page = NULL;
+	sk->sk_sndmsg_off = 0;
+	exthdrlen = rt->dst.header_len;
+	length += exthdrlen;
+	transhdrlen += exthdrlen;
+
+	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
+
+	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
+	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
+
+	if (rt->dst.dev->features & NETIF_F_V4_CSUM && !exthdrlen)
+		csummode = CHECKSUM_PARTIAL;
+
+	skb = skb_peek_tail(&usk->assembly);
+	if (skb) {
+		unsigned int off;
+
+		off = skb->len;
+
+		copy = mtu - skb->len;
+		if (copy > length)
+			copy = length;
+
+		if (copy > 0 &&
+		    getfrag(from, skb_put(skb, copy), 0, copy, off, skb) < 0) {
+			__skb_trim(skb, off);
+			err = -EFAULT;
+			goto error;
+		}
+		length -= copy;
+		offset += copy;
+
+		if (!length)
+			return 0;
+	}
+
+	do {
+		char *data;
+		unsigned int datalen;
+		unsigned int fraglen;
+		unsigned int alloclen;
+
+		length += transhdrlen;
+		/*
+		 * If remaining data exceeds the mtu,
+		 * we know we need more fragment(s).
+		 */
+		datalen = length;
+		if (datalen > mtu - fragheaderlen)
+			datalen = maxfraglen - fragheaderlen;
+		fraglen = datalen + fragheaderlen;
+
+		if ((flags & MSG_MORE)
+		    && !(rt->dst.dev->features & NETIF_F_SG))
+			alloclen = mtu;
+		else
+			alloclen = fraglen;
+
+		alloclen += rt->dst.trailer_len + hh_len + 15;
+
+		udpcp_release_sock(sk);
+		skb = sock_alloc_send_skb(sk, alloclen,
+					(flags & MSG_DONTWAIT), &err);
+		lock_sock(sk);
+		if (skb == NULL)
+			goto error;
+
+		if (udpcp_validate_skb(skb)) {
+			kfree_skb(skb);
+
+			goto error;
+		}
+
+		/*
+		 * Fill in the control structures
+		 */
+		skb->ip_summed = csummode;
+		skb->csum = 0;
+		skb_reserve(skb, hh_len);
+
+		/*
+		 * Find where to start putting bytes.
+		 */
+		data = skb_put(skb, fraglen);
+		skb_set_network_header(skb, exthdrlen);
+		skb->transport_header = (skb->network_header + fragheaderlen);
+		data += fragheaderlen;
+
+		copy = datalen - transhdrlen;
+
+		if (copy > 0 &&
+		  getfrag(from, data + transhdrlen, offset, copy, 0, skb) < 0) {
+			err = -EFAULT;
+			kfree_skb(skb);
+			goto error;
+		}
+
+		offset += copy;
+		length -= datalen;
+
+		if (ipc->opt)
+			memcpy(skb->cb, &ipc->opt, optlength(opt));
+
+		skb_pull(skb, fragheaderlen);
+		skb_queue_tail(&usk->assembly, skb);
+	} while (length > 0);
+
+	return 0;
+error:
+	skb_queue_purge(&usk->assembly);
+	usk->assembly_len = 0;
+
+	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
+	return err;
+}
+
+/*
+ * This function will be called by send(), sento() and sendmsg()
+ */
+static int udpcp_sendmsg(struct kiocb *iocb, struct sock *sk,
+			 struct msghdr *msg, size_t len)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	struct ipcm_cookie *ipc;
+	struct rtable *rt = NULL;
+	int free = 0;
+	int connected = 0;
+	__be32 daddr, faddr, saddr;
+	__be16 dport;
+	u8 tos;
+	int err = 0;
+	int corkreq = usk->udpsock.corkflag || msg->msg_flags & MSG_MORE;
+	int (*getfrag) (void *, char *, int, int, int, struct sk_buff *);
+	struct udpcp_dest *dest;
+
+	if (len > UDPCP_MAX_MSGSIZE)
+		return -EMSGSIZE;
+
+	/*
+	 * Check the flags.
+	 */
+	if (msg->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	/*
+	 * check if socket is binded to a port
+	 */
+	if (!(sk->sk_userlocks & SOCK_BINDPORT_LOCK) || !inet->inet_num)
+		return -ENOTCONN;
+
+	/*
+	 * Get and verify the address.
+	 */
+	if (msg->msg_name) {
+		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
+		if (msg->msg_namelen < sizeof(*usin))
+			return -EINVAL;
+		if (usin->sin_family != AF_INET) {
+			if (usin->sin_family != AF_UNSPEC)
+				return -EAFNOSUPPORT;
+		}
+
+		daddr = usin->sin_addr.s_addr;
+		dport = usin->sin_port;
+	} else {
+		if (sk->sk_state != TCP_ESTABLISHED)
+			return -EDESTADDRREQ;
+		daddr = inet->inet_daddr;
+		dport = inet->inet_dport;
+		/* Open fast path for connected socket.
+		   Route will not be used, if at least one option is set.
+		 */
+		connected = 1;
+	}
+
+	if (dport == 0)
+		return -EINVAL;
+
+	dest = find_dest(sk, daddr, dport);
+
+	if (!(dest->use_flag & TX_NODE)) {
+		unsigned long flags;
+
+		dest->use_flag |= TX_NODE;
+		usk->stat.txNodes++;
+
+		spin_lock_irqsave(&spinlock, flags);
+		udpcp_stat.txNodes++;
+		spin_unlock_irqrestore(&spinlock, flags);
+	}
+
+	ipc = &dest->ipc;
+
+	getfrag = IS_UDPLITE(sk) ? udplite_getfrag : ip_generic_getfrag;
+
+	if (!skb_queue_empty(&usk->assembly)) {
+		/*
+		 * assembly is ongoing
+		 */
+		lock_sock(sk);
+		if (likely(!skb_queue_empty(&usk->assembly))) {
+			if (usk->assembly_dest != dest) {
+				udpcp_release_sock(sk);
+				return -EUSERS;
+			}
+			ipc->opt =
+			    (struct ip_options *)skb_peek(&usk->assembly)->cb;
+			goto queue_data;
+		}
+		udpcp_release_sock(sk);
+	}
+
+	ipc->addr = inet->inet_saddr;
+	ipc->oif = sk->sk_bound_dev_if;
+
+	dest->ackmode = usk->ackmode;
+	dest->chkmode = usk->chkmode;
+
+	if (msg->msg_controllen) {
+		/*
+		 * handle control message
+		 */
+		err = udpcp_cmsg_send(msg, &dest->ackmode, &dest->chkmode);
+		if (err)
+			return err;
+		err = ip_cmsg_send(sock_net(sk), msg, ipc);
+		if (err)
+			return err;
+		if (ipc->opt)
+			free = 1;
+		connected = 0;
+	}
+
+	if (!ipc->opt)
+		ipc->opt = inet->opt;
+
+	saddr = ipc->addr;
+	ipc->addr = faddr = daddr;
+
+	if (ipc->opt && ipc->opt->srr) {
+		if (!daddr)
+			return -EINVAL;
+		faddr = ipc->opt->faddr;
+		connected = 0;
+	}
+	tos = RT_TOS(inet->tos);
+	if (sock_flag(sk, SOCK_LOCALROUTE) ||
+	    (msg->msg_flags & MSG_DONTROUTE) ||
+	    (ipc->opt && ipc->opt->is_strictroute)) {
+		tos |= RTO_ONLINK;
+		connected = 0;
+	}
+
+	if (ipv4_is_multicast(daddr)) {
+		if (dest->ackmode != UDPCP_NOACK) {
+			err = EOPNOTSUPP;
+			goto out;
+		}
+		if (!ipc->oif)
+			ipc->oif = inet->mc_index;
+		if (!saddr)
+			saddr = inet->mc_addr;
+		connected = 0;
+	}
+
+	lock_sock(sk);
+	rt = dest->rt;
+	if (rt)
+		goto queue_data;
+	udpcp_release_sock(sk);
+
+	/*
+	 * calculate routing
+	 */
+	if (connected)
+		rt = (struct rtable *)sk_dst_check(sk, 0);
+
+	if (rt == NULL) {
+		struct flowi fl = {.oif = ipc->oif,
+			.nl_u = {.ip4_u = {.daddr = faddr,
+					   .saddr = saddr,
+					   .tos = tos} },
+			.proto = sk->sk_protocol,
+			.uli_u = {.ports = {.sport = inet->inet_sport,
+					    .dport = dport} }
+		};
+		struct net *net = sock_net(sk);
+
+		security_sk_classify_flow(sk, &fl);
+		err = ip_route_output_flow(net, &rt, &fl, sk, 1);
+		if (err) {
+			if (err == -ENETUNREACH)
+				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+			goto out;
+		}
+
+		err = -EACCES;
+		if ((rt->rt_flags & RTCF_BROADCAST) &&
+		    !sock_flag(sk, SOCK_BROADCAST))
+			goto out;
+		if (connected)
+			sk_dst_set(sk, dst_clone(&rt->dst));
+	}
+
+	if (msg->msg_flags & MSG_CONFIRM)
+		goto do_confirm;
+back_from_confirm:
+
+	saddr = rt->rt_src;
+	if (!ipc->addr)
+		daddr = ipc->addr = rt->rt_dst;
+
+	lock_sock(sk);
+
+	dest->fl.fl4_dst = daddr;
+	dest->fl.fl_ip_dport = dport;
+	dest->fl.fl4_src = saddr;
+	dest->fl.fl_ip_sport = inet->inet_sport;
+	dest->rt = rt;
+
+queue_data:
+	if (msg->msg_flags & MSG_PROBE)
+		goto release;
+
+	if (!dest->insync && skb_queue_empty(&dest->xmit)) {
+		/*
+		 * if not synced, queue a SYNC message
+		 */
+		err = udpcp_data(sk, dest, getfrag, NULL, 0, 0);
+		if (err)
+			goto release;
+		dest->msgid = 0;
+		udpcp_queue_xmit(sk, dest, UDPCP_ACK, UDPCP_CHECKSUM);
+	}
+
+	/*
+	 * split message and store it to the assembly queue
+	 */
+	err = udpcp_data(sk, dest, getfrag, msg->msg_iov, len,
+		       corkreq ? msg->msg_flags | MSG_MORE : msg->msg_flags);
+	if (err)
+		goto release;
+
+	if (!dest->msgid)
+		dest->msgid = 1;
+
+	if (!corkreq) {
+		/*
+		 * message is complete, transfer it from the assembly queue
+		 * into the transmit queue
+		 */
+		udpcp_queue_xmit(sk, dest, dest->ackmode, dest->chkmode);
+		/*
+		 * start transmit if possible
+		 */
+		err = udpcp_xmit(sk, dest);
+	}
+release:
+	udpcp_release_sock(sk);
+out:
+	if (free)
+		kfree(ipc->opt);
+
+	if (!err)
+		return len;
+	/*
+	 * ENOBUFS = no kernel mem, SOCK_NOSPACE = no sndbuf space.  Reporting
+	 * ENOBUFS might not be good (it's not tunable per se), but otherwise
+	 * we don't have a good statistic (IpOutDiscards but it can be too many
+	 * things).  We could add another new stat but at least for now that
+	 * seems like overkill.
+	 */
+	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
+		UDP_INC_STATS_USER(sock_net(sk),
+				   UDP_MIB_SNDBUFERRORS, IS_UDPLITE(sk));
+	}
+	return err;
+
+do_confirm:
+	dst_confirm(&rt->dst);
+	if (!(msg->msg_flags & MSG_PROBE) || len)
+		goto back_from_confirm;
+
+	err = 0;
+	goto out;
+}
+
+/*
+ * Sendpage() is not really implemented
+ */
+static int udpcp_sendpage(struct sock *sk, struct page *page, int offset,
+			  size_t size, int flags)
+{
+	return sock_no_sendpage(sk->sk_socket, page, offset, size, flags);
+}
+
+/*
+ * Release all message fragments of the first in the transmit queue
+ */
+static void udpcp_release_xmit(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	struct sk_buff *skb;
+	struct udpcphdr *uh;
+
+	for (;;) {
+		skb = skb_dequeue(&dest->xmit);
+
+		uh = udpcp_hdr(skb);
+
+		if (udpcp_is_last_frag(uh) && uh->msgid) {
+			unsigned long flags;
+
+			usk->stat.txMsgs++;
+			spin_lock_irqsave(&spinlock, flags);
+			udpcp_stat.txMsgs++;
+			spin_unlock_irqrestore(&spinlock, flags);
+		}
+
+		udpcp_dec_pending(sk);
+
+		kfree_skb(skb);
+		if (skb == dest->xmit_last)
+			break;
+	}
+
+	dest->xmit_wait = 0;
+	dest->xmit_last = 0;
+	dest->try = 0;
+}
+
+/*
+ * Set the sync state
+ */
+static void udpcp_sync(struct sock *sk, struct udpcp_dest *dest)
+{
+	dest->xmit_wait = 0;
+	dest->xmit_last = 0;
+	dest->try = 0;
+	dest->acks = 0;
+	dest->insync = 1;
+}
+
+/*
+ * Returns true if the first message in the transmit queue is a sync message
+ */
+static inline int udpcp_xmit_is_sync(struct udpcp_dest *dest)
+{
+	struct sk_buff *skb = skb_peek(&dest->xmit);
+
+	return skb && !udpcp_hdr(skb)->msgid;
+}
+
+static inline struct udpcphdr *udpcp_ack_scan(struct sk_buff *skb)
+{
+	struct udpcphdr *uh;
+
+	for (;;) {
+		uh = udpcp_hdr(skb);
+
+		if (!(ntohs(uh->msginfo) & UDPCP_SINGLE_ACK_FLAG)
+		    || udpcp_is_last_frag(uh))
+			return uh;
+
+		skb = skb->next;
+	}
+}
+
+/*
+ * Handle an incoming ack
+ */
+static void udpcp_handle_ack(struct sock *sk, struct sk_buff *skb,
+			     struct udpcp_dest *dest)
+{
+	struct udpcphdr *r_uh;
+	struct udpcphdr *q_uh;
+
+	if (!dest->acks)
+		return;
+
+	r_uh = udpcp_hdr(skb);
+
+	/*
+	 * acks doesn't have a payload
+	 */
+	if (r_uh->length)
+		return;
+
+	q_uh = udpcp_ack_scan(dest->xmit_wait);
+
+	/*
+	 * message id, fragnum and fragamount must match the awaited message
+	 * fragment
+	 */
+	if (r_uh->msgid != q_uh->msgid)
+		return;
+
+	if (r_uh->fragnum != q_uh->fragnum)
+		return;
+
+	if (r_uh->fragamount != q_uh->fragamount)
+		return;
+
+	dest->acks--;
+
+	/*
+	 * if last fragment release message
+	 */
+	if (udpcp_is_last_frag(q_uh)) {
+		udpcp_release_xmit(sk, dest);
+
+		/*
+		 * special handling for sync messages
+		 */
+		if (r_uh->msgid == 0)
+			udpcp_sync(sk, dest);
+	} else
+		dest->xmit_wait = dest->xmit_wait->next;
+
+	/*
+	 * try to transmit next message/fragment
+	 */
+	udpcp_xmit(sk, dest);
+}
+
+/*
+ * Queue incoming message as owned by udpcp socket
+ */
+static void udpcp_set_owner_r(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct sk_buff *skb;
+
+	skb = dest->recv_msg;
+	skb_set_owner_r(skb, sk);
+
+	skb = skb_shinfo(skb)->frag_list;
+	if (!skb)
+		return;
+
+	for (;;) {
+		skb_set_owner_r(skb, sk);
+		if (udpcp_is_last_frag(udpcp_hdr(skb)))
+			break;
+		skb = skb->next;
+	}
+}
+
+/*
+ * Handle an incoming data message fragment
+ */
+static int udpcp_handle_data(struct sock *sk, struct sk_buff *skb,
+			     struct udpcp_dest *dest)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	struct udpcphdr *uh = udpcp_hdr(skb);
+	unsigned short msginfo = ntohs(uh->msginfo);
+	unsigned short length = ntohs(uh->length);
+
+	/*
+	 * special handling for sync messages
+	 */
+	if (uh->msgid == 0) {
+		/*
+		 * sync messages doesn't have a payload
+		 */
+		if (length)
+			return 1;
+
+		/*
+		 * sync messages doesn't have a ack rules
+		 */
+		if (msginfo & (UDPCP_NO_ACK_FLAG | UDPCP_SINGLE_ACK_FLAG))
+			return 1;
+
+		udpcp_send_ack(sk, skb, dest,
+			       memcmp(uh, &dest->lastmsg,
+				      sizeof(dest->lastmsg)) ? 0 : 1);
+
+		udpcp_purge_incoming(sk, dest);
+
+		/*
+		 * skip the first message in the queue if it is a sync messages
+		 */
+		if (udpcp_xmit_is_sync(dest)) {
+			dest->acks--;
+			udpcp_dec_pending(sk);
+			kfree_skb(skb_dequeue(&dest->xmit));
+		}
+
+		if (!dest->insync)
+			udpcp_sync(sk, dest);
+
+		udpcp_xmit(sk, dest);
+
+		return -1;
+	}
+
+	if (!dest->insync)
+		return 1;
+
+	if (length > UDPCP_MAX_MSGSIZE)
+		return 1;
+
+	length += sizeof(struct udpcphdr);
+
+	/*
+	 * if the message was still handled, send a duplicate ack
+	 */
+	if (!memcmp(uh, &dest->lastmsg, sizeof(dest->lastmsg))) {
+		udpcp_send_ack(sk, skb, dest, 1);
+		return 1;
+	}
+
+	if (dest->recv_msg) {
+		/*
+		 * if a fragment is already received validate the fragment
+		 */
+		if ((uh->msgid != udpcp_hdr(dest->recv_msg)->msgid) ||
+		    (uh->msginfo != udpcp_hdr(dest->recv_msg)->msginfo) ||
+		    (uh->length != udpcp_hdr(dest->recv_msg)->length) ||
+		    (uh->fragamount != udpcp_hdr(dest->recv_msg)->fragamount)
+		    ) {
+			udpcp_purge_incoming(sk, dest);
+			goto newmsg;
+		}
+
+		if (uh->fragnum != udpcp_hdr(dest->recv_last)->fragnum + 1)
+			return 1;
+
+		if (dest->recv_msg->len + skb->len - sizeof(struct udpcphdr) >
+		    length)
+			return 1;
+	} else {
+newmsg:
+		/*
+		 * first fragment must have the number 0
+		 */
+		if (uh->fragnum != 0)
+			return 1;
+
+		/*
+		 * UDPCP data length cannot be smaller then the UDP data length
+		 */
+		if (skb->len > length)
+			return 1;
+
+		/*
+		 * id of the last received is not valid
+		 */
+		if (dest->lastmsg.msgid == uh->msgid)
+			return 1;
+
+		/*
+		 * check against receive buffer limit
+		 */
+		if (atomic_read(&sk->sk_rmem_alloc) + length > sk->sk_rcvbuf)
+			return 1;
+	}
+
+	memset(&dest->lastmsg, 0, sizeof(dest->lastmsg));
+
+	if (!dest->recv_msg) {
+		/*
+		 * store the first message fragment
+		 */
+		if (skb->cloned) {
+			struct sk_buff *skbc;
+
+			skbc = skb_copy(skb, sk->sk_allocation);
+			if (skbc == NULL)
+				return 1;
+			kfree_skb(skb);
+			skb = skbc;
+		}
+		dest->recv_msg = skb;
+	} else {
+		/*
+		 * store the consecutively message fragment
+		 */
+		struct skb_shared_info *shinfo;
+
+		shinfo = skb_shinfo(dest->recv_msg);
+
+		if (!shinfo->frag_list)
+			shinfo->frag_list = skb;
+		else
+			dest->recv_last->next = skb;
+
+		skb_pull(skb, sizeof(struct udpcphdr));
+		dest->recv_msg->len += skb->len;
+		dest->recv_msg->data_len += skb->len;
+	}
+	dest->recv_last = skb;
+
+	msginfo = ntohs(uh->msginfo);
+
+	if (udpcp_is_last_frag(uh) || uh->fragamount == 0) {
+		/*
+		 * last fragment: queue it to the socket sk_receive_queue
+		 * and ack it
+		 */
+		unsigned long flags;
+
+		if (dest->recv_msg->len != length) {
+			udpcp_purge_incoming(sk, dest);
+			return 0;
+		}
+
+		if (!(msginfo & UDPCP_NO_ACK_FLAG))
+			udpcp_send_ack(sk, skb, dest, 0);
+
+		memcpy(dest->recv_msg->data + UDPCP_HDRSIZE,
+		       dest->recv_msg->data, sizeof(struct udphdr));
+		skb_pull(dest->recv_msg, UDPCP_HDRSIZE);
+
+		usk->stat.rxMsgs++;
+		spin_lock_irqsave(&spinlock, flags);
+		udpcp_stat.rxMsgs++;
+		spin_unlock_irqrestore(&spinlock, flags);
+
+		/*
+		 * set a flag for UDPCP message
+		 */
+		skb->cb[sizeof(struct udp_skb_cb)] = 1;
+
+		udpcp_set_owner_r(sk, dest);
+		skb_queue_tail(&sk->sk_receive_queue, dest->recv_msg);
+
+		/*
+		 * call the original data available handler
+		 */
+		if (usk->udp_data_ready)
+			usk->udp_data_ready(sk, dest->recv_msg->len);
+
+		dest->recv_msg = 0;
+		dest->recv_last = 0;
+	} else {
+		/*
+		 * ack fragment if requiered
+		 */
+		if (!(msginfo & UDPCP_NO_ACK_FLAG)
+		    && !(msginfo & UDPCP_SINGLE_ACK_FLAG))
+			udpcp_send_ack(sk, skb, dest, 0);
+
+		/*
+		 * setup timeout handler
+		 */
+		dest->rx_time = jiffies;
+
+		if (!timer_pending(&usk->timer))
+			udpcp_timer(sk, dest->rx_time + usk->rx_timeout);
+	}
+
+	return 0;
+}
+
+/*
+ * Deal with received UDPCP frames - sort out what type source it is
+ * and hand of it to the udpcp_handle_packet function.
+ */
+static void udpcp_data_ready(struct sock *sk, int slen)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	struct sk_buff *skb;
+	struct udpcp_dest *dest;
+	struct udpcphdr *uh;
+	unsigned short msginfo;
+	int ret;
+	unsigned long flags;
+
+	skb = skb_peek_tail(&sk->sk_receive_queue);
+
+	/*
+	 * don't handle NULL pointer buffer and UDPCP messages
+	 */
+	if (skb == NULL || skb->cb[sizeof(struct udp_skb_cb)]) {
+		if (usk->udp_data_ready)
+			usk->udp_data_ready(sk, slen);
+		return;
+	}
+
+	__skb_unlink(skb, &sk->sk_receive_queue);
+	if (udpcp_validate_skb(skb)) {
+		kfree_skb(skb);
+
+		return;
+	}
+
+	skb_orphan(skb);
+
+	/*
+	 * do UDP checksum
+	 */
+	if (udp_lib_checksum_complete(skb)) {
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
+				 IS_UDPLITE(sk));
+		return;
+	}
+
+	if (debug)
+		dump_msg("receive", skb, ip_hdr(skb)->saddr,
+			 ip_hdr(skb)->daddr);
+
+	uh = udpcp_hdr(skb);
+	msginfo = ntohs(uh->msginfo);
+
+	/*
+	 * handle only UDPCP protocol version 2
+	 */
+	if ((msginfo & UDPCP_PROTOCOL_MASK) != UDPCP_PROTOCOL_VERSION_2) {
+		kfree_skb(skb);
+		return;
+	}
+
+	/*
+	 * handle UDPCP checksum
+	 */
+	if (msginfo & UDPCP_CHECKSUM_FLAG) {
+		u8 *data;
+		u32 data_len;
+		u32 chksum;
+
+		chksum = ntohl(uh->chksum);
+		data = (u8 *) skb->data + sizeof(struct udphdr);
+		data_len = skb->len - sizeof(struct udphdr);
+
+		uh->chksum = 0;
+
+		if (chksum != zlib_adler32(1, data, data_len)) {
+			kfree_skb(skb);
+			usk->stat.crcErrors++;
+			spin_lock_irqsave(&spinlock, flags);
+			udpcp_stat.crcErrors++;
+			spin_unlock_irqrestore(&spinlock, flags);
+			return;
+		}
+	}
+
+	dest = __find_dest(sk, ip_hdr(skb)->saddr, udp_hdr(skb)->source);
+
+	if (!dest) {
+		/*
+		 * new communication destination must start with an sync message
+		 */
+		if (((msginfo & UDPCP_MSG_TYPE_MASK) != UDPCP_MSG_TYPE_DATA) ||
+		    (uh->msgid != 0)) {
+			kfree_skb(skb);
+			return;
+		}
+
+		dest = new_dest(sk, ip_hdr(skb)->saddr, udp_hdr(skb)->source);
+
+		if (!dest) {
+			kfree_skb(skb);
+			return;
+		}
+	}
+
+	/*
+	 * handle message type
+	 */
+	switch (msginfo & UDPCP_MSG_TYPE_MASK) {
+	case UDPCP_MSG_TYPE_DATA:
+		if (!(dest->use_flag & RX_NODE)) {
+			dest->use_flag |= RX_NODE;
+			usk->stat.rxNodes++;
+			spin_lock_irqsave(&spinlock, flags);
+			udpcp_stat.rxNodes++;
+			spin_unlock_irqrestore(&spinlock, flags);
+		}
+
+		ret = udpcp_handle_data(sk, skb, dest);
+
+		if (ret > 0) {
+			dest->rxDiscardedFrags++;
+			usk->stat.rxDiscardedFrags++;
+			spin_lock_irqsave(&spinlock, flags);
+			udpcp_stat.rxDiscardedFrags++;
+			spin_unlock_irqrestore(&spinlock, flags);
+		}
+		break;
+	case UDPCP_MSG_TYPE_ACK:
+		udpcp_handle_ack(sk, skb, dest);
+	default:
+		ret = 1;
+		break;
+	}
+	if (ret)
+		kfree_skb(skb);
+}
+
+/*
+ * Set socket options
+ */
+static int udpcp_setsockopt(struct sock *sk, int level, int optname,
+			    char __user *optval, unsigned int optlen)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	int val, ret;
+
+	if (level != SOL_UDPCP) {
+		if (udp_prot.setsockopt) {
+			ret = udp_prot.setsockopt(sk, level, optname, optval,
+						optlen);
+			check_timeout(sk);
+			return ret;
+		}
+		return -ENOPROTOOPT;
+	}
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	switch (optname) {
+	case UDPCP_OPT_TRANSFER_MODE:
+		switch (val) {
+		case UDPCP_NOACK:
+		case UDPCP_ACK:
+		case UDPCP_SINGLE_ACK:
+			usk->ackmode = val;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDPCP_OPT_CHECKSUM_MODE:
+		switch (val) {
+		case UDPCP_NOCHECKSUM:
+		case UDPCP_CHECKSUM:
+			usk->chkmode = val;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+
+	case UDPCP_OPT_TX_TIMEOUT:
+		if ((val < 1) || (val > UDPCP_MAX_WAIT_SEC * 1000))
+			return -EINVAL;
+		usk->tx_timeout = msecs_to_jiffies(val);
+		break;
+
+	case UDPCP_OPT_RX_TIMEOUT:
+		if ((val < 1) || (val > UDPCP_MAX_WAIT_SEC * 1000))
+			return -EINVAL;
+		usk->rx_timeout = msecs_to_jiffies(val);
+		break;
+
+	case UDPCP_OPT_MAXTRY:
+		if ((val < 1) || (val > 10))
+			return -EINVAL;
+		usk->maxtry = val;
+		break;
+
+	case UDPCP_OPT_OUTSTANDING_ACKS:
+		if ((val < 1) || (val > 255))
+			return -EINVAL;
+		usk->acks = val;
+		break;
+
+	default:
+		return -ENOPROTOOPT;
+	}
+	return 0;
+}
+
+/*
+ * Get socket options
+ */
+static int udpcp_getsockopt(struct sock *sk, int level, int optname,
+			    char __user *optval, int __user *optlen)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	int val, len, ret;
+
+	if (level != SOL_UDPCP) {
+		if (udp_prot.getsockopt) {
+			ret = udp_prot.getsockopt(sk, level, optname, optval,
+						optlen);
+			check_timeout(sk);
+			return ret;
+		}
+		return -ENOPROTOOPT;
+	}
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+
+	len = min_t(unsigned int, len, sizeof(int));
+
+	if (len < 0)
+		return -EINVAL;
+
+	switch (optname) {
+	case UDPCP_OPT_TRANSFER_MODE:
+		val = usk->ackmode;
+		break;
+
+	case UDPCP_OPT_CHECKSUM_MODE:
+		val = usk->chkmode;
+		break;
+
+	case UDPCP_OPT_TX_TIMEOUT:
+		val = jiffies_to_msecs(usk->tx_timeout);
+		break;
+
+	case UDPCP_OPT_MAXTRY:
+		val = usk->maxtry;
+		break;
+
+	case UDPCP_OPT_OUTSTANDING_ACKS:
+		val = usk->acks;
+		break;
+
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+	return 0;
+}
+
+/*
+ * ioctl() requests applicable to the UDPCP protocol
+ */
+int udpcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
+{
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	int ret = 0;
+
+	switch (cmd) {
+	case UDPCP_IOCTL_GET_STATISTICS:
+		lock_sock(sk);
+		if (copy_to_user((void *)arg, &usk->stat, sizeof(usk->stat)))
+			ret = -EFAULT;
+		udpcp_release_sock(sk);
+		break;
+
+	case UDPCP_IOCTL_RESET_STATISTICS:
+		lock_sock(sk);
+		usk->stat.txMsgs = 0;
+		usk->stat.rxMsgs = 0;
+		usk->stat.txTimeout = 0;
+		usk->stat.rxTimeout = 0;
+		usk->stat.txRetries = 0;
+		usk->stat.rxDiscardedFrags = 0;
+		usk->stat.crcErrors = 0;
+		udpcp_release_sock(sk);
+		break;
+
+	case UDPCP_IOCTL_SYNC:
+		if (arg)
+			ret = wait_event_interruptible_timeout(usk->wq,
+				!usk->pending, msecs_to_jiffies(arg));
+		else
+			ret = wait_event_interruptible(usk->wq, !usk->pending);
+
+		break;
+
+	default:
+		if (udp_prot.ioctl) {
+			ret = udp_prot.ioctl(sk, cmd, arg);
+			check_timeout(sk);
+		} else
+			ret = -ENOIOCTLCMD;
+		break;
+	}
+	return ret;
+}
+
+/*
+ * This function will be called by recv(), recvfrom() and revmsg()
+ */
+int udpcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		  size_t len, int noblock, int flags, int *addr_len)
+{
+	int ret;
+
+	ret = udp_prot.recvmsg(iocb, sk, msg, len, noblock, flags, addr_len);
+	check_timeout(sk);
+	return ret;
+}
+
+/*
+ * This function will be called by socket() and initialized the socket
+ */
+static int udpcp_sockinit(struct sock *sk)
+{
+	int ret;
+	struct udpcp_sock *usk;
+	unsigned long flags;
+
+	sk->sk_protocol = SOL_UDP;
+	sk->sk_allocation = GFP_ATOMIC;
+	if (udp_prot.init) {
+		ret = udp_prot.init(sk);
+
+		if (ret)
+			return ret;
+	}
+
+	usk = udpcp_sk(sk);
+	usk->timer.expires = 0;
+	usk->timer.function = udpcp_timeout;
+	usk->timer.data = (long)sk;
+	init_timer(&usk->timer);
+	INIT_LIST_HEAD(&usk->destlist);
+	init_waitqueue_head(&usk->wq);
+	usk->pending = 0;
+	usk->ackmode = UDPCP_ACK;
+	usk->chkmode = UDPCP_CHECKSUM;
+	usk->maxtry = UDPCP_TX_MAXTRY;
+	usk->acks = UDPCP_OUTSTANDING_ACKS;
+	usk->tx_timeout = msecs_to_jiffies(UDPCP_TX_TIMEOUT);
+	usk->rx_timeout = msecs_to_jiffies(UDPCP_RX_TIMEOUT);
+	usk->udp_data_ready = sk->sk_data_ready;
+	sk->sk_data_ready = udpcp_data_ready;
+	usk->udpsock.pending = 0;
+	skb_queue_head_init(&usk->assembly);
+	usk->assembly_len = 0;
+	usk->assembly_dest = NULL;
+
+	spin_lock_irqsave(&spinlock, flags);
+	list_add_tail(&usk->udpcplist, &udpcp_list);
+
+	spin_unlock_irqrestore(&spinlock, flags);
+
+#ifdef MODULE
+	try_module_get(THIS_MODULE);
+#endif
+	return 0;
+}
+
+/*
+ * This function will be called by close()
+ */
+static void udpcp_destroy(struct sock *sk)
+{
+	struct list_head *p;
+	struct list_head *n;
+	struct udpcp_sock *usk = udpcp_sk(sk);
+	unsigned long flags;
+
+	spin_lock_irqsave(&spinlock, flags);
+	list_del(&usk->udpcplist);
+	spin_unlock_irqrestore(&spinlock, flags);
+
+	if (udp_prot.destroy)
+		udp_prot.destroy(sk);
+
+	lock_sock(sk);
+
+	del_timer_sync(&usk->timer);
+	sk->sk_data_ready = usk->udp_data_ready;
+
+	skb_queue_purge(&usk->assembly);
+
+	list_for_each_safe(p, n, &usk->destlist) {
+		struct udpcp_dest *dest;
+
+		dest = list_to_udpcpdest(p);
+
+		skb_queue_purge(&dest->xmit);
+
+		kfree_skb(dest->recv_msg);
+
+		if (dest->rt)
+			dst_release(&dest->rt->dst);
+
+		kfree(dest);
+	}
+
+	spin_lock_irqsave(&spinlock, flags);
+	udpcp_stat.txNodes -= usk->stat.txNodes;
+	udpcp_stat.rxNodes -= usk->stat.rxNodes;
+	spin_unlock_irqrestore(&spinlock, flags);
+
+	usk->pending = 0;
+
+	if (waitqueue_active(&usk->wq))
+		wake_up_interruptible(&usk->wq);
+
+	release_sock(sk);
+
+#ifdef MODULE
+	module_put(THIS_MODULE);
+#endif
+}
+
+static struct proto udpcp_prot;
+
+/*
+ * inet protocol stack descriptor
+ */
+static struct inet_protosw udpcp_protosw = {
+	.type = SOCK_DGRAM,
+	.protocol = PF_UDPCP,
+	.prot = &udpcp_prot,
+	.ops = &inet_dgram_ops,
+	.no_check = UDP_CSUM_DEFAULT,
+	.flags = 0,
+};
+
+#ifdef CONFIG_PROC_FS
+/*
+ * The following functions handles the /proc/net/udpcp entry
+ */
+struct udpcp_seq_afinfo {
+	char *name;
+	const struct file_operations seq_fops;
+	const struct seq_operations seq_ops;
+};
+
+struct udpcp_iter_state {
+	struct seq_net_private p;
+	struct sock *sk;
+	struct udpcp_dest *dest;
+	int bucket;
+};
+
+static void *udpcp_get_first(struct seq_file *seq)
+{
+	struct udpcp_sock *usk;
+	struct list_head *p;
+	struct udpcp_iter_state *state = seq->private;
+	unsigned long flags;
+
+	spin_lock_irqsave(&spinlock, flags);
+	list_for_each(p, &udpcp_list) {
+		usk = list_to_udpcpsock(p);
+
+		if (!list_empty(&usk->destlist)) {
+			state->sk = (struct sock *)usk;
+			state->dest = list_first_entry(&usk->destlist,
+					struct udpcp_dest, list);
+			sock_hold(state->sk);
+
+			if (atomic_read(&state->sk->sk_refcnt) != 1) {
+				spin_unlock_irqrestore(&spinlock, flags);
+				return state;
+			}
+			atomic_dec(&state->sk->sk_refcnt);
+		}
+
+		state->bucket++;
+	}
+	spin_unlock_irqrestore(&spinlock, flags);
+	return 0;
+}
+
+static void *udpcp_get_next(struct seq_file *seq)
+{
+	struct udpcp_iter_state *state = seq->private;
+	unsigned long flags;
+	struct udpcp_sock *usk;
+	struct sock *sk;
+
+	if (!state)
+		return NULL;
+
+	sk = state->sk;
+
+	if (!sk)
+		return NULL;
+
+	usk = udpcp_sk(sk);
+
+	if (!list_is_last(&state->dest->list, &usk->destlist)) {
+		state->dest =
+		    list_entry(state->dest->list.next, struct udpcp_dest, list);
+		state->bucket++;
+		return state;
+	}
+
+	spin_lock_irqsave(&spinlock, flags);
+	while (!list_is_last(&usk->udpcplist, &udpcp_list)) {
+		state->bucket++;
+
+		usk = list_entry(usk->udpcplist.next, struct udpcp_sock,
+			       udpcplist);
+		if (!list_empty(&usk->destlist)) {
+			state->sk = (struct sock *)usk;
+			state->dest = list_first_entry(&usk->destlist,
+					struct udpcp_dest, list);
+			sock_hold(state->sk);
+			if (atomic_read(&state->sk->sk_refcnt) != 1) {
+				sock_put(sk);
+				spin_unlock_irqrestore(&spinlock, flags);
+				return state;
+			}
+			atomic_dec(&state->sk->sk_refcnt);
+		}
+	}
+	spin_unlock_irqrestore(&spinlock, flags);
+
+	sock_put(sk);
+	state->sk = NULL;
+	return NULL;
+}
+
+static void *udpcp_get_idx(struct seq_file *seq, loff_t pos)
+{
+	if (!udpcp_get_first(seq))
+		return NULL;
+
+	while (pos--) {
+		if (!udpcp_get_next(seq))
+			return NULL;
+	}
+	return seq->private;
+}
+
+static void *udpcp_seq_start(struct seq_file *seq, loff_t * pos)
+{
+	return *pos ? udpcp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+}
+
+static void *udpcp_seq_next(struct seq_file *seq, void *v, loff_t * pos)
+{
+	void *private;
+
+	if (v == SEQ_START_TOKEN)
+		private = udpcp_get_idx(seq, 0);
+	else
+		private = udpcp_get_next(seq);
+
+	++*pos;
+	return private;
+}
+
+static void udpcp_seq_stop(struct seq_file *seq, void *v)
+{
+	struct udpcp_iter_state *state = seq->private;
+
+	if (state->sk)
+		sock_put(state->sk);
+}
+
+static int udpcp_seq_open(struct inode *inode, struct file *file)
+{
+	struct udpcp_seq_afinfo *afinfo = PDE(inode)->data;
+	struct udpcp_iter_state *state;
+	int err;
+
+	err = seq_open_net(inode, file, &afinfo->seq_ops,
+			   sizeof(struct udpcp_iter_state));
+	if (err < 0)
+		return err;
+
+	state = ((struct seq_file *)file->private_data)->private;
+	state->sk = 0;
+	state->dest = 0;
+	return err;
+}
+
+int udpcp_proc_register(struct net *net, struct udpcp_seq_afinfo *afinfo)
+{
+	struct proc_dir_entry *p;
+	int rc = 0;
+
+	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
+			     &afinfo->seq_fops, afinfo);
+	if (!p)
+		rc = -ENOMEM;
+	return rc;
+}
+
+void udpcp_proc_unregister(struct net *net, struct udpcp_seq_afinfo *afinfo)
+{
+	proc_net_remove(net, afinfo->name);
+}
+
+static unsigned int udpcp_tx_queue_len(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct sk_buff *skb;
+	unsigned int n;
+
+	n = 0;
+	lock_sock(sk);
+	skb_queue_walk(&dest->xmit, skb)
+	    n += skb->len;
+	udpcp_release_sock(sk);
+	return n;
+}
+
+static unsigned int udpcp_rx_queue_len(struct sock *sk, struct udpcp_dest *dest)
+{
+	struct sk_buff *skb;
+	unsigned int n;
+
+	n = 0;
+	lock_sock(sk);
+	skb_queue_walk(&sk->sk_receive_queue, skb) {
+		if (udp_hdr(skb)->source == dest->port
+		    && ip_hdr(skb)->saddr == dest->addr)
+			n += skb->len;
+	}
+	udpcp_release_sock(sk);
+	return n;
+}
+
+static void udpcp_format_sock(struct seq_file *seq, int *len)
+{
+	struct udpcp_iter_state *state = seq->private;
+	struct sock *sk = state->sk;
+	struct inet_sock *inet = inet_sk(sk);
+	__be32 src = inet->inet_rcv_saddr;
+	__u16 srcp = ntohs(inet->inet_sport);
+	__be32 dest = state->dest->addr;
+	__u16 destp = ntohs(state->dest->port);
+
+	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
+		   " %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %u%n",
+		   state->bucket, src, srcp, dest, destp, sk->sk_state,
+		   udpcp_tx_queue_len(sk, state->dest),
+		   udpcp_rx_queue_len(sk, state->dest),
+		   0, 0L, state->dest->txRetries, sock_i_uid(sk),
+		   state->dest->txTimeout, sock_i_ino(sk),
+		   atomic_read(&sk->sk_refcnt), sk, state->dest->rxTimeout,
+		   len);
+}
+
+int udpcp_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_printf(seq, "%-127s\n",
+			   "  sl  local_address rem_address   st tx_queue "
+			   "rx_queue tr tm->when retrnsmt   uid  timeout "
+			   "inode ref pointer drops");
+	else {
+		int len;
+
+		udpcp_format_sock(seq, &len);
+		seq_printf(seq, "%*s\n", 127 - len, "");
+	}
+	return 0;
+}
+
+static struct udpcp_seq_afinfo udpcp_seq_afinfo = {
+	.name = "udpcp",
+	.seq_fops = {
+			.owner = THIS_MODULE,
+			.open = udpcp_seq_open,
+			.read = seq_read,
+			.llseek = seq_lseek,
+			.release = seq_release_net,
+		     },
+	.seq_ops = {
+			.show = udpcp_seq_show,
+			.start = udpcp_seq_start,
+			.next = udpcp_seq_next,
+			.stop = udpcp_seq_stop,
+		    },
+};
+
+static int udpcp_proc_init_net(struct net *net)
+{
+	return udpcp_proc_register(net, &udpcp_seq_afinfo);
+}
+
+static void udpcp_proc_exit_net(struct net *net)
+{
+	udpcp_proc_unregister(net, &udpcp_seq_afinfo);
+}
+
+static struct pernet_operations udpcp_net_ops = {
+	.init = udpcp_proc_init_net,
+	.exit = udpcp_proc_exit_net,
+};
+
+int __init udpcp_proc_init(void)
+{
+	return register_pernet_subsys(&udpcp_net_ops);
+}
+
+void udpcp_proc_exit(void)
+{
+	unregister_pernet_subsys(&udpcp_net_ops);
+}
+#endif /* CONFIG_PROC_FS */
+
+/*
+ * Install and init module
+ */
+static int __init udpcp_init(void)
+{
+	int ret;
+	struct proc_dir_entry *proc_entry = NULL;
+
+	spin_lock_init(&spinlock);
+
+	INIT_LIST_HEAD(&udpcp_list);
+
+	/*
+	 * to prevent to rewrite the whole UDP protocol,
+	 * assign struct proto udp to the struct proto udpcp
+	 */
+	udpcp_prot = udp_prot;
+
+	/*
+	 * change the protocol name
+	 */
+	strcpy(udpcp_prot.name, "UDPCP");
+
+	/*
+	 * overload the following function, all other
+	 * functions will use the UDP protocol functions
+	 */
+	udpcp_prot.sendmsg = udpcp_sendmsg;
+	udpcp_prot.sendpage = udpcp_sendpage;
+	udpcp_prot.init = udpcp_sockinit;
+	udpcp_prot.destroy = udpcp_destroy;
+	udpcp_prot.setsockopt = udpcp_setsockopt;
+	udpcp_prot.getsockopt = udpcp_getsockopt;
+	udpcp_prot.ioctl = udpcp_ioctl;
+	udpcp_prot.recvmsg = udpcp_recvmsg;
+
+	/*
+	 * fix the object size for the embedded udpcp_sock structure
+	 */
+	udpcp_prot.obj_size = sizeof(struct udpcp_sock);
+
+	/*
+	 * register the UDPCP protocol
+	 */
+	ret = proto_register(&udpcp_prot, 1);
+	if (ret)
+		return ret;
+
+	/*
+	 * register the inet socket for UDPCP
+	 */
+	inet_register_protosw(&udpcp_protosw);
+
+#ifdef CONFIG_PROC_FS
+	/*
+	 * register /proc/driver/udpcp entry
+	 */
+	proc_entry =
+	    create_proc_read_entry(UDPCP_PROC, S_IRUSR | S_IRGRP | S_IROTH,
+				   NULL, udpcp_proc, NULL);
+
+	if (!proc_entry) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	/*
+	 * register /proc/net/udpcp entry
+	 */
+	ret = udpcp_proc_init();
+
+	if (ret)
+		goto err;
+#endif
+	pr_info("UDPCP protocol stack version " VERSION "\n");
+	return 0;
+#ifdef CONFIG_PROC_FS
+err:
+	if (proc_entry)
+		remove_proc_entry(UDPCP_PROC, NULL);
+	proto_unregister(&udpcp_prot);
+	return ret;
+#endif
+}
+
+/*
+ * Cleanup and exit module
+ */
+static void __exit udpcp_exit(void)
+{
+#ifdef CONFIG_PROC_FS
+	udpcp_proc_exit();
+	remove_proc_entry(UDPCP_PROC, NULL);
+#endif
+	inet_unregister_protosw(&udpcp_protosw);
+	proto_unregister(&udpcp_prot);
+}
+
+module_init(udpcp_init);
+module_exit(udpcp_exit);
+
+MODULE_AUTHOR("Stefani Seibold <stefani@seibold.net>");
+MODULE_DESCRIPTION("UDPCP protocol stack v" VERSION);
+MODULE_LICENSE("GPL");
+
-- 
1.7.3.4
