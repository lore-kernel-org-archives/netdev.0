From: "James R. Leu" <jleu@mindspring.com>
Subject: [RFC] Virtual Routing and Forwarding
Date: Mon, 21 Oct 2002 22:38:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021021223810.A23086@nero.doit.wisc.edu>
Reply-To: jleu@mindspring.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I have given my first shot at implementing virtual routing and forwarding
in the 2.4 IPv4 stack.  I'm looking for feedback to see if there is a
better way to go about this and to see if there is any interest from others.

This patch associates a VRF index to netdevices and sockets.  Packets
arriving on an interface or being sent via the socket are marked with
the VRF index. This VRF index is used to choose which rule list will be
used for route lookups (in fib_lookup).  This index is also used when
handling TCP, UDP and raw sockets.

The result is that each VRF has a complete rule list and associated tables.
In addition the TCP and UDP ports are unique to each VRF (ie port numbers
can be re-used and concurrently used in each VRF).

I'm including only the kernel patch, but there are associated patches
for ip (iproute2) and ping (iputils).  There is also a userland utility for
creating VRFs.  Anyone who would like the full package (with some simple
documentation) can get the package at http://sf.net/projects/linux-vrf/
in the file section.

Humbly submitted.
-- 
James R. Leu


diff -uNr linux-kernel/include/asm-i386/socket.h vrf-kernel/include/asm-i386/socket.h
--- linux-kernel/include/asm-i386/socket.h	Sat Aug 24 00:21:07 2002
+++ vrf-kernel/include/asm-i386/socket.h	Sat Aug 24 00:14:05 2002
@@ -44,6 +44,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_ACCEPTCONN		30
+#define SO_VRF			31
 
 /* Nasty libc5 fixup - bletch */
 #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
diff -uNr linux-kernel/include/linux/inetdevice.h vrf-kernel/include/linux/inetdevice.h
--- linux-kernel/include/linux/inetdevice.h	Sat Aug 24 00:21:55 2002
+++ vrf-kernel/include/linux/inetdevice.h	Sat Aug 24 00:14:19 2002
@@ -77,7 +77,7 @@
 extern int register_inetaddr_notifier(struct notifier_block *nb);
 extern int unregister_inetaddr_notifier(struct notifier_block *nb);
 
-extern struct net_device 	*ip_dev_find(u32 addr);
+extern struct net_device 	*ip_dev_find(unsigned char vrf, u32 addr);
 extern int		inet_addr_onlink(struct in_device *in_dev, u32 a, u32 b);
 extern int		devinet_ioctl(unsigned int cmd, void *);
 extern void		devinet_init(void);
diff -uNr linux-kernel/include/linux/netdevice.h vrf-kernel/include/linux/netdevice.h
--- linux-kernel/include/linux/netdevice.h	Sat Aug 24 00:21:57 2002
+++ vrf-kernel/include/linux/netdevice.h	Sun Sep 15 12:16:58 2002
@@ -431,6 +431,7 @@
 	/* this will get initialized at each interface type init routine */
 	struct divert_blk	*divert;
 #endif /* CONFIG_NET_DIVERT */
+	unsigned char vrf;
 };
 
 
diff -uNr linux-kernel/include/linux/rtnetlink.h vrf-kernel/include/linux/rtnetlink.h
--- linux-kernel/include/linux/rtnetlink.h	Sat Aug 24 00:22:03 2002
+++ vrf-kernel/include/linux/rtnetlink.h	Sat Aug 24 00:14:20 2002
@@ -88,6 +88,7 @@
 	unsigned char		rtm_tos;
 
 	unsigned char		rtm_table;	/* Routing table id */
+	unsigned char		rtm_vrf;	/* VRF id */
 	unsigned char		rtm_protocol;	/* Routing protocol; see below	*/
 	unsigned char		rtm_scope;	/* See below */	
 	unsigned char		rtm_type;	/* See below	*/
@@ -179,6 +180,7 @@
 	RT_TABLE_LOCAL=255
 };
 #define RT_TABLE_MAX RT_TABLE_LOCAL
+#define VRF_MAX 8
 
 
 
@@ -440,12 +442,13 @@
 #define IFLA_COST IFLA_COST
 	IFLA_PRIORITY,
 #define IFLA_PRIORITY IFLA_PRIORITY
-	IFLA_MASTER
+	IFLA_MASTER,
 #define IFLA_MASTER IFLA_MASTER
+	IFLA_VRF
 };
 
 
-#define IFLA_MAX IFLA_MASTER
+#define IFLA_MAX IFLA_VRF
 
 #define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
 #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
diff -uNr linux-kernel/include/linux/skbuff.h vrf-kernel/include/linux/skbuff.h
--- linux-kernel/include/linux/skbuff.h	Sat Aug 24 00:22:04 2002
+++ vrf-kernel/include/linux/skbuff.h	Sun Sep 15 12:16:58 2002
@@ -215,6 +215,7 @@
 #ifdef CONFIG_NET_SCHED
        __u32           tc_index;               /* traffic control index */
 #endif
+	unsigned char vrf;
 };
 
 #define SK_WMEM_MAX	65535
diff -uNr linux-kernel/include/linux/sockios.h vrf-kernel/include/linux/sockios.h
--- linux-kernel/include/linux/sockios.h	Sat Aug 24 00:22:04 2002
+++ vrf-kernel/include/linux/sockios.h	Sat Aug 24 00:14:21 2002
@@ -105,6 +105,12 @@
 #define SIOCGIFVLAN	0x8982		/* 802.1Q VLAN support		*/
 #define SIOCSIFVLAN	0x8983		/* Set 802.1Q VLAN options 	*/
 
+#define SIOCGIFVRF      0x8984		/* get VRF			*/
+#define SIOCSIFVRF      0x8985		/* set VRF 			*/
+
+#define SIOCADDVRF      0x8986		/* add VRF			*/
+#define SIOCDELVRF      0x8987		/* del VRF 			*/
+
 /* bonding calls */
 
 #define SIOCBONDENSLAVE	0x8990		/* enslave a device to the bond */
diff -uNr linux-kernel/include/net/ip_fib.h vrf-kernel/include/net/ip_fib.h
--- linux-kernel/include/net/ip_fib.h	Sat Aug 24 00:22:09 2002
+++ vrf-kernel/include/net/ip_fib.h	Mon Sep 16 19:48:57 2002
@@ -132,69 +132,33 @@
 	void		(*tb_select_default)(struct fib_table *table,
 					     const struct rt_key *key, struct fib_result *res);
 
+	unsigned char	tb_vrf;
 	unsigned char	tb_data[0];
 };
 
-#ifndef CONFIG_IP_MULTIPLE_TABLES
-
-extern struct fib_table *local_table;
-extern struct fib_table *main_table;
-
-static inline struct fib_table *fib_get_table(int id)
-{
-	if (id != RT_TABLE_LOCAL)
-		return main_table;
-	return local_table;
-}
-
-static inline struct fib_table *fib_new_table(int id)
-{
-	return fib_get_table(id);
-}
-
-static inline int fib_lookup(const struct rt_key *key, struct fib_result *res)
-{
-	if (local_table->tb_lookup(local_table, key, res) &&
-	    main_table->tb_lookup(main_table, key, res))
-		return -ENETUNREACH;
-	return 0;
-}
-
-static inline void fib_select_default(const struct rt_key *key, struct fib_result *res)
-{
-	if (FIB_RES_GW(*res) && FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
-		main_table->tb_select_default(main_table, key, res);
-}
-
-#else /* CONFIG_IP_MULTIPLE_TABLES */
-#define local_table (fib_tables[RT_TABLE_LOCAL])
-#define main_table (fib_tables[RT_TABLE_MAIN])
-
-extern struct fib_table * fib_tables[RT_TABLE_MAX+1];
+extern struct fib_table * fib_tables[VRF_MAX][RT_TABLE_MAX+1];
 extern int fib_lookup(const struct rt_key *key, struct fib_result *res);
-extern struct fib_table *__fib_new_table(int id);
+extern struct fib_table *__fib_new_table(unsigned char vrf, int id);
 extern void fib_rule_put(struct fib_rule *r);
 
-static inline struct fib_table *fib_get_table(int id)
+static inline struct fib_table *fib_get_table(unsigned char vrf, int id)
 {
 	if (id == 0)
 		id = RT_TABLE_MAIN;
 
-	return fib_tables[id];
+	return fib_tables[vrf][id];
 }
 
-static inline struct fib_table *fib_new_table(int id)
+static inline struct fib_table *fib_new_table(unsigned char vrf, int id)
 {
 	if (id == 0)
 		id = RT_TABLE_MAIN;
 
-	return fib_tables[id] ? : __fib_new_table(id);
+	return fib_tables[vrf][id] ? : __fib_new_table(vrf,id);
 }
 
 extern void fib_select_default(const struct rt_key *key, struct fib_result *res);
 
-#endif /* CONFIG_IP_MULTIPLE_TABLES */
-
 /* Exported by fib_frontend.c */
 extern void		ip_fib_init(void);
 extern void		fib_flush(void);
@@ -212,11 +176,11 @@
 extern int		fib_semantic_match(int type, struct fib_info *,
 					   const struct rt_key *, struct fib_result*);
 extern struct fib_info	*fib_create_info(const struct rtmsg *r, struct kern_rta *rta,
-					 const struct nlmsghdr *, int *err);
+					 const struct nlmsghdr *, unsigned char vrf, int *err);
 extern int fib_nh_match(struct rtmsg *r, struct nlmsghdr *, struct kern_rta *rta, struct fib_info *fi);
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 			 u8 tb_id, u8 type, u8 scope, void *dst, int dst_len, u8 tos,
-			 struct fib_info *fi);
+			 struct fib_info *fi, unsigned char vrf);
 extern int fib_sync_down(u32 local, struct net_device *dev, int force);
 extern int fib_sync_up(struct net_device *dev);
 extern int fib_convert_rtentry(int cmd, struct nlmsghdr *nl, struct rtmsg *rtm,
@@ -225,7 +189,7 @@
 extern u32  __fib_res_prefsrc(struct fib_result *res);
 
 /* Exported by fib_hash.c */
-extern struct fib_table *fib_hash_init(int id);
+extern struct fib_table *fib_hash_init(unsigned char vrf, int id);
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 /* Exported by fib_rules.c */
diff -uNr linux-kernel/include/net/raw.h vrf-kernel/include/net/raw.h
--- linux-kernel/include/net/raw.h	Sat Aug 24 00:22:12 2002
+++ vrf-kernel/include/net/raw.h	Sat Aug 24 00:14:24 2002
@@ -35,7 +35,7 @@
 
 extern struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
 				    unsigned long raddr, unsigned long laddr,
-				    int dif);
+				    int dif, unsigned char vrf);
 
 extern struct sock *raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash);
 
diff -uNr linux-kernel/include/net/route.h vrf-kernel/include/net/route.h
--- linux-kernel/include/net/route.h	Sat Aug 24 00:22:12 2002
+++ vrf-kernel/include/net/route.h	Sun Sep 15 12:17:16 2002
@@ -56,6 +56,7 @@
 #endif
 	__u8			tos;
 	__u8			scope;
+	__u8			vrf;
 };
 
 struct inet_peer;
@@ -126,11 +127,11 @@
 extern void		rt_cache_flush(int how);
 extern int		ip_route_output_key(struct rtable **, const struct rt_key *key);
 extern int		ip_route_input(struct sk_buff*, u32 dst, u32 src, u8 tos, struct net_device *devin);
-extern unsigned short	ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu);
+extern unsigned short	ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu, unsigned char vrf);
 extern void		ip_rt_update_pmtu(struct dst_entry *dst, unsigned mtu);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
 
-extern unsigned		inet_addr_type(u32 addr);
+extern unsigned		inet_addr_type(unsigned char vrf, u32 addr);
 extern void		ip_rt_multicast_event(struct in_device *);
 extern int		ip_rt_ioctl(unsigned int cmd, void *arg);
 extern void		ip_rt_get_source(u8 *src, struct rtable *rt);
@@ -161,17 +162,19 @@
 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
 }
 
-static inline int ip_route_connect(struct rtable **rp, u32 dst, u32 src, u32 tos, int oif)
+static inline int ip_route_connect(struct rtable **rp, u32 dst, u32 src, u32 tos, int oif, int vrf)
 {
 	int err;
-	err = ip_route_output(rp, dst, src, tos, oif);
+	struct rt_key key = { dst:dst, src:src, oif:oif, tos:tos, vrf:vrf };
+
+	err = ip_route_output_key(rp, &key);
 	if (err || (dst && src))
 		return err;
-	dst = (*rp)->rt_dst;
-	src = (*rp)->rt_src;
+	key.dst = (*rp)->rt_dst;
+	key.src = (*rp)->rt_src;
 	ip_rt_put(*rp);
 	*rp = NULL;
-	return ip_route_output(rp, dst, src, tos, oif);
+	return ip_route_output_key(rp, &key);
 }
 
 extern void rt_bind_peer(struct rtable *rt, int create);
diff -uNr linux-kernel/include/net/sock.h vrf-kernel/include/net/sock.h
--- linux-kernel/include/net/sock.h	Sat Aug 24 00:22:12 2002
+++ vrf-kernel/include/net/sock.h	Sun Sep 15 12:17:06 2002
@@ -493,6 +493,7 @@
 	__u16			dport;		/* Destination port			*/
 	unsigned short		num;		/* Local port				*/
 	int			bound_dev_if;	/* Bound device index if != 0		*/
+	unsigned char		vrf;		/* VRF != 0		*/
 
 	/* Main hash linkage for various protocol lookup tables. */
 	struct sock		*next;
diff -uNr linux-kernel/include/net/tcp.h vrf-kernel/include/net/tcp.h
--- linux-kernel/include/net/tcp.h	Sat Aug 24 00:22:13 2002
+++ vrf-kernel/include/net/tcp.h	Sat Aug 24 00:14:24 2002
@@ -79,6 +79,7 @@
 	struct tcp_bind_bucket	*next;
 	struct sock		*owners;
 	struct tcp_bind_bucket	**pprev;
