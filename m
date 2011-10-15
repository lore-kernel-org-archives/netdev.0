From: Ari Savolainen <ari.m.savolainen@gmail.com>
Subject: Kernel panic from tg3 net driver
Date: Sat, 15 Oct 2011 10:50:43 +0300
Message-ID: <CAEbykaXz+J8abVzU3yjqZG2+yhHNrQWsQy2c8wNyoERWPpxWKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I get this panic when I try to print from a virtual machine:

https://docs.google.com/leaf?id=0B7LPWLwa6EUaODIxYTY2YmQtNWJlZS00M2ViLTk5ZmEtNDM2ZTZmNzE2MDEz&hl=fi

I tried to bisect it, but couldn't finish, because after the last step
the boot process got stuck right after selecting the kernel in grub
and I ran out of time:

git bisect start
# bad: [322a8b034003c0d46d39af85bf24fee27b902f48] Linux 3.1-rc1
git bisect bad 322a8b034003c0d46d39af85bf24fee27b902f48
# good: [02f8c6aee8df3cdc935e9bdd4f2d020306035dbe] Linux 3.0
git bisect good 02f8c6aee8df3cdc935e9bdd4f2d020306035dbe
# bad: [0003230e8200699860f0b10af524dc47bf8aecad] Merge branch
'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6
git bisect bad 0003230e8200699860f0b10af524dc47bf8aecad
# bad: [72f96e0e38d7e29ba16dcfd824ecaebe38b8293e] Merge branch
'for-linus-core' of
git://git.kernel.org/pub/scm/linux/kernel/git/nab/target-pending
git bisect bad 72f96e0e38d7e29ba16dcfd824ecaebe38b8293e
# good: [204d1641d200709c759d8c269458cbc7de378c40] Merge branch
'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6
into for-davem
git bisect good 204d1641d200709c759d8c269458cbc7de378c40
# bad: [415b3334a21aa67806c52d1acf4e72e14f7f402f] icmp: Fix regression
in nexthop resolution during replies.
git bisect bad 415b3334a21aa67806c52d1acf4e72e14f7f402f
# bad: [95a943c162d74b20d869917bdf5df11293c35b63] Merge branch
'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6
into for-davem
git bisect bad 95a943c162d74b20d869917bdf5df11293c35b63

In the first bad kernel (3.1-rc1) there was this in the log:

[  105.612095]
[  105.612096] ===================================================
[  105.612100] [ INFO: suspicious rcu_dereference_check() usage. ]
[  105.612101] ---------------------------------------------------
[  105.612103] include/net/dst.h:91 invoked rcu_dereference_check()
without protection!
[  105.612105]
[  105.612106] other info that might help us debug this:
[  105.612106]
[  105.612108]
[  105.612108] rcu_scheduler_active = 1, debug_locks = 0
[  105.612110] 1 lock held by dnsmasq/2618:
[  105.612111]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff815df8c7>]
rtnl_lock+0x17/0x20
[  105.612120]
[  105.612121] stack backtrace:
[  105.612123] Pid: 2618, comm: dnsmasq Not tainted 3.1.0-rc1 #41
[  105.612125] Call Trace:
[  105.612129]  [<ffffffff810ccdcb>] lockdep_rcu_dereference+0xbb/0xc0
[  105.612132]  [<ffffffff815dc5a9>] neigh_update+0x4f9/0x5f0
[  105.612135]  [<ffffffff815da001>] ? neigh_lookup+0xe1/0x220
[  105.612139]  [<ffffffff81639298>] arp_req_set+0xb8/0x230
[  105.612142]  [<ffffffff8163a59f>] arp_ioctl+0x1bf/0x310
[  105.612146]  [<ffffffff810baa40>] ? lock_hrtimer_base.isra.26+0x30/0x60
[  105.612150]  [<ffffffff8163fb75>] inet_ioctl+0x85/0x90
[  105.612154]  [<ffffffff815b5520>] sock_do_ioctl+0x30/0x70
[  105.612157]  [<ffffffff815b55d3>] sock_ioctl+0x73/0x280
[  105.612162]  [<ffffffff811b7698>] do_vfs_ioctl+0x98/0x570
[  105.612165]  [<ffffffff811a5c40>] ? fget_light+0x340/0x3a0
[  105.612168]  [<ffffffff811b7bbf>] sys_ioctl+0x4f/0x80
[  105.612172]  [<ffffffff816fdcab>] system_call_fastpath+0x16/0x1b
