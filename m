From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Red Hat INTERNAL-ONLY kernel discussion list
 <rhkernel-list@redhat.com>
Date: Thu, 14 May 2015 13:56:34 +0800
Message-ID: <20150514055634.GA6058@gondor.apana.org.au>
References: <20150513062038.GA26944@gondor.apana.org.au>
 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514025333.GA3853@gondor.apana.org.au>
 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514033448.GA5080@gondor.apana.org.au>
 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514041628.GA5428@gondor.apana.org.au>
 <20150514042151.GA5482@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38124 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934163AbbENF4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 01:56:45 -0400
Content-Disposition: inline
In-Reply-To: <20150514042151.GA5482@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 12:21:51PM +0800, Herbert Xu wrote:
> 
> If that was the case then we simply need to get rid of dynamic
> rehashing.

Here is a totally untested patch against 4.0.

---8<---
The current rhashtable rehash code is buggy and can't deal with
parallel insertions/removals without corrupting the hash table.

This patch disables it by partially reverting
c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink: eliminate
nl_sk_hash_lock").

This patch also removes a bogus socket lock introduced by that
very same patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 05919bf..322fe03 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1052,7 +1052,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	struct netlink_table *table = &nl_table[sk->sk_protocol];
 	int err;
 
-	lock_sock(sk);
+	mutex_lock(&table->hash.mutex);
 
 	err = -EBUSY;
 	if (nlk_sk(sk)->portid)
@@ -1073,7 +1073,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	}
 
 err:
-	release_sock(sk);
+	mutex_unlock(&table->hash.mutex);
 	return err;
 }
 
@@ -1082,10 +1082,12 @@ static void netlink_remove(struct sock *sk)
 	struct netlink_table *table;
 
 	table = &nl_table[sk->sk_protocol];
+	mutex_lock(&table->hash.mutex);
 	if (rhashtable_remove(&table->hash, &nlk_sk(sk)->node)) {
 		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
 		__sock_put(sk);
 	}
+	mutex_unlock(&table->hash.mutex);
 
 	netlink_table_grab();
 	if (nlk_sk(sk)->subscriptions) {

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
