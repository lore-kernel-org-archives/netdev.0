From: kaber@trash.net
Subject: [PATCH 67/72] tproxy: use the interface primary IP address as a default value for --on-ip
Date: Thu, 21 Oct 2010 17:19:54 +0200
Message-ID: <1287674399-31455-68-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

The REDIRECT target and the older TProxy versions used the primary address
of the incoming interface as the default value of the --on-ip parameter.
This was unintentionally changed during the initial TProxy submission and
caused confusion among users.

Since IPv6 has no notion of primary address, we just select the first address
on the list: this way the socket lookup finds wildcard bound sockets
properly and we cannot really do better without the user telling us the
IPv6 address of the proxy.

This is implemented for both IPv4 and IPv6.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_TPROXY.c |  202 +++++++++++++++++++++++++++++----------------
 1 files changed, 132 insertions(+), 70 deletions(-)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index d5f97e2..19c482c 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -16,15 +16,41 @@
 #include <net/checksum.h>
 #include <net/udp.h>
 #include <net/inet_sock.h>
-
+#include <linux/inetdevice.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
-#include <linux/netfilter_ipv6/ip6_tables.h>
-#include <linux/netfilter/xt_TPROXY.h>
 
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#include <net/if_inet6.h>
+#include <net/addrconf.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
+#endif
+
 #include <net/netfilter/nf_tproxy_core.h>
+#include <linux/netfilter/xt_TPROXY.h>
+
+static inline __be32
+tproxy_laddr4(struct sk_buff *skb, __be32 user_laddr, __be32 daddr)
+{
+	struct in_device *indev;
+	__be32 laddr;
+
+	if (user_laddr)
+		return user_laddr;
+
+	laddr = 0;
+	rcu_read_lock();
+	indev = __in_dev_get_rcu(skb->dev);
+	for_primary_ifa(indev) {
+		laddr = ifa->ifa_local;
+		break;
+	} endfor_ifa(indev);
+	rcu_read_unlock();
+
+	return laddr ? laddr : daddr;
+}
 
 /**
  * tproxy_handle_time_wait4() - handle IPv4 TCP TIME_WAIT reopen redirections
@@ -75,60 +101,6 @@ tproxy_handle_time_wait4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 	return sk;
 }
 
-/**
- * tproxy_handle_time_wait6() - handle IPv6 TCP TIME_WAIT reopen redirections
- * @skb:	The skb being processed.
- * @tproto:	Transport protocol.
- * @thoff:	Transport protocol header offset.
- * @par:	Iptables target parameters.
- * @sk:		The TIME_WAIT TCP socket found by the lookup.
- *
- * We have to handle SYN packets arriving to TIME_WAIT sockets
- * differently: instead of reopening the connection we should rather
- * redirect the new connection to the proxy if there's a listener
- * socket present.
- *
- * tproxy_handle_time_wait6() consumes the socket reference passed in.
- *
- * Returns the listener socket if there's one, the TIME_WAIT socket if
- * no such listener is found, or NULL if the TCP header is incomplete.
- */
-static struct sock *
-tproxy_handle_time_wait6(struct sk_buff *skb, int tproto, int thoff,
-			 const struct xt_action_param *par,
-			 struct sock *sk)
-{
-	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct tcphdr _hdr, *hp;
-	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
-
-	hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
-	if (hp == NULL) {
-		inet_twsk_put(inet_twsk(sk));
-		return NULL;
-	}
-
-	if (hp->syn && !hp->rst && !hp->ack && !hp->fin) {
-		/* SYN to a TIME_WAIT socket, we'd rather redirect it
-		 * to a listener socket if there's one */
-		struct sock *sk2;
-
-		sk2 = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
-					    &iph->saddr,
-					    !ipv6_addr_any(&tgi->laddr.in6) ? &tgi->laddr.in6 : &iph->daddr,
-					    hp->source,
-					    tgi->lport ? tgi->lport : hp->dest,
-					    skb->dev, NFT_LOOKUP_LISTENER);
-		if (sk2) {
-			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
-			inet_twsk_put(inet_twsk(sk));
-			sk = sk2;
-		}
-	}
-
-	return sk;
-}
-
 static unsigned int
 tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 	   u_int32_t mark_mask, u_int32_t mark_value)
@@ -150,6 +122,10 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 				   hp->source, hp->dest,
 				   skb->dev, NFT_LOOKUP_ESTABLISHED);
 
+	laddr = tproxy_laddr4(skb, laddr, iph->daddr);
+	if (!lport)
+		lport = hp->dest;
+
 	/* UDP has no TCP_TIME_WAIT state, so we never enter here */
 	if (sk && sk->sk_state == TCP_TIME_WAIT)
 		/* reopening a TIME_WAIT connection needs special handling */
@@ -158,8 +134,8 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 		/* no, there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
 		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-					   iph->saddr, laddr ? laddr : iph->daddr,
-					   hp->source, lport ? lport : hp->dest,
+					   iph->saddr, laddr,
+					   hp->source, lport,
 					   skb->dev, NFT_LOOKUP_LISTENER);
 
 	/* NOTE: assign_sock consumes our sk reference */
@@ -174,9 +150,9 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 		return NF_ACCEPT;
 	}
 
