From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [PATCH] net: Reduce skb_warn_bad_offload() noise.
Date: Tue, 8 Aug 2017 13:26:43 +0800
Message-ID: <CAMDZJNUyaXnVp7jAH-E_d-X__zikoa=-3ypHo64aOnqra7TbRw@mail.gmail.com>
References: <1501852317-11684-1-git-send-email-xiangxia.m.yue@gmail.com>
 <1501853380.25002.38.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAMDZJNUcqFYQ8c4urSyha+F2C0Z9WzTTw05qLBX9VYpCH4V6Wg@mail.gmail.com>
 <CAF=yD-K_nbns=KA_4Acq_PRA=tCP0r+d3fD=jiVx9DkAdkyUYw@mail.gmail.com> <CAMDZJNVRqbByUfa5Oc_=xs+O_BJ4ehUJUSz9Y+wCPwj6kQGtLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Pravin B Shelar <pshelar@ovn.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34720 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750736AbdHHF0o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 01:26:44 -0400
Received: by mail-oi0-f67.google.com with SMTP id v11so2297167oif.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 22:26:44 -0700 (PDT)
In-Reply-To: <CAMDZJNVRqbByUfa5Oc_=xs+O_BJ4ehUJUSz9Y+wCPwj6kQGtLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willem

In a case, there is also warn info. The test topo is shown as below.

VM01: veth1 and eth0 in the VM01 are inserted to ovs br0.
veth0(IP: 172.16.34.100/24) =E2=80=94=E2=80=94 veth1--br0--eth0

iperf3  -c 172.168.100.13 -i 1 -P 10 -t 10 -u -b 1000M -l 10K



VM02
eth0(IP: 172.16.34.200/24)
iperf3  -s

The warn info is shown as below [1]. If we change the CHECKSUM_NONE to
CHECKSUM_UNNECESSARY in the udp4_ufo_fragment().
and we should add a check in skb_needs_check() when outputting a packet.

