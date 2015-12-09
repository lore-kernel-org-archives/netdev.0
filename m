From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Wed, 9 Dec 2015 15:41:29 +0100
Message-ID: <CACT4Y+YYbC53awV4eiDAwjJO=WHYGv3Og3XDh-gTFB1q_w0YXQ@mail.gmail.com>
References: <56631357.6020304@gmail.com> <CACT4Y+YCZO2rfYdO_ACPF1U0p3YyXYJGA_Bhdb8CP8pecLy7SA@mail.gmail.com>
 <20151207131524.GA22989@mrl.redhat.com> <CACT4Y+ZhRG-LCdEoF=WusYVUj8gnm16663GcgJ=ztu0QC6r0vg@mail.gmail.com>
 <20151207185218.GB22989@mrl.redhat.com> <5665DF20.9020904@gmail.com>
 <20151207195032.GA22987@mrl.redhat.com> <5665EE26.3000706@gmail.com>
 <5665F17B.5030908@gmail.com> <CACT4Y+ad0YGve+KB8wiv6f1+eHt9Ci19FGM0SMWQvJFSez+Rcw@mail.gmail.com>
 <20151208174039.GB22987@mrl.redhat.com> <CACT4Y+b1OEE9NqN3J5574iN7t8NEi9jPc2Hxoj6AMHZKjCJ-mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36876 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbbLIOlv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 09:41:51 -0500
Received: by wmww144 with SMTP id w144so76235217wmw.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 06:41:49 -0800 (PST)
In-Reply-To: <CACT4Y+b1OEE9NqN3J5574iN7t8NEi9jPc2Hxoj6AMHZKjCJ-mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 8:22 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Dec 8, 2015 at 6:40 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
>> On Tue, Dec 08, 2015 at 06:30:51PM +0100, Dmitry Vyukov wrote:
>>> On Mon, Dec 7, 2015 at 9:52 PM, Marcelo Ricardo Leitner
>>> <marcelo.leitner@gmail.com> wrote:
>>> > Em 07-12-2015 18:37, Vlad Yasevich escreveu:
>>> >>
>>> >> On 12/07/2015 02:50 PM, Marcelo Ricardo Leitner wrote:
>>> >>>
>>> >>> On Mon, Dec 07, 2015 at 02:33:52PM -0500, Vlad Yasevich wrote:
>>> >>>>
>>> >>>> On 12/07/2015 01:52 PM, Marcelo Ricardo Leitner wrote:
>>> >>>>>
>>> >>>>> Vlad, I reviewed the places on which it returns SCTP_DISPOSITION_ABORT,
>>> >>>>> and if I didn't miss something in there all of them either issue
>>> >>>>> SCTP_CMD_ASSOC_FAILED or SCTP_CMD_INIT_FAILED before returning it, thus
>>> >>>>> delaying DELETE_TCB and with that the asoc free.
>>> >>>>
>>> >>>>
>>> >>>> They delay it from the perspective of the command interpreter since the
>>> >>>> command
>>> >>>> to delete the TCB happens a little later, but status code  is checked
>>> >>>> after all
>>> >>>> commands are processed and command processing doesn't change it.  So the
>>> >>>> 'status'
>>> >>>> code would still be SCTP_DISPOSITION_ABORT after DELETE_TCB command was
>>> >>>> processed.
>>> >>>> So, I think we may still have an use-after-free issue here.
>>> >>>
>>> >>>
>>> >>> Gotcha! That's pretty much it then. From that point of view now, there
>>> >>> shouldn't be a case that it returns _ABORT without freeing the asoc in
>>> >>> the same loop. (more below)
>>> >>>
>>> >>>>> There is one place,
>>> >>>>> though, that may not do it that way, it's sctp_sf_abort_violation(),
>>> >>>>> but
>>> >>>>> then that code only runs if asoc is already NULL by then.
>>> >>>>
>>> >>>>
>>> >>>> I don't believe so.  The violation state function can run with a
>>> >>>> non-NULL association
>>> >>>> if we are encountering protocol violations after the association is
>>> >>>> established.
>>> >>>
>>> >>>
>>> >>> Yup, that's correct. I just tried to reference one case on which it
>>> >>> would return _ABORT without issuing any of those _FAILEDs before doing
>>> >>> so (meaning the association could still be valid) but that in that case,
>>> >>> the asoc was already NULL.
>>> >>
>>> >>
>>> >> I think it is possible to hit the 'discard:' tag in that function while
>>> >> still
>>> >> having a valid association.  That happens when ABORT chunk is required to
>>> >> be
>>> >> authenticated.  This that case, instead of generating an ABORT and
>>> >> terminating the
>>> >> current association, we just drop the packet, but still report an _ABORT
>>> >> disposition code.
>>> >>
>>> >> This probably need to change if we are going to catch the _ABORT
>>> >> disposition and
>>> >> clear the asoc pointer.
>>> >
>>> >
>>> > Oups. Nice one. I'll switch it to SCTP_DISPOSITION_DISCARD if it hits that
>>> > if() then. Thanks Vlad.
>>>
>>>
>>> So I am waiting for a new patch, right?
>>> Can you please combine all changes into a single patch (as far as I
>>> understand the previous one must be applied on top of the first one)?
>>
>> The patches were combined already, but this last pick by Vlad is just
>> not yet patched. It's not necessary for your testing and I didn't want
>> to interrupt it in case you were already testing it.
>>
>> You can use my last patch here, from 2 emails ago, the one which
>> contains this line:
>> -       case SCTP_DISPOSITION_ABORT:
>
>
> You are right. I missed that they are combined. Testing with it now.




