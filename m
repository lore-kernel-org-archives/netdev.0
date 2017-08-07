From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [PATCH] net: Reduce skb_warn_bad_offload() noise.
Date: Mon, 7 Aug 2017 08:37:55 +0800
Message-ID: <CAMDZJNUcqFYQ8c4urSyha+F2C0Z9WzTTw05qLBX9VYpCH4V6Wg@mail.gmail.com>
References: <1501852317-11684-1-git-send-email-xiangxia.m.yue@gmail.com> <1501853380.25002.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Pravin B Shelar <pshelar@ovn.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34354 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751374AbdHGAh4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 20:37:56 -0400
Received: by mail-oi0-f66.google.com with SMTP id v11so6356690oif.1
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 17:37:56 -0700 (PDT)
In-Reply-To: <1501853380.25002.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 4, 2017 at 9:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
> On Fri, 2017-08-04 at 06:11 -0700, Tonghao Zhang wrote:
>> This patch will revert the b2504a5dbe "net: reduce
>> skb_warn_bad_offload() noise". The ovs will call the
>> __skb_gso_segment() with tx false. When segmenting UDP with UFO,
>> the __skb_gso_segment raises a warning as below [1], because the
>> ip_summed is CHECKSUM_NONE. While the net-next has removed the
>> UFO support, but the 4.11 and 4.12 kernel don't address that problem.
>>
>> In the kernel, only qdisc_pkt_len_init() (__dev_queue_xmit call it.)
>> uses the SKB_GSO_DODGY to do something. Other places just set it.
>> The warn described in b2504a5dbe is shown [2]. We may know that:
>>     1. the net_device don=E2=80=99t have qdisc.
>>     2. the skb->ip_summed was changed to CHECKSUM_NONE. it maybe
>>     changed in skb_checksum_help() when calling validate_xmit_skb().
>>     or other place.
>>
>> And we should not revert the  6e7bc478c9 "net: skb_needs_check() accepts
>> CHECKSUM_NONE for tx". The check is necessary.
>
> Why is it necessary ?
I am not familiar with __skb_gso_segment() when tx_path =3D=3D true. I
should say sorry to you.

>
> If you revert b2504a5dbe, then we also need to revert 6e7bc478c9,
> unless you provide hard facts.
>
The openvswitch kernel module calls the __skb_gso_segment()(and sets
tx_path =3D false) when passing packets to userspace. The UFO will set
the ip_summed to CHECKSUM_NONE. There are a lot of warn logs. The warn
log is shown as below. I guess we should revert the patch.


>>
>> [1]
>> [321428.168903] WARNING: CPU: 0 PID: 2279 at net/core/dev.c:2562
>> skb_warn_bad_offload+0xc4/0x110
>> [321428.168906] san0: caps=3D(0x000004009fbb58e9, 0x0000000000000000) le=
n=3D6769
>> data_len=3D6727 gso_size=3D1480 gso_type=3D2 ip_summed=3D0
>>
>> [321428.168955] CPU: 0 PID: 2279 Comm: ruby-mri 4.11.12-200.fc25.x86_64 =
#1
>> [321428.168956] Hardware name: Supermicro SYS-1028U-TNRTP+/X10DRU-i+, BI=
OS 1.1 07/22/2015
>> [321428.168957] Call Trace:
>> [321428.168962]  dump_stack+0x63/0x86
>> [321428.168965]  __warn+0xcb/0xf0
>> [321428.168966]  warn_slowpath_fmt+0x5a/0x80
>> [321428.168968]  skb_warn_bad_offload+0xc4/0x110
>> [321428.168970]  __skb_gso_segment+0x190/0x1a0
>> [321428.168977]  queue_gso_packets+0x62/0x160 [openvswitch]
>> [321428.168992]  ovs_dp_upcall+0x31/0x60 [openvswitch]
>> [321428.168994]  ovs_dp_process_packet+0x10d/0x130 [openvswitch]
>> [321428.168997]  ovs_vport_receive+0x76/0xd0 [openvswitch]
>> [321428.169013]  internal_dev_xmit+0x28/0x60 [openvswitch]
>> [321428.169014]  dev_hard_start_xmit+0xa3/0x1f0
>> [321428.169016]  __dev_queue_xmit+0x592/0x650
>> [321428.169026]  dev_queue_xmit+0x10/0x20
>>
>> [2]
>> WARNING: CPU: 1 PID: 6768 at net/core/dev.c:2439 skb_warn_bad_offload+0x=
2af/0x390 net/core/dev.c:2434
>> lo: caps=3D(0x000000a2803b7c69, 0x0000000000000000) len=3D138 data_len=
=3D0 gso_size=3D15883 gso_type=3D4 ip_summed=3D0
>> Kernel panic - not syncing: panic_on_warn set ...
>>
>> CPU: 1 PID: 6768 Comm: syz-executor1 Not tainted 4.9.0 #5
>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS =
Google 01/01/2011
>> ffff8801c063ecd8 ffffffff82346bdf ffffffff00000001 1ffff100380c7d2e
>> ffffed00380c7d26 0000000041b58ab3 ffffffff84b37e38 ffffffff823468f1
>> ffffffff84820740 ffffffff84f289c0 dffffc0000000000 ffff8801c063ee20
>> Call Trace:
>
> Why are you adding this trace that was part of the b2504a5dbef3
> changelog ?
I hope we can fix the bug with other solution.

>
>> [<ffffffff82346bdf>] __dump_stack lib/dump_stack.c:15 [inline]
>> [<ffffffff82346bdf>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>> [<ffffffff81827e34>] panic+0x1fb/0x412 kernel/panic.c:179
>> [<ffffffff8141f704>] __warn+0x1c4/0x1e0 kernel/panic.c:542
>> [<ffffffff8141f7e5>] warn_slowpath_fmt+0xc5/0x100 kernel/panic.c:565
>> [<ffffffff8356cbaf>] skb_warn_bad_offload+0x2af/0x390 net/core/dev.c:243=
4
>> [<ffffffff83585cd2>] __skb_gso_segment+0x482/0x780 net/core/dev.c:2706
>> [<ffffffff83586f19>] skb_gso_segment include/linux/netdevice.h:3985 [inl=
ine]
>> [<ffffffff83586f19>] validate_xmit_skb+0x5c9/0xc20 net/core/dev.c:2969
>> [<ffffffff835892bb>] __dev_queue_xmit+0xe6b/0x1e70 net/core/dev.c:3383
>> [<ffffffff8358a2d7>] dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
>>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Willem de Bruijn <willemb@google.com>
>> Cc: Pravin B Shelar <pshelar@ovn.org>
>> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
>> ---
>
>
> IMO, this description is too confusing, I do not understand this patch.
sorry
