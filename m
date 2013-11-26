From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: netfilter: xt_hashlimit: fix proc entry leak in netns destroy path
Date: Tue, 26 Nov 2013 14:09:47 +0200
Message-ID: <2088236.yE4m0nz1sa@tuxracer>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp9.mail.ru ([94.100.176.54]:53281 "EHLO smtp9.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755276Ab3KZMOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Nov 2013 07:14:33 -0500
Received: from [2a01:6d80:103:13::c3ea:4404] (port=51330 helo=tuxracer.localnet)
	by smtp9.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1VlHXC-0003vR-EL
	for netdev@vger.kernel.org; Tue, 26 Nov 2013 16:14:30 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 32263dd1b43378b4f7d7796ed713f77e95f27e8a
Author: Vitaly E. Lavrov <>
Date:   Mon Dec 24 14:42:17 2012 +0100

    netfilter: xt_hashlimit: fix namespace destroy path

Takes into account fact, that hashlimit_net_exit() called right before
hashlimit_mt_destroy() and fixes destroy path for netns.

However using xt_hashlimit for IPv4 and IPv6 together produces following 
output
on netconsole from one of our servers on netns destroy:

 Pid: 9499, comm: kworker/u:0 Tainted: G        WC O 3.2.0-5-netctl-amd64-
core2
 Call Trace:
  [<ffffffff8104708d>] ? warn_slowpath_common+0x78/0x8c
  [<ffffffff81047139>] ? warn_slowpath_fmt+0x45/0x4a
  [<ffffffff81144a99>] ? remove_proc_entry+0xd8/0x22e
  [<ffffffff810ebbaa>] ? kfree+0x5b/0x6c
  [<ffffffffa043c501>] ? hashlimit_net_exit+0x45/0x8d [xt_hashlimit]
  [<ffffffff8128ab30>] ? ops_exit_list+0x1c/0x44
  [<ffffffff8128b28e>] ? cleanup_net+0xf1/0x180
  [<ffffffff810369fc>] ? should_resched+0x5/0x23
  [<ffffffff8105b8f9>] ? process_one_work+0x161/0x269
  [<ffffffff8105aea5>] ? cwq_activate_delayed_work+0x3c/0x48
  [<ffffffff8105c8c2>] ? worker_thread+0xc2/0x145
  [<ffffffff8105c800>] ? manage_workers.isra.25+0x15b/0x15b
  [<ffffffff8105fa01>] ? kthread+0x76/0x7e
  [<ffffffff813581f4>] ? kernel_thread_helper+0x4/0x10
  [<ffffffff8105f98b>] ? kthread_worker_fn+0x139/0x139
  [<ffffffff813581f0>] ? gs_change+0x13/0x13
 ---[ end trace d8c3cc0ad163ef79 ]---
 ------------[ cut here ]------------
 WARNING: at 
/usr/src/linux-3.2.52/debian/build/source_netctl/fs/proc/generic.c:849
 remove_proc_entry+0x217/0x22e()
 Hardware name:
 remove_proc_entry: removing non-empty directory 'net/ip6t_hashlimit', leaking
at least 'IN-REJECT'

This is due to lack of removal net/ip6t_hashlimit/* entries in
hashlimit_proc_net_exit().

Found and tested with custom build 3.2.x and backported commits
32263dd1b (netfilter: xt_hashlimit: fix namespace destroy path) and
commit 665e205c1 (netfilter: xt_recent: fix namespace destroy path),
which seems not currently in linux-stable (at least for 3.2.x series).

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/netfilter/xt_hashlimit.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 9ff035c..a3910fc 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -325,21 +325,24 @@ static void htable_gc(unsigned long htlong)
 	add_timer(&ht->timer);
 }
 
-static void htable_destroy(struct xt_hashlimit_htable *hinfo)
+static void htable_remove_proc_entry(struct xt_hashlimit_htable *hinfo)
 {
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(hinfo->net);
 	struct proc_dir_entry *parent;
 
-	del_timer_sync(&hinfo->timer);
-
 	if (hinfo->family == NFPROTO_IPV4)
 		parent = hashlimit_net->ipt_hashlimit;
 	else
 		parent = hashlimit_net->ip6t_hashlimit;
 
-	if(parent != NULL)
+	if (parent != NULL)
 		remove_proc_entry(hinfo->name, parent);
+}
 
+static void htable_destroy(struct xt_hashlimit_htable *hinfo)
+{
+	del_timer_sync(&hinfo->timer);
+	htable_remove_proc_entry(hinfo);
 	htable_selective_cleanup(hinfo, select_all);
 	kfree(hinfo->name);
 	vfree(hinfo);
@@ -883,21 +886,15 @@ static int __net_init hashlimit_proc_net_init(struct net 
*net)
 static void __net_exit hashlimit_proc_net_exit(struct net *net)
 {
 	struct xt_hashlimit_htable *hinfo;
-	struct proc_dir_entry *pde;
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
 
-	/* recent_net_exit() is called before recent_mt_destroy(). Make sure
-	 * that the parent xt_recent proc entry is is empty before trying to
-	 * remove it.
+	/* hashlimit_net_exit() is called before hashlimit_mt_destroy().
+	 * Make sure that the parent ipt_hashlimit and ip6t_hashlimit proc
+	 * entries is empty before trying to remove it.
 	 */
 	mutex_lock(&hashlimit_mutex);
-	pde = hashlimit_net->ipt_hashlimit;
-	if (pde == NULL)
-		pde = hashlimit_net->ip6t_hashlimit;
-
 	hlist_for_each_entry(hinfo, &hashlimit_net->htables, node)
-		remove_proc_entry(hinfo->name, pde);
-
+		htable_remove_proc_entry(hinfo);
 	hashlimit_net->ipt_hashlimit = NULL;
 	hashlimit_net->ip6t_hashlimit = NULL;
 	mutex_unlock(&hashlimit_mutex);
-- 
1.8.3.4
