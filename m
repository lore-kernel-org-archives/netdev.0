From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] pptp: avoid releasing the sock too early
Date: Mon, 14 Sep 2015 11:40:29 -0400
Message-ID: <1442245229-31099-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: xeb@mail.ru, ebiederm@xmission.com, davem@davemloft.net,
	simon@farnz.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we're using RCU we can't free the sock structure before RCU lets us,
otherwise we're risking getting use-after-frees accessing it:

[982915.329359] BUG: KASan: use after free in pptp_connect+0xbe3/0xc10 at addr ffff88006903e540
[982915.333044] Read of size 2 by task trinity-c4/27338
[982915.335176] page:ffffea0001a40f80 count:0 mapcount:0 mapping:          (null) index:0x0
[982915.338684] flags: 0x1fffff80000000()
[982915.340331] page dumped because: kasan: bad access detected
[982915.342766] CPU: 1 PID: 27338 Comm: trinity-c4 Not tainted 4.2.0-next-20150911-sasha-00043-g353d875-dirty #2545
[982915.347043]  00000000000007cd ffff88025625fbf0 ffffffffa8fc62ba ffff88025625fc78
[982915.349843]  ffff88025625fc68 ffffffffa77e206e ffffed004c23799b ffff8802611bcce0
[982915.353106]  0000000000000282 0000000000000000 ffff88025625fc60 ffffffffa7473789
[982915.357338] Call Trace:
[982915.358451] dump_stack (lib/dump_stack.c:52)
[982915.360649] kasan_report_error (mm/kasan/report.c:132 mm/kasan/report.c:193)
[982915.363184] ? __lock_is_held (kernel/locking/lockdep.c:3491)
[982915.365555] __asan_report_load2_noabort (mm/kasan/report.c:249)
[982915.368322] ? rcu_read_lock_held (kernel/rcu/update.c:270)
[982915.370956] ? pptp_connect (drivers/net/ppp/pptp.c:123 drivers/net/ppp/pptp.c:445)
[982915.373322] pptp_connect (drivers/net/ppp/pptp.c:123 drivers/net/ppp/pptp.c:445)
[982915.375654] ? pptp_connect (drivers/net/ppp/pptp.c:445)
[982915.378180] ? pptp_bind (drivers/net/ppp/pptp.c:433)
[982915.380581] ? __might_fault (mm/memory.c:3797 (discriminator 1))
[982915.383047] ? __might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3795)
[982915.385407] SYSC_connect (net/socket.c:1549)
[982915.387598] ? SYSC_bind (net/socket.c:1532)
[982915.389677] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[982915.392286] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[982915.394779] ? alarm_setitimer (kernel/time/itimer.c:271)
[982915.397236] ? do_setitimer (kernel/time/itimer.c:254)
[982915.399620] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[982915.402366] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[982915.405302] ? lockdep_sys_exit_thunk (arch/x86/entry/thunk_64.S:44)
[982915.407928] SyS_connect (net/socket.c:1530)
[982915.410141] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:186)
[982915.413286] Memory state around the buggy address:
[982915.415530]  ffff88006903e400: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[982915.418656]  ffff88006903e480: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[982915.421680] >ffff88006903e500: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[982915.424792]                                            ^
[982915.427125]  ffff88006903e580: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[982915.430027]  ffff88006903e600: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 drivers/net/ppp/pptp.c   |    9 ++++++++-
 include/linux/if_pppox.h |    1 +
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 686f37d..cb7a029 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -517,6 +517,13 @@ static int pptp_getname(struct socket *sock, struct sockaddr *uaddr,
 	return 0;
 }
 
+static void pptp_release_cb(struct rcu_head *rcu)
+{
+	struct pppox_sock *p = container_of(rcu, struct pppox_sock, rcu);
+
+	sock_put(sk_pppox(p));
+}
+
 static int pptp_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
@@ -545,7 +552,7 @@ static int pptp_release(struct socket *sock)
 	sock->sk = NULL;
 
 	release_sock(sk);
-	sock_put(sk);
+	call_rcu(&po->rcu, pptp_release_cb);
 
 	return error;
 }
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index b49cf92..ba9c378 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -55,6 +55,7 @@ struct pppox_sock {
 		struct pptp_opt  pptp;
 	} proto;
 	__be16			num;
+	struct rcu_head rcu;
 };
 #define pppoe_dev	proto.pppoe.dev
 #define pppoe_ifindex	proto.pppoe.ifindex
-- 
1.7.10.4
