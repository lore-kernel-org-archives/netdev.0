From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [RFC] IPSEC failover and replay detection sequence numbers
Date: Fri, 29 Oct 2004 12:23:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099045435.2888.47.camel@nienna.balabit>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-+wYg4lem0EGz4c5sfVBn"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net,
        vpn-failover@lists.balabit.hu
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-+wYg4lem0EGz4c5sfVBn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


  Hi,

  While developing an IPSEC failover solution we came to a problem of
replay detection sequence numbers used by IPSEC ESP and AH. To be able
to keep IPSEC SAs alive after a failing over to a slave, the state of
the SAs has to be available on the slave node(s) as well. Except for the
sequence numbers this is not really a problem, since the state of an
already established SA does not change too often.

  However, currently getting or setting the replay detection state of an
SA is not possible. Unfortunately the ability to get/set the replay
detection sequence number is not enough, it would be great if the key
management daemon could get state change notifications in certain cases.

  The attached patch is an implementation of the concept, and consists
of the following parts:

      * xfrm_state replay detection notification facility: calls the
        registered callback functions if:
              * the input/output sequence number is at least the value
                sent in the last notification plus N
              * at least T jiffies has elapsed since the last
                notification and the sequence numbers have changed since
                then
      * the PFKEY implementation of the callback: sends notify pfkey
        messages (new message type)
      * the PFKEY extensions needed to get/set the parameters of the
        notification messages (N and T) (new extension header)
      * a new PFKEY message to explicitly set the replay detection state
        of an already established SA (new message type)

  As there are a couple of PFKEY changes which could possibly break
compatibility, I tried to implement these extensions so that they are
completely invisible unless the user-space explicitly requests
notifications to be sent. Both N and T parameters of a new SA default to
zero, and notification-related extension headers are sent only if these
were explicitly set to a non-zero value.

  The xfrm-netlink parts are completely missing, but could be added
easily. The corresponding libipsec changes should be trivial as well.

  Comments are welcome, especially since this is the first public
release of the patch and I'm not much of an xfrm/pfkey expert... :)

-- 
 Regards,
   Krisztian KOVACS

--=-+wYg4lem0EGz4c5sfVBn
Content-Disposition: attachment; filename=ipsec_rd_notify_200410251031.patch
Content-Type: text/x-patch; name=ipsec_rd_notify_200410251031.patch; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit

Index: linux-2.6.9/include/linux/pfkeyv2.h
===================================================================
--- linux-2.6.9.orig/include/linux/pfkeyv2.h	2004-10-18 23:54:55.000000000 +0200
+++ linux-2.6.9/include/linux/pfkeyv2.h	2004-10-29 11:12:48.653359687 +0200
@@ -216,6 +216,25 @@
 } __attribute__((packed));
 /* sizeof(struct sadb_x_nat_t_port) == 8 */
 
+/* IPSEC failover support sequence number update notification */
+struct sadb_x_saseq {
+	uint16_t	sadb_x_saseq_len;
+	uint16_t	sadb_x_saseq_exttype;
+	uint32_t	sadb_x_saseq_iseq;
+	uint32_t	sadb_x_saseq_iwnd;
+	uint32_t	sadb_x_saseq_oseq;
+} __attribute__((packed));
+/* sizeof(struct sadb_x_saseq) == 16 */
+
+struct sadb_x_saseq_notify {
+	uint16_t	sadb_x_saseq_notify_len;
+	uint16_t	sadb_x_saseq_notify_exttype;
+	uint32_t	sadb_x_saseq_notify_maxdiff;
+	uint32_t	sadb_x_saseq_notify_maxage;
+	uint32_t	sadb_x_saseq_notify_reserved;
+} __attribute__((packed));
+/* sizeof(struct sadb_x_saseq_notify) == 16 */
+
 /* Message types */
 #define SADB_RESERVED		0
 #define SADB_GETSPI		1
@@ -241,7 +260,9 @@
 #define SADB_X_SPDEXPIRE	21
 #define SADB_X_SPDDELETE2	22
 #define SADB_X_NAT_T_NEW_MAPPING	23
-#define SADB_MAX		23
+#define SADB_X_SEQNO_NOTIFY	24
+#define SADB_X_SEQNO_UPDATE	25
+#define SADB_MAX		25
 
 /* Security Association flags */
 #define SADB_SAFLAGS_PFS	1
