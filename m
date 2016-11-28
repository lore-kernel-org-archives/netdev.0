From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 4/5] l2tp: fix lookup for sockets not bound to a device
 in l2tp_ip
Date: Mon, 28 Nov 2016 20:40:00 +0100
Message-ID: <bea0f3aa90ca8bb971043289ce553674070da259.1480360512.git.g.nault@alphalink.fr>
References: <cover.1480360512.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:48864 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754380AbcK1TkE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:40:04 -0500
Content-Disposition: inline
In-Reply-To: <cover.1480360512.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When looking up an l2tp socket, we must consider a null netdevice id as
wild card. There are currently two problems caused by
__l2tp_ip_bind_lookup() not considering 'dif' as wild card when set to 0:

  * A socket bound to a device (i.e. with sk->sk_bound_dev_if != 0)
    never receives any packet. Since __l2tp_ip_bind_lookup() is called
    with dif == 0 in l2tp_ip_recv(), sk->sk_bound_dev_if is always
    different from 'dif' so the socket doesn't match.

  * Two sockets, one bound to a device but not the other, can be bound
    to the same address. If the first socket binding to the address is
    the one that is also bound to a device, the second socket can bind
    to the same address without __l2tp_ip_bind_lookup() noticing the
    overlap.

To fix this issue, we need to consider that any null device index, be
it 'sk->sk_bound_dev_if' or 'dif', matches with any other value.
We also need to pass the input device index to __l2tp_ip_bind_lookup()
on reception so that sockets bound to a device never receive packets
from other devices.

This patch fixes l2tp_ip6 in the same way.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c  | 6 ++++--
 net/l2tp/l2tp_ip6.c | 7 ++++---
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index ea818f3..aa42e10 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -61,7 +61,8 @@ static struct sock *__l2tp_ip_bind_lookup(struct net *net, __be32 laddr, int dif
 		if ((l2tp->conn_id == tunnel_id) &&
 		    net_eq(sock_net(sk), net) &&
 		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
-		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+		    (!sk->sk_bound_dev_if || !dif ||
+		     sk->sk_bound_dev_if == dif))
 			goto found;
 	}
 
@@ -182,7 +183,8 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 		struct iphdr *iph = (struct iphdr *) skb_network_header(skb);
 
 		read_lock_bh(&l2tp_ip_lock);
-		sk = __l2tp_ip_bind_lookup(net, iph->daddr, 0, tunnel_id);
+		sk = __l2tp_ip_bind_lookup(net, iph->daddr, inet_iif(skb),
+					   tunnel_id);
 		if (!sk) {
 			read_unlock_bh(&l2tp_ip_lock);
 			goto discard;
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 5f2ae61..4a86440 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -73,7 +73,8 @@ static struct sock *__l2tp_ip6_bind_lookup(struct net *net,
 		if ((l2tp->conn_id == tunnel_id) &&
 		    net_eq(sock_net(sk), net) &&
 		    !(addr && ipv6_addr_equal(addr, laddr)) &&
-		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+		    (!sk->sk_bound_dev_if || !dif ||
+		     sk->sk_bound_dev_if == dif))
 			goto found;
 	}
 
@@ -196,8 +197,8 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 
 		read_lock_bh(&l2tp_ip6_lock);
-		sk = __l2tp_ip6_bind_lookup(net, &iph->daddr,
-					    0, tunnel_id);
+		sk = __l2tp_ip6_bind_lookup(net, &iph->daddr, inet6_iif(skb),
+					    tunnel_id);
 		if (!sk) {
 			read_unlock_bh(&l2tp_ip6_lock);
 			goto discard;
-- 
2.10.2
