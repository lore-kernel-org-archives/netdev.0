From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 3/7] gue: Add infrastructure for flags and options
Date: Tue,  4 Nov 2014 09:06:53 -0800
Message-ID: <1415120817-2105-4-git-send-email-therbert@google.com>
References: <1415120817-2105-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:62230 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbaKDRH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:07:28 -0500
Received: by mail-ie0-f180.google.com with SMTP id y20so7962330ier.39
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:07:28 -0800 (PST)
In-Reply-To: <1415120817-2105-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add functions and basic definitions for processing standard flags,
private flags, and control messages. This includes definitions
to compute length of optional fields corresponding to a set of flags.
Flag validation is in validate_gue_flags function. This checks for
unknown flags, and that length of optional fields is <= length
in guehdr hlen.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/gue.h | 100 ++++++++++++++++++++++++++++++++++++--
 net/ipv4/fou.c    | 142 ++++++++++++++++++++++++++++++++++++------------------
 2 files changed, 189 insertions(+), 53 deletions(-)

diff --git a/include/net/gue.h b/include/net/gue.h
index b6c3327..cb68ae8 100644
--- a/include/net/gue.h
+++ b/include/net/gue.h
@@ -1,23 +1,113 @@
 #ifndef __NET_GUE_H
 #define __NET_GUE_H
 
+/* Definitions for the GUE header, standard and private flags, lengths
+ * of optional fields are below.
+ *
+ * Diagram of GUE header:
+ *
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |Ver|C|  Hlen   | Proto/ctype   |        Standard flags       |P|
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                                                               |
+ * ~                      Fields (optional)                        ~
+ * |                                                               |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |            Private flags (optional, P bit is set)             |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                                                               |
+ * ~                   Private fields (optional)                   ~
+ * |                                                               |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * C bit indicates contol message when set, data message when unset.
+ * For a control message, proto/ctype is interpreted as a type of
+ * control message. For data messages, proto/ctype is the IP protocol
+ * of the next header.
+ *
+ * P bit indicates private flags field is present. The private flags
+ * may refer to options placed after this field.
+ */
+
 struct guehdr {
 	union {
 		struct {
 #if defined(__LITTLE_ENDIAN_BITFIELD)
-			__u8	hlen:4,
-			version:4;
+			__u8	hlen:5,
+				control:1,
+				version:2;
 #elif defined (__BIG_ENDIAN_BITFIELD)
-			__u8	version:4,
-				hlen:4;
+			__u8	version:2,
+				control:1,
+				hlen:5;
 #else
 #error  "Please fix <asm/byteorder.h>"
 #endif
-			__u8    next_hdr;
+			__u8    proto_ctype;
 			__u16   flags;
 		};
 		__u32 word;
 	};
 };
 
+/* Standard flags in GUE header */
+
+#define GUE_FLAG_PRIV	htons(1<<0)	/* Private flags are in options */
+#define GUE_LEN_PRIV	4
+
+#define GUE_FLAGS_ALL	(GUE_FLAG_PRIV)
+
+/* Private flags in the private option extension */
+
+#define GUE_PFLAGS_ALL	(0)
+
+/* Functions to compute options length corresponding to flags.
+ * If we ever have a lot of flags this can be potentially be
+ * converted to a more optimized algorithm (table lookup
+ * for instance).
+ */
+static inline size_t guehdr_flags_len(__be16 flags)
+{
+	return ((flags & GUE_FLAG_PRIV) ? GUE_LEN_PRIV : 0);
+}
+
+static inline size_t guehdr_priv_flags_len(__be32 flags)
+{
+	return 0;
+}
+
+/* Validate standard and private flags. Returns non-zero (meaning invalid)
+ * if there is an unknown standard or private flags, or the options length for
+ * the flags exceeds the options length specific in hlen of the GUE header.
+ */
+static inline int validate_gue_flags(struct guehdr *guehdr,
+				     size_t optlen)
+{
+	size_t len;
+	__be32 flags = guehdr->flags;
+
+	if (flags & ~GUE_FLAGS_ALL)
+		return 1;
+
+	len = guehdr_flags_len(flags);
+	if (len > optlen)
+		return 1;
+
+	if (flags & GUE_FLAG_PRIV) {
+		/* Private flags are last four bytes accounted in
+		 * guehdr_flags_len
+		 */
+		flags = *(__be32 *)((void *)&guehdr[1] + len - GUE_LEN_PRIV);
+
+		if (flags & ~GUE_PFLAGS_ALL)
+			return 1;
+
+		len += guehdr_priv_flags_len(flags);
+		if (len > optlen)
+			return 1;
+	}
+
+	return 0;
+}
+
 #endif
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 5446c1c..a3b8c5b 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -38,21 +38,17 @@ static inline struct fou *fou_from_sock(struct sock *sk)
 	return sk->sk_user_data;
 }
 