@@ -324,7 +345,10 @@
 #define SADB_X_EXT_NAT_T_SPORT		21
 #define SADB_X_EXT_NAT_T_DPORT		22
 #define SADB_X_EXT_NAT_T_OA		23
-#define SADB_EXT_MAX			23
+/* The next two entries are for IPSEC failover sequence number update notifications */
+#define SADB_X_EXT_SASEQ		24
+#define SADB_X_EXT_SASEQ_NOTIFY		25
+#define SADB_EXT_MAX			25
 
 /* Identity Extension values */
 #define SADB_IDENTTYPE_RESERVED	0
Index: linux-2.6.9/include/net/xfrm.h
===================================================================
--- linux-2.6.9.orig/include/net/xfrm.h	2004-10-18 23:54:55.000000000 +0200
+++ linux-2.6.9/include/net/xfrm.h	2004-10-29 11:12:48.654359460 +0200
@@ -133,6 +133,16 @@
 	/* State for replay detection */
 	struct xfrm_replay_state replay;
 
+	/* Replay detection state at the time we sent the last notification */
+	struct xfrm_replay_state preplay;
+
+	/* Replay detection notification settings */
+	__u64			replay_maxage;
+	__u32			replay_maxdiff;
+
+	/* Replay detection notification timer */
+	struct timer_list	rtimer;
+
 	/* Statistics */
 	struct xfrm_stats	stats;
 
@@ -287,6 +297,15 @@
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
 
+/* which seqno */
+#define XFRM_REPLAY_SEQ		1
+#define XFRM_REPLAY_OSEQ	2
+#define XFRM_REPLAY_SEQ_MASK	3
+/* what happened */
+#define XFRM_REPLAY_UPDATE	4
+#define XFRM_REPLAY_TIMEOUT	8
+#define XFRM_REPLAY_ACTION_MASK	12
+
 #define XFRM_KM_TIMEOUT		30
 
 struct xfrm_mgr
@@ -298,6 +317,7 @@
 	struct xfrm_policy	*(*compile_policy)(u16 family, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, int event);
+	int			(*notify_seq)(struct xfrm_state *x, int event);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -812,6 +832,8 @@
 extern void xfrm_state_flush(u8 proto);
 extern int xfrm_replay_check(struct xfrm_state *x, u32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, u32 seq);
+extern void xfrm_replay_notify(struct xfrm_state *x, int event);
+extern void xfrm_state_replay_update(struct xfrm_state *x, struct xfrm_replay_state *replay);
 extern int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl);
 extern int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv(struct sk_buff *skb);
Index: linux-2.6.9/net/ipv4/ah4.c
===================================================================
--- linux-2.6.9.orig/net/ipv4/ah4.c	2004-10-18 23:55:06.000000000 +0200
+++ linux-2.6.9/net/ipv4/ah4.c	2004-10-29 11:14:00.700963876 +0200
@@ -98,6 +98,7 @@
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
+	xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 	ahp->icv(ahp, skb, ah->auth_data);
 
 	top_iph->tos = iph->tos;
Index: linux-2.6.9/net/ipv4/esp4.c
===================================================================
--- linux-2.6.9.orig/net/ipv4/esp4.c	2004-10-18 23:54:32.000000000 +0200
+++ linux-2.6.9/net/ipv4/esp4.c	2004-10-29 11:12:48.656359005 +0200
@@ -98,6 +98,8 @@
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);
 
+	xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+
 	if (esp->conf.ivlen)
 		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
 
Index: linux-2.6.9/net/ipv6/ah6.c
===================================================================
--- linux-2.6.9.orig/net/ipv6/ah6.c	2004-10-18 23:54:39.000000000 +0200
+++ linux-2.6.9/net/ipv6/ah6.c	2004-10-29 11:14:23.076870730 +0200
@@ -214,6 +214,7 @@
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
+	xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 	ahp->icv(ahp, skb, ah->auth_data);
 
 	err = 0;
Index: linux-2.6.9/net/ipv6/esp6.c
===================================================================
--- linux-2.6.9.orig/net/ipv6/esp6.c	2004-10-18 23:54:37.000000000 +0200
+++ linux-2.6.9/net/ipv6/esp6.c	2004-10-29 11:12:48.658358550 +0200
@@ -95,6 +95,8 @@
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);
 
+	xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+	
 	if (esp->conf.ivlen)
 		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
 