diff --git a/net/core/dev.c b/net/core/dev.c
index 416137c..8fe12a7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2670,6 +2670,7 @@ static inline bool skb_needs_check(struct
sk_buff *skb, bool tx_path)
 {
        if (tx_path)
                return skb->ip_summed !=3D CHECKSUM_PARTIAL &&
+                      skb->ip_summed !=3D CHECKSUM_UNNECESSARY &&
                       skb->ip_summed !=3D CHECKSUM_NONE;

        return skb->ip_summed =3D=3D CHECKSUM_NONE;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 7812501..0932c85 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -235,7 +235,7 @@ static struct sk_buff *udp4_ufo_fragment(struct
sk_buff *skb,
        if (uh->check =3D=3D 0)
                uh->check =3D CSUM_MANGLED_0;

-       skb->ip_summed =3D CHECKSUM_NONE;
+       skb->ip_summed =3D CHECKSUM_UNNECESSARY;

        /* If there is no outer header we can fake a checksum offload
         * due to the fact that we have already done the checksum in


[1]:
[ 1291.596232] vmxnet3: caps=3D(0x0000006000214ba9, 0x0000000000000000)
len=3D10282 data_len=3D10240 gso_size=3D1480 gso_type=3D2 ip_summed=3D1
[ 1291.596239] ------------[ cut here ]------------
[ 1291.596242] WARNING: CPU: 1 PID: 2203 at net/core/dev.c:2564
skb_warn_bad_offload+0xd3/0xde
[ 1291.596242] Modules linked in: veth udp_tunnel gre openvswitch
nf_conntrack_ipv6 nf_nat_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4
nf_nat_ipv4 nf_defrag_ipv6 nf_nat nf_conntrack cfg80211 rfkill ext4
jbd2 mbcache sb_edac coretemp crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel pcbc aesni_intel crypto_simd glue_helper ppdev
vmw_balloon cryptd vmw_vmci sg i2c_piix4 pcspkr parport_pc parport
shpchp ip_tables xfs libcrc32c sd_mod ata_generic pata_acpi vmwgfx
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm
crc32c_intel serio_raw vmxnet3 ata_piix mptspi libata
scsi_transport_spi mptscsih mptbase i2c_core floppy dm_mirror
dm_region_hash dm_log dm_mod
[ 1291.596280] CPU: 1 PID: 2203 Comm: iperf3 Tainted: G        W
4.12.0+ #1
[ 1291.596280] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 09/21/2015
[ 1291.596281] task: ffff8be36f5e9680 task.stack: ffffb6c840d44000
[ 1291.596283] RIP: 0010:skb_warn_bad_offload+0xd3/0xde
[ 1291.596284] RSP: 0018:ffff8be3796438c8 EFLAGS: 00010246
[ 1291.596285] RAX: 0000000000000074 RBX: ffff8be363ff9f00 RCX: 00000000000=
00006
[ 1291.596286] RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffff8be3796=
4e0a0
[ 1291.596287] RBP: ffff8be3796438f0 R08: 0000000000000000 R09: 00000000000=
00bf2
[ 1291.596287] R10: 0000000000000004 R11: 0000000000000bf1 R12: ffff8be3660=
f0000
[ 1291.596288] R13: 0000000000000001 R14: 0000000000000000 R15: ffff8be3660=
f0000
[ 1291.596289] FS:  00007f8d93bdb740(0000) GS:ffff8be379640000(0000)
knlGS:0000000000000000
[ 1291.596290] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1291.596291] CR2: 0000555f94a6e0c8 CR3: 000000012b84a000 CR4: 00000000001=
406e0
[ 1291.596296] Call Trace:
[ 1291.596297]  <IRQ>
[ 1291.596300]  __skb_gso_segment+0x15d/0x170
[ 1291.596301]  validate_xmit_skb+0x12d/0x2b0
[ 1291.596303]  validate_xmit_skb_list+0x42/0x70
[ 1291.596306]  sch_direct_xmit+0xd0/0x1b0
[ 1291.596308]  __dev_queue_xmit+0x42e/0x630
[ 1291.596310]  ? hrtimer_interrupt+0xd2/0x1a0
[ 1291.596312]  dev_queue_xmit+0x10/0x20
[ 1291.596315]  ovs_vport_send+0xc2/0x150 [openvswitch]
[ 1291.596318]  do_output+0x53/0xf0 [openvswitch]
[ 1291.596322]  do_execute_actions+0x9bc/0x9d0 [openvswitch]
[ 1291.596324]  ? __bpf_prog_run+0x385/0x1310
[ 1291.596327]  ovs_execute_actions+0x40/0x120 [openvswitch]
[ 1291.596330]  ovs_dp_process_packet+0x84/0x120 [openvswitch]
[ 1291.596333]  ? ovs_ct_update_key+0x9a/0xe0 [openvswitch]
[ 1291.596336]  ovs_vport_receive+0x73/0xd0 [openvswitch]
[ 1291.596339]  ? handle_irq_event_percpu+0x54/0x80
[ 1291.596340]  ? handle_irq_event+0x46/0x60
[ 1291.596342]  ? handle_edge_irq+0x8d/0x130
[ 1291.596344]  ? handle_irq+0xab/0x120
[ 1291.596346]  ? irq_exit+0x77/0xf0
[ 1291.596348]  ? do_IRQ+0x51/0xd0
[ 1291.596352]  netdev_frame_hook+0xd3/0x160 [openvswitch]
[ 1291.596355]  __netif_receive_skb_core+0x1da/0x9e0
[ 1291.596358]  ? vport_netdev_free+0x30/0x30 [openvswitch]
[ 1291.596360]  ? kfree_skbmem+0x5a/0x60
[ 1291.596361]  ? consume_skb+0x34/0x90
[ 1291.596363]  __netif_receive_skb+0x18/0x60
[ 1291.596365]  process_backlog+0x95/0x140
[ 1291.596367]  net_rx_action+0x26c/0x3b0
[ 1291.596369]  __do_softirq+0xc9/0x269
[ 1291.596371]  do_softirq_own_stack+0x1c/0x30
[ 1291.596372]  </IRQ>
[ 1291.596374]  do_softirq+0x50/0x60
[ 1291.596375]  __local_bh_enable_ip+0x5a/0x70
[ 1291.596377]  ip_finish_output2+0x15e/0x390
[ 1291.596380]  ip_finish_output+0x136/0x1e0
[ 1291.596382]  ip_output+0x76/0xe0
[ 1291.596384]  ? ip_fragment.constprop.53+0x80/0x80
[ 1291.596386]  ip_local_out+0x35/0x40
[ 1291.596387]  ip_send_skb+0x19/0x40
[ 1291.596390]  udp_send_skb+0x172/0x280
[ 1291.596391]  udp_sendmsg+0x2cf/0xa60
[ 1291.596393]  ? ip_reply_glue_bits+0x50/0x50
[ 1291.596396]  ? sock_has_perm+0x75/0x90
[ 1291.596398]  inet_sendmsg+0x31/0xb0
[ 1291.596399]  sock_sendmsg+0x38/0x50
[ 1291.596401]  sock_write_iter+0x85/0xf0
[ 1291.596403]  __vfs_write+0xe3/0x160
[ 1291.596405]  vfs_write+0xb2/0x1b0
[ 1291.596407]  ? syscall_trace_enter+0x1d0/0x2b0
[ 1291.596408]  SyS_write+0x55/0xc0
[ 1291.596411]  do_syscall_64+0x67/0x150
[ 1291.596412]  entry_SYSCALL64_slow_path+0x25/0x25
[ 1291.596413] RIP: 0033:0x7f8d931cdc60
[ 1291.596414] RSP: 002b:00007ffc0790e9c8 EFLAGS: 00000246 ORIG_RAX:
0000000000000001
[ 1291.596415] RAX: ffffffffffffffda RBX: 0000000000002800 RCX: 00007f8d931=
cdc60
[ 1291.596417] RDX: 0000000000002800 RSI: 00007f8d93bc9000 RDI: 00000000000=
00012
[ 1291.596417] RBP: 00007f8d93bc9000 R08: 0000000000000000 R09: 00000000000=
0003d
[ 1291.596418] R10: 0000000000000001 R11: 0000000000000246 R12: 00000000000=
00012
[ 1291.596419] R13: 0000000000002800 R14: 0000000000000001 R15: 00007ffc079=
0ea40
[ 1291.596420] Code: 8d 94 24 d0 00 00 00 48 0f 44 ce 4d 85 e4 44 89
54 24 08 48 0f 44 d6 89 3c 24 48 89 c6 48 c7 c7 80 65 ac 8f 31 c0 e8
a7 bd a5 ff <0f> ff 48 83 c4 18 5b 41 5c 5d c3 55 48 89 f2 31 c0 89 fe
48 c7
[ 1291.596447] ---[ end trace b66534f41f98ceda ]---


On Tue, Aug 8, 2017 at 7:44 AM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wr=
ote:
> That is fine to me. I have tested it. Thanks.
>
> On Mon, Aug 7, 2017 at 12:42 PM, Willem de Bruijn
> <willemdebruijn.kernel@gmail.com> wrote:
>>> The openvswitch kernel module calls the __skb_gso_segment()(and sets
>>> tx_path =3D false) when passing packets to userspace. The UFO will set
>>> the ip_summed to CHECKSUM_NONE. There are a lot of warn logs. The warn
>>> log is shown as below. I guess we should revert the patch.
>>
>> Indeed, the software UFO code computes the checksum and
>> sets ip_summed to CHECKSUM_NONE, as is correct on the
>> egress path.
>>
>> Commit 6e7bc478c9a0 ("net: skb_needs_check() accepts
>> CHECKSUM_NONE for tx") revised the tx_path case in
>> skb_needs_check to avoid the warning exactly for the UFO case.
>>
>> We cannot just make an exception for CHECKSUM_NONE in the
>> !tx_path case, as the entire statement then becomes false:
>>
>>        return skb->ip_summed =3D=3D CHECKSUM_NONE;
>>
>> Since on egress CHECKSUM_UNNECESSARY is equivalent to
>> CHECKSUM_NONE, it should be fine to update the UFO code
>> to set that, instead:
>>
>> @@ -235,7 +235,7 @@ static struct sk_buff *udp4_ufo_fragment(struct
>> sk_buff *skb,
>>         if (uh->check =3D=3D 0)
>>                 uh->check =3D CSUM_MANGLED_0;
>>
>> -       skb->ip_summed =3D CHECKSUM_NONE;
>> +       skb->ip_summed =3D CHECKSUM_UNNECESSARY;
