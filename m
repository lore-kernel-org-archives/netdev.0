From: Joe Perches <joe@perches.com>
Subject: [PATCH] net: Remove casts to same type
Date: Sun,  3 Jun 2012 20:41:40 -0700
Message-ID: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33157 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755748Ab2FDDln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2012 23:41:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding casts of objects to the same type is unnecessary
and confusing for a human reader.

For example, this cast:

	int y;
	int *p = (int *)&y;

I used the coccinelle script below to find and remove these
unnecessary casts.  I manually removed the conversions this
script produces of casts with __force and __user.

@@
type T;
T *p;
@@

-	(T *)p
+	p

Signed-off-by: Joe Perches <joe@perches.com>
---

Let me know if this needs to be broken up by maintainer.

 net/9p/client.c                        |    2 +-
 net/atm/lec.c                          |    2 +-
 net/decnet/dn_nsp_out.c                |    2 +-
 net/ipv4/af_inet.c                     |    2 +-
 net/ipv4/fib_trie.c                    |   13 ++++++-------
 net/ipv4/netfilter/nf_nat_snmp_basic.c |    4 ++--
 net/ipv6/exthdrs.c                     |    4 ++--
 net/irda/irqueue.c                     |    6 +++---
 net/l2tp/l2tp_ppp.c                    |    8 ++++----
 net/mac80211/scan.c                    |    3 +--
 net/netfilter/nf_conntrack_core.c      |    2 +-
 net/packet/af_packet.c                 |    9 ++++-----
 net/tipc/port.c                        |    9 ++++-----
 net/tipc/socket.c                      |    2 +-
 14 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index a170893..5cbea90 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -1548,7 +1548,7 @@ p9_client_read(struct p9_fid *fid, char *data, char __user *udata, u64 offset,
 			kernel_buf = 1;
 			indata = data;
 		} else
-			indata = (char *)udata;
+			indata = udata;
 		/*
 		 * response header len is 11
 		 * PDU Header(7) + IO Size (4)
diff --git a/net/atm/lec.c b/net/atm/lec.c
index a7d1721..cbe1ebc 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1602,7 +1602,7 @@ static void lec_arp_expire_vcc(unsigned long data)
 {
 	unsigned long flags;
 	struct lec_arp_table *to_remove = (struct lec_arp_table *)data;
-	struct lec_priv *priv = (struct lec_priv *)to_remove->priv;
+	struct lec_priv *priv = to_remove->priv;
 
 	del_timer(&to_remove->timer);
 
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 564a6ad..8a96047c 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -322,7 +322,7 @@ static __le16 *dn_mk_ack_header(struct sock *sk, struct sk_buff *skb, unsigned c
 	/* Set "cross subchannel" bit in ackcrs */
 	ackcrs |= 0x2000;
 
-	ptr = (__le16 *)dn_mk_common_header(scp, skb, msgflag, hlen);
+	ptr = dn_mk_common_header(scp, skb, msgflag, hlen);
 
 	*ptr++ = cpu_to_le16(acknum);
 	*ptr++ = cpu_to_le16(ackcrs);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c8f7aee..e4e8e00 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -553,7 +553,7 @@ int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
 
 	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
 		return -EAGAIN;
