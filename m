From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH 00/17] v3 net generic subsystem refcount conversions
Date: Sat, 8 Jul 2017 18:51:26 +0000
Message-ID: <20170708185206.jj5mjjasmrd7bjry@sasha-lappy>
References: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
 <1499074136.1462.0.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Elena Reshetova <elena.reshetova@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omzsmtpe01.verizonbusiness.com ([199.249.25.210]:38195 "EHLO
        omzsmtpe01.verizonbusiness.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753108AbdGHSwE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 14:52:04 -0400
In-Reply-To: <1499074136.1462.0.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Content-ID: <74D87816258EE34BA047D34A5034D618@vzwcorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 03, 2017 at 02:28:56AM -0700, Eric Dumazet wrote:
>On Fri, 2017-06-30 at 13:07 +0300, Elena Reshetova wrote:
>> Changes in v3:
>> Rebased on top of the net-next tree.
>>
>> Changes in v2:
>> No changes in patches apart from rebases, but now by
>> default refcount_t =3D atomic_t (*) and uses all atomic standard operati=
ons
>> unless CONFIG_REFCOUNT_FULL is enabled. This is a compromise for the
>> systems that are critical on performance (such as net) and cannot accept=
 even
>> slight delay on the refcounter operations.
>>
>> This series, for core network subsystem components, replaces atomic_t re=
ference
>> counters with the new refcount_t type and API (see include/linux/refcoun=
t.h).
>> By doing this we prevent intentional or accidental
>> underflows or overflows that can led to use-after-free vulnerabilities.
>> These patches contain only generic net pieces. Other changes will be sen=
t separately.
>>
>> The patches are fully independent and can be cherry-picked separately.
>> The big patches, such as conversions for sock structure, need a very det=
ailed
>> look from maintainers: refcount managing is quite complex in them and wh=
ile
>> it seems that they would benefit from the change, extra checking is need=
ed.
>> The biggest corner issue is the fact that refcount_inc() does not increm=
ent
>> from zero.
>>
>> If there are no objections to the patches, please merge them via respect=
ive trees.
>>
>> * The respective change is currently merged into -next as
>>   "locking/refcount: Create unchecked atomic_t implementation".
>>
>> Elena Reshetova (17):
>>   net: convert inet_peer.refcnt from atomic_t to refcount_t
>>   net: convert neighbour.refcnt from atomic_t to refcount_t
>>   net: convert neigh_params.refcnt from atomic_t to refcount_t
>>   net: convert nf_bridge_info.use from atomic_t to refcount_t
>>   net: convert sk_buff.users from atomic_t to refcount_t
>>   net: convert sk_buff_fclones.fclone_ref from atomic_t to refcount_t
>>   net: convert sock.sk_wmem_alloc from atomic_t to refcount_t
>>   net: convert sock.sk_refcnt from atomic_t to refcount_t
>>   net: convert ip_mc_list.refcnt from atomic_t to refcount_t
>>   net: convert in_device.refcnt from atomic_t to refcount_t
>>   net: convert netpoll_info.refcnt from atomic_t to refcount_t
>>   net: convert unix_address.refcnt from atomic_t to refcount_t
>>   net: convert fib_rule.refcnt from atomic_t to refcount_t
>>   net: convert inet_frag_queue.refcnt from atomic_t to refcount_t
>>   net: convert net.passive from atomic_t to refcount_t
>>   net: convert netlbl_lsm_cache.refcount from atomic_t to refcount_t
>>   net: convert packet_fanout.sk_ref from atomic_t to refcount_t
>
>
>Can you take a look at this please ?
>
>[   64.601749] ------------[ cut here ]------------
>[   64.601757] WARNING: CPU: 0 PID: 6476 at lib/refcount.c:184 refcount_su=
b_and_test+0x75/0xa0
>[   64.601758] Modules linked in: w1_therm wire cdc_acm ehci_pci ehci_hcd =
mlx4_en ib_uverbs mlx4_ib ib_core mlx4_core
>[   64.601769] CPU: 0 PID: 6476 Comm: ip Tainted: G        W       4.12.0-=
smp-DEV #274
>[   64.601770] Hardware name: Intel RML,PCH/Iota_QC_19, BIOS 2.40.0 06/22/=
2016
>[   64.601771] task: ffff8837bf482040 task.stack: ffff8837bdc08000
>[   64.601773] RIP: 0010:refcount_sub_and_test+0x75/0xa0
>[   64.601774] RSP: 0018:ffff8837bdc0f5c0 EFLAGS: 00010286
>[   64.601776] RAX: 0000000000000026 RBX: 0000000000000001 RCX: 0000000000=
000000
>[   64.601777] RDX: 0000000000000026 RSI: 0000000000000096 RDI: ffffed06f7=
b81eae
>[   64.601778] RBP: ffff8837bdc0f5d0 R08: 0000000000000004 R09: fffffbfff4=
a54c25
>[   64.601779] R10: 00000000cbc500e5 R11: ffffffffa52a6128 R12: ffff881feb=
cf6f24
>[   64.601779] R13: ffff881fbf4eaf00 R14: ffff881febcf6f80 R15: ffff8837d7=
a4ed00
>[   64.601781] FS:  00007ff5a2f6b700(0000) GS:ffff881fff800000(0000) knlGS=
:0000000000000000
>[   64.601782] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>[   64.601783] CR2: 00007ffcdc70d000 CR3: 0000001f9c91e000 CR4: 0000000000=
1406f0
>[   64.601783] Call Trace:
>[   64.601786]  refcount_dec_and_test+0x11/0x20
>[   64.601790]  fib_nl_delrule+0xc39/0x1630
[snip]

I'm seeing a similar one coming from sctp:

refcount_t: underflow; use-after-free.
------------[ cut here ]------------
WARNING: CPU: 3 PID: 15570 at lib/refcount.c:186 refcount_sub_and_test.cold=
.13+0x18/0x21 lib/refcount.c:186
Kernel panic - not syncing: panic_on_warn set ...

CPU: 3 PID: 15570 Comm: syz-executor0 Not tainted 4.12.0-next-20170706+ #18=
6
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x11d/0x1ef lib/dump_stack.c:52
 panic+0x1bc/0x3ad kernel/panic.c:180
 __warn.cold.6+0x2f/0x2f kernel/panic.c:541
 report_bug+0x20d/0x2d0 lib/bug.c:183
 fixup_bug+0x3f/0x90 arch/x86/kernel/traps.c:190
 do_trap_no_signal arch/x86/kernel/traps.c:224 [inline]
 do_trap+0x132/0x390 arch/x86/kernel/traps.c:273
 do_error_trap+0x133/0x380 arch/x86/kernel/traps.c:310
 do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:323
 invalid_op+0x1e/0x30 arch/x86/entry/entry_64.S:845
RIP: 0010:refcount_sub_and_test.cold.13+0x18/0x21 lib/refcount.c:186
RSP: 0018:ffff880062f7e270 EFLAGS: 00010282
RAX: 0000000000000026 RBX: ffff88006086a8cc RCX: 0000000000000000
RDX: 0000000000000000 RSI: 1ffff1000c5efc0a RDI: ffffffffac15c400
RBP: ffff880062f7e2f8 R08: 0000000000000006 R09: 0000000000000000
R10: ffff880069914040 R11: 0000000000000000 R12: 00000000ffffff01
R13: 0000000000000100 R14: 1ffff1000c5efc4e R15: 0000000000000001
 sctp_wfree+0x183/0x620 net/sctp/socket.c:7745
 skb_release_head_state+0x124/0x250 net/core/skbuff.c:652
 skb_release_all+0x15/0x60 net/core/skbuff.c:665
 __kfree_skb net/core/skbuff.c:681 [inline]
 consume_skb+0x16c/0x500 net/core/skbuff.c:748
 sctp_chunk_destroy net/sctp/sm_make_chunk.c:1441 [inline]
 sctp_chunk_put+0x206/0x430 net/sctp/sm_make_chunk.c:1468
 sctp_chunk_free+0x53/0x60 net/sctp/sm_make_chunk.c:1455
 __sctp_outq_teardown+0x274/0x15b0 net/sctp/outqueue.c:228
 sctp_outq_free+0x15/0x20 net/sctp/outqueue.c:284
 sctp_association_free+0x2d4/0x934 net/sctp/associola.c:358
 sctp_cmd_delete_tcb net/sctp/sm_sideeffect.c:917 [inline]
 sctp_cmd_interpreter net/sctp/sm_sideeffect.c:1333 [inline]
 sctp_side_effects net/sctp/sm_sideeffect.c:1198 [inline]
 sctp_do_sm+0x4024/0x6d60 net/sctp/sm_sideeffect.c:1170
 sctp_primitive_ABORT+0xa0/0xd0 net/sctp/primitive.c:119
 sctp_close+0x293/0x9b0 net/sctp/socket.c:1529
 inet_release+0xed/0x1c0 net/ipv4/af_inet.c:425
 inet6_release+0x50/0x70 net/ipv6/af_inet6.c:432
 sock_release+0x8d/0x1b0 net/socket.c:597
 sock_close+0x16/0x20 net/socket.c:1112
 __fput+0x327/0x920 fs/file_table.c:210
 ____fput+0x15/0x20 fs/file_table.c:246
llcp: llcp_sock_recvmsg: Recv datagram failed state 5 -11 0
 task_work_run+0x192/0x270 kernel/task_work.c:116
 exit_task_work include/linux/task_work.h:21 [inline]
 do_exit+0xa42/0x1ba0 kernel/exit.c:864
 do_group_exit+0x151/0x410 kernel/exit.c:966
 get_signal+0x84e/0x18a0 kernel/signal.c:2330
 do_signal+0x9c/0x2210 arch/x86/kernel/signal.c:808
 exit_to_usermode_loop+0x187/0x220 arch/x86/entry/common.c:157
 prepare_exit_to_usermode arch/x86/entry/common.c:194 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:263 [inline]
 do_syscall_64+0x50b/0x740 arch/x86/entry/common.c:289
llcp: llcp_sock_recvmsg: Recv datagram failed state 5 -11 0
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x452309
RSP: 002b:00007f6aed443cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 0000000000718218 RCX: 0000000000452309
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000718218
RBP: 00000000007181f8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007fffb90a5aae
R13: 00007fffb90a5aaf R14: 00007f6aed4449c0 R15: 00007f6aed444700
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: 0x24000000 from 0xffffffff81000000 (relocation range: 0xffff=
ffff80000000-0xffffffffbfffffff)
Rebooting in 86400 seconds..

--=20

Thanks,
Sasha=
