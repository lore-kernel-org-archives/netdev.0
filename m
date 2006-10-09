From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH-update][RFC]    net: consolidated UDP / UDP-Lite code
Date: Mon, 9 Oct 2006 10:51:44 +0100
Message-ID: <200610091051.45021@strip-the-willow>
References: <200607141719.02766@strip-the-willow> <20060727.223010.63131639.davem@davemloft.net> <200609190825.23709@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41358 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1751662AbWJIJwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 05:52:02 -0400
To: davem@davemloft.net
In-Reply-To: <200609190825.23709@strip-the-willow>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

this is a maintenance update of the UDP-Lite code. It tracks recent changes to udp.c
which make it difficult to apply earlier versions of the patch. For consistency, the 
code has now also been aligned to use __be32/16.

The patch addresses the suggestions made earlier by the following people on this list:
Patrick McHardy, Herbert Xu,  James Morris, Arnaldo de Melo, Yoshifuji Hideaki, 
and David S. Miller. 

Being small, I send it in one piece (but could dice it up); the code comprises:
  * self-contained UDP-Lite extension (udplite.c and include/net/udplite.h)
  * consolidated checksumming for UDPv4/6 and UDP-Litev4/6
    	--UDPv{4,6} checksumming therefore simpler
	--enforces the mandatory UDPv6 checksums (RFC 2460, sec. 8.1)
  * fixes the bug stated on  http://bugzilla.kernel.org/show_bug.cgi?id=6660
     ( i.e. correct counting of delivered/erratic datagrams )
  * concentrates some shared code which previously re-appeared in different files
  * basic xfrm/netfilter support

I have left the v6-side sitting in the drawer. But it is easy to add, since it mirrors
the structure of the v4-side  -  and asking whether this structure is ok with regard
to the existing code is the whole point of this patch. 

- Gerrit

--
 Documentation/networking/udplite.txt |  291 ++++++++++++++++++++
 include/linux/in.h                   |    1
 include/linux/socket.h               |    1
 include/linux/udp.h                  |   11
 include/net/snmp.h                   |    2
 include/net/udp.h                    |   95 ++++++
 include/net/udplite.h                |   86 ++++++
 include/net/xfrm.h                   |    2
 net/ipv4/af_inet.c                   |    9
 net/ipv4/netfilter/ipt_LOG.c         |   11
 net/ipv4/proc.c                      |   12
 net/ipv4/udp.c                       |  487 +++++++++++++++++++++--------------
 net/ipv4/udplite.c                   |  186 +++++++++++++
 net/ipv4/xfrm4_policy.c              |    1
 net/ipv6/netfilter/ip6t_LOG.c        |   10
 net/ipv6/udp.c                       |   60 ----
 net/ipv6/xfrm6_policy.c              |    1
 net/netfilter/xt_multiport.c         |    5
 net/netfilter/xt_tcpudp.c            |   20 +
 19 files changed, 1040 insertions(+), 251 deletions(-)

