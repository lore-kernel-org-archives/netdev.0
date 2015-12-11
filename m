From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Fri, 11 Dec 2015 14:35:32 +0100
Message-ID: <CACT4Y+YPEqETP7NTOwJ6=4yYoAmM30qv6oRgw7apSS3+UwusAg@mail.gmail.com>
References: <20151207185218.GB22989@mrl.redhat.com> <5665DF20.9020904@gmail.com>
 <20151207195032.GA22987@mrl.redhat.com> <5665EE26.3000706@gmail.com>
 <5665F17B.5030908@gmail.com> <CACT4Y+ad0YGve+KB8wiv6f1+eHt9Ci19FGM0SMWQvJFSez+Rcw@mail.gmail.com>
 <20151208174039.GB22987@mrl.redhat.com> <CACT4Y+b1OEE9NqN3J5574iN7t8NEi9jPc2Hxoj6AMHZKjCJ-mg@mail.gmail.com>
 <CACT4Y+YYbC53awV4eiDAwjJO=WHYGv3Og3XDh-gTFB1q_w0YXQ@mail.gmail.com>
 <20151209150356.GA3886@mrl.redhat.com> <20151209164108.GB3886@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35581 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbbLKNfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 08:35:54 -0500
Received: by mail-wm0-f47.google.com with SMTP id l68so13822532wml.0
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 05:35:53 -0800 (PST)
In-Reply-To: <20151209164108.GB3886@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 5:41 PM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Wed, Dec 09, 2015 at 01:03:56PM -0200, Marcelo Ricardo Leitner wrote:
>> On Wed, Dec 09, 2015 at 03:41:29PM +0100, Dmitry Vyukov wrote:
>> > On Tue, Dec 8, 2015 at 8:22 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> > > On Tue, Dec 8, 2015 at 6:40 PM, Marcelo Ricardo Leitner
>> > > <marcelo.leitner@gmail.com> wrote:
>> ...
>> > >> The patches were combined already, but this last pick by Vlad is just
>> > >> not yet patched. It's not necessary for your testing and I didn't want
>> > >> to interrupt it in case you were already testing it.
>> > >>
>> > >> You can use my last patch here, from 2 emails ago, the one which
>> > >> contains this line:
>> > >> -       case SCTP_DISPOSITION_ABORT:
>> > >
>> > >
>> > > You are right. I missed that they are combined. Testing with it now.
>> >
>> >
>> >
>> >
>> > Use-after-free still happens.
>> > I am on commit aa53685549a2cfb5f175b0c4a20bc9aa1e5a1b85 (Dec 8) plus
>> > the following sctp-related changes:
>>
>> Changes are fine.  Ugh. Ok, I'll try your new reproducer here.
>
> Heh I wasn't going to reproduce this by myself anytime soon, I think.
> It's using the same socket to connect to itself, and only happens if the
> connect() gets there before the listen() call. Figured this out because
> I could only reproduce it under strace at first.
>
> Please give this other patch a try. A state command
> (sctp_sf_cookie_wait_prm_abort) was issuing SCTP_CMD_INIT_FAILED, which
> leads to SCTP_CMD_DELETE_TCB, but returning SCTP_DISPOSITION_CONSUME,
> which fooled the patch.
>
> ---8<---
> commit 9f84d50e36cee0ce66e4ce9b3b1665e0a1dbcdd3
> Author: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date:   Fri Dec 4 15:30:23 2015 -0200
>
>     sctp: fix use-after-free in pr_debug statement
>
>     Dmitry Vyukov reported a use-after-free in the code expanded by the
>     macro debug_post_sfx, which is caused by the use of the asoc pointer
>     after it was freed within sctp_side_effect() scope.
>
>     This patch fixes it by allowing sctp_side_effect to clear that asoc
>     pointer when the TCB is freed.
>
>     As Vlad explained, we also have to cover the SCTP_DISPOSITION_ABORT case
>     because it will trigger DELETE_TCB too on that same loop.
>
>     Also, there was a place issuing SCTP_CMD_INIT_FAILED but returning
>     SCTP_DISPOSITION_CONSUME, which would fool the scheme above. Fix it by
>     returning SCTP_DISPOSITION_ABORT instead.
>
>     The macro is already prepared to handle such NULL pointer.
>
>     Reported-by: Dmitry Vyukov <dvyukov@google.com>
>
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 6098d4c42fa9..be23d5c2074f 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -63,7 +63,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>                              sctp_state_t state,
>                              struct sctp_endpoint *ep,
> -                            struct sctp_association *asoc,
> +                            struct sctp_association **asoc,
>                              void *event_arg,
>                              sctp_disposition_t status,
>                              sctp_cmd_seq_t *commands,
> @@ -1123,7 +1123,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
>         debug_post_sfn();
>
>         error = sctp_side_effects(event_type, subtype, state,
> -                                 ep, asoc, event_arg, status,
> +                                 ep, &asoc, event_arg, status,
>                                   &commands, gfp);
>         debug_post_sfx();
>
> @@ -1136,7 +1136,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
>  static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>                              sctp_state_t state,
>                              struct sctp_endpoint *ep,
> -                            struct sctp_association *asoc,
> +                            struct sctp_association **asoc,
>                              void *event_arg,
>                              sctp_disposition_t status,
>                              sctp_cmd_seq_t *commands,
> @@ -1151,7 +1151,7 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>          * disposition SCTP_DISPOSITION_CONSUME.
>          */
>         if (0 != (error = sctp_cmd_interpreter(event_type, subtype, state,
> -                                              ep, asoc,
> +                                              ep, *asoc,
>                                                event_arg, status,
>                                                commands, gfp)))
>                 goto bail;
> @@ -1174,11 +1174,12 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
>                 break;
>
>         case SCTP_DISPOSITION_DELETE_TCB:
> +       case SCTP_DISPOSITION_ABORT:
>                 /* This should now be a command. */
> +               *asoc = NULL;
>                 break;
>
>         case SCTP_DISPOSITION_CONSUME:
> -       case SCTP_DISPOSITION_ABORT:
>                 /*
>                  * We should no longer have much work to do here as the
>                  * real work has been done as explicit commands above.
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 6f46aa16cb76..d801e151498a 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -4959,12 +4959,10 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
>         sctp_cmd_seq_t *commands)
>  {
>         struct sctp_chunk *abort = arg;
> -       sctp_disposition_t retval;
>
>         /* Stop T1-init timer */
>         sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
>                         SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
> -       retval = SCTP_DISPOSITION_CONSUME;
>
>         sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
>
> @@ -4983,7 +4981,7 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
>         sctp_add_cmd_sf(commands, SCTP_CMD_INIT_FAILED,
>                         SCTP_PERR(SCTP_ERROR_USER_ABORT));
>
> -       return retval;
> +       return SCTP_DISPOSITION_ABORT;
>  }
>
>  /*


Still happens...
I am on commit aa53685549a2cfb5f175b0c4a20bc9aa1e5a1b85 with your
latest patch applied.
Can you figure out what happens now from the report below? If not I
can create a repro, it's just somewhat time consuming.


BUG: KASAN: use-after-free in sctp_do_sm+0x4bca/0x4db0 at addr ffff880067c600a8
Read of size 4 by task syzkaller_execu/10266
=============================================================================
BUG kmalloc-4096 (Tainted: G        W      ): kasan: bad access detected
-----------------------------------------------------------------------------
Disabling lock debugging due to kernel taint
INFO: Allocated in sctp_association_new+0x6f/0x1da0 age=53 cpu=2 pid=10265
[<      none      >] ___slab_alloc+0x489/0x4e0 mm/slub.c:2468
[<      none      >] __slab_alloc+0x4c/0x90 mm/slub.c:2497
[<     inline     >] slab_alloc_node mm/slub.c:2560
[<     inline     >] slab_alloc mm/slub.c:2602
[<      none      >] kmem_cache_alloc_trace+0x264/0x2f0 mm/slub.c:2619
[<     inline     >] kmalloc include/linux/slab.h:458
[<     inline     >] kzalloc include/linux/slab.h:602
[<      none      >] sctp_association_new+0x6f/0x1da0 net/sctp/associola.c:302
[<      none      >] sctp_unpack_cookie+0x8b0/0x11c0
net/sctp/sm_make_chunk.c:1812
[<      none      >] sctp_sf_do_5_1D_ce+0x3ca/0x1410 net/sctp/sm_statefuns.c:702
[<      none      >] sctp_do_sm+0x20d/0x4db0 net/sctp/sm_sideeffect.c:1122
[<      none      >] sctp_endpoint_bh_rcv+0x38d/0x830 net/sctp/endpointola.c:486
[<      none      >] sctp_inq_push+0x12c/0x190 net/sctp/inqueue.c:95
[<      none      >] sctp_rcv+0x1d3b/0x2840 net/sctp/input.c:270
[<      none      >] ip_local_deliver_finish+0x2b0/0xa50 net/ipv4/ip_input.c:216
[<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
[<     inline     >] NF_HOOK include/linux/netfilter.h:249
[<      none      >] ip_local_deliver+0x1c4/0x2f0 net/ipv4/ip_input.c:257
[<     inline     >] dst_input include/net/dst.h:465
[<      none      >] ip_rcv_finish+0x5ea/0x1730 net/ipv4/ip_input.c:365
[<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
[<     inline     >] NF_HOOK include/linux/netfilter.h:249
[<      none      >] ip_rcv+0x963/0x1080 net/ipv4/ip_input.c:455
[<      none      >] __netif_receive_skb_core+0x1636/0x2f90 net/core/dev.c:3943
[<      none      >] __netif_receive_skb+0x2a/0x160 net/core/dev.c:3978

INFO: Freed in sctp_association_put+0x150/0x250 age=0 cpu=2 pid=10266
[<      none      >] __slab_free+0x1fc/0x320 mm/slub.c:2678
[<     inline     >] slab_free mm/slub.c:2833
[<      none      >] kfree+0x26a/0x290 mm/slub.c:3662
[<     inline     >] sctp_association_destroy net/sctp/associola.c:424
[<      none      >] sctp_association_put+0x150/0x250 net/sctp/associola.c:860
[<      none      >] sctp_association_free+0x3dc/0x520 net/sctp/associola.c:402
[<     inline     >] sctp_cmd_delete_tcb net/sctp/sm_sideeffect.c:867
[<     inline     >] sctp_cmd_interpreter net/sctp/sm_sideeffect.c:1287
[<     inline     >] sctp_side_effects net/sctp/sm_sideeffect.c:1153
[<      none      >] sctp_do_sm+0x175c/0x4db0 net/sctp/sm_sideeffect.c:1125
[<      none      >] sctp_primitive_ABORT+0xa9/0xd0 net/sctp/primitive.c:119
[<      none      >] sctp_close+0x274/0x7b0 net/sctp/socket.c:1517
[<      none      >] inet_release+0xed/0x1c0 net/ipv4/af_inet.c:413
[<      none      >] sock_release+0x8d/0x1d0 net/socket.c:571
[<      none      >] sock_close+0x16/0x20 net/socket.c:1022
[<      none      >] __fput+0x233/0x780 fs/file_table.c:208
[<      none      >] ____fput+0x15/0x20 fs/file_table.c:244
[<      none      >] task_work_run+0x16b/0x200 kernel/task_work.c:115
[<     inline     >] exit_task_work include/linux/task_work.h:21
[<      none      >] do_exit+0x8bb/0x2b20 kernel/exit.c:750
[<      none      >] do_group_exit+0x108/0x320 kernel/exit.c:880
[<      none      >] get_signal+0x5e4/0x1500 kernel/signal.c:2307

INFO: Slab 0xffffea00019f1800 objects=7 used=1 fp=0xffff880067c60000
flags=0x5fffc0000004080
INFO: Object 0xffff880067c60000 @offset=0 fp=0xffff880067c623b0
CPU: 2 PID: 10266 Comm: syzkaller_execu Tainted: G    B   W
4.4.0-rc4+ #160
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff880038777458 ffffffff82899b0d ffff88003e806a00
 ffff880067c60000 ffff880067c60000 ffff880038777488 ffffffff816c5564
 ffff88003e806a00 ffffea00019f1800 ffff880067c60000 ffff880067c60000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82899b0d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
 [<ffffffff816c5564>] print_trailer+0xf4/0x150 mm/slub.c:659
 [<ffffffff816cbd1f>] object_err+0x2f/0x40 mm/slub.c:689
 [<     inline     >] print_address_description mm/kasan/report.c:138
 [<ffffffff816ce6dd>] kasan_report_error+0x25d/0x560 mm/kasan/report.c:251
 [<     inline     >] kasan_report mm/kasan/report.c:274
 [<ffffffff816cea9e>] __asan_report_load4_noabort+0x3e/0x40
mm/kasan/report.c:294
 [<     inline     >] sctp_assoc2id include/net/sctp/sctp.h:323
 [<ffffffff8566f14a>] sctp_do_sm+0x4bca/0x4db0 net/sctp/sm_sideeffect.c:1128
 [<ffffffff856c6289>] sctp_primitive_ABORT+0xa9/0xd0 net/sctp/primitive.c:119
 [<ffffffff856b1d94>] sctp_close+0x274/0x7b0 net/sctp/socket.c:1517
 [<ffffffff84f29dcd>] inet_release+0xed/0x1c0 net/ipv4/af_inet.c:413
 [<ffffffff84ae520d>] sock_release+0x8d/0x1d0 net/socket.c:571
 [<ffffffff84ae5366>] sock_close+0x16/0x20 net/socket.c:1022
 [<ffffffff81715f73>] __fput+0x233/0x780 fs/file_table.c:208
 [<ffffffff81716545>] ____fput+0x15/0x20 fs/file_table.c:244
 [<ffffffff8134679b>] task_work_run+0x16b/0x200 kernel/task_work.c:115
 [<     inline     >] exit_task_work include/linux/task_work.h:21
 [<ffffffff812f4d3b>] do_exit+0x8bb/0x2b20 kernel/exit.c:750
 [<ffffffff812f7118>] do_group_exit+0x108/0x320 kernel/exit.c:880
 [<ffffffff813196c4>] get_signal+0x5e4/0x1500 kernel/signal.c:2307
 [<ffffffff811507a3>] do_signal+0x83/0x1c90 arch/x86/kernel/signal.c:712
 [<ffffffff81003901>] exit_to_usermode_loop+0xf1/0x1a0
arch/x86/entry/common.c:247
 [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
 [<ffffffff8100631f>] syscall_return_slowpath+0x19f/0x210
arch/x86/entry/common.c:344
 [<ffffffff85b676e2>] int_ret_from_sys_call+0x25/0x9f
arch/x86/entry/entry_64.S:281
