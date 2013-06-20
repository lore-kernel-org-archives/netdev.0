From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH crypto] crypto: algboss: fix NULL pointer dereference in cryptomgr_probe
Date: Thu, 20 Jun 2013 10:00:21 +0200
Message-ID: <1371715221-27192-1-git-send-email-dborkman@redhat.com>
Cc: linux-crypto@vger.kernel.org, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After having fixed a NULL pointer dereference in SCTP 1abd165e ("net:
sctp: fix NULL pointer dereference in socket destruction"), I ran into
the following NULL pointer dereference in the crypto subsystem with
the same reproducer, easily hit each time:

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff81070321>] __wake_up_common+0x31/0x90
PGD 0
Oops: 0000 [#1] SMP
Modules linked in: padlock_sha(F-) sha256_generic(F) sctp(F) libcrc32c(F) [..]
CPU: 6 PID: 3326 Comm: cryptomgr_probe Tainted: GF            3.10.0-rc5+ #1
Hardware name: Dell Inc. PowerEdge T410/0H19HD, BIOS 1.6.3 02/01/2011
task: ffff88007b6cf4e0 ti: ffff88007b7cc000 task.ti: ffff88007b7cc000
RIP: 0010:[<ffffffff81070321>]  [<ffffffff81070321>] __wake_up_common+0x31/0x90
RSP: 0018:ffff88007b7cde08  EFLAGS: 00010082
RAX: ffffffffffffffe8 RBX: ffff88003756c130 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000003 RDI: ffff88003756c130
RBP: ffff88007b7cde48 R08: 0000000000000000 R09: ffff88012b173200
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000282
R13: ffff88003756c138 R14: 0000000000000000 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88012fc60000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 ffff88007b7cde28 0000000300000000 ffff88007b7cde28 ffff88003756c130
 0000000000000282 ffff88003756c128 ffffffff81227670 0000000000000000
 ffff88007b7cde78 ffffffff810722b7 ffff88007cdcf000 ffffffff81a90540
Call Trace:
 [<ffffffff81227670>] ? crypto_alloc_pcomp+0x20/0x20
 [<ffffffff810722b7>] complete_all+0x47/0x60
 [<ffffffff81227708>] cryptomgr_probe+0x98/0xc0
 [<ffffffff81227670>] ? crypto_alloc_pcomp+0x20/0x20
 [<ffffffff8106760e>] kthread+0xce/0xe0
 [<ffffffff81067540>] ? kthread_freezable_should_stop+0x70/0x70
 [<ffffffff815450dc>] ret_from_fork+0x7c/0xb0
 [<ffffffff81067540>] ? kthread_freezable_should_stop+0x70/0x70
Code: 41 56 41 55 41 54 53 48 83 ec 18 66 66 66 66 90 89 75 cc 89 55 c8
      4c 8d 6f 08 48 8b 57 08 41 89 cf 4d 89 c6 48 8d 42 e
RIP  [<ffffffff81070321>] __wake_up_common+0x31/0x90
 RSP <ffff88007b7cde08>
CR2: 0000000000000000
---[ end trace b495b19270a4d37e ]---

My assumption is that the following is happening: the minimal SCTP
tool runs under ``echo 1 > /proc/sys/net/sctp/auth_enable'', hence
it's making use of crypto_alloc_hash() via sctp_auth_init_hmacs().
It forks itself, heavily allocates, binds, listens and waits in
accept on sctp sockets, and then randomly kills some of them (no
need for an actual client in this case to hit this). Then, again,
allocating, binding, etc, and then killing child processes.

The problem that might be happening here is that cryptomgr requests
the module to probe/load through cryptomgr_schedule_probe(), but
before the thread handler cryptomgr_probe() returns, we return from
the wait_for_completion_interruptible() function and probably already
have cleared up larval, thus we run into a NULL pointer dereference
when in cryptomgr_probe() complete_all() is being called.

If we wait with wait_for_completion() instead, this panic will not
occur anymore. This is valid, because in case a signal is pending,
cryptomgr_probe() returns from probing anyway with properly calling
complete_all().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1->v2:
  - Submitting as non-RFC
  - Slightly improving commit message

 crypto/algboss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/algboss.c b/crypto/algboss.c
index 769219b..eee89a5 100644
--- a/crypto/algboss.c
+++ b/crypto/algboss.c
@@ -195,7 +195,7 @@ static int cryptomgr_schedule_probe(struct crypto_larval *larval)
 	if (IS_ERR(thread))
 		goto err_free_param;
 
-	wait_for_completion_interruptible(&larval->completion);
+	wait_for_completion(&larval->completion);
 
 	return NOTIFY_STOP;
 
-- 
1.7.11.7
