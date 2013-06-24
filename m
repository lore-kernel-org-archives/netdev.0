From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH crypto] crypto: algboss: fix NULL pointer dereference
 in cryptomgr_probe
Date: Mon, 24 Jun 2013 21:59:43 +0800
Message-ID: <20130624135943.GA11776@gondor.apana.org.au>
References: <1371715221-27192-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46453 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751006Ab3FXN7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 09:59:46 -0400
Content-Disposition: inline
In-Reply-To: <1371715221-27192-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel:

Can you see if this patch helps?

commit f2baa471deead85e3285f23032609cd7bd52f197
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Jun 24 21:57:42 2013 +0800

    crypto: algboss - Hold ref count on larval
    
    On Thu, Jun 20, 2013 at 10:00:21AM +0200, Daniel Borkmann wrote:
    > After having fixed a NULL pointer dereference in SCTP 1abd165e ("net:
    > sctp: fix NULL pointer dereference in socket destruction"), I ran into
    > the following NULL pointer dereference in the crypto subsystem with
    > the same reproducer, easily hit each time:
    >
    > BUG: unable to handle kernel NULL pointer dereference at (null)
    > IP: [<ffffffff81070321>] __wake_up_common+0x31/0x90
    > PGD 0
    > Oops: 0000 [#1] SMP
    > Modules linked in: padlock_sha(F-) sha256_generic(F) sctp(F) libcrc32c(F) [..]
    > CPU: 6 PID: 3326 Comm: cryptomgr_probe Tainted: GF            3.10.0-rc5+ #1
    > Hardware name: Dell Inc. PowerEdge T410/0H19HD, BIOS 1.6.3 02/01/2011
    > task: ffff88007b6cf4e0 ti: ffff88007b7cc000 task.ti: ffff88007b7cc000
    > RIP: 0010:[<ffffffff81070321>]  [<ffffffff81070321>] __wake_up_common+0x31/0x90
    > RSP: 0018:ffff88007b7cde08  EFLAGS: 00010082
    > RAX: ffffffffffffffe8 RBX: ffff88003756c130 RCX: 0000000000000000
    > RDX: 0000000000000000 RSI: 0000000000000003 RDI: ffff88003756c130
    > RBP: ffff88007b7cde48 R08: 0000000000000000 R09: ffff88012b173200
    > R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000282
    > R13: ffff88003756c138 R14: 0000000000000000 R15: 0000000000000000
    > FS:  0000000000000000(0000) GS:ffff88012fc60000(0000) knlGS:0000000000000000
    > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
    > CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000000007e0
    > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
    > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
    > Stack:
    >  ffff88007b7cde28 0000000300000000 ffff88007b7cde28 ffff88003756c130
    >  0000000000000282 ffff88003756c128 ffffffff81227670 0000000000000000
    >  ffff88007b7cde78 ffffffff810722b7 ffff88007cdcf000 ffffffff81a90540
    > Call Trace:
    >  [<ffffffff81227670>] ? crypto_alloc_pcomp+0x20/0x20
    >  [<ffffffff810722b7>] complete_all+0x47/0x60
    >  [<ffffffff81227708>] cryptomgr_probe+0x98/0xc0
    >  [<ffffffff81227670>] ? crypto_alloc_pcomp+0x20/0x20
    >  [<ffffffff8106760e>] kthread+0xce/0xe0
    >  [<ffffffff81067540>] ? kthread_freezable_should_stop+0x70/0x70
    >  [<ffffffff815450dc>] ret_from_fork+0x7c/0xb0
    >  [<ffffffff81067540>] ? kthread_freezable_should_stop+0x70/0x70
    > Code: 41 56 41 55 41 54 53 48 83 ec 18 66 66 66 66 90 89 75 cc 89 55 c8
    >       4c 8d 6f 08 48 8b 57 08 41 89 cf 4d 89 c6 48 8d 42 e
    > RIP  [<ffffffff81070321>] __wake_up_common+0x31/0x90
    >  RSP <ffff88007b7cde08>
    > CR2: 0000000000000000
    > ---[ end trace b495b19270a4d37e ]---
    >
    > My assumption is that the following is happening: the minimal SCTP
    > tool runs under ``echo 1 > /proc/sys/net/sctp/auth_enable'', hence
    > it's making use of crypto_alloc_hash() via sctp_auth_init_hmacs().
    > It forks itself, heavily allocates, binds, listens and waits in
    > accept on sctp sockets, and then randomly kills some of them (no
    > need for an actual client in this case to hit this). Then, again,
    > allocating, binding, etc, and then killing child processes.
    >
    > The problem that might be happening here is that cryptomgr requests
    > the module to probe/load through cryptomgr_schedule_probe(), but
    > before the thread handler cryptomgr_probe() returns, we return from
    > the wait_for_completion_interruptible() function and probably already
    > have cleared up larval, thus we run into a NULL pointer dereference
    > when in cryptomgr_probe() complete_all() is being called.
    >
    > If we wait with wait_for_completion() instead, this panic will not
    > occur anymore. This is valid, because in case a signal is pending,
    > cryptomgr_probe() returns from probing anyway with properly calling
    > complete_all().
    
    The use of wait_for_completion_interruptible is intentional so that
    we don't lock up the thread if a bug causes us to never wake up.
    
    This bug is caused by the helper thread using the larval without
    holding a reference count on it.  If the helper thread completes
    after the original thread requesting for help has gone away and
    destroyed the larval, then we get the crash above.
    
    So the fix is to hold a reference count on the larval.
    
    Cc: <stable@vger.kernel.org> # 3.6+
    Reported-by: Daniel Borkmann <dborkman@redhat.com>
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/crypto/algboss.c b/crypto/algboss.c
index 769219b..76fc0b2 100644
--- a/crypto/algboss.c
+++ b/crypto/algboss.c
@@ -45,10 +45,9 @@ struct cryptomgr_param {
 		} nu32;
 	} attrs[CRYPTO_MAX_ATTRS];
 
-	char larval[CRYPTO_MAX_ALG_NAME];
 	char template[CRYPTO_MAX_ALG_NAME];
 
-	struct completion *completion;
+	struct crypto_larval *larval;
 
 	u32 otype;
 	u32 omask;
@@ -87,7 +86,8 @@ static int cryptomgr_probe(void *data)
 	crypto_tmpl_put(tmpl);
 
 out:
-	complete_all(param->completion);
+	complete_all(&param->larval->completion);
+	crypto_alg_put(&param->larval->alg);
 	kfree(param);
 	module_put_and_exit(0);
 }
