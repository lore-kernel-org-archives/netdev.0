From: Ani Sinha <ani@arista.com>
Subject: kernel BUG in ipmr_queue_xmit()
Date: Thu, 29 Oct 2015 16:55:15 -0700 (PDT)
Message-ID: <alpine.OSX.2.00.1510291646320.59200@animac.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>, ani@anirban.org,
	fruggeri@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36685 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758398AbbJ2XzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 19:55:18 -0400
Received: by pacfv9 with SMTP id fv9so56971138pac.3
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 16:55:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys:

We are noticing the following kernel BUG in 3.18 kernel. The 
code path that leads to the crash is the following :

 ip_mroute_setsockopt()
  ->ipmr_mfc_add()
      ->ipmr_cache_resolve()
        ->ip_mr_forward()
           -> ipmr_queue_xmit()
             -> ipmr_forward_finish()
               ->IP_INC_STATS_BH()
                  -> SNMP_INC_STATS64_BH()
                    -> SNMP_INC_STATS_BH()
                          -> __this_cpu_inc()
                              -> __this_cpu_add()
                                  -> __this_cpu_preempt_check()
                                     -> check_preemption_disabled()

I have verified that preempt_count() is 0 when the crash happens.
Is anyone else seeing the same crash in the laetst upstream code? I dug 
around a little bit and it does not look like there were any fixes that 
went into post 3.18 kernel which could have disabled preemption in this 
code path but I could be wrong. 

thoughts?

[  499.991221] BUG: using __this_cpu_add() in preemptible [00000000] code: KernelMfib/2758
[  500.086877] caller is __this_cpu_preempt_check+0x13/0x15
[  500.086884] CPU: 0 PID: 2758 Comm: KernelMfib Tainted: P           O   3.18.19.Ar-2716649.EosKernelnextcolonafix #2
[  500.086891]  ffffffff8170eaca ffff880110d1b788 ffffffff81482b2a 0000000000000000
[  500.086906]  0000000000000000 ffff880110d1b7b8 ffffffff812010ae ffff880007cab800
[  500.086912]  ffff88001a060800 ffff88013a899108 ffff880108b84240 ffff880110d1b7c8
[  500.086918] Call Trace:
[  500.086926] [<ffffffff81482b2a>] dump_stack+0x52/0x80
[  500.086931] [<ffffffff812010ae>] check_preemption_disabled+0xce/0xe1
[  500.086936] [<ffffffff812010d4>] __this_cpu_preempt_check+0x13/0x15
[  500.086942] [<ffffffff81419d60>] ipmr_queue_xmit+0x647/0x70c
[  500.086947] [<ffffffff8141a154>] ip_mr_forward+0x32f/0x34e
[  500.086953] [<ffffffff8141af76>] ip_mroute_setsockopt+0xe03/0x108c
[  500.086959] [<ffffffff810553fc>] ? get_parent_ip+0x11/0x42
[  500.086967] [<ffffffff810e6974>] ? pollwake+0x4d/0x51
[  500.086972] [<ffffffff81058ac0>] ? default_wake_function+0x0/0xf
[  500.086977] [<ffffffff810553fc>] ? get_parent_ip+0x11/0x42
[  500.086981] [<ffffffff810613d9>] ? __wake_up_common+0x45/0x77
[  500.086987] [<ffffffff81486ea9>] ? _raw_spin_unlock_irqrestore+0x1d/0x32
[  500.086991] [<ffffffff810618bc>] ? __wake_up_sync_key+0x4a/0x53
[  500.086996] [<ffffffff8139a519>] ? sock_def_readable+0x71/0x75
[  500.087002] [<ffffffff813dd226>] do_ip_setsockopt+0x9d/0xb55
[  500.087008] [<ffffffff81429818>] ? unix_seqpacket_sendmsg+0x3f/0x41
[  500.087012] [<ffffffff813963fe>] ? sock_sendmsg+0x6d/0x86
[  500.087017] [<ffffffff813959d4>] ? sockfd_lookup_light+0x12/0x5d
[  500.087021] [<ffffffff8139650a>] ? SyS_sendto+0xf3/0x11b
[  500.087025] [<ffffffff810d5738>] ? new_sync_read+0x82/0xaa
[  500.087030] [<ffffffff813ddd19>] compat_ip_setsockopt+0x3b/0x99
[  500.087034] [<ffffffff813fb24a>] compat_raw_setsockopt+0x11/0x32
[  500.087038] [<ffffffff81399052>] compat_sock_common_setsockopt+0x18/0x1f
[  500.087043] [<ffffffff813c4d05>] compat_SyS_setsockopt+0x1a9/0x1cf
[  500.087048] [<ffffffff813c4149>] compat_SyS_socketcall+0x180/0x1e3
[  500.087054] [<ffffffff81488ea1>] cstar_dispatch+0x7/0x1e


-Ani
