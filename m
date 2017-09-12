From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net v3 1/3] net_sched: get rid of tcfa_rcu
Date: Tue, 12 Sep 2017 11:42:15 +0200
Message-ID: <20170912094215.GB2036@nanopsycho>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
 <20170911233332.7594-2-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
        jakub.kicinski@netronome.com, jhs@mojatatu.com,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36816 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbdILJmS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 05:42:18 -0400
Received: by mail-wr0-f194.google.com with SMTP id g50so5664946wra.3
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 02:42:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170911233332.7594-2-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 12, 2017 at 01:33:30AM CEST, xiyou.wangcong@gmail.com wrote:
>gen estimator has been rewritten in commit 1c0d32fde5bd
>("net_sched: gen_estimator: complete rewrite of rate estimators"),
>the caller is no longer needed to wait for a grace period.
>So this patch gets rid of it.
>
>This also completely closes a race condition between action free
>path and filter chain add/remove path for the following patch.
>Because otherwise the nested RCU callback can't be caught by
>rcu_barrier().
>
>Please see also the comments in code.

Looks like this is causing a null pointer dereference bug for me, 100%
of the time. Just add and remove any rule with action and you get:


[  598.599825] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[  598.607782] IP: tcf_action_destroy+0xc0/0x140
[  598.612231] PGD 0 P4D 0 
[  598.614797] Oops: 0000 [#1] SMP KASAN
[  598.618525] Modules linked in: act_gact cls_flower sch_ingress rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace fscache intel_rapl x86_pkg_temp_thermal coretemp mlxsw_spectrum kvm_intel mlxfw kvm parman bridge sunrpc irqbypass iTCO_wdt iTCO_vendor_support stp crct10dif_pclmul llc crc32_pclmul crc32c_intel mlxsw_pci ghash_clmulni_intel mlxsw_core i2c_i801 e1000e pcspkr ptp tpm_tis mei_me pps_core mei tpm_tis_core lpc_ich tpm shpchp video
[  598.659010] CPU: 1 PID: 758 Comm: bash Tainted: G    B           4.13.0jiri+ #70
[  598.666509] Hardware name: Mellanox Technologies Ltd. Mellanox switch/Mellanox x86 mezzanine board, BIOS 4.6.5 08/02/2016
[  598.677630] task: ffff880371624bc0 task.stack: ffff880387808000
[  598.683648] RIP: 0010:tcf_action_destroy+0xc0/0x140
[  598.688617] RSP: 0018:ffff88038d107cb8 EFLAGS: 00010282
[  598.693922] RAX: 0000000000000000 RBX: ffff88038d107d28 RCX: ffffffff820b80e0
[  598.701184] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 0000000000000030
[  598.708405] RBP: ffff88038d107ce8 R08: 0000000000000001 R09: 0000000000000001
[  598.715607] R10: ffff88038d107b27 R11: fffffbfff0bcf36c R12: 0000000000000000
[  598.722816] R13: ffff88038d107d38 R14: ffff88036bf75650 R15: 0000000000000001
[  598.730047] FS:  00007f398050b700(0000) GS:ffff88038d100000(0000) knlGS:0000000000000000
[  598.738253] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  598.744086] CR2: 0000000000000030 CR3: 0000000371ac4001 CR4: 00000000001606e0
[  598.751328] Call Trace:
[  598.753809]  <IRQ>
[  598.755871]  tcf_exts_destroy+0x17f/0x260
[  598.775969]  fl_destroy_filter+0x1d/0x30 [cls_flower]
[  598.781069]  rcu_process_callbacks+0x6b2/0xe00


Kasan says:

[  597.503005] BUG: KASAN: use-after-free in tcf_action_destroy+0xad/0x140
[  597.509751] Read of size 8 at addr ffff88036bf75640 by task bash/758
[  597.516222] 
[  597.517761] CPU: 1 PID: 758 Comm: bash Not tainted 4.13.0jiri+ #70
[  597.524075] Hardware name: Mellanox Technologies Ltd. Mellanox switch/Mellanox x86 mezzanine board, BIOS 4.6.5 08/02/2016
[  597.535132] Call Trace:
[  597.537630]  <IRQ>
[  597.539718]  dump_stack+0xd5/0x150
[  597.554853]  print_address_description+0x86/0x410
[  597.559667]  kasan_report+0x181/0x4c0
[  597.583360]  tcf_action_destroy+0xad/0x140
[  597.587551]  tcf_exts_destroy+0x17f/0x260


Ubsan says:

[  598.184033] UBSAN: Undefined behaviour in net/sched/act_api.c:523:4
[  598.190409] member access within null pointer of type 'const struct tc_action_ops'
[  598.198076] CPU: 1 PID: 758 Comm: bash Tainted: G    B           4.13.0jiri+ #70
[  598.205570] Hardware name: Mellanox Technologies Ltd. Mellanox switch/Mellanox x86 mezzanine board, BIOS 4.6.5 08/02/2016
[  598.216669] Call Trace:
[  598.219157]  <IRQ>
[  598.221245]  dump_stack+0xd5/0x150
[  598.228703]  ubsan_epilogue+0xd/0x4e
[  598.232333]  __ubsan_handle_type_mismatch+0xf2/0x293
[  598.252880]  tcf_action_destroy+0x115/0x140
[  598.257151]  tcf_exts_destroy+0x17f/0x260
[  598.277336]  fl_destroy_filter+0x1d/0x30 [cls_flower]
[  598.282472]  rcu_process_callbacks+0x6b2/0xe00

Looks like you need to save owner of the module before you call
__tcf_idr_release so you can later on use it for module_put
