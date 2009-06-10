From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 30/31: xt_socket: added new revision of the 'socket' match supporting flags
Date: Wed, 10 Jun 2009 21:47:00 +0200 (MEST)
Message-ID: <20090610194658.11112.99429.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a31e1ffd2231b8fdf7eda9ed750a4a0df9bcad4e
Author: Laszlo Attila Toth <panther@balabit.hu>
Date:   Tue Jun 9 15:16:34 2009 +0200

    netfilter: xt_socket: added new revision of the 'socket' match supporting flags
    
    If the XT_SOCKET_TRANSPARENT flag is set, enabled 'transparent'
    socket option is required for the socket to be matched.
    
    Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/xt_socket.h b/include/linux/netfilter/xt_socket.h
new file mode 100644
index 0000000..6f475b8
--- /dev/null
+++ b/include/linux/netfilter/xt_socket.h
@@ -0,0 +1,12 @@
+#ifndef _XT_SOCKET_H
+#define _XT_SOCKET_H
+
+enum {
+	XT_SOCKET_TRANSPARENT = 1 << 0,
+};
+
+struct xt_socket_mtinfo1 {
+	__u8 flags;
+};
+
+#endif /* _XT_SOCKET_H */
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 1acc089..ebf00ad 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -22,6 +22,8 @@
 #include <net/netfilter/nf_tproxy_core.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 
+#include <linux/netfilter/xt_socket.h>
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #define XT_SOCKET_HAVE_CONNTRACK 1
 #include <net/netfilter/nf_conntrack.h>
@@ -86,7 +88,8 @@ extract_icmp_fields(const struct sk_buff *skb,
 
 
 static bool
-socket_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
+	     const struct xt_socket_mtinfo1 *info)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct udphdr _hdr, *hp = NULL;
@@ -141,10 +144,24 @@ socket_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
 				   saddr, daddr, sport, dport, par->in, false);
 	if (sk != NULL) {
-		bool wildcard = (sk->sk_state != TCP_TIME_WAIT && inet_sk(sk)->rcv_saddr == 0);
+		bool wildcard;
+		bool transparent = true;
+
+		/* Ignore sockets listening on INADDR_ANY */
+		wildcard = (sk->sk_state != TCP_TIME_WAIT &&
+			    inet_sk(sk)->rcv_saddr == 0);
+
+		/* Ignore non-transparent sockets,
+		   if XT_SOCKET_TRANSPARENT is used */
+		if (info && info->flags & XT_SOCKET_TRANSPARENT)
+			transparent = ((sk->sk_state != TCP_TIME_WAIT &&
+					inet_sk(sk)->transparent) ||
+				       (sk->sk_state == TCP_TIME_WAIT &&
+					inet_twsk(sk)->tw_transparent));
 
 		nf_tproxy_put_sock(sk);
-		if (wildcard)
+
+		if (wildcard || !transparent)
 			sk = NULL;
 	}
 
@@ -157,23 +174,47 @@ socket_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return (sk != NULL);
 }
 
-static struct xt_match socket_mt_reg __read_mostly = {
-	.name		= "socket",
-	.family		= AF_INET,
-	.match		= socket_mt,
-	.hooks		= 1 << NF_INET_PRE_ROUTING,
-	.me		= THIS_MODULE,
+static bool
+socket_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	return socket_match(skb, par, NULL);
+}
+
+static bool
+socket_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	return socket_match(skb, par, par->matchinfo);
+}
+
+static struct xt_match socket_mt_reg[] __read_mostly = {
+	{
+		.name		= "socket",
+		.revision	= 0,
+		.family		= NFPROTO_IPV4,
+		.match		= socket_mt_v0,
+		.hooks		= 1 << NF_INET_PRE_ROUTING,
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "socket",
+		.revision	= 1,
+		.family		= NFPROTO_IPV4,
+		.match		= socket_mt_v1,
+		.matchsize	= sizeof(struct xt_socket_mtinfo1),
+		.hooks		= 1 << NF_INET_PRE_ROUTING,
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init socket_mt_init(void)
 {
 	nf_defrag_ipv4_enable();
-	return xt_register_match(&socket_mt_reg);
+	return xt_register_matches(socket_mt_reg, ARRAY_SIZE(socket_mt_reg));
 }
 
 static void __exit socket_mt_exit(void)
 {
-	xt_unregister_match(&socket_mt_reg);
+	xt_unregister_matches(socket_mt_reg, ARRAY_SIZE(socket_mt_reg));
 }
 
 module_init(socket_mt_init);