diff --git a/Documentation/networking/udplite.txt b/Documentation/networking/udplite.txt
new file mode 100644
index 0000000..a899fa1
--- /dev/null
+++ b/Documentation/networking/udplite.txt
@@ -0,0 +1,291 @@
+  ===========================================================================
+                      The UDP-Lite protocol (RFC 3828)
+  ===========================================================================
+  last modified: 	Mon 18th September 2006
+
+
+  UDP-Lite is a Standards-Track IETF transport protocol whose characteristic
+  is a variable-length checksum. This has advantages for transport of multimedia
+  (video, VoIP) over wireless networks, as partly damaged packets can still be
+  fed into the codec instead of being discarded due to a failed checksum test.
+
+  This file briefly describes the existing kernel support and the socket API.
+  For in-depth information, you can consult:
+
+   o The UDP-Lite Homepage: http://www.erg.abdn.ac.uk/users/gerrit/udp-lite/
+       Fom here you can always also download the latest patch for the stable
+       kernel tree and some example application source code.
+
+   o The UDP-Lite HOWTO on
+       http://www.erg.abdn.ac.uk/users/gerrit/udp-lite/files/UDP-Lite-HOWTO.txt
+
+   o The Wireshark UDP-Lite WiKi (with capture files):
+       http://wiki.wireshark.org/Lightweight_User_Datagram_Protocol
+
+   o The Protocol Spec, RFC 3828, on  http://www.ietf.org/rfc/rfc3828.txt
+
+
+  I) APPLICATIONS
+
+  Several applications have been ported successfully to UDP-Lite. Ethereal
+  (now called wireshark) has UDP-Litev4/v6 support by default. The tarball on
+
+   http://www.erg.abdn.ac.uk/users/gerrit/udp-lite/files/udplite_linux.tar.gz
+
+  has source code for several v4/v6 client-server and network testing examples.
+
+  Porting applications to UDP-Lite is straightforward: only socket level and
+  IPPROTO need to be changed; senders additionally set the checksum coverage
+  length (default = header length = 8). Details are in the next section.
+  UDP-Lite is not enabled per default: set CONFIG_IP_UDPLITE=y to support it.
+
+
+  II) PROGRAMMING API
+
+  UDP-Lite provides a connectionless, unreliable datagram service and hence
+  uses the same socket type as UDP. In fact, porting from UDP to UDP-Lite is
+  dead easy: simply add `IPPROTO_UDPLITE' as the last argument of the socket(2)
+  call so that the statement looks like:
+
+      s = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDPLITE);
+
+                      or, respectively,
+
+      s = socket(PF_INET6, SOCK_DGRAM, IPPROTO_UDPLITE);
+
+  Since both UDP-Litev4 and UDP-Litev6 are supported, the porting process is the
+  same in both occasions. With just this change you are able to run UDP-Lite
+  services or connect to UDP-Lite servers. The kernel will assume that you are
+  not interested in using partial checksum coverage and so emulate UDP mode.
+
+  To make use of the partial checksum coverage facilities requires setting just
+  one socket option which takes an integer specifying the coverage length:
+
+    * Sender checksum coverage: UDPLITE_SEND_CSCOV
+
+      For example,
+
+        int val = 20;
+        setsockopt(s, SOL_UDPLITE, UDPLITE_SEND_CSCOV, &val, sizeof(int));
+
+      sets the checksum coverage length to 20 bytes (12b data + 8b header).
+      Of each packet only the first 20 bytes (plus the pseudo-header) will be
+      checksummed. This is useful for RTP applications which have a 12-byte
+      base header.
+
+
+    * Receiver checksum coverage: UDPLITE_RECV_CSCOV
+
+      This option is the receiver-side analogue. It is truly optional, i.e. not
+      required to enable traffic with partial checksum coverage. Its function is
+      that of a traffic filter: when enabled, it instructs the kernel to drop
+      all packets which have a coverage _less_ than this value. For example, if
+      RTP and UDP headers are to be protected, a receiver can enforce that only
+      packets with a minimum coverage of 20 are admitted:
+
+        int min = 20;
+        setsockopt(s, SOL_UDPLITE, UDPLITE_RECV_CSCOV, &min, sizeof(int));
+
+  The calls to getsockopt(2) are analogous. Being an extension and not a stand-
+  alone protocol, all socket options known from UDP can be used in exactly the
+  same manner as before, e.g. UDP_CORK or UDP_ENCAP.
+
+  A detailed discussion of UDP-Lite checksum coverage options is in section IV.
+
+
+
+  III) HEADER FILES
+
+  The socket API requires support through header files in /usr/include:
+
+    * /usr/include/netinet/in.h
+        to define IPPROTO_UDPLITE
+
+    * /usr/include/netinet/udplite.h
+        for UDP-Lite header fields and protocol constants
+
+  For testing purposes, the following can serve as a `mini' header file:
+
+    #define IPPROTO_UDPLITE       136
+    #define SOL_UDPLITE           136
+    #define UDPLITE_SEND_CSCOV     10
+    #define UDPLITE_RECV_CSCOV     11
+
+  Ready-made header files for various distros are in the UDP-Lite tarball.
+
+
+
+  IV) KERNEL BEHAVIOUR WITH REGARD TO THE VARIOUS SOCKET OPTIONS
+
+  To enable debugging messages, the log level must be set to 8, as most
+  messages use the KERN_DEBUG level (7).
+
+
+  1) Sender Socket Options
+
+  If the sender specifies a value of 0 as coverage length, the module
+  assumes full coverage, transmits a packet with coverage length of 0
+  and according checksum.  If the sender specifies a coverage < 8 and
+  different from 0, the kernel assumes 8 as default value.  Finally,
+  if the specified coverage length exceeds the packet length, the packet
+  length is used instead as coverage length.
+
+
+  2) Receiver Socket Options
+
+  The receiver specifies the minimum value of the coverage length it
+  is willing to accept.  A value of 0 here indicates that the receiver
+  always wants the whole of the packet covered. In this case, all
+  partially covered packets are dropped and an error is logged.
+
+  It is not possible to specify illegal values (<0 and <8); in these
+  cases the default of 8 is assumed.
+
+  All packets arriving with a coverage value less than the specified
+  threshold are discarded, these events are also logged.
+
+
+  3) Disabling the Checksum Computation
+
+  On both sender and receiver, checksumming will always be performed
+  and can not be disabled using SO_NO_CHECK. Thus
+
+        setsockopt(sockfd, SOL_SOCKET, SO_NO_CHECK,  ... );
+
+  will always will be ignored, while the value of
+
+        getsockopt(sockfd, SOL_SOCKET, SO_NO_CHECK, &value, ...);
+
+  is meaningless (as in TCP). Packets with a zero checksum field are
+  illegal (cf. RFC 3828, sec. 3.1) will be silently discarded.
+
+
+  4) Fragmentation
+
+  The checksum computation respects both buffersize and MTU. The size
+  of UDP-Lite packets is determined by the size of the send buffer. The
+  minimum size of the send buffer is 2048 (defined as SOCK_MIN_SNDBUF
+  in include/net/sock.h), the default value is configurable as
+  net.core.wmem_default or via setting the SO_SNDBUF socket(7)
+  option. The maximum upper bound for the send buffer is determined
+  by net.core.wmem_max.
+
+  Given a payload size larger than the send buffer size, UDP-Lite will
+  split the payload into several individual packets, filling up the
+  send buffer size in each case.
+
+  The precise value also depends on the interface MTU. The interface MTU,
+  in turn, may trigger IP fragmentation. In this case, the generated
+  UDP-Lite packet is split into several IP packets, of which only the
+  first one contains the L4 header.
+
+  The send buffer size has implications on the checksum coverage length.
+  Consider the following example:
+
+  Payload: 1536 bytes          Send Buffer:     1024 bytes
+  MTU:     1500 bytes          Coverage Length:  856 bytes
+
+  UDP-Lite will ship the 1536 bytes in two separate packets:
+
+  Packet 1: 1024 payload + 8 byte header + 20 byte IP header = 1052 bytes
+  Packet 2:  512 payload + 8 byte header + 20 byte IP header =  540 bytes
+
+  The coverage packet covers the UDP-Lite header and 848 bytes of the
+  payload in the first packet, the second packet is fully covered. Note
+  that for the second packet, the coverage length exceeds the packet
+  length. The kernel always re-adjusts the coverage length to the packet
+  length in such cases.
+
+  As an example of what happens when one UDP-Lite packet is split into
+  several tiny fragments, consider the following example.
+
+  Payload: 1024 bytes            Send buffer size: 1024 bytes
+  MTU:      300 bytes            Coverage length:   575 bytes
+
+  +-+-----------+--------------+--------------+--------------+
+  |8|    272    |      280     |     280      |     280      |
+  +-+-----------+--------------+--------------+--------------+
+               280            560            840           1032
+                                    ^
+  *****checksum coverage*************
+
+  The UDP-Lite module generates one 1032 byte packet (1024 + 8 byte
+  header). According to the interface MTU, these are split into 4 IP
+  packets (280 byte IP payload + 20 byte IP header). The kernel module
+  sums the contents of the entire first two packets, plus 15 bytes of
+  the last packet before releasing the fragments to the IP module.
+
+  To see the analogous case for IPv6 fragmentation, consider a link
+  MTU of 1280 bytes and a write buffer of 3356 bytes. If the checksum
+  coverage is less than 1232 bytes (MTU minus IPv6/fragment header
+  lengths), only the first fragment needs to be considered. When using
+  larger checksum coverage lengths, each eligible fragment needs to be
+  checksummed. Suppose we have a checksum coverage of 3062. The buffer
+  of 3356 bytes will be split into the following fragments:
+
+    Fragment 1: 1280 bytes carrying  1232 bytes of UDP-Lite data
+    Fragment 2: 1280 bytes carrying  1232 bytes of UDP-Lite data
+    Fragment 3:  948 bytes carrying   900 bytes of UDP-Lite data
+
+  The first two fragments have to be checksummed in full, of the last
+  fragment only 598 (= 3062 - 2*1232) bytes are checksummed.
+
+  While it is important that such cases are dealt with correctly, they
+  are (annoyingly) rare: UDP-Lite is designed for optimising multimedia
+  performance over wireless (or generally noisy) links and thus smaller
+  coverage lenghts are likely to be expected.
+
+
+  V) UDP-LITE RUNTIME STATISTICS AND THEIR MEANING
+
+  Exceptional and error conditions are logged to syslog at the KERN_DEBUG
+  level.  Live statistics about UDP-Lite are available in /proc/net/snmp
+  and can (with newer versions of netstat) be viewed using
+
+                            netstat -svu
+
+  This displays UDP-Lite statistics variables, whose meaning is as follows.
+
+   InDatagrams:     Total number of received datagrams.
+
+   NoPorts:         Number of packets received to an unknown port.
+                    These cases are counted separately (not as InErrors).
+
+   InErrors:        Number of erroneous UDP-Lite packets. Errors include:
+                      * internal socket queue receive errors
+                      * packet too short (less than 8 bytes or stated
+                        coverage length exceeds received length)
+                      * xfrm4_policy_check() returned with error
+                      * application has specified larger min. coverage
+                        length than that of incoming packet
+                      * checksum coverage violated
+                      * bad checksum
+
+   OutDatagrams:    Total number of sent datagrams.
+
+   These statistics derive from the UDP MIB (RFC 2013).
+
+
+  VI) IPTABLES
+
+  There is packet match support for UDP-Lite as well as support for the LOG target.
+  If you copy and paste the following line into /etc/protcols,
+
+  udplite 136     UDP-Lite        # UDP-Lite [RFC 3828]
+
+  then
+              iptables -A INPUT -p udplite -j LOG
+
+  will produce logging output to syslog. Dropping and rejecting packets also works.
+
+
+  VII) MAINTAINER ADDRESS
+
+  The UDP-Lite patch was developed at
+                    University of Aberdeen
+                    Electronics Research Group
+                    Department of Engineering
+                    Fraser Noble Building
+                    Aberdeen AB24 3UE; UK
+  The current maintainer is Gerrit Renker, <gerrit@erg.abdn.ac.uk>. Initial
+  code had been developed by William  Stanislaus, <william@erg.abdn.ac.uk>.
diff --git a/include/linux/in.h b/include/linux/in.h
index 2619859..1912e7c 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -45,6 +45,7 @@ enum {
 
   IPPROTO_COMP   = 108,                /* Compression Header protocol */
   IPPROTO_SCTP   = 132,		/* Stream Control Transport Protocol	*/
+  IPPROTO_UDPLITE = 136,	/* UDP-Lite (RFC 3828)			*/
 
   IPPROTO_RAW	 = 255,		/* Raw IP packets			*/
   IPPROTO_MAX
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 3614090..592b666 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -264,6 +264,7 @@ #define SOL_UDP		17
 #define SOL_IPV6	41
 #define SOL_ICMPV6	58
 #define SOL_SCTP	132
+#define SOL_UDPLITE	136     /* UDP-Lite (RFC 3828) */
 #define SOL_RAW		255
 #define SOL_IPX		256
 #define SOL_AX25	257
diff --git a/include/linux/udp.h b/include/linux/udp.h
index 014b41d..1248668 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -50,12 +50,23 @@ struct udp_sock {
 	 * when the socket is uncorked.
 	 */
 	__u16		 len;		/* total length of pending frames */
+	/*
+	 * Fields specific to UDP-Lite.
+	 */
+	__u16		 pcslen;
+	__u16		 pcrlen;
+/* indicator bits used by pcflag: */
+#define UDPLITE_BIT      0x1  		/* set by udplite proto init function */
+#define UDPLITE_SEND_CC  0x2  		/* set via udplite setsockopt         */
+#define UDPLITE_RECV_CC  0x4		/* set via udplite setsocktopt        */
+	__u8		 pcflag;        /* marks socket as UDP-Lite if > 0    */
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
 {
 	return (struct udp_sock *)sk;
 }
+#define IS_UDPLITE(__sk) (udp_sk(__sk)->pcflag)
 
 #endif
 
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 464970e..34183aa 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -131,6 +131,8 @@ #define SNMP_INC_STATS(mib, field) 	\
 	(per_cpu_ptr(mib[!in_softirq()], raw_smp_processor_id())->mibs[field]++)
 #define SNMP_DEC_STATS(mib, field) 	\
 	(per_cpu_ptr(mib[!in_softirq()], raw_smp_processor_id())->mibs[field]--)
+#define SNMP_DEC_STATS_BH(mib, field) 	\
+	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field]--)
 #define SNMP_ADD_STATS_BH(mib, field, addend) 	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field] += addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
