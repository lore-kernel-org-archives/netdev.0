From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH-mm 8/8] decnet: remove private wrappers of endian helpers
Date: Wed, 26 Nov 2008 13:12:54 -0800
Message-ID: <1227733974.5511.130.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:4584 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbYKZVNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 16:13:04 -0500
Received: by yx-out-2324.google.com with SMTP id 8so337060yxm.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 13:13:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 include/net/dn.h               |    8 ++---
 include/net/dn_fib.h           |    6 ++--
 net/decnet/af_decnet.c         |   62 ++++++++++++++++++++--------------------
 net/decnet/dn_dev.c            |   20 ++++++------
 net/decnet/dn_neigh.c          |   18 ++++++------
 net/decnet/dn_nsp_in.c         |   28 +++++++++--------
 net/decnet/dn_nsp_out.c        |   22 +++++++-------
 net/decnet/dn_route.c          |   18 ++++++------
 net/decnet/dn_table.c          |    2 +-
 net/decnet/sysctl_net_decnet.c |    4 +-
 10 files changed, 94 insertions(+), 94 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index 6277783..7cd6bb8 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -4,9 +4,7 @@
 #include <linux/dn.h>
 #include <net/sock.h>
 #include <asm/byteorder.h>
-
-#define dn_ntohs(x) le16_to_cpu(x)
-#define dn_htons(x) cpu_to_le16(x)
+#include <asm/unalignedh>
 
 struct dn_scp                                   /* Session Control Port */
 {
@@ -175,7 +173,7 @@ struct dn_skb_cb {
 
 static inline __le16 dn_eth2dn(unsigned char *ethaddr)
 {
-	return dn_htons(ethaddr[4] | (ethaddr[5] << 8));
+	return get_unaligned((__le16 *)(ethaddr + 4));
 }
 
 static inline __le16 dn_saddr2dn(struct sockaddr_dn *saddr)
@@ -185,7 +183,7 @@ static inline __le16 dn_saddr2dn(struct sockaddr_dn *saddr)
 
 static inline void dn_dn2eth(unsigned char *ethaddr, __le16 addr)
 {
-	__u16 a = dn_ntohs(addr);
+	__u16 a = le16_to_cpu(addr);
 	ethaddr[0] = 0xAA;
 	ethaddr[1] = 0x00;
 	ethaddr[2] = 0x04;
diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index 3012511..c378be7 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -181,9 +181,9 @@ static inline void dn_fib_res_put(struct dn_fib_res *res)
 
 static inline __le16 dnet_make_mask(int n)
 {
-        if (n)
-                return dn_htons(~((1<<(16-n))-1));
-        return 0;
+	if (n)
+		return cpu_to_le16(~((1 << (16 - n)) - 1));
+	return cpu_to_le16(0);
 }
 
 #endif /* _NET_DN_FIB_H */
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 3c23ab3..cf0e184 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -167,7 +167,7 @@ static struct hlist_head *dn_find_list(struct sock *sk)
 	if (scp->addr.sdn_flags & SDF_WILD)
 		return hlist_empty(&dn_wild_sk) ? &dn_wild_sk : NULL;
 
-	return &dn_sk_hash[dn_ntohs(scp->addrloc) & DN_SK_HASH_MASK];
+	return &dn_sk_hash[le16_to_cpu(scp->addrloc) & DN_SK_HASH_MASK];
 }
 
 /*
@@ -181,7 +181,7 @@ static int check_port(__le16 port)
 	if (port == 0)
 		return -1;
 
-	sk_for_each(sk, node, &dn_sk_hash[dn_ntohs(port) & DN_SK_HASH_MASK]) {
+	sk_for_each(sk, node, &dn_sk_hash[le16_to_cpu(port) & DN_SK_HASH_MASK]) {
 		struct dn_scp *scp = DN_SK(sk);
 		if (scp->addrloc == port)
 			return -1;
@@ -195,12 +195,12 @@ static unsigned short port_alloc(struct sock *sk)
 static unsigned short port = 0x2000;
 	unsigned short i_port = port;
 
-	while(check_port(dn_htons(++port)) != 0) {
+	while(check_port(cpu_to_le16(++port)) != 0) {
 		if (port == i_port)
 			return 0;
 	}
 
-	scp->addrloc = dn_htons(port);
+	scp->addrloc = cpu_to_le16(port);
 
 	return 1;
 }
@@ -255,7 +255,7 @@ static struct hlist_head *listen_hash(struct sockaddr_dn *addr)
 
 	if (hash == 0) {
 		hash = addr->sdn_objnamel;
-		for(i = 0; i < dn_ntohs(addr->sdn_objnamel); i++) {
+		for(i = 0; i < le16_to_cpu(addr->sdn_objnamel); i++) {
 			hash ^= addr->sdn_objname[i];
 			hash ^= (hash << 3);
 		}
@@ -297,16 +297,16 @@ int dn_sockaddr2username(struct sockaddr_dn *sdn, unsigned char *buf, unsigned c
 			break;
 		case 1:
 			*buf++ = 0;
-			*buf++ = dn_ntohs(sdn->sdn_objnamel);
-			memcpy(buf, sdn->sdn_objname, dn_ntohs(sdn->sdn_objnamel));
-			len = 3 + dn_ntohs(sdn->sdn_objnamel);
+			*buf++ = le16_to_cpu(sdn->sdn_objnamel);
+			memcpy(buf, sdn->sdn_objname, le16_to_cpu(sdn->sdn_objnamel));
+			len = 3 + le16_to_cpu(sdn->sdn_objnamel);
 			break;
 		case 2:
 			memset(buf, 0, 5);
 			buf += 5;
-			*buf++ = dn_ntohs(sdn->sdn_objnamel);
-			memcpy(buf, sdn->sdn_objname, dn_ntohs(sdn->sdn_objnamel));
-			len = 7 + dn_ntohs(sdn->sdn_objnamel);
+			*buf++ = le16_to_cpu(sdn->sdn_objnamel);
+			memcpy(buf, sdn->sdn_objname, le16_to_cpu(sdn->sdn_objnamel));
+			len = 7 + le16_to_cpu(sdn->sdn_objnamel);
 			break;
 	}
 
@@ -327,7 +327,7 @@ int dn_username2sockaddr(unsigned char *data, int len, struct sockaddr_dn *sdn,
 	int namel = 12;
 
 	sdn->sdn_objnum = 0;
-	sdn->sdn_objnamel = dn_htons(0);
+	sdn->sdn_objnamel = cpu_to_le16(0);
 	memset(sdn->sdn_objname, 0, DN_MAXOBJL);
 
 	if (len < 2)
@@ -361,13 +361,13 @@ int dn_username2sockaddr(unsigned char *data, int len, struct sockaddr_dn *sdn,
 	if (len < 0)
 		return -1;
 
-	sdn->sdn_objnamel = dn_htons(*data++);
-	len -= dn_ntohs(sdn->sdn_objnamel);
+	sdn->sdn_objnamel = cpu_to_le16(*data++);
+	len -= le16_to_cpu(sdn->sdn_objnamel);
 
-	if ((len < 0) || (dn_ntohs(sdn->sdn_objnamel) > namel))
+	if ((len < 0) || (le16_to_cpu(sdn->sdn_objnamel) > namel))
 		return -1;
 
-	memcpy(sdn->sdn_objname, data, dn_ntohs(sdn->sdn_objnamel));
+	memcpy(sdn->sdn_objname, data, le16_to_cpu(sdn->sdn_objnamel));
 
 	return size - len;
 }
@@ -391,7 +391,7 @@ struct sock *dn_sklist_find_listener(struct sockaddr_dn *addr)
 				continue;
 			if (scp->addr.sdn_objnamel != addr->sdn_objnamel)
 				continue;
-			if (memcmp(scp->addr.sdn_objname, addr->sdn_objname, dn_ntohs(addr->sdn_objnamel)) != 0)
+			if (memcmp(scp->addr.sdn_objname, addr->sdn_objname, le16_to_cpu(addr->sdn_objnamel)) != 0)
 				continue;
 		}
 		sock_hold(sk);
@@ -419,7 +419,7 @@ struct sock *dn_find_by_skb(struct sk_buff *skb)
 	struct dn_scp *scp;
 
 	read_lock(&dn_hash_lock);
-	sk_for_each(sk, node, &dn_sk_hash[dn_ntohs(cb->dst_port) & DN_SK_HASH_MASK]) {
+	sk_for_each(sk, node, &dn_sk_hash[le16_to_cpu(cb->dst_port) & DN_SK_HASH_MASK]) {
 		scp = DN_SK(sk);
 		if (cb->src != dn_saddr2dn(&scp->peer))
 			continue;
@@ -734,10 +734,10 @@ static int dn_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (saddr->sdn_family != AF_DECnet)
 		return -EINVAL;
 
-	if (dn_ntohs(saddr->sdn_nodeaddrl) && (dn_ntohs(saddr->sdn_nodeaddrl) != 2))
+	if (le16_to_cpu(saddr->sdn_nodeaddrl) && (le16_to_cpu(saddr->sdn_nodeaddrl) != 2))
 		return -EINVAL;
 
-	if (dn_ntohs(saddr->sdn_objnamel) > DN_MAXOBJL)
+	if (le16_to_cpu(saddr->sdn_objnamel) > DN_MAXOBJL)
 		return -EINVAL;
 
 	if (saddr->sdn_flags & ~SDF_WILD)
@@ -748,7 +748,7 @@ static int dn_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		return -EACCES;
 
 	if (!(saddr->sdn_flags & SDF_WILD)) {
-		if (dn_ntohs(saddr->sdn_nodeaddrl)) {
+		if (le16_to_cpu(saddr->sdn_nodeaddrl)) {
 			read_lock(&dev_base_lock);
 			ldev = NULL;
 			for_each_netdev(&init_net, dev) {
@@ -799,15 +799,15 @@ static int dn_auto_bind(struct socket *sock)
 	if ((scp->accessdata.acc_accl != 0) &&
 		(scp->accessdata.acc_accl <= 12)) {
 
-		scp->addr.sdn_objnamel = dn_htons(scp->accessdata.acc_accl);
-		memcpy(scp->addr.sdn_objname, scp->accessdata.acc_acc, dn_ntohs(scp->addr.sdn_objnamel));
+		scp->addr.sdn_objnamel = cpu_to_le16(scp->accessdata.acc_accl);
+		memcpy(scp->addr.sdn_objname, scp->accessdata.acc_acc, le16_to_cpu(scp->addr.sdn_objnamel));
 
 		scp->accessdata.acc_accl = 0;
 		memset(scp->accessdata.acc_acc, 0, 40);
 	}
 	/* End of compatibility stuff */
 
-	scp->addr.sdn_add.a_len = dn_htons(2);
+	scp->addr.sdn_add.a_len = cpu_to_le16(2);
 	rv = dn_dev_bind_default((__le16 *)scp->addr.sdn_add.a_addr);
 	if (rv == 0) {
 		rv = dn_hash_sock(sk);
@@ -1027,7 +1027,7 @@ static void dn_user_copy(struct sk_buff *skb, struct optdata_dn *opt)
 	u16 len = *ptr++; /* yes, it's 8bit on the wire */
 
 	BUG_ON(len > 16); /* we've checked the contents earlier */
-	opt->opt_optl   = dn_htons(len);
+	opt->opt_optl   = cpu_to_le16(len);
 	opt->opt_status = 0;
 	memcpy(opt->opt_data, ptr, len);
 	skb_pull(skb, len + 1);
@@ -1375,7 +1375,7 @@ static int __dn_setsockopt(struct socket *sock, int level,int optname, char __us
 			if (optlen != sizeof(struct optdata_dn))
 				return -EINVAL;
 
-			if (dn_ntohs(u.opt.opt_optl) > 16)
+			if (le16_to_cpu(u.opt.opt_optl) > 16)
 				return -EINVAL;
 
 			memcpy(&scp->conndata_out, &u.opt, optlen);
@@ -1388,7 +1388,7 @@ static int __dn_setsockopt(struct socket *sock, int level,int optname, char __us
 			if (optlen != sizeof(struct optdata_dn))
 				return -EINVAL;
 
-			if (dn_ntohs(u.opt.opt_optl) > 16)
+			if (le16_to_cpu(u.opt.opt_optl) > 16)
 				return -EINVAL;
 
 			memcpy(&scp->discdata_out, &u.opt, optlen);
@@ -2213,12 +2213,12 @@ static void dn_printable_object(struct sockaddr_dn *dn, unsigned char *buf)
 {
 	int i;
 
-	switch (dn_ntohs(dn->sdn_objnamel)) {
+	switch (le16_to_cpu(dn->sdn_objnamel)) {
 		case 0:
 			sprintf(buf, "%d", dn->sdn_objnum);
 			break;
 		default:
-			for (i = 0; i < dn_ntohs(dn->sdn_objnamel); i++) {
+			for (i = 0; i < le16_to_cpu(dn->sdn_objnamel); i++) {
 				buf[i] = dn->sdn_objname[i];
 				if (IS_NOT_PRINTABLE(buf[i]))
 					buf[i] = '.';
@@ -2281,7 +2281,7 @@ static inline void dn_socket_format_entry(struct seq_file *seq, struct sock *sk)
 	seq_printf(seq,
 		   "%6s/%04X %04d:%04d %04d:%04d %01d %-16s "
 		   "%6s/%04X %04d:%04d %04d:%04d %01d %-16s %4s %s\n",
-		   dn_addr2asc(dn_ntohs(dn_saddr2dn(&scp->addr)), buf1),
+		   dn_addr2asc(le16_to_cpu(dn_saddr2dn(&scp->addr)), buf1),
 		   scp->addrloc,
 		   scp->numdat,
 		   scp->numoth,
@@ -2289,7 +2289,7 @@ static inline void dn_socket_format_entry(struct seq_file *seq, struct sock *sk)
 		   scp->ackxmt_oth,
 		   scp->flowloc_sw,
 		   local_object,
-		   dn_addr2asc(dn_ntohs(dn_saddr2dn(&scp->peer)), buf2),
+		   dn_addr2asc(le16_to_cpu(dn_saddr2dn(&scp->peer)), buf2),
 		   scp->addrrem,
 		   scp->numdat_rcv,
 		   scp->numoth_rcv,
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 28e26bd..424d86a 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -885,7 +885,7 @@ static void dn_send_endnode_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 	memcpy(msg->tiver, dn_eco_version, 3);
 	dn_dn2eth(msg->id, ifa->ifa_local);
 	msg->iinfo   = DN_RT_INFO_ENDN;
-	msg->blksize = dn_htons(mtu2blksize(dev));
+	msg->blksize = cpu_to_le16(mtu2blksize(dev));
 	msg->area    = 0x00;
 	memset(msg->seed, 0, 8);
 	memcpy(msg->neighbor, dn_hiord, ETH_ALEN);
@@ -895,13 +895,13 @@ static void dn_send_endnode_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 		dn_dn2eth(msg->neighbor, dn->addr);
 	}
 
-	msg->timer   = dn_htons((unsigned short)dn_db->parms.t3);
+	msg->timer   = cpu_to_le16((unsigned short)dn_db->parms.t3);
 	msg->mpd     = 0x00;
 	msg->datalen = 0x02;
 	memset(msg->data, 0xAA, 2);
 
 	pktlen = (__le16 *)skb_push(skb,2);
-	*pktlen = dn_htons(skb->len - 2);
+	*pktlen = cpu_to_le16(skb->len - 2);
 
 	skb_reset_network_header(skb);
 
@@ -929,7 +929,7 @@ static int dn_am_i_a_router(struct dn_neigh *dn, struct dn_dev *dn_db, struct dn
 	if (dn->priority != dn_db->parms.priority)
 		return 0;
 
-	if (dn_ntohs(dn->addr) < dn_ntohs(ifa->ifa_local))
+	if (le16_to_cpu(dn->addr) < le16_to_cpu(ifa->ifa_local))
 		return 1;
 
 	return 0;
@@ -973,11 +973,11 @@ static void dn_send_router_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 	ptr += ETH_ALEN;
 	*ptr++ = dn_db->parms.forwarding == 1 ?
 			DN_RT_INFO_L1RT : DN_RT_INFO_L2RT;
-	*((__le16 *)ptr) = dn_htons(mtu2blksize(dev));
+	*((__le16 *)ptr) = cpu_to_le16(mtu2blksize(dev));
 	ptr += 2;
 	*ptr++ = dn_db->parms.priority; /* Priority */
 	*ptr++ = 0; /* Area: Reserved */
-	*((__le16 *)ptr) = dn_htons((unsigned short)dn_db->parms.t3);
+	*((__le16 *)ptr) = cpu_to_le16((unsigned short)dn_db->parms.t3);
 	ptr += 2;
 	*ptr++ = 0; /* MPD: Reserved */
 	i1 = ptr++;
@@ -993,7 +993,7 @@ static void dn_send_router_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 	skb_trim(skb, (27 + *i2));
 
 	pktlen = (__le16 *)skb_push(skb, 2);
-	*pktlen = dn_htons(skb->len - 2);
+	*pktlen = cpu_to_le16(skb->len - 2);
 
 	skb_reset_network_header(skb);
 
@@ -1401,8 +1401,8 @@ static int dn_dev_seq_show(struct seq_file *seq, void *v)
 				mtu2blksize(dev),
 				dn_db->parms.priority,
 				dn_db->parms.state, dn_db->parms.name,
-				dn_db->router ? dn_addr2asc(dn_ntohs(*(__le16 *)dn_db->router->primary_key), router_buf) : "",
-				dn_db->peer ? dn_addr2asc(dn_ntohs(*(__le16 *)dn_db->peer->primary_key), peer_buf) : "");
+				dn_db->router ? dn_addr2asc(le16_to_cpu(*(__le16 *)dn_db->router->primary_key), router_buf) : "",
+				dn_db->peer ? dn_addr2asc(le16_to_cpu(*(__le16 *)dn_db->peer->primary_key), peer_buf) : "");
 	}
 	return 0;
 }
@@ -1445,7 +1445,7 @@ void __init dn_dev_init(void)
 		return;
 	}
 
-	decnet_address = dn_htons((addr[0] << 10) | addr[1]);
+	decnet_address = cpu_to_le16((addr[0] << 10) | addr[1]);
 
 	dn_dev_devices_on();
 
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 1ca13b1..05b5aa0 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -250,7 +250,7 @@ static int dn_long_output(struct sk_buff *skb)
 	data = skb_push(skb, sizeof(struct dn_long_packet) + 3);
 	lp = (struct dn_long_packet *)(data+3);
 
-	*((__le16 *)data) = dn_htons(skb->len - 2);
+	*((__le16 *)data) = cpu_to_le16(skb->len - 2);
 	*(data + 2) = 1 | DN_RT_F_PF; /* Padding */
 
 	lp->msgflg   = DN_RT_PKT_LONG|(cb->rt_flags&(DN_RT_F_IE|DN_RT_F_RQR|DN_RT_F_RTS));
@@ -294,7 +294,7 @@ static int dn_short_output(struct sk_buff *skb)
 	}
 
 	data = skb_push(skb, sizeof(struct dn_short_packet) + 2);
-	*((__le16 *)data) = dn_htons(skb->len - 2);
+	*((__le16 *)data) = cpu_to_le16(skb->len - 2);
 	sp = (struct dn_short_packet *)(data+2);
 
 	sp->msgflg     = DN_RT_PKT_SHORT|(cb->rt_flags&(DN_RT_F_RQR|DN_RT_F_RTS));
@@ -336,12 +336,12 @@ static int dn_phase3_output(struct sk_buff *skb)
 	}
 
 	data = skb_push(skb, sizeof(struct dn_short_packet) + 2);
-	*((__le16 *)data) = dn_htons(skb->len - 2);
+	*((__le16 *)data) = cpu_to_le16(skb->len - 2);
 	sp = (struct dn_short_packet *)(data + 2);
 
 	sp->msgflg   = DN_RT_PKT_SHORT|(cb->rt_flags&(DN_RT_F_RQR|DN_RT_F_RTS));
-	sp->dstnode  = cb->dst & dn_htons(0x03ff);
-	sp->srcnode  = cb->src & dn_htons(0x03ff);
+	sp->dstnode  = cb->dst & cpu_to_le16(0x03ff);
+	sp->srcnode  = cb->src & cpu_to_le16(0x03ff);
 	sp->forward  = cb->hops & 0x3f;
 
 	skb_reset_network_header(skb);
@@ -394,7 +394,7 @@ int dn_neigh_router_hello(struct sk_buff *skb)
 			if (neigh->dev->type == ARPHRD_ETHER)
 				memcpy(neigh->ha, &eth_hdr(skb)->h_source, ETH_ALEN);
 
-			dn->blksize  = dn_ntohs(msg->blksize);
+			dn->blksize  = le16_to_cpu(msg->blksize);
 			dn->priority = msg->priority;
 
 			dn->flags &= ~DN_NDFLAG_P3;
@@ -410,7 +410,7 @@ int dn_neigh_router_hello(struct sk_buff *skb)
 		}
 
 		/* Only use routers in our area */
-		if ((dn_ntohs(src)>>10) == (dn_ntohs((decnet_address))>>10)) {
+		if ((le16_to_cpu(src)>>10) == (le16_to_cpu((decnet_address))>>10)) {
 			if (!dn_db->router) {
 				dn_db->router = neigh_clone(neigh);
 			} else {
@@ -453,7 +453,7 @@ int dn_neigh_endnode_hello(struct sk_buff *skb)
 			if (neigh->dev->type == ARPHRD_ETHER)
 				memcpy(neigh->ha, &eth_hdr(skb)->h_source, ETH_ALEN);
 			dn->flags   &= ~(DN_NDFLAG_R1 | DN_NDFLAG_R2);
-			dn->blksize  = dn_ntohs(msg->blksize);
+			dn->blksize  = le16_to_cpu(msg->blksize);
 			dn->priority = 0;
 		}
 
@@ -543,7 +543,7 @@ static inline void dn_neigh_format_entry(struct seq_file *seq,
 
 	read_lock(&n->lock);
 	seq_printf(seq, "%-7s %s%s%s   %02x    %02d  %07ld %-8s\n",
-		   dn_addr2asc(dn_ntohs(dn->addr), buf),
+		   dn_addr2asc(le16_to_cpu(dn->addr), buf),
 		   (dn->flags&DN_NDFLAG_R1) ? "1" : "-",
 		   (dn->flags&DN_NDFLAG_R2) ? "2" : "-",
 		   (dn->flags&DN_NDFLAG_P3) ? "3" : "-",
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 4074a6e..5d8a2a5 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -83,7 +83,9 @@ static void dn_log_martian(struct sk_buff *skb, const char *msg)
 	if (decnet_log_martians && net_ratelimit()) {
 		char *devname = skb->dev ? skb->dev->name : "???";
 		struct dn_skb_cb *cb = DN_SKB_CB(skb);
-		printk(KERN_INFO "DECnet: Martian packet (%s) dev=%s src=0x%04hx dst=0x%04hx srcport=0x%04hx dstport=0x%04hx\n", msg, devname, dn_ntohs(cb->src), dn_ntohs(cb->dst), dn_ntohs(cb->src_port), dn_ntohs(cb->dst_port));
+		printk(KERN_INFO "DECnet: Martian packet (%s) dev=%s src=0x%04hx dst=0x%04hx srcport=0x%04hx dstport=0x%04hx\n",
+		       msg, devname, le16_to_cpu(cb->src), le16_to_cpu(cb->dst),
+		       le16_to_cpu(cb->src_port), le16_to_cpu(cb->dst_port));
 	}
 }
 
@@ -133,7 +135,7 @@ static int dn_process_ack(struct sock *sk, struct sk_buff *skb, int oth)
 	if (skb->len < 2)
 		return len;
 
-	if ((ack = dn_ntohs(*ptr)) & 0x8000) {
+	if ((ack = le16_to_cpu(*ptr)) & 0x8000) {
 		skb_pull(skb, 2);
 		ptr++;
 		len += 2;
@@ -147,7 +149,7 @@ static int dn_process_ack(struct sock *sk, struct sk_buff *skb, int oth)
 	if (skb->len < 2)
 		return len;
 
-	if ((ack = dn_ntohs(*ptr)) & 0x8000) {
+	if ((ack = le16_to_cpu(*ptr)) & 0x8000) {
 		skb_pull(skb, 2);
 		len += 2;
 		if ((ack & 0x4000) == 0) {
@@ -237,7 +239,7 @@ static struct sock *dn_find_listener(struct sk_buff *skb, unsigned short *reason
 	cb->dst_port = msg->dstaddr;
 	cb->services = msg->services;
 	cb->info     = msg->info;
-	cb->segsize  = dn_ntohs(msg->segsize);
+	cb->segsize  = le16_to_cpu(msg->segsize);
 
 	if (!pskb_may_pull(skb, sizeof(*msg)))
 		goto err_out;
@@ -344,7 +346,7 @@ static void dn_nsp_conn_conf(struct sock *sk, struct sk_buff *skb)
 	ptr = skb->data;
 	cb->services = *ptr++;
 	cb->info = *ptr++;
-	cb->segsize = dn_ntohs(*(__le16 *)ptr);
+	cb->segsize = le16_to_cpu(*(__le16 *)ptr);
 
 	if ((scp->state == DN_CI) || (scp->state == DN_CD)) {
 		scp->persist = 0;
@@ -361,7 +363,7 @@ static void dn_nsp_conn_conf(struct sock *sk, struct sk_buff *skb)
 		if (skb->len > 0) {
 			u16 dlen = *skb->data;
 			if ((dlen <= 16) && (dlen <= skb->len)) {
-				scp->conndata_in.opt_optl = dn_htons(dlen);
+				scp->conndata_in.opt_optl = cpu_to_le16(dlen);
 				skb_copy_from_linear_data_offset(skb, 1,
 					      scp->conndata_in.opt_data, dlen);
 			}
@@ -396,17 +398,17 @@ static void dn_nsp_disc_init(struct sock *sk, struct sk_buff *skb)
 	if (skb->len < 2)
 		goto out;
 
-	reason = dn_ntohs(*(__le16 *)skb->data);
+	reason = le16_to_cpu(*(__le16 *)skb->data);
 	skb_pull(skb, 2);
 
-	scp->discdata_in.opt_status = dn_htons(reason);
+	scp->discdata_in.opt_status = cpu_to_le16(reason);
 	scp->discdata_in.opt_optl   = 0;
 	memset(scp->discdata_in.opt_data, 0, 16);
 
 	if (skb->len > 0) {
 		u16 dlen = *skb->data;
 		if ((dlen <= 16) && (dlen <= skb->len)) {
-			scp->discdata_in.opt_optl = dn_htons(dlen);
+			scp->discdata_in.opt_optl = cpu_to_le16(dlen);
 			skb_copy_from_linear_data_offset(skb, 1, scp->discdata_in.opt_data, dlen);
 		}
 	}
@@ -463,7 +465,7 @@ static void dn_nsp_disc_conf(struct sock *sk, struct sk_buff *skb)
 	if (skb->len != 2)
 		goto out;
 
-	reason = dn_ntohs(*(__le16 *)skb->data);
+	reason = le16_to_cpu(*(__le16 *)skb->data);
 
 	sk->sk_state = TCP_CLOSE;
 
@@ -512,7 +514,7 @@ static void dn_nsp_linkservice(struct sock *sk, struct sk_buff *skb)
 	if (skb->len != 4)
 		goto out;
 
-	segnum = dn_ntohs(*(__le16 *)ptr);
+	segnum = le16_to_cpu(*(__le16 *)ptr);
 	ptr += 2;
 	lsflags = *(unsigned char *)ptr++;
 	fcval = *ptr;
@@ -620,7 +622,7 @@ static void dn_nsp_otherdata(struct sock *sk, struct sk_buff *skb)
 	if (skb->len < 2)
 		goto out;
 
-	cb->segnum = segnum = dn_ntohs(*(__le16 *)skb->data);
+	cb->segnum = segnum = le16_to_cpu(*(__le16 *)skb->data);
 	skb_pull(skb, 2);
 
 	if (seq_next(scp->numoth_rcv, segnum)) {
@@ -648,7 +650,7 @@ static void dn_nsp_data(struct sock *sk, struct sk_buff *skb)
 	if (skb->len < 2)
 		goto out;
 
-	cb->segnum = segnum = dn_ntohs(*(__le16 *)skb->data);
+	cb->segnum = segnum = le16_to_cpu(*(__le16 *)skb->data);
 	skb_pull(skb, 2);
 
 	if (seq_next(scp->numdat_rcv, segnum)) {
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 81a40ff..2013c25 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -325,8 +325,8 @@ static __le16 *dn_mk_ack_header(struct sock *sk, struct sk_buff *skb, unsigned c
 
 	ptr = (__le16 *)dn_mk_common_header(scp, skb, msgflag, hlen);
 
-	*ptr++ = dn_htons(acknum);
-	*ptr++ = dn_htons(ackcrs);
+	*ptr++ = cpu_to_le16(acknum);
+	*ptr++ = cpu_to_le16(ackcrs);
 
 	return ptr;
 }
@@ -344,7 +344,7 @@ static __le16 *dn_nsp_mk_data_header(struct sock *sk, struct sk_buff *skb, int o
 		cb->segnum = scp->numdat;
 		seq_add(&scp->numdat, 1);
 	}
-	*(ptr++) = dn_htons(cb->segnum);
+	*(ptr++) = cpu_to_le16(cb->segnum);
 
 	return ptr;
 }
@@ -522,7 +522,7 @@ void dn_send_conn_conf(struct sock *sk, gfp_t gfp)
 	struct dn_scp *scp = DN_SK(sk);
 	struct sk_buff *skb = NULL;
 	struct nsp_conn_init_msg *msg;
-	__u8 len = (__u8)dn_ntohs(scp->conndata_out.opt_optl);
+	__u8 len = (__u8)le16_to_cpu(scp->conndata_out.opt_optl);
 
 	if ((skb = dn_alloc_skb(sk, 50 + len, gfp)) == NULL)
 		return;
@@ -533,7 +533,7 @@ void dn_send_conn_conf(struct sock *sk, gfp_t gfp)
 	msg->srcaddr = scp->addrloc;
 	msg->services = scp->services_loc;
 	msg->info = scp->info_loc;
-	msg->segsize = dn_htons(scp->segsize_loc);
+	msg->segsize = cpu_to_le16(scp->segsize_loc);
 
 	*skb_put(skb,1) = len;
 
@@ -559,7 +559,7 @@ static __inline__ void dn_nsp_do_disc(struct sock *sk, unsigned char msgflg,
 
 	if ((dst == NULL) || (rem == 0)) {
 		if (net_ratelimit())
-			printk(KERN_DEBUG "DECnet: dn_nsp_do_disc: BUG! Please report this to SteveW@ACM.org rem=%u dst=%p\n", dn_ntohs(rem), dst);
+			printk(KERN_DEBUG "DECnet: dn_nsp_do_disc: BUG! Please report this to SteveW@ACM.org rem=%u dst=%p\n", le16_to_cpu(rem), dst);
 		return;
 	}
 
@@ -572,7 +572,7 @@ static __inline__ void dn_nsp_do_disc(struct sock *sk, unsigned char msgflg,
 	msg += 2;
 	*(__le16 *)msg = loc;
 	msg += 2;
-	*(__le16 *)msg = dn_htons(reason);
+	*(__le16 *)msg = cpu_to_le16(reason);
 	msg += 2;
 	if (msgflg == NSP_DISCINIT)
 		*msg++ = ddl;
@@ -598,10 +598,10 @@ void dn_nsp_send_disc(struct sock *sk, unsigned char msgflg,
 	int ddl = 0;
 
 	if (msgflg == NSP_DISCINIT)
-		ddl = dn_ntohs(scp->discdata_out.opt_optl);
+		ddl = le16_to_cpu(scp->discdata_out.opt_optl);
 
 	if (reason == 0)
-		reason = dn_ntohs(scp->discdata_out.opt_status);
+		reason = le16_to_cpu(scp->discdata_out.opt_status);
 
 	dn_nsp_do_disc(sk, msgflg, reason, gfp, sk->sk_dst_cache, ddl,
 		scp->discdata_out.opt_data, scp->addrrem, scp->addrloc);
@@ -675,7 +675,7 @@ void dn_nsp_send_conninit(struct sock *sk, unsigned char msgflg)
 	msg->srcaddr	= scp->addrloc;
 	msg->services	= scp->services_loc;	/* Requested flow control    */
 	msg->info	= scp->info_loc;	/* Version Number            */
-	msg->segsize	= dn_htons(scp->segsize_loc);	/* Max segment size  */
+	msg->segsize	= cpu_to_le16(scp->segsize_loc);	/* Max segment size  */
 
 	if (scp->peer.sdn_objnum)
 		type = 0;
@@ -708,7 +708,7 @@ void dn_nsp_send_conninit(struct sock *sk, unsigned char msgflg)
 	if (aux > 0)
 	memcpy(skb_put(skb, aux), scp->accessdata.acc_acc, aux);
 
-	aux = (__u8)dn_ntohs(scp->conndata_out.opt_optl);
+	aux = (__u8)le16_to_cpu(scp->conndata_out.opt_optl);
 	*skb_put(skb, 1) = aux;
 	if (aux > 0)
 	memcpy(skb_put(skb,aux), scp->conndata_out.opt_data, aux);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index eeaa3d8..b33b254 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -475,7 +475,7 @@ static int dn_route_rx_packet(struct sk_buff *skb)
 		printk(KERN_DEBUG
 			"DECnet: dn_route_rx_packet: rt_flags=0x%02x dev=%s len=%d src=0x%04hx dst=0x%04hx err=%d type=%d\n",
 			(int)cb->rt_flags, devname, skb->len,
-			dn_ntohs(cb->src), dn_ntohs(cb->dst),
+			le16_to_cpu(cb->src), le16_to_cpu(cb->dst),
 			err, skb->pkt_type);
 	}
 
@@ -575,7 +575,7 @@ int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type
 {
 	struct dn_skb_cb *cb;
 	unsigned char flags = 0;
-	__u16 len = dn_ntohs(*(__le16 *)skb->data);
+	__u16 len = le16_to_cpu(*(__le16 *)skb->data);
 	struct dn_dev *dn = (struct dn_dev *)dev->dn_ptr;
 	unsigned char padlen = 0;
 
@@ -773,7 +773,7 @@ static int dn_rt_bug(struct sk_buff *skb)
 		struct dn_skb_cb *cb = DN_SKB_CB(skb);
 
 		printk(KERN_DEBUG "dn_rt_bug: skb from:%04x to:%04x\n",
-				dn_ntohs(cb->src), dn_ntohs(cb->dst));
+				le16_to_cpu(cb->src), le16_to_cpu(cb->dst));
 	}
 
 	kfree_skb(skb);
@@ -816,7 +816,7 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 
 static inline int dn_match_addr(__le16 addr1, __le16 addr2)
 {
-	__u16 tmp = dn_ntohs(addr1) ^ dn_ntohs(addr2);
+	__u16 tmp = le16_to_cpu(addr1) ^ le16_to_cpu(addr2);
 	int match = 16;
 	while(tmp) {
 		tmp >>= 1;
@@ -886,8 +886,8 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *old
 	if (decnet_debug_level & 16)
 		printk(KERN_DEBUG
 		       "dn_route_output_slow: dst=%04x src=%04x mark=%d"
-		       " iif=%d oif=%d\n", dn_ntohs(oldflp->fld_dst),
-		       dn_ntohs(oldflp->fld_src),
+		       " iif=%d oif=%d\n", le16_to_cpu(oldflp->fld_dst),
+		       le16_to_cpu(oldflp->fld_src),
 		       oldflp->mark, init_net.loopback_dev->ifindex, oldflp->oif);
 
 	/* If we have an output interface, verify its a DECnet device */
@@ -959,7 +959,7 @@ source_ok:
 		printk(KERN_DEBUG
 		       "dn_route_output_slow: initial checks complete."
 		       " dst=%o4x src=%04x oif=%d try_hard=%d\n",
-		       dn_ntohs(fl.fld_dst), dn_ntohs(fl.fld_src),
+		       le16_to_cpu(fl.fld_dst), le16_to_cpu(fl.fld_src),
 		       fl.oif, try_hard);
 
 	/*
@@ -1711,8 +1711,8 @@ static int dn_rt_cache_seq_show(struct seq_file *seq, void *v)
 
 	seq_printf(seq, "%-8s %-7s %-7s %04d %04d %04d\n",
 			rt->u.dst.dev ? rt->u.dst.dev->name : "*",
-			dn_addr2asc(dn_ntohs(rt->rt_daddr), buf1),
-			dn_addr2asc(dn_ntohs(rt->rt_saddr), buf2),
+			dn_addr2asc(le16_to_cpu(rt->rt_daddr), buf1),
+			dn_addr2asc(le16_to_cpu(rt->rt_saddr), buf2),
 			atomic_read(&rt->u.dst.__refcnt),
 			rt->u.dst.__use,
 			(int) dst_metric(&rt->u.dst, RTAX_RTT));
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 3a2830a..69ad928 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -85,7 +85,7 @@ static int dn_fib_hash_zombies;
 
 static inline dn_fib_idx_t dn_hash(dn_fib_key_t key, struct dn_zone *dz)
 {
-	u16 h = dn_ntohs(key.datum)>>(16 - dz->dz_order);
+	u16 h = le16_to_cpu(key.datum)>>(16 - dz->dz_order);
 	h ^= (h >> 10);
 	h ^= (h >> 6);
 	h &= DZ_HASHMASK(dz);
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index 2f360a1..965397a 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -126,7 +126,7 @@ static int parse_addr(__le16 *addr, char *str)
 	if (INVALID_END_CHAR(*str))
 		return -1;
 
-	*addr = dn_htons((area << 10) | node);
+	*addr = cpu_to_le16((area << 10) | node);
 
 	return 0;
 }
@@ -201,7 +201,7 @@ static int dn_node_address_handler(ctl_table *table, int write,
 		return 0;
 	}
 
-	dn_addr2asc(dn_ntohs(decnet_address), addr);
+	dn_addr2asc(le16_to_cpu(decnet_address), addr);
 	len = strlen(addr);
 	addr[len++] = '\n';
 
-- 
1.6.0.4.1044.g77718

