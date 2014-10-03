From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 3/4] gue: Receive side for Generic UDP Encapsulation
Date: Fri,  3 Oct 2014 15:48:09 -0700
Message-ID: <1412376490-8774-4-git-send-email-therbert@google.com>
References: <1412376490-8774-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:49555 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758129AbaJCWsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:48:52 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so300744pdj.18
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:48:51 -0700 (PDT)
In-Reply-To: <1412376490-8774-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support receiving for GUE packets in the fou module. The
fou module now supports direct foo-over-udp (no encapsulation header)
and GUE. To support this a type parameter is added to the fou netlink
parameters.

For a GUE socket we define gue_udp_recv, gue_gro_receive, and
gue_gro_complete to handle the specifics of the GUE protocol. Most
of the code to manage and configure sockets is common with the fou.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/gue.h        |  23 ++++++
 include/uapi/linux/fou.h |   7 ++
 net/ipv4/fou.c           | 196 ++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 217 insertions(+), 9 deletions(-)
 create mode 100644 include/net/gue.h

diff --git a/include/net/gue.h b/include/net/gue.h
new file mode 100644
index 0000000..b6c3327
--- /dev/null
+++ b/include/net/gue.h
@@ -0,0 +1,23 @@
+#ifndef __NET_GUE_H
+#define __NET_GUE_H
+
+struct guehdr {
+	union {
+		struct {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+			__u8	hlen:4,
+			version:4;
+#elif defined (__BIG_ENDIAN_BITFIELD)
+			__u8	version:4,
+				hlen:4;
+#else
+#error  "Please fix <asm/byteorder.h>"
+#endif
+			__u8    next_hdr;
+			__u16   flags;
+		};
+		__u32 word;
+	};
+};
+
+#endif
diff --git a/include/uapi/linux/fou.h b/include/uapi/linux/fou.h
index e03376d..8df0689 100644
--- a/include/uapi/linux/fou.h
+++ b/include/uapi/linux/fou.h
@@ -13,6 +13,7 @@ enum {
 	FOU_ATTR_PORT,				/* u16 */
 	FOU_ATTR_AF,				/* u8 */
 	FOU_ATTR_IPPROTO,			/* u8 */
+	FOU_ATTR_TYPE,				/* u8 */
 
 	__FOU_ATTR_MAX,
 };
@@ -27,6 +28,12 @@ enum {
 	__FOU_CMD_MAX,
 };
 
+enum {
+	FOU_ENCAP_UNSPEC,
+	FOU_ENCAP_DIRECT,
+	FOU_ENCAP_GUE,
+};
+
 #define FOU_CMD_MAX	(__FOU_CMD_MAX - 1)
 
 #endif /* _UAPI_LINUX_FOU_H */
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 7e2126a..efa70ad 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -7,6 +7,7 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <net/genetlink.h>
+#include <net/gue.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/udp.h>
@@ -27,6 +28,7 @@ struct fou {
 };
 
 struct fou_cfg {
+	u16 type;
 	u8 protocol;
 	struct udp_port_cfg udp_config;
 };
@@ -64,6 +66,41 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 					  sizeof(struct udphdr));
 }
 
+static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct fou *fou = fou_from_sock(sk);
+	size_t len;
+	struct guehdr *guehdr;
+	struct udphdr *uh;
+
+	if (!fou)
+		return 1;
+
+	len = sizeof(struct udphdr) + sizeof(struct guehdr);
+	if (!pskb_may_pull(skb, len))
+		goto drop;
+
+	uh = udp_hdr(skb);
+	guehdr = (struct guehdr *)&uh[1];
+
+	len += guehdr->hlen << 2;
+	if (!pskb_may_pull(skb, len))
+		goto drop;
+
+	if (guehdr->version != 0)
+		goto drop;
+
+	if (guehdr->flags) {
+		/* No support yet */
+		goto drop;
+	}
+
+	return fou_udp_encap_recv_deliver(skb, guehdr->next_hdr, len);
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
 static struct sk_buff **fou_gro_receive(struct sk_buff **head,
 					struct sk_buff *skb)
 {
@@ -107,6 +144,112 @@ out_unlock:
 	return err;
 }
 
