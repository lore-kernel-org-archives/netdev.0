From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH] netlink: Do not schedule work from sk_destruct
Date: Mon, 5 Dec 2016 15:26:00 +0800
Message-ID: <20161205072600.GA10204@gondor.apana.org.au>
References: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
 <CAM_iQpUSSc6xvAd3u5C3d=xk_yL4LUBgui7pgK5AHxJ8LP363A@mail.gmail.com>
 <CAM_iQpWo42AnAT-LMJNSOL=3NQswRwHxPNC_4FAk3teAPEQDJg@mail.gmail.com>
 <20161205071946.GB9496@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Bob Copeland <me@bobcopeland.com>,
        Tom Herbert <tom@herbertland.com>,
        David Decotigny <decot@googlers.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161205071946.GB9496@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2016 at 03:19:46PM +0800, Herbert Xu wrote:
>
> Thanks for the patch.  It'll obviously work but I wanted avoid that
> because it penalises the common path for the rare case.
> 
> Andrey, please try this patch and let me know if it's any better.
> 
> ---8<---
> Subject: netlink: Do not schedule work from sk_destruct

Crap, I screwed it up again.  Here is a v2 which moves the atomic
call into the RCU callback as otherwise the socket can be freed from
another path while we await the RCU callback.

---8<---
It is wrong to schedule a work from sk_destruct using the socket
as the memory reserve because the socket will be freed immediately
after the return from sk_destruct.

Instead we should do the deferral prior to sk_free.

This patch does just that.

Fixes: 707693c8a498 ("netlink: Call cb->done from a worker thread")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 602e5eb..463f5cf 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -322,11 +322,13 @@ static void netlink_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	sk_mem_charge(sk, skb->truesize);
 }
 
-static void __netlink_sock_destruct(struct sock *sk)
+static void netlink_sock_destruct(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (nlk->cb_running) {
+		if (nlk->cb.done)
+			nlk->cb.done(&nlk->cb);
 		module_put(nlk->cb.module);
 		kfree_skb(nlk->cb.skb);
 	}
@@ -348,21 +350,7 @@ static void netlink_sock_destruct_work(struct work_struct *work)
 	struct netlink_sock *nlk = container_of(work, struct netlink_sock,
 						work);
 
-	nlk->cb.done(&nlk->cb);
-	__netlink_sock_destruct(&nlk->sk);
-}
-
-static void netlink_sock_destruct(struct sock *sk)
-{
-	struct netlink_sock *nlk = nlk_sk(sk);
-
-	if (nlk->cb_running && nlk->cb.done) {
-		INIT_WORK(&nlk->work, netlink_sock_destruct_work);
-		schedule_work(&nlk->work);
-		return;
-	}
-
-	__netlink_sock_destruct(sk);
+	sk_free(&nlk->sk);
 }
 
 /* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ bad on
@@ -664,11 +652,21 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	goto out;
 }
 
-static void deferred_put_nlk_sk(struct rcu_head *head)
+static void deferred_free_nlk_sk(struct rcu_head *head)
 {
 	struct netlink_sock *nlk = container_of(head, struct netlink_sock, rcu);
+	struct sock *sk = &nlk->sk;
+
+	if (!atomic_dec_and_test(&sk->sk_refcnt))
+		return;
+
+	if (nlk->cb_running && nlk->cb.done) {
+		INIT_WORK(&nlk->work, netlink_sock_destruct_work);
+		schedule_work(&nlk->work);
+		return;
+	}
 
-	sock_put(&nlk->sk);
+	sk_free(sk);
 }
 
 static int netlink_release(struct socket *sock)
@@ -743,7 +741,7 @@ static int netlink_release(struct socket *sock)
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
 	local_bh_enable();
-	call_rcu(&nlk->rcu, deferred_put_nlk_sk);
+	call_rcu(&nlk->rcu, deferred_free_nlk_sk);
 	return 0;
 }
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