Index: linux-2.6.9/net/key/af_key.c
===================================================================
--- linux-2.6.9.orig/net/key/af_key.c	2004-10-18 23:55:36.000000000 +0200
+++ linux-2.6.9/net/key/af_key.c	2004-10-29 11:12:48.662357640 +0200
@@ -336,6 +336,7 @@
 	[SADB_X_EXT_NAT_T_SPORT]	= (u8) sizeof(struct sadb_x_nat_t_port),
 	[SADB_X_EXT_NAT_T_DPORT]	= (u8) sizeof(struct sadb_x_nat_t_port),
 	[SADB_X_EXT_NAT_T_OA]		= (u8) sizeof(struct sadb_address),
+	[SADB_X_EXT_SASEQ_NOTIFY]	= (u8) sizeof(struct sadb_x_saseq_notify),
 };
 
 /* Verify sadb_address_{len,prefixlen} against sa_family.  */
@@ -606,9 +607,9 @@
 		sizeof(struct sadb_lifetime) +
 		((hsc & 1) ? sizeof(struct sadb_lifetime) : 0) +
 		((hsc & 2) ? sizeof(struct sadb_lifetime) : 0) +
-			sizeof(struct sadb_address)*2 + 
-				sockaddr_size*2 +
-					sizeof(struct sadb_x_sa2);
+		sizeof(struct sadb_address)*2 + 
+		sockaddr_size*2 +
+		sizeof(struct sadb_x_sa2);
 	/* identity & sensitivity */
 
 	if ((x->props.family == AF_INET &&
@@ -641,6 +642,9 @@
 		size += sizeof(struct sadb_x_nat_t_port);
 	}
 
+	if (x->replay_maxage || x->replay_maxdiff)
+		size += sizeof(struct sadb_x_saseq_notify);
+
 	skb =  alloc_skb(size + 16, GFP_ATOMIC);
 	if (skb == NULL)
 		return ERR_PTR(-ENOBUFS);
@@ -892,6 +896,17 @@
 		n_port->sadb_x_nat_t_port_reserved = 0;
 	}
 
+	if (x->replay_maxage || x->replay_maxdiff) {
+		struct sadb_x_saseq_notify *seqn;
+
+		seqn = (struct sadb_x_saseq_notify *) skb_put(skb, sizeof (*seqn));
+		seqn->sadb_x_saseq_notify_len = sizeof(*seqn)/sizeof(uint64_t);
+		seqn->sadb_x_saseq_notify_exttype = SADB_X_EXT_SASEQ_NOTIFY;
+		seqn->sadb_x_saseq_notify_maxage = x->replay_maxage * 10 / HZ;
+		seqn->sadb_x_saseq_notify_maxdiff = x->replay_maxdiff;
+		seqn->sadb_x_saseq_notify_reserved = 0;
+	}
+
 	return skb;
 }
 
@@ -1091,6 +1106,13 @@
 		}
 	}
 
+	if (ext_hdrs[SADB_X_EXT_SASEQ_NOTIFY-1]) {
+		struct sadb_x_saseq_notify *seqn = ext_hdrs[SADB_X_EXT_SASEQ_NOTIFY-1];
+
+		x->replay_maxage = seqn->sadb_x_saseq_notify_maxage * HZ / 10;
+		x->replay_maxdiff = seqn->sadb_x_saseq_notify_maxdiff;
+	}
+
 	x->type = xfrm_get_type(proto, x->props.family);
 	if (x->type == NULL) {
 		err = -ENOPROTOOPT;
@@ -2122,6 +2144,52 @@
 	return 0;
 }
 