+	unsigned char		vrf;
 };
 
 struct tcp_bind_hashbucket {
@@ -136,10 +137,10 @@
 
 extern kmem_cache_t *tcp_bucket_cachep;
 extern struct tcp_bind_bucket *tcp_bucket_create(struct tcp_bind_hashbucket *head,
-						 unsigned short snum);
+					 unsigned short snum,unsigned char vrf);
 extern void tcp_bucket_unlock(struct sock *sk);
 extern int tcp_port_rover;
-extern struct sock *tcp_v4_lookup_listener(u32 addr, unsigned short hnum, int dif);
+extern struct sock *tcp_v4_lookup_listener(u32 addr, unsigned short hnum, int dif, unsigned char vrf);
 
 /* These are AF independent. */
 static __inline__ int tcp_bhashfn(__u16 lport)
@@ -161,6 +162,7 @@
 	__u16			dport;
 	unsigned short		num;
 	int			bound_dev_if;
+        unsigned char           vrf;
 	struct sock		*next;
 	struct sock		**pprev;
 	struct sock		*bind_next;
@@ -229,17 +231,19 @@
 #define TCP_V4_ADDR_COOKIE(__name, __saddr, __daddr) \
 	__u64 __name = (((__u64)(__daddr))<<32)|((__u64)(__saddr));
 #endif /* __BIG_ENDIAN */
-#define TCP_IPV4_MATCH(__sk, __cookie, __saddr, __daddr, __ports, __dif)\
+#define TCP_IPV4_MATCH(__sk, __cookie, __saddr, __daddr, __ports, __dif, __vrf)\
 	(((*((__u64 *)&((__sk)->daddr)))== (__cookie))	&&		\
 	 ((*((__u32 *)&((__sk)->dport)))== (__ports))   &&		\
-	 (!((__sk)->bound_dev_if) || ((__sk)->bound_dev_if == (__dif))))
+	 (!((__sk)->bound_dev_if) || ((__sk)->bound_dev_if == (__dif))) && \
+	 ((__sk)->vrf == (__vrf)))
 #else /* 32-bit arch */
 #define TCP_V4_ADDR_COOKIE(__name, __saddr, __daddr)
-#define TCP_IPV4_MATCH(__sk, __cookie, __saddr, __daddr, __ports, __dif)\
+#define TCP_IPV4_MATCH(__sk, __cookie, __saddr, __daddr, __ports, __dif, __vrf)\
 	(((__sk)->daddr			== (__saddr))	&&		\
 	 ((__sk)->rcv_saddr		== (__daddr))	&&		\
 	 ((*((__u32 *)&((__sk)->dport)))== (__ports))   &&		\
-	 (!((__sk)->bound_dev_if) || ((__sk)->bound_dev_if == (__dif))))
+	 (!((__sk)->bound_dev_if) || ((__sk)->bound_dev_if == (__dif))) && \
+	 ((__sk)->vrf == (__vrf)))
 #endif /* 64-bit arch */
 
 #define TCP_IPV6_MATCH(__sk, __saddr, __daddr, __ports, __dif)			   \
diff -uNr linux-kernel/net/core/dev.c vrf-kernel/net/core/dev.c
--- linux-kernel/net/core/dev.c	Sat Aug 24 00:22:26 2002
+++ vrf-kernel/net/core/dev.c	Sat Aug 24 00:14:27 2002
@@ -2011,6 +2011,14 @@
 				notifier_call_chain(&netdev_chain, NETDEV_CHANGEMTU, dev);
 			return err;
 
+		case SIOCGIFVRF:	/* Get the VRF for a device */
+			ifr->ifr_flags = dev->vrf;
+			return 0;
+	
+		case SIOCSIFVRF:	/* Set the VRF for a device */
+			dev->vrf = ifr->ifr_flags;
+			return 0;
+
 		case SIOCGIFHWADDR:
 			memcpy(ifr->ifr_hwaddr.sa_data,dev->dev_addr, MAX_ADDR_LEN);
 			ifr->ifr_hwaddr.sa_family=dev->type;
@@ -2185,6 +2193,7 @@
 		case SIOCGIFFLAGS:
 		case SIOCGIFMETRIC:
 		case SIOCGIFMTU:
+		case SIOCGIFVRF:
 		case SIOCGIFHWADDR:
 		case SIOCGIFSLAVE:
 		case SIOCGIFMAP:
@@ -2238,6 +2247,7 @@
 		case SIOCSIFFLAGS:
 		case SIOCSIFMETRIC:
 		case SIOCSIFMTU:
+		case SIOCSIFVRF:
 		case SIOCSIFMAP:
 		case SIOCSIFHWADDR:
 		case SIOCSIFSLAVE:
diff -uNr linux-kernel/net/core/rtnetlink.c vrf-kernel/net/core/rtnetlink.c
--- linux-kernel/net/core/rtnetlink.c	Sat Aug 24 00:22:26 2002
+++ vrf-kernel/net/core/rtnetlink.c	Sat Aug 24 00:14:27 2002
@@ -155,6 +155,7 @@
 	struct ifinfomsg *r;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
+	int vrf;
 
 	nlh = NLMSG_PUT(skb, pid, seq, type, sizeof(*r));
 	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
@@ -171,6 +172,8 @@
 		r->ifi_flags |= IFF_RUNNING;
 
 	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
+	vrf = dev->vrf;
+	RTA_PUT(skb, IFLA_VRF, sizeof(vrf), &vrf);
 	if (dev->addr_len) {
 		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
 		RTA_PUT(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast);
@@ -187,6 +190,9 @@
 			dev->qdisc_sleeping->ops->id);
 	if (dev->master)
 		RTA_PUT(skb, IFLA_MASTER, sizeof(int), &dev->master->ifindex);
+
+	RTA_PUT(skb, IFLA_VRF, sizeof(int), &dev->vrf);
+
 	if (dev->get_stats) {
 		struct net_device_stats *stats = dev->get_stats(dev);
 		if (stats)
diff -uNr linux-kernel/net/core/skbuff.c vrf-kernel/net/core/skbuff.c
--- linux-kernel/net/core/skbuff.c	Sat Aug 24 00:22:26 2002
+++ vrf-kernel/net/core/skbuff.c	Sat Aug 24 00:14:27 2002
@@ -249,6 +249,7 @@
 #ifdef CONFIG_NET_SCHED
 	skb->tc_index = 0;
 #endif
+	skb->vrf = 0;
 }
 
 static void skb_drop_fraglist(struct sk_buff *skb)
@@ -398,6 +399,7 @@
 #ifdef CONFIG_NET_SCHED
 	C(tc_index);
 #endif
+	C(vrf);
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));
 	skb->cloned = 1;
@@ -441,6 +443,7 @@
 #ifdef CONFIG_NET_SCHED
 	new->tc_index = old->tc_index;
 #endif
+	new->vrf = old->vrf;
 }
 
 /**
diff -uNr linux-kernel/net/core/sock.c vrf-kernel/net/core/sock.c
--- linux-kernel/net/core/sock.c	Sat Aug 24 00:22:26 2002
+++ vrf-kernel/net/core/sock.c	Sun Sep 15 16:05:54 2002
@@ -281,6 +281,13 @@
 				ret = -EPERM;
 			break;
 
+                case SO_VRF:
+			if((val >= 0 && val <= 8) || capable(CAP_NET_ADMIN))
+				sk->vrf = val;
+			else
+				ret = -EPERM;
+                        break;
+
 		case SO_LINGER:
 			if(optlen<sizeof(ling)) {
 				ret = -EINVAL;	/* 1003.1g */
@@ -532,6 +539,10 @@
 		case SO_PASSCRED:
 			v.val = sock->passcred;
 			break;
+
+                case SO_VRF:
+                        v.val = sk->vrf;
+                        break;
 
 		case SO_PEERCRED:
 			if (len > sizeof(sk->peercred))
diff -uNr linux-kernel/net/ipv4/af_inet.c vrf-kernel/net/ipv4/af_inet.c
--- linux-kernel/net/ipv4/af_inet.c	Sat Aug 24 00:22:27 2002
+++ vrf-kernel/net/ipv4/af_inet.c	Sat Aug 24 00:14:27 2002
@@ -130,6 +130,8 @@
 extern int tcp_get_info(char *, char **, off_t, int);
 extern int udp_get_info(char *, char **, off_t, int);
 extern void ip_mc_drop_socket(struct sock *sk);
+extern int fib_add_vrf(unsigned char vrf);
+extern int fib_del_vrf(unsigned char vrf);
 
 #ifdef CONFIG_DLCI
 extern int dlci_ioctl(unsigned int, void*);
@@ -485,7 +487,7 @@
 	if (addr_len < sizeof(struct sockaddr_in))
 		return -EINVAL;
 
-	chk_addr_ret = inet_addr_type(addr->sin_addr.s_addr);
+	chk_addr_ret = inet_addr_type(sk->vrf, addr->sin_addr.s_addr);
 
 	/* Not specified by any standard per-se, however it breaks too
 	 * many applications when removed.  It is unfortunate since
@@ -923,6 +925,18 @@
 			}
 #endif
 			return -ENOPKG;
+
+		case SIOCADDVRF:
+			lock_kernel();
+			err = fib_add_vrf((unsigned char)arg);
+			unlock_kernel();
+			return err;
+
+		case SIOCDELVRF:
+			lock_kernel();
+			err = fib_del_vrf((unsigned char)arg);
+			unlock_kernel();
+			return err;
 
 		default:
 			if ((cmd >= SIOCDEVPRIVATE) &&
diff -uNr linux-kernel/net/ipv4/arp.c vrf-kernel/net/ipv4/arp.c
--- linux-kernel/net/ipv4/arp.c	Sat Aug 24 00:22:27 2002
+++ vrf-kernel/net/ipv4/arp.c	Sat Aug 24 00:14:27 2002
@@ -233,7 +233,7 @@
 	if (in_dev == NULL)
 		return -EINVAL;
 
-	neigh->type = inet_addr_type(addr);
+	neigh->type = inet_addr_type(dev->vrf, addr);
 	if (in_dev->arp_parms)
 		neigh->parms = in_dev->arp_parms;
 
@@ -322,7 +322,7 @@
 	u32 target = *(u32*)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 
-	if (skb && inet_addr_type(skb->nh.iph->saddr) == RTN_LOCAL)
+	if (skb && inet_addr_type(dev->vrf, skb->nh.iph->saddr) == RTN_LOCAL)
 		saddr = skb->nh.iph->saddr;
 	else
 		saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
@@ -347,11 +347,18 @@
 
 static int arp_filter(__u32 sip, __u32 tip, struct net_device *dev)
 {
+	struct rt_key key;
 	struct rtable *rt;
 	int flag = 0; 
 	/*unsigned long now; */
 
-	if (ip_route_output(&rt, sip, tip, 0, 0) < 0) 
+	memset(&key,0,sizeof(key));
+	key.dst = sip;
+	key.src = tip;
+	key.tos = 0;
+	key.oif = 0;
+	key.vrf = dev->vrf;
+	if (ip_route_output_key(&rt, &key) < 0) 
 		return 1;
 	if (rt->u.dst.dev != dev) { 
 		NET_INC_STATS_BH(ArpFilter);
@@ -404,7 +411,7 @@
 
 	paddr = ((struct rtable*)skb->dst)->rt_gateway;
 
-	if (arp_set_predefined(inet_addr_type(paddr), haddr, paddr, dev))
+	if (arp_set_predefined(inet_addr_type(dev->vrf, paddr), haddr, paddr, dev))
 		return 0;
 
 	n = __neigh_lookup(&arp_tbl, &paddr, dev, 1);
@@ -627,6 +634,8 @@
 	arp = skb->nh.arph;
 	arp_ptr= (unsigned char *)(arp+1);
 
+	skb->vrf = dev->vrf;
+
 	switch (dev_type) {
 	default:	
 		if (arp->ar_pro != __constant_htons(ETH_P_IP))
@@ -755,7 +764,7 @@
 	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
 	if (sip == 0) {
 		if (arp->ar_op == __constant_htons(ARPOP_REQUEST) &&
-		    inet_addr_type(tip) == RTN_LOCAL)
+		    inet_addr_type(dev->vrf, tip) == RTN_LOCAL)
 			arp_send(ARPOP_REPLY,ETH_P_ARP,tip,dev,tip,sha,dev->dev_addr,dev->dev_addr);
 		goto out;
 	}
@@ -811,7 +820,7 @@
 	 */
 	if (n == NULL &&
 	    arp->ar_op == __constant_htons(ARPOP_REPLY) &&
-	    inet_addr_type(sip) == RTN_UNICAST)
+	    inet_addr_type(dev->vrf, sip) == RTN_UNICAST)
 		n = __neigh_lookup(&arp_tbl, &sip, dev, -1);
 #endif
 
