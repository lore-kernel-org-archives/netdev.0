From: Samo Pogacnik <samo.pogacnik@s5.net>
Subject: network interface groups
Date: Tue, 2 Dec 2003 22:43:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312022225.hB2MP0Ta005412@oss.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,

i made a small modification of the linux networking code, that might be 
interesting to someone. So here is the description of what i did and 
a linux patch at the end of the description. The following URL:
http://friends.s5.net/pogacnik/net_if_grp.html leeds to linux 
(2.4.18 and 2.6.0-test11) and ifconfig patches.

----------------------------------------------------------------------
Network interface groups

1. Introduction
Provided modification gives you the possibility to assign a set of group numbers 
between 0 and 31 to each network interface in the system and to configure 
your networking services to be accessible on those groups of interfaces, 
as you like.

The linux patch implements this functionality (IPv4 only), while the net-tools 
(ifconfig) patch adds the ability to manage group numbers of each network 
interface.

2. How this works or How I think that this works?
This code extends the ability of a socket to accept packets on 
ANY of your network interfaces into the ability to accept packets on a selected 
group of network interfaces.

The goal was achived in a way, that an interface group mask number has been added 
to the net_device structure and another one to the inet_opt structure. 
When the received packet looks for its socket, the group mask of the associated 
network interface has to match the socket's group mask at least in one bit.
This way a bind system call with the desired interface group number as its parameter
(instead of an IP or INADDR_ANY), selects a group of interfaces that may provide 
packets on this socket.

By default all network interfaces belong only to group 0, as well as all sockets 
initialise its group mask to group 0.

You may change group mask of network interfaces while network services are 
running, using the patched ifconfig tool. For example, the result of changing 
the group mask number of an interface may be, that a network service stops accepting 
connections via this interface, while the existing connections remain 
operational until they are closed. The same way a network service may start 
accepting connections via the desired interface.

The good thing about this solution is, that the default behaviour of this 
extension should not make any significant difference (correct me if i'm wrong),
because all network interfaces fall into group zero by default.

3. What is it good for?
Separating network services, moving services between interfaces, better 
security, ....???

4. To think about
Can we use this aproach on IPv6?
Do we need more than 32 groups?

5. Note:
To be able to build the patched ifconfig tool, you have to synchronise changes 
of linux headers if.h and sockios.h with coresponding libc headers (net/if.h 
and bits/ioctls.h - on my system) and correctly set the Linux headers path.

Comments appreciated:)

	Samo
	
samo.pogacnik@s5.net
--------------------------------------------------------------------------


diff -Nur linux-2.6.0-test11/include/linux/if.h linux-2.6.0-test11-ifgrp/include/linux/if.h
--- linux-2.6.0-test11/include/linux/if.h	Wed Nov 26 21:43:51 2003
+++ linux-2.6.0-test11-ifgrp/include/linux/if.h	Tue Dec  2 19:58:09 2003
@@ -141,6 +141,7 @@
 		short	ifru_flags;
 		int	ifru_ivalue;
 		int	ifru_mtu;
+		unsigned int ifru_group;
 		struct  ifmap ifru_map;
 		char	ifru_slave[IFNAMSIZ];	/* Just fits the size */
 		char	ifru_newname[IFNAMSIZ];
@@ -158,6 +159,7 @@
 #define	ifr_flags	ifr_ifru.ifru_flags	/* flags		*/
 #define	ifr_metric	ifr_ifru.ifru_ivalue	/* metric		*/
 #define	ifr_mtu		ifr_ifru.ifru_mtu	/* mtu			*/
+#define	ifr_group	ifr_ifru.ifru_group	/* device group		*/
 #define ifr_map		ifr_ifru.ifru_map	/* device map		*/
 #define ifr_slave	ifr_ifru.ifru_slave	/* slave device		*/
 #define	ifr_data	ifr_ifru.ifru_data	/* for use by interface	*/
diff -Nur linux-2.6.0-test11/include/linux/ip.h linux-2.6.0-test11-ifgrp/include/linux/ip.h
--- linux-2.6.0-test11/include/linux/ip.h	Wed Nov 26 21:43:28 2003
+++ linux-2.6.0-test11-ifgrp/include/linux/ip.h	Tue Dec  2 20:17:23 2003
@@ -144,6 +144,7 @@
 		u32			addr;
 		struct flowi		fl;
 	} cork;
+	__u32			if_group;	/* Bound network interface group mask */
 };
 
 #define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
