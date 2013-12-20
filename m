From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Thu, 19 Dec 2013 22:22:53 -0800
Message-ID: <1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59198 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab3LTGWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 01:22:55 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so334091pab.33
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 22:22:55 -0800 (PST)
In-Reply-To: <1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 17:34 -0800, Cong Wang wrote:
> tcf_match_indev() is called in fast path, it is not wise to
> search for a netdev by ifindex and then compare by its name,
> just compare the ifindex.
> 
> This will also save some bytes from the core struct of u32.
> 

This seems very suspect to me. How was it tested ?

BTW, latest net-next doesn't work anymore.

[   76.591023] BUG: unable to handle kernel paging request at ffffffffffffffff^M
[   76.598025] IP: [<ffffffffa008d882>] mirred_cleanup_module+0x13a/0x2a [act_mirred]^M
[   76.605624] PGD 180c067 PUD 180e067 PMD 0 ^M
[   76.609769] Oops: 0000 [#1] SMP ^M
[   76.613038] Modules linked in: act_mirred cls_tcindex sch_dsmark xt_multiport iptable_mangle w1_therm wire cdc_acm uhci_hcd ehci_hcd i2c_dev i2c_i801 i2c_core msr cpuid ib_uverbs mlx4_ib ib_sa ib_mad ib_core mlx4_en mlx4_core ipv6^M
[   76.633899] CPU: 27 PID: 10394 Comm: BweTCTree_DoWor Not tainted 3.13.0-smp-DEV #411^M
[   76.648567] task: ffff881030085670 ti: ffff881014088000 task.ti: ffff881014088000^M
[   76.656061] RIP: 0010:[<ffffffffa008d882>]  [<ffffffffa008d882>] mirred_cleanup_module+0x13a/0x2a [act_mirred]^M
[   76.666131] RSP: 0018:ffff8810140899b0  EFLAGS: 00010206^M
[   76.671455] RAX: 0000000000010000 RBX: ffff88101bfff240 RCX: 0000000000000000^M
[   76.678593] RDX: ffffffff818a4b50 RSI: ffffffffa0059790 RDI: ffff88101bfff240^M
[   76.685793] RBP: ffff881014089aa8 R08: ffff88107f4004c0 R09: ffff88101bfff240^M
[   76.692959] R10: ffff88102eb6eb40 R11: 00000000ffffff97 R12: ffff88102f2aa160^M
[   76.700133] R13: ffff88102f2aa000 R14: ffff88102f2aa000 R15: ffff881028802c00^M
[   76.707272] FS:  00007fddb20a0700(0000) GS:ffff88107fbe0000(0000) knlGS:0000000000000000^M
[   76.715429] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
[   76.721209] CR2: ffffffffffffffff CR3: 000000007919e000 CR4: 00000000001407e0^M
[   76.728364] Stack:^M
[   76.730378]  ffffffff814dd0e1 0000000000000028 ffffffff818a1940 ffffffff818a4b50^M
[   76.737845]  ffff88102eb6eb40 ffff881028802c24 0000000800000000 ffffffff818a1940^M
[   76.745367]  0000000000000000 ffffffff8169ca80 0001000000010000 ffff881014089a68^M
[   76.752860] Call Trace:^M
[   76.755320]  [<ffffffff814dd0e1>] ? tc_ctl_tfilter+0x4a1/0x760^M
[   76.761153]  [<ffffffff814e6866>] ? __netlink_sendskb+0x56/0x130^M
[   76.767165]  [<ffffffff814caa04>] rtnetlink_rcv_msg+0xa4/0x240^M
[   76.773026]  [<ffffffff814ca960>] ? __rtnl_unlock+0x20/0x20^M
[   76.778604]  [<ffffffff814e9741>] netlink_rcv_skb+0xb1/0xc0^M
[   76.784180]  [<ffffffff814c7635>] rtnetlink_rcv+0x25/0x40^M
[   76.789606]  [<ffffffff814e8fed>] netlink_unicast+0x14d/0x1f0^M
[   76.795359]  [<ffffffff814e9393>] netlink_sendmsg+0x303/0x410^M
[   76.801109]  [<ffffffff814a048c>] sock_sendmsg+0x9c/0xd0^M
[   76.806444]  [<ffffffff814a0da0>] ? move_addr_to_kernel+0x40/0xa0^M
[   76.812552]  [<ffffffff814add21>] ? verify_iovec+0x51/0xd0^M
[   76.818065]  [<ffffffff814a0c21>] ___sys_sendmsg+0x3c1/0x3d0^M
[   76.823740]  [<ffffffff8156897c>] ? __do_page_fault+0x26c/0x500^M
[   76.829706]  [<ffffffff811d23f6>] ? mntput+0x26/0x40^M
[   76.834718]  [<ffffffff811b4ce1>] ? __fput+0x161/0x230^M
[   76.839879]  [<ffffffff814a1809>] __sys_sendmsg+0x49/0x90^M
[   76.845299]  [<ffffffff814a1862>] SyS_sendmsg+0x12/0x20^M
[   76.850564]  [<ffffffff8156d252>] system_call_fastpath+0x16/0x1b^M

I wonder how you tested "net_sched: init struct tcf_hashinfo at register time",
it is completely buggy.

static inline int tcf_hashinfo_init(struct tcf_hashinfo *hf, unsigned int mask)

mask is a mask, yet all callers pass 'MASK+1'

include/net/act_api.h:49:static inline int tcf_hashinfo_init(struct tcf_hashinfo *hf, unsigned int mask)
net/sched/act_csum.c:589:       int err = tcf_hashinfo_init(&csum_hash_info, CSUM_TAB_MASK+1);
net/sched/act_gact.c:211:       int err = tcf_hashinfo_init(&gact_hash_info, GACT_TAB_MASK+1);
net/sched/act_ipt.c:317:        err = tcf_hashinfo_init(&ipt_hash_info, IPT_TAB_MASK+1);
net/sched/act_mirred.c:279:     err = tcf_hashinfo_init(&mirred_hash_info, MIRRED_TAB_MASK+1);
net/sched/act_nat.c:313:        int err = tcf_hashinfo_init(&nat_hash_info, NAT_TAB_MASK+1);
net/sched/act_pedit.c:249:      int err = tcf_hashinfo_init(&pedit_hash_info, PEDIT_TAB_MASK+1);
net/sched/act_police.c:399:     int err = tcf_hashinfo_init(&police_hash_info, POL_TAB_MASK+1);
net/sched/act_simple.c:206:     err = tcf_hashinfo_init(&simp_hash_info, SIMP_TAB_MASK+1);
net/sched/act_skbedit.c:206:    int err = tcf_hashinfo_init(&skbedit_hash_info, SKBEDIT_TAB_MASK+1);

I'll send a fix