@@ -918,8 +927,16 @@
 	if (r->arp_flags & ATF_PERM)
 		r->arp_flags |= ATF_COM;
 	if (dev == NULL) {
+		struct rt_key key;
 		struct rtable * rt;
-		if ((err = ip_route_output(&rt, ip, 0, RTO_ONLINK, 0)) != 0)
+
+		memset(&key,0,sizeof(key));
+		key.dst = ip;
+		key.src = 0;
+		key.tos = RTO_ONLINK;
+		key.oif = 0;
+		key.vrf = 0;
+		if ((err = ip_route_output_key(&rt, &key)) != 0)
 			return err;
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
@@ -1001,8 +1018,16 @@
 	}
 
 	if (dev == NULL) {
+		struct rt_key key;
 		struct rtable * rt;
-		if ((err = ip_route_output(&rt, ip, 0, RTO_ONLINK, 0)) != 0)
+
+		memset(&key,0,sizeof(key));
+		key.dst = ip;
+		key.src = 0;
+		key.tos = RTO_ONLINK;
+		key.oif = 0;
+		key.vrf = 0;
+		if ((err = ip_route_output_key(&rt, &key)) != 0)
 			return err;
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
diff -uNr linux-kernel/net/ipv4/fib_frontend.c vrf-kernel/net/ipv4/fib_frontend.c
--- linux-kernel/net/ipv4/fib_frontend.c	Sat Aug 24 00:22:27 2002
+++ vrf-kernel/net/ipv4/fib_frontend.c	Mon Sep 16 20:12:42 2002
@@ -51,23 +51,20 @@
 
 #define RT_TABLE_MIN RT_TABLE_MAIN
 
-struct fib_table *local_table;
-struct fib_table *main_table;
-
 #else
 
 #define RT_TABLE_MIN 1
 
-struct fib_table *fib_tables[RT_TABLE_MAX+1];
+struct fib_table *fib_tables[VRF_MAX][RT_TABLE_MAX+1];
 
-struct fib_table *__fib_new_table(int id)
+struct fib_table *__fib_new_table(unsigned char vrf, int id)
 {
 	struct fib_table *tb;
 
-	tb = fib_hash_init(id);
+	tb = fib_hash_init(vrf,id);
 	if (!tb)
 		return NULL;
-	fib_tables[id] = tb;
+	fib_tables[vrf][id] = tb;
 	return tb;
 }
 
@@ -78,20 +75,17 @@
 void fib_flush(void)
 {
 	int flushed = 0;
-#ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_table *tb;
+	int vrf;
 	int id;
 
-	for (id = RT_TABLE_MAX; id>0; id--) {
-		if ((tb = fib_get_table(id))==NULL)
-			continue;
-		flushed += tb->tb_flush(tb);
-	}
-#else /* CONFIG_IP_MULTIPLE_TABLES */
-	flushed += main_table->tb_flush(main_table);
-	flushed += local_table->tb_flush(local_table);
-#endif /* CONFIG_IP_MULTIPLE_TABLES */
-
+	for (vrf = 0 ; vrf < VRF_MAX ; vrf++) {
+		for (id = RT_TABLE_MAX; id>0; id--) {
+			if ((tb = fib_get_table(vrf,id))==NULL)
+				continue;
+			flushed += tb->tb_flush(tb);
+		}
+	}
 	if (flushed)
 		rt_cache_flush(-1);
 }
@@ -112,6 +106,7 @@
 	int first = offset/128;
 	char *ptr = buffer;
 	int count = (length+127)/128;
+	struct fib_table *table;
 	int len;
 
 	*start = buffer + offset%128;
@@ -123,8 +118,8 @@
 		first = 0;
   	}
 