+static int pfkey_seqno_update(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
+{
+	struct xfrm_state *x;
+	struct sadb_x_saseq *seq;
+	struct xfrm_replay_state replay;
+	struct sk_buff *skb_out;
+	struct sadb_msg *hdr_out;
+
+	if (!ext_hdrs[SADB_EXT_SA-1] ||
+	    !present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
+				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]))
+		return -EINVAL;
+
+	x = pfkey_xfrm_state_lookup(hdr, ext_hdrs);
+	if (x == NULL)
+		return -ESRCH;
+
+	seq = ext_hdrs[SADB_X_EXT_SASEQ-1];
+	if (!seq) {
+		xfrm_state_put(x);
+		return -EINVAL;
+	}
+
+	skb_out = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_KERNEL);
+	if (!skb_out) {
+		xfrm_state_put(x);
+		return -ENOBUFS;
+	}
+
+	replay.seq = seq->sadb_x_saseq_iseq;
+	replay.bitmap = seq->sadb_x_saseq_iwnd;
+	replay.oseq = seq->sadb_x_saseq_oseq;
+
+	xfrm_state_replay_update(x, &replay);
+	xfrm_state_put(x);
+
+	hdr_out = (struct sadb_msg *) skb_put(skb_out, sizeof(struct sadb_msg));
+	pfkey_hdr_dup(hdr_out, hdr);
+	hdr_out->sadb_msg_errno = (uint8_t) 0;
+	hdr_out->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
+
+	pfkey_broadcast(skb_out, GFP_KERNEL, BROADCAST_ALL, sk);
+
+	return 0;
+}
+
 typedef int (*pfkey_handler)(struct sock *sk, struct sk_buff *skb,
 			     struct sadb_msg *hdr, void **ext_hdrs);
 static pfkey_handler pfkey_funcs[SADB_MAX + 1] = {
@@ -2147,6 +2215,7 @@
 	[SADB_X_SPDFLUSH]	= pfkey_spdflush,
 	[SADB_X_SPDSETIDX]	= pfkey_spdadd,
 	[SADB_X_SPDDELETE2]	= pfkey_spdget,
+	[SADB_X_SEQNO_UPDATE]	= pfkey_seqno_update,
 };
 
 static int pfkey_process(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr)
@@ -2688,6 +2757,134 @@
 	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL);
 }
 