diff --git a/include/net/udp.h b/include/net/udp.h
index db0c05f..06476e3 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -26,9 +26,31 @@ #include <linux/list.h>
 #include <net/inet_sock.h>
 #include <net/sock.h>
 #include <net/snmp.h>
+#include <net/ip.h>
+#include <linux/ipv6.h>
 #include <linux/seq_file.h>
 
 #define UDP_HTABLE_SIZE		128
+#include <net/udplite.h>
+
+/**
+ *	struct udp_skb_cb  -  UDP(-Lite) private variables
+ *
+ *	@header:      private variables used by IPv4/IPv6
+ *	@cscov:       checksum coverage length (UDP-Lite only)
+ *	@partial_cov: if set indicates partial csum coverage
+ */
+struct udp_skb_cb {
+	union {
+		struct inet_skb_parm	h4;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+		struct inet6_skb_parm	h6;
+#endif
+	} header;
+	__u16		cscov;
+	__u8		partial_cov;
+};
+#define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
 
 extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 extern rwlock_t udp_hash_lock;
@@ -47,6 +69,62 @@ extern struct proto udp_prot;
 
 struct sk_buff;
 
+/*
+ *	Generic checksumming routines for UDP(-Lite) v4 and v6
+ */
+static inline u16  __udp_lib_checksum_complete(struct sk_buff *skb)
+{
+	if (! UDP_SKB_CB(skb)->partial_cov)
+		return __skb_checksum_complete(skb);
+	return  csum_fold(skb_checksum(skb, 0, UDP_SKB_CB(skb)->cscov,
+			  skb->csum));
+}
+
+static __inline__ int udp_checksum_complete(struct sk_buff *skb)
+{
+	return skb->ip_summed != CHECKSUM_UNNECESSARY &&
+		__udp_lib_checksum_complete(skb);
+}
+
+/**
+ * 	udp_csum_outgoing  -  compute UDPv4/v6 checksum over fragments
+ * 	@sk: 	socket we are writing to
+ * 	@skb: 	sk_buff containing the filled-in UDP header
+ * 	        (checksum field must be zeroed out)
+ */
+static inline u32 udp_csum_outgoing(struct sock *sk, struct sk_buff *skb)
+{
+	u32 csum = csum_partial(skb->h.raw, sizeof(struct udphdr), 0);
+
+	skb_queue_walk(&sk->sk_write_queue, skb) {
+		csum = csum_add(csum, skb->csum);
+	}
+	return csum;
+}
+
+/* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
+static inline void udp_lib_hash(struct sock *sk)
+{
+	BUG();
+}
+
+static inline void udp_lib_unhash(struct sock *sk)
+{
+	write_lock_bh(&udp_hash_lock);
+	if (sk_del_node_init(sk)) {
+		inet_sk(sk)->num = 0;
+		sock_prot_dec_use(sk->sk_prot);
+	}
+	write_unlock_bh(&udp_hash_lock);
+}
+
+static inline void udp_lib_close(struct sock *sk, long timeout)
+{
+	sk_common_release(sk);
+}
+
+
+/* net/ipv4/udp.c */
 extern int	udp_get_port(struct sock *sk, unsigned short snum,
 			     int (*saddr_cmp)(const struct sock *, const struct sock *));
 extern void	udp_err(struct sk_buff *, u32);