diff -Nur linux-2.6.0-test11/include/linux/netdevice.h linux-2.6.0-test11-ifgrp/include/linux/netdevice.h
--- linux-2.6.0-test11/include/linux/netdevice.h	Wed Nov 26 21:45:38 2003
+++ linux-2.6.0-test11-ifgrp/include/linux/netdevice.h	Tue Dec  2 19:59:42 2003
@@ -295,6 +295,10 @@
 	int			ifindex;
 	int			iflink;
 
+	/* The 'ifgroup' field adds support for binding services to a group
+	 * of interfaces.
+	 */
+	unsigned int            ifgroup;
 
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
 	struct iw_statistics*	(*get_wireless_stats)(struct net_device *dev);
diff -Nur linux-2.6.0-test11/include/linux/sockios.h linux-2.6.0-test11-ifgrp/include/linux/sockios.h
--- linux-2.6.0-test11/include/linux/sockios.h	Wed Nov 26 21:42:50 2003
+++ linux-2.6.0-test11-ifgrp/include/linux/sockios.h	Tue Dec  2 20:07:01 2003
@@ -116,6 +116,12 @@
 #define SIOCBONDINFOQUERY      0x8994	/* rtn info about bond state    */
 #define SIOCBONDCHANGEACTIVE   0x8995   /* update to a new active slave */
 			
+/* Interface group configuration calls */
+
+#define	SIOCGIFGROUP	0x89A0		/* Get device group numbers	*/
+#define	SIOCAIFGROUP	0x89A1		/* Add device group number	*/
+#define	SIOCRIFGROUP	0x89A2		/* Remove device group number	*/
+
 /* Device private ioctl calls */
 
 /*
diff -Nur linux-2.6.0-test11/include/net/raw.h linux-2.6.0-test11-ifgrp/include/net/raw.h
--- linux-2.6.0-test11/include/net/raw.h	Wed Nov 26 21:45:37 2003
+++ linux-2.6.0-test11-ifgrp/include/net/raw.h	Tue Dec  2 20:08:34 2003
@@ -35,7 +35,7 @@
 
 extern struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
 				    unsigned long raddr, unsigned long laddr,
-				    int dif);
+				    int dif, u32 grp);
 
 extern void raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash);
 
diff -Nur linux-2.6.0-test11/include/net/tcp.h linux-2.6.0-test11-ifgrp/include/net/tcp.h
--- linux-2.6.0-test11/include/net/tcp.h	Wed Nov 26 21:43:05 2003
+++ linux-2.6.0-test11-ifgrp/include/net/tcp.h	Tue Dec  2 20:18:06 2003
@@ -161,7 +161,7 @@
 extern void tcp_bucket_destroy(struct tcp_bind_bucket *tb);
 extern void tcp_bucket_unlock(struct sock *sk);
 extern int tcp_port_rover;
-extern struct sock *tcp_v4_lookup_listener(u32 addr, unsigned short hnum, int dif);
+extern struct sock *tcp_v4_lookup_listener(u32 addr, unsigned short hnum, int dif, u32 grp);
 
 /* These are AF independent. */
 static __inline__ int tcp_bhashfn(__u16 lport)
diff -Nur linux-2.6.0-test11/net/core/dev.c linux-2.6.0-test11-ifgrp/net/core/dev.c
--- linux-2.6.0-test11/net/core/dev.c	Wed Nov 26 21:44:11 2003
+++ linux-2.6.0-test11-ifgrp/net/core/dev.c	Tue Dec  2 20:32:10 2003
@@ -2340,6 +2340,22 @@
 			dev->tx_queue_len = ifr->ifr_qlen;
 			return 0;
 
+		case SIOCGIFGROUP:
+			ifr->ifr_group = dev->ifgroup;
+			return 0;
+
+		case SIOCAIFGROUP:
+			if (ifr->ifr_group > 31)
+				return -EINVAL;
+			dev->ifgroup |= (1 << ifr->ifr_group);
+			return 0;
+
+		case SIOCRIFGROUP:
+			if (ifr->ifr_group > 31)
+				return -EINVAL;
+			dev->ifgroup &= ~(1 << ifr->ifr_group);
+			return 0;
+
 		case SIOCSIFNAME:
 			if (dev->flags & IFF_UP)
 				return -EBUSY;
@@ -2452,6 +2468,7 @@
 		case SIOCGIFMAP:
 		case SIOCGIFINDEX:
 		case SIOCGIFTXQLEN:
+		case SIOCGIFGROUP:
 			dev_load(ifr.ifr_name);
 			read_lock(&dev_base_lock);
 			ret = dev_ifsioc(&ifr, cmd);
@@ -2518,6 +2535,8 @@
 		case SIOCDELMULTI:
 		case SIOCSIFHWBROADCAST:
 		case SIOCSIFTXQLEN:
+		case SIOCAIFGROUP:
+		case SIOCRIFGROUP:
 		case SIOCSIFNAME:
 		case SIOCSMIIREG:
 		case SIOCBONDENSLAVE:
@@ -2658,6 +2677,7 @@
 		goto out;
 
 	dev->iflink = -1;
+	dev->ifgroup = 1;
 
 	/* Init, if this function is available */
 	if (dev->init) {
diff -Nur linux-2.6.0-test11/net/ipv4/af_inet.c linux-2.6.0-test11-ifgrp/net/ipv4/af_inet.c
--- linux-2.6.0-test11/net/ipv4/af_inet.c	Wed Nov 26 21:43:06 2003
+++ linux-2.6.0-test11-ifgrp/net/ipv4/af_inet.c	Tue Dec  2 20:47:02 2003
@@ -403,6 +403,7 @@
 	inet->mc_ttl	= 1;
 	inet->mc_index	= 0;
 	inet->mc_list	= NULL;
+	inet->if_group	= 1;
 
 #ifdef INET_REFCNT_DEBUG
 	atomic_inc(&inet_sock_nr);
@@ -476,6 +477,7 @@
 	unsigned short snum;
 	int chk_addr_ret;
 	int err;
+	__u32 grp;
 
 	/* If the socket has its own bind function then use it. (RAW) */
 	if (sk->sk_prot->bind) {
@@ -527,12 +529,17 @@
 	if (chk_addr_ret == RTN_MULTICAST || chk_addr_ret == RTN_BROADCAST)
 		inet->saddr = 0;  /* Use device */
 
+	inet->if_group = 1;
 	/* Make sure we are allowed to bind here. */
 	if (sk->sk_prot->get_port(sk, snum)) {
 		inet->saddr = inet->rcv_saddr = 0;
 		err = -EADDRINUSE;
 		goto out_release_sock;
 	}
+
+	grp = ntohl(inet->rcv_saddr);
+	if (grp < 32)
+		inet->if_group = 1 << grp;
 
 	if (inet->rcv_saddr)
 		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
diff -Nur linux-2.6.0-test11/net/ipv4/icmp.c linux-2.6.0-test11-ifgrp/net/ipv4/icmp.c
--- linux-2.6.0-test11/net/ipv4/icmp.c	Wed Nov 26 21:45:38 2003
+++ linux-2.6.0-test11-ifgrp/net/ipv4/icmp.c	Tue Dec  2 20:49:24 2003
@@ -696,7 +696,7 @@
 	if ((raw_sk = sk_head(&raw_v4_htable[hash])) != NULL) {
 		while ((raw_sk = __raw_v4_lookup(raw_sk, protocol, iph->daddr,
 						 iph->saddr,
-						 skb->dev->ifindex)) != NULL) {
+						 skb->dev->ifindex, skb->dev->ifgroup)) != NULL) {
 			raw_err(raw_sk, skb, info);
 			raw_sk = sk_next(raw_sk);
 			iph = (struct iphdr *)skb->data;
diff -Nur linux-2.6.0-test11/net/ipv4/raw.c linux-2.6.0-test11-ifgrp/net/ipv4/raw.c
--- linux-2.6.0-test11/net/ipv4/raw.c	Wed Nov 26 21:44:20 2003
+++ linux-2.6.0-test11-ifgrp/net/ipv4/raw.c	Tue Dec  2 20:55:16 2003
@@ -104,7 +104,7 @@
 
 struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
 			     unsigned long raddr, unsigned long laddr,
-			     int dif)
+			     int dif, u32 grp)
 {
 	struct hlist_node *node;
 
@@ -113,7 +113,7 @@
 
 		if (inet->num == num 					&&
 		    !(inet->daddr && inet->daddr != raddr) 		&&
-		    !(inet->rcv_saddr && inet->rcv_saddr != laddr)	&&
+		    !(!(inet->if_group & grp) && inet->rcv_saddr != laddr)	&&
 		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
 			goto found; /* gotcha */
 	}
@@ -158,7 +158,7 @@
 		goto out;
 	sk = __raw_v4_lookup(__sk_head(head), iph->protocol,
 			     iph->saddr, iph->daddr,
-			     skb->dev->ifindex);
+			     skb->dev->ifindex, skb->dev->ifgroup);
 
 	while (sk) {
 		if (iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) {
@@ -170,7 +170,7 @@
 		}
 		sk = __raw_v4_lookup(sk_next(sk), iph->protocol,
 				     iph->saddr, iph->daddr,
-				     skb->dev->ifindex);
+				     skb->dev->ifindex, skb->dev->ifgroup);
 	}
 out:
 	read_unlock(&raw_v4_lock);
