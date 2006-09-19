From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCHv3  1/4][RFC]     net/ipv4: consolidated UDP / UDP-Lite code
Date: Tue, 19 Sep 2006 08:25:23 +0100
Message-ID: <200609190825.23709@strip-the-willow>
References: <200607141719.02766@strip-the-willow> <20060727.223010.63131639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43765 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1751103AbWISHZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 03:25:37 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060727.223010.63131639.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

please find enclosed for review the proposed changes to integrate UDP-Lite
code with UDP.

Please disregard all earlier patches, I have been putting in more hard work to
consolidate the code further, also with regard to expanding to UDP(-Lite) v6.
(Reductions are drastic: udplite.c is slimmed down to 186 lines.)

This is the v4-side and with a minimum of formatting diffs. Any suggestions
for v4  will automatically be incorporated into the v6 side in the subsequent
revision.

Enclosed patch applies on your 2.6.19 tree and on 2.6.18-rc6-mm2 and has been
tested (UDPv4/v6 as well) for quite a while.

                    R e s o l v e d   I s s u e s

a)  Common Naming scheme:

     --stuff that works for both UDPv4/6 and UDP-Litev4/6 is called udp_lib_xxx()
        * restricted to v4: udp4_lib_xxx()
        * restricted to v6: udp6_lib_xxx()
        * when it should not be called directly:  __udp_lib_xxx() [resp.__udp{4,6}_lib_xxx()]

     --some old functions (e.g. udp_v4_mcast_next()) have retained their name
       although they would need to be renamed (here udp4_lib_mcast_next());
       this  is left for later -- a `name-change-only' patch

b)  Correct MIB-counting of de facto received datagrams (resolving
     http://bugzilla.kernel.org/show_bug.cgi?id=6660 for this module; some follow-up
    work may have to look at doing the same for sunrpc, nfs, and likewise)

c)  udp_v{4,6}_get_port(): consolidated.


                          C h a n g e l o g

* inline functions which are shared between UDP and UDP-Lite and v4/v6 have
  been put into header files rather than duplicated in source files
* made net/ipv4/udplite.c self-contained unit (#included at the end of udp.c)
* consolidated v4/v6 checksumming code (generic now for UDP and UDP-Lite)
  --new:           udp_csum_outgoing()
  --contrasts with udplite_csum_outgoing()
  --removed support for disabling UDPv6 checksums (RFC 2460 says it's illegal)
* udp_v{4,6}_hash() and udp_v{4,6}_unhash() identical: inlined into header file
* basic xfrm/netfilter support (thanks to Patrick McHardy)
* updated the protocol registration in udplite4_register to not do
  /proc registration on error (thanks to comments by James Morris)
* detailed per-function breakdown as per earlier mail

Regards,
Gerrit
--
 include/linux/udp.h |   11 +
 include/net/udp.h   |   89 +++++++++
 net/ipv4/udp.c      |  485 ++++++++++++++++++++++++++++++++--------------------
 net/ipv6/udp.c      |   50 -----
 4 files changed, 406 insertions(+), 229 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 90223f0..1b7cf10 100644
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
 
diff --git a/include/net/udp.h b/include/net/udp.h
index db0c05f..b22abb3 100644
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
@@ -47,6 +69,56 @@ extern struct proto udp_prot;
 
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
+/* net/ipv4/udp.c */
 extern int	udp_get_port(struct sock *sk, unsigned short snum,
 			     int (*saddr_cmp)(const struct sock *, const struct sock *));
 extern void	udp_err(struct sk_buff *, u32);
@@ -61,21 +133,32 @@ extern unsigned int udp_poll(struct file
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
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 77e265d..9bbb2b2 100644
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
+static inline int __udp_lib_lport_inuse(u16 num, struct hlist_head udptable[])
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
@@ -225,33 +232,20 @@ static inline int udp_v4_get_port(struct
 }
 
 
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
-static struct sock *udp_v4_lookup_longway(u32 saddr, u16 sport,
-					  u32 daddr, u16 dport, int dif)
+static struct sock *__udp4_lib_lookup(u32 saddr, u16 sport,
+				      u32 daddr, u16 dport,
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
@@ -285,20 +279,17 @@ static struct sock *udp_v4_lookup_longwa
 			}
 		}
 	}
+	if (result)
+		sock_hold(result);
+	read_unlock(&udp_hash_lock);
+
 	return result;
 }
 
 static __inline__ struct sock *udp_v4_lookup(u32 saddr, u16 sport,
 					     u32 daddr, u16 dport, int dif)
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
@@ -340,7 +331,8 @@ found:
  * to find the appropriate port.
  */
 
-void udp_err(struct sk_buff *skb, u32 info)
+static void __udp4_lib_err(struct sk_buff *skb, u32 info,
+			   struct hlist_head udptable[]  )
 {
 	struct inet_sock *inet;
 	struct iphdr *iph = (struct iphdr*)skb->data;
@@ -351,7 +343,8 @@ void udp_err(struct sk_buff *skb, u32 in
 	int harderr;
 	int err;
 
-	sk = udp_v4_lookup(iph->daddr, uh->dest, iph->saddr, uh->source, skb->dev->ifindex);
+	sk = __udp4_lib_lookup(iph->daddr, uh->dest, iph->saddr, uh->source,
+			       skb->dev->ifindex, udptable		    );
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
     	  	return;	/* No socket for error */
@@ -405,6 +398,11 @@ out:
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
@@ -419,6 +417,45 @@ static void udp_flush_pending_frames(str
 	}
 }
 
+/**
+ * 	udp4_hwcsum_outgoing  -  handle outgoing HW checksumming
+ * 	@sk: 	socket we are sending on
+ * 	@skb: 	sk_buff containing the filled-in UDP header
+ * 	        (checksum field must be zeroed out)
+ */
+static void udp4_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
+				 u32 src, u32 dst, int len            )
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
@@ -429,6 +466,7 @@ static int udp_push_pending_frames(struc
 	struct sk_buff *skb;
 	struct udphdr *uh;
 	int err = 0;
+	u32 csum = 0;
 
 	/* Grab the skbuff where UDP header space exists. */
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
@@ -443,52 +481,31 @@ static int udp_push_pending_frames(struc
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
@@ -497,12 +514,6 @@ out:
 	return err;
 }
 
-
-static unsigned short udp_check(struct udphdr *uh, int len, unsigned long saddr, unsigned long daddr, unsigned long base)
-{
-	return(csum_tcpudp_magic(saddr, daddr, len, IPPROTO_UDP, base));
-}
-
 int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len)
 {
@@ -516,8 +527,9 @@ int udp_sendmsg(struct kiocb *iocb, stru
 	u32 daddr, faddr, saddr;
 	u16 dport;
 	u8  tos;
-	int err;
+	int err, is_udplite = up->pcflag;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
+	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
@@ -622,7 +634,7 @@ int udp_sendmsg(struct kiocb *iocb, stru
 					      { .daddr = faddr,
 						.saddr = saddr,
 						.tos = tos } },
-				    .proto = IPPROTO_UDP,
+				    .proto = sk->sk_protocol,
 				    .uli_u = { .ports =
 					       { .sport = inet->sport,
 						 .dport = dport } } };
@@ -668,8 +680,9 @@ back_from_confirm:
 
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
@@ -682,7 +695,7 @@ out:
 	if (free)
 		kfree(ipc.opt);
 	if (!err) {
-		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS);
+		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
 		return len;
 	}
 	/*
@@ -693,7 +706,7 @@ out:
 	 * seems like overkill.
 	 */
 	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
-		UDP_INC_STATS_USER(UDP_MIB_SNDBUFERRORS);
+		UDP_INC_STATS_USER(UDP_MIB_SNDBUFERRORS, is_udplite);
 	}
 	return err;
 
@@ -793,17 +806,6 @@ int udp_ioctl(struct sock *sk, int cmd, 
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
@@ -815,7 +817,7 @@ static int udp_recvmsg(struct kiocb *ioc
 	struct inet_sock *inet = inet_sk(sk);
   	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
   	struct sk_buff *skb;
-  	int copied, err;
+	int copied, err, copy_only, is_udplite = IS_UDPLITE(sk);
 
 	/*
 	 *	Check any passed addresses
@@ -837,15 +839,25 @@ try_again:
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
@@ -878,7 +890,8 @@ out:
   	return err;
 
 csum_copy_err:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS);
+	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
 
 	skb_kill_datagram(sk, skb, flags);
 
@@ -1019,10 +1032,8 @@ static int udp_queue_rcv_skb(struct sock
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
@@ -1046,31 +1057,77 @@ static int udp_queue_rcv_skb(struct sock
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
 		}
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
+		}
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
+	 * XXX  Incrementing this counter when the datagram is later taken
+	 *	off the queue due to receive failure is problematic, cf.
+	 *	http://bugzilla.kernel.org/show_bug.cgi?id=6660
+	 * This module counts correctly by decrementing InDatagrams
+	 * whenever the datagram is popped off a queue without being
+	 * actually delivered; see also udp_recvmsg() and udp_poll().
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
@@ -1079,14 +1136,14 @@ static int udp_queue_rcv_skb(struct sock
  *	Note: called only from the BH handler context,
  *	so we don't need to lock the hashes.
  */
-static int udp_v4_mcast_deliver(struct sk_buff *skb, struct udphdr *uh,
-				 u32 saddr, u32 daddr)
+static int __udp4_lib_mcast_deliver(struct sk_buff *skb, struct udphdr *uh,
+			u32 saddr, u32 daddr, struct hlist_head udptable[])
 {
 	struct sock *sk;
 	int dif;
 
 	read_lock(&udp_hash_lock);
-	sk = sk_head(&udp_hash[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
+	sk = sk_head(&udptable[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (sk) {
@@ -1115,6 +1172,12 @@ static int udp_v4_mcast_deliver(struct s
 	return 0;
 }
 
+static __inline__ int udp_v4_mcast_deliver(struct sk_buff *skb,
+					struct udphdr *uh, u32 saddr, u32 daddr)
+{
+	return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udp_hash);
+}
+
 /* Initialize UDP checksum. If exited with zero value (success),
  * CHECKSUM_UNNECESSARY means, that no more checks are required.
  * Otherwise, csum completion requires chacksumming packet body,
@@ -1126,7 +1189,7 @@ static void udp_checksum_init(struct sk_
 	if (uh->check == 0) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		if (!udp_check(uh, ulen, saddr, daddr, skb->csum))
+	       if (!csum_tcpudp_magic(saddr,daddr,ulen, IPPROTO_UDP, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
@@ -1134,16 +1197,19 @@ static void udp_checksum_init(struct sk_
 	/* Probably, we should checksum udp header (it should be in cache
 	 * in any case) and data in tiny packets (< rx copybreak).
 	 */
+
+	/* UDP = UDP-Lite with a non-partial checksum coverage */
+	UDP_SKB_CB(skb)->partial_cov = 0;
 }
 
 /*
- *	All we need to do is get the socket, and then do a checksum. 
+ *	All we need to do is get the socket, and then do a checksum.
  */
- 
-int udp_rcv(struct sk_buff *skb)
+static int __udp4_lib_rcv(struct sk_buff *skb,
+			  struct hlist_head udptable[], int is_udplite)
 {
   	struct sock *sk;
-  	struct udphdr *uh;
+  	struct udphdr *uh = skb->h.uh;
 	unsigned short ulen;
 	struct rtable *rt = (struct rtable*)skb->dst;
 	u32 saddr = skb->nh.iph->saddr;
@@ -1151,34 +1217,39 @@ int udp_rcv(struct sk_buff *skb)
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
+
+		if ( ulen < sizeof(*uh)  ||  pskb_trim_rcsum(skb, ulen) )
+			goto short_packet;
+		/* note the difference: UDP uses ulen, UDP-Lite uses len */
+		udp_checksum_init(skb, uh, ulen, saddr, daddr);
 
-	udp_checksum_init(skb, uh, ulen, saddr, daddr);
+	} else 	{			/* UDP-Lite validates cscov. */
+		if (! udplite_checksum_init(skb, uh, len, saddr, daddr) )
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
@@ -1193,7 +1264,7 @@ int udp_rcv(struct sk_buff *skb)
 	if (udp_checksum_complete(skb))
 		goto csum_error;
 
-	UDP_INC_STATS_BH(UDP_MIB_NOPORTS);
+	UDP_INC_STATS_BH(UDP_MIB_NOPORTS, is_udplite);
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 	/*
@@ -1204,35 +1275,39 @@ int udp_rcv(struct sk_buff *skb)
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
-	/* 
-	 * RFC1122: OK.  Discards the bad packet silently (as far as 
-	 * the network is concerned, anyway) as per 4.1.3.4 (MUST). 
+	/*
+	 * RFC1122: OK.  Discards the bad packet silently (as far as
+	 * the network is concerned, anyway) as per 4.1.3.4 (MUST).
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
@@ -1282,6 +1357,32 @@ static int do_udp_setsockopt(struct sock
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
@@ -1293,18 +1394,18 @@ static int do_udp_setsockopt(struct sock
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
 
@@ -1331,6 +1432,15 @@ static int do_udp_getsockopt(struct sock
 		val = up->encap_type;
 		break;
 
+	/* the following two always return 0 on UDP sockets */
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
@@ -1345,18 +1455,18 @@ static int do_udp_getsockopt(struct sock
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
@@ -1376,7 +1486,8 @@ unsigned int udp_poll(struct file *file,
 {
 	unsigned int mask = datagram_poll(file, sock, wait);
 	struct sock *sk = sock->sk;
-	
+	int 	is_lite = IS_UDPLITE(sk);
+
 	/* Check for false positives due to checksum errors */
 	if ( (mask & POLLRDNORM) &&
 	     !(file->f_flags & O_NONBLOCK) &&
@@ -1387,7 +1498,11 @@ unsigned int udp_poll(struct file *file,
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
@@ -1420,8 +1535,8 @@ struct proto udp_prot = {
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
@@ -1440,7 +1555,7 @@ static struct sock *udp_get_first(struct
 
 	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
 		struct hlist_node *node;
-		sk_for_each(sk, node, &udp_hash[state->bucket]) {
+		sk_for_each(sk, node, state->hashtable + state->bucket) {
 			if (sk->sk_family == state->family)
 				goto found;
 		}
@@ -1461,7 +1576,7 @@ try_again:
 	} while (sk && sk->sk_family != state->family);
 
 	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
-		sk = sk_head(&udp_hash[state->bucket]);
+		sk = sk_head(state->hashtable + state->bucket);
 		goto try_again;
 	}
 	return sk;
@@ -1511,6 +1626,7 @@ static int udp_seq_open(struct inode *in
 	if (!s)
 		goto out;
 	s->family		= afinfo->family;
+	s->hashtable		= afinfo->hashtable;
 	s->seq_ops.start	= udp_seq_start;
 	s->seq_ops.next		= udp_seq_next;
 	s->seq_ops.show		= afinfo->seq_show;
@@ -1577,7 +1693,7 @@ static void udp4_format_sock(struct sock
 		atomic_read(&sp->sk_refcnt), sp);
 }
 
-static int udp4_seq_show(struct seq_file *seq, void *v)
+int udp4_seq_show(struct seq_file *seq, void *v)
 {
 	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "%-127s\n",
@@ -1600,6 +1716,7 @@ static struct udp_seq_afinfo udp4_seq_af
 	.owner		= THIS_MODULE,
 	.name		= "udp",
 	.family		= AF_INET,
+	.hashtable	= udp_hash,
 	.seq_show	= udp4_seq_show,
 	.seq_fops	= &udp4_seq_fops,
 };
@@ -1628,3 +1745,5 @@ #ifdef CONFIG_PROC_FS
 EXPORT_SYMBOL(udp_proc_register);
 EXPORT_SYMBOL(udp_proc_unregister);
 #endif
+/* the extensions for UDP-Lite (RFC 3828) */
+#include "udplite.c"
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9662561..cf6cd7a 100644
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
@@ -485,6 +470,7 @@ static int udp_v6_push_pending_frames(st
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	int err = 0;
+	u32 csum;
 
 	/* Grab the skbuff where UDP header space exists. */
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
@@ -499,35 +485,12 @@ static int udp_v6_push_pending_frames(st
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
+	csum = udp_csum_outgoing(sk, skb);
+	uh->check = csum_ipv6_magic(&fl->fl6_src, &fl->fl6_dst,
+				    up->len, fl->proto, csum   );
 	if (uh->check == 0)
 		uh->check = -1;
 
-send:
 	err = ip6_push_pending_frames(sk);
 out:
 	up->len = 0;
@@ -1001,6 +964,7 @@ static struct udp_seq_afinfo udp6_seq_af
 	.owner		= THIS_MODULE,
 	.name		= "udp6",
 	.family		= AF_INET6,
+	.hashtable	= udp_hash,
 	.seq_show	= udp6_seq_show,
 	.seq_fops	= &udp6_seq_fops,
 };
@@ -1030,8 +994,8 @@ struct proto udpv6_prot = {
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