@@ -61,21 +139,32 @@ extern unsigned int udp_poll(struct file
 			     poll_table *wait);
 
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
-#define UDP_INC_STATS(field)		SNMP_INC_STATS(udp_statistics, field)
-#define UDP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(udp_statistics, field)
-#define UDP_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(udp_statistics, field)
+/*
+ * 	SNMP statistics for UDP and UDP-Lite
+ */
+#define UDP_INC_STATS_USER(field, is_udplite)			       do {   \
+	if (is_udplite) SNMP_INC_STATS_USER(udplite_statistics, field);       \
+	else		SNMP_INC_STATS_USER(udp_statistics, field);  }  while(0)
+#define UDP_INC_STATS_BH(field, is_udplite) 			       do  {  \
+	if (is_udplite) SNMP_INC_STATS_BH(udplite_statistics, field);         \
+	else		SNMP_INC_STATS_BH(udp_statistics, field);    }  while(0)
+#define UDP_DEC_STATS_BH(field, is_udplite)			       do  {  \
+	if (is_udplite) SNMP_DEC_STATS_BH(udplite_statistics, field);         \
+	else		SNMP_DEC_STATS_BH(udp_statistics, field);    }  while(0)
 
 /* /proc */
 struct udp_seq_afinfo {
 	struct module		*owner;
 	char			*name;
 	sa_family_t		family;
+	struct hlist_head	*hashtable;
 	int 			(*seq_show) (struct seq_file *m, void *v);
 	struct file_operations	*seq_fops;
 };
 
 struct udp_iter_state {
 	sa_family_t		family;
+	struct hlist_head	*hashtable;
 	int			bucket;
 	struct seq_operations	seq_ops;
 };
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
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1e2a4dd..2bd23cd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -468,6 +468,7 @@ __be16 xfrm_flowi_sport(struct flowi *fl
 	switch(fl->proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE:
 	case IPPROTO_SCTP:
 		port = fl->fl_ip_sport;
 		break;
@@ -493,6 +494,7 @@ __be16 xfrm_flowi_dport(struct flowi *fl
 	switch(fl->proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE:
 	case IPPROTO_SCTP:
 		port = fl->fl_ip_dport;
 		break;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index edcf093..2b997b1 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1223,10 +1223,13 @@ static int __init init_ipv4_mibs(void)
 	tcp_statistics[1] = alloc_percpu(struct tcp_mib);
 	udp_statistics[0] = alloc_percpu(struct udp_mib);
 	udp_statistics[1] = alloc_percpu(struct udp_mib);
+	udplite_statistics[0] = alloc_percpu(struct udp_mib);
+	udplite_statistics[1] = alloc_percpu(struct udp_mib);
 	if (!
 	    (net_statistics[0] && net_statistics[1] && ip_statistics[0]
 	     && ip_statistics[1] && tcp_statistics[0] && tcp_statistics[1]
-	     && udp_statistics[0] && udp_statistics[1]))
+	     && udp_statistics[0] && udp_statistics[1]
+	     && udplite_statistics[0] && udplite_statistics[1]             ) )
 		return -ENOMEM;
 
 	(void) tcp_mib_init();
@@ -1313,6 +1316,10 @@ #endif
 	/* Setup TCP slab cache for open requests. */
 	tcp_init();
 
+	/*
+	 * 	Add UDP-Lite (RFC 3828)
+	 */
+	udplite4_register();
 
 	/*
 	 *	Set the ICMP layer up
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 7dc820d..46eee64 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -171,11 +171,15 @@ static void dump_packet(const struct nf_
 		}
 		break;
 	}
-	case IPPROTO_UDP: {
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE: {
 		struct udphdr _udph, *uh;
 
-		/* Max length: 10 "PROTO=UDP " */
-		printk("PROTO=UDP ");
+		if (ih->protocol == IPPROTO_UDP)
+			/* Max length: 10 "PROTO=UDP "     */
+			printk("PROTO=UDP " );
+		else	/* Max length: 14 "PROTO=UDPLITE " */
+			printk("PROTO=UDPLITE ");
 
 		if (ntohs(ih->frag_off) & IP_OFFSET)
 			break;
@@ -341,6 +345,7 @@ static void dump_packet(const struct nf_
 	/* IP:      40+46+6+11+127 = 230 */
 	/* TCP:     10+max(25,20+30+13+9+32+11+127) = 252 */
 	/* UDP:     10+max(25,20) = 35 */
+	/* UDPLITE: 14+max(25,20) = 39 */
 	/* ICMP:    11+max(25, 18+25+max(19,14,24+3+n+10,3+n+10)) = 91+n */
 	/* ESP:     10+max(25)+15 = 50 */
 	/* AH:      9+max(25)+15 = 49 */
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 9c6cbe3..9b72fe4 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -66,6 +66,7 @@ static int sockstat_seq_show(struct seq_
 		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
 	seq_printf(seq, "UDP: inuse %d\n", fold_prot_inuse(&udp_prot));
+	seq_printf(seq, "UDPLITE: inuse %d\n", fold_prot_inuse(&udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n", fold_prot_inuse(&raw_prot));
 	seq_printf(seq,  "FRAG: inuse %d memory %d\n", ip_frag_nqueues,
 		   atomic_read(&ip_frag_mem));
@@ -304,6 +305,17 @@ static int snmp_seq_show(struct seq_file
 			   fold_field((void **) udp_statistics, 
 				      snmp4_udp_list[i].entry));
 
+	/* the UDP and UDP-Lite MIBs are the same */
+	seq_puts(seq, "\nUdpLite:");
+	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+		seq_printf(seq, " %s", snmp4_udp_list[i].name);
+
+	seq_puts(seq, "\nUdpLite:");
+	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+		seq_printf(seq, " %lu",
+			   fold_field((void **) udplite_statistics,
+				      snmp4_udp_list[i].entry)     );
+
 	seq_putc(seq, '\n');
 	return 0;
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 865d752..47bfbf3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -92,10 +92,8 @@ #include <linux/errno.h>
 #include <linux/timer.h>
 #include <linux/mm.h>
 #include <linux/inet.h>
-#include <linux/ipv6.h>
 #include <linux/netdevice.h>
 #include <net/snmp.h>
-#include <net/ip.h>
 #include <net/tcp_states.h>
 #include <net/protocol.h>
 #include <linux/skbuff.h>
@@ -120,26 +118,29 @@ DEFINE_RWLOCK(udp_hash_lock);
 
 static int udp_port_rover;
 
-static inline int udp_lport_inuse(u16 num)
+static inline int __udp_lib_lport_inuse(__be16 num, struct hlist_head udptable[])
 {
 	struct sock *sk;
 	struct hlist_node *node;
 
-	sk_for_each(sk, node, &udp_hash[num & (UDP_HTABLE_SIZE - 1)])
+	sk_for_each(sk, node, &udptable[num & (UDP_HTABLE_SIZE - 1)])
 		if (inet_sk(sk)->num == num)
 			return 1;
 	return 0;
 }
 
 /**
- *  udp_get_port  -  common port lookup for IPv4 and IPv6
+ *  __udp_lib_get_port  -  UDP/-Lite port lookup for IPv4 and IPv6
  *
  *  @sk:          socket struct in question
  *  @snum:        port number to look up
+ *  @udptable:    hash list table, must be of UDP_HTABLE_SIZE
+ *  @port_rover:  pointer to record of last unallocated port
  *  @saddr_comp:  AF-dependent comparison of bound local IP addresses
  */
-int udp_get_port(struct sock *sk, unsigned short snum,
-		 int (*saddr_cmp)(const struct sock *sk1, const struct sock *sk2))
+static int __udp_lib_get_port(struct sock *sk, unsigned short snum,
+		struct hlist_head udptable[], int *port_rover,
+		int (*saddr_cmp)(const struct sock *, const struct sock *))
 {
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -150,15 +151,15 @@ int udp_get_port(struct sock *sk, unsign
 	if (snum == 0) {
 		int best_size_so_far, best, result, i;
 
-		if (udp_port_rover > sysctl_local_port_range[1] ||
-		    udp_port_rover < sysctl_local_port_range[0])
-			udp_port_rover = sysctl_local_port_range[0];
+		if (*port_rover > sysctl_local_port_range[1] ||
+		    *port_rover < sysctl_local_port_range[0])
+			*port_rover = sysctl_local_port_range[0];
 		best_size_so_far = 32767;
-		best = result = udp_port_rover;
+		best = result = *port_rover;
 		for (i = 0; i < UDP_HTABLE_SIZE; i++, result++) {
 			int size;
 
-			head = &udp_hash[result & (UDP_HTABLE_SIZE - 1)];
+			head = &udptable[result & (UDP_HTABLE_SIZE - 1)];
 			if (hlist_empty(head)) {
 				if (result > sysctl_local_port_range[1])
 					result = sysctl_local_port_range[0] +
@@ -179,15 +180,15 @@ int udp_get_port(struct sock *sk, unsign
 				result = sysctl_local_port_range[0]
 					+ ((result - sysctl_local_port_range[0]) &
 					   (UDP_HTABLE_SIZE - 1));
-			if (!udp_lport_inuse(result))
+			if (! __udp_lib_lport_inuse(result, udptable))
 				break;
 		}
 		if (i >= (1 << 16) / UDP_HTABLE_SIZE)
 			goto fail;
 gotit:
-		udp_port_rover = snum = result;
+		*port_rover = snum = result;
 	} else {
-		head = &udp_hash[snum & (UDP_HTABLE_SIZE - 1)];
+		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
 
 		sk_for_each(sk2, node, head)
 			if (inet_sk(sk2)->num == snum                        &&
@@ -200,7 +201,7 @@ gotit:
 	}
 	inet_sk(sk)->num = snum;
 	if (sk_unhashed(sk)) {
-		head = &udp_hash[snum & (UDP_HTABLE_SIZE - 1)];
+		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
 		sk_add_node(sk, head);
 		sock_prot_inc_use(sk->sk_prot);
 	}
@@ -210,6 +211,12 @@ fail:
 	return error;
 }
 
+__inline__ int udp_get_port(struct sock *sk, unsigned short snum,
+			int (*scmp)(const struct sock *, const struct sock *))
+{
+	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
+}
+
 static inline int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
@@ -224,34 +231,20 @@ static inline int udp_v4_get_port(struct
 	return udp_get_port(sk, snum, ipv4_rcv_saddr_equal);
 }
 
-
-static void udp_v4_hash(struct sock *sk)
-{
-	BUG();
-}
-
-static void udp_v4_unhash(struct sock *sk)
-{
-	write_lock_bh(&udp_hash_lock);
-	if (sk_del_node_init(sk)) {
-		inet_sk(sk)->num = 0;
-		sock_prot_dec_use(sk->sk_prot);
-	}
-	write_unlock_bh(&udp_hash_lock);
-}
-
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-static struct sock *udp_v4_lookup_longway(__be32 saddr, __be16 sport,
-					  __be32 daddr, __be16 dport, int dif)
+static struct sock *__udp4_lib_lookup(__be32 saddr, __be16 sport,
+				      __be32 daddr, __be16 dport,
+				      int dif, struct hlist_head udptable[])
 {
 	struct sock *sk, *result = NULL;
 	struct hlist_node *node;
 	unsigned short hnum = ntohs(dport);
 	int badness = -1;
 
-	sk_for_each(sk, node, &udp_hash[hnum & (UDP_HTABLE_SIZE - 1)]) {
+	read_lock(&udp_hash_lock);
+	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
 		if (inet->num == hnum && !ipv6_only_sock(sk)) {
@@ -285,20 +278,16 @@ static struct sock *udp_v4_lookup_longwa
 			}
 		}
 	}
+	if (result)
+		sock_hold(result);
+	read_unlock(&udp_hash_lock);
 	return result;
 }
 
 static __inline__ struct sock *udp_v4_lookup(__be32 saddr, __be16 sport,
 					     __be32 daddr, __be16 dport, int dif)
 {
-	struct sock *sk;
-
-	read_lock(&udp_hash_lock);
-	sk = udp_v4_lookup_longway(saddr, sport, daddr, dport, dif);
-	if (sk)
-		sock_hold(sk);
-	read_unlock(&udp_hash_lock);
-	return sk;
+	return __udp4_lib_lookup(saddr, sport, daddr, dport, dif, udp_hash);
 }
 
 static inline struct sock *udp_v4_mcast_next(struct sock *sk,
@@ -340,7 +329,8 @@ found:
  * to find the appropriate port.
  */
 
-void udp_err(struct sk_buff *skb, u32 info)
+static void __udp4_lib_err(struct sk_buff *skb, u32 info,
+			   struct hlist_head udptable[]  )
 {
 	struct inet_sock *inet;
 	struct iphdr *iph = (struct iphdr*)skb->data;
@@ -351,7 +341,8 @@ void udp_err(struct sk_buff *skb, u32 in
 	int harderr;
 	int err;
 
-	sk = udp_v4_lookup(iph->daddr, uh->dest, iph->saddr, uh->source, skb->dev->ifindex);
+	sk = __udp4_lib_lookup(iph->daddr, uh->dest, iph->saddr, uh->source,
+			       skb->dev->ifindex, udptable		    );
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
     	  	return;	/* No socket for error */
@@ -405,6 +396,11 @@ out:
 	sock_put(sk);
 }
 
+__inline__ void udp_err(struct sk_buff *skb, u32 info)
+{
+	return __udp4_lib_err(skb, info, udp_hash);
+}
+
 /*
  * Throw away all pending data and cancel the corking. Socket is locked.
  */
@@ -419,6 +415,45 @@ static void udp_flush_pending_frames(str
 	}
 }
 
+/**
+ * 	udp4_hwcsum_outgoing  -  handle outgoing HW checksumming
+ * 	@sk: 	socket we are sending on
+ * 	@skb: 	sk_buff containing the filled-in UDP header
+ * 	        (checksum field must be zeroed out)
+ */
+static void udp4_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
+				 __be32 src, __be32 dst, int len      )
+{
+	unsigned int csum = 0, offset;
+	struct udphdr *uh = skb->h.uh;
+
+	if (skb_queue_len(&sk->sk_write_queue) == 1) {
+		/*
+		 * Only one fragment on the socket.
+		 */
+		skb->csum = offsetof(struct udphdr, check);
+		uh->check = ~csum_tcpudp_magic(src, dst, len, IPPROTO_UDP, 0);
+	} else {
+		/*
+		 * HW-checksum won't work as there are two or more
+		 * fragments on the socket so that all csums of sk_buffs
+		 * should be together
+		 */
+		offset = skb->h.raw - skb->data;
+		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+
+		skb->ip_summed = CHECKSUM_NONE;
+
+		skb_queue_walk(&sk->sk_write_queue, skb) {
+			csum = csum_add(csum, skb->csum);
+		}
+
+		uh->check = csum_tcpudp_magic(src, dst, len, IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = -1;
+	}
+}
+
 /*
  * Push out all pending data as one UDP datagram. Socket is locked.
  */
@@ -429,6 +464,7 @@ static int udp_push_pending_frames(struc
 	struct sk_buff *skb;
 	struct udphdr *uh;
 	int err = 0;
+	u32 csum = 0;
 
 	/* Grab the skbuff where UDP header space exists. */
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
@@ -443,52 +479,31 @@ static int udp_push_pending_frames(struc
 	uh->len = htons(up->len);
 	uh->check = 0;
 
-	if (sk->sk_no_check == UDP_CSUM_NOXMIT) {
+	if (up->pcflag) {				 /*     UDP-Lite      */
+		int cscov = udplite_sender_cscov(up, uh);
+
+		csum  = udplite_csum_outgoing(sk, cscov);
+		skb->ip_summed = CHECKSUM_NONE;
+
+	} else if (sk->sk_no_check == UDP_CSUM_NOXMIT) { /* UDP csum disabled */
+
 		skb->ip_summed = CHECKSUM_NONE;
 		goto send;
-	}
 
-	if (skb_queue_len(&sk->sk_write_queue) == 1) {
-		/*
-		 * Only one fragment on the socket.
-		 */
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			skb->csum = offsetof(struct udphdr, check);
-			uh->check = ~csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst,
-					up->len, IPPROTO_UDP, 0);
-		} else {
-			skb->csum = csum_partial((char *)uh,
-					sizeof(struct udphdr), skb->csum);
-			uh->check = csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst,
-					up->len, IPPROTO_UDP, skb->csum);
-			if (uh->check == 0)
-				uh->check = -1;
-		}
-	} else {
-		unsigned int csum = 0;
-		/*
-		 * HW-checksum won't work as there are two or more 
-		 * fragments on the socket so that all csums of sk_buffs
-		 * should be together.
-		 */
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			int offset = (unsigned char *)uh - skb->data;
-			skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
 
-			skb->ip_summed = CHECKSUM_NONE;
-		} else {
-			skb->csum = csum_partial((char *)uh,
-					sizeof(struct udphdr), skb->csum);
-		}
+		udp4_hwcsum_outgoing(sk, skb, fl->fl4_src,fl->fl4_dst, up->len);
+		goto send;
+
+	} else						 /*   `normal' UDP    */
+		csum = udp_csum_outgoing(sk, skb);
+
+	/* add protocol-dependent pseudo-header */
+	uh->check = csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst, up->len,
+				      sk->sk_protocol, csum             );
+	if (uh->check == 0)
+		uh->check = -1;
 
-		skb_queue_walk(&sk->sk_write_queue, skb) {
-			csum = csum_add(csum, skb->csum);
-		}
-		uh->check = csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst,
-				up->len, IPPROTO_UDP, csum);
-		if (uh->check == 0)
-			uh->check = -1;
-	}
 send:
 	err = ip_push_pending_frames(sk);
 out:
@@ -497,12 +512,6 @@ out:
 	return err;
 }
 
-
-static unsigned short udp_check(struct udphdr *uh, int len, __be32 saddr, __be32 daddr, unsigned long base)
-{
-	return(csum_tcpudp_magic(saddr, daddr, len, IPPROTO_UDP, base));
-}
-
 int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len)
 {
@@ -516,8 +525,9 @@ int udp_sendmsg(struct kiocb *iocb, stru
 	__be32 daddr, faddr, saddr;
 	__be16 dport;
 	u8  tos;
-	int err;
+	int err, is_udplite = up->pcflag;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
+	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
@@ -622,7 +632,7 @@ int udp_sendmsg(struct kiocb *iocb, stru
 					      { .daddr = faddr,
 						.saddr = saddr,
 						.tos = tos } },
-				    .proto = IPPROTO_UDP,
+				    .proto = sk->sk_protocol,
 				    .uli_u = { .ports =
 					       { .sport = inet->sport,
 						 .dport = dport } } };
@@ -668,8 +678,9 @@ back_from_confirm:
 
 do_append_data:
 	up->len += ulen;
-	err = ip_append_data(sk, ip_generic_getfrag, msg->msg_iov, ulen, 
-			sizeof(struct udphdr), &ipc, rt, 
+	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
+	err = ip_append_data(sk, getfrag, msg->msg_iov, ulen,
+			sizeof(struct udphdr), &ipc, rt,
 			corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
 		udp_flush_pending_frames(sk);
@@ -684,7 +695,7 @@ out:
 	if (free)
 		kfree(ipc.opt);
 	if (!err) {
-		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS);
+		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
 		return len;
 	}
 	/*
@@ -695,7 +706,7 @@ out:
 	 * seems like overkill.
 	 */
 	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
-		UDP_INC_STATS_USER(UDP_MIB_SNDBUFERRORS);
+		UDP_INC_STATS_USER(UDP_MIB_SNDBUFERRORS, is_udplite);
 	}
 	return err;
 
@@ -795,17 +806,6 @@ int udp_ioctl(struct sock *sk, int cmd, 
 	return(0);
 }
 
-static __inline__ int __udp_checksum_complete(struct sk_buff *skb)
-{
-	return __skb_checksum_complete(skb);
-}
-
-static __inline__ int udp_checksum_complete(struct sk_buff *skb)
-{
-	return skb->ip_summed != CHECKSUM_UNNECESSARY &&
-		__udp_checksum_complete(skb);
-}
-
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
@@ -817,7 +817,7 @@ static int udp_recvmsg(struct kiocb *ioc
 	struct inet_sock *inet = inet_sk(sk);
   	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
   	struct sk_buff *skb;
-  	int copied, err;
+	int copied, err, copy_only, is_udplite = IS_UDPLITE(sk);
 
 	/*
 	 *	Check any passed addresses
@@ -839,15 +839,25 @@ try_again:
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
-		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov,
-					      copied);
-	} else if (msg->msg_flags&MSG_TRUNC) {
-		if (__udp_checksum_complete(skb))
+	/*
+	 * 	Decide whether to checksum and/or copy data.
+	 *
+	 * 	UDP:      checksum may have been computed in HW,
+	 * 	          (re-)compute it if message is truncated.
+	 * 	UDP-Lite: always needs to checksum, no HW support.
+	 */
+	copy_only = (skb->ip_summed==CHECKSUM_UNNECESSARY);
+
+	if (is_udplite  ||  (!copy_only  &&  msg->msg_flags&MSG_TRUNC)) {
+		if (__udp_lib_checksum_complete(skb))
 			goto csum_copy_err;
-		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov,
-					      copied);
-	} else {
+		copy_only = 1;
+	}
+
+	if (copy_only)
+		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
+					      msg->msg_iov, copied       );
+	else {
 		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
 
 		if (err == -EINVAL)
@@ -880,7 +890,8 @@ out:
   	return err;
 
 csum_copy_err:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS);
+	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
 
 	skb_kill_datagram(sk, skb, flags);
 
@@ -912,11 +923,6 @@ int udp_disconnect(struct sock *sk, int 
 	return 0;
 }
 
-static void udp_close(struct sock *sk, long timeout)
-{
-	sk_common_release(sk);
-}
-
 /* return:
  * 	1  if the the UDP system should process it
  *	0  if we should drop this packet
@@ -1021,10 +1027,8 @@ static int udp_queue_rcv_skb(struct sock
 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
 	 */
-	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb)) {
-		kfree_skb(skb);
-		return -1;
-	}
+	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
+		goto drop;
 	nf_reset(skb);
 
 	if (up->encap_type) {
@@ -1048,31 +1052,77 @@ static int udp_queue_rcv_skb(struct sock
 		if (ret < 0) {
 			/* process the ESP packet */
 			ret = xfrm4_rcv_encap(skb, up->encap_type);
-			UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS);
+			UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 			return -ret;
 		}
 		/* FALLTHROUGH -- it's a UDP Packet */
 	}
 
-	if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
-		if (__udp_checksum_complete(skb)) {
-			UDP_INC_STATS_BH(UDP_MIB_INERRORS);
-			kfree_skb(skb);
-			return -1;
+	/*
+	 * 	UDP-Lite specific tests, ignored on UDP sockets
+	 */
+	if ((up->pcflag & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
+
+		/*
+		 * MIB statistics other than incrementing the error count are
+		 * disabled for the following two types of errors: these depend
+		 * on the application settings, not on the functioning of the
+		 * protocol stack as such.
+		 *
+		 *
+		 * RFC 3828 here recommends (sec 3.3): "There should also be a
+		 * way ... to ... at least let the receiving application block
+		 * delivery of packets with coverage values less than a value
+		 * provided by the application."
+		 */
+		if (up->pcrlen == 0) {          /* full coverage was set  */
+			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE: partial coverage "
+				"%d while full coverage %d requested\n",
+				UDP_SKB_CB(skb)->cscov, skb->len);
+			goto drop;
+		}
+		/* The next case involves violating the min. coverage requested
+		 * by the receiver. This is subtle: if receiver wants x and x is
+		 * greater than the buffersize/MTU then receiver will complain
+		 * that it wants x while sender emits packets of smaller size y.
+		 * Therefore the above ...()->partial_cov statement is essential.
+		 */
+		if (UDP_SKB_CB(skb)->cscov  <  up->pcrlen) {
+			LIMIT_NETDEBUG(KERN_WARNING
+				"UDPLITE: coverage %d too small, need min %d\n",
+				UDP_SKB_CB(skb)->cscov, up->pcrlen);
+			goto drop;
 		}
+	}
+
+	if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
+		if (__udp_lib_checksum_complete(skb))
+			goto drop;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS);
-		UDP_INC_STATS_BH(UDP_MIB_INERRORS);
-		kfree_skb(skb);
-		return -1;
+			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+		goto drop;
 	}
-	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS);
+
+	/*
+	 *  Incrementing this counter when the datagram is later taken
+	 *  off the queue (e.g. due to receive failure) is problematic, cf.
+	 *     http://bugzilla.kernel.org/show_bug.cgi?id=6660
+	 *  This module counts correctly by decrementing InDatagrams
+	 *  whenever the datagram is popped off a queue without being
+	 *  actually delivered: see udp_recvmsg() and udp_poll().
+	 */
+	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 	return 0;
+
+drop:
+	UDP_INC_STATS_BH(UDP_MIB_INERRORS, up->pcflag);
+	kfree_skb(skb);
+	return -1;
 }
 
 /*
@@ -1081,14 +1131,16 @@ static int udp_queue_rcv_skb(struct sock
  *	Note: called only from the BH handler context,
  *	so we don't need to lock the hashes.
  */
