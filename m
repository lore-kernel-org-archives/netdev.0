From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: Fw: [Bug 111771] New: deadlock in ppp/l2tp
Date: Wed, 3 Feb 2016 18:14:02 +0100
Message-ID: <20160203171401.GC1267@alphalink.fr>
References: <20160203110431.7b878a4f@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Sorin Manolache <sorinm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:36944 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933081AbcBCROH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 12:14:07 -0500
Content-Disposition: inline
In-Reply-To: <20160203110431.7b878a4f@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2016 at 11:04:31AM +1100, Stephen Hemminger wrote:
> Please excuse URL mangling, my bugzilla address appears to route through
> stupid corporate firewall.
> 
> Begin forwarded message:
> 
> Date: Tue, 2 Feb 2016 18:38:41 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 111771] New: deadlock in ppp/l2tp
> 
> 
> https://urldefense.proofpoint.com/v2/url?u=https-3A__bugzilla.kernel.org_show-5Fbug.cgi-3Fid-3D111771&d=CwICaQ&c=IL_XqQWOjubgfqINi2jTzg&r=q_lvUiVm1uM6QEw9TPH-6jiV__hsrE6xXUAtATPE9x0&m=QRVzJYt9nD-EOW0XdrPpw2-kYmZu0sg62aaPeiiLI_Q&s=l3HC8fgAgyPVwSgMaX2Hjr8GL3P5j2fL1kDXhEW-v9w&e= 
> 
>             Bug ID: 111771
>            Summary: deadlock in ppp/l2tp
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 4.3.2
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: sorinm@gmail.com
>         Regression: No
> 
> Created attachment 202771
>   --> https://urldefense.proofpoint.com/v2/url?u=https-3A__bugzilla.kernel.org_attachment.cgi-3Fid-3D202771-26action-3Dedit&d=CwICaQ&c=IL_XqQWOjubgfqINi2jTzg&r=q_lvUiVm1uM6QEw9TPH-6jiV__hsrE6xXUAtATPE9x0&m=QRVzJYt9nD-EOW0XdrPpw2-kYmZu0sg62aaPeiiLI_Q&s=2a_KCXgtoQ6NLxDon6_3flSUMpb7Tjj8WhGPZ09E8Vo&e= 
> kernel.log, config, cpuinfo
> 
> I'm getting a deadlock and the computer is unresponsive shortly after setting
> up a xl2tpd/ipsec vpn connection. The deadlock occurs every time, it is very
> reproducible on my computer.
> 
> It is the mainline kernel, version 4.3.2.
> 

Sorin, it seems like one of your L2TP tunnels is routed to one of its upper PPP
devices. Most likely, the peer address of the PPP device is also the address of
the remote L2TP tunnel endpoint. So L2TP packets are sent back to the upper PPP
device, instead of leaving through the physical interface.

For easier reference, here the trace extracted from bugzilla:

