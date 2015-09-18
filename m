From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH v4] netlink: Fix autobind race condition that leads to zero
 port ID
Date: Fri, 18 Sep 2015 19:16:50 +0800
Message-ID: <20150918111650.GA7508@gondor.apana.org.au>
References: <20150917022909.GA22754@htj.duckdns.org>
 <20150917030845.GA19162@gondor.apana.org.au>
 <20150917034134.GA19327@gondor.apana.org.au>
 <CAHA+R7OdJyZiidHarKhp-U6R5fkHj=5KjugK=XoWj=q4D8krxw@mail.gmail.com>
 <20150917051503.GA19978@gondor.apana.org.au>
 <20150917113034.GA14471@htj.duckdns.org>
 <20150918063609.GA31747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team <kernel-team@fb.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150918063609.GA31747@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 18, 2015 at 02:36:09PM +0800, Herbert Xu wrote:
> 
> But yes there are ordering issues here so I've decided to make
> rhashtable use a new field for its hash instead.
> 
> Note that I've dropped the acks as this patch is now substantially
> different.

v3 doesn't apply to the current tree anymore so here is a respin
rebased on rc1.

---8<---
The commit c0bb07df7d981e4091432754e30c9c720e2c0c78 ("netlink:
Reset portid after netlink_insert failure") introduced a race
condition where if two threads try to autobind the same socket
one of them may end up with a zero port ID.  This led to kernel
deadlocks that were observed by multiple people.

This patch reverts that commit and instead fixes it by introducing
a separte rhash_portid variable so that the real portid is only set
after the socket has been successfully hashed.

Fixes: c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
Reported-by: Tejun Heo <tj@kernel.org>
Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7f86d3b..303efb7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1015,7 +1015,7 @@ static inline int netlink_compare(struct rhashtable_compare_arg *arg,
 	const struct netlink_compare_arg *x = arg->key;
 	const struct netlink_sock *nlk = ptr;
 
-	return nlk->portid != x->portid ||
+	return nlk->rhash_portid != x->portid ||
 	       !net_eq(sock_net(&nlk->sk), read_pnet(&x->pnet));
 }
 
@@ -1041,7 +1041,7 @@ static int __netlink_insert(struct netlink_table *table, struct sock *sk)
 {
 	struct netlink_compare_arg arg;
 
-	netlink_compare_arg_init(&arg, sock_net(sk), nlk_sk(sk)->portid);
+	netlink_compare_arg_init(&arg, sock_net(sk), nlk_sk(sk)->rhash_portid);
 	return rhashtable_lookup_insert_key(&table->hash, &arg,
 					    &nlk_sk(sk)->node,
 					    netlink_rhashtable_params);
@@ -1103,7 +1103,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	    unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
 		goto err;
 
-	nlk_sk(sk)->portid = portid;
+	nlk_sk(sk)->rhash_portid = portid;
 	sock_hold(sk);
 
 	err = __netlink_insert(table, sk);
@@ -1115,10 +1115,12 @@ static int netlink_insert(struct sock *sk, u32 portid)
 			err = -EOVERFLOW;
 		if (err == -EEXIST)
 			err = -EADDRINUSE;
-		nlk_sk(sk)->portid = 0;
 		sock_put(sk);
+		goto err;
 	}
 
+	nlk_sk(sk)->portid = portid;
+
 err:
 	release_sock(sk);
 	return err;
@@ -3255,7 +3257,7 @@ static inline u32 netlink_hash(const void *data, u32 len, u32 seed)
 	const struct netlink_sock *nlk = data;
 	struct netlink_compare_arg arg;
 
-	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->portid);
+	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->rhash_portid);
 	return jhash2((u32 *)&arg, netlink_compare_arg_len / sizeof(u32), seed);
 }
 
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 8900840..c96dfa3 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -25,6 +25,7 @@ struct netlink_ring {
 struct netlink_sock {
 	/* struct sock has to be the first member of netlink_sock */
 	struct sock		sk;
+	u32			rhash_portid;
 	u32			portid;
 	u32			dst_portid;
 	u32			dst_group;
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