-	return sk->sk_prot->connect(sk, (struct sockaddr *)uaddr, addr_len);
+	return sk->sk_prot->connect(sk, uaddr, addr_len);
 }
 EXPORT_SYMBOL(inet_dgram_connect);
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 30b88d7..18cbc15 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1007,9 +1007,9 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 	while (tn != NULL && (tp = node_parent((struct rt_trie_node *)tn)) != NULL) {
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
 		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
-		tn = (struct tnode *) resize(t, (struct tnode *)tn);
+		tn = (struct tnode *)resize(t, tn);
 
-		tnode_put_child_reorg((struct tnode *)tp, cindex,
+		tnode_put_child_reorg(tp, cindex,
 				      (struct rt_trie_node *)tn, wasfull);
 
 		tp = node_parent((struct rt_trie_node *) tn);
@@ -1024,7 +1024,7 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 
 	/* Handle last (top) tnode */
 	if (IS_TNODE(tn))
-		tn = (struct tnode *)resize(t, (struct tnode *)tn);
+		tn = (struct tnode *)resize(t, tn);
 
 	rcu_assign_pointer(t->trie, (struct rt_trie_node *)tn);
 	tnode_free_flush();
@@ -1125,7 +1125,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		node_set_parent((struct rt_trie_node *)l, tp);
 
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
-		put_child(t, (struct tnode *)tp, cindex, (struct rt_trie_node *)l);
+		put_child(t, tp, cindex, (struct rt_trie_node *)l);
 	} else {
 		/* Case 3: n is a LEAF or a TNODE and the key doesn't match. */
 		/*
@@ -1160,8 +1160,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 
 		if (tp) {
 			cindex = tkey_extract_bits(key, tp->pos, tp->bits);
-			put_child(t, (struct tnode *)tp, cindex,
-				  (struct rt_trie_node *)tn);
+			put_child(t, tp, cindex, (struct rt_trie_node *)tn);
 		} else {
 			rcu_assign_pointer(t->trie, (struct rt_trie_node *)tn);
 			tp = tn;
@@ -1620,7 +1619,7 @@ static void trie_leaf_remove(struct trie *t, struct leaf *l)
 
 	if (tp) {
 		t_key cindex = tkey_extract_bits(l->key, tp->pos, tp->bits);
-		put_child(t, (struct tnode *)tp, cindex, NULL);
+		put_child(t, tp, cindex, NULL);
 		trie_rebalance(t, tp);
 	} else
 		RCU_INIT_POINTER(t->trie, NULL);
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 746edec..bac7122 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -405,7 +405,7 @@ static unsigned char asn1_octets_decode(struct asn1_ctx *ctx,
 
 	ptr = *octets;
 	while (ctx->pointer < eoc) {
-		if (!asn1_octet_decode(ctx, (unsigned char *)ptr++)) {
+		if (!asn1_octet_decode(ctx, ptr++)) {
 			kfree(*octets);
 			*octets = NULL;
 			return 0;
@@ -759,7 +759,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 		}
 		break;
 	case SNMP_OBJECTID:
-		if (!asn1_oid_decode(ctx, end, (unsigned long **)&lp, &len)) {
+		if (!asn1_oid_decode(ctx, end, &lp, &len)) {
 			kfree(id);
 			return 0;
 		}
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 6447dc4..fa3d9c3 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -791,14 +791,14 @@ static int ipv6_renew_option(void *ohdr,
 		if (ohdr) {
 			memcpy(*p, ohdr, ipv6_optlen((struct ipv6_opt_hdr *)ohdr));
 			*hdr = (struct ipv6_opt_hdr *)*p;
-			*p += CMSG_ALIGN(ipv6_optlen(*(struct ipv6_opt_hdr **)hdr));
+			*p += CMSG_ALIGN(ipv6_optlen(*hdr));
 		}
 	} else {
 		if (newopt) {
 			if (copy_from_user(*p, newopt, newoptlen))
 				return -EFAULT;
 			*hdr = (struct ipv6_opt_hdr *)*p;
-			if (ipv6_optlen(*(struct ipv6_opt_hdr **)hdr) > newoptlen)
+			if (ipv6_optlen(*hdr) > newoptlen)
 				return -EINVAL;
 			*p += CMSG_ALIGN(newoptlen);
 		}
diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
index f06947c..7152624 100644
--- a/net/irda/irqueue.c
+++ b/net/irda/irqueue.c
@@ -523,7 +523,7 @@ void *hashbin_remove_first( hashbin_t *hashbin)
 		 * Dequeue the entry...
 		 */
 		dequeue_general( (irda_queue_t**) &hashbin->hb_queue[ bin ],
-				 (irda_queue_t*) entry );
+				 entry);
 		hashbin->hb_size--;
 		entry->q_next = NULL;
 		entry->q_prev = NULL;
@@ -615,7 +615,7 @@ void* hashbin_remove( hashbin_t* hashbin, long hashv, const char* name)
 	 */
 	if ( found ) {
 		dequeue_general( (irda_queue_t**) &hashbin->hb_queue[ bin ],
-				 (irda_queue_t*) entry );
+				 entry);
 		hashbin->hb_size--;
 
 		/*
@@ -685,7 +685,7 @@ void* hashbin_remove_this( hashbin_t* hashbin, irda_queue_t* entry)
 	 * Dequeue the entry...
 	 */
 	dequeue_general( (irda_queue_t**) &hashbin->hb_queue[ bin ],
-			 (irda_queue_t*) entry );
+			 entry);
 	hashbin->hb_size--;
 	entry->q_next = NULL;
 	entry->q_prev = NULL;
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 8ef6b94..286366e 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1522,8 +1522,8 @@ static int pppol2tp_session_getsockopt(struct sock *sk,
  * handler, according to whether the PPPoX socket is a for a regular session
  * or the special tunnel type.
  */
-static int pppol2tp_getsockopt(struct socket *sock, int level,
-			       int optname, char __user *optval, int __user *optlen)
+static int pppol2tp_getsockopt(struct socket *sock, int level, int optname,
+			       char __user *optval, int __user *optlen)
 {
 	struct sock *sk = sock->sk;
 	struct l2tp_session *session;
@@ -1535,7 +1535,7 @@ static int pppol2tp_getsockopt(struct socket *sock, int level,
 	if (level != SOL_PPPOL2TP)
 		return udp_prot.getsockopt(sk, level, optname, optval, optlen);
 
-	if (get_user(len, (int __user *) optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
 
 	len = min_t(unsigned int, len, sizeof(int));
@@ -1568,7 +1568,7 @@ static int pppol2tp_getsockopt(struct socket *sock, int level,
 		err = pppol2tp_session_getsockopt(sk, session, optname, &val);
 
 	err = -EFAULT;
-	if (put_user(len, (int __user *) optlen))
+	if (put_user(len, optlen))
 		goto end_put_sess;
 
 	if (copy_to_user((void __user *) optval, &val, len))
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 169da07..6d90a56 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -114,8 +114,7 @@ ieee80211_bss_info_update(struct ieee80211_local *local,
 
 	if (elems->tim && (!elems->parse_error ||
 			   !(bss->valid_data & IEEE80211_BSS_VALID_DTIM))) {
-		struct ieee80211_tim_ie *tim_ie =
-			(struct ieee80211_tim_ie *)elems->tim;
+		struct ieee80211_tim_ie *tim_ie = elems->tim;
 		bss->dtim_period = tim_ie->dtim_period;
 		if (!elems->parse_error)
 				bss->valid_data |= IEEE80211_BSS_VALID_DTIM;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ac3af97..95976a5 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -531,7 +531,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	tstamp = nf_conn_tstamp_find(ct);
 	if (tstamp) {
 		if (skb->tstamp.tv64 == 0)
-			__net_timestamp((struct sk_buff *)skb);
+			__net_timestamp(skb);
 
 		tstamp->start = ktime_to_ns(skb->tstamp);
 	}
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0f66174..71ac655 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -592,7 +592,7 @@ static void init_prb_bdqc(struct packet_sock *po,
 	p1->knxt_seq_num = 1;
 	p1->pkbdq = pg_vec;
 	pbd = (struct tpacket_block_desc *)pg_vec[0].buffer;
-	p1->pkblk_start	= (char *)pg_vec[0].buffer;
+	p1->pkblk_start	= pg_vec[0].buffer;
 	p1->kblk_size = req_u->req3.tp_block_size;
 	p1->knum_blocks	= req_u->req3.tp_block_nr;
 	p1->hdrlen = po->tp_hdrlen;
@@ -824,8 +824,7 @@ static void prb_open_block(struct tpacket_kbdq_core *pkc1,
 		h1->ts_first_pkt.ts_sec = ts.tv_sec;
 		h1->ts_first_pkt.ts_nsec = ts.tv_nsec;
 		pkc1->pkblk_start = (char *)pbd1;
-		pkc1->nxt_offset = (char *)(pkc1->pkblk_start +
-		BLK_PLUS_PRIV(pkc1->blk_sizeof_priv));
+		pkc1->nxt_offset = pkc1->pkblk_start + BLK_PLUS_PRIV(pkc1->blk_sizeof_priv);
 		BLOCK_O2FP(pbd1) = (__u32)BLK_PLUS_PRIV(pkc1->blk_sizeof_priv);
 		BLOCK_O2PRIV(pbd1) = BLK_HDR_LEN;
 		pbd1->version = pkc1->version;
@@ -1018,7 +1017,7 @@ static void *__packet_lookup_frame_in_block(struct packet_sock *po,
 	struct tpacket_block_desc *pbd;
 	char *curr, *end;
 
-	pkc = GET_PBDQC_FROM_RB(((struct packet_ring_buffer *)&po->rx_ring));
+	pkc = GET_PBDQC_FROM_RB(&po->rx_ring);
 	pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
 
 	/* Queue is frozen when user space is lagging behind */
@@ -1044,7 +1043,7 @@ static void *__packet_lookup_frame_in_block(struct packet_sock *po,
 	smp_mb();
 	curr = pkc->nxt_offset;
 	pkc->skb = skb;
-	end = (char *) ((char *)pbd + pkc->kblk_size);
+	end = (char *)pbd + pkc->kblk_size;
 
 	/* first try the current block */
 	if (curr+TOTAL_PKT_LEN_INCL_ALIGN(len) < end) {
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 2ad37a4..a1e8289 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -909,8 +909,8 @@ int tipc_createport(void *usr_handle,
 		warn("Port creation failed, no memory\n");
 		return -ENOMEM;
 	}
-	p_ptr = (struct tipc_port *)tipc_createport_raw(NULL, port_dispatcher,
-						   port_wakeup, importance);
+	p_ptr = tipc_createport_raw(NULL, port_dispatcher, port_wakeup,
+				    importance);
 	if (!p_ptr) {
 		kfree(up_ptr);
 		return -ENOMEM;
@@ -1078,8 +1078,7 @@ int tipc_disconnect_port(struct tipc_port *tp_ptr)
 	if (tp_ptr->connected) {
 		tp_ptr->connected = 0;
 		/* let timer expire on it's own to avoid deadlock! */
-		tipc_nodesub_unsubscribe(
-			&((struct tipc_port *)tp_ptr)->subscription);
+		tipc_nodesub_unsubscribe(&tp_ptr->subscription);
 		res = 0;
 	} else {
 		res = -ENOTCONN;
@@ -1099,7 +1098,7 @@ int tipc_disconnect(u32 ref)
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	res = tipc_disconnect_port((struct tipc_port *)p_ptr);
+	res = tipc_disconnect_port(p_ptr);
 	tipc_port_unlock(p_ptr);
 	return res;
 }
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 5577a44..11a863d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -54,7 +54,7 @@ struct tipc_sock {
 };
 
 #define tipc_sk(sk) ((struct tipc_sock *)(sk))
-#define tipc_sk_port(sk) ((struct tipc_port *)(tipc_sk(sk)->p))
+#define tipc_sk_port(sk) (tipc_sk(sk)->p)
 
 #define tipc_rx_ready(sock) (!skb_queue_empty(&sock->sk->sk_receive_queue) || \
 			(sock->state == SS_DISCONNECTING))
-- 
1.7.8.111.gad25c.dirty
