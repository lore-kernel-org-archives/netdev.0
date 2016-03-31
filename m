From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 1/4] tun: add socket locking around sk_{attach,detach}_filter
Date: Fri,  1 Apr 2016 01:29:39 +0200
Message-ID: <1459466982-20432-2-git-send-email-hannes@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, sasha.levin@oracle.com,
	daniel@iogearbox.net, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59112 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753103AbcCaX3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:29:54 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 08DA221A56
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 19:29:54 -0400 (EDT)
In-Reply-To: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Changelog stolen from Daniel Borkmann:]

Sasha Levin reported a suspicious rcu_dereference_protected() warning
found while fuzzing with trinity that is similar to this one:

  [   52.765684] net/core/filter.c:2262 suspicious rcu_dereference_protected() usage!
  [   52.765688] other info that might help us debug this:
  [   52.765695] rcu_scheduler_active = 1, debug_locks = 1
  [   52.765701] 1 lock held by a.out/1525:
  [   52.765704]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff816a64b7>] rtnl_lock+0x17/0x20
  [   52.765721] stack backtrace:
  [   52.765728] CPU: 1 PID: 1525 Comm: a.out Not tainted 4.5.0+ #264
  [...]
  [   52.765768] Call Trace:
  [   52.765775]  [<ffffffff813e488d>] dump_stack+0x85/0xc8
  [   52.765784]  [<ffffffff810f2fa5>] lockdep_rcu_suspicious+0xd5/0x110
  [   52.765792]  [<ffffffff816afdc2>] sk_detach_filter+0x82/0x90
  [   52.765801]  [<ffffffffa0883425>] tun_detach_filter+0x35/0x90 [tun]
  [   52.765810]  [<ffffffffa0884ed4>] __tun_chr_ioctl+0x354/0x1130 [tun]
  [   52.765818]  [<ffffffff8136fed0>] ? selinux_file_ioctl+0x130/0x210
  [   52.765827]  [<ffffffffa0885ce3>] tun_chr_ioctl+0x13/0x20 [tun]
  [   52.765834]  [<ffffffff81260ea6>] do_vfs_ioctl+0x96/0x690
  [   52.765843]  [<ffffffff81364af3>] ? security_file_ioctl+0x43/0x60
  [   52.765850]  [<ffffffff81261519>] SyS_ioctl+0x79/0x90
  [   52.765858]  [<ffffffff81003ba2>] do_syscall_64+0x62/0x140
  [   52.765866]  [<ffffffff817d563f>] entry_SYSCALL64_slow_path+0x25/0x25

Same can be triggered with PROVE_RCU (+ PROVE_RCU_REPEATEDLY) enabled
from tun_attach_filter() when user space calls ioctl(tun_fd, TUN{ATTACH,
DETACH}FILTER, ...) for adding/removing a BPF filter on tap devices.

Since the fix in commit f91ff5b9ff52 ("net: sk_{detach|attach}_filter()
rcu fixes") sk_attach_filter()/sk_detach_filter() now dereferences the
filter with rcu_dereference_protected(), checking whether socket lock
is held in control path.

Since its introduction in commit 994051625981 ("tun: socket
filter support"), tap filters are managed under RTNL lock from
__tun_chr_ioctl(). Thus the sock_owned_by_user(sk) doesn't apply in this
specific case and therefore triggers the false positive.

Simply holding the locks during the filter updates will fix this problem.

Fixes: 994051625981 ("tun: socket filter support")
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/tun.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index afdf950617c36e..dccbbacbbc7f02 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -622,7 +622,11 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 
 	/* Re-attach the filter to persist device */
 	if (!skip_filter && (tun->filter_attached == true)) {
+		bool slow;
+
+		slow = lock_sock_fast(tfile->socket.sk);
 		err = sk_attach_filter(&tun->fprog, tfile->socket.sk);
+		unlock_sock_fast(tfile->socket.sk, slow);
 		if (!err)
 			goto out;
 	}
@@ -1821,8 +1825,12 @@ static void tun_detach_filter(struct tun_struct *tun, int n)
 	struct tun_file *tfile;
 
 	for (i = 0; i < n; i++) {
+		bool slow;
+
 		tfile = rtnl_dereference(tun->tfiles[i]);
+		slow = lock_sock_fast(tfile->socket.sk);
 		sk_detach_filter(tfile->socket.sk);
+		unlock_sock_fast(tfile->socket.sk, slow);
 	}
 
 	tun->filter_attached = false;
@@ -1834,8 +1842,12 @@ static int tun_attach_filter(struct tun_struct *tun)
 	struct tun_file *tfile;
 
 	for (i = 0; i < tun->numqueues; i++) {
+		bool slow;
+
 		tfile = rtnl_dereference(tun->tfiles[i]);
+		slow = lock_sock_fast(tfile->socket.sk);
 		ret = sk_attach_filter(&tun->fprog, tfile->socket.sk);
+		unlock_sock_fast(tfile->socket.sk, slow);
 		if (ret) {
 			tun_detach_filter(tun, i);
 			return ret;
-- 
2.5.5
