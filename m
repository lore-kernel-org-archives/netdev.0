From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: kernel panic receiving flooded VXLAN traffic with OVS
Date: Fri, 07 Nov 2014 13:13:16 -0800
Message-ID: <26235.1415394796@famine>
References: <19014.1415325508@famine> <CALnjE+r-s-usJoHq0E74QdorKX2H2cx429xwmsQ2kh+tzp1Y-g@mail.gmail.com> <CAEP_g=95s37umz-hLGH0-sB32RcW+t+1dJ=_Eg1jMt4HYG+gEg@mail.gmail.com> <CAEP_g=_ToXZB14MY4Y+FaYfNj_GHpaX59n3nzDrkALXHBzK1yw@mail.gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"discuss@openvswitch.org" <discuss@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36562 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbaKGVNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 16:13:22 -0500
In-reply-to: <CAEP_g=_ToXZB14MY4Y+FaYfNj_GHpaX59n3nzDrkALXHBzK1yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse@nicira.com> wrote:

>On Fri, Nov 7, 2014 at 10:34 AM, Jesse Gross <jesse@nicira.com> wrote:
>> On Fri, Nov 7, 2014 at 9:40 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>>> On Thu, Nov 6, 2014 at 5:58 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
[...]
>>>>         I'm not sure if this is an error on the part of the RX / GRO
>>>> processing in assembling the GRO skb, or in how OVS calls skb_segment.
>>>>
>>>
>>> I think this is related skb_segment() issue where it is not able to
>>> handle this type of skb geometry. We need to fix skb-segmentation. I
>>> will investigate it more.
>>
>> One problem that I see is that vxlan_gro_complete() doesn't add
>> SKB_GSO_UDP_TUNNEL to gso_type. This causes us to attempt
>> fragmentation as UDP rather than continuing down to do TCP
>> segmentation. That probably screws up the skb geometry.
>
>I sent out a patch to fix this issue. I'm pretty sure that it is the
>root cause of the originally reported case but I don't have a good way
>to reproduce it so it would be great if you could test it Jay.

	I'm having an issue there; when I set up my recreation on
current net-next (3.18-rc2) without your new patch, I get the following
oops when my ovs script does "ovs-vsctl --if-exists del-br br-ex":