-static int fou_udp_encap_recv_deliver(struct sk_buff *skb,
-				      u8 protocol, size_t len)
+static void fou_recv_pull(struct sk_buff *skb, size_t len)
 {
 	struct iphdr *iph = ip_hdr(skb);
 
 	/* Remove 'len' bytes from the packet (UDP header and
-	 * FOU header if present), modify the protocol to the one
-	 * we found, and then call rcv_encap.
+	 * FOU header if present).
 	 */
 	iph->tot_len = htons(ntohs(iph->tot_len) - len);
 	__skb_pull(skb, len);
 	skb_postpull_rcsum(skb, udp_hdr(skb), len);
 	skb_reset_transport_header(skb);
-
-	return -protocol;
 }
 
 static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
@@ -62,16 +58,24 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 	if (!fou)
 		return 1;
 
-	return fou_udp_encap_recv_deliver(skb, fou->protocol,
-					  sizeof(struct udphdr));
+	fou_recv_pull(skb, sizeof(struct udphdr));
+
+	return -fou->protocol;
+}
+
+static int gue_control_message(struct sk_buff *skb, struct guehdr *guehdr)
+{
+	/* No support yet */
+	kfree_skb(skb);
+	return 0;
 }
 
 static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct fou *fou = fou_from_sock(sk);
-	size_t len;
+	size_t len, optlen, hdrlen;
 	struct guehdr *guehdr;
-	struct udphdr *uh;
+	void *data;
 
 	if (!fou)
 		return 1;
@@ -80,25 +84,38 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, len))
 		goto drop;
 
-	uh = udp_hdr(skb);
-	guehdr = (struct guehdr *)&uh[1];
+	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
+
+	optlen = guehdr->hlen << 2;
+	len += optlen;
 
-	len += guehdr->hlen << 2;
 	if (!pskb_may_pull(skb, len))
 		goto drop;
 
-	uh = udp_hdr(skb);
-	guehdr = (struct guehdr *)&uh[1];
+	/* guehdr may change after pull */
+	guehdr = (struct guehdr *)&udp_hdr(skb)[1];
 
-	if (guehdr->version != 0)
-		goto drop;
+	hdrlen = sizeof(struct guehdr) + optlen;
 
