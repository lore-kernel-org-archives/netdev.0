From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: use-after-free in worker_thread
Date: Mon, 5 Dec 2016 15:19:46 +0800
Message-ID: <20161205071946.GB9496@gondor.apana.org.au>
References: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
 <CAM_iQpUSSc6xvAd3u5C3d=xk_yL4LUBgui7pgK5AHxJ8LP363A@mail.gmail.com>
 <CAM_iQpWo42AnAT-LMJNSOL=3NQswRwHxPNC_4FAk3teAPEQDJg@mail.gmail.com>
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
In-Reply-To: <CAM_iQpWo42AnAT-LMJNSOL=3NQswRwHxPNC_4FAk3teAPEQDJg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 03, 2016 at 10:14:48AM -0800, Cong Wang wrote:
> On Sat, Dec 3, 2016 at 9:41 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Sat, Dec 3, 2016 at 4:56 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> >> Hi!
> >>
> >> I'm seeing lots of the following error reports while running the
> >> syzkaller fuzzer.
> >>
> >> Reports appeared when I updated to 3c49de52 (Dec 2) from 2caceb32 (Dec 1).
> >>
> >> ==================================================================
> >> BUG: KASAN: use-after-free in worker_thread+0x17d8/0x18a0
> >> Read of size 8 at addr ffff880067f3ecd8 by task kworker/3:1/774
> >>
> >> page:ffffea00019fce00 count:1 mapcount:0 mapping:          (null)
> >> index:0xffff880067f39c10 compound_mapcount: 0
> >> flags: 0x500000000004080(slab|head)
> >> page dumped because: kasan: bad access detected
> >>
> >> CPU: 3 PID: 774 Comm: kworker/3:1 Not tainted 4.9.0-rc7+ #66
> >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >>  ffff88006c267838 ffffffff81f882da ffffffff6c25e338 1ffff1000d84ce9a
> >>  ffffed000d84ce92 ffff88006c25e340 0000000041b58ab3 ffffffff8541e198
> >>  ffffffff81f88048 0000000100000000 0000000041b58ab3 ffffffff853d3ee8
> >> Call Trace:
> >>  [<     inline     >] __dump_stack lib/dump_stack.c:15
> >>  [<ffffffff81f882da>] dump_stack+0x292/0x398 lib/dump_stack.c:51
> >>  [<     inline     >] describe_address mm/kasan/report.c:262
> >>  [<ffffffff817e50d1>] kasan_report_error+0x121/0x560 mm/kasan/report.c:368
> >>  [<     inline     >] kasan_report mm/kasan/report.c:390
> >>  [<ffffffff817e560e>] __asan_report_load8_noabort+0x3e/0x40
> >> mm/kasan/report.c:411
> >>  [<ffffffff81329b88>] worker_thread+0x17d8/0x18a0 kernel/workqueue.c:2228
> >>  [<ffffffff8133ebf3>] kthread+0x323/0x3e0 kernel/kthread.c:209
> >>  [<ffffffff84a2a22a>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433
> >
> > Heck... this is the pending work vs. sk_destruct() race. :-/
> > We can't wait for the work in RCU callback, let me think about it...

Sorry, my patch was obviously crap as it was trying to delay the
freeing of a socket from sk_destruct which can't be done.

> Please try the attached patch, I only did compile test, I can't access
> my desktop now, so can't do further tests.

Thanks for the patch.  It'll obviously work but I wanted avoid that
because it penalises the common path for the rare case.

Andrey, please try this patch and let me know if it's any better.

---8<---
Subject: netlink: Do not schedule work from sk_destruct

It is wrong to schedule a work from sk_destruct using the socket
as the memory reserve because the socket will be freed immediately
after the return from sk_destruct.

Instead we should do the deferral prior to sk_free.

This patch does just that.

Fixes: 707693c8a498 ("netlink: Call cb->done from a worker thread")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 602e5eb..8a642c5 100644
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
@@ -664,11 +652,17 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	goto out;
 }
 
-static void deferred_put_nlk_sk(struct rcu_head *head)
+static void deferred_free_nlk_sk(struct rcu_head *head)
 {
 	struct netlink_sock *nlk = container_of(head, struct netlink_sock, rcu);
 
-	sock_put(&nlk->sk);
+	if (nlk->cb_running && nlk->cb.done) {
+		INIT_WORK(&nlk->work, netlink_sock_destruct_work);
+		schedule_work(&nlk->work);
+		return;
+	}
+
+	sk_free(&nlk->sk);
 }
 
 static int netlink_release(struct socket *sock)
@@ -743,7 +737,9 @@ static int netlink_release(struct socket *sock)
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
 	local_bh_enable();
-	call_rcu(&nlk->rcu, deferred_put_nlk_sk);
+
+	if (atomic_dec_and_test(&sk->sk_refcnt))
+		call_rcu(&nlk->rcu, deferred_free_nlk_sk);
 	return 0;
 }
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
