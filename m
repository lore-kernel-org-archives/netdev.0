From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: provide stubs for ip6_set_txhash and ip6_make_flowlabel
Date: Tue,  8 Jul 2014 11:15:03 -0700
Message-ID: <1404843303-15405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, therbert@google.com, edumazet@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:64487 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbaGHSP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 14:15:27 -0400
Received: by mail-pd0-f181.google.com with SMTP id v10so7577383pde.40
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 11:15:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cb1ce2ef387b ("ipv6: Implement automatic flow label generation on
transmit") introduced ip6_make_flowlabel, while commit b73c3d0e4f0e
("net: Save TX flow hash in sock and set in skbuf on xmit") introduced
ip6_set_txhash.

ip6_set_tx_hash() uses sk_v6_daddr which references
__sk_common.skc_v6_daddr from struct sock_common, which is gated with
IS_ENABLED(CONFIG_IPV6).

ip6_make_flowlabel() uses the ipv6 member from struct net which is also
gated with IS_ENABLED(CONFIG_IPV6).

When CONFIG_IPV6 is disabled, we will hit a build failure that looks like this
when the compiler attempts inlining these functions:

  CC [M]  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.o
In file included from include/net/inet_sock.h:27:0,
                 from include/net/ip.h:30,
                 from drivers/net/ethernet/broadcom/cnic.c:37:
include/net/ipv6.h: In function 'ip6_set_txhash':
include/net/sock.h:327:33: error: 'struct sock_common' has no member
named 'skc_v6_daddr'
 #define sk_v6_daddr  __sk_common.skc_v6_daddr
                                 ^
include/net/ipv6.h:696:49: note: in expansion of macro 'sk_v6_daddr'
  keys.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
                                                 ^
In file included from include/net/inetpeer.h:15:0,
                 from include/net/route.h:28,
                 from include/net/ip.h:31,
                 from drivers/net/ethernet/broadcom/cnic.c:37:
include/net/ipv6.h: In function 'ip6_make_flowlabel':
include/net/ipv6.h:706:37: error: 'struct net' has no member named
'ipv6'
  if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
                                     ^

Fixes: cb1ce2ef387b ("ipv6: Implement automatic flow label generation on
transmit)
Fixes: b73c3d0e4f0e ("net: Save TX flow hash in sock and set
in skbuf on xmit")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/ipv6.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4308f2ada8b3..b9ac2357e7db 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -685,6 +685,7 @@ static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6 *fl6,
 	return hlimit;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
 static inline void ip6_set_txhash(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -718,6 +719,15 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 
 	return flowlabel;
 }
+#else
+static inline void ip6_set_txhash(struct sock *sk) { }
+static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
+					__be32 flowlabel, bool autolabel)
+{
+	return flowlabel;
+}
+#endif
+
 
 /*
  *	Header manipulation
-- 
1.9.1
