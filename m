From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] net/sctp: always initialise sctp_ht_iter::start_fail
Date: Sat, 23 Jul 2016 11:52:23 +0200
Message-ID: <1469267543-24650-1-git-send-email-vegard.nossum@oracle.com>
Cc: linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@oracle.com>,
	Xin Long <lucien.xin@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Eric W. Biederman" <ebiederm@xmission.com>, stable@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

seq_read() can call ->start() twice on the same iterator more than once
(e.g. once through traverse() and once in seq_read() itself).

We should initialize sctp_ht_iter::start_fail to zero if ->start()
succeeds, otherwise it's possible that we leave an old value of 1 there,
which will cause ->stop() to not call sctp_transport_walk_stop(), which
causes all sorts of problems like not calling rcu_read_unlock() (and
preempt_enable()), eventually leading to more warnings like this:

    BUG: sleeping function called from invalid context at mm/slab.h:388
    in_atomic(): 0, irqs_disabled(): 0, pid: 16551, name: trinity-c2
    Preemption disabled at:[<ffffffff819bceb6>] rhashtable_walk_start+0x46/0x150

     [<ffffffff81149abb>] preempt_count_add+0x1fb/0x280
     [<ffffffff83295892>] _raw_spin_lock+0x12/0x40
     [<ffffffff819bceb6>] rhashtable_walk_start+0x46/0x150
     [<ffffffff82ec665f>] sctp_transport_walk_start+0x2f/0x60
     [<ffffffff82edda1d>] sctp_transport_seq_start+0x4d/0x150
     [<ffffffff81439e50>] traverse+0x170/0x850
     [<ffffffff8143aeec>] seq_read+0x7cc/0x1180
     [<ffffffff814f996c>] proc_reg_read+0xbc/0x180
     [<ffffffff813d0384>] do_loop_readv_writev+0x134/0x210
     [<ffffffff813d2a95>] do_readv_writev+0x565/0x660
     [<ffffffff813d6857>] vfs_readv+0x67/0xa0
     [<ffffffff813d6c16>] do_preadv+0x126/0x170
     [<ffffffff813d710c>] SyS_preadv+0xc/0x10
     [<ffffffff8100334c>] do_syscall_64+0x19c/0x410
     [<ffffffff83296225>] return_from_SYSCALL_64+0x0/0x6a
     [<ffffffffffffffff>] 0xffffffffffffffff

(Notice that this is a subtly different stacktrace from the previous bug
I reported.)

Cc: Xin Long <lucien.xin@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: stable@vger.kernel.org
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/sctp/proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 4cb5aed..ef8ba77 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -293,6 +293,7 @@ static void *sctp_transport_seq_start(struct seq_file *seq, loff_t *pos)
 		return ERR_PTR(err);
 	}
 
+	iter->start_fail = 0;
 	return sctp_transport_get_idx(seq_file_net(seq), &iter->hti, *pos);
 }
 
-- 
1.9.1