diff -Nur linux-2.6.0-test11/net/ipv4/tcp_diag.c linux-2.6.0-test11-ifgrp/net/ipv4/tcp_diag.c
--- linux-2.6.0-test11/net/ipv4/tcp_diag.c	Wed Nov 26 21:42:49 2003
+++ linux-2.6.0-test11-ifgrp/net/ipv4/tcp_diag.c	Tue Dec  2 20:57:22 2003
@@ -206,7 +206,7 @@
 	return -1;
 }
 
-extern struct sock *tcp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif);
+extern struct sock *tcp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif, u32 grp);
 #ifdef CONFIG_IPV6
 extern struct sock *tcp_v6_lookup(struct in6_addr *saddr, u16 sport,
 				  struct in6_addr *daddr, u16 dport,
@@ -223,7 +223,7 @@
 	if (req->tcpdiag_family == AF_INET) {
 		sk = tcp_v4_lookup(req->id.tcpdiag_dst[0], req->id.tcpdiag_dport,
 				   req->id.tcpdiag_src[0], req->id.tcpdiag_sport,
-				   req->id.tcpdiag_if);
+				   req->id.tcpdiag_if, 1);
 	}
 #ifdef CONFIG_IPV6
 	else if (req->tcpdiag_family == AF_INET6) {
diff -Nur linux-2.6.0-test11/net/ipv4/tcp_ipv4.c linux-2.6.0-test11-ifgrp/net/ipv4/tcp_ipv4.c
--- linux-2.6.0-test11/net/ipv4/tcp_ipv4.c	Wed Nov 26 21:43:32 2003
+++ linux-2.6.0-test11-ifgrp/net/ipv4/tcp_ipv4.c	Tue Dec  2 21:10:39 2003
@@ -412,7 +412,7 @@
  * during the search since they can never be otherwise.
  */
 static struct sock *__tcp_v4_lookup_listener(struct hlist_head *head, u32 daddr,
-					     unsigned short hnum, int dif)
+					     unsigned short hnum, int dif, u32 grp)
 {
 	struct sock *result = NULL, *sk;
 	struct hlist_node *node;
@@ -424,9 +424,10 @@
 
 		if (inet->num == hnum && !ipv6_only_sock(sk)) {
 			__u32 rcv_saddr = inet->rcv_saddr;
+			__u32 if_group = inet->if_group;
 
 			score = (sk->sk_family == PF_INET ? 1 : 0);
-			if (rcv_saddr) {
+			if (!(if_group & grp)) {
 				if (rcv_saddr != daddr)
 					continue;
 				score+=2;
@@ -449,7 +450,7 @@
 
 /* Optimize the common listener case. */
 inline struct sock *tcp_v4_lookup_listener(u32 daddr, unsigned short hnum,
-					   int dif)
+					   int dif, u32 grp)
 {
 	struct sock *sk = NULL;
 	struct hlist_head *head;
@@ -460,11 +461,11 @@
 		struct inet_opt *inet = inet_sk((sk = __sk_head(head)));
 
 		if (inet->num == hnum && !sk->sk_node.next &&
-		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
+		    ((inet->if_group & grp) || inet->rcv_saddr == daddr) &&
 		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
 		    !sk->sk_bound_dev_if)
 			goto sherry_cache;
-		sk = __tcp_v4_lookup_listener(head, daddr, hnum, dif);
+		sk = __tcp_v4_lookup_listener(head, daddr, hnum, dif, grp);
 	}
 	if (sk) {
 sherry_cache:
@@ -515,21 +516,21 @@
 }
 
 static inline struct sock *__tcp_v4_lookup(u32 saddr, u16 sport,
-					   u32 daddr, u16 hnum, int dif)
+					   u32 daddr, u16 hnum, int dif, u32 grp)
 {
 	struct sock *sk = __tcp_v4_lookup_established(saddr, sport,
 						      daddr, hnum, dif);
 
-	return sk ? : tcp_v4_lookup_listener(daddr, hnum, dif);
+	return sk ? : tcp_v4_lookup_listener(daddr, hnum, dif, grp);
 }
 
 inline struct sock *tcp_v4_lookup(u32 saddr, u16 sport, u32 daddr,
-				  u16 dport, int dif)
+				  u16 dport, int dif, u32 grp)
 {
 	struct sock *sk;
 
 	local_bh_disable();
-	sk = __tcp_v4_lookup(saddr, sport, daddr, ntohs(dport), dif);
+	sk = __tcp_v4_lookup(saddr, sport, daddr, ntohs(dport), dif, grp);
 	local_bh_enable();
 
 	return sk;
@@ -1003,7 +1004,7 @@
 	}
 
 	sk = tcp_v4_lookup(iph->daddr, th->dest, iph->saddr,
-			   th->source, tcp_v4_iif(skb));
+			   th->source, tcp_v4_iif(skb), skb->dev->ifgroup);
 	if (!sk) {
 		ICMP_INC_STATS_BH(IcmpInErrors);
 		return;
@@ -1774,7 +1775,7 @@
 
 	sk = __tcp_v4_lookup(skb->nh.iph->saddr, th->source,
 			     skb->nh.iph->daddr, ntohs(th->dest),
-			     tcp_v4_iif(skb));
+			     tcp_v4_iif(skb), skb->dev->ifgroup);
 
 	if (!sk)
 		goto no_tcp_socket;