+static int pfkey_send_replay_notify(struct xfrm_state *x, int event)
+{
+	struct sk_buff *skb;
+	struct sadb_msg *hdr;
+	struct sadb_sa *sa;
+	struct sadb_address *addr;
+	struct sockaddr_in *sin;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct sockaddr_in6 *sin6;
+#endif
+	struct sadb_x_saseq *seq;
+	int sockaddr_size;
+	int size;
+	__u8 satype = (x->id.proto == IPPROTO_ESP ? SADB_SATYPE_ESP : 0);
+
+	sockaddr_size = pfkey_sockaddr_size(x->props.family);
+	if (!sockaddr_size)
+		return -EINVAL;
+
+	if (!satype)
+		return -EINVAL;
+
+	size = sizeof(struct sadb_msg) +
+		sizeof(struct sadb_sa) +
+		sizeof(struct sadb_address) * 2 +
+		sockaddr_size * 2 +
+		sizeof(struct sadb_x_saseq);
+
+	skb = alloc_skb(size + 16, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	hdr->sadb_msg_version = PF_KEY_V2;
+	hdr->sadb_msg_type = SADB_X_SEQNO_NOTIFY;
+	hdr->sadb_msg_satype = satype;
+	hdr->sadb_msg_len = size / sizeof(uint64_t);
+	hdr->sadb_msg_errno = 0;
+	hdr->sadb_msg_reserved = 0;
+	hdr->sadb_msg_seq = x->km.seq;
+	hdr->sadb_msg_pid = 0;
+
+	/* SA */
+	sa = (struct sadb_sa *) skb_put(skb, sizeof(struct sadb_sa));
+	sa->sadb_sa_len = sizeof(struct sadb_sa)/sizeof(uint64_t);
+	sa->sadb_sa_exttype = SADB_EXT_SA;
+	sa->sadb_sa_spi = x->id.spi;
+	sa->sadb_sa_replay = x->props.replay_window;
+	sa->sadb_sa_state = 0;
+	sa->sadb_sa_auth = 0;
+	sa->sadb_sa_encrypt = 0;
+	sa->sadb_sa_flags = 0;
+
+	/* src address */
+	addr = (struct sadb_address *) skb_put(skb,
+			sizeof(struct sadb_address) + sockaddr_size);
+	addr->sadb_address_len = 
+		(sizeof(struct sadb_address) + sockaddr_size) / sizeof(uint64_t);
+	addr->sadb_address_exttype = SADB_EXT_ADDRESS_SRC;
+	addr->sadb_address_proto = 0;
+	addr->sadb_address_reserved = 0;
+	if (x->props.family == AF_INET) {
+		addr->sadb_address_prefixlen = 32;
+		sin = (struct sockaddr_in *) (addr + 1);
+		sin->sin_family = AF_INET;
+		sin->sin_addr.s_addr = x->props.saddr.a4;
+		sin->sin_port = 0;
+		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	else if (x->props.family == AF_INET6) {
+ 		addr->sadb_address_prefixlen = 128;
+
+		sin6 = (struct sockaddr_in6 *) (addr + 1);
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_port = 0;
+		sin6->sin6_flowinfo = 0;
+ 		memcpy(&sin6->sin6_addr, x->props.saddr.a6,
+		       sizeof(struct in6_addr));
+		sin6->sin6_scope_id = 0;
+ 	}
+#endif
+	else
+		BUG();
+
+	/* dst address */
+	addr = (struct sadb_address *) skb_put(skb,
+			sizeof(struct sadb_address) + sockaddr_size);
+	addr->sadb_address_len = 
+		(sizeof(struct sadb_address) + sockaddr_size) / sizeof(uint64_t);
+	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
+	addr->sadb_address_proto = 0;
+	addr->sadb_address_reserved = 0;
+	if (x->props.family == AF_INET) {
+		addr->sadb_address_prefixlen = 32;
+		sin = (struct sockaddr_in *) (addr + 1);
+		sin->sin_family = AF_INET;
+		sin->sin_addr.s_addr = x->id.daddr.a4;
+		sin->sin_port = 0;
+		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	else if (x->props.family == AF_INET6) {
+ 		addr->sadb_address_prefixlen = 128;
+
+		sin6 = (struct sockaddr_in6 *) (addr + 1);
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_port = 0;
+		sin6->sin6_flowinfo = 0;
+ 		memcpy(&sin6->sin6_addr, x->id.daddr.a6,
+		       sizeof(struct in6_addr));
+		sin6->sin6_scope_id = 0;
+ 	}
+#endif
+	else
+		BUG();
+
+	/* replay detection sequence numbers */
+	seq = (struct sadb_x_saseq*) skb_put(skb, sizeof(*seq));
+	seq->sadb_x_saseq_len = sizeof(*seq)/sizeof(uint64_t);
+	seq->sadb_x_saseq_exttype = SADB_X_EXT_SASEQ;
+	seq->sadb_x_saseq_iseq = x->replay.seq;
+	seq->sadb_x_saseq_iwnd = x->replay.bitmap;
+	seq->sadb_x_saseq_oseq = x->replay.oseq;
+
+	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL);
+}
+
 static int pfkey_sendmsg(struct kiocb *kiocb,
 			 struct socket *sock, struct msghdr *msg, size_t len)
 {
@@ -2856,6 +3053,7 @@
 	.acquire	= pfkey_send_acquire,
 	.compile_policy	= pfkey_compile_policy,
 	.new_mapping	= pfkey_send_new_mapping,
+	.notify_seq	= pfkey_send_replay_notify,
 };
 
 static void __exit ipsec_pfkey_exit(void)
Index: linux-2.6.9/net/xfrm/xfrm_export.c
===================================================================
--- linux-2.6.9.orig/net/xfrm/xfrm_export.c	2004-10-18 23:54:27.000000000 +0200
+++ linux-2.6.9/net/xfrm/xfrm_export.c	2004-10-29 11:12:48.662357640 +0200
@@ -27,6 +27,8 @@
 EXPORT_SYMBOL(xfrm_state_delete_tunnel);
 EXPORT_SYMBOL(xfrm_replay_check);
 EXPORT_SYMBOL(xfrm_replay_advance);
+EXPORT_SYMBOL(xfrm_replay_notify);
+EXPORT_SYMBOL(xfrm_state_replay_update);
 EXPORT_SYMBOL(xfrm_check_selectors);
 EXPORT_SYMBOL(__secpath_destroy);
 EXPORT_SYMBOL(secpath_dup);
Index: linux-2.6.9/net/xfrm/xfrm_state.c
===================================================================
--- linux-2.6.9.orig/net/xfrm/xfrm_state.c	2004-10-18 23:54:40.000000000 +0200
+++ linux-2.6.9/net/xfrm/xfrm_state.c	2004-10-29 11:12:48.664357185 +0200
@@ -52,6 +52,8 @@
 {
 	if (del_timer(&x->timer))
 		BUG();
+	if (del_timer(&x->rtimer))
+		BUG();
 	if (x->aalg)
 		kfree(x->aalg);
 	if (x->ealg)
@@ -92,6 +94,20 @@
 	        return secs*HZ;
 }
 
+void xfrm_replay_notify(struct xfrm_state *, int);
+
+static void xfrm_replay_timer_handler(unsigned long data)
+{
+	struct xfrm_state *x = (struct xfrm_state*)data;
+
+	spin_lock(&x->lock);
+
+	if (x->km.state == XFRM_STATE_VALID)
+		xfrm_replay_notify(x, XFRM_REPLAY_TIMEOUT);
+
+	spin_unlock(&x->lock);
+}
+
 static void xfrm_timer_handler(unsigned long data)
 {
 	struct xfrm_state *x = (struct xfrm_state*)data;
@@ -178,11 +194,16 @@
 		init_timer(&x->timer);
 		x->timer.function = xfrm_timer_handler;
 		x->timer.data	  = (unsigned long)x;
+		init_timer(&x->rtimer);
+		x->rtimer.function = xfrm_replay_timer_handler;
+		x->rtimer.data	   = (unsigned long)x;
 		x->curlft.add_time = (unsigned long)xtime.tv_sec;
 		x->lft.soft_byte_limit = XFRM_INF;
 		x->lft.soft_packet_limit = XFRM_INF;
 		x->lft.hard_byte_limit = XFRM_INF;
 		x->lft.hard_packet_limit = XFRM_INF;
+		x->replay_maxage = 0;
+		x->replay_maxdiff = 0;
 		x->lock = SPIN_LOCK_UNLOCKED;
 	}
 	return x;
@@ -212,6 +233,8 @@
 		spin_unlock(&xfrm_state_lock);
 		if (del_timer(&x->timer))
 			atomic_dec(&x->refcnt);
+		if (del_timer(&x->rtimer))
+			atomic_dec(&x->refcnt);
 
 		/* The number two in this test is the reference
 		 * mentioned in the comment below plus the reference
@@ -377,6 +400,10 @@
 	if (!mod_timer(&x->timer, jiffies + HZ))
 		xfrm_state_hold(x);
 
+	if (x->replay_maxage &&
+	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
+		xfrm_state_hold(x);
+
 	wake_up(&km_waitq);
 }
 
@@ -696,6 +723,48 @@
 }
 
 
+void km_replay_notify(struct xfrm_state *, int);
+
+void xfrm_replay_notify(struct xfrm_state *x, int event)
+{
+	/* we send notify messages in case
+	 *  1. we updated on of the sequence numbers, and the seqno difference
+	 *     is at least x->replay_maxdiff, in this case we also update the
+	 *     timeout of our timer function
+	 *  2. if x->replay_maxage has elapsed since last update,
+	 *     and there were changes
+	 *
+	 *  The state structure must be locked!
+	 */
+
+	switch (event & XFRM_REPLAY_ACTION_MASK) {
+	case XFRM_REPLAY_UPDATE:
+		if (x->replay_maxdiff &&
+		    (x->replay.seq - x->preplay.seq < x->replay_maxdiff) &&
+		    (x->replay.oseq - x->preplay.oseq < x->replay_maxdiff))
+			return;
+
+		break;
+
+	case XFRM_REPLAY_TIMEOUT:
+		if ((x->replay.seq == x->preplay.seq) &&
+		    (x->replay.bitmap == x->preplay.bitmap) &&
+		    (x->replay.oseq == x->preplay.oseq))
+			goto resched;
+
+		break;
+	}
+
+	memcpy(&x->preplay, &x->replay, sizeof(struct xfrm_replay_state));
+	km_replay_notify(x, event);
+
+resched:
+	if (x->replay_maxage && 
+	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
+		xfrm_state_hold(x);
+
+}
+
 int xfrm_replay_check(struct xfrm_state *x, u32 seq)
 {
 	u32 diff;
@@ -738,6 +807,16 @@
 		diff = x->replay.seq - seq;
 		x->replay.bitmap |= (1U << diff);
 	}
+
+	xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+}
+
+void xfrm_state_replay_update(struct xfrm_state *x, struct xfrm_replay_state *replay)
+{
+	spin_lock(&x->lock);
+	memcpy(&x->replay, replay, sizeof(*replay));
+	memcpy(&x->preplay, replay, sizeof(*replay));
+	spin_unlock(&x->lock);
 }
 
 int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl)
@@ -819,6 +898,17 @@
 		wake_up(&km_waitq);
 }
 
+void km_replay_notify(struct xfrm_state *x, int event)
+{
+	struct xfrm_mgr *km;
+
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list)
+		if (km->notify_seq)
+			km->notify_seq(x, event);
+	read_unlock(&xfrm_km_lock);
+}
+
 int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
 {
 	int err;

--=-+wYg4lem0EGz4c5sfVBn--
