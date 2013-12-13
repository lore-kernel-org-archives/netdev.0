From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] netvsc: don't flush peers notifying work during
 setting mtu
Date: Fri, 13 Dec 2013 16:05:37 +0000
Message-ID: <4f802e3386e546029784e28cf89cd3eb@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1386926487-30822-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Jason Wang <jasowang@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.93]:55002 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751571Ab3LMQWK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 11:22:10 -0500
In-Reply-To: <1386926487-30822-1-git-send-email-jasowang@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Jason Wang [mailto:jasowang@redhat.com]
> Sent: Friday, December 13, 2013 4:21 AM
> To: KY Srinivasan; Haiyang Zhang; devel@linuxdriverproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Cc: Jason Wang
> Subject: [PATCH net] netvsc: don't flush peers notifying work during setting
> mtu
> 
> There's a possible deadlock if we flush the peers notifying work during
> setting
> mtu:
> 
> [   22.991149]
> ======================================================
> [   22.991173] [ INFO: possible circular locking dependency detected ]
> [   22.991198] 3.10.0-54.0.1.el7.x86_64.debug #1 Not tainted
> [   22.991219] -------------------------------------------------------
> [   22.991243] ip/974 is trying to acquire lock:
> [   22.991261]  ((&(&net_device_ctx->dwork)->work)){+.+.+.}, at:
> [<ffffffff8108af95>] flush_work+0x5/0x2e0
> [   22.991307]
> but task is already holding lock:
> [   22.991330]  (rtnl_mutex){+.+.+.}, at: [<ffffffff81539deb>]
> rtnetlink_rcv+0x1b/0x40
> [   22.991367]
> which lock already depends on the new lock.
> 
> [   22.991398]
> the existing dependency chain (in reverse order) is:
> [   22.991426]
> -> #1 (rtnl_mutex){+.+.+.}:
> [   22.991449]        [<ffffffff810dfdd9>] __lock_acquire+0xb19/0x1260
> [   22.991477]        [<ffffffff810e0d12>] lock_acquire+0xa2/0x1f0
> [   22.991501]        [<ffffffff81673659>] mutex_lock_nested+0x89/0x4f0
> [   22.991529]        [<ffffffff815392b7>] rtnl_lock+0x17/0x20
> [   22.991552]        [<ffffffff815230b2>] netdev_notify_peers+0x12/0x30
> [   22.991579]        [<ffffffffa0340212>] netvsc_send_garp+0x22/0x30
> [hv_netvsc]
> [   22.991610]        [<ffffffff8108d251>] process_one_work+0x211/0x6e0
> [   22.991637]        [<ffffffff8108d83b>] worker_thread+0x11b/0x3a0
> [   22.991663]        [<ffffffff81095e5d>] kthread+0xed/0x100
> [   22.991686]        [<ffffffff81681c6c>] ret_from_fork+0x7c/0xb0
> [   22.991715]
> -> #0 ((&(&net_device_ctx->dwork)->work)){+.+.+.}:
> [   22.991715]        [<ffffffff810de817>] check_prevs_add+0x967/0x970
> [   22.991715]        [<ffffffff810dfdd9>] __lock_acquire+0xb19/0x1260
> [   22.991715]        [<ffffffff810e0d12>] lock_acquire+0xa2/0x1f0
> [   22.991715]        [<ffffffff8108afde>] flush_work+0x4e/0x2e0
> [   22.991715]        [<ffffffff8108e1b5>] __cancel_work_timer+0x95/0x130
> [   22.991715]        [<ffffffff8108e303>] cancel_delayed_work_sync+0x13/0x20
> [   22.991715]        [<ffffffffa03404e4>] netvsc_change_mtu+0x84/0x200
> [hv_netvsc]
> [   22.991715]        [<ffffffff815233d4>] dev_set_mtu+0x34/0x80
> [   22.991715]        [<ffffffff8153bc2a>] do_setlink+0x23a/0xa00
> [   22.991715]        [<ffffffff8153d054>] rtnl_newlink+0x394/0x5e0
> [   22.991715]        [<ffffffff81539eac>] rtnetlink_rcv_msg+0x9c/0x260
> [   22.991715]        [<ffffffff8155cdd9>] netlink_rcv_skb+0xa9/0xc0
> [   22.991715]        [<ffffffff81539dfa>] rtnetlink_rcv+0x2a/0x40
> [   22.991715]        [<ffffffff8155c41d>] netlink_unicast+0xdd/0x190
> [   22.991715]        [<ffffffff8155c807>] netlink_sendmsg+0x337/0x750
> [   22.991715]        [<ffffffff8150d219>] sock_sendmsg+0x99/0xd0
> [   22.991715]        [<ffffffff8150d63e>] ___sys_sendmsg+0x39e/0x3b0
> [   22.991715]        [<ffffffff8150eba2>] __sys_sendmsg+0x42/0x80
> [   22.991715]        [<ffffffff8150ebf2>] SyS_sendmsg+0x12/0x20
> [   22.991715]        [<ffffffff81681d19>] system_call_fastpath+0x16/0x1b
> 
> This is because we hold the rtnl_lock() before ndo_change_mtu() and try to
> flush the work in netvsc_change_mtu(), in the mean time,
> netdev_notify_peers() may be called from worker and also trying to hold the
> rtnl_lock. This will lead the flush won't succeed forever. Solve this by not
> canceling and flushing the work, this is safe because the transmission done
> by NETDEV_NOTIFY_PEERS was synchronized with the netif_tx_disable()
> called by netvsc_change_mtu().
> 
> Reported-by: Yaju Cao <yacao@redhat.com>
> Tested-by: Yaju Cao <yacao@redhat.com>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
