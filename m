From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCHv3  2/4][RFC]     net/ipv4: self-contained UDP-Lite module
Date: Tue, 19 Sep 2006 08:25:30 +0100
Message-ID: <200609190825.30341@strip-the-willow>
References: <200607141719.02766@strip-the-willow> <20060727.223010.63131639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:45045 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1751111AbWISHZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 03:25:43 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060727.223010.63131639.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The self-contained UDP-Litev4 module for v4; logically completely separate from ipv4/udp.c.

--
include/net/udplite.h |   86 +++++++++++++++++++++++
 net/ipv4/udplite.c    |  186 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 272 insertions(+)


diff --git a/include/net/udplite.h b/include/net/udplite.h
new file mode 100644
index 0000000..90d7aec
--- /dev/null
+++ b/include/net/udplite.h
@@ -0,0 +1,86 @@
+/*
+ *	Definitions for the UDP-Lite (RFC 3828) code.
+ */
+#ifndef _UDPLITE_H
+#define _UDPLITE_H
+
+/* UDP-Lite socket options */
+#define UDPLITE_SEND_CSCOV   10 /* sender partial coverage (as sent)      */
+#define UDPLITE_RECV_CSCOV   11 /* receiver partial coverage (threshold ) */
+
+extern struct proto 		udplite_prot;
+extern struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
+
+/* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
+DECLARE_SNMP_STAT(struct udp_mib, udplite_statistics);
+
+/*
+ *	Checksum computation is all in software, hence simpler getfrag.
+ */
+static __inline__ int udplite_getfrag(void *from, char *to, int  offset,
+				      int len, int odd, struct sk_buff *skb)
+{
+	return memcpy_fromiovecend(to, (struct iovec *) from, offset, len);
+}
+
+/*
+ * 	Functions used by UDP-Litev4 and UDP-Litev6
+ */
+/* calculate checksum coverage set for outgoing packets */
+static inline int udplite_sender_cscov(struct udp_sock *up, struct udphdr *uh)
+{
+	int cscov = up->len;
+
+	/*
+	 * Sender has set `partial coverage' option on UDP-Lite socket
+	 */
+	if (up->pcflag & UDPLITE_SEND_CC)    {
+		if (up->pcslen < up->len) {
+		/* up->pcslen == 0 means that full coverage is required,
+		 * partial coverage only if  0 < up->pcslen < up->len */
+			if (0 < up->pcslen) {
+			       cscov = up->pcslen;
+			}
+			uh->len = htons(up->pcslen);
+		}
+	/*
+	 * NOTE: Causes for the error case  `up->pcslen > up->len':
+	 *        (i)  Application error (will not be penalized).
+	 *       (ii)  Payload too big for send buffer: data is split
+	 *             into several packets, each with its own header.
+	 *             In this case (e.g. last segment), coverage may
+	 *             exceed packet length.
+	 *       Since packets with coverage length > packet length are
+	 *       illegal, we fall back to the defaults here.
+	 */
+	}
+	return cscov;
+}
+
+static inline u32 udplite_csum_outgoing(struct sock *sk, int cscov)
+{
+	struct sk_buff *skb;
+	int off, len;
+	u32 csum = 0;
+
+	skb_queue_walk(&sk->sk_write_queue, skb) {
+		off = skb->h.raw - skb->data;
+		len = skb->len - off;
+
+		csum = skb_checksum(skb, off, (cscov > len)? len : cscov, csum);
+
+		if ((cscov -= len) <= 0)
+			break;
+	}
+	return csum;
+}
+
+/*
+ *  	net/ipv4/udplite.c
+ */
+extern void	udplite4_register(void);
+extern int 	udplite_get_port(struct sock *sk, unsigned short snum,
+			int (*scmp)(const struct sock *, const struct sock *));
+extern int	udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh,
+				      u16 len, u32 saddr, u32 daddr          );
+#endif	/* _UDPLITE_H */
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
new file mode 100644
index 0000000..7f6498d
--- /dev/null
+++ b/net/ipv4/udplite.c
@@ -0,0 +1,186 @@
+/*
+ *  UDPLITE     An implementation of the UDP-Lite protocol (RFC 3828).
+ *
+ *  Version:    $Id: udplite.c,v 1.24 2006/09/18 21:50:59 gerrit Exp gerrit $
+ *
+ *  Authors:    Gerrit Renker       <gerrit@erg.abdn.ac.uk>
+ *
+ *  Changes:
+ *  Fixes:
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+
+struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
+static int  		udplite_port_rover;
+DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics)	__read_mostly;
+
+/* Designate sk as UDP-Lite socket */
+static	inline int udplite_sk_init(struct sock *sk)
+{
+	udp_sk(sk)->pcflag = UDPLITE_BIT;
+	return 0;
+}
+
+__inline__ int udplite_get_port(struct sock *sk, unsigned short p,
+			int (*c)(const struct sock *, const struct sock *))
+{
+	return  __udp_lib_get_port(sk, p, udplite_hash, &udplite_port_rover, c);
+}
+
+static __inline__ int udplite_v4_get_port(struct sock *sk, unsigned short snum)
+{
+	return udplite_get_port(sk, snum, ipv4_rcv_saddr_equal);
+}
+
+static __inline__ struct sock *udplite_v4_lookup(u32 saddr, u16 sport,
+						 u32 daddr, u16 dport, int dif)
+{
+	return __udp4_lib_lookup(saddr, sport, daddr, dport, dif, udplite_hash);
+}
+
+static __inline__ int udplite_v4_mcast_deliver(struct sk_buff *skb,
+					struct udphdr *uh, u32 saddr, u32 daddr)
+{
+	return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udplite_hash);
+}
+
+__inline__ void udplite_err(struct sk_buff *skb, u32 info)
+{
+	return __udp4_lib_err(skb, info, udplite_hash);
+}
+
+int udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh,
+			  u16 len, u32 saddr, u32 daddr          )
+{
+	u16 cscov;
+
+        /* In UDPv4 a zero checksum means that the transmitter generated no
+         * checksum. UDP-Lite (like IPv6) mandates checksums, hence packets
+         * with a zero checksum field are illegal.                            */
+	if (uh->check == 0) {
+		LIMIT_NETDEBUG(KERN_DEBUG "UDPLITE: zeroed csum field"
+	                "(%d.%d.%d.%d:%d -> %d.%d.%d.%d:%d)\n", NIPQUAD(saddr),
+			ntohs(uh->source), NIPQUAD(daddr), ntohs(uh->dest)    );
+		return 0;
+	}
+
+        UDP_SKB_CB(skb)->partial_cov = 0;
+        cscov = ntohs(uh->len);
+
+	if (cscov == 0)		 /* Indicates that full coverage is required. */
+		cscov = len;
+	else if (cscov < 8  || cscov > len) {
+		/*
+		 * Coverage length violates RFC 3828: log and discard silently.
+		 */
+		LIMIT_NETDEBUG(KERN_DEBUG "UDPLITE: bad csum coverage %d/%d "
+			"(%d.%d.%d.%d:%d -> %d.%d.%d.%d:%d)\n", cscov, len,
+			NIPQUAD(saddr), ntohs(uh->source),
+			NIPQUAD(daddr), ntohs(uh->dest)                       );
+		return 0;
+
+	} else if (cscov < len)
+        	UDP_SKB_CB(skb)->partial_cov = 1;
+
+        UDP_SKB_CB(skb)->cscov = cscov;
+
+	/*
+	 * 	Initialise pseudo-header for checksum computation.
+	 *
+	 * 	There is no known NIC manufacturer supporting UDP-Lite yet,
+	 * 	hence ip_summed is always (re-)set to CHECKSUM_NONE.
+	 */
+	skb->csum = csum_tcpudp_nofold(saddr, daddr, len, IPPROTO_UDPLITE, 0);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return 1;
+}
+
+__inline__ int udplite_rcv(struct sk_buff *skb)
+{
+	return __udp4_lib_rcv(skb, udplite_hash, 1);
+}
+
+struct proto 	udplite_prot = {
+	.name		   = "UDP-Lite",
+	.owner		   = THIS_MODULE,
+	.close		   = udp_close,
+	.connect	   = ip4_datagram_connect,
+	.disconnect	   = udp_disconnect,
+	.ioctl		   = udp_ioctl,
+	.init		   = udplite_sk_init,
+	.destroy	   = udp_destroy_sock,
+	.setsockopt	   = udp_setsockopt,
+	.getsockopt	   = udp_getsockopt,
+	.sendmsg	   = udp_sendmsg,
+	.recvmsg	   = udp_recvmsg,
+	.sendpage	   = udp_sendpage,
+	.backlog_rcv	   = udp_queue_rcv_skb,
+	.hash		   = udp_lib_hash,
+	.unhash		   = udp_lib_unhash,
+	.get_port	   = udplite_v4_get_port,
+	.obj_size	   = sizeof(struct udp_sock),
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_udp_setsockopt,
+	.compat_getsockopt = compat_udp_getsockopt,
+#endif
+};
+
+static	struct net_protocol udplite_protocol = {
+	.handler	= udplite_rcv,
+	.err_handler	= udplite_err,
+	.no_policy	= 1,
+};
+
+static struct inet_protosw udplite4_protosw = {
+	.type		=  SOCK_DGRAM,
+	.protocol	=  IPPROTO_UDPLITE,
+	.prot		=  &udplite_prot,
+	.ops		=  &inet_dgram_ops,
+	.capability	= -1,
+	.no_check	=  0,		/* must checksum (RFC 3828) */
+	.flags		=  INET_PROTOSW_PERMANENT,
+};
+
+#ifdef CONFIG_PROC_FS
+static struct file_operations udplite4_seq_fops;
+static struct udp_seq_afinfo udplite4_seq_afinfo = {
+	.owner		= THIS_MODULE,
+	.name		= "udplite",
+	.family		= AF_INET,
+	.hashtable	= udplite_hash,
+	.seq_show	= udp4_seq_show,
+	.seq_fops	= &udplite4_seq_fops,
+};
+#endif /* CONFIG_PROC_FS */
+
+
+void __init udplite4_register(void)
+{
+	if (proto_register(&udplite_prot, 1))
+		goto out_register_err;
+
+	if (inet_add_protocol(&udplite_protocol, IPPROTO_UDPLITE) < 0)
+		goto out_unregister_proto;
+
+	inet_register_protosw(&udplite4_protosw);
+
+#ifdef CONFIG_PROC_FS
+	if (udp_proc_register(&udplite4_seq_afinfo)) /* udplite4_proc_init() */
+		printk(KERN_ERR "udplite4: Cannot register /proc!\n");
+#endif /* CONFIG_PROC_FS */
+	return;
+
+out_unregister_proto:
+	proto_unregister(&udplite_prot);
+out_register_err:
+	printk(KERN_CRIT "udplite4_register: Cannot add UDP-Lite protocol.\n");
+}
+
+EXPORT_SYMBOL(udplite_hash);
+EXPORT_SYMBOL(udplite_prot);
+EXPORT_SYMBOL(udplite_get_port);	/* for v6 */