[   18.580812] BUG: unable to handle kernel paging request at 0000000022835df6
[   18.585532] IP: [<ffffffffa01cc5ec>] ovs_flow_tbl_insert+0xdc/0x1f0 [openvswitch]
[   18.585532] PGD b016e067 PUD afdf2067 PMD 0 
[   18.585532] Oops: 0002 [#1] SMP 
[   18.585532] Modules linked in: i915 openvswitch libcrc32c video
[   18.608578] sky2 0000:05:00.0 eth0: Link is up at 1000 Mbps, full duplex, flow control rx
[   18.585532]  drm_kms_helper drm gpio_ich lpc_ich i2c_algo_bit ppdev lp serio_raw coretemp kvm_intel kvm parport_pc parport mac_hid hid_generic usbhid hid psmouse r8169 sky2 mii
[   18.585532] CPU: 0 PID: 843 Comm: ovs-vswitchd Not tainted 3.18.0-rc2+ #7
[   18.585532] Hardware name: LENOVO 0829F3U/To be filled by O.E.M., BIOS 90KT15AUS 07/21/2010
[   18.585532] task: ffff880134af3200 ti: ffff8800b0cc4000 task.ti: ffff8800b0cc4000
[   18.585532] RIP: 0010:[<ffffffffa01cc5ec>]  [<ffffffffa01cc5ec>] ovs_flow_tbl_insert+0xdc/0x1f0 [openvswitch]
[   18.585532] RSP: 0018:ffff8800b0cc77a8  EFLAGS: 00010212
[   18.585532] RAX: 00000000432e9568 RBX: ffff880134cb2120 RCX: 0000000001d3d19d
[   18.585532] RDX: 00000000f4372b69 RSI: 000000006d3fa049 RDI: ffff8800b017c19c
[   18.585532] RBP: ffff8800b0cc77f8 R08: 0000000022835dc6 R09: 000000000974849a
[   18.585532] R10: ffffffffa01cc696 R11: 0000000000000004 R12: ffff880134cb2128
[   18.585532] R13: ffff8800b0cc7850 R14: ffff880134cb2128 R15: ffff8800b2706400
[   18.585532] FS:  00007f0497d3a980(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
[   18.585532] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   18.585532] CR2: 0000000022835df6 CR3: 00000000b060e000 CR4: 00000000000407f0
[   18.585532] Stack:
[   18.585532]  ffff8800b017c000 ffff8800b017c000 ffff8800b0cc7a70 ffff8800b017c1c0
[   18.585532]  ffff8800b076b400 ffff8800b017c000 ffff8800b0cc7a70 0000000000000000
[   18.585532]  ffff8800b076b400 ffff880134cb2120 ffff8800b0cc7a38 ffffffffa01c3ed5
[   18.585532] Call Trace:
[   18.585532]  [<ffffffffa01c3ed5>] ovs_flow_cmd_new+0x175/0x3a0 [openvswitch]
[   18.585532]  [<ffffffff81208688>] ? bh_lru_install+0x178/0x1b0
[   18.585532]  [<ffffffff8137ed83>] ? radix_tree_lookup_slot+0x13/0x30
[   18.585532]  [<ffffffff8165f445>] genl_family_rcv_msg+0x1a5/0x3c0
[   18.585532]  [<ffffffff8165f660>] ? genl_family_rcv_msg+0x3c0/0x3c0
[   18.585532]  [<ffffffff8165f6f1>] genl_rcv_msg+0x91/0xd0
[   18.585532]  [<ffffffff8165d761>] netlink_rcv_skb+0xc1/0xe0
[   18.585532]  [<ffffffff8165dc8c>] genl_rcv+0x2c/0x40
[   18.585532]  [<ffffffff8165ccf6>] netlink_unicast+0xf6/0x200
[   18.585532]  [<ffffffff8165d11d>] netlink_sendmsg+0x31d/0x780
[   18.585532]  [<ffffffff81614173>] sock_sendmsg+0x93/0xd0
[   18.585532]  [<ffffffff8101c375>] ? native_sched_clock+0x35/0x90
[   18.585532]  [<ffffffff8101c3d9>] ? sched_clock+0x9/0x10
[   18.585532]  [<ffffffff810966f5>] ? sched_clock_local+0x25/0x90
[   18.585532]  [<ffffffff81622427>] ? verify_iovec+0x47/0xd0
[   18.585532]  [<ffffffff81614989>] ___sys_sendmsg+0x399/0x3b0
[   18.585532]  [<ffffffff81096cb5>] ? fetch_task_cputime+0x95/0x100
[   18.585532]  [<ffffffff811de4c8>] ? pipe_read+0x1c8/0x2f0
[   18.585532]  [<ffffffff8101c375>] ? native_sched_clock+0x35/0x90
[   18.585532]  [<ffffffff8101c375>] ? native_sched_clock+0x35/0x90
[   18.585532]  [<ffffffff8101c3d9>] ? sched_clock+0x9/0x10
[   18.585532]  [<ffffffff8111cf1c>] ? acct_account_cputime+0x1c/0x20
[   18.585532]  [<ffffffff81096dab>] ? account_user_time+0x8b/0xa0
[   18.585532]  [<ffffffff811f30e5>] ? __fget_light+0x25/0x70
[   18.585532]  [<ffffffff81615082>] __sys_sendmsg+0x42/0x80
[   18.585532]  [<ffffffff816150d2>] SyS_sendmsg+0x12/0x20
[   18.585532]  [<ffffffff817365e4>] tracesys_phase2+0xd8/0xdd
[   18.585532] Code: 24 e8 4c 8b 45 b0 31 d2 4d 89 b8 48 03 00 00 41 0f b7 4f 28 41 0f b7 77 2a 0f b7 c1 29 ce 49 8d 7c 00 38 c1 fe 02 e8 d4 af 1d e1 <41> 89 40 30 4c 8b 2b 4c 89 c6 4c 89 ef e8 a2 f5 ff ff 8b 43 20 
[   18.585532] RIP  [<ffffffffa01cc5ec>] ovs_flow_tbl_insert+0xdc/0x1f0 [openvswitch]
[   18.585532]  RSP <ffff8800b0cc77a8>
[   18.585532] CR2: 0000000022835df6
[   18.969812] ---[ end trace fdb3743001087166 ]---

	I'll go back to 3.17 to test your patch in the meantime.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