-	pr_debug("no socket, dropping: proto %hhu %08x:%hu -> %08x:%hu, mark: %x\n",
-		 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
-		 ntohl(laddr), ntohs(lport), skb->mark);
+	pr_debug("no socket, dropping: proto %hhu %pI4:%hu -> %pI4:%hu, mark: %x\n",
+		 iph->protocol, &iph->saddr, ntohs(hp->source),
+		 &iph->daddr, ntohs(hp->dest), skb->mark);
 	return NF_DROP;
 }
 
@@ -197,6 +173,88 @@ tproxy_tg4_v1(struct sk_buff *skb, const struct xt_action_param *par)
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
+static inline const struct in6_addr *
+tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr,
+	      const struct in6_addr *daddr)
+{
+	struct inet6_dev *indev;
+	struct inet6_ifaddr *ifa;
+	struct in6_addr *laddr;
+
+	if (!ipv6_addr_any(user_laddr))
+		return user_laddr;
+	laddr = NULL;
+
+	rcu_read_lock();
+	indev = __in6_dev_get(skb->dev);
+	if (indev)
+		list_for_each_entry(ifa, &indev->addr_list, if_list) {
+			if (ifa->flags & (IFA_F_TENTATIVE | IFA_F_DEPRECATED))
+				continue;
+
+			laddr = &ifa->addr;
+			break;
+		}
+	rcu_read_unlock();
+
+	return laddr ? laddr : daddr;
+}
+
+/**
+ * tproxy_handle_time_wait6() - handle IPv6 TCP TIME_WAIT reopen redirections
+ * @skb:	The skb being processed.
+ * @tproto:	Transport protocol.
+ * @thoff:	Transport protocol header offset.
+ * @par:	Iptables target parameters.
+ * @sk:		The TIME_WAIT TCP socket found by the lookup.
+ *
+ * We have to handle SYN packets arriving to TIME_WAIT sockets
+ * differently: instead of reopening the connection we should rather
+ * redirect the new connection to the proxy if there's a listener
+ * socket present.
+ *
+ * tproxy_handle_time_wait6() consumes the socket reference passed in.
+ *
+ * Returns the listener socket if there's one, the TIME_WAIT socket if
+ * no such listener is found, or NULL if the TCP header is incomplete.
+ */
+static struct sock *
+tproxy_handle_time_wait6(struct sk_buff *skb, int tproto, int thoff,
+			 const struct xt_action_param *par,
+			 struct sock *sk)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct tcphdr _hdr, *hp;
+	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
+
+	hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
+	if (hp == NULL) {
+		inet_twsk_put(inet_twsk(sk));
+		return NULL;
+	}
+
+	if (hp->syn && !hp->rst && !hp->ack && !hp->fin) {
+		/* SYN to a TIME_WAIT socket, we'd rather redirect it
+		 * to a listener socket if there's one */
+		struct sock *sk2;
+
+		sk2 = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+					    &iph->saddr,
+					    tproxy_laddr6(skb, &tgi->laddr.in6, &iph->daddr),
+					    hp->source,
+					    tgi->lport ? tgi->lport : hp->dest,
+					    skb->dev, NFT_LOOKUP_LISTENER);
+		if (sk2) {
+			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_put(inet_twsk(sk));
+			sk = sk2;
+		}
+	}
+
+	return sk;
+}
+
 static unsigned int
 tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 {
@@ -204,6 +262,8 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
 	struct udphdr _hdr, *hp;
 	struct sock *sk;
+	const struct in6_addr *laddr;
+	__be16 lport;
 	int thoff;
 	int tproto;
 
@@ -228,6 +288,9 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 				   hp->source, hp->dest,
 				   par->in, NFT_LOOKUP_ESTABLISHED);
 
+	laddr = tproxy_laddr6(skb, &tgi->laddr.in6, &iph->daddr);
+	lport = tgi->lport ? tgi->lport : hp->dest;
+
 	/* UDP has no TCP_TIME_WAIT state, so we never enter here */
 	if (sk && sk->sk_state == TCP_TIME_WAIT)
 		/* reopening a TIME_WAIT connection needs special handling */
@@ -236,10 +299,8 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 		/* no there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
 		sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
-					   &iph->saddr,
-					   !ipv6_addr_any(&tgi->laddr.in6) ? &tgi->laddr.in6 : &iph->daddr,
-					   hp->source,
-					   tgi->lport ? tgi->lport : hp->dest,
+					   &iph->saddr, laddr,
+					   hp->source, lport,
 					   par->in, NFT_LOOKUP_LISTENER);
 
 	/* NOTE: assign_sock consumes our sk reference */
@@ -249,14 +310,15 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 		skb->mark = (skb->mark & ~tgi->mark_mask) ^ tgi->mark_value;
 
 		pr_debug("redirecting: proto %hhu %pI6:%hu -> %pI6:%hu, mark: %x\n",
-			 tproto, &iph->saddr, ntohs(hp->dest),
-			 &tgi->laddr.in6, ntohs(tgi->lport), skb->mark);
+			 tproto, &iph->saddr, ntohs(hp->source),
+			 laddr, ntohs(lport), skb->mark);
 		return NF_ACCEPT;
 	}
 
 	pr_debug("no socket, dropping: proto %hhu %pI6:%hu -> %pI6:%hu, mark: %x\n",
-		 tproto, &iph->saddr, ntohs(hp->dest),
-		 &tgi->laddr.in6, ntohs(tgi->lport), skb->mark);
+		 tproto, &iph->saddr, ntohs(hp->source),
+		 &iph->daddr, ntohs(hp->dest), skb->mark);
+
 	return NF_DROP;
 }
 
-- 
1.7.1