-	if (guehdr->flags) {
-		/* No support yet */
+	if (guehdr->version != 0 || validate_gue_flags(guehdr, optlen))
 		goto drop;
+
+	/* Pull UDP and GUE headers */
+	fou_recv_pull(skb, len);
+
+	data = &guehdr[1];
+
+	if (guehdr->flags & GUE_FLAG_PRIV) {
+		data += GUE_LEN_PRIV;
+
+		/* Process private flags */
 	}
 
-	return fou_udp_encap_recv_deliver(skb, guehdr->next_hdr, len);
+	if (unlikely(guehdr->control))
+		return gue_control_message(skb, guehdr);
+
+	return -guehdr->proto_ctype;
+
 drop:
 	kfree_skb(skb);
 	return 0;
@@ -154,36 +171,47 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 	const struct net_offload *ops;
 	struct sk_buff **pp = NULL;
 	struct sk_buff *p;
-	u8 proto;
 	struct guehdr *guehdr;
-	unsigned int hlen, guehlen;
-	unsigned int off;
+	size_t len, optlen, hdrlen, off;
+	void *data;
 	int flush = 1;
 
 	off = skb_gro_offset(skb);
-	hlen = off + sizeof(*guehdr);
+	len = off + sizeof(*guehdr);
+
 	guehdr = skb_gro_header_fast(skb, off);
-	if (skb_gro_header_hard(skb, hlen)) {
-		guehdr = skb_gro_header_slow(skb, hlen, off);
+	if (skb_gro_header_hard(skb, len)) {
+		guehdr = skb_gro_header_slow(skb, len, off);
 		if (unlikely(!guehdr))
 			goto out;
 	}
 
-	proto = guehdr->next_hdr;
+	optlen = guehdr->hlen << 2;
+	len += optlen;
 
-	rcu_read_lock();
-	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
-	ops = rcu_dereference(offloads[proto]);
-	if (WARN_ON(!ops || !ops->callbacks.gro_receive))
-		goto out_unlock;
+	if (skb_gro_header_hard(skb, len)) {
+		guehdr = skb_gro_header_slow(skb, len, off);
+		if (unlikely(!guehdr))
+			goto out;
+	}
 
-	guehlen = sizeof(*guehdr) + (guehdr->hlen << 2);
+	if (unlikely(guehdr->control) || guehdr->version != 0 ||
+	    validate_gue_flags(guehdr, optlen))
+		goto out;
 
-	hlen = off + guehlen;
-	if (skb_gro_header_hard(skb, hlen)) {
-		guehdr = skb_gro_header_slow(skb, hlen, off);
-		if (unlikely(!guehdr))
-			goto out_unlock;
+	hdrlen = sizeof(*guehdr) + optlen;
+
+	skb_gro_pull(skb, hdrlen);
+
+	/* Adjusted NAPI_GRO_CB(skb)->csum after skb_gro_pull()*/
+	skb_gro_postpull_rcsum(skb, guehdr, hdrlen);
+
+	data = &guehdr[1];
+
+	if (guehdr->flags & GUE_FLAG_PRIV) {
+		data += GUE_LEN_PRIV;
+
+		/* Process private flags */
 	}
 
 	flush = 0;
@@ -197,7 +225,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 		guehdr2 = (struct guehdr *)(p->data + off);
 
 		/* Compare base GUE header to be equal (covers
-		 * hlen, version, next_hdr, and flags.
+		 * hlen, version, proto_ctype, and flags.
 		 */
 		if (guehdr->word != guehdr2->word) {
 			NAPI_GRO_CB(p)->same_flow = 0;
@@ -212,10 +240,11 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 		}
 	}
 
-	skb_gro_pull(skb, guehlen);
-
-	/* Adjusted NAPI_GRO_CB(skb)->csum after skb_gro_pull()*/
-	skb_gro_postpull_rcsum(skb, guehdr, guehlen);
+	rcu_read_lock();
+	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
+	ops = rcu_dereference(offloads[guehdr->proto_ctype]);
+	if (WARN_ON(!ops || !ops->callbacks.gro_receive))
+		goto out_unlock;
 
 	pp = ops->callbacks.gro_receive(head, skb);
 
@@ -236,7 +265,7 @@ static int gue_gro_complete(struct sk_buff *skb, int nhoff)
 	u8 proto;
 	int err = -ENOENT;
 
-	proto = guehdr->next_hdr;
+	proto = guehdr->proto_ctype;
 
 	guehlen = sizeof(*guehdr) + (guehdr->hlen << 2);
 
@@ -533,8 +562,12 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	bool csum = !!(e->flags & TUNNEL_ENCAP_FLAG_CSUM);
 	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 	struct guehdr *guehdr;
-	size_t hdr_len = sizeof(struct guehdr);
+	size_t optlen = 0;
 	__be16 sport;
+	void *data;
+	bool need_priv = false;
+
+	optlen += need_priv ? GUE_LEN_PRIV : 0;
 
 	skb = iptunnel_handle_offloads(skb, csum, type);
 
@@ -545,14 +578,27 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
 					       skb, 0, 0, false);
 
-	skb_push(skb, hdr_len);
+	skb_push(skb, sizeof(struct guehdr) + optlen);
 
 	guehdr = (struct guehdr *)skb->data;
 
+	guehdr->control = 0;
 	guehdr->version = 0;
-	guehdr->hlen = 0;
+	guehdr->hlen = optlen >> 2;
 	guehdr->flags = 0;
-	guehdr->next_hdr = *protocol;
+	guehdr->proto_ctype = *protocol;
+
+	data = &guehdr[1];
+
+	if (need_priv) {
+		__be32 *flags = data;
+
+		guehdr->flags |= GUE_FLAG_PRIV;
+		*flags = 0;
+		data += GUE_LEN_PRIV;
+
+		/* Add private flags */
+	}
 
 	fou_build_udp(skb, e, fl4, protocol, sport);
 
-- 
2.1.0.rc2.206.gedb03e5
