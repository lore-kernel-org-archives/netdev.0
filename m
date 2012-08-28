From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: route.c:645 suspicious rcu_dereference_check()
Date: Tue, 28 Aug 2012 15:33:07 -0700
Message-ID: <1346193187.3571.21.camel@edumazet-glaptop>
References: <20120828175734.41b17a6c@mj>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:33885 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab2H1WdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 18:33:08 -0400
Received: by dady13 with SMTP id y13so3615174dad.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 15:33:08 -0700 (PDT)
In-Reply-To: <20120828175734.41b17a6c@mj>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Tue, 2012-08-28 at 17:57 -0400, Pavel Roskin wrote:
> Hello!
> 
> I've got a warning in the kernel log starting with
> 
> [ 1570.586223] ===============================
> [ 1570.586225] [ INFO: suspicious RCU usage. ]
> [ 1570.586228] 3.6.0-rc3-wl-main #98 Not tainted
> [ 1570.586229] -------------------------------
> [ 1570.586231] /home/proski/src/linux/net/ipv4/route.c:645 suspicious
> rcu_dereference_check() usage! [ 1570.586233] 
> [ 1570.586233] other info that might help us debug this:
> [ 1570.586233] 
> [ 1570.586236] 
> [ 1570.586236] rcu_scheduler_active = 1, debug_locks = 0
> [ 1570.586238] 2 locks held by Chrome_IOThread/4467:
> [ 1570.586240]  #0:  (slock-AF_INET){+.-...}, at: [<ffffffff814f2c0c>]
> release_sock+0x2c/0xa0 [ 1570.586253]  #1:  (fnhe_lock){+.-...}, at:
> [<ffffffff815302fc>] update_or_create_fnhe+0x2c/0x270 [ 1570.586260] 
> [ 1570.586260] stack backtrace:
> [ 1570.586263] Pid: 4467, comm: Chrome_IOThread Not tainted
> 3.6.0-rc3-wl-main #98 [ 1570.586265] Call Trace:
> [ 1570.586271]  [<ffffffff810976ed>] lockdep_rcu_suspicious+0xfd/0x130
> [ 1570.586275]  [<ffffffff8153042c>] update_or_create_fnhe+0x15c/0x270
> 
> The dmesg output and the .config file are attached.
> 

Thanks this seems a real bug

[PATCH] ipv4: must use rcu protection while calling fib_lookup

Following lockdep splat was reported by Pavel Roskin :

[ 1570.586223] ===============================
[ 1570.586225] [ INFO: suspicious RCU usage. ]
[ 1570.586228] 3.6.0-rc3-wl-main #98 Not tainted
[ 1570.586229] -------------------------------
[ 1570.586231] /home/proski/src/linux/net/ipv4/route.c:645 suspicious rcu_dereference_check() usage!
[ 1570.586233] 
[ 1570.586233] other info that might help us debug this:
[ 1570.586233] 
[ 1570.586236] 
[ 1570.586236] rcu_scheduler_active = 1, debug_locks = 0
[ 1570.586238] 2 locks held by Chrome_IOThread/4467:
[ 1570.586240]  #0:  (slock-AF_INET){+.-...}, at: [<ffffffff814f2c0c>] release_sock+0x2c/0xa0
[ 1570.586253]  #1:  (fnhe_lock){+.-...}, at: [<ffffffff815302fc>] update_or_create_fnhe+0x2c/0x270
[ 1570.586260] 
[ 1570.586260] stack backtrace:
[ 1570.586263] Pid: 4467, comm: Chrome_IOThread Not tainted 3.6.0-rc3-wl-main #98
[ 1570.586265] Call Trace:
[ 1570.586271]  [<ffffffff810976ed>] lockdep_rcu_suspicious+0xfd/0x130
[ 1570.586275]  [<ffffffff8153042c>] update_or_create_fnhe+0x15c/0x270
[ 1570.586278]  [<ffffffff815305b3>] __ip_rt_update_pmtu+0x73/0xb0
[ 1570.586282]  [<ffffffff81530619>] ip_rt_update_pmtu+0x29/0x90
[ 1570.586285]  [<ffffffff815411dc>] inet_csk_update_pmtu+0x2c/0x80
[ 1570.586290]  [<ffffffff81558d1e>] tcp_v4_mtu_reduced+0x2e/0xc0
[ 1570.586293]  [<ffffffff81553bc4>] tcp_release_cb+0xa4/0xb0
[ 1570.586296]  [<ffffffff814f2c35>] release_sock+0x55/0xa0
[ 1570.586300]  [<ffffffff815442ef>] tcp_sendmsg+0x4af/0xf50
[ 1570.586305]  [<ffffffff8156fc60>] inet_sendmsg+0x120/0x230
[ 1570.586308]  [<ffffffff8156fb40>] ? inet_sk_rebuild_header+0x40/0x40
[ 1570.586312]  [<ffffffff814f4bdd>] ? sock_update_classid+0xbd/0x3b0
[ 1570.586315]  [<ffffffff814f4c50>] ? sock_update_classid+0x130/0x3b0
[ 1570.586320]  [<ffffffff814ec435>] do_sock_write+0xc5/0xe0
[ 1570.586323]  [<ffffffff814ec4a3>] sock_aio_write+0x53/0x80
[ 1570.586328]  [<ffffffff8114bc83>] do_sync_write+0xa3/0xe0
[ 1570.586332]  [<ffffffff8114c5a5>] vfs_write+0x165/0x180
[ 1570.586335]  [<ffffffff8114c805>] sys_write+0x45/0x90
[ 1570.586340]  [<ffffffff815d2722>] system_call_fastpath+0x16/0x1b

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Pavel Roskin <proski@gnu.org>
---
 net/ipv4/route.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 24fd4c5..82cf2a7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -934,12 +934,14 @@ static u32 __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 	if (mtu < ip_rt_min_pmtu)
 		mtu = ip_rt_min_pmtu;
 
+	rcu_read_lock();
 	if (fib_lookup(dev_net(rt->dst.dev), fl4, &res) == 0) {
 		struct fib_nh *nh = &FIB_RES_NH(res);
 
 		update_or_create_fnhe(nh, fl4->daddr, 0, mtu,
 				      jiffies + ip_rt_mtu_expires);
 	}
+	rcu_read_unlock();
 	return mtu;
 }
 
