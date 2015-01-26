From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netlink: Kill redundant net argument in netlink_insert
Date: Mon, 26 Jan 2015 14:02:56 +1100
Message-ID: <20150126030256.GA20066@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56279 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbbAZDDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 22:03:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket already carries the net namespace with it so there is
no need to be passing another net around.
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7a94185..d77b346 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -994,11 +994,10 @@ static struct sock *__netlink_lookup(struct netlink_table *table, u32 portid,
 					 &netlink_compare, &arg);
 }
 
-static bool __netlink_insert(struct netlink_table *table, struct sock *sk,
-			     struct net *net)
+static bool __netlink_insert(struct netlink_table *table, struct sock *sk)
 {
 	struct netlink_compare_arg arg = {
-		.net = net,
+		.net = sock_net(sk),
 		.portid = nlk_sk(sk)->portid,
 	};
 
@@ -1047,7 +1046,7 @@ netlink_update_listeners(struct sock *sk)
 	 * makes sure updates are visible before bind or setsockopt return. */
 }
 
-static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
+static int netlink_insert(struct sock *sk, u32 portid)
 {
 	struct netlink_table *table = &nl_table[sk->sk_protocol];
 	int err;
@@ -1067,7 +1066,7 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
 	sock_hold(sk);
 
 	err = 0;
-	if (!__netlink_insert(table, sk, net)) {
+	if (!__netlink_insert(table, sk)) {
 		err = -EADDRINUSE;
 		sock_put(sk);
 	}
@@ -1289,7 +1288,7 @@ retry:
 	}
 	rcu_read_unlock();
 
-	err = netlink_insert(sk, net, portid);
+	err = netlink_insert(sk, portid);
 	if (err == -EADDRINUSE)
 		goto retry;
 
@@ -1477,7 +1476,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 
 	if (!nlk->portid) {
 		err = nladdr->nl_pid ?
-			netlink_insert(sk, net, nladdr->nl_pid) :
+			netlink_insert(sk, nladdr->nl_pid) :
 			netlink_autobind(sock);
 		if (err) {
 			netlink_undo_bind(nlk->ngroups, groups, sk);
@@ -2483,7 +2482,7 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 	if (cfg && cfg->input)
 		nlk_sk(sk)->netlink_rcv = cfg->input;
 
-	if (netlink_insert(sk, net, 0))
+	if (netlink_insert(sk, 0))
 		goto out_sock_release;
 
 	nlk = nlk_sk(sk);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
