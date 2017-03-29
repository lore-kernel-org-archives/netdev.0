From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] l2tp: hold tunnel socket when handling control frames in
 l2tp_ip and l2tp_ip6
Date: Wed, 29 Mar 2017 08:44:59 +0200
Message-ID: <3bedc3952e5e1a96f54442b083f935a44d9c3f83.1490769855.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51677 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753355AbdC2GpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 02:45:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code following l2tp_tunnel_find() expects that a new reference is
held on sk. Either sk_receive_skb() or the discard_put error path will
drop a reference from the tunnel's socket.

This issue exists in both l2tp_ip and l2tp_ip6.

Fixes: a3c18422a4b4 ("l2tp: hold socket before dropping lock in l2tp_ip{, 6}_recv()")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c  | 5 +++--
 net/l2tp/l2tp_ip6.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index d25038cfd64e..7208fbe5856b 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -178,9 +178,10 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 
 	tunnel_id = ntohl(*(__be32 *) &skb->data[4]);
 	tunnel = l2tp_tunnel_find(net, tunnel_id);
-	if (tunnel != NULL)
+	if (tunnel) {
 		sk = tunnel->sock;
-	else {
+		sock_hold(sk);
+	} else {
 		struct iphdr *iph = (struct iphdr *) skb_network_header(skb);
 
 		read_lock_bh(&l2tp_ip_lock);
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index a4abcbc4c09a..516d7ce24ba7 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -191,9 +191,10 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 
 	tunnel_id = ntohl(*(__be32 *) &skb->data[4]);
 	tunnel = l2tp_tunnel_find(net, tunnel_id);
-	if (tunnel != NULL)
+	if (tunnel) {
 		sk = tunnel->sock;
-	else {
+		sock_hold(sk);
+	} else {
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 
 		read_lock_bh(&l2tp_ip6_lock);
-- 
2.11.0
