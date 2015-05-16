From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [net] netlink: Make autobind rover an atomic_t
Date: Sat, 16 May 2015 21:40:07 +0800
Message-ID: <20150516134007.GA1152@gondor.apana.org.au>
References: <20150514042151.GA5482@gondor.apana.org.au>
 <20150514055824.GB6058@gondor.apana.org.au>
 <20150514060230.GD6058@gondor.apana.org.au>
 <20150515.130219.331336809636676892.davem@redhat.com>
 <20150516123242.GA683@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34314 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbbEPNkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 09:40:20 -0400
Content-Disposition: inline
In-Reply-To: <20150516123242.GA683@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 21e4902aea80ef35afc00ee8d2abdea4f519b7f7 ("netlink:
Lockless lookup with RCU grace period in socket release") removed
the locks around the autobind rover without making the rover itself
safe for use by multiple threads.

This patch converts rover to an atomic_t to make it at least
somewhat safe to use locklessly.  The tricky bit is when the
rover wraps around.  This patch simply deals with it by blindly
doing an atomic_set.  So if many threads encounter the wraparound
simultaneously then they'll all step on each other's toes and
all try to bind to -4097.  But this should eventually sort itself
out as they loop around and try the atomic_dec_return after the
last thread does an atomic_set.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbd..6ffce5b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1292,24 +1292,27 @@ static int netlink_release(struct socket *sock)
 static int netlink_autobind(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
+	struct sock *sk2;
 	struct net *net = sock_net(sk);
 	struct netlink_table *table = &nl_table[sk->sk_protocol];
 	s32 portid = task_tgid_vnr(current);
 	int err;
-	static s32 rover = -4097;
+	static atomic_t rover = ATOMIC_INIT(-4096);
 
 retry:
 	cond_resched();
 	rcu_read_lock();
-	if (__netlink_lookup(table, portid, net)) {
+	sk2 = __netlink_lookup(table, portid, net);
+	rcu_read_unlock();
+	if (sk2) {
 		/* Bind collision, search negative portid values. */
-		portid = rover--;
-		if (rover > -4097)
-			rover = -4097;
-		rcu_read_unlock();
+		portid = atomic_dec_return(&rover);
+		if (unlikely(portid > -4097)) {
+			atomic_set(&rover, -4097);
+			portid = -4097;
+		}
 		goto retry;
 	}
-	rcu_read_unlock();
 
 	err = netlink_insert(sk, portid);
 	if (err == -EADDRINUSE)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