-static int udp_v4_mcast_deliver(struct sk_buff *skb, struct udphdr *uh,
-				 __be32 saddr, __be32 daddr)
+static int __udp4_lib_mcast_deliver(struct sk_buff *skb,
+				    struct udphdr  *uh,
+				    __be32 saddr, __be32 daddr,
+				    struct hlist_head udptable[])
 {
 	struct sock *sk;
 	int dif;
 
 	read_lock(&udp_hash_lock);
-	sk = sk_head(&udp_hash[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
+	sk = sk_head(&udptable[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (sk) {
@@ -1117,6 +1169,12 @@ static int udp_v4_mcast_deliver(struct s
 	return 0;
 }
 
+static __inline__ int udp_v4_mcast_deliver(struct sk_buff *skb, struct udphdr *uh,
+					   __be32 saddr, __be32 daddr             )
+{
+	return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udp_hash);
+}
+
 /* Initialize UDP checksum. If exited with zero value (success),
  * CHECKSUM_UNNECESSARY means, that no more checks are required.
  * Otherwise, csum completion requires chacksumming packet body,
@@ -1128,7 +1186,7 @@ static void udp_checksum_init(struct sk_
 	if (uh->check == 0) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		if (!udp_check(uh, ulen, saddr, daddr, skb->csum))
+	       if (!csum_tcpudp_magic(saddr,daddr,ulen, IPPROTO_UDP, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
@@ -1136,16 +1194,20 @@ static void udp_checksum_init(struct sk_
 	/* Probably, we should checksum udp header (it should be in cache
 	 * in any case) and data in tiny packets (< rx copybreak).
 	 */
+
+	/* UDP = UDP-Lite with a non-partial checksum coverage */
+	UDP_SKB_CB(skb)->partial_cov = 0;
 }
 
 /*
  *	All we need to do is get the socket, and then do a checksum. 
  */
  
-int udp_rcv(struct sk_buff *skb)
+static int __udp4_lib_rcv(struct sk_buff *skb,
+			  struct hlist_head udptable[], int is_udplite)
 {
   	struct sock *sk;
-  	struct udphdr *uh;
+  	struct udphdr *uh = skb->h.uh;
 	unsigned short ulen;
 	struct rtable *rt = (struct rtable*)skb->dst;
 	__be32 saddr = skb->nh.iph->saddr;
@@ -1153,34 +1215,40 @@ int udp_rcv(struct sk_buff *skb)
 	int len = skb->len;
 
 	/*
-	 *	Validate the packet and the UDP length.
+	 *  Validate the packet.
 	 */
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
-		goto no_header;
-
-	uh = skb->h.uh;
+		goto drop;		/* No space for header. */
 
 	ulen = ntohs(uh->len);
-
-	if (ulen > len || ulen < sizeof(*uh))
+	if (ulen > len)
 		goto short_packet;
 
-	if (pskb_trim_rcsum(skb, ulen))
-		goto short_packet;
+	if(! is_udplite ) {		/* UDP validates ulen. */
 
-	udp_checksum_init(skb, uh, ulen, saddr, daddr);
+		if (ulen < sizeof(*uh) || pskb_trim_rcsum(skb, ulen))
+			goto short_packet;
+
+		/* note the difference: UDP uses ulen, UDP-Lite uses len */
+		udp_checksum_init(skb, uh, ulen, saddr, daddr);
+
+	} else 	{			/* UDP-Lite validates cscov. */
+		if (! udplite_checksum_init(skb, uh, len, saddr, daddr))
+			goto csum_error;
+	}
 
 	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-		return udp_v4_mcast_deliver(skb, uh, saddr, daddr);
+		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
-	sk = udp_v4_lookup(saddr, uh->source, daddr, uh->dest, skb->dev->ifindex);
+	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
+			       skb->dev->ifindex, udptable        );
 
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
 		/* a return value > 0 means to resubmit the input, but
-		 * it it wants the return to be -protocol, or 0
+		 * it wants the return to be -protocol, or 0
 		 */
 		if (ret > 0)
 			return -ret;
@@ -1195,7 +1263,7 @@ int udp_rcv(struct sk_buff *skb)
 	if (udp_checksum_complete(skb))
 		goto csum_error;
 
-	UDP_INC_STATS_BH(UDP_MIB_NOPORTS);
+	UDP_INC_STATS_BH(UDP_MIB_NOPORTS, is_udplite);
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 	/*
@@ -1206,35 +1274,39 @@ int udp_rcv(struct sk_buff *skb)
 	return(0);
 
 short_packet:
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP: short packet: From %u.%u.%u.%u:%u %d/%d to %u.%u.%u.%u:%u\n",
+	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: short packet: From %u.%u.%u.%u:%u %d/%d to %u.%u.%u.%u:%u\n",
+		       is_udplite? "-Lite" : "",
 		       NIPQUAD(saddr),
 		       ntohs(uh->source),
 		       ulen,
 		       len,
 		       NIPQUAD(daddr),
 		       ntohs(uh->dest));
-no_header:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS);
-	kfree_skb(skb);
-	return(0);
+	goto drop;
 
 csum_error:
 	/* 
 	 * RFC1122: OK.  Discards the bad packet silently (as far as 
 	 * the network is concerned, anyway) as per 4.1.3.4 (MUST). 
 	 */
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP: bad checksum. From %d.%d.%d.%d:%d to %d.%d.%d.%d:%d ulen %d\n",
+	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: bad checksum. From %d.%d.%d.%d:%d to %d.%d.%d.%d:%d ulen %d\n",
+		       is_udplite? "-Lite" : "",
 		       NIPQUAD(saddr),
 		       ntohs(uh->source),
 		       NIPQUAD(daddr),
 		       ntohs(uh->dest),
 		       ulen);
 drop:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS);
+	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return(0);
 }
 
+__inline__ int udp_rcv(struct sk_buff *skb)
+{
+	return __udp4_lib_rcv(skb, udp_hash, 0);
+}
+
 static int udp_destroy_sock(struct sock *sk)
 {
 	lock_sock(sk);
@@ -1284,6 +1356,32 @@ static int do_udp_setsockopt(struct sock
 		}
 		break;
 
+	/*
+	 * 	UDP-Lite's partial checksum coverage (RFC 3828).
+	 */
+	/* The sender sets actual checksum coverage length via this option.
+	 * The case coverage > packet length is handled by send module. */
+	case UDPLITE_SEND_CSCOV:
+		if (!up->pcflag)         /* Disable the option on UDP sockets */
+			return -ENOPROTOOPT;
+		if (val != 0 && val < 8) /* Illegal coverage: use default (8) */
+			val = 8;
+		up->pcslen = val;
+		up->pcflag |= UDPLITE_SEND_CC;
+		break;
+
+        /* The receiver specifies a minimum checksum coverage value. To make
+         * sense, this should be set to at least 8 (as done below). If zero is
+	 * used, this again means full checksum coverage.                     */
+	case UDPLITE_RECV_CSCOV:
+		if (!up->pcflag)         /* Disable the option on UDP sockets */
+			return -ENOPROTOOPT;
+		if (val != 0 && val < 8) /* Avoid silly minimal values.       */
+			val = 8;
+		up->pcrlen = val;
+		up->pcflag |= UDPLITE_RECV_CC;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -1295,18 +1393,18 @@ static int do_udp_setsockopt(struct sock
 static int udp_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int optlen)
 {
-	if (level != SOL_UDP)
-		return ip_setsockopt(sk, level, optname, optval, optlen);
-	return do_udp_setsockopt(sk, level, optname, optval, optlen);
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udp_setsockopt(sk, level, optname, optval, optlen);
+	return ip_setsockopt(sk, level, optname, optval, optlen);
 }
 
 #ifdef CONFIG_COMPAT
 static int compat_udp_setsockopt(struct sock *sk, int level, int optname,
 				 char __user *optval, int optlen)
 {
-	if (level != SOL_UDP)
-		return compat_ip_setsockopt(sk, level, optname, optval, optlen);
-	return do_udp_setsockopt(sk, level, optname, optval, optlen);
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udp_setsockopt(sk, level, optname, optval, optlen);
+	return compat_ip_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
 
@@ -1333,6 +1431,16 @@ static int do_udp_getsockopt(struct sock
 		val = up->encap_type;
 		break;
 
+	/* The following two cannot be changed on UDP sockets, the return is
+	 * always 0 (which corresponds to the full checksum coverage of UDP). */
+	case UDPLITE_SEND_CSCOV:
+		val = up->pcslen;
+		break;
+
+	case UDPLITE_RECV_CSCOV:
+		val = up->pcrlen;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	};
@@ -1347,18 +1455,18 @@ static int do_udp_getsockopt(struct sock
 static int udp_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen)
 {
-	if (level != SOL_UDP)
-		return ip_getsockopt(sk, level, optname, optval, optlen);
-	return do_udp_getsockopt(sk, level, optname, optval, optlen);
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udp_getsockopt(sk, level, optname, optval, optlen);
+	return ip_getsockopt(sk, level, optname, optval, optlen);
 }
 
 #ifdef CONFIG_COMPAT
 static int compat_udp_getsockopt(struct sock *sk, int level, int optname,
 				 char __user *optval, int __user *optlen)
 {
-	if (level != SOL_UDP)
-		return compat_ip_getsockopt(sk, level, optname, optval, optlen);
-	return do_udp_getsockopt(sk, level, optname, optval, optlen);
+	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+		return do_udp_getsockopt(sk, level, optname, optval, optlen);
+	return compat_ip_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
 /**
@@ -1378,7 +1486,8 @@ unsigned int udp_poll(struct file *file,
 {
 	unsigned int mask = datagram_poll(file, sock, wait);
 	struct sock *sk = sock->sk;
-	
+	int 	is_lite = IS_UDPLITE(sk);
+
 	/* Check for false positives due to checksum errors */
 	if ( (mask & POLLRDNORM) &&
 	     !(file->f_flags & O_NONBLOCK) &&
@@ -1389,7 +1498,11 @@ unsigned int udp_poll(struct file *file,
 		spin_lock_bh(&rcvq->lock);
 		while ((skb = skb_peek(rcvq)) != NULL) {
 			if (udp_checksum_complete(skb)) {
-				UDP_INC_STATS_BH(UDP_MIB_INERRORS);
+				/* The datagram has already been counted as
+				 * InDatagram when earlier it was enqueued.
+				 * Update count of really received datagrams. */
+				UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS, is_lite);
+				UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_lite);
 				__skb_unlink(skb, rcvq);
 				kfree_skb(skb);
 			} else {
@@ -1411,7 +1524,7 @@ unsigned int udp_poll(struct file *file,
 struct proto udp_prot = {
  	.name		   = "UDP",
 	.owner		   = THIS_MODULE,
-	.close		   = udp_close,
+	.close		   = udp_lib_close,
 	.connect	   = ip4_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
@@ -1422,8 +1535,8 @@ struct proto udp_prot = {
 	.recvmsg	   = udp_recvmsg,
 	.sendpage	   = udp_sendpage,
 	.backlog_rcv	   = udp_queue_rcv_skb,
-	.hash		   = udp_v4_hash,
-	.unhash		   = udp_v4_unhash,
+	.hash		   = udp_lib_hash,
+	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
@@ -1442,7 +1555,7 @@ static struct sock *udp_get_first(struct
 
 	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
 		struct hlist_node *node;
-		sk_for_each(sk, node, &udp_hash[state->bucket]) {
+		sk_for_each(sk, node, state->hashtable + state->bucket) {
 			if (sk->sk_family == state->family)
 				goto found;
 		}
@@ -1463,7 +1576,7 @@ try_again:
 	} while (sk && sk->sk_family != state->family);
 
 	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
-		sk = sk_head(&udp_hash[state->bucket]);
+		sk = sk_head(state->hashtable + state->bucket);
 		goto try_again;
 	}
 	return sk;
@@ -1513,6 +1626,7 @@ static int udp_seq_open(struct inode *in
 	if (!s)
 		goto out;
 	s->family		= afinfo->family;
+	s->hashtable		= afinfo->hashtable;
 	s->seq_ops.start	= udp_seq_start;
 	s->seq_ops.next		= udp_seq_next;
 	s->seq_ops.show		= afinfo->seq_show;
@@ -1579,7 +1693,7 @@ static void udp4_format_sock(struct sock
 		atomic_read(&sp->sk_refcnt), sp);
 }
 
-static int udp4_seq_show(struct seq_file *seq, void *v)
+int udp4_seq_show(struct seq_file *seq, void *v)
 {
 	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "%-127s\n",
@@ -1602,6 +1716,7 @@ static struct udp_seq_afinfo udp4_seq_af
 	.owner		= THIS_MODULE,
 	.name		= "udp",
 	.family		= AF_INET,
+	.hashtable	= udp_hash,
 	.seq_show	= udp4_seq_show,
 	.seq_fops	= &udp4_seq_fops,
 };
@@ -1630,3 +1745,5 @@ #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
 EXPORT_SYMBOL(udp_proc_unregister);
 #endif
+/* the extensions for UDP-Lite (RFC 3828) */
+#include "udplite.c"
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
new file mode 100644
index 0000000..84d09f3
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
+	.close		   = udp_lib_close,
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
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 7a7a001..923a48b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -199,6 +199,7 @@ _decode_session4(struct sk_buff *skb, st
 	if (!(iph->frag_off & htons(IP_MF | IP_OFFSET))) {
 		switch (iph->protocol) {
 		case IPPROTO_UDP:
+		case IPPROTO_UDPLITE:
 		case IPPROTO_TCP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 0cf537d..3cb6bb7 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -270,11 +270,15 @@ static void dump_packet(const struct nf_
 		}
 		break;
 	}
-	case IPPROTO_UDP: {
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE: {
 		struct udphdr _udph, *uh;
 
-		/* Max length: 10 "PROTO=UDP " */
-		printk("PROTO=UDP ");
+		if (currenthdr == IPPROTO_UDP)
+			/* Max length: 10 "PROTO=UDP "     */
+			printk("PROTO=UDP " );
+		else	/* Max length: 14 "PROTO=UDPLITE " */
+			printk("PROTO=UDPLITE ");
 
 		if (fragment)
 			break;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e0c3934..fc9761f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -66,21 +66,6 @@ static inline int udp_v6_get_port(struct
 	return udp_get_port(sk, snum, ipv6_rcv_saddr_equal);
 }
 
-static void udp_v6_hash(struct sock *sk)
-{
-	BUG();
-}
-
-static void udp_v6_unhash(struct sock *sk)
-{
- 	write_lock_bh(&udp_hash_lock);
-	if (sk_del_node_init(sk)) {
-		inet_sk(sk)->num = 0;
-		sock_prot_dec_use(sk->sk_prot);
-	}
-	write_unlock_bh(&udp_hash_lock);
-}
-
 static struct sock *udp_v6_lookup(struct in6_addr *saddr, u16 sport,
 				  struct in6_addr *daddr, u16 dport, int dif)
 {
@@ -132,15 +117,6 @@ static struct sock *udp_v6_lookup(struct
 }
 
 /*
- *
- */
-
-static void udpv6_close(struct sock *sk, long timeout)
-{
-	sk_common_release(sk);
-}
-
-/*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
  */
@@ -499,35 +475,12 @@ static int udp_v6_push_pending_frames(st
 	uh->len = htons(up->len);
 	uh->check = 0;
 
-	if (sk->sk_no_check == UDP_CSUM_NOXMIT) {
-		skb->ip_summed = CHECKSUM_NONE;
-		goto send;
-	}
-
-	if (skb_queue_len(&sk->sk_write_queue) == 1) {
-		skb->csum = csum_partial((char *)uh,
-				sizeof(struct udphdr), skb->csum);
-		uh->check = csum_ipv6_magic(&fl->fl6_src,
-					    &fl->fl6_dst,
-					    up->len, fl->proto, skb->csum);
-	} else {
-		u32 tmp_csum = 0;
-
-		skb_queue_walk(&sk->sk_write_queue, skb) {
-			tmp_csum = csum_add(tmp_csum, skb->csum);
-		}
-		tmp_csum = csum_partial((char *)uh,
-				sizeof(struct udphdr), tmp_csum);
-                tmp_csum = csum_ipv6_magic(&fl->fl6_src,
-					   &fl->fl6_dst,
-					   up->len, fl->proto, tmp_csum);
-                uh->check = tmp_csum;
-
-	}
+	uh->check = csum_ipv6_magic(&fl->fl6_src, &fl->fl6_dst,
+				    up->len, fl->proto,
+				    udp_csum_outgoing(sk, skb) );
 	if (uh->check == 0)
 		uh->check = -1;
 
-send:
 	err = ip6_push_pending_frames(sk);
 out:
 	up->len = 0;
@@ -1003,6 +956,7 @@ static struct udp_seq_afinfo udp6_seq_af
 	.owner		= THIS_MODULE,
 	.name		= "udp6",
 	.family		= AF_INET6,
+	.hashtable	= udp_hash,
 	.seq_show	= udp6_seq_show,
 	.seq_fops	= &udp6_seq_fops,
 };
@@ -1022,7 +976,7 @@ #endif /* CONFIG_PROC_FS */
 struct proto udpv6_prot = {
 	.name		   = "UDPv6",
 	.owner		   = THIS_MODULE,
-	.close		   = udpv6_close,
+	.close		   = udp_lib_close,
 	.connect	   = ip6_datagram_connect,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = udp_ioctl,
@@ -1032,8 +986,8 @@ struct proto udpv6_prot = {
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
 	.backlog_rcv	   = udpv6_queue_rcv_skb,
-	.hash		   = udp_v6_hash,
-	.unhash		   = udp_v6_unhash,
+	.hash		   = udp_lib_hash,
+	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
 	.obj_size	   = sizeof(struct udp6_sock),
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 6a252e2..cb352e3 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -272,6 +272,7 @@ _decode_session6(struct sk_buff *skb, st
 			break;
 
 		case IPPROTO_UDP:
+		case IPPROTO_UDPLITE:
 		case IPPROTO_TCP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index d3aefd3..c3b4bc0 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -1,5 +1,5 @@
-/* Kernel module to match one of a list of TCP/UDP/SCTP/DCCP ports: ports are in
-   the same place so we can treat them as equal. */
+/* Kernel module to match one of a list of TCP/UDP(-Lite)/SCTP/DCCP ports:
+   ports are in the same place so we can treat them as equal. */
 
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
@@ -162,6 +162,7 @@ check(u_int16_t proto,
 {
 	/* Must specify supported protocol, no unknown flags or bad count */
 	return (proto == IPPROTO_TCP || proto == IPPROTO_UDP
+		|| proto == IPPROTO_UDPLITE
 		|| proto == IPPROTO_SCTP || proto == IPPROTO_DCCP)
 		&& !(ip_invflags & XT_INV_PROTO)
 		&& (match_flags == XT_MULTIPORT_SOURCE
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index e76a68e..46414b5 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -10,7 +10,7 @@ #include <linux/netfilter/xt_tcpudp.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 
-MODULE_DESCRIPTION("x_tables match for TCP and UDP, supports IPv4 and IPv6");
+MODULE_DESCRIPTION("x_tables match for TCP and UDP(-Lite), supports IPv4 and IPv6");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("xt_tcp");
 MODULE_ALIAS("xt_udp");
@@ -234,6 +234,24 @@ static struct xt_match xt_tcpudp_match[]
 		.proto		= IPPROTO_UDP,
 		.me		= THIS_MODULE,
 	},
+	{
+		.name		= "udplite",
+		.family		= AF_INET,
+		.checkentry	= udp_checkentry,
+		.match		= udp_match,
+		.matchsize	= sizeof(struct xt_udp),
+		.proto		= IPPROTO_UDPLITE,
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "udplite",
+		.family		= AF_INET6,
+		.checkentry	= udp_checkentry,
+		.match		= udp_match,
+		.matchsize	= sizeof(struct xt_udp),
+		.proto		= IPPROTO_UDPLITE,
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init xt_tcpudp_init(void)
