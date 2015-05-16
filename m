From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Sat, 16 May 2015 21:16:28 +0800
Message-ID: <20150516131628.GA981@gondor.apana.org.au>
References: <20150514041628.GA5428@gondor.apana.org.au>
 <20150514042151.GA5482@gondor.apana.org.au>
 <20150514055824.GB6058@gondor.apana.org.au>
 <20150515.130257.1322224469755323983.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:50185 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbbEPNQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 09:16:37 -0400
Content-Disposition: inline
In-Reply-To: <20150515.130257.1322224469755323983.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2015 at 01:02:57PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 14 May 2015 13:58:24 +0800
> 
> > The current rhashtable rehash code is buggy and can't deal with
> > parallel insertions/removals without corrupting the hash table.
> > 
> > This patch disables it by partially reverting
> > c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink: eliminate
> > nl_sk_hash_lock").
> > 
> > This patch also removes a bogus socket lock introduced by that
> > very same patch.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Herbert, if you agree with me in the other thread that the lock_sock()
> or something like it has to remain, you'll need to respin this.

Actually I think this one is OK because I'm replacing it with the
hash table mutex which is just like the previous global lock except
that it is per-family.  As you cannot change the family on a netlink
socket this should be good enough.

But the changelog message is wrong so here is an updated version.

Cheers,

---8<---
The current rhashtable rehash code is buggy and can't deal with
parallel insertions/removals without corrupting the hash table.

This patch disables it by partially reverting
c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink: eliminate
nl_sk_hash_lock").

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