Feb  2 19:02:06 leo-naphta kernel: [  329.888935] ======================================================
Feb  2 19:02:06 leo-naphta kernel: [  329.888939] [ INFO: possible circular locking dependency detected ]
Feb  2 19:02:06 leo-naphta kernel: [  329.888945] 4.3.2 #5 Not tainted
Feb  2 19:02:06 leo-naphta kernel: [  329.888948] -------------------------------------------------------
Feb  2 19:02:06 leo-naphta kernel: [  329.888952] pppd/4034 is trying to acquire lock:
Feb  2 19:02:06 leo-naphta kernel: [  329.888956]  (_xmit_PPP#2){+.....}, at: [<ffffffff8143b793>] sch_direct_xmit+0xf3/0x1f0
Feb  2 19:02:06 leo-naphta kernel: [  329.888979] 
Feb  2 19:02:06 leo-naphta kernel: [  329.888979] but task is already holding lock:
Feb  2 19:02:06 leo-naphta kernel: [  329.888982]  (l2tp_sock){+.-...}, at: [<ffffffffa03716f7>] l2tp_xmit_skb+0x117/0x3d0 [l2tp_core]
Feb  2 19:02:06 leo-naphta kernel: [  329.888997] 
Feb  2 19:02:06 leo-naphta kernel: [  329.888997] which lock already depends on the new lock.
Feb  2 19:02:06 leo-naphta kernel: [  329.888997] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889002] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889002] the existing dependency chain (in reverse order) is:
Feb  2 19:02:06 leo-naphta kernel: [  329.889006] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889006] -> #3 (l2tp_sock){+.-...}:
Feb  2 19:02:06 leo-naphta kernel: [  329.889015]        [<ffffffff8108f2f0>] lock_acquire+0x60/0x80
Feb  2 19:02:06 leo-naphta kernel: [  329.889023]        [<ffffffff81512c13>] _raw_spin_lock+0x33/0x50
Feb  2 19:02:06 leo-naphta kernel: [  329.889033]        [<ffffffffa03716f7>] l2tp_xmit_skb+0x117/0x3d0 [l2tp_core]
Feb  2 19:02:06 leo-naphta kernel: [  329.889041]        [<ffffffffa037c563>] pppol2tp_xmit+0x143/0x1f3 [l2tp_ppp]
Feb  2 19:02:06 leo-naphta kernel: [  329.889049]        [<ffffffffa03569ab>] ppp_channel_push+0x4b/0xc0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889057]        [<ffffffffa0356cb0>] ppp_write+0xc0/0xf0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889065]        [<ffffffff8115a2e3>] __vfs_write+0x23/0xe0
Feb  2 19:02:06 leo-naphta kernel: [  329.889074]        [<ffffffff8115ab9d>] vfs_write+0x9d/0x180
Feb  2 19:02:06 leo-naphta kernel: [  329.889080]        [<ffffffff8115b6d4>] SyS_write+0x44/0xa0
Feb  2 19:02:06 leo-naphta kernel: [  329.889086]        [<ffffffff815137db>] entry_SYSCALL_64_fastpath+0x16/0x6f
Feb  2 19:02:06 leo-naphta kernel: [  329.889094] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889094] -> #2 (&(&pch->downl)->rlock){+.....}:
Feb  2 19:02:06 leo-naphta kernel: [  329.889102]        [<ffffffff8108f2f0>] lock_acquire+0x60/0x80
Feb  2 19:02:06 leo-naphta kernel: [  329.889107]        [<ffffffff81512d5a>] _raw_spin_lock_bh+0x3a/0x50
Feb  2 19:02:06 leo-naphta kernel: [  329.889114]        [<ffffffffa035402a>] ppp_push+0x10a/0x5b0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889133]        [<ffffffffa0356785>] ppp_xmit_process+0x3f5/0x5d0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889141]        [<ffffffffa0356cba>] ppp_write+0xca/0xf0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889149]        [<ffffffff8115a2e3>] __vfs_write+0x23/0xe0
Feb  2 19:02:06 leo-naphta kernel: [  329.889156]        [<ffffffff8115ab9d>] vfs_write+0x9d/0x180
Feb  2 19:02:06 leo-naphta kernel: [  329.889162]        [<ffffffff8115b6d4>] SyS_write+0x44/0xa0
Feb  2 19:02:06 leo-naphta kernel: [  329.889169]        [<ffffffff815137db>] entry_SYSCALL_64_fastpath+0x16/0x6f
Feb  2 19:02:06 leo-naphta kernel: [  329.889177] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889177] -> #1 (&(&ppp->wlock)->rlock){+.....}:
Feb  2 19:02:06 leo-naphta kernel: [  329.889186]        [<ffffffff8108f2f0>] lock_acquire+0x60/0x80
Feb  2 19:02:06 leo-naphta kernel: [  329.889191]        [<ffffffff81512d5a>] _raw_spin_lock_bh+0x3a/0x50
Feb  2 19:02:06 leo-naphta kernel: [  329.889199]        [<ffffffffa03563b7>] ppp_xmit_process+0x27/0x5d0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889207]        [<ffffffffa0356b96>] ppp_start_xmit+0x156/0x1b0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889215]        [<ffffffff8141ba12>] dev_hard_start_xmit+0x2a2/0x3d0
Feb  2 19:02:06 leo-naphta kernel: [  329.889225]        [<ffffffff8143b7bb>] sch_direct_xmit+0x11b/0x1f0
Feb  2 19:02:06 leo-naphta kernel: [  329.889233]        [<ffffffff8141bf26>] __dev_queue_xmit+0x2b6/0x780
Feb  2 19:02:06 leo-naphta kernel: [  329.889240]        [<ffffffff8141c3fe>] dev_queue_xmit_sk+0xe/0x10
Feb  2 19:02:06 leo-naphta kernel: [  329.889248]        [<ffffffff814232fd>] neigh_direct_output+0xd/0x10
Feb  2 19:02:06 leo-naphta kernel: [  329.889255]        [<ffffffff8145b426>] ip_finish_output2+0x1e6/0x610
Feb  2 19:02:06 leo-naphta kernel: [  329.889265]        [<ffffffff8145cad4>] ip_finish_output+0x1a4/0x300
Feb  2 19:02:06 leo-naphta kernel: [  329.889272]        [<ffffffff8145cf4d>] ip_output+0x6d/0x100
Feb  2 19:02:06 leo-naphta kernel: [  329.889279]        [<ffffffff8145afc4>] ip_local_out_sk+0x34/0x70
Feb  2 19:02:06 leo-naphta kernel: [  329.889286]        [<ffffffff8145d911>] ip_send_skb+0x11/0x40
Feb  2 19:02:06 leo-naphta kernel: [  329.889293]        [<ffffffff81486031>] udp_send_skb+0x171/0x260
Feb  2 19:02:06 leo-naphta kernel: [  329.889304]        [<ffffffff81486e3e>] udp_sendmsg+0x2de/0xa80
Feb  2 19:02:06 leo-naphta kernel: [  329.889310]        [<ffffffff814961fd>] inet_sendmsg+0xfd/0x1c0
Feb  2 19:02:06 leo-naphta kernel: [  329.889318]        [<ffffffff813fcd2c>] ___sys_sendmsg+0x2ac/0x2c0
Feb  2 19:02:06 leo-naphta kernel: [  329.889327]        [<ffffffff813fd69d>] __sys_sendmsg+0x3d/0x70
Feb  2 19:02:06 leo-naphta kernel: [  329.889334]        [<ffffffff813fd6dd>] SyS_sendmsg+0xd/0x20
Feb  2 19:02:06 leo-naphta kernel: [  329.889342]        [<ffffffff815137db>] entry_SYSCALL_64_fastpath+0x16/0x6f
Feb  2 19:02:06 leo-naphta kernel: [  329.889350] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889350] -> #0 (_xmit_PPP#2){+.....}:
Feb  2 19:02:06 leo-naphta kernel: [  329.889360]        [<ffffffff8108ea3b>] __lock_acquire+0x1a6b/0x1a70
Feb  2 19:02:06 leo-naphta kernel: [  329.889366]        [<ffffffff8108f2f0>] lock_acquire+0x60/0x80
Feb  2 19:02:06 leo-naphta kernel: [  329.889372]        [<ffffffff81512c13>] _raw_spin_lock+0x33/0x50
Feb  2 19:02:06 leo-naphta kernel: [  329.889380]        [<ffffffff8143b793>] sch_direct_xmit+0xf3/0x1f0
Feb  2 19:02:06 leo-naphta kernel: [  329.889388]        [<ffffffff8141bf26>] __dev_queue_xmit+0x2b6/0x780
Feb  2 19:02:06 leo-naphta kernel: [  329.889395]        [<ffffffff8141c3fe>] dev_queue_xmit_sk+0xe/0x10
Feb  2 19:02:06 leo-naphta kernel: [  329.889403]        [<ffffffff814232fd>] neigh_direct_output+0xd/0x10
Feb  2 19:02:06 leo-naphta kernel: [  329.889408]        [<ffffffff8145b426>] ip_finish_output2+0x1e6/0x610
Feb  2 19:02:06 leo-naphta kernel: [  329.889416]        [<ffffffff8145cad4>] ip_finish_output+0x1a4/0x300
Feb  2 19:02:06 leo-naphta kernel: [  329.889422]        [<ffffffff8145cf4d>] ip_output+0x6d/0x100
Feb  2 19:02:06 leo-naphta kernel: [  329.889429]        [<ffffffff814b8cc1>] xfrm_output_resume+0x541/0x620
Feb  2 19:02:06 leo-naphta kernel: [  329.889437]        [<ffffffff814b8e09>] xfrm_output+0x49/0x110
Feb  2 19:02:06 leo-naphta kernel: [  329.889444]        [<ffffffff814aaa94>] xfrm4_output_finish+0x24/0x30
Feb  2 19:02:06 leo-naphta kernel: [  329.889452]        [<ffffffff814aa8ef>] __xfrm4_output+0x3f/0xd0
Feb  2 19:02:06 leo-naphta kernel: [  329.889459]        [<ffffffff814aaadc>] xfrm4_output+0x3c/0xe0
Feb  2 19:02:06 leo-naphta kernel: [  329.889467]        [<ffffffff8145afc4>] ip_local_out_sk+0x34/0x70
Feb  2 19:02:06 leo-naphta kernel: [  329.889474]        [<ffffffff8145bba1>] ip_queue_xmit+0x1d1/0x550
Feb  2 19:02:06 leo-naphta kernel: [  329.889481]        [<ffffffffa037186b>] l2tp_xmit_skb+0x28b/0x3d0 [l2tp_core]
Feb  2 19:02:06 leo-naphta kernel: [  329.889489]        [<ffffffffa037c563>] pppol2tp_xmit+0x143/0x1f3 [l2tp_ppp]
Feb  2 19:02:06 leo-naphta kernel: [  329.889497]        [<ffffffffa03569ab>] ppp_channel_push+0x4b/0xc0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889505]        [<ffffffffa0356cb0>] ppp_write+0xc0/0xf0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889514]        [<ffffffff8115a2e3>] __vfs_write+0x23/0xe0
Feb  2 19:02:06 leo-naphta kernel: [  329.889520]        [<ffffffff8115ab9d>] vfs_write+0x9d/0x180
Feb  2 19:02:06 leo-naphta kernel: [  329.889526]        [<ffffffff8115b6d4>] SyS_write+0x44/0xa0
Feb  2 19:02:06 leo-naphta kernel: [  329.889533]        [<ffffffff815137db>] entry_SYSCALL_64_fastpath+0x16/0x6f
Feb  2 19:02:06 leo-naphta kernel: [  329.889542] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889542] other info that might help us debug this:
Feb  2 19:02:06 leo-naphta kernel: [  329.889542] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889547] Chain exists of:
Feb  2 19:02:06 leo-naphta kernel: [  329.889547]   _xmit_PPP#2 --> &(&pch->downl)->rlock --> l2tp_sock
Feb  2 19:02:06 leo-naphta kernel: [  329.889547] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889561]  Possible unsafe locking scenario:
Feb  2 19:02:06 leo-naphta kernel: [  329.889561] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889565]        CPU0                    CPU1
Feb  2 19:02:06 leo-naphta kernel: [  329.889568]        ----                    ----
Feb  2 19:02:06 leo-naphta kernel: [  329.889570]   lock(l2tp_sock);
Feb  2 19:02:06 leo-naphta kernel: [  329.889576]                                lock(&(&pch->downl)->rlock);
Feb  2 19:02:06 leo-naphta kernel: [  329.889582]                                lock(l2tp_sock);
Feb  2 19:02:06 leo-naphta kernel: [  329.889587]   lock(_xmit_PPP#2);
Feb  2 19:02:06 leo-naphta kernel: [  329.889594] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889594]  *** DEADLOCK ***
Feb  2 19:02:06 leo-naphta kernel: [  329.889594] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889600] 5 locks held by pppd/4034:
Feb  2 19:02:06 leo-naphta kernel: [  329.889603]  #0:  (&(&pch->downl)->rlock){+.....}, at: [<ffffffffa035697d>] ppp_channel_push+0x1d/0xc0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889618]  #1:  (l2tp_sock){+.-...}, at: [<ffffffffa03716f7>] l2tp_xmit_skb+0x117/0x3d0 [l2tp_core]
Feb  2 19:02:06 leo-naphta kernel: [  329.889632]  #2:  (rcu_read_lock){......}, at: [<ffffffff8145b9d0>] ip_queue_xmit+0x0/0x550
Feb  2 19:02:06 leo-naphta kernel: [  329.889645]  #3:  (rcu_read_lock_bh){......}, at: [<ffffffff8145b2b7>] ip_finish_output2+0x77/0x610
Feb  2 19:02:06 leo-naphta kernel: [  329.889658]  #4:  (rcu_read_lock_bh){......}, at: [<ffffffff8141bcbb>] __dev_queue_xmit+0x4b/0x780
Feb  2 19:02:06 leo-naphta kernel: [  329.889672] 
Feb  2 19:02:06 leo-naphta kernel: [  329.889672] stack backtrace:
Feb  2 19:02:06 leo-naphta kernel: [  329.889679] CPU: 1 PID: 4034 Comm: pppd Not tainted 4.3.2 #5
Feb  2 19:02:06 leo-naphta kernel: [  329.889684] Hardware name: ASUSTeK Computer Inc. U30Sd/U30Sd, BIOS U30Sd.213 11/24/2011
Feb  2 19:02:06 leo-naphta kernel: [  329.889688]  ffffffff8236a350 ffff8800a286f8f0 ffffffff812895c9 ffffffff8236b280
Feb  2 19:02:06 leo-naphta kernel: [  329.889698]  ffff8800a286f930 ffffffff8108b6f3 ffff8800a286f980 ffff880148755a18
Feb  2 19:02:06 leo-naphta kernel: [  329.889706]  0000000000000002 0000000000000001 ffff880148755ab8 ffff880148755300
Feb  2 19:02:06 leo-naphta kernel: [  329.889715] Call Trace:
Feb  2 19:02:06 leo-naphta kernel: [  329.889724]  [<ffffffff812895c9>] dump_stack+0x4b/0x72
Feb  2 19:02:06 leo-naphta kernel: [  329.889730]  [<ffffffff8108b6f3>] print_circular_bug+0x1e3/0x250
Feb  2 19:02:06 leo-naphta kernel: [  329.889736]  [<ffffffff8108ea3b>] __lock_acquire+0x1a6b/0x1a70
Feb  2 19:02:06 leo-naphta kernel: [  329.889743]  [<ffffffff8108f2f0>] lock_acquire+0x60/0x80
Feb  2 19:02:06 leo-naphta kernel: [  329.889751]  [<ffffffff8143b793>] ? sch_direct_xmit+0xf3/0x1f0
Feb  2 19:02:06 leo-naphta kernel: [  329.889758]  [<ffffffff81512c13>] _raw_spin_lock+0x33/0x50
Feb  2 19:02:06 leo-naphta kernel: [  329.889765]  [<ffffffff8143b793>] ? sch_direct_xmit+0xf3/0x1f0
Feb  2 19:02:06 leo-naphta kernel: [  329.889772]  [<ffffffff8143b793>] sch_direct_xmit+0xf3/0x1f0
Feb  2 19:02:06 leo-naphta kernel: [  329.889779]  [<ffffffff8141bf26>] __dev_queue_xmit+0x2b6/0x780
Feb  2 19:02:06 leo-naphta kernel: [  329.889786]  [<ffffffff8141bcbb>] ? __dev_queue_xmit+0x4b/0x780
Feb  2 19:02:06 leo-naphta kernel: [  329.889793]  [<ffffffff8141c3fe>] dev_queue_xmit_sk+0xe/0x10
Feb  2 19:02:06 leo-naphta kernel: [  329.889798]  [<ffffffff814232fd>] neigh_direct_output+0xd/0x10
Feb  2 19:02:06 leo-naphta kernel: [  329.889804]  [<ffffffff8145b426>] ip_finish_output2+0x1e6/0x610
Feb  2 19:02:06 leo-naphta kernel: [  329.889810]  [<ffffffff8145b2b7>] ? ip_finish_output2+0x77/0x610
Feb  2 19:02:06 leo-naphta kernel: [  329.889817]  [<ffffffff8145cad4>] ip_finish_output+0x1a4/0x300
Feb  2 19:02:06 leo-naphta kernel: [  329.889823]  [<ffffffff8145cf4d>] ip_output+0x6d/0x100
Feb  2 19:02:06 leo-naphta kernel: [  329.889830]  [<ffffffff814b8cc1>] xfrm_output_resume+0x541/0x620
Feb  2 19:02:06 leo-naphta kernel: [  329.889836]  [<ffffffff814b8e09>] xfrm_output+0x49/0x110
Feb  2 19:02:06 leo-naphta kernel: [  329.889843]  [<ffffffff814aaa94>] xfrm4_output_finish+0x24/0x30
Feb  2 19:02:06 leo-naphta kernel: [  329.889850]  [<ffffffff814aa8ef>] __xfrm4_output+0x3f/0xd0
Feb  2 19:02:06 leo-naphta kernel: [  329.889857]  [<ffffffff814aaadc>] xfrm4_output+0x3c/0xe0
Feb  2 19:02:06 leo-naphta kernel: [  329.889863]  [<ffffffff8145aee3>] ? __ip_local_out_sk+0x33/0xe0
Feb  2 19:02:06 leo-naphta kernel: [  329.889871]  [<ffffffff81297a9f>] ? prandom_u32+0x1f/0x40
Feb  2 19:02:06 leo-naphta kernel: [  329.889877]  [<ffffffff8144f1f6>] ? ip_idents_reserve+0x66/0x80
Feb  2 19:02:06 leo-naphta kernel: [  329.889884]  [<ffffffff8145afc4>] ip_local_out_sk+0x34/0x70
Feb  2 19:02:06 leo-naphta kernel: [  329.889890]  [<ffffffff8145bba1>] ip_queue_xmit+0x1d1/0x550
Feb  2 19:02:06 leo-naphta kernel: [  329.889897]  [<ffffffff8145b9d0>] ? ip_copy_metadata+0x180/0x180
Feb  2 19:02:06 leo-naphta kernel: [  329.889905]  [<ffffffffa037186b>] l2tp_xmit_skb+0x28b/0x3d0 [l2tp_core]
Feb  2 19:02:06 leo-naphta kernel: [  329.889913]  [<ffffffffa037c563>] pppol2tp_xmit+0x143/0x1f3 [l2tp_ppp]
Feb  2 19:02:06 leo-naphta kernel: [  329.889920]  [<ffffffffa03569ab>] ppp_channel_push+0x4b/0xc0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889928]  [<ffffffffa0356cb0>] ppp_write+0xc0/0xf0 [ppp_generic]
Feb  2 19:02:06 leo-naphta kernel: [  329.889934]  [<ffffffff8115a2e3>] __vfs_write+0x23/0xe0
Feb  2 19:02:06 leo-naphta kernel: [  329.889941]  [<ffffffff8115ab9d>] vfs_write+0x9d/0x180
Feb  2 19:02:06 leo-naphta kernel: [  329.889950]  [<ffffffff81178f61>] ? __fget_light+0x61/0x90
Feb  2 19:02:06 leo-naphta kernel: [  329.889957]  [<ffffffff8115b6d4>] SyS_write+0x44/0xa0
Feb  2 19:02:06 leo-naphta kernel: [  329.889965]  [<ffffffff815137db>] entry_SYSCALL_64_fastpath+0x16/0x6f
Feb  2 19:02:32 leo-naphta kernel: [  356.033579] INFO: rcu_preempt self-detected stall on CPU
Feb  2 19:02:32 leo-naphta kernel: [  356.033609] ^I1: (1 GPs behind) idle=d51/140000000000001/0 softirq=21854/21854 fqs=8661 
Feb  2 19:02:32 leo-naphta kernel: [  356.033612] ^I (t=26000 jiffies g=11850 c=11849 q=475)
Feb  2 19:02:32 leo-naphta kernel: [  356.033629] Task dump for CPU 1:
Feb  2 19:02:32 leo-naphta kernel: [  356.033634] pppd            R  running task        0  4034   2653 0x00000008
Feb  2 19:02:32 leo-naphta kernel: [  356.033642]  0000000000000a5d ffff88014fa43da0 ffffffff810722ee ffffffff8107221c
Feb  2 19:02:32 leo-naphta kernel: [  356.033651]  0000000000000001 ffffffff81a2fb40 ffff88014fa43db8 ffffffff81075212
Feb  2 19:02:32 leo-naphta kernel: [  356.033659]  0000000000000002 ffff88014fa43de8 ffffffff810a7f13 ffff88014fa55240
Feb  2 19:02:32 leo-naphta kernel: [  356.033667] Call Trace:
Feb  2 19:02:32 leo-naphta kernel: [  356.033671]  <IRQ>  [<ffffffff810722ee>] sched_show_task+0x12e/0x230
Feb  2 19:02:32 leo-naphta kernel: [  356.033688]  [<ffffffff8107221c>] ? sched_show_task+0x5c/0x230
Feb  2 19:02:32 leo-naphta kernel: [  356.033695]  [<ffffffff81075212>] dump_cpu_task+0x32/0x40
Feb  2 19:02:32 leo-naphta kernel: [  356.033703]  [<ffffffff810a7f13>] rcu_dump_cpu_stacks+0x83/0xd0
Feb  2 19:02:32 leo-naphta kernel: [  356.033709]  [<ffffffff810ac141>] rcu_check_callbacks+0x481/0x850
Feb  2 19:02:32 leo-naphta kernel: [  356.033717]  [<ffffffff81088a05>] ? cpuacct_account_field+0xd5/0x1b0
Feb  2 19:02:32 leo-naphta kernel: [  356.033723]  [<ffffffff81088930>] ? cpuacct_charge+0x1a0/0x1a0
Feb  2 19:02:32 leo-naphta kernel: [  356.033732]  [<ffffffff810ae8c4>] update_process_times+0x34/0x60
Feb  2 19:02:32 leo-naphta kernel: [  356.033739]  [<ffffffff810bd560>] tick_sched_handle.isra.18+0x20/0x50
Feb  2 19:02:32 leo-naphta kernel: [  356.033744]  [<ffffffff810bdbf8>] tick_sched_timer+0x38/0x70
Feb  2 19:02:32 leo-naphta kernel: [  356.033749]  [<ffffffff810bdbc0>] ? tick_sched_do_timer+0x30/0x30
Feb  2 19:02:32 leo-naphta kernel: [  356.033757]  [<ffffffff810af257>] __hrtimer_run_queues+0x97/0x190
Feb  2 19:02:32 leo-naphta kernel: [  356.033762]  [<ffffffff810af576>] hrtimer_interrupt+0xa6/0x1b0
Feb  2 19:02:32 leo-naphta kernel: [  356.033770]  [<ffffffff81089ead>] ? trace_hardirqs_off+0xd/0x10
Feb  2 19:02:32 leo-naphta kernel: [  356.033777]  [<ffffffff810305a3>] smp_trace_apic_timer_interrupt+0x63/0x90
Feb  2 19:02:32 leo-naphta kernel: [  356.033783]  [<ffffffff810305d9>] smp_apic_timer_interrupt+0x9/0x10
Feb  2 19:02:32 leo-naphta kernel: [  356.033792]  [<ffffffff81514594>] apic_timer_interrupt+0x84/0x90
Feb  2 19:02:32 leo-naphta kernel: [  356.033795]  <EOI>  [<ffffffffa035402a>] ? ppp_push+0x10a/0x5b0 [ppp_generic]
Feb  2 19:02:32 leo-naphta kernel: [  356.033811]  [<ffffffff81295938>] ? delay_tsc+0x18/0x80
Feb  2 19:02:32 leo-naphta kernel: [  356.033817]  [<ffffffff8129588a>] __delay+0xa/0x10
Feb  2 19:02:32 leo-naphta kernel: [  356.033823]  [<ffffffff810923a7>] do_raw_spin_lock+0x87/0x150
Feb  2 19:02:32 leo-naphta kernel: [  356.033830]  [<ffffffff81512d62>] _raw_spin_lock_bh+0x42/0x50
Feb  2 19:02:32 leo-naphta kernel: [  356.033837]  [<ffffffffa035402a>] ? ppp_push+0x10a/0x5b0 [ppp_generic]
Feb  2 19:02:32 leo-naphta kernel: [  356.033843]  [<ffffffffa035402a>] ppp_push+0x10a/0x5b0 [ppp_generic]
Feb  2 19:02:32 leo-naphta kernel: [  356.033850]  [<ffffffff81403858>] ? skb_dequeue+0x18/0x70
Feb  2 19:02:32 leo-naphta kernel: [  356.033858]  [<ffffffffa0356785>] ppp_xmit_process+0x3f5/0x5d0 [ppp_generic]
Feb  2 19:02:32 leo-naphta kernel: [  356.033863]  [<ffffffff8108cd1d>] ? trace_hardirqs_on+0xd/0x10
Feb  2 19:02:32 leo-naphta kernel: [  356.033870]  [<ffffffffa0356b96>] ppp_start_xmit+0x156/0x1b0 [ppp_generic]
Feb  2 19:02:32 leo-naphta kernel: [  356.033877]  [<ffffffff8141ba12>] dev_hard_start_xmit+0x2a2/0x3d0
Feb  2 19:02:32 leo-naphta kernel: [  356.033886]  [<ffffffff8143b7bb>] sch_direct_xmit+0x11b/0x1f0
Feb  2 19:02:32 leo-naphta kernel: [  356.033892]  [<ffffffff8141bf26>] __dev_queue_xmit+0x2b6/0x780
Feb  2 19:02:32 leo-naphta kernel: [  356.033898]  [<ffffffff8141bcbb>] ? __dev_queue_xmit+0x4b/0x780
Feb  2 19:02:32 leo-naphta kernel: [  356.033904]  [<ffffffff8141c3fe>] dev_queue_xmit_sk+0xe/0x10
Feb  2 19:02:32 leo-naphta kernel: [  356.033909]  [<ffffffff814232fd>] neigh_direct_output+0xd/0x10
Feb  2 19:02:32 leo-naphta kernel: [  356.033916]  [<ffffffff8145b426>] ip_finish_output2+0x1e6/0x610
Feb  2 19:02:32 leo-naphta kernel: [  356.033921]  [<ffffffff8145b2b7>] ? ip_finish_output2+0x77/0x610
Feb  2 19:02:32 leo-naphta kernel: [  356.033927]  [<ffffffff8145cad4>] ip_finish_output+0x1a4/0x300
Feb  2 19:02:32 leo-naphta kernel: [  356.033933]  [<ffffffff8145cf4d>] ip_output+0x6d/0x100
Feb  2 19:02:32 leo-naphta kernel: [  356.033940]  [<ffffffff814b8cc1>] xfrm_output_resume+0x541/0x620
Feb  2 19:02:32 leo-naphta kernel: [  356.033945]  [<ffffffff814b8e09>] xfrm_output+0x49/0x110
Feb  2 19:02:32 leo-naphta kernel: [  356.033952]  [<ffffffff814aaa94>] xfrm4_output_finish+0x24/0x30
Feb  2 19:02:32 leo-naphta kernel: [  356.033958]  [<ffffffff814aa8ef>] __xfrm4_output+0x3f/0xd0
Feb  2 19:02:32 leo-naphta kernel: [  356.033965]  [<ffffffff814aaadc>] xfrm4_output+0x3c/0xe0
Feb  2 19:02:32 leo-naphta kernel: [  356.033970]  [<ffffffff8145aee3>] ? __ip_local_out_sk+0x33/0xe0
Feb  2 19:02:32 leo-naphta kernel: [  356.033978]  [<ffffffff81297a9f>] ? prandom_u32+0x1f/0x40
Feb  2 19:02:32 leo-naphta kernel: [  356.033983]  [<ffffffff8144f1f6>] ? ip_idents_reserve+0x66/0x80
Feb  2 19:02:32 leo-naphta kernel: [  356.033989]  [<ffffffff8145afc4>] ip_local_out_sk+0x34/0x70
Feb  2 19:02:32 leo-naphta kernel: [  356.033994]  [<ffffffff8145bba1>] ip_queue_xmit+0x1d1/0x550
Feb  2 19:02:32 leo-naphta kernel: [  356.034000]  [<ffffffff8145b9d0>] ? ip_copy_metadata+0x180/0x180
Feb  2 19:02:32 leo-naphta kernel: [  356.034008]  [<ffffffffa037186b>] l2tp_xmit_skb+0x28b/0x3d0 [l2tp_core]
Feb  2 19:02:32 leo-naphta kernel: [  356.034016]  [<ffffffffa037c563>] pppol2tp_xmit+0x143/0x1f3 [l2tp_ppp]
Feb  2 19:02:32 leo-naphta kernel: [  356.034024]  [<ffffffffa03569ab>] ppp_channel_push+0x4b/0xc0 [ppp_generic]
Feb  2 19:02:32 leo-naphta kernel: [  356.034031]  [<ffffffffa0356cb0>] ppp_write+0xc0/0xf0 [ppp_generic]
Feb  2 19:02:32 leo-naphta kernel: [  356.034037]  [<ffffffff8115a2e3>] __vfs_write+0x23/0xe0
Feb  2 19:02:32 leo-naphta kernel: [  356.034043]  [<ffffffff8115ab9d>] vfs_write+0x9d/0x180
Feb  2 19:02:32 leo-naphta kernel: [  356.034052]  [<ffffffff81178f61>] ? __fget_light+0x61/0x90
Feb  2 19:02:32 leo-naphta kernel: [  356.034058]  [<ffffffff8115b6d4>] SyS_write+0x44/0xa0
Feb  2 19:02:32 leo-naphta kernel: [  356.034065]  [<ffffffff815137db>] entry_SYSCALL_64_fastpath+0x16/0x6f