@@ -1837,7 +1838,8 @@
 	case TCP_TW_SYN: {
 		struct sock *sk2 = tcp_v4_lookup_listener(skb->nh.iph->daddr,
 							  ntohs(th->dest),
-							  tcp_v4_iif(skb));
+							  tcp_v4_iif(skb),
+							  skb->dev->ifgroup);
 		if (sk2) {
 			tcp_tw_deschedule((struct tcp_tw_bucket *)sk);
 			tcp_tw_put((struct tcp_tw_bucket *)sk);
diff -Nur linux-2.6.0-test11/net/ipv4/udp.c linux-2.6.0-test11-ifgrp/net/ipv4/udp.c
--- linux-2.6.0-test11/net/ipv4/udp.c	Wed Nov 26 21:43:09 2003
+++ linux-2.6.0-test11-ifgrp/net/ipv4/udp.c	Tue Dec  2 21:17:05 2003
@@ -219,7 +219,7 @@
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-struct sock *udp_v4_lookup_longway(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif)
+struct sock *udp_v4_lookup_longway(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif, u32 grp)
 {
 	struct sock *sk, *result = NULL;
 	struct hlist_node *node;
@@ -231,7 +231,7 @@
 
 		if (inet->num == hnum && !ipv6_only_sock(sk)) {
 			int score = (sk->sk_family == PF_INET ? 1 : 0);
-			if (inet->rcv_saddr) {
+			if (!(inet->if_group & grp)) {
 				if (inet->rcv_saddr != daddr)
 					continue;
 				score+=2;
@@ -263,12 +263,12 @@
 	return result;
 }
 
-__inline__ struct sock *udp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif)
+__inline__ struct sock *udp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif, u32 grp)
 {
 	struct sock *sk;
 
 	read_lock(&udp_hash_lock);
-	sk = udp_v4_lookup_longway(saddr, sport, daddr, dport, dif);
+	sk = udp_v4_lookup_longway(saddr, sport, daddr, dport, dif, grp);
 	if (sk)
 		sock_hold(sk);
 	read_unlock(&udp_hash_lock);
@@ -325,7 +325,7 @@
 	int harderr;
 	int err;
 
-	sk = udp_v4_lookup(iph->daddr, uh->dest, iph->saddr, uh->source, skb->dev->ifindex);
+	sk = udp_v4_lookup(iph->daddr, uh->dest, iph->saddr, uh->source, skb->dev->ifindex, skb->dev->ifgroup);
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(IcmpInErrors);
     	  	return;	/* No socket for error */
@@ -1187,7 +1187,7 @@
 	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return udp_v4_mcast_deliver(skb, uh, saddr, daddr);
 
-	sk = udp_v4_lookup(saddr, uh->source, daddr, uh->dest, skb->dev->ifindex);
+	sk = udp_v4_lookup(saddr, uh->source, daddr, uh->dest, skb->dev->ifindex, skb->dev->ifgroup);
 
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);
