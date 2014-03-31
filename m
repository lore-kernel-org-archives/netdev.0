From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NFS does not work on linux-next 20140331
Date: Mon, 31 Mar 2014 09:29:04 -0700
Message-ID: <1396283344.29410.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:55349 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbaCaQ3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:29:06 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so8430990pad.17
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:29:05 -0700 (PDT)
In-Reply-To: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-31 at 13:14 -0300, Fabio Estevam wrote:
> Hi,
> 
> When running linux-next 20140331 I am no longer able to mount NFS on a
> mx6qsabresd board:
> 
> =================================
> [ INFO: inconsistent lock state ]
> 3.14.0-rc8-next-20140331 #964 Not tainted
> ---------------------------------
> inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> kworker/0:2/50 [HC0[0]:SC0[0]:HE1:SE1] takes:
>  (&addrconf_stats->syncp.seq){+.?...}, at: [<8057ca88>] mld_send_initial_cr.par0
> {IN-SOFTIRQ-W} state was registered at:
>   [<8006366c>] mark_lock+0x140/0x6ac
>   [<80063ebc>] __lock_acquire+0x2e4/0x1c00
>   [<80065cbc>] lock_acquire+0x68/0x7c
>   [<8057bf28>] mld_sendpack+0xec/0x73c
>   [<8057cc80>] mld_ifc_timer_expire+0x1e4/0x2e4
>   [<8003310c>] call_timer_fn+0x74/0xec
>   [<80033a5c>] run_timer_softirq+0x1c4/0x264
>   [<8002d3d4>] __do_softirq+0x130/0x278
>   [<8002d814>] irq_exit+0xb0/0x104
>   [<8000f47c>] handle_IRQ+0x58/0xb8
>   [<80008680>] gic_handle_irq+0x30/0x64
>   [<800129a4>] __irq_svc+0x44/0x5c
>   [<8005f9dc>] cpu_startup_entry+0xfc/0x160
>   [<80617a3c>] rest_init+0xb0/0xd8
>   [<8083db58>] start_kernel+0x324/0x388
>   [<10008074>] 0x10008074
> irq event stamp: 62347
> hardirqs last  enabled at (62347): [<8002d67c>] __local_bh_enable_ip+0x80/0xe8
> hardirqs last disabled at (62345): [<8002d63c>] __local_bh_enable_ip+0x40/0xe8
> softirqs last  enabled at (62346): [<80558740>] ip6_finish_output2+0x16c/0x9d8
> softirqs last disabled at (62334): [<80558624>] ip6_finish_output2+0x50/0x9d8
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(&addrconf_stats->syncp.seq);
>   <Interrupt>
>     lock(&addrconf_stats->syncp.seq);
> 
>  *** DEADLOCK ***
> 
> 4 locks held by kworker/0:2/50:
>  #0:  ("%s"("ipv6_addrconf")){.+.+..}, at: [<8003f2d0>] process_one_work+0x134/4
>  #1:  ((&(&ifa->dad_work)->work)){+.+...}, at: [<8003f2d0>] process_one_work+0x4
>  #2:  (rtnl_mutex){+.+.+.}, at: [<804e0acc>] rtnl_lock+0x18/0x20
>  #3:  (rcu_read_lock){......}, at: [<8057be3c>] mld_sendpack+0x0/0x73c
> 
> stack backtrace:
> CPU: 0 PID: 50 Comm: kworker/0:2 Not tainted 3.14.0-rc8-next-20140331 #964
> Workqueue: ipv6_addrconf addrconf_dad_work
> Backtrace:
> [<80011cd4>] (dump_backtrace) from [<80011e70>] (show_stack+0x18/0x1c)
>  r6:be81c440 r5:00000000 r4:00000000 r3:be81c440
> [<80011e58>] (show_stack) from [<8061e054>] (dump_stack+0x88/0xa4)
> [<8061dfcc>] (dump_stack) from [<8061bcf8>] (print_usage_bug+0x260/0x2d0)
>  r5:80784b0c r4:809aee20
> [<8061ba98>] (print_usage_bug) from [<800637c8>] (mark_lock+0x29c/0x6ac)
>  r10:80062cc0 r8:00000004 r7:be81c440 r6:00001054 r5:be81c8e8 r4:00000006
> [<8006352c>] (mark_lock) from [<80064200>] (__lock_acquire+0x628/0x1c00)
>  r10:bf7b755c r9:be82e000 r8:000001ef r7:8098e030 r6:808b3afc r5:be81c440
>  r4:80dde8cc r3:00000004
> [<80063bd8>] (__lock_acquire) from [<80065cbc>] (lock_acquire+0x68/0x7c)
>  r10:808e4e00 r9:00000001 r8:80896d2c r7:00000001 r6:60000013 r5:be82e000
>  r4:00000000
> [<80065c54>] (lock_acquire) from [<8057c248>] (mld_sendpack+0x40c/0x73c)
>  r7:00000000 r6:8057ca88 r5:0000004c r4:bf7b7438
> [<8057be3c>] (mld_sendpack) from [<8057ca88>] (mld_send_initial_cr.part.18+0x9c)
>  r10:be9d48d0 r9:00000001 r8:00000000 r7:00000001 r6:beb880c0 r5:bebe4668
>  r4:00000000
> [<8057c9ec>] (mld_send_initial_cr.part.18) from [<8057ffb0>] (ipv6_mc_dad_compl)
>  r10:00000000 r8:be9d48d0 r7:be9d2a00 r6:be9d2a20 r5:be8c8000 r4:be9d4800
> [<8057ff7c>] (ipv6_mc_dad_complete) from [<805641b8>] (addrconf_dad_completed+0)
>  r4:be9d2a00 r3:be81c440
> [<805640bc>] (addrconf_dad_completed) from [<8056445c>] (addrconf_dad_work+0x1f)
>  r5:be9d2a40 r4:be9d2a74
> [<80564260>] (addrconf_dad_work) from [<8003f344>] (process_one_work+0x1a8/0x44)
>  r10:bf7b7200 r8:00000000 r7:be82e000 r6:bf7b15c0 r5:be9d2a74 r4:be801c80
> [<8003f19c>] (process_one_work) from [<8003f9e4>] (worker_thread+0x124/0x398)
>  r10:808eddf6 r9:bf7b15c0 r8:be82e000 r7:be801c98 r6:be82e000 r5:bf7b15f0
>  r4:be801c80
> [<8003f8c0>] (worker_thread) from [<8004669c>] (kthread+0xd0/0xec)
>  r10:00000000 r9:00000000 r8:00000000 r7:8003f8c0 r6:be801c80 r5:be808a40
>  r4:00000000
> [<800465cc>] (kthread) from [<8000ebe8>] (ret_from_fork+0x14/0x2c)
>  r7:00000000 r6:00000000 r5:800465cc r4:be808a40
> INFO: rcu_sched detected stalls on CPUs/tasks: {} (detected by 1, t=2102 jiffie)
> INFO: Stall ended before state dump start
> random: nonblocking pool is initialized
> INFO: rcu_sched detected stalls on CPUs/tasks: {} (detected by 0, t=8407 jiffie)
> INFO: Stall ended before state dump start
> INFO: rcu_sched detected stalls on CPUs/tasks: {} (detected by 3, t=14712 jiffi)
> INFO: Stall ended before state dump start
> --

Hi Fabio

Could you try the following patch ?

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index e1e47350784b..74a774af8265 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1588,7 +1588,7 @@ static void mld_sendpack(struct sk_buff *skb)
 
 	rcu_read_lock();
 	idev = __in6_dev_get(skb->dev);
-	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
+	IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUT, skb->len);
 
 	payload_len = (skb_tail_pointer(skb) - skb_network_header(skb)) -
 		sizeof(*pip6);