+static struct sk_buff **gue_gro_receive(struct sk_buff **head,
+					struct sk_buff *skb)
+{
+	const struct net_offload **offloads;
+	const struct net_offload *ops;
+	struct sk_buff **pp = NULL;
+	struct sk_buff *p;
+	u8 proto;
+	struct guehdr *guehdr;
+	unsigned int hlen, guehlen;
+	unsigned int off;
+	int flush = 1;
+
+	off = skb_gro_offset(skb);
+	hlen = off + sizeof(*guehdr);
+	guehdr = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		guehdr = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!guehdr))
+			goto out;
+	}
+
+	proto = guehdr->next_hdr;
+
+	rcu_read_lock();
+	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
+	ops = rcu_dereference(offloads[proto]);
+	if (WARN_ON(!ops || !ops->callbacks.gro_receive))
+		goto out_unlock;
+
+	guehlen = sizeof(*guehdr) + (guehdr->hlen << 2);
+
+	hlen = off + guehlen;
+	if (skb_gro_header_hard(skb, hlen)) {
+		guehdr = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!guehdr))
+			goto out_unlock;
+	}
+
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		const struct guehdr *guehdr2;
+
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		guehdr2 = (struct guehdr *)(p->data + off);
+
+		/* Compare base GUE header to be equal (covers
+		 * hlen, version, next_hdr, and flags.
+		 */
+		if (guehdr->word != guehdr2->word) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+
+		/* Compare optional fields are the same. */
+		if (guehdr->hlen && memcmp(&guehdr[1], &guehdr2[1],
+					   guehdr->hlen << 2)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+	}
+
+	skb_gro_pull(skb, guehlen);
+
+	/* Adjusted NAPI_GRO_CB(skb)->csum after skb_gro_pull()*/
+	skb_gro_postpull_rcsum(skb, guehdr, guehlen);
+
+	pp = ops->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int gue_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	const struct net_offload **offloads;
+	struct guehdr *guehdr = (struct guehdr *)(skb->data + nhoff);
+	const struct net_offload *ops;
+	unsigned int guehlen;
+	u8 proto;
+	int err = -ENOENT;
+
+	proto = guehdr->next_hdr;
+
+	guehlen = sizeof(*guehdr) + (guehdr->hlen << 2);
+
+	rcu_read_lock();
+	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
+	ops = rcu_dereference(offloads[proto]);
+	if (WARN_ON(!ops || !ops->callbacks.gro_complete))
+		goto out_unlock;
+
+	err = ops->callbacks.gro_complete(skb, nhoff + guehlen);
+
+out_unlock:
+	rcu_read_unlock();
+	return err;
+}
+
 static int fou_add_to_port_list(struct fou *fou)
 {
 	struct fou *fout;
@@ -142,6 +285,28 @@ static void fou_release(struct fou *fou)
 	kfree(fou);
 }
 
+static int fou_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
+{
+	udp_sk(sk)->encap_rcv = fou_udp_recv;
+	fou->protocol = cfg->protocol;
+	fou->udp_offloads.callbacks.gro_receive = fou_gro_receive;
+	fou->udp_offloads.callbacks.gro_complete = fou_gro_complete;
+	fou->udp_offloads.port = cfg->udp_config.local_udp_port;
+	fou->udp_offloads.ipproto = cfg->protocol;
+
+	return 0;
+}
+
+static int gue_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
+{
+	udp_sk(sk)->encap_rcv = gue_udp_recv;
+	fou->udp_offloads.callbacks.gro_receive = gue_gro_receive;
+	fou->udp_offloads.callbacks.gro_complete = gue_gro_complete;
+	fou->udp_offloads.port = cfg->udp_config.local_udp_port;
+
+	return 0;
+}
+
 static int fou_create(struct net *net, struct fou_cfg *cfg,
 		      struct socket **sockp)
 {
@@ -164,10 +329,24 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
 	sk = sock->sk;
 
-	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
-	fou->protocol = cfg->protocol;
-	fou->port =  cfg->udp_config.local_udp_port;
-	udp_sk(sk)->encap_rcv = fou_udp_recv;
+	fou->port = cfg->udp_config.local_udp_port;
+
+	/* Initial for fou type */
+	switch (cfg->type) {
+	case FOU_ENCAP_DIRECT:
+		err = fou_encap_init(sk, fou, cfg);
+		if (err)
+			goto error;
+		break;
+	case FOU_ENCAP_GUE:
+		err = gue_encap_init(sk, fou, cfg);
+		if (err)
+			goto error;
+		break;
+	default:
+		err = -EINVAL;
+		goto error;
+	}
 
 	udp_sk(sk)->encap_type = 1;
 	udp_encap_enable();
@@ -179,11 +358,6 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
 	sk->sk_allocation = GFP_ATOMIC;
 
-	fou->udp_offloads.callbacks.gro_receive = fou_gro_receive;
-	fou->udp_offloads.callbacks.gro_complete = fou_gro_complete;
-	fou->udp_offloads.port = cfg->udp_config.local_udp_port;
-	fou->udp_offloads.ipproto = cfg->protocol;
-
 	if (cfg->udp_config.family == AF_INET) {
 		err = udp_add_offload(&fou->udp_offloads);
 		if (err)
@@ -240,6 +414,7 @@ static struct nla_policy fou_nl_policy[FOU_ATTR_MAX + 1] = {
 	[FOU_ATTR_PORT] = { .type = NLA_U16, },
 	[FOU_ATTR_AF] = { .type = NLA_U8, },
 	[FOU_ATTR_IPPROTO] = { .type = NLA_U8, },
+	[FOU_ATTR_TYPE] = { .type = NLA_U8, },
 };
 
 static int parse_nl_config(struct genl_info *info,
@@ -267,6 +442,9 @@ static int parse_nl_config(struct genl_info *info,
 	if (info->attrs[FOU_ATTR_IPPROTO])
 		cfg->protocol = nla_get_u8(info->attrs[FOU_ATTR_IPPROTO]);
 
+	if (info->attrs[FOU_ATTR_TYPE])
+		cfg->type = nla_get_u8(info->attrs[FOU_ATTR_TYPE]);
+
 	return 0;
 }
 
-- 
2.1.0.rc2.206.gedb03e5
