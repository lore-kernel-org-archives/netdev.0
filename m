From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Mon, 28 Nov 2016 19:22:12 +0800
Message-ID: <20161128112211.GA990@gondor.apana.org.au>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
 <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+7arMOHSwDhE5npH_82R9LTNrmny6jK1H-fkW2+9Jcg@mail.gmail.com>
 <1480213570.18162.31.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUnz2kkjOFuk3fKKEYDh54b9WHk1dvH098mGtrGTPjZFQ@mail.gmail.com>
 <1480263824.18162.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXB_LRqE83cWwU0ZDckLWPrMcZg-yD4+NKy+rBVz3YAyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:48989 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753929AbcK1LWo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 06:22:44 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpXB_LRqE83cWwU0ZDckLWPrMcZg-yD4+NKy+rBVz3YAyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 10:53:21PM -0800, Cong Wang wrote:
>
> I just took a deeper look, some user calls rhashtable_destroy() in ->done(),
> so even removing that genl lock is not enough, perhaps we should just
> move it to a work struct like what Daniel does for the tcf_proto, but that is
> ugly... I don't know if RCU provides any API to execute the callback in process
> context.

I looked into doing it without a worker struct, but basically it
means that we'd have to add more crap to the common code path for
what is essentially a very rare case.

So I think we should go with the worker struct because all we lose
is a bit of memory.

---8<---
netlink: Call cb->done from a worker thread

The cb->done interface expects to be called in process context.
This was broken by the netlink RCU conversion.  This patch fixes
it by adding a worker struct to make the cb->done call where
necessary.

Fixes: 21e4902aea80 ("netlink: Lockless lookup with RCU grace...")
Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 62bea45..602e5eb 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -322,14 +322,11 @@ static void netlink_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	sk_mem_charge(sk, skb->truesize);
 }
 
-static void netlink_sock_destruct(struct sock *sk)
+static void __netlink_sock_destruct(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 
 	if (nlk->cb_running) {
-		if (nlk->cb.done)
-			nlk->cb.done(&nlk->cb);
-
 		module_put(nlk->cb.module);
 		kfree_skb(nlk->cb.skb);
 	}
@@ -346,6 +343,28 @@ static void netlink_sock_destruct(struct sock *sk)
 	WARN_ON(nlk_sk(sk)->groups);
 }
 
+static void netlink_sock_destruct_work(struct work_struct *work)
+{
+	struct netlink_sock *nlk = container_of(work, struct netlink_sock,
+						work);
+
+	nlk->cb.done(&nlk->cb);
+	__netlink_sock_destruct(&nlk->sk);
+}
+
+static void netlink_sock_destruct(struct sock *sk)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+
+	if (nlk->cb_running && nlk->cb.done) {
+		INIT_WORK(&nlk->work, netlink_sock_destruct_work);
+		schedule_work(&nlk->work);
+		return;
+	}
+
+	__netlink_sock_destruct(sk);
+}
+
 /* This lock without WQ_FLAG_EXCLUSIVE is good on UP and it is _very_ bad on
  * SMP. Look, when several writers sleep and reader wakes them up, all but one
  * immediately hit write lock and grab all the cpus. Exclusive sleep solves
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 3cfd6cc..4fdb383 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -3,6 +3,7 @@
 
 #include <linux/rhashtable.h>
 #include <linux/atomic.h>
+#include <linux/workqueue.h>
 #include <net/sock.h>
 
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
@@ -33,6 +34,7 @@ struct netlink_sock {
 
 	struct rhash_head	node;
 	struct rcu_head		rcu;
+	struct work_struct	work;
 };
 
 static inline struct netlink_sock *nlk_sk(struct sock *sk)

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
