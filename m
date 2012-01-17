From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix some sparse errors
Date: Tue, 17 Jan 2012 06:27:39 +0100
Message-ID: <1326778059.2564.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:55361 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2AQF1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 00:27:44 -0500
Received: by wibhm6 with SMTP id hm6so1097134wib.19
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2012 21:27:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make C=2 CF="-D__CHECK_ENDIAN__" M=net

And fix flowi4_init_output() prototype for sport

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/flow.h    |    2 +-
 net/core/secure_seq.c |    2 +-
 net/ipv4/inetpeer.c   |    2 +-
 net/ipv4/ipconfig.c   |    8 ++++----
 net/ipv4/ping.c       |   27 ++++++++++++++-------------
 net/ipv6/datagram.c   |    2 +-
 6 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index da1f064..9b58243 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -78,7 +78,7 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 				      __u32 mark, __u8 tos, __u8 scope,
 				      __u8 proto, __u8 flags,
 				      __be32 daddr, __be32 saddr,
-				      __be16 dport, __be32 sport)
+				      __be16 dport, __be16 sport)
 {
 	fl4->flowi4_oif = oif;
 	fl4->flowi4_iif = 0;
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 6fd4460..99b2596 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -46,7 +46,7 @@ __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 
 	memcpy(hash, saddr, 16);
 	for (i = 0; i < 4; i++)
-		secret[i] = net_secret[i] + daddr[i];
+		secret[i] = net_secret[i] + (__force u32)daddr[i];
 	secret[4] = net_secret[4] +
 		(((__force u16)sport << 16) + (__force u16)dport);
 	for (i = 5; i < MD5_MESSAGE_BYTES / 4; i++)
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 86f13c67..986a02b 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -136,7 +136,7 @@ static int addr_compare(const struct inetpeer_addr *a,
 	for (i = 0; i < n; i++) {
 		if (a->addr.a6[i] == b->addr.a6[i])
 			continue;
-		if (a->addr.a6[i] < b->addr.a6[i])
+		if ((__force u32)a->addr.a6[i] < (__force u32)b->addr.a6[i])
 			return -1;
 		return 1;
 	}
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 7e4ec9f..6e412a6 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -141,7 +141,7 @@ __be32 ic_servaddr = NONE;	/* Boot server IP address */
 __be32 root_server_addr = NONE;	/* Address of NFS server */
 u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
-u32 ic_dev_xid;		/* Device under configuration */
+__be32 ic_dev_xid;		/* Device under configuration */
 
 /* vendor class identifier */
 static char vendor_class_identifier[253] __initdata;
@@ -859,9 +859,9 @@ static int __init ic_bootp_string(char *dest, char *src, int len, int max)
  */
 static void __init ic_do_bootp_ext(u8 *ext)
 {
-       u8 servers;
-       int i;
-	u16 mtu;
+	u8 servers;
+	int i;
+	__be16 mtu;
 
 #ifdef IPCONFIG_DEBUG
 	u8 *c;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 43d4c3b..aea5a19 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -140,13 +140,14 @@ static void ping_v4_unhash(struct sock *sk)
 		write_lock_bh(&ping_table.lock);
 		hlist_nulls_del(&sk->sk_nulls_node);
 		sock_put(sk);
-		isk->inet_num = isk->inet_sport = 0;
+		isk->inet_num = 0;
+		isk->inet_sport = 0;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 		write_unlock_bh(&ping_table.lock);
 	}
 }
 
-static struct sock *ping_v4_lookup(struct net *net, u32 saddr, u32 daddr,
+static struct sock *ping_v4_lookup(struct net *net, __be32 saddr, __be32 daddr,
 				   u16 ident, int dif)
 {
 	struct hlist_nulls_head *hslot = ping_hashslot(&ping_table, net, ident);
@@ -154,15 +155,15 @@ static struct sock *ping_v4_lookup(struct net *net, u32 saddr, u32 daddr,
 	struct inet_sock *isk;
 	struct hlist_nulls_node *hnode;
 
-	pr_debug("try to find: num = %d, daddr = %ld, dif = %d\n",
-			 (int)ident, (unsigned long)daddr, dif);
+	pr_debug("try to find: num = %d, daddr = %pI4, dif = %d\n",
+			 (int)ident, &daddr, dif);
 	read_lock_bh(&ping_table.lock);
 
 	ping_portaddr_for_each_entry(sk, hnode, hslot) {
 		isk = inet_sk(sk);
 
-		pr_debug("found: %p: num = %d, daddr = %ld, dif = %d\n", sk,
-			 (int)isk->inet_num, (unsigned long)isk->inet_rcv_saddr,
+		pr_debug("found: %p: num = %d, daddr = %pI4, dif = %d\n", sk,
+			 (int)isk->inet_num, &isk->inet_rcv_saddr,
 			 sk->sk_bound_dev_if);
 
 		pr_debug("iterate\n");
@@ -254,7 +255,7 @@ static int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		sk, addr->sin_addr.s_addr, ntohs(addr->sin_port));
 
 	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
-	if (addr->sin_addr.s_addr == INADDR_ANY)
+	if (addr->sin_addr.s_addr == htonl(INADDR_ANY))
 		chk_addr_ret = RTN_LOCAL;
 
 	if ((sysctl_ip_nonlocal_bind == 0 &&
@@ -278,9 +279,9 @@ static int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	}
 
-	pr_debug("after bind(): num = %d, daddr = %ld, dif = %d\n",
+	pr_debug("after bind(): num = %d, daddr = %pI4, dif = %d\n",
 		(int)isk->inet_num,
-		(unsigned long) isk->inet_rcv_saddr,
+		&isk->inet_rcv_saddr,
 		(int)sk->sk_bound_dev_if);
 
 	err = 0;
@@ -407,7 +408,7 @@ out:
 struct pingfakehdr {
 	struct icmphdr icmph;
 	struct iovec *iov;
-	u32 wcheck;
+	__wsum wcheck;
 };
 
 static int ping_getfrag(void *from, char * to,
@@ -459,7 +460,7 @@ static int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct rtable *rt = NULL;
 	struct ip_options_data opt_copy;
 	int free = 0;
-	u32 saddr, daddr, faddr;
+	__be32 saddr, daddr, faddr;
 	u8  tos;
 	int err;
 
@@ -696,8 +697,8 @@ void ping_rcv(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	struct iphdr *iph = ip_hdr(skb);
 	struct icmphdr *icmph = icmp_hdr(skb);
-	u32 saddr = iph->saddr;
-	u32 daddr = iph->daddr;
+	__be32 saddr = iph->saddr;
+	__be32 daddr = iph->daddr;
 
 	/* We assume the packet has already been checked by icmp_rcv */
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index ae08aee..251e7cd 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -575,7 +575,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 	}
 	if (np->rxopt.bits.rxorigdstaddr) {
 		struct sockaddr_in6 sin6;
-		u16 *ports = (u16 *) skb_transport_header(skb);
+		__be16 *ports = (__be16 *) skb_transport_header(skb);
 
 		if (skb_transport_offset(skb) + 4 <= skb->len) {
 			/* All current transport protocols have the port numbers in the
