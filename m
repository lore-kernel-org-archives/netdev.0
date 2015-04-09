From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/20] netfilter: x_tables: don't extract flow keys on early demuxed sks in socket match
Date: Thu,  9 Apr 2015 13:34:53 +0200
Message-ID: <1428579304-5520-10-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33100 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932976AbbDILbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:14 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>

Currently in xt_socket, we take advantage of early demuxed sockets
since commit 00028aa37098 ("netfilter: xt_socket: use IP early demux")
in order to avoid a second socket lookup in the fast path, but we
only make partial use of this:

We still unnecessarily parse headers, extract proto, {s,d}addr and
{s,d}ports from the skb data, accessing possible conntrack information,
etc even though we were not even calling into the socket lookup via
xt_socket_get_sock_{v4,v6}() due to skb->sk hit, meaning those cycles
can be spared.

After this patch, we only proceed the slower, manual lookup path
when we have a skb->sk miss, thus time to match verdict for early
demuxed sockets will improve further, which might be i.e. interesting
for use cases such as mentioned in 681f130f39e1 ("netfilter: xt_socket:
add XT_SOCKET_NOWILDCARD flag").

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_socket.c |   95 ++++++++++++++++++++++++---------------------
 1 file changed, 50 insertions(+), 45 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 895534e..e092cb0 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -143,13 +143,10 @@ static bool xt_socket_sk_is_transparent(struct sock *sk)
 	}
 }
 
-static bool
-socket_match(const struct sk_buff *skb, struct xt_action_param *par,
-	     const struct xt_socket_mtinfo1 *info)
+static struct sock *xt_socket_lookup_slow_v4(const struct sk_buff *skb,
+					     const struct net_device *indev)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct udphdr _hdr, *hp = NULL;
-	struct sock *sk = skb->sk;
 	__be32 uninitialized_var(daddr), uninitialized_var(saddr);
 	__be16 uninitialized_var(dport), uninitialized_var(sport);
 	u8 uninitialized_var(protocol);
@@ -159,10 +156,12 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 #endif
 
 	if (iph->protocol == IPPROTO_UDP || iph->protocol == IPPROTO_TCP) {
+		struct udphdr _hdr, *hp;
+
 		hp = skb_header_pointer(skb, ip_hdrlen(skb),
 					sizeof(_hdr), &_hdr);
 		if (hp == NULL)
-			return false;
+			return NULL;
 
 		protocol = iph->protocol;
 		saddr = iph->saddr;
@@ -172,16 +171,17 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 
 	} else if (iph->protocol == IPPROTO_ICMP) {
 		if (extract_icmp4_fields(skb, &protocol, &saddr, &daddr,
-					&sport, &dport))
-			return false;
+					 &sport, &dport))
+			return NULL;
 	} else {
-		return false;
+		return NULL;
 	}
 
 #ifdef XT_SOCKET_HAVE_CONNTRACK
-	/* Do the lookup with the original socket address in case this is a
-	 * reply packet of an established SNAT-ted connection. */
-
+	/* Do the lookup with the original socket address in
+	 * case this is a reply packet of an established
+	 * SNAT-ted connection.
+	 */
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct && !nf_ct_is_untracked(ct) &&
 	    ((iph->protocol != IPPROTO_ICMP &&
@@ -197,10 +197,18 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	}
 #endif
 
+	return xt_socket_get_sock_v4(dev_net(skb->dev), protocol, saddr, daddr,
+				     sport, dport, indev);
+}
+
+static bool
+socket_match(const struct sk_buff *skb, struct xt_action_param *par,
+	     const struct xt_socket_mtinfo1 *info)
+{
+	struct sock *sk = skb->sk;
+
 	if (!sk)
-		sk = xt_socket_get_sock_v4(dev_net(skb->dev), protocol,
-					   saddr, daddr, sport, dport,
-					   par->in);
+		sk = xt_socket_lookup_slow_v4(skb, par->in);
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
@@ -225,12 +233,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 			sk = NULL;
 	}
 
-	pr_debug("proto %hhu %pI4:%hu -> %pI4:%hu (orig %pI4:%hu) sock %p\n",
-		 protocol, &saddr, ntohs(sport),
-		 &daddr, ntohs(dport),
-		 &iph->daddr, hp ? ntohs(hp->dest) : 0, sk);
-
-	return (sk != NULL);
+	return sk != NULL;
 }
 
 static bool
@@ -327,28 +330,26 @@ xt_socket_get_sock_v6(struct net *net, const u8 protocol,
 	return NULL;
 }
 
-static bool
-socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
+static struct sock *xt_socket_lookup_slow_v6(const struct sk_buff *skb,
+					     const struct net_device *indev)
 {
-	struct ipv6hdr ipv6_var, *iph = ipv6_hdr(skb);
-	struct udphdr _hdr, *hp = NULL;
-	struct sock *sk = skb->sk;
-	const struct in6_addr *daddr = NULL, *saddr = NULL;
 	__be16 uninitialized_var(dport), uninitialized_var(sport);
-	int thoff = 0, uninitialized_var(tproto);
-	const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
+	const struct in6_addr *daddr = NULL, *saddr = NULL;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	int thoff = 0, tproto;
 
 	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
 	if (tproto < 0) {
 		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
-		return NF_DROP;
+		return NULL;
 	}
 
 	if (tproto == IPPROTO_UDP || tproto == IPPROTO_TCP) {
-		hp = skb_header_pointer(skb, thoff,
-					sizeof(_hdr), &_hdr);
+		struct udphdr _hdr, *hp;
+
+		hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
 		if (hp == NULL)
-			return false;
+			return NULL;
 
 		saddr = &iph->saddr;
 		sport = hp->source;
@@ -356,17 +357,27 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 		dport = hp->dest;
 
 	} else if (tproto == IPPROTO_ICMPV6) {
+		struct ipv6hdr ipv6_var;
+
 		if (extract_icmp6_fields(skb, thoff, &tproto, &saddr, &daddr,
 					 &sport, &dport, &ipv6_var))
-			return false;
+			return NULL;
 	} else {
-		return false;
+		return NULL;
 	}
 
+	return xt_socket_get_sock_v6(dev_net(skb->dev), tproto, saddr, daddr,
+				     sport, dport, indev);
+}
+
+static bool
+socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
+	struct sock *sk = skb->sk;
+
 	if (!sk)
-		sk = xt_socket_get_sock_v6(dev_net(skb->dev), tproto,
-					   saddr, daddr, sport, dport,
-					   par->in);
+		sk = xt_socket_lookup_slow_v6(skb, par->in);
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
@@ -391,13 +402,7 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 			sk = NULL;
 	}
 
-	pr_debug("proto %hhd %pI6:%hu -> %pI6:%hu "
-		 "(orig %pI6:%hu) sock %p\n",
-		 tproto, saddr, ntohs(sport),
-		 daddr, ntohs(dport),
-		 &iph->daddr, hp ? ntohs(hp->dest) : 0, sk);
-
-	return (sk != NULL);
+	return sk != NULL;
 }
 #endif
 
-- 
1.7.10.4
