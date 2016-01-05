From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] udp_diag: fix udp_dump_one() vs SO_REUSEPORT
Date: Tue, 05 Jan 2016 14:08:58 -0800
Message-ID: <1452031738.8255.127.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33175 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbcAEWI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 17:08:59 -0500
Received: by mail-pa0-f43.google.com with SMTP id cy9so221651987pac.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 14:08:59 -0800 (PST)
In-Reply-To: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

udp_dump_one() uses __udp4_lib_lookup() & __udp6_lib_lookup()
which cannot properly handle the provided cookie when SO_REUSEPORT
is used, as many sockets share the same 4-tuple

Instead, let's use the provided 64bit cookie to uniquely identify
the socket.

This will allow us to remove a check against skb being NULL in
reuseport_select_sock(), as we no longer share __udp4_lib_lookup() &
__udp6_lib_lookup() with packet processing path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp_diag.c |   44 ++++++++++++++++++------------------------
 1 file changed, 19 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index df1966f3b6ec..09d0e1cffeb4 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -35,36 +35,30 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 			const struct nlmsghdr *nlh,
 			const struct inet_diag_req_v2 *req)
 {
-	int err = -EINVAL;
-	struct sock *sk;
+	struct sock *aux, *sk = NULL;
 	struct sk_buff *rep;
 	struct net *net = sock_net(in_skb->sk);
-
-	if (req->sdiag_family == AF_INET)
-		sk = __udp4_lib_lookup(net,
-				req->id.idiag_src[0], req->id.idiag_sport,
-				req->id.idiag_dst[0], req->id.idiag_dport,
-				req->id.idiag_if, tbl, NULL);
-#if IS_ENABLED(CONFIG_IPV6)
-	else if (req->sdiag_family == AF_INET6)
-		sk = __udp6_lib_lookup(net,
-				(struct in6_addr *)req->id.idiag_src,
-				req->id.idiag_sport,
-				(struct in6_addr *)req->id.idiag_dst,
-				req->id.idiag_dport,
-				req->id.idiag_if, tbl, NULL);
-#endif
-	else
-		goto out_nosk;
-
-	err = -ENOENT;
+	unsigned short hnum = ntohs(req->id.idiag_dport);
+	unsigned int slot = udp_hashfn(net, hnum, tbl->mask);
+	struct udp_hslot *hslot = &tbl->hash[slot];
+	struct hlist_nulls_node *node;
+	int err = -ENOENT;
+
+	spin_lock_bh(&hslot->lock);
+	sk_nulls_for_each(aux, node, &hslot->head) {
+		if (net_eq(sock_net(aux), net) &&
+		    !sock_diag_check_cookie(aux, req->id.idiag_cookie) &&
+		    (req->sdiag_family == AF_UNSPEC ||
+		     req->sdiag_family == aux->sk_family)) {
+			sk = aux;
+			sock_hold(sk);
+			break;
+		}
+	}
+	spin_unlock_bh(&hslot->lock);
 	if (!sk)
 		goto out_nosk;
 
-	err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
-	if (err)
-		goto out;
-
 	err = -ENOMEM;
 	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
 			sizeof(struct inet_diag_meminfo) + 64,
