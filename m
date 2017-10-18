From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net-tun: fix panics at dismantle time
Date: Wed, 18 Oct 2017 12:12:09 -0700
Message-ID: <1508353929.31614.136.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Petar Penkov <peterpenkov96@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:46159 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdJRTML (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 15:12:11 -0400
Received: by mail-it0-f68.google.com with SMTP id f187so7578328itb.1
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 12:12:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller got crashes at dismantle time [1]

It is not correct to test (tun->flags & IFF_NAPI) in tun_napi_disable()
and tun_napi_del() : Each tun_file can have different mode, depending
on how they were created.

Similarly I have changed tun_get_user() and tun_poll_controller()
to use the new tfile->napi_enabled boolean.

[  154.331360] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  154.339220] IP: [<ffffffff9634cad6>] hrtimer_active+0x26/0x60
[  154.344983] PGD 0 
[  154.347009] Oops: 0000 [#1] SMP 
[  154.350680] gsmi: Log Shutdown Reason 0x03
[  154.379572] task: ffff994719150dc0 ti: ffff99475c0ae000 task.ti: ffff99475c0ae000
[  154.387043] RIP: 0010:[<ffffffff9634cad6>]  [<ffffffff9634cad6>] hrtimer_active+0x26/0x60
[  154.395232] RSP: 0018:ffff99475c0afce8  EFLAGS: 00010246
[  154.400542] RAX: ffff994754850ac0 RBX: ffff994753e65408 RCX: ffff994753e65388
[  154.407666] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff994753e65408
[  154.414790] RBP: ffff99475c0afce8 R08: 0000000000000000 R09: 0000000000000000
[  154.421921] R10: ffff99475f6f5910 R11: 0000000000000001 R12: 0000000000000000
[  154.429044] R13: ffff99417deab668 R14: ffff99417deaa780 R15: ffff99475f45dde0
[  154.436174] FS:  0000000000000000(0000) GS:ffff994767a00000(0000) knlGS:0000000000000000
[  154.444249] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  154.449986] CR2: 0000000000000000 CR3: 00000005a8a0e000 CR4: 0000000000022670
[  154.457110] Stack:
[  154.459120]  ffff99475c0afd28 ffffffff9634d614 1000000000000000 0000000000000000
[  154.466598]  ffffe54240000000 ffff994753e65408 ffff994753e653a8 ffff99417deab668
[  154.474067]  ffff99475c0afd48 ffffffff9634d6fd ffff99474c2be678 ffff994753e65398
[  154.481537] Call Trace:
[  154.483985]  [<ffffffff9634d614>] hrtimer_try_to_cancel+0x24/0xf0
[  154.490074]  [<ffffffff9634d6fd>] hrtimer_cancel+0x1d/0x30
[  154.495563]  [<ffffffff96860b3c>] napi_disable+0x3c/0x70
[  154.500875]  [<ffffffff9678ae62>] __tun_detach+0xd2/0x360
[  154.506272]  [<ffffffff9678b117>] tun_chr_close+0x27/0x40
[  154.511669]  [<ffffffff9646ebe6>] __fput+0xd6/0x1e0
[  154.516548]  [<ffffffff9646ed3e>] ____fput+0xe/0x10
[  154.521429]  [<ffffffff963035a2>] task_work_run+0x72/0x90
[  154.526827]  [<ffffffff962e9407>] do_exit+0x317/0xb60
[  154.531879]  [<ffffffff962e9c8f>] do_group_exit+0x3f/0xa0
[  154.537275]  [<ffffffff962e9d07>] SyS_exit_group+0x17/0x20
[  154.542769]  [<ffffffff969784be>] entry_SYSCALL_64_fastpath+0x12/0x17

Fixes: 943170998b20 ("net-tun: enable NAPI for TUN/TAP driver")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 57e4c31fa84adc4d9af6ab69a87feac23a8b034e..aef6c7f2f429559ba060b30beb9f729bc71a9c5a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -175,6 +175,7 @@ struct tun_file {
 		unsigned int ifindex;
 	};
 	struct napi_struct napi;
+	bool napi_enabled;
 	struct mutex napi_mutex;	/* Protects access to the above napi */
 	struct list_head next;
 	struct tun_struct *detached;
@@ -276,6 +277,7 @@ static int tun_napi_poll(struct napi_struct *napi, int budget)
 static void tun_napi_init(struct tun_struct *tun, struct tun_file *tfile,
 			  bool napi_en)
 {
+	tfile->napi_enabled = napi_en;
 	if (napi_en) {
 		netif_napi_add(tun->dev, &tfile->napi, tun_napi_poll,
 			       NAPI_POLL_WEIGHT);
@@ -286,13 +288,13 @@ static void tun_napi_init(struct tun_struct *tun, struct tun_file *tfile,
 
 static void tun_napi_disable(struct tun_struct *tun, struct tun_file *tfile)
 {
-	if (tun->flags & IFF_NAPI)
+	if (tfile->napi_enabled)
 		napi_disable(&tfile->napi);
 }
 
 static void tun_napi_del(struct tun_struct *tun, struct tun_file *tfile)
 {
-	if (tun->flags & IFF_NAPI)
+	if (tfile->napi_enabled)
 		netif_napi_del(&tfile->napi);
 }
 
@@ -1055,7 +1057,8 @@ static void tun_poll_controller(struct net_device *dev)
 		rcu_read_lock();
 		for (i = 0; i < tun->numqueues; i++) {
 			tfile = rcu_dereference(tun->tfiles[i]);
-			napi_schedule(&tfile->napi);
+			if (tfile->napi_enabled)
+				napi_schedule(&tfile->napi);
 		}
 		rcu_read_unlock();
 	}
@@ -1749,7 +1752,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		napi_gro_frags(&tfile->napi);
 		local_bh_enable();
 		mutex_unlock(&tfile->napi_mutex);
-	} else if (tun->flags & IFF_NAPI) {
+	} else if (tfile->napi_enabled) {
 		struct sk_buff_head *queue = &tfile->sk.sk_write_queue;
 		int queue_len;
 