@@ -187,18 +187,19 @@ static int cryptomgr_schedule_probe(struct crypto_larval *larval)
 	param->otype = larval->alg.cra_flags;
 	param->omask = larval->mask;
 
-	memcpy(param->larval, larval->alg.cra_name, CRYPTO_MAX_ALG_NAME);
-
-	param->completion = &larval->completion;
+	crypto_alg_get(&larval->alg);
+	param->larval = larval;
 
 	thread = kthread_run(cryptomgr_probe, param, "cryptomgr_probe");
 	if (IS_ERR(thread))
-		goto err_free_param;
+		goto err_put_larval;
 
 	wait_for_completion_interruptible(&larval->completion);
 
 	return NOTIFY_STOP;
 
+err_put_larval:
+	crypto_alg_put(&larval->alg);
 err_free_param:
 	kfree(param);
 err_put_module:
diff --git a/crypto/api.c b/crypto/api.c
index 033a714..3b61803 100644
--- a/crypto/api.c
+++ b/crypto/api.c
@@ -34,12 +34,6 @@ EXPORT_SYMBOL_GPL(crypto_alg_sem);
 BLOCKING_NOTIFIER_HEAD(crypto_chain);
 EXPORT_SYMBOL_GPL(crypto_chain);
 
-static inline struct crypto_alg *crypto_alg_get(struct crypto_alg *alg)
-{
-	atomic_inc(&alg->cra_refcnt);
-	return alg;
-}
-
 struct crypto_alg *crypto_mod_get(struct crypto_alg *alg)
 {
 	return try_module_get(alg->cra_module) ? crypto_alg_get(alg) : NULL;
diff --git a/crypto/internal.h b/crypto/internal.h
index 9ebedae..bd39bfc 100644
--- a/crypto/internal.h
+++ b/crypto/internal.h
@@ -103,6 +103,12 @@ int crypto_register_notifier(struct notifier_block *nb);
 int crypto_unregister_notifier(struct notifier_block *nb);
 int crypto_probing_notify(unsigned long val, void *v);
 
+static inline struct crypto_alg *crypto_alg_get(struct crypto_alg *alg)
+{
+	atomic_inc(&alg->cra_refcnt);
+	return alg;
+}
+
 static inline void crypto_alg_put(struct crypto_alg *alg)
 {
 	if (atomic_dec_and_test(&alg->cra_refcnt) && alg->cra_destroy)

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