Use-after-free still happens.
I am on commit aa53685549a2cfb5f175b0c4a20bc9aa1e5a1b85 (Dec 8) plus
the following sctp-related changes:

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 6098d4c..be23d5c 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -63,7 +63,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
                             sctp_state_t state,
                             struct sctp_endpoint *ep,
-                            struct sctp_association *asoc,
+                            struct sctp_association **asoc,
                             void *event_arg,
                             sctp_disposition_t status,
                             sctp_cmd_seq_t *commands,
@@ -1123,7 +1123,7 @@ int sctp_do_sm(struct net *net, sctp_event_t
event_type, sctp_subtype_t subtype,
        debug_post_sfn();

        error = sctp_side_effects(event_type, subtype, state,
-                                 ep, asoc, event_arg, status,
+                                 ep, &asoc, event_arg, status,
                                  &commands, gfp);
        debug_post_sfx();

@@ -1136,7 +1136,7 @@ int sctp_do_sm(struct net *net, sctp_event_t
event_type, sctp_subtype_t subtype,
 static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
                             sctp_state_t state,
                             struct sctp_endpoint *ep,
-                            struct sctp_association *asoc,
+                            struct sctp_association **asoc,
                             void *event_arg,
                             sctp_disposition_t status,
                             sctp_cmd_seq_t *commands,
@@ -1151,7 +1151,7 @@ static int sctp_side_effects(sctp_event_t
event_type, sctp_subtype_t subtype,
         * disposition SCTP_DISPOSITION_CONSUME.
         */
        if (0 != (error = sctp_cmd_interpreter(event_type, subtype, state,
-                                              ep, asoc,
+                                              ep, *asoc,
                                               event_arg, status,
                                               commands, gfp)))
                goto bail;
@@ -1174,11 +1174,12 @@ static int sctp_side_effects(sctp_event_t
event_type, sctp_subtype_t subtype,
                break;

        case SCTP_DISPOSITION_DELETE_TCB:
+       case SCTP_DISPOSITION_ABORT:
                /* This should now be a command. */
+               *asoc = NULL;
                break;

        case SCTP_DISPOSITION_CONSUME:
-       case SCTP_DISPOSITION_ABORT:
                /*
                 * We should no longer have much work to do here as the
                 * real work has been done as explicit commands above.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 03c8256..4c9282b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7199,6 +7199,9 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
        newinet->mc_ttl = 1;
        newinet->mc_index = 0;
        newinet->mc_list = NULL;
+
+       if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
+               net_enable_timestamp();
 }



The new program is:

// autogenerated by syzkaller (http://github.com/google/syzkaller)
#include <syscall.h>
#include <string.h>
#include <stdint.h>
#include <pthread.h>

long r0;

void *thr(void *arg)
{
        memcpy((void*)0x20001000,
"\x02\x00\x33\xd9\x7f\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
128);
        long r5 = syscall(SYS_connect, r0, 0x20001000ul, 0x80ul, 0, 0, 0);
        return 0;
}

int main()
{
        r0 = syscall(SYS_socket, 0xaul, 0x1ul, 0x84ul, 0, 0, 0);
        long r1 = syscall(SYS_mmap, 0x20000000ul, 0x10000ul, 0x3ul,
0x32ul, 0xfffffffffffffffful, 0x0ul);
        memcpy((void*)0x20000000,
"\x0a\x00\x33\xe0\x49\xd0\x2e\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x4c\x37\xff\xc4",
28);
        long r3 = syscall(SYS_bind, r0, 0x20000000ul, 0x1cul, 0, 0, 0);
        pthread_t th;
        pthread_create(&th, 0, thr, 0);
        *(uint32_t*)0x20002ff8 = 0x6;
        *(uint32_t*)0x20002ffc = 0x0;
        long r8 = syscall(SYS_setsockopt, r0, 0x1ul, 0xdul,
0x20002ff8ul, 0x8ul, 0);
        *(uint64_t*)0x20003ffd = 0x0;
        long r10 = syscall(SYS_sendfile, r0, r0, 0x20003ffdul, 0xc0ul, 0, 0);
        memcpy((void*)0x20004f90,
"\x88\x24\x1a\xa0\xa9\x55\x4a\x24\x5b\xe8\x4f\x5d\x46\x39\x42\x26\x62\xc3\xd5\xd1\x1c\x00\xf1\x73\x4c\x11\x8d\x48\xbd\x25\x4f\xd3\xc1\xef\xc7\xbf\x1d\x0c\xe1\xf2\xc6\x64\x9d\xb5\x98\x5e\xc0\x1b\x7e\x83\xee\x06\x79\x10\x3b\xeb\x3c\x89\x9e\x30\xb6\xb5\xbd\xf9\xaa\xc1\xe0\x47\xdf\xed\x94\xda\xc5\xcb\x21\x32\x66\xbd\xc9\xa5\x84\xbc\x32\x8f\xce\x8e\xff\x1f\x76\x63\x67\x2f\x40\xc7\x42\xa3\x60\x17\xd6\x05\x45\xc2\x10\xd1\x53\x5f\x0d\x02\xcd\xf1\x44\x30",
112);
        memcpy((void*)0x20004f80,
"\x0a\x00\x33\xdc\x14\x4d\x5b\xd1\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xdd\x01\xf8\xfd\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
128);
        long r13 = syscall(SYS_sendto, r0, 0x20004f90ul, 0x70ul,
0x0ul, 0x20004f80ul, 0x80ul);
        long r14 = syscall(SYS_listen, r0, 0x3ul, 0, 0, 0, 0);
        long r15 = syscall(SYS_accept4, r0, 0x20003f80ul,
0x20003ab4ul, 0x80800ul, 0, 0);
        *(uint64_t*)0x20003000 = 0x2;
        *(uint64_t*)0x20003008 = 0x2;
        *(uint64_t*)0x20003010 = 0x1;
        *(uint64_t*)0x20003018 = 0x7;
        *(uint64_t*)0x20003020 = 0x7;
        *(uint64_t*)0x20003028 = 0x5f;
        *(uint64_t*)0x20003030 = 0x9;
        *(uint64_t*)0x20003038 = 0x88;
        long r24 = syscall(SYS_setsockopt, r0, 0xfffffffffffffff7ul,
0x8ul, 0x20003000ul, 0x40ul, 0);
        long r25 = syscall(SYS_dup3, r15, r0, 0x80000ul, 0, 0, 0);
        memcpy((void*)0x20006000,
"\xd9\x4f\xbe\x3f\x43\x89\x02\x0d\x1e\x84\x8d\x16\xe8\xdf\xdd\x27\x1f\xfe\xc6\x4a\xfa\x93\x00\xb9\xaf\xd7\x5e\xf1\x1f\x88\xc4\x57\x12\x70\xb4\xc5\xa6\xfc\xb9\x99\xd2\x80\x30\x2a\x53\xda\xd2\x57\x6d\xdc",
50);
        long r27 = syscall(SYS_setsockopt, r25, 0x117ul, 0x1ul,
0x20006000ul, 0x32ul, 0);
        long r28 = syscall(SYS_close, r15, 0, 0, 0, 0, 0);
        return 0;
}


The use-after-free reports:

==================================================================
BUG: KASAN: use-after-free in sctp_do_sm+0x530e/0x5d90 at addr ffff880069d4c808
Read of size 4 by task a.out/8211
=============================================================================
BUG kmalloc-4096 (Tainted: G    B          ): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in sctp_association_new+0xbd/0x21d0 age=9 cpu=3 pid=8211
[<      none      >] ___slab_alloc+0x648/0x8c0 mm/slub.c:2468
[<      none      >] __slab_alloc+0x4c/0x90 mm/slub.c:2497
[<     inline     >] slab_alloc_node mm/slub.c:2560
[<     inline     >] slab_alloc mm/slub.c:2602
[<      none      >] kmem_cache_alloc_trace+0x23c/0x3f0 mm/slub.c:2619
[<     inline     >] kmalloc include/linux/slab.h:458
[<     inline     >] kzalloc include/linux/slab.h:602
[<      none      >] sctp_association_new+0xbd/0x21d0 net/sctp/associola.c:302
[<      none      >] __sctp_connect+0x5e8/0xd80 net/sctp/socket.c:1161
[<      none      >] sctp_connect+0xdc/0x130 net/sctp/socket.c:3874
[<      none      >] inet_dgram_connect+0x136/0x2a0 net/ipv4/af_inet.c:528
[<      none      >] SYSC_connect+0x263/0x380 net/socket.c:1542
[<      none      >] SyS_connect+0x24/0x30 net/socket.c:1523
[<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

INFO: Freed in sctp_association_put+0x179/0x2c0 age=11 cpu=3 pid=8211
[<      none      >] __slab_free+0x21e/0x3e0 mm/slub.c:2678
[<     inline     >] slab_free mm/slub.c:2833
[<      none      >] kfree+0x26f/0x3e0 mm/slub.c:3662
[<     inline     >] sctp_association_destroy net/sctp/associola.c:424
[<      none      >] sctp_association_put+0x179/0x2c0 net/sctp/associola.c:860
[<      none      >] sctp_association_free+0x416/0x5d0 net/sctp/associola.c:402
[<     inline     >] sctp_cmd_delete_tcb net/sctp/sm_sideeffect.c:867
[<     inline     >] sctp_cmd_interpreter net/sctp/sm_sideeffect.c:1287
[<     inline     >] sctp_side_effects net/sctp/sm_sideeffect.c:1153
[<      none      >] sctp_do_sm+0x1364/0x5d90 net/sctp/sm_sideeffect.c:1125
[<      none      >] sctp_primitive_ABORT+0xa9/0xd0 net/sctp/primitive.c:119
[<      none      >] sctp_close+0x2ad/0x9b0 net/sctp/socket.c:1517
[<      none      >] inet_release+0x111/0x270 net/ipv4/af_inet.c:413
[<      none      >] inet6_release+0x55/0x90 net/ipv6/af_inet6.c:406
[<      none      >] sock_release+0x96/0x260 net/socket.c:571
[<      none      >] sock_close+0x16/0x20 net/socket.c:1022
[<      none      >] __fput+0x244/0x860 fs/file_table.c:208
[<      none      >] ____fput+0x15/0x20 fs/file_table.c:244
[<      none      >] task_work_run+0x130/0x240 kernel/task_work.c:115
[<     inline     >] exit_task_work include/linux/task_work.h:21
[<      none      >] do_exit+0x885/0x3050 kernel/exit.c:750
[<      none      >] do_group_exit+0xec/0x390 kernel/exit.c:880

INFO: Slab 0xffffea0001a75200 objects=7 used=2 fp=0xffff880069d4c760
flags=0x5fffc0000004080
INFO: Object 0xffff880069d4c760 @offset=18272 fp=0xffff880069d4b588
CPU: 3 PID: 8211 Comm: a.out Tainted: G    B           4.4.0-rc4+ #158
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 0000000000000003 ffff880032a8f3e0 ffffffff82e0f6d8 0000000041b58ab3
 ffffffff87aa2c7d ffffffff82e0f626 ffff880031901740 ffffffff87ac3e19
 ffff88003e806a00 0000000000000008 ffff880069d4c760 ffff880032a8f3e0

Call Trace:
 [<ffffffff818450f4>] __asan_report_load4_noabort+0x54/0x70
mm/kasan/report.c:294
 [<     inline     >] sctp_assoc2id include/net/sctp/sctp.h:323
 [<ffffffff864927fe>] sctp_do_sm+0x530e/0x5d90 net/sctp/sm_sideeffect.c:1128
 [<ffffffff864f9899>] sctp_primitive_ABORT+0xa9/0xd0 net/sctp/primitive.c:119
 [<ffffffff864e55ad>] sctp_close+0x2ad/0x9b0 net/sctp/socket.c:1517
 [<ffffffff85bfe691>] inet_release+0x111/0x270 net/ipv4/af_inet.c:413
 [<ffffffff85d60ce5>] inet6_release+0x55/0x90 net/ipv6/af_inet6.c:406
 [<ffffffff856b3b96>] sock_release+0x96/0x260 net/socket.c:571
 [<ffffffff856b3d76>] sock_close+0x16/0x20 net/socket.c:1022
 [<ffffffff8189d304>] __fput+0x244/0x860 fs/file_table.c:208
 [<ffffffff8189d9b5>] ____fput+0x15/0x20 fs/file_table.c:244
 [<ffffffff813e2dc0>] task_work_run+0x130/0x240 kernel/task_work.c:115
 [<     inline     >] exit_task_work include/linux/task_work.h:21
 [<ffffffff8137d1e5>] do_exit+0x885/0x3050 kernel/exit.c:750
 [<ffffffff8137fb0c>] do_group_exit+0xec/0x390 kernel/exit.c:880
 [<ffffffff813aa957>] get_signal+0x677/0x1bf0 kernel/signal.c:2307
 [<ffffffff8118645e>] do_signal+0x7e/0x20a0 arch/x86/kernel/signal.c:712
 [<ffffffff81003a1e>] exit_to_usermode_loop+0xfe/0x1e0
arch/x86/entry/common.c:247
 [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
 [<ffffffff8100733b>] syscall_return_slowpath+0x16b/0x240
arch/x86/entry/common.c:344
 [<ffffffff86a92662>] int_ret_from_sys_call+0x25/0x9f
arch/x86/entry/entry_64.S:281
==================================================================
