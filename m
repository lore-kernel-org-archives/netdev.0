From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: suspicious RCU usage in net/ipv4/ip_tunnel.c:80
Date: Fri, 10 Jan 2014 17:21:21 -0800
Message-ID: <1389403281.31367.171.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7PAyR_cJ9_9nfUBc0U9o-U=gCV+sN_VYbHwgq-QdoEVzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f177.google.com ([209.85.161.177]:36935 "EHLO
	mail-gg0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbaAKBV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 20:21:26 -0500
Received: by mail-gg0-f177.google.com with SMTP id 4so1446635ggm.22
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 17:21:25 -0800 (PST)
In-Reply-To: <CAHA+R7PAyR_cJ9_9nfUBc0U9o-U=gCV+sN_VYbHwgq-QdoEVzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 16:37 -0800, Cong Wang wrote:
> Hi, Tom
> 
> I saw:
> 
> [   65.609535] [ INFO: suspicious RCU usage. ]
> [   65.609537] 3.13.0-rc6+ #139 Not tainted
> [   65.609538] -------------------------------
> [   65.609539] net/ipv4/ip_tunnel.c:80 suspicious rcu_dereference_check() usage!
> [   65.609540]
> [   65.609540] other info that might help us debug this:
> [   65.609540]
> [   65.609541]
> [   65.609541] rcu_scheduler_active = 1, debug_locks = 0
> [   65.609542] 5 locks held by kworker/u8:0/6:
> [   65.609553]  #0:  (%s#4){.+.+.+}, at: [<ffffffff8106d56b>]
> process_one_work+0x173/0x41e
> [   65.609557]  #1:  (net_cleanup_work){+.+.+.}, at:
> [<ffffffff8106d56b>] process_one_work+0x173/0x41e
> [   65.609563]  #2:  (net_mutex){+.+.+.}, at: [<ffffffff817816c9>]
> cleanup_net+0x85/0x18a
> [   65.609569]  #3:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81796058>]
> rtnl_lock+0x17/0x19
> [   65.609575]  #4:  (&(&idst->lock)->rlock){+.....}, at:
> [<ffffffff818820fe>] __tunnel_dst_set+0x30/0x8b
> [   65.609575]
> [   65.609575] stack backtrace:
> [   65.609577] CPU: 1 PID: 6 Comm: kworker/u8:0 Not tainted 3.13.0-rc6+ #139
> [   65.609579] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [   65.609582] Workqueue: netns cleanup_net
> [   65.609585]  0000000000000000 ffff880118205bb0 ffffffff819894b6
> ffff8801181ea550
> [   65.609587]  ffff880118205be0 ffffffff81095f34 0000000000000000
> ffffe8ffff606df0
> [   65.609589]  ffffe8ffff606df8 0000000000000000 ffff880118205c10
> ffffffff8188213c
> [   65.609590] Call Trace:
> [   65.609595]  [<ffffffff819894b6>] dump_stack+0x4d/0x66
> [   65.609598]  [<ffffffff81095f34>] lockdep_rcu_suspicious+0x107/0x110
> [   65.609600]  [<ffffffff8188213c>] __tunnel_dst_set+0x6e/0x8b
> [   65.609602]  [<ffffffff81882203>] tunnel_dst_reset_all.isra.25+0x40/0x47
> [   65.609605]  [<ffffffff81883e28>] ip_tunnel_uninit+0x61/0x64
> [   65.609608]  [<ffffffff8178aeb2>] rollback_registered_many+0x188/0x21f
> [   65.609610]  [<ffffffff8178b02f>] unregister_netdevice_many+0x19/0x63
> [   65.609612]  [<ffffffff81883a17>] ip_tunnel_delete_net+0xd1/0xe5
> [   65.609615]  [<ffffffff8188bc68>] vti_exit_net+0x2a/0x2c
> [   65.609617]  [<ffffffff81780f21>] ops_exit_list+0x44/0x55
> [   65.609619]  [<ffffffff8178173a>] cleanup_net+0xf6/0x18a
> [   65.609621]  [<ffffffff8106d612>] process_one_work+0x21a/0x41e
> [   65.609623]  [<ffffffff8106d56b>] ? process_one_work+0x173/0x41e
> [   65.609625]  [<ffffffff8106dc1b>] worker_thread+0x149/0x1f5
> [   65.609628]  [<ffffffff8106dad2>] ? rescuer_thread+0x28d/0x28d
> [   65.609630]  [<ffffffff81073f6f>] kthread+0xd2/0xda
> [   65.609634]  [<ffffffff8107d0ed>] ? finish_task_switch+0x3a/0xbe
> [   65.609636]  [<ffffffff81073e9d>] ? __kthread_parkme+0x61/0x61
> [   65.609640]  [<ffffffff819961ac>] ret_from_fork+0x7c/0xb0
> [   65.609642]  [<ffffffff81073e9d>] ? __kthread_parkme+0x61/0x61
> 
> 
> I think the patch below could fix it but not sure if we really need
> synchronize_rcu() here...
> 
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index d3929a6..eb50b9a 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -77,10 +77,11 @@ static inline void __tunnel_dst_set(struct
> ip_tunnel_dst *idst,
>                 dst = NULL;
> 
>         spin_lock_bh(&idst->lock);
> -       old_dst = rcu_dereference(idst->dst);
> +       old_dst = idst->dst;
>         rcu_assign_pointer(idst->dst, dst);
> -       dst_release(old_dst);
>         spin_unlock_bh(&idst->lock);
> +       synchronize_rcu();
> +       dst_release(old_dst);
>  }


Nope, the synchronize_rcu() is not needed here.

Please use following sparse ready patch, thanks :

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index d3929a69f008..6eda759b5c4b 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -77,10 +77,11 @@ static inline void __tunnel_dst_set(struct ip_tunnel_dst *idst,
 		dst = NULL;
 
 	spin_lock_bh(&idst->lock);
-	old_dst = rcu_dereference(idst->dst);
+	old_dst = rcu_dereference_protected(idst->dst,
+					    lockdep_is_held(&idst->lock));
 	rcu_assign_pointer(idst->dst, dst);
-	dst_release(old_dst);
 	spin_unlock_bh(&idst->lock);
+	dst_release(old_dst);
 }
 
 static inline void tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