-	if (main_table && count > 0) {
-		int n = main_table->tb_get_info(main_table, ptr, first, count);
+	if ((table = fib_get_table(0,RT_TABLE_MAIN)) && count > 0) {
+		int n = table->tb_get_info(table, ptr, first, count);
 		count -= n;
 		ptr += n*128;
 	}
@@ -142,19 +137,21 @@
  *	Find the first device with a given source address.
  */
 
-struct net_device * ip_dev_find(u32 addr)
+struct net_device * ip_dev_find(unsigned char vrf, u32 addr)
 {
 	struct rt_key key;
 	struct fib_result res;
 	struct net_device *dev = NULL;
+	struct fib_table *table;
 
 	memset(&key, 0, sizeof(key));
 	key.dst = addr;
+	key.vrf = vrf;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	res.r = NULL;
 #endif
 
-	if (!local_table || local_table->tb_lookup(local_table, &key, &res)) {
+	if (!(table = fib_get_table(vrf,RT_TABLE_LOCAL)) || table->tb_lookup(table, &key, &res)) {
 		return NULL;
 	}
 	if (res.type != RTN_LOCAL)
@@ -168,10 +165,11 @@
 	return dev;
 }
 
-unsigned inet_addr_type(u32 addr)
+unsigned inet_addr_type(unsigned char vrf, u32 addr)
 {
 	struct rt_key		key;
 	struct fib_result	res;
+	struct fib_table	*table;
 	unsigned ret = RTN_BROADCAST;
 
 	if (ZERONET(addr) || BADCLASS(addr))
@@ -181,13 +179,14 @@
 
 	memset(&key, 0, sizeof(key));
 	key.dst = addr;
+	key.vrf = vrf;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	res.r = NULL;
 #endif
 	
-	if (local_table) {
+	if ((table = fib_get_table(vrf,RT_TABLE_LOCAL))) {
 		ret = RTN_UNICAST;
-		if (local_table->tb_lookup(local_table, &key, &res) == 0) {
+		if (table->tb_lookup(table, &key, &res) == 0) {
 			ret = res.type;
 			fib_res_put(&res);
 		}
@@ -216,6 +215,7 @@
 	key.src = dst;
 	key.tos = tos;
 	key.oif = 0;
+	key.vrf = dev->vrf;
 	key.iif = oif;
 	key.scope = RT_SCOPE_UNIVERSE;
 
@@ -304,12 +304,12 @@
 		err = fib_convert_rtentry(cmd, &req.nlh, &req.rtm, &rta, &r);
 		if (err == 0) {
 			if (cmd == SIOCDELRT) {
-				struct fib_table *tb = fib_get_table(req.rtm.rtm_table);
+				struct fib_table *tb = fib_get_table(req.rtm.rtm_vrf, req.rtm.rtm_table);
 				err = -ESRCH;
 				if (tb)
 					err = tb->tb_delete(tb, &req.rtm, &rta, &req.nlh, NULL);
 			} else {
-				struct fib_table *tb = fib_new_table(req.rtm.rtm_table);
+				struct fib_table *tb = fib_new_table(req.rtm.rtm_vrf, req.rtm.rtm_table);
 				err = -ENOBUFS;
 				if (tb)
 					err = tb->tb_insert(tb, &req.rtm, &rta, &req.nlh, NULL);
@@ -357,7 +357,7 @@
 	if (inet_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = fib_get_table(r->rtm_table);
+	tb = fib_get_table(r->rtm_vrf, r->rtm_table);
 	if (tb)
 		return tb->tb_delete(tb, r, (struct kern_rta*)rta, nlh, &NETLINK_CB(skb));
 	return -ESRCH;
@@ -372,7 +372,7 @@
 	if (inet_check_attr(r, rta))
 		return -EINVAL;
 
-	tb = fib_new_table(r->rtm_table);
+	tb = fib_new_table(r->rtm_vrf, r->rtm_table);
 	if (tb)
 		return tb->tb_insert(tb, r, (struct kern_rta*)rta, nlh, &NETLINK_CB(skb));
 	return -ENOBUFS;
@@ -381,6 +381,7 @@
 int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int t;
+	int v;
 	int s_t;
 	struct fib_table *tb;
 
@@ -392,14 +393,18 @@
 	if (s_t == 0)
 		s_t = cb->args[0] = RT_TABLE_MIN;
 
-	for (t=s_t; t<=RT_TABLE_MAX; t++) {
-		if (t < s_t) continue;
-		if (t > s_t)
-			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
-		if ((tb = fib_get_table(t))==NULL)
-			continue;
-		if (tb->tb_dump(tb, skb, cb) < 0) 
-			break;
+	for (v=0;v < VRF_MAX; v++) {
+		for (t=s_t; t<=RT_TABLE_MAX; t++) {
+			if (t < s_t) continue;
+			if (t > s_t)
+				memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
+			if ((tb = fib_get_table(v,t))==NULL)
+				continue;
+			if (tb->tb_dump(tb, skb, cb) < 0) {
+				v = VRF_MAX;
+				break;
+			}
+		}
 	}
 
 	cb->args[0] = t;
@@ -414,7 +419,7 @@
    only when netlink is already locked.
  */
 
-static void fib_magic(int cmd, int type, u32 dst, int dst_len, struct in_ifaddr *ifa)
+static void fib_magic(int cmd, int type, u32 dst, int dst_len, struct in_ifaddr *ifa, unsigned char vrf)
 {
 	struct fib_table * tb;
 	struct {
@@ -427,9 +432,9 @@
 	memset(&rta, 0, sizeof(rta));
 
 	if (type == RTN_UNICAST)
-		tb = fib_new_table(RT_TABLE_MAIN);
+		tb = fib_new_table(vrf, RT_TABLE_MAIN);
 	else
-		tb = fib_new_table(RT_TABLE_LOCAL);
+		tb = fib_new_table(vrf, RT_TABLE_LOCAL);
 
 	if (tb == NULL)
 		return;
@@ -442,6 +447,7 @@
 
 	req.rtm.rtm_dst_len = dst_len;
 	req.rtm.rtm_table = tb->tb_id;
+	req.rtm.rtm_vrf = tb->tb_vrf;
 	req.rtm.rtm_protocol = RTPROT_KERNEL;
 	req.rtm.rtm_scope = (type != RTN_LOCAL ? RT_SCOPE_LINK : RT_SCOPE_HOST);
 	req.rtm.rtm_type = type;
@@ -473,24 +479,24 @@
 		}
 	}
 
-	fib_magic(RTM_NEWROUTE, RTN_LOCAL, addr, 32, prim);
+	fib_magic(RTM_NEWROUTE, RTN_LOCAL, addr, 32, prim, dev->vrf);
 
 	if (!(dev->flags&IFF_UP))
 		return;
 
 	/* Add broadcast address, if it is explicitly assigned. */
 	if (ifa->ifa_broadcast && ifa->ifa_broadcast != 0xFFFFFFFF)
-		fib_magic(RTM_NEWROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
+		fib_magic(RTM_NEWROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim, dev->vrf);
 
 	if (!ZERONET(prefix) && !(ifa->ifa_flags&IFA_F_SECONDARY) &&
 	    (prefix != addr || ifa->ifa_prefixlen < 32)) {
 		fib_magic(RTM_NEWROUTE, dev->flags&IFF_LOOPBACK ? RTN_LOCAL :
-			  RTN_UNICAST, prefix, ifa->ifa_prefixlen, prim);
+			  RTN_UNICAST, prefix, ifa->ifa_prefixlen, prim, dev->vrf);
 
 		/* Add network specific broadcasts, when it takes a sense */
 		if (ifa->ifa_prefixlen < 31) {
-			fib_magic(RTM_NEWROUTE, RTN_BROADCAST, prefix, 32, prim);
-			fib_magic(RTM_NEWROUTE, RTN_BROADCAST, prefix|~mask, 32, prim);
+			fib_magic(RTM_NEWROUTE, RTN_BROADCAST, prefix, 32, prim, dev->vrf);
+			fib_magic(RTM_NEWROUTE, RTN_BROADCAST, prefix|~mask, 32, prim, dev->vrf);
 		}
 	}
 }
@@ -511,7 +517,7 @@
 
 	if (!(ifa->ifa_flags&IFA_F_SECONDARY))
 		fib_magic(RTM_DELROUTE, dev->flags&IFF_LOOPBACK ? RTN_LOCAL :
-			  RTN_UNICAST, any, ifa->ifa_prefixlen, prim);
+			  RTN_UNICAST, any, ifa->ifa_prefixlen, prim, dev->vrf);
 	else {
 		prim = inet_ifa_byprefix(in_dev, any, ifa->ifa_mask);
 		if (prim == NULL) {
@@ -538,16 +544,16 @@
 	}
 
 	if (!(ok&BRD_OK))
-		fib_magic(RTM_DELROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
+		fib_magic(RTM_DELROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim, dev->vrf);
 	if (!(ok&BRD1_OK))
-		fib_magic(RTM_DELROUTE, RTN_BROADCAST, brd, 32, prim);
+		fib_magic(RTM_DELROUTE, RTN_BROADCAST, brd, 32, prim, dev->vrf);
 	if (!(ok&BRD0_OK))
-		fib_magic(RTM_DELROUTE, RTN_BROADCAST, any, 32, prim);
+		fib_magic(RTM_DELROUTE, RTN_BROADCAST, any, 32, prim, dev->vrf);
 	if (!(ok&LOCAL_OK)) {
-		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim);
+		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim, dev->vrf);
 
 		/* Check, that this local address finally disappeared. */
-		if (inet_addr_type(ifa->ifa_local) != RTN_LOCAL) {
+		if (inet_addr_type(dev->vrf,ifa->ifa_local) != RTN_LOCAL) {
 			/* And the last, but not the least thing.
 			   We must flush stray FIB entries.
 
@@ -647,12 +653,7 @@
 	proc_net_create("route",0,fib_get_procinfo);
 #endif		/* CONFIG_PROC_FS */
 
-#ifndef CONFIG_IP_MULTIPLE_TABLES
-	local_table = fib_hash_init(RT_TABLE_LOCAL);
-	main_table = fib_hash_init(RT_TABLE_MAIN);
-#else
 	fib_rules_init();
-#endif
 
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);
diff -uNr linux-kernel/net/ipv4/fib_hash.c vrf-kernel/net/ipv4/fib_hash.c
--- linux-kernel/net/ipv4/fib_hash.c	Sat Aug 24 00:22:27 2002
+++ vrf-kernel/net/ipv4/fib_hash.c	Sun Sep 15 14:37:51 2002
@@ -427,7 +427,7 @@
 
 static void rtmsg_fib(int, struct fib_node*, int, int,
 		      struct nlmsghdr *n,
-		      struct netlink_skb_parms *);
+		      struct netlink_skb_parms *, unsigned char vrf);
 
 static int
 fn_hash_insert(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
@@ -464,7 +464,7 @@
 		key = fz_key(dst, fz);
 	}
 
-	if  ((fi = fib_create_info(r, rta, n, &err)) == NULL)
+	if  ((fi = fib_create_info(r, rta, n, tb->tb_vrf, &err)) == NULL)
 		return err;
 
 #ifdef CONFIG_IP_ROUTE_LARGE_TABLES
@@ -593,7 +593,7 @@
 		write_unlock_bh(&fib_hash_lock);
 
 		if (!(f->fn_state&FN_S_ZOMBIE))
-			rtmsg_fib(RTM_DELROUTE, f, z, tb->tb_id, n, req);
+			rtmsg_fib(RTM_DELROUTE, f, z, tb->tb_id, n, req, tb->tb_vrf);
 		if (f->fn_state&FN_S_ACCESSED)
 			rt_cache_flush(-1);
 		fn_free_node(f);
@@ -601,7 +601,7 @@
 	} else {
 		rt_cache_flush(-1);
 	}
-	rtmsg_fib(RTM_NEWROUTE, new_f, z, tb->tb_id, n, req);
+	rtmsg_fib(RTM_NEWROUTE, new_f, z, tb->tb_id, n, req, tb->tb_vrf);
 	return 0;
 
 out:
@@ -677,7 +677,7 @@
 
 	if (del_fp) {
 		f = *del_fp;
-		rtmsg_fib(RTM_DELROUTE, f, z, tb->tb_id, n, req);
+		rtmsg_fib(RTM_DELROUTE, f, z, tb->tb_id, n, req, tb->tb_vrf);
 
 		if (matched != 1) {
 			write_lock_bh(&fib_hash_lock);
@@ -807,7 +807,7 @@
 				  RTM_NEWROUTE,
 				  tb->tb_id, (f->fn_state&FN_S_ZOMBIE) ? 0 : f->fn_type, f->fn_scope,
 				  &f->fn_key, fz->fz_order, f->fn_tos,
-				  f->fn_info) < 0) {
+				  f->fn_info, tb->tb_vrf) < 0) {
 			cb->args[3] = i;
 			return -1;
 		}
@@ -863,7 +863,8 @@
 }
 
 static void rtmsg_fib(int event, struct fib_node* f, int z, int tb_id,
-		      struct nlmsghdr *n, struct netlink_skb_parms *req)
+		      struct nlmsghdr *n, struct netlink_skb_parms *req,
+		      unsigned char vrf)
 {
 	struct sk_buff *skb;
 	u32 pid = req ? req->pid : 0;
@@ -875,7 +876,7 @@
 
 	if (fib_dump_info(skb, pid, n->nlmsg_seq, event, tb_id,
 			  f->fn_type, f->fn_scope, &f->fn_key, z, f->fn_tos,
-			  FIB_INFO(f)) < 0) {
+			  FIB_INFO(f), vrf) < 0) {
 		kfree_skb(skb);
 		return;
 	}
@@ -887,11 +888,7 @@
 		netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
 }
 
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-struct fib_table * fib_hash_init(int id)
-#else
-struct fib_table * __init fib_hash_init(int id)
-#endif
+struct fib_table * fib_hash_init(unsigned char vrf, int id)
 {
 	struct fib_table *tb;
 
@@ -906,6 +903,7 @@
 		return NULL;
 
 	tb->tb_id = id;
+	tb->tb_vrf = vrf;
 	tb->tb_lookup = fn_hash_lookup;
 	tb->tb_insert = fn_hash_insert;
 	tb->tb_delete = fn_hash_delete;
diff -uNr linux-kernel/net/ipv4/fib_rules.c vrf-kernel/net/ipv4/fib_rules.c
--- linux-kernel/net/ipv4/fib_rules.c	Sat Aug 24 00:22:27 2002
+++ vrf-kernel/net/ipv4/fib_rules.c	Sun Sep 15 19:52:50 2002
@@ -74,32 +74,11 @@
 #endif
 	char		r_ifname[IFNAMSIZ];
 	int		r_dead;
+	unsigned char	r_vrf;
 };
 
-static struct fib_rule default_rule = {
-	r_clntref:	ATOMIC_INIT(2),
-	r_preference:	0x7FFF,
-	r_table:	RT_TABLE_DEFAULT,
-	r_action:	RTN_UNICAST,
-};
-
-static struct fib_rule main_rule = {
-	r_next:		&default_rule,
-	r_clntref:	ATOMIC_INIT(2),
-	r_preference:	0x7FFE,
-	r_table:	RT_TABLE_MAIN,
-	r_action:	RTN_UNICAST,
-};
-
-static struct fib_rule local_rule = {
-	r_next:		&main_rule,
-	r_clntref:	ATOMIC_INIT(2),
-	r_table:	RT_TABLE_LOCAL,
-	r_action:	RTN_UNICAST,
-};
-
-static struct fib_rule *fib_rules = &local_rule;
-static rwlock_t fib_rules_lock = RW_LOCK_UNLOCKED;
+static struct fib_rule *fib_rules[VRF_MAX];
+static rwlock_t fib_rules_lock[VRF_MAX];
 
 int inet_rtm_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
@@ -107,8 +86,11 @@
 	struct rtmsg *rtm = NLMSG_DATA(nlh);
 	struct fib_rule *r, **rp;
 	int err = -ESRCH;
+	unsigned char vrf;
 
-	for (rp=&fib_rules; (r=*rp) != NULL; rp=&r->r_next) {
+	vrf = rtm->rtm_vrf;
+
+	for (rp=&fib_rules[vrf]; (r=*rp) != NULL; rp=&r->r_next) {
 		if ((!rta[RTA_SRC-1] || memcmp(RTA_DATA(rta[RTA_SRC-1]), &r->r_src, 4) == 0) &&
 		    rtm->rtm_src_len == r->r_src_len &&
 		    rtm->rtm_dst_len == r->r_dst_len &&
@@ -122,13 +104,13 @@
 		    (!rta[RTA_IIF-1] || strcmp(RTA_DATA(rta[RTA_IIF-1]), r->r_ifname) == 0) &&
 		    (!rtm->rtm_table || (r && rtm->rtm_table == r->r_table))) {
 			err = -EPERM;
-			if (r == &local_rule)
+			if (r == fib_rules[0])
 				break;
 
-			write_lock_bh(&fib_rules_lock);
+			write_lock_bh(&fib_rules_lock[vrf]);
 			*rp = r->r_next;
 			r->r_dead = 1;
-			write_unlock_bh(&fib_rules_lock);
+			write_unlock_bh(&fib_rules_lock[vrf]);
 			fib_rule_put(r);
 			err = 0;
 			break;
@@ -139,13 +121,13 @@
 
 /* Allocate new unique table id */
 
-static struct fib_table *fib_empty_table(void)
+static struct fib_table *fib_empty_table(unsigned char vrf)
 {
 	int id;
 
 	for (id = 1; id <= RT_TABLE_MAX; id++)
-		if (fib_tables[id] == NULL)
-			return __fib_new_table(id);
+		if (fib_tables[vrf][id] == NULL)
+			return __fib_new_table(vrf,id);
 	return NULL;
 }
 
@@ -165,6 +147,7 @@
 	struct rtmsg *rtm = NLMSG_DATA(nlh);
 	struct fib_rule *r, *new_r, **rp;
 	unsigned char table_id;
+	unsigned char vrf;
 
 	if (rtm->rtm_src_len > 32 || rtm->rtm_dst_len > 32 ||
 	    (rtm->rtm_tos & ~IPTOS_TOS_MASK))
@@ -173,11 +156,12 @@
 	if (rta[RTA_IIF-1] && RTA_PAYLOAD(rta[RTA_IIF-1]) > IFNAMSIZ)
 		return -EINVAL;
 
+	vrf = rtm->rtm_vrf;
 	table_id = rtm->rtm_table;
 	if (table_id == RT_TABLE_UNSPEC) {
 		struct fib_table *table;
 		if (rtm->rtm_type == RTN_UNICAST || rtm->rtm_type == RTN_NAT) {
-			if ((table = fib_empty_table()) == NULL)
+			if ((table = fib_empty_table(vrf)) == NULL)
 				return -ENOBUFS;
 			table_id = table->tb_id;
 		}
@@ -198,6 +182,7 @@
 	new_r->r_srcmask = inet_make_mask(rtm->rtm_src_len);
 	new_r->r_dstmask = inet_make_mask(rtm->rtm_dst_len);
 	new_r->r_tos = rtm->rtm_tos;
+	new_r->r_vrf = vrf;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	if (rta[RTA_PROTOINFO-1])
 		memcpy(&new_r->r_fwmark, RTA_DATA(rta[RTA_PROTOINFO-1]), 4);
@@ -221,11 +206,11 @@
 		memcpy(&new_r->r_tclassid, RTA_DATA(rta[RTA_FLOW-1]), 4);
 #endif
 
-	rp = &fib_rules;
+	rp = &fib_rules[vrf];
 	if (!new_r->r_preference) {
-		r = fib_rules;
+		r = fib_rules[vrf];
 		if (r && (r = r->r_next) != NULL) {
-			rp = &fib_rules->r_next;
+			rp = &fib_rules[vrf]->r_next;
 			if (r->r_preference)
 				new_r->r_preference = r->r_preference - 1;
 		}
@@ -239,9 +224,9 @@
 
 	new_r->r_next = r;
 	atomic_inc(&new_r->r_clntref);
-	write_lock_bh(&fib_rules_lock);
+	write_lock_bh(&fib_rules_lock[vrf]);
 	*rp = new_r;
-	write_unlock_bh(&fib_rules_lock);
+	write_unlock_bh(&fib_rules_lock[vrf]);
 	return 0;
 }
 
@@ -256,7 +241,7 @@
 	struct fib_rule *r = res->r;
 
 	if (r->r_action == RTN_NAT) {
-		int addrtype = inet_addr_type(r->r_srcmap);
+		int addrtype = inet_addr_type(r->r_vrf, r->r_srcmap);
 
 		if (addrtype == RTN_NAT) {
 			/* Packet is from  translated source; remember it */
@@ -285,11 +270,11 @@
 {
 	struct fib_rule *r;
 
-	for (r=fib_rules; r; r=r->r_next) {
+	for (r=fib_rules[dev->vrf]; r; r=r->r_next) {
 		if (r->r_ifindex == dev->ifindex) {
-			write_lock_bh(&fib_rules_lock);
+			write_lock_bh(&fib_rules_lock[dev->vrf]);
 			r->r_ifindex = -1;
-			write_unlock_bh(&fib_rules_lock);
+			write_unlock_bh(&fib_rules_lock[dev->vrf]);
 		}
 	}
 }
@@ -298,11 +283,11 @@
 {
 	struct fib_rule *r;
 
-	for (r=fib_rules; r; r=r->r_next) {
+	for (r=fib_rules[dev->vrf]; r; r=r->r_next) {
 		if (r->r_ifindex == -1 && strcmp(dev->name, r->r_ifname) == 0) {
-			write_lock_bh(&fib_rules_lock);
+			write_lock_bh(&fib_rules_lock[dev->vrf]);
 			r->r_ifindex = dev->ifindex;
-			write_unlock_bh(&fib_rules_lock);
+			write_unlock_bh(&fib_rules_lock[dev->vrf]);
 		}
 	}
 }
@@ -315,11 +300,12 @@
 
 	u32 daddr = key->dst;
 	u32 saddr = key->src;
+	unsigned char vrf = key->vrf;
 
 FRprintk("Lookup: %u.%u.%u.%u <- %u.%u.%u.%u ",
 	NIPQUAD(key->dst), NIPQUAD(key->src));
-	read_lock(&fib_rules_lock);
-	for (r = fib_rules; r; r=r->r_next) {
+	read_lock(&fib_rules_lock[vrf]);
+	for (r = fib_rules[vrf]; r; r=r->r_next) {
 		if (((saddr^r->r_src) & r->r_srcmask) ||
 		    ((daddr^r->r_dst) & r->r_dstmask) ||
 #ifdef CONFIG_IP_ROUTE_TOS
@@ -328,6 +314,7 @@
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		    (r->r_fwmark && r->r_fwmark != key->fwmark) ||
 #endif
+		    (r->r_vrf != vrf) ||
 		    (r->r_ifindex && r->r_ifindex != key->iif))
 			continue;
 
@@ -338,34 +325,34 @@
 			policy = r;
 			break;
 		case RTN_UNREACHABLE:
-			read_unlock(&fib_rules_lock);
+			read_unlock(&fib_rules_lock[vrf]);
 			return -ENETUNREACH;
 		default:
 		case RTN_BLACKHOLE:
-			read_unlock(&fib_rules_lock);
+			read_unlock(&fib_rules_lock[vrf]);
 			return -EINVAL;
 		case RTN_PROHIBIT:
-			read_unlock(&fib_rules_lock);
+			read_unlock(&fib_rules_lock[vrf]);
 			return -EACCES;
 		}
 
-		if ((tb = fib_get_table(r->r_table)) == NULL)
+		if ((tb = fib_get_table(vrf, r->r_table)) == NULL)
 			continue;
 		err = tb->tb_lookup(tb, key, res);
 		if (err == 0) {
 			res->r = policy;
 			if (policy)
 				atomic_inc(&policy->r_clntref);
-			read_unlock(&fib_rules_lock);
+			read_unlock(&fib_rules_lock[vrf]);
 			return 0;
 		}
 		if (err < 0 && err != -EAGAIN) {
-			read_unlock(&fib_rules_lock);
+			read_unlock(&fib_rules_lock[vrf]);
 			return err;
 		}
 	}
 FRprintk("FAILURE\n");
-	read_unlock(&fib_rules_lock);
+	read_unlock(&fib_rules_lock[vrf]);
 	return -ENETUNREACH;
 }
 
@@ -374,7 +361,7 @@
 	if (res->r && res->r->r_action == RTN_UNICAST &&
 	    FIB_RES_GW(*res) && FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK) {
 		struct fib_table *tb;
-		if ((tb = fib_get_table(res->r->r_table)) != NULL)
+		if ((tb = fib_get_table(key->vrf, res->r->r_table)) != NULL)
 			tb->tb_select_default(tb, key, res);
 	}
 }
@@ -414,6 +401,7 @@
 		RTA_PUT(skb, RTA_PROTOINFO, 4, &r->r_fwmark);
 #endif
 	rtm->rtm_table = r->r_table;
+	rtm->rtm_vrf = r->r_vrf;
 	rtm->rtm_protocol = 0;
 	rtm->rtm_scope = 0;
 	rtm->rtm_type = r->r_action;
@@ -433,6 +421,7 @@
 	if (r->r_tclassid)
 		RTA_PUT(skb, RTA_FLOW, 4, &r->r_tclassid);
 #endif
+
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
@@ -444,24 +433,108 @@
 
 int inet_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int idx;
+	int idx = 0;
+	int vrf;
 	int s_idx = cb->args[0];
 	struct fib_rule *r;
 
-	read_lock(&fib_rules_lock);
-	for (r=fib_rules, idx=0; r; r = r->r_next, idx++) {
-		if (idx < s_idx)
-			continue;
-		if (inet_fill_rule(skb, r, cb) < 0)
-			break;
+	for (vrf = 0;vrf < VRF_MAX;vrf++) {
+		read_lock(&fib_rules_lock[vrf]);
+		for (r=fib_rules[vrf]; r; r = r->r_next, idx++) {
+			if (idx < s_idx)
+				continue;
+			if (inet_fill_rule(skb, r, cb) < 0) {
+				vrf = VRF_MAX;
+				break;
+			}
+		}
+		read_unlock(&fib_rules_lock[vrf]);
 	}
-	read_unlock(&fib_rules_lock);
 	cb->args[0] = idx;
 
 	return skb->len;
 }
 
+void do_fib_del_vrf(struct fib_rule *rule) {
+	if (rule->r_next) {
+		do_fib_del_vrf(rule->r_next);
+		rule->r_next = NULL;
+	}
+	rule->r_dead = 1;
+	fib_rule_put(rule);
+}
+
+int fib_del_vrf(unsigned char vrf) {
+
+	if (!vrf) {
+		return 0;
+	}
+	write_lock_bh(&fib_rules_lock[vrf]);
+
+	do_fib_del_vrf(fib_rules[vrf]);
+	fib_rules[vrf] = NULL;
+
+	write_unlock_bh(&fib_rules_lock[vrf]);
+
+	return 0;
+}
+
+int fib_add_vrf(unsigned char vrf) {
+	struct fib_rule *df_rule;
+	struct fib_rule *main_rule;
+	struct fib_rule *loc_rule;
+
+	if (fib_rules[vrf]) return -EEXIST;
+	if (vrf) write_lock_bh(&fib_rules_lock[vrf]);
+
+	df_rule = kmalloc(sizeof(struct fib_rule),GFP_KERNEL);
+	main_rule = kmalloc(sizeof(struct fib_rule),GFP_KERNEL);
+	loc_rule = kmalloc(sizeof(struct fib_rule),GFP_KERNEL);
+
+	memset(df_rule,0,sizeof(*df_rule));
+	memset(main_rule,0,sizeof(*main_rule));
+	memset(loc_rule,0,sizeof(*loc_rule));
+
+        df_rule->r_preference = 0x7FFF;
+        df_rule->r_table = RT_TABLE_DEFAULT;
+        df_rule->r_action = RTN_UNICAST;
+        df_rule->r_vrf = vrf;
+
+        main_rule->r_next = df_rule;
+        main_rule->r_preference = 0x7FFE;
+        main_rule->r_table = RT_TABLE_MAIN;
+        main_rule->r_action = RTN_UNICAST;
+        main_rule->r_vrf = vrf;
+
+        loc_rule->r_next = main_rule;
+        loc_rule->r_table = RT_TABLE_LOCAL;
+        loc_rule->r_action = RTN_UNICAST;
+        loc_rule->r_vrf = vrf;
+
+	atomic_inc(&df_rule->r_clntref);
+	atomic_inc(&loc_rule->r_clntref);
+	atomic_inc(&main_rule->r_clntref);
+
+	__fib_new_table(vrf,RT_TABLE_LOCAL);
+	__fib_new_table(vrf,RT_TABLE_MAIN);
+	__fib_new_table(vrf,RT_TABLE_DEFAULT);
+
+	fib_rules[vrf] = loc_rule;
+
+	if (vrf) write_unlock_bh(&fib_rules_lock[vrf]);
+
+	return 0;
+}
+
 void __init fib_rules_init(void)
 {
+	int i;
+	for (i = 0;i < VRF_MAX;i++) {
+		fib_rules_lock[i] = RW_LOCK_UNLOCKED;
+		fib_rules[i] = NULL;
+	}
+
+	fib_add_vrf(0);
+
 	register_netdevice_notifier(&fib_rules_notifier);
 }
diff -uNr linux-kernel/net/ipv4/fib_semantics.c vrf-kernel/net/ipv4/fib_semantics.c
--- linux-kernel/net/ipv4/fib_semantics.c	Sat Aug 24 00:22:27 2002
+++ vrf-kernel/net/ipv4/fib_semantics.c	Sun Sep 15 14:38:22 2002
@@ -344,7 +344,7 @@
 						|-> {local prefix} (terminal node)
  */
 
-static int fib_check_nh(const struct rtmsg *r, struct fib_info *fi, struct fib_nh *nh)
+static int fib_check_nh(const struct rtmsg *r, struct fib_info *fi, struct fib_nh *nh,unsigned char vrf)
 {
 	int err;
 
@@ -361,7 +361,7 @@
 
 			if (r->rtm_scope >= RT_SCOPE_LINK)
 				return -EINVAL;
-			if (inet_addr_type(nh->nh_gw) != RTN_UNICAST)
+			if (inet_addr_type(r->rtm_vrf, nh->nh_gw) != RTN_UNICAST)
 				return -EINVAL;
 			if ((dev = __dev_get_by_index(nh->nh_oif)) == NULL)
 				return -ENODEV;
@@ -375,6 +375,7 @@
 		memset(&key, 0, sizeof(key));
 		key.dst = nh->nh_gw;
 		key.oif = nh->nh_oif;
+		key.vrf = vrf;
 		key.scope = r->rtm_scope + 1;
 
 		/* It is not necessary, but requires a bit of thinking */
@@ -420,7 +421,7 @@
 
 struct fib_info *
 fib_create_info(const struct rtmsg *r, struct kern_rta *rta,
-		const struct nlmsghdr *nlh, int *errp)
+		const struct nlmsghdr *nlh, unsigned char vrf, int *errp)
 {
 	int err;
 	struct fib_info *fi = NULL;
@@ -534,7 +535,7 @@
 			goto failure;
 	} else {
 		change_nexthops(fi) {
-			if ((err = fib_check_nh(r, fi, nh)) != 0)
+			if ((err = fib_check_nh(r, fi, nh, vrf)) != 0)
 				goto failure;
 		} endfor_nexthops(fi)
 	}
@@ -542,7 +543,7 @@
 	if (fi->fib_prefsrc) {
 		if (r->rtm_type != RTN_LOCAL || rta->rta_dst == NULL ||
 		    memcmp(&fi->fib_prefsrc, rta->rta_dst, 4))
-			if (inet_addr_type(fi->fib_prefsrc) != RTN_LOCAL)
+			if (inet_addr_type(r->rtm_vrf, fi->fib_prefsrc) != RTN_LOCAL)
 				goto err_inval;
 	}
 
@@ -640,7 +641,7 @@
 int
 fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 	      u8 tb_id, u8 type, u8 scope, void *dst, int dst_len, u8 tos,
-	      struct fib_info *fi)
+	      struct fib_info *fi, unsigned char vrf)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr  *nlh;
@@ -653,6 +654,7 @@
 	rtm->rtm_src_len = 0;
 	rtm->rtm_tos = tos;
 	rtm->rtm_table = tb_id;
+	rtm->rtm_vrf = vrf;
 	rtm->rtm_type = type;
 	rtm->rtm_flags = fi->fib_flags;
 	rtm->rtm_scope = scope;
@@ -803,7 +805,7 @@
 	ptr = &((struct sockaddr_in*)&r->rt_gateway)->sin_addr.s_addr;
 	if (r->rt_gateway.sa_family == AF_INET && *ptr) {
 		rta->rta_gw = ptr;
-		if (r->rt_flags&RTF_GATEWAY && inet_addr_type(*ptr) == RTN_UNICAST)
+		if (r->rt_flags&RTF_GATEWAY && inet_addr_type(0, *ptr) == RTN_UNICAST)
 			rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	}
 
diff -uNr linux-kernel/net/ipv4/icmp.c vrf-kernel/net/ipv4/icmp.c
--- linux-kernel/net/ipv4/icmp.c	Sat Aug 24 00:22:27 2002
+++ vrf-kernel/net/ipv4/icmp.c	Sat Aug 24 00:14:28 2002
@@ -341,6 +341,7 @@
 static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 {
 	struct sock *sk=icmp_socket->sk;
+	struct rt_key key;
 	struct ipcm_cookie ipc;
 	struct rtable *rt = (struct rtable*)skb->dst;
 	u32 daddr;
@@ -364,8 +365,15 @@
 		if (ipc.opt->srr)
 			daddr = icmp_param->replyopts.faddr;
 	}
-	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), 0))
+	memset(&key,0,sizeof(key));
+	key.dst = daddr;
+	key.src = rt->rt_spec_dst;
+	key.tos = RT_TOS(skb->nh.iph->tos);
+	key.oif = 0;
+	key.vrf = skb->vrf;
+	if (ip_route_output_key(&rt, &key))
 		goto out;
+
 	if (icmpv4_xrlim_allow(rt, icmp_param->data.icmph.type, 
 			       icmp_param->data.icmph.code)) { 
 		ip_build_xmit(sk, icmp_glue_bits, icmp_param, 
@@ -391,6 +399,7 @@
 void icmp_send(struct sk_buff *skb_in, int type, int code, u32 info)
 {
 	struct iphdr *iph;
+	struct rt_key key;
 	int room;
 	struct icmp_bxm icmp_param;
 	struct rtable *rt = (struct rtable*)skb_in->dst;
@@ -481,7 +490,13 @@
 		((iph->tos & IPTOS_TOS_MASK) | IPTOS_PREC_INTERNETCONTROL) :
 			iph->tos;
 
-	if (ip_route_output(&rt, iph->saddr, saddr, RT_TOS(tos), 0))
+	memset(&key,0,sizeof(key));
+	key.dst = iph->saddr;
+	key.src = saddr;
+	key.tos = RT_TOS(tos);
+	key.oif = 0;
+	key.vrf = skb_in->vrf;
+	if (ip_route_output_key(&rt, &key))
 		goto out;
 
 	if (ip_options_echo(&icmp_param.replyopts, skb_in)) 
@@ -506,7 +521,13 @@
 	ipc.opt = &icmp_param.replyopts;
 	if (icmp_param.replyopts.srr) {
 		ip_rt_put(rt);
-		if (ip_route_output(&rt, icmp_param.replyopts.faddr, saddr, RT_TOS(tos), 0))
+		memset(&key,0,sizeof(key));
+		key.dst = icmp_param.replyopts.faddr;
+		key.src = saddr;
+		key.tos = RT_TOS(tos);
+		key.oif = 0;
+		key.vrf = skb_in->vrf;
+		if (ip_route_output_key(&rt, &key))
 			goto out;
 	}
 
@@ -586,7 +607,7 @@
 						printk(KERN_INFO "ICMP: %u.%u.%u.%u: fragmentation needed and DF set.\n",
 						       NIPQUAD(iph->daddr));
 				} else {
-					info = ip_rt_frag_needed(iph, ntohs(icmph->un.frag.mtu));
+					info = ip_rt_frag_needed(iph, ntohs(icmph->un.frag.mtu), skb->vrf);
 					if (!info) 
 						goto out;
 				}
@@ -622,7 +643,7 @@
 	if (!sysctl_icmp_ignore_bogus_error_responses)
 	{
 	
-		if (inet_addr_type(iph->daddr) == RTN_BROADCAST)
+		if (inet_addr_type(skb->vrf, iph->daddr) == RTN_BROADCAST)
 		{
 			if (net_ratelimit())
 				printk(KERN_WARNING "%u.%u.%u.%u sent an invalid ICMP error to a broadcast.\n",
@@ -650,7 +671,8 @@
 	if ((raw_sk = raw_v4_htable[hash]) != NULL) 
 	{
 		while ((raw_sk = __raw_v4_lookup(raw_sk, protocol, iph->daddr,
-						 iph->saddr, skb->dev->ifindex)) != NULL) {
+						 iph->saddr, skb->dev->ifindex,
+						 skb->vrf)) != NULL) {
 			raw_err(raw_sk, skb, info);
 			raw_sk = raw_sk->next;
 			iph = (struct iphdr *)skb->data;
@@ -737,6 +759,7 @@
 
 static void icmp_echo(struct sk_buff *skb)
 {
+
 	if (!sysctl_icmp_echo_ignore_all) {
 		struct icmp_bxm icmp_param;
 
diff -uNr linux-kernel/net/ipv4/igmp.c vrf-kernel/net/ipv4/igmp.c
--- linux-kernel/net/ipv4/igmp.c	Sat Aug 24 00:22:27 2002
+++ vrf-kernel/net/ipv4/igmp.c	Sat Aug 24 00:14:28 2002
@@ -198,6 +198,7 @@
 	struct iphdr *iph;
 	struct igmphdr *ih;
 	struct rtable *rt;
+	struct rt_key key;
 	u32	dst;
 
 	/* According to IGMPv2 specs, LEAVE messages are
@@ -207,7 +208,13 @@
 	if (type == IGMP_HOST_LEAVE_MESSAGE)
 		dst = IGMP_ALL_ROUTER;
 
-	if (ip_route_output(&rt, dst, 0, 0, dev->ifindex))
+	memset(&key,0,sizeof(key));
+	key.dst = dst;
+	key.src = 0;
+	key.tos = 0;
+	key.oif = dev->ifindex;
+	key.vrf = dev->vrf;
+	if (ip_route_output_key(&rt, &key))
 		return -1;
 	if (rt->rt_src == 0) {
 		ip_rt_put(rt);
@@ -609,20 +616,27 @@
 	write_unlock_bh(&in_dev->lock);
 }
 
-static struct in_device * ip_mc_find_dev(struct ip_mreqn *imr)
+static struct in_device * ip_mc_find_dev(unsigned char vrf, struct ip_mreqn *imr)
 {
 	struct rtable *rt;
+	struct rt_key key;
 	struct net_device *dev = NULL;
 	struct in_device *idev = NULL;
 
 	if (imr->imr_address.s_addr) {
-		dev = ip_dev_find(imr->imr_address.s_addr);
+		dev = ip_dev_find(vrf, imr->imr_address.s_addr);
 		if (!dev)
 			return NULL;
 		__dev_put(dev);
 	}
 
-	if (!dev && !ip_route_output(&rt, imr->imr_multiaddr.s_addr, 0, 0, 0)) {
+	memset(&key,0,sizeof(key));
+	key.dst = imr->imr_multiaddr.s_addr;
+	key.src = 0;
+	key.tos = 0;
+	key.oif = 0;
+	key.vrf = vrf;
+	if (!dev && !ip_route_output_key(&rt, &key)) {
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
 	}
@@ -652,7 +666,7 @@
 	rtnl_shlock();
 
 	if (!imr->imr_ifindex)
-		in_dev = ip_mc_find_dev(imr);
+		in_dev = ip_mc_find_dev(sk->vrf,imr);
 	else {
 		in_dev = inetdev_by_index(imr->imr_ifindex);
 		if (in_dev)
diff -uNr linux-kernel/net/ipv4/ip_gre.c vrf-kernel/net/ipv4/ip_gre.c
--- linux-kernel/net/ipv4/ip_gre.c	Sat Aug 24 00:22:28 2002
+++ vrf-kernel/net/ipv4/ip_gre.c	Sat Aug 24 00:14:29 2002
@@ -411,6 +411,7 @@
 	int grehlen = (iph->ihl<<2) + 4;
 	struct sk_buff *skb2;
 	struct rtable *rt;
+	struct rt_key key;
 
 	if (p[1] != __constant_htons(ETH_P_IP))
 		return;
@@ -485,8 +486,14 @@
 	skb_pull(skb2, skb->data - (u8*)eiph);
 	skb2->nh.raw = skb2->data;
 
+	memset(&key,0,sizeof(key));
+	key.dst = eiph->saddr;
+	key.src = 0;
+	key.tos = RT_TOS(eiph->tos);
+	key.oif = 0;
+	key.vrf = skb->vrf
 	/* Try to guess incoming interface */
-	if (ip_route_output(&rt, eiph->saddr, 0, RT_TOS(eiph->tos), 0)) {
+	if (ip_route_output_key(&rt, &key)) {
 		kfree_skb(skb2);
 		return;
 	}
@@ -496,8 +503,12 @@
 	if (rt->rt_flags&RTCF_LOCAL) {
 		ip_rt_put(rt);
 		rt = NULL;
-		if (ip_route_output(&rt, eiph->daddr, eiph->saddr, eiph->tos, 0) ||
-		    rt->u.dst.dev->type != ARPHRD_IPGRE) {
+		key.dst = eiph->daddr;
+		key.src = eiph->saddr;
+		key.tos = eiph->tos;
+		key.oif = 0;
+		key.vrf = skb2->vrf;
+		if (ip_route_output_key(&rt, &key) || rt->u.dst.dev->type != ARPHRD_IPGRE) {
 			ip_rt_put(rt);
 			kfree_skb(skb2);
 			return;
@@ -677,6 +688,7 @@
 	struct net_device_stats *stats = &tunnel->stat;
 	struct iphdr  *old_iph = skb->nh.iph;
 	struct iphdr  *tiph;
+	struct rt_key key;
 	u8     tos;
 	u16    df;
 	struct rtable *rt;     			/* Route to the other host */
@@ -747,7 +759,13 @@
 		tos &= ~1;
 	}
 
-	if (ip_route_output(&rt, dst, tiph->saddr, RT_TOS(tos), tunnel->parms.link)) {
+	memset(&key,0,sizeof(key));
+	key.dst = dst;
+	key.src = tiph->saddr;
+	key.tos = RT_TOS(tos);
+	key.oif = tunnel->parms.link;
+	key.vrf = skb->vrf;
+	if (ip_route_output_key(&rt, &key)) {
 		tunnel->stat.tx_carrier_errors++;
 		goto tx_error;
 	}
@@ -1102,10 +1120,16 @@
 
 	MOD_INC_USE_COUNT;
 	if (MULTICAST(t->parms.iph.daddr)) {
+		struct rt_key key;
 		struct rtable *rt;
-		if (ip_route_output(&rt, t->parms.iph.daddr,
-				    t->parms.iph.saddr, RT_TOS(t->parms.iph.tos), 
-				    t->parms.link)) {
+
+		memset(&key,0,sizeof(key));
+		key.dst = t->parms.iph.daddr;
+		key.src = t->parms.iph.saddr;
+		key.tos = RT_TOS(t->parms.iph.tos);
+		key.oif = t->parms.link;
+		key.vrf = dev->vrf;
+		if (ip_route_output_key(&rt, &key)) {
 			MOD_DEC_USE_COUNT;
 			return -EADDRNOTAVAIL;
 		}
@@ -1176,7 +1200,15 @@
 
 	if (iph->daddr) {
 		struct rtable *rt;
-		if (!ip_route_output(&rt, iph->daddr, iph->saddr, RT_TOS(iph->tos), tunnel->parms.link)) {
+		struct rt_key key;
+
+		memset(&key,0,sizeof(key));
+		key.dst = iph->daddr;
+		key.src = iph->saddr;
+		key.tos = RT_TOS(iph->tos);
+		key.oif = tunnel->parms.link;
+		key.vrf = dev->vrf;
+		if (!ip_route_output_key(&rt, &key)) {
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
diff -uNr linux-kernel/net/ipv4/ip_input.c vrf-kernel/net/ipv4/ip_input.c
--- linux-kernel/net/ipv4/ip_input.c	Sat Aug 24 00:22:28 2002
+++ vrf-kernel/net/ipv4/ip_input.c	Sat Aug 24 00:14:29 2002
@@ -276,7 +276,7 @@
 			raw_rcv(raw_sk, skb);
 			sock_put(raw_sk);
 		} else if (!flag) {		/* Free and report errors */
-			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PROT_UNREACH, 0);	
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PROT_UNREACH, 0);
 			kfree_skb(skb);
 		}
 	}
@@ -433,6 +433,7 @@
 				skb->ip_summed = CHECKSUM_NONE;
 		}
 	}
+	skb->vrf = dev->vrf;
 
 	return NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
 		       ip_rcv_finish);
diff -uNr linux-kernel/net/ipv4/ip_options.c vrf-kernel/net/ipv4/ip_options.c
--- linux-kernel/net/ipv4/ip_options.c	Sat Aug 24 00:22:28 2002
+++ vrf-kernel/net/ipv4/ip_options.c	Sat Aug 24 00:14:29 2002
@@ -147,7 +147,7 @@
 						__u32 addr;
 
 						memcpy(&addr, sptr+soffset-1, 4);
-						if (inet_addr_type(addr) != RTN_LOCAL) {
+						if (inet_addr_type(skb->vrf, addr) != RTN_LOCAL) {
 							dopt->ts_needtime = 1;
 							soffset += 8;
 						}
@@ -388,7 +388,7 @@
 					{
 						u32 addr;
 						memcpy(&addr, &optptr[optptr[2]-1], 4);
-						if (inet_addr_type(addr) == RTN_UNICAST)
+						if (inet_addr_type(skb->vrf, addr) == RTN_UNICAST)
 							break;
 						if (skb)
 							timeptr = (__u32*)&optptr[optptr[2]+3];
diff -uNr linux-kernel/net/ipv4/ip_output.c vrf-kernel/net/ipv4/ip_output.c
--- linux-kernel/net/ipv4/ip_output.c	Sat Aug 24 00:22:28 2002
+++ vrf-kernel/net/ipv4/ip_output.c	Sat Aug 24 00:14:29 2002
@@ -353,6 +353,7 @@
 	/* Make sure we can route this packet. */
 	rt = (struct rtable *)__sk_dst_check(sk, 0);
 	if (rt == NULL) {
+		struct rt_key key;
 		u32 daddr;
 
 		/* Use correct destination address if we have options. */
@@ -364,9 +365,13 @@
 		 * keep trying until route appears or the connection times itself
 		 * out.
 		 */
-		if (ip_route_output(&rt, daddr, sk->saddr,
-				    RT_CONN_FLAGS(sk),
-				    sk->bound_dev_if))
+		memset(&key,0,sizeof(key));
+		key.dst = daddr;
+		key.src = sk->saddr;
+		key.tos = RT_CONN_FLAGS(sk);
+		key.oif = sk->bound_dev_if;
+		key.vrf = sk->vrf;
+		if (ip_route_output_key(&rt, &key))
 			goto no_route;
 		__sk_dst_set(sk, &rt->u.dst);
 		sk->route_caps = rt->u.dst.dev->features;
@@ -532,6 +537,7 @@
 		skb->priority = sk->priority;
 		skb->dst = dst_clone(&rt->u.dst);
 		skb_reserve(skb, hh_len);
+		skb->vrf = sk->vrf;
 
 		/*
 		 *	Find where to start putting bytes.
@@ -652,7 +658,7 @@
 		/*
 		 * 	Check for slow path.
 		 */
-		if (length > rt->u.dst.pmtu || ipc->opt != NULL)  
+		if (length > rt->u.dst.pmtu || ipc->opt != NULL) 
 			return ip_build_xmit_slow(sk,getfrag,frag,length,ipc,rt,flags); 
 	} else {
 		if (length > rt->u.dst.dev->mtu) {
@@ -683,6 +689,7 @@
 	skb_reserve(skb, hh_len);
 	}
 
+	skb->vrf = rt->key.vrf;
 	skb->priority = sk->priority;
 	skb->dst = dst_clone(&rt->u.dst);
 
@@ -948,6 +955,7 @@
 		struct ip_options	opt;
 		char			data[40];
 	} replyopts;
+	struct rt_key key;
 	struct ipcm_cookie ipc;
 	u32 daddr;
 	struct rtable *rt = (struct rtable*)skb->dst;
@@ -965,7 +973,13 @@
 			daddr = replyopts.opt.faddr;
 	}
 
-	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), 0))
+	memset(&key,0,sizeof(key));
+	key.dst = daddr;
+	key.src = rt->rt_spec_dst;
+	key.tos = RT_TOS(skb->nh.iph->tos);
+	key.oif = 0;
+	key.vrf = sk->vrf;
+	if (ip_route_output_key(&rt, &key))
 		return;
 
 	/* And let IP do all the hard work.
diff -uNr linux-kernel/net/ipv4/ip_sockglue.c vrf-kernel/net/ipv4/ip_sockglue.c
--- linux-kernel/net/ipv4/ip_sockglue.c	Sat Aug 24 00:22:28 2002
+++ vrf-kernel/net/ipv4/ip_sockglue.c	Sat Aug 24 00:14:29 2002
@@ -560,7 +560,7 @@
 					err = 0;
 					break;
 				}
-				dev = ip_dev_find(mreq.imr_address.s_addr);
+				dev = ip_dev_find(sk->vrf, mreq.imr_address.s_addr);
 				if (dev) {
 					mreq.imr_ifindex = dev->ifindex;
 					dev_put(dev);
diff -uNr linux-kernel/net/ipv4/ipip.c vrf-kernel/net/ipv4/ipip.c
--- linux-kernel/net/ipv4/ipip.c	Sat Aug 24 00:22:28 2002
+++ vrf-kernel/net/ipv4/ipip.c	Sat Aug 24 00:14:29 2002
@@ -356,6 +356,7 @@
 	int rel_info = 0;
 	struct sk_buff *skb2;
 	struct rtable *rt;
+	struct rt_key key;
 
 	if (len < hlen + sizeof(struct iphdr))
 		return;
@@ -416,8 +417,14 @@
 	skb_pull(skb2, skb->data - (u8*)eiph);
 	skb2->nh.raw = skb2->data;
 
+	memset(&key,0,sizeof(key));
+	key.dst = eiph->saddr;
+	key.src = 0;
+	key.tos = RT_TOS(eiph->tos);
+	key.oif = 0;
+	key.vrf = skb->vrf;
 	/* Try to guess incoming interface */
-	if (ip_route_output(&rt, eiph->saddr, 0, RT_TOS(eiph->tos), 0)) {
+	if (ip_route_output_key(&rt, &key)) {
 		kfree_skb(skb2);
 		return;
 	}
@@ -427,8 +434,12 @@
 	if (rt->rt_flags&RTCF_LOCAL) {
 		ip_rt_put(rt);
 		rt = NULL;
-		if (ip_route_output(&rt, eiph->daddr, eiph->saddr, eiph->tos, 0) ||
-		    rt->u.dst.dev->type != ARPHRD_IPGRE) {
+		key.dst = eiph->daddr;
+		key.src = eiph->saddr;
+		key.tos = eiph->tos;
+		key.oif = 0;
+		key.vrf = skb2->vrf;
+		if (ip_route_output_key(&rt, &key) || rt->u.dst.dev->type != ARPHRD_IPGRE) {
 			ip_rt_put(rt);
 			kfree_skb(skb2);
 			return;
@@ -531,6 +542,7 @@
 	struct iphdr  *tiph = &tunnel->parms.iph;
 	u8     tos = tunnel->parms.iph.tos;
 	u16    df = tiph->frag_off;
+	struct rt_key key;
 	struct rtable *rt;     			/* Route to the other host */
 	struct net_device *tdev;			/* Device to other host */
 	struct iphdr  *old_iph = skb->nh.iph;
@@ -560,7 +572,13 @@
 			goto tx_error_icmp;
 	}
 
-	if (ip_route_output(&rt, dst, tiph->saddr, RT_TOS(tos), tunnel->parms.link)) {
+	memset(&key,0,sizeof(key));
+	key.dst = dst;
+	key.src = tiph->saddr;
+	key.tos = RT_TOS(tos);
+	key.oif = tunnel->parms.link;
+	key.vrf = skb->vrf;
+	if (ip_route_output_key(&rt, &key)) {
 		tunnel->stat.tx_carrier_errors++;
 		goto tx_error_icmp;
 	}
@@ -822,8 +840,16 @@
 	ipip_tunnel_init_gen(dev);
 
 	if (iph->daddr) {
+		struct rt_key key;
 		struct rtable *rt;
-		if (!ip_route_output(&rt, iph->daddr, iph->saddr, RT_TOS(iph->tos), tunnel->parms.link)) {
+
+		memset(&key,0,sizeof(key));
+		key.dst = iph->daddr;
+		key.src = iph->saddr;
+		key.tos = RT_TOS(iph->tos);
+		key.oif = tunnel->parms.link;
+		key.vrf = dev->vrf;
+		if (!ip_route_output_key(&rt, &key)) {
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
diff -uNr linux-kernel/net/ipv4/ipmr.c vrf-kernel/net/ipv4/ipmr.c
--- linux-kernel/net/ipv4/ipmr.c	Sat Aug 24 00:22:28 2002
+++ vrf-kernel/net/ipv4/ipmr.c	Sat Aug 24 00:14:29 2002
@@ -372,7 +372,7 @@
 	}
 }
 
-static int vif_add(struct vifctl *vifc, int mrtsock)
+static int vif_add(unsigned char vrf, struct vifctl *vifc, int mrtsock)
 {
 	int vifi = vifc->vifc_vifi;
 	struct vif_device *v = &vif_table[vifi];
@@ -403,7 +403,7 @@
 			return -ENOBUFS;
 		break;
 	case 0:
-		dev=ip_dev_find(vifc->vifc_lcl_addr.s_addr);
+		dev=ip_dev_find(vrf, vifc->vifc_lcl_addr.s_addr);
 		if (!dev)
 			return -EADDRNOTAVAIL;
 		__dev_put(dev);
@@ -890,7 +890,7 @@
 				return -ENFILE;
 			rtnl_lock();
 			if (optname==MRT_ADD_VIF) {
-				ret = vif_add(&vif, sk==mroute_socket);
+				ret = vif_add(sk->vrf, &vif, sk==mroute_socket);
 			} else {
 				ret = vif_delete(vif.vifc_vifi);
 			}
@@ -1125,6 +1125,7 @@
 	struct rtable *rt;
 	int    encap = 0;
 	struct sk_buff *skb2;
+	struct rt_key key;
 
 	if (vif->dev == NULL)
 		return;
@@ -1141,11 +1142,23 @@
 #endif
 
 	if (vif->flags&VIFF_TUNNEL) {
-		if (ip_route_output(&rt, vif->remote, vif->local, RT_TOS(iph->tos), vif->link))
+		memset(&key,0,sizeof(key));
+		key.dst = vif->remote;
+		key.src = vif->local;
+		key.tos = RT_TOS(iph->tos);
+		key.oif = vif->link;
+		key.vrf = skb->vrf;
+		if (ip_route_output_key(&rt, &key))
 			return;
 		encap = sizeof(struct iphdr);
 	} else {
-		if (ip_route_output(&rt, iph->daddr, 0, RT_TOS(iph->tos), vif->link))
+		memset(&key,0,sizeof(key));
+		key.dst = iph->daddr;
+		key.src = 0;
+		key.tos = RT_TOS(iph->tos);
+		key.oif = vif->link;
+		key.vrf = skb->vrf;
+		if (ip_route_output_key(&rt, &key))
 			return;
 	}
 
diff -uNr linux-kernel/net/ipv4/raw.c vrf-kernel/net/ipv4/raw.c
--- linux-kernel/net/ipv4/raw.c	Sat Aug 24 00:22:31 2002
+++ vrf-kernel/net/ipv4/raw.c	Sat Aug 24 00:14:30 2002
@@ -98,12 +98,13 @@
 
 struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
 			     unsigned long raddr, unsigned long laddr,
-			     int dif)
+			     int dif,unsigned char vrf)
 {
 	struct sock *s = sk;
 
 	for (s = sk; s; s = s->next) {
 		if (s->num == num 				&&
+		    s->vrf == vrf 				&&
 		    !(s->daddr && s->daddr != raddr) 		&&
 		    !(s->rcv_saddr && s->rcv_saddr != laddr)	&&
 		    !(s->bound_dev_if && s->bound_dev_if != dif))
@@ -147,12 +148,13 @@
 		goto out;
 	sk = __raw_v4_lookup(sk, iph->protocol,
 			     iph->saddr, iph->daddr,
-			     skb->dev->ifindex);
+			     skb->dev->ifindex, skb->vrf);
 
 	while (sk) {
 		struct sock *sknext = __raw_v4_lookup(sk->next, iph->protocol,
 						      iph->saddr, iph->daddr,
-						      skb->dev->ifindex);
+						      skb->dev->ifindex,
+						      skb->vrf);
 		if (iph->protocol != IPPROTO_ICMP ||
 		    !icmp_filter(sk, skb)) {
 			struct sk_buff *clone;
@@ -307,6 +309,7 @@
 	struct ipcm_cookie ipc;
 	struct rawfakehdr rfh;
 	struct rtable *rt = NULL;
+	struct rt_key key;
 	int free = 0;
 	u32 daddr;
 	u8  tos;
@@ -408,7 +411,13 @@
 			rfh.saddr = sk->protinfo.af_inet.mc_addr;
 	}
 
-	err = ip_route_output(&rt, daddr, rfh.saddr, tos, ipc.oif);
+	memset(&key,0,sizeof(key));
+	key.dst = daddr;
+	key.src = rfh.saddr;
+	key.tos = tos;
+	key.oif = ipc.oif;
+	key.vrf = sk->vrf;
+	err = ip_route_output_key(&rt, &key);
 
 	if (err)
 		goto done;
@@ -463,7 +472,7 @@
 
 	if (sk->state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_in))
 		goto out;
-	chk_addr_ret = inet_addr_type(addr->sin_addr.s_addr);
+	chk_addr_ret = inet_addr_type(sk->vrf, addr->sin_addr.s_addr);
 	ret = -EADDRNOTAVAIL;
 	if (addr->sin_addr.s_addr && chk_addr_ret != RTN_LOCAL &&
 	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
diff -uNr linux-kernel/net/ipv4/route.c vrf-kernel/net/ipv4/route.c
--- linux-kernel/net/ipv4/route.c	Sat Aug 24 00:22:32 2002
+++ vrf-kernel/net/ipv4/route.c	Sun Sep 15 16:21:47 2002
@@ -792,7 +792,7 @@
 		if (IN_DEV_SEC_REDIRECTS(in_dev) && ip_fib_check_default(new_gw, dev))
 			goto reject_redirect;
 	} else {
-		if (inet_addr_type(new_gw) != RTN_UNICAST)
+		if (inet_addr_type(dev->vrf, new_gw) != RTN_UNICAST)
 			goto reject_redirect;
 	}
 
@@ -811,6 +811,7 @@
 				if (rth->key.dst != daddr ||
 				    rth->key.src != skeys[i] ||
 				    rth->key.tos != tos ||
+				    rth->key.vrf != dev->vrf ||
 				    rth->key.oif != ikeys[k] ||
 				    rth->key.iif != 0) {
 					rthp = &rth->u.rt_next;
@@ -1015,7 +1016,7 @@
 
 out:	kfree_skb(skb);
 	return 0;
-} 
+}
 
 /*
  *	The last two values are not from the RFC but
@@ -1035,7 +1036,7 @@
 	return 68;
 }
 
-unsigned short ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu)
+unsigned short ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu, unsigned char vrf)
 {
 	int i;
 	unsigned short old_mtu = ntohs(iph->tot_len);
@@ -1058,6 +1059,7 @@
 			    rth->key.src == skeys[i] &&
 			    rth->rt_dst  == daddr &&
 			    rth->rt_src  == iph->saddr &&
+			    rth->key.vrf == vrf &&
 			    rth->key.tos == tos &&
 			    rth->key.iif == 0 &&
 			    !(rth->u.dst.mxlock & (1 << RTAX_MTU))) {
@@ -1271,6 +1273,7 @@
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	rth->key.fwmark	= skb->nfmark;
 #endif
+	rth->key.vrf	= dev->vrf;
 	rth->key.src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_NAT
@@ -1350,6 +1353,7 @@
 	key.fwmark	= skb->nfmark;
 #endif
 	key.iif		= dev->ifindex;
+	key.vrf		= skb->vrf;
 	key.oif		= 0;
 	key.scope	= RT_SCOPE_UNIVERSE;
 
@@ -1488,6 +1492,7 @@
 #endif
 	rth->rt_iif 	=
 	rth->key.iif	= dev->ifindex;
+	rth->key.vrf	= skb->vrf;
 	rth->u.dst.dev	= out_dev->dev;
 	dev_hold(rth->u.dst.dev);
 	rth->key.oif 	= 0;
@@ -1565,6 +1570,7 @@
 #endif
 	rth->rt_iif	=
 	rth->key.iif	= dev->ifindex;
+	rth->key.vrf	= dev->vrf;
 	rth->u.dst.dev	= &loopback_dev;
 	dev_hold(rth->u.dst.dev);
 	rth->key.oif 	= 0;
@@ -1647,6 +1653,7 @@
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
 		if (rth->key.dst == daddr &&
 		    rth->key.src == saddr &&
+		    rth->key.vrf == skb->vrf &&
 		    rth->key.iif == iif &&
 		    rth->key.oif == 0 &&
 #ifdef CONFIG_IP_ROUTE_FWMARK
@@ -1718,6 +1725,7 @@
 	key.src		= oldkey->src;
 	key.tos		= tos & IPTOS_RT_MASK;
 	key.iif		= loopback_dev.ifindex;
+	key.vrf		= oldkey->vrf;
 	key.oif		= oldkey->oif;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	key.fwmark	= oldkey->fwmark;
@@ -1737,7 +1745,7 @@
 			goto out;
 
 		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-		dev_out = ip_dev_find(oldkey->src);
+		dev_out = ip_dev_find(oldkey->vrf, oldkey->src);
 		if (dev_out == NULL)
 			goto out;
 
@@ -1929,6 +1937,7 @@
 	rth->key.tos	= tos;
 	rth->key.src	= oldkey->src;
 	rth->key.iif	= 0;
+	rth->key.vrf	= oldkey->vrf;
 	rth->key.oif	= oldkey->oif;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	rth->key.fwmark	= oldkey->fwmark;
@@ -2008,6 +2017,7 @@
 		    rth->key.src == key->src &&
 		    rth->key.iif == 0 &&
 		    rth->key.oif == key->oif &&
+		    rth->key.vrf == key->vrf &&
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		    rth->key.fwmark == key->fwmark &&
 #endif
@@ -2165,10 +2175,17 @@
 		if (!err && rt->u.dst.error)
 			err = -rt->u.dst.error;
 	} else {
+		struct rt_key key;
 		int oif = 0;
 		if (rta[RTA_OIF - 1])
 			memcpy(&oif, RTA_DATA(rta[RTA_OIF - 1]), sizeof(int));
-		err = ip_route_output(&rt, dst, src, rtm->rtm_tos, oif);
+		memset(&key,0,sizeof(key));
+		key.dst = dst;
+		key.src = src;
+		key.tos = rtm->rtm_tos;
+		key.oif = oif;
+		key.vrf = rtm->rtm_vrf;
+		err = ip_route_output_key(&rt, &key);
 	}
 	if (err) {
 		kfree_skb(skb);
diff -uNr linux-kernel/net/ipv4/syncookies.c vrf-kernel/net/ipv4/syncookies.c
--- linux-kernel/net/ipv4/syncookies.c	Sat Aug 24 00:22:32 2002
+++ vrf-kernel/net/ipv4/syncookies.c	Sat Aug 24 00:14:30 2002
@@ -117,6 +117,7 @@
 	int mss; 
 	struct rtable *rt; 
 	__u8 rcv_wscale;
+	struct rt_key key;
 
 	if (!sysctl_tcp_syncookies || !skb->h.th->ack)
 		goto out;
@@ -169,12 +170,13 @@
 	 * hasn't changed since we received the original syn, but I see
 	 * no easy way to do this. 
 	 */
-	if (ip_route_output(&rt,
-			    opt && 
-			    opt->srr ? opt->faddr : req->af.v4_req.rmt_addr,
-			    req->af.v4_req.loc_addr,
-			    RT_CONN_FLAGS(sk),
-			    0)) { 
+	memset(&key,0,sizeof(key));
+	key.dst = opt && opt->srr ? opt->faddr : req->af.v4_req.rmt_addr;
+	key.src = req->af.v4_req.loc_addr;
+	key.oif = 0;
+	key.tos = RT_CONN_FLAGS(sk);
+	key.vrf = sk->vrf;
+	if (ip_route_output_key(&rt, &key)) {
 		tcp_openreq_free(req);
 		goto out; 
 	}
diff -uNr linux-kernel/net/ipv4/tcp_ipv4.c vrf-kernel/net/ipv4/tcp_ipv4.c
--- linux-kernel/net/ipv4/tcp_ipv4.c	Sat Aug 24 00:22:32 2002
+++ vrf-kernel/net/ipv4/tcp_ipv4.c	Sat Sep 14 23:48:05 2002
@@ -124,13 +124,14 @@
  * The bindhash mutex for snum's hash chain must be held here.
  */
 struct tcp_bind_bucket *tcp_bucket_create(struct tcp_bind_hashbucket *head,
-					  unsigned short snum)
+				  unsigned short snum, unsigned char vrf)
 {
 	struct tcp_bind_bucket *tb;
 
 	tb = kmem_cache_alloc(tcp_bucket_cachep, SLAB_ATOMIC);
 	if(tb != NULL) {
 		tb->port = snum;
+		tb->vrf = vrf;
 		tb->fastreuse = 0;
 		tb->owners = NULL;
 		if((tb->next = head->chain) != NULL)
@@ -186,9 +187,10 @@
 			if (!sk_reuse	||
 			    !sk2->reuse	||
 			    sk2->state == TCP_LISTEN) {
-				if (!sk2->rcv_saddr	||
+				if ((sk->vrf == sk2->vrf) &&
+				    (!sk2->rcv_saddr	||
 				    !sk->rcv_saddr	||
-				    (sk2->rcv_saddr == sk->rcv_saddr))
+				    (sk2->rcv_saddr == sk->rcv_saddr)))
 					break;
 			}
 		}
@@ -243,7 +245,7 @@
 		head = &tcp_bhash[tcp_bhashfn(snum)];
 		spin_lock(&head->lock);
 		for (tb = head->chain; tb != NULL; tb = tb->next)
-			if (tb->port == snum)
+			if (tb->port == snum && tb->vrf == sk->vrf)
 				break;
 	}
 	if (tb != NULL && tb->owners != NULL) {
@@ -259,7 +261,7 @@
 	}
 	ret = 1;
 	if (tb == NULL &&
-	    (tb = tcp_bucket_create(head, snum)) == NULL)
+	    (tb = tcp_bucket_create(head, snum, sk->vrf)) == NULL)
 			goto fail_unlock;
 	if (tb->owners == NULL) {
 		if (sk->reuse && sk->state != TCP_LISTEN)
@@ -413,7 +415,7 @@
  * connection.  So always assume those are both wildcarded
  * during the search since they can never be otherwise.
  */
-static struct sock *__tcp_v4_lookup_listener(struct sock *sk, u32 daddr, unsigned short hnum, int dif)
+static struct sock *__tcp_v4_lookup_listener(struct sock *sk, u32 daddr, unsigned short hnum, int dif, unsigned char vrf)
 {
 	struct sock *result = NULL;
 	int score, hiscore;
@@ -434,7 +436,11 @@
 					continue;
 				score++;
 			}
-			if (score == 3)
+
+			if (sk->vrf != vrf)
+				continue;
+			score++;
+			if (score == 4)
 				return sk;
 			if (score > hiscore) {
 				hiscore = score;
@@ -446,7 +452,7 @@
 }
 
 /* Optimize the common listener case. */
-__inline__ struct sock *tcp_v4_lookup_listener(u32 daddr, unsigned short hnum, int dif)
+__inline__ struct sock *tcp_v4_lookup_listener(u32 daddr, unsigned short hnum, int dif, unsigned char vrf)
 {
 	struct sock *sk;
 
@@ -458,7 +464,7 @@
 		    (!sk->rcv_saddr || sk->rcv_saddr == daddr) &&
 		    !sk->bound_dev_if)
 			goto sherry_cache;
-		sk = __tcp_v4_lookup_listener(sk, daddr, hnum, dif);
+		sk = __tcp_v4_lookup_listener(sk, daddr, hnum, dif, vrf);
 	}
 	if (sk) {
 sherry_cache:
@@ -475,7 +481,7 @@
  */
 
 static inline struct sock *__tcp_v4_lookup_established(u32 saddr, u16 sport,
-						       u32 daddr, u16 hnum, int dif)
+       u32 daddr, u16 hnum, int dif, unsigned char vrf)
 {
 	struct tcp_ehash_bucket *head;
 	TCP_V4_ADDR_COOKIE(acookie, saddr, daddr)
@@ -490,13 +496,13 @@
 	head = &tcp_ehash[hash];
 	read_lock(&head->lock);
 	for(sk = head->chain; sk; sk = sk->next) {
-		if(TCP_IPV4_MATCH(sk, acookie, saddr, daddr, ports, dif))
+		if(TCP_IPV4_MATCH(sk, acookie, saddr, daddr, ports, dif, vrf))
 			goto hit; /* You sunk my battleship! */
 	}
 
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
 	for(sk = (head + tcp_ehash_size)->chain; sk; sk = sk->next)
-		if(TCP_IPV4_MATCH(sk, acookie, saddr, daddr, ports, dif))
+		if(TCP_IPV4_MATCH(sk, acookie, saddr, daddr, ports, dif, vrf))
 			goto hit;
 	read_unlock(&head->lock);
 
@@ -508,25 +514,25 @@
 	return sk;
 }
 
-static inline struct sock *__tcp_v4_lookup(u32 saddr, u16 sport,
-					   u32 daddr, u16 hnum, int dif)
+static inline struct sock *__tcp_v4_lookup(u32 saddr, u16 sport, u32 daddr,
+	u16 hnum, int dif, unsigned char vrf)
 {
 	struct sock *sk;
 
-	sk = __tcp_v4_lookup_established(saddr, sport, daddr, hnum, dif);
+	sk = __tcp_v4_lookup_established(saddr, sport, daddr, hnum, dif, vrf);
 
 	if (sk)
 		return sk;
 		
-	return tcp_v4_lookup_listener(daddr, hnum, dif);
+	return tcp_v4_lookup_listener(daddr, hnum, dif, vrf);
 }
 
-__inline__ struct sock *tcp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif)
+__inline__ struct sock *tcp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif, unsigned char vrf)
 {
 	struct sock *sk;
 
 	local_bh_disable();
-	sk = __tcp_v4_lookup(saddr, sport, daddr, ntohs(dport), dif);
+	sk = __tcp_v4_lookup(saddr, sport, daddr, ntohs(dport), dif, vrf);
 	local_bh_enable();
 
 	return sk;
@@ -547,6 +553,7 @@
 	u32 daddr = sk->rcv_saddr;
 	u32 saddr = sk->daddr;
 	int dif = sk->bound_dev_if;
+	unsigned char vrf = sk->vrf;
 	TCP_V4_ADDR_COOKIE(acookie, saddr, daddr)
 	__u32 ports = TCP_COMBINED_PORTS(sk->dport, lport);
 	int hash = tcp_hashfn(daddr, lport, saddr, sk->dport);
@@ -561,7 +568,7 @@
 	    skp = &sk2->next) {
 		tw = (struct tcp_tw_bucket*)sk2;
 
-		if(TCP_IPV4_MATCH(sk2, acookie, saddr, daddr, ports, dif)) {
+		if(TCP_IPV4_MATCH(sk2, acookie, saddr, daddr, ports, dif, vrf)) {
 			struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
 
 			/* With PAWS, it is safe from the viewpoint
@@ -596,7 +603,7 @@
 
 	/* And established part... */
 	for(skp = &head->chain; (sk2=*skp)!=NULL; skp = &sk2->next) {
-		if(TCP_IPV4_MATCH(sk2, acookie, saddr, daddr, ports, dif))
+		if(TCP_IPV4_MATCH(sk2, acookie, saddr, daddr, ports, dif, vrf))
 			goto not_unique;
 	}
 
@@ -690,7 +697,7 @@
 				}
 			}
 
-			tb = tcp_bucket_create(head, rover);
+			tb = tcp_bucket_create(head, rover, sk->vrf);
 			if (!tb) {
 				spin_unlock(&head->lock);
 				break;
@@ -771,7 +778,7 @@
 	}
 
 	tmp = ip_route_connect(&rt, nexthop, sk->saddr,
-			       RT_CONN_FLAGS(sk), sk->bound_dev_if);
+			       RT_CONN_FLAGS(sk), sk->bound_dev_if, sk->vrf);
 	if (tmp < 0)
 		return tmp;
 
@@ -985,7 +992,7 @@
 		return;
 	}
 
-	sk = tcp_v4_lookup(iph->daddr, th->dest, iph->saddr, th->source, tcp_v4_iif(skb));
+	sk = tcp_v4_lookup(iph->daddr, th->dest, iph->saddr, th->source, tcp_v4_iif(skb), skb->vrf);
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(IcmpInErrors);
 		return;
@@ -1259,14 +1266,18 @@
 static struct dst_entry* tcp_v4_route_req(struct sock *sk, struct open_request *req)
 {
 	struct rtable *rt;
+	struct rt_key key;
 	struct ip_options *opt;
 
 	opt = req->af.v4_req.opt;
-	if(ip_route_output(&rt, ((opt && opt->srr) ?
-				 opt->faddr :
-				 req->af.v4_req.rmt_addr),
-			   req->af.v4_req.loc_addr,
-			   RT_CONN_FLAGS(sk), sk->bound_dev_if)) {
+	memset(&key,0,sizeof(key));
+	key.dst = ((opt && opt->srr) ? opt->faddr : req->af.v4_req.rmt_addr);
+	key.src = req->af.v4_req.loc_addr;
+	key.oif = sk->bound_dev_if;
+	key.tos = RT_CONN_FLAGS(sk);
+	key.vrf = sk->vrf;
+
+	if(ip_route_output_key(&rt, &key)) {
 		IP_INC_STATS_BH(IpOutNoRoutes);
 		return NULL;
 	}
@@ -1295,6 +1306,7 @@
 		goto out;
 
 	skb = tcp_make_synack(sk, dst, req);
+	skb->vrf = sk->vrf;
 
 	if (skb) {
 		struct tcphdr *th = skb->h.th;
@@ -1599,7 +1611,7 @@
 					  th->source,
 					  skb->nh.iph->daddr,
 					  ntohs(th->dest),
-					  tcp_v4_iif(skb));
+					  tcp_v4_iif(skb), skb->vrf);
 
 	if (nsk) {
 		if (nsk->state != TCP_TIME_WAIT) {
@@ -1749,7 +1761,8 @@
 	TCP_SKB_CB(skb)->sacked = 0;
 
 	sk = __tcp_v4_lookup(skb->nh.iph->saddr, th->source,
-			     skb->nh.iph->daddr, ntohs(th->dest), tcp_v4_iif(skb));
+			     skb->nh.iph->daddr, ntohs(th->dest),
+			     tcp_v4_iif(skb), skb->vrf);
 
 	if (!sk)
 		goto no_tcp_socket;
@@ -1804,7 +1817,8 @@
 	{
 		struct sock *sk2;
 
-		sk2 = tcp_v4_lookup_listener(skb->nh.iph->daddr, ntohs(th->dest), tcp_v4_iif(skb));
+		sk2 = tcp_v4_lookup_listener(skb->nh.iph->daddr,
+			ntohs(th->dest), tcp_v4_iif(skb), skb->vrf);
 		if (sk2 != NULL) {
 			tcp_tw_deschedule((struct tcp_tw_bucket *)sk);
 			tcp_timewait_kill((struct tcp_tw_bucket *)sk);
@@ -1847,7 +1861,7 @@
 	/* Query new route. */
 	err = ip_route_connect(&rt, daddr, 0,
 			       RT_TOS(sk->protinfo.af_inet.tos)|sk->localroute,
-			       sk->bound_dev_if);
+			       sk->bound_dev_if, sk->vrf);
 	if (err)
 		return err;
 
@@ -1883,6 +1897,7 @@
 int tcp_v4_rebuild_header(struct sock *sk)
 {
 	struct rtable *rt = (struct rtable *)__sk_dst_check(sk, 0);
+	struct rt_key key;
 	u32 daddr;
 	int err;
 
@@ -1895,8 +1910,13 @@
 	if(sk->protinfo.af_inet.opt && sk->protinfo.af_inet.opt->srr)
 		daddr = sk->protinfo.af_inet.opt->faddr;
 
-	err = ip_route_output(&rt, daddr, sk->saddr,
-			      RT_CONN_FLAGS(sk), sk->bound_dev_if);
+	memset(&key,0,sizeof(key));
+	key.dst = daddr;
+	key.src = sk->saddr;
+	key.oif = sk->bound_dev_if;
+	key.tos = RT_CONN_FLAGS(sk);
+	key.vrf = sk->vrf;
+	err = ip_route_output_key(&rt, &key);
 	if (!err) {
 		__sk_dst_set(sk, &rt->u.dst);
 		sk->route_caps = rt->u.dst.dev->features;
diff -uNr linux-kernel/net/ipv4/tcp_output.c vrf-kernel/net/ipv4/tcp_output.c
--- linux-kernel/net/ipv4/tcp_output.c	Sat Aug 24 00:22:32 2002
+++ vrf-kernel/net/ipv4/tcp_output.c	Sat Aug 24 00:14:30 2002
@@ -265,6 +265,7 @@
 
 			TCP_ECN_send(sk, tp, skb, tcp_header_size);
 		}
+		skb->vrf = sk->vrf;
 		tp->af_specific->send_check(sk, th, skb->len, skb);
 
 		if (tcb->flags & TCPCB_FLAG_ACK)
diff -uNr linux-kernel/net/ipv4/udp.c vrf-kernel/net/ipv4/udp.c
--- linux-kernel/net/ipv4/udp.c	Sat Aug 24 00:22:32 2002
+++ vrf-kernel/net/ipv4/udp.c	Sat Sep 14 23:36:58 2002
@@ -160,6 +160,7 @@
 			if (sk2->num == snum &&
 			    sk2 != sk &&
 			    sk2->bound_dev_if == sk->bound_dev_if &&
+			    sk2->vrf == sk->vrf &&
 			    (!sk2->rcv_saddr ||
 			     !sk->rcv_saddr ||
 			     sk2->rcv_saddr == sk->rcv_saddr) &&
@@ -208,7 +209,7 @@
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-struct sock *udp_v4_lookup_longway(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif)
+struct sock *udp_v4_lookup_longway(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif, unsigned char vrf)
 {
 	struct sock *sk, *result = NULL;
 	unsigned short hnum = ntohs(dport);
@@ -237,7 +238,11 @@
 					continue;
 				score++;
 			}
-			if(score == 4) {
+			if(sk->vrf != vrf)
+				continue;
+			score++;
+
+			if(score == 5) {
 				result = sk;
 				break;
 			} else if(score > badness) {
@@ -249,12 +254,12 @@
 	return result;
 }
 
-__inline__ struct sock *udp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif)
+__inline__ struct sock *udp_v4_lookup(u32 saddr, u16 sport, u32 daddr, u16 dport, int dif, unsigned char vrf)
 {
 	struct sock *sk;
 
 	read_lock(&udp_hash_lock);
-	sk = udp_v4_lookup_longway(saddr, sport, daddr, dport, dif);
+	sk = udp_v4_lookup_longway(saddr, sport, daddr, dport, dif, vrf);
 	if (sk)
 		sock_hold(sk);
 	read_unlock(&udp_hash_lock);
@@ -271,9 +276,10 @@
 	for(; s; s = s->next) {
 		if ((s->num != hnum)					||
 		    (s->daddr && s->daddr!=rmt_addr)			||
-		    (s->dport != rmt_port && s->dport != 0)			||
+		    (s->dport != rmt_port && s->dport != 0)		||
 		    (s->rcv_saddr  && s->rcv_saddr != loc_addr)		||
-		    (s->bound_dev_if && s->bound_dev_if != dif))
+		    (s->bound_dev_if && s->bound_dev_if != dif)		||
+		    (s->vrf != sk->vrf))
 			continue;
 		break;
   	}
@@ -301,7 +307,7 @@
 	int harderr;
 	int err;
 
-	sk = udp_v4_lookup(iph->daddr, uh->dest, iph->saddr, uh->source, skb->dev->ifindex);
+	sk = udp_v4_lookup(iph->daddr, uh->dest, iph->saddr, uh->source, skb->dev->ifindex, skb->vrf);
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(IcmpInErrors);
     	  	return;	/* No socket for error */
@@ -517,7 +523,14 @@
 		rt = (struct rtable*)sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
-		err = ip_route_output(&rt, daddr, ufh.saddr, tos, ipc.oif);
+		struct rt_key key;
+		memset(&key,0,sizeof(key));
+		key.dst = daddr;
+		key.src = ufh.saddr;
+		key.tos = tos;
+		key.oif = ipc.oif;
+		key.vrf = sk->vrf;
+		err = ip_route_output_key(&rt, &key);
 		if (err)
 			goto out;
 
@@ -734,7 +747,7 @@
 			saddr = sk->protinfo.af_inet.mc_addr;
 	}
 	err = ip_route_connect(&rt, usin->sin_addr.s_addr, saddr,
-			       RT_CONN_FLAGS(sk), oif);
+			       RT_CONN_FLAGS(sk), oif, sk->vrf);
 	if (err)
 		return err;
 	if ((rt->rt_flags&RTCF_BROADCAST) && !sk->broadcast) {
@@ -915,7 +928,7 @@
 	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return udp_v4_mcast_deliver(skb, uh, saddr, daddr);
 
-	sk = udp_v4_lookup(saddr, uh->source, daddr, uh->dest, skb->dev->ifindex);
+	sk = udp_v4_lookup(saddr, uh->source, daddr, uh->dest, skb->dev->ifindex, skb->vrf);
 
 	if (sk != NULL) {
 		udp_queue_rcv_skb(sk, skb);
