From: Jesse Gross <jesse@nicira.com>
Subject: Re: kernel panic receiving flooded VXLAN traffic with OVS
Date: Fri, 7 Nov 2014 12:27:33 -0800
Message-ID: <CAEP_g=_ToXZB14MY4Y+FaYfNj_GHpaX59n3nzDrkALXHBzK1yw@mail.gmail.com>
References: <19014.1415325508@famine> <CALnjE+r-s-usJoHq0E74QdorKX2H2cx429xwmsQ2kh+tzp1Y-g@mail.gmail.com>
 <CAEP_g=95s37umz-hLGH0-sB32RcW+t+1dJ=_Eg1jMt4HYG+gEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	netdev <netdev@vger.kernel.org>,
	"discuss@openvswitch.org" <discuss@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:55459 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752063AbaKGU1z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 15:27:55 -0500
Received: by mail-qc0-f173.google.com with SMTP id x3so3150242qcv.32
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 12:27:54 -0800 (PST)
In-Reply-To: <CAEP_g=95s37umz-hLGH0-sB32RcW+t+1dJ=_Eg1jMt4HYG+gEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2014 at 10:34 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Nov 7, 2014 at 9:40 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Thu, Nov 6, 2014 at 5:58 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>>>
>>>         I am able to reproduce a kernel panic on an system using
>>> openvswitch when receiving VXLAN traffic under a very specific set of
>>> circumstances.  This occurs with a recent net-next as well as an Ubuntu
>>> 3.13 kernel.  I'm not sure if the error lies in OVS, GRO, or elsewhere.
>>>
>>>         In summary, when the system receives multiple VXLAN encapsulated
>>> TCP segments for a different system (not intended for local reception)
>>> that are from the middle of an active connection (received due to a switch
>>> flood), and are tagged to a VLAN not configured on the local host, then
>>> the system panics in skb_segment when OVS calls __skb_gso_segment on the
>>> GRO skb prior to performing an upcall to user space.
>>>
>>>         The panic occurs in skbuff.c:skb_segment(), at the BUG_ON around
>>> line 3036:
>>>
>>> struct sk_buff *skb_segment(struct sk_buff *head_skb,
>>>                             netdev_features_t features)
>>> {
>>> [...]
>>>                 skb_shinfo(nskb)->tx_flags = skb_shinfo(head_skb)->tx_flags &
>>>                         SKBTX_SHARED_FRAG;
>>>
>>>                 while (pos < offset + len) {
>>>                         if (i >= nfrags) {
>>>                                 BUG_ON(skb_headlen(list_skb));
>>>
>>>                                 i = 0;
>>>
>>>
>>>         The BUG_ON triggers because the skbs that have been GRO
>>> accumulated are partially or entirely linear, depending upon the receiving
>>> network device (sky2 is partial, enic is entire).  The receive buffers end
>>> up being linear evidently because the mtu is set to 9000, and
>>> __netdev_alloc_skb calls __alloc_skb (and thus kmalloc) instead of
>>> __netdev_alloc_frag followed by build_skb.
>>>
>>>         The foreign-VLAN VXLAN TCP segments are not processed as normal
>>> VXLAN traffic, as there is no listener on the VLAN in question, so once
>>> GRO processes them, they are sent directly to ovs_vport_receive.  The
>>> panic stack appears as follows:
>>>
>>> [ 6558.812214] kernel BUG at net/core/skbuff.c:3025!
>>> [ 6558.812214] invalid opcode: 0000 [#1] SMP
>>> [ 6558.812214] Modules linked in: veth 8021q garp mrp bonding xt_tcpudp bridge stp llc iptable_filter ip_tables x_tables openvswitch vxlan ip6_udp_tunnel udp_tunnel gre libcrc32c i915 video drm_kms_helper coretemp drm kvm_intel kvm gpio_ich ppdev parport_pc lp lpc_ich serio_raw i2c_algo_bit parport mac_hid hid_generic usbhid hid psmouse r8169 mii sky2
>>> [ 6558.812214] CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted 3.17.0-rc7-testola+ #5
>>> [ 6558.812214] Hardware name: LENOVO 0829F3U/To be filled by O.E.M., BIOS 90KT15AUS 07/21/2010
>>> [ 6558.812214] task: ffff880139eb3200 ti: ffff880139ed0000 task.ti: ffff880139ed0000
>>> [ 6558.812214] RIP: 0010:[<ffffffff81616bc2>]  [<ffffffff81616bc2>] skb_segment+0x9d2/0xa00
>>> [ 6558.812214] RSP: 0018:ffff880139ed3610  EFLAGS: 00010216
>>> [ 6558.812214] RAX: 00000000000002dc RBX: ffff8800a3be5e00 RCX: ffff8800b10a26f0
>>> [ 6558.812214] RDX: 0000000000000074 RSI: ffff8800b10a2600 RDI: ffff8800b10a2000
>>> [ 6558.812214] RBP: ffff880139ed36e0 R08: 0000000000000022 R09: 0000000000000000
>>> [ 6558.812214] R10: ffff8800b11e6000 R11: 00000000000005ca R12: ffff8800b10a20f0
>>> [ 6558.812214] R13: 0000000000000000 R14: ffff8800b116cb00 R15: 0000000000000074
>>> [ 6558.812214] FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
>>> [ 6558.812214] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>> [ 6558.812214] CR2: 00007fa906f4f148 CR3: 00000000b2a46000 CR4: 00000000000407f0
>>> [ 6558.812214] Stack:
>>> [ 6558.812214]  00000000000016a0 ffff880031353800 ffffffffffffffde ffff8800000005ca
>>> [ 6558.812214]  0000000000000022 0000000000000040 ffff8800b11e6000 00000001000016a0
>>> [ 6558.812214]  0000000000000000 0000000000000022 00000000000005a8 ffff8800a3be5e00
>>> [ 6558.812214] Call Trace:
>>> [ 6558.812214]  [<ffffffff8168c97f>] udp4_ufo_fragment+0x10f/0x1a0
>>> [ 6558.812214]  [<ffffffff81695c51>] inet_gso_segment+0x141/0x370
>>> [ 6558.812214]  [<ffffffff810aa2c8>] ? __wake_up_common+0x58/0x90
>>> [ 6558.812214]  [<ffffffff81624f4f>] skb_mac_gso_segment+0x9f/0x100
>>> [ 6558.812214]  [<ffffffff81625016>] __skb_gso_segment+0x66/0xd0
>>> [ 6558.812214]  [<ffffffffa01d4c91>] queue_gso_packets+0x41/0x130 [openvswitch]
>>> [ 6558.812214]  [<ffffffff8121aa4d>] ? ep_poll_safewake+0x2d/0x30
>>> [ 6558.812214]  [<ffffffff8121b03d>] ? ep_poll_callback+0xcd/0x170
>>> [ 6558.812214]  [<ffffffff810aa2c8>] ? __wake_up_common+0x58/0x90
>>> [ 6558.812214]  [<ffffffff810aa860>] ? __wake_up_sync_key+0x50/0x60
>>> [ 6558.812214]  [<ffffffff8161c232>] ? __skb_flow_dissect+0x162/0x4c0
>>> [ 6558.812214]  [<ffffffff8172001f>] ? __slab_free+0xfe/0x2c3
>>> [ 6558.812214]  [<ffffffff816107af>] ? kfree_skbmem+0x3f/0xa0
>>> [ 6558.812214]  [<ffffffff8161c5ba>] ? __skb_get_hash+0x2a/0x160
>>> [ 6558.812214]  [<ffffffffa01d609e>] ovs_dp_upcall+0x2e/0x70 [openvswitch]
>>> [ 6558.812214]  [<ffffffffa01d6193>] ovs_dp_process_packet+0xb3/0xd0 [openvswitch]
>>> [ 6558.812214]  [<ffffffffa01dc860>] ovs_vport_receive+0x60/0x80 [openvswitch]
>>> [ 6558.812214]  [<ffffffff811828f1>] ? zone_statistics+0x81/0xa0
>>> [ 6558.812214]  [<ffffffff81617819>] ? skb_gro_receive+0x559/0x5f0
>>> [ 6558.812214]  [<ffffffff81695ada>] ? inet_gro_receive+0x1da/0x210
>>> [ 6558.812214]  [<ffffffffa01dd10a>] netdev_frame_hook+0xca/0x130 [openvswitch]
>>> [ 6558.812214]  [<ffffffff816233aa>] __netif_receive_skb_core+0x1ba/0x7a0
>>> [ 6558.812214]  [<ffffffff816239a8>] __netif_receive_skb+0x18/0x60
>>> [ 6558.812214]  [<ffffffff81623a13>] netif_receive_skb_internal+0x23/0x90
>>> [ 6558.812214]  [<ffffffff8168cefa>] ? udp4_gro_complete+0x6a/0x70
>>> [ 6558.812214]  [<ffffffff81623b94>] napi_gro_complete+0xa4/0xe0
>>> [ 6558.812214]  [<ffffffff81623c3d>] napi_gro_flush+0x6d/0x90
>>> [ 6558.812214]  [<ffffffff81623c7e>] napi_complete+0x1e/0x50
>>> [ 6558.812214]  [<ffffffffa0006538>] sky2_poll+0xa38/0xd80 [sky2]
>>> [ 6558.812214]  [<ffffffff81623e02>] net_rx_action+0x152/0x250
>>> [ 6558.812214]  [<ffffffff81070aa5>] __do_softirq+0xf5/0x2e0
>>> [ 6558.812214]  [<ffffffff81070cc0>] run_ksoftirqd+0x30/0x50
>>> [ 6558.812214]  [<ffffffff8108e0ff>] smpboot_thread_fn+0xff/0x1b0
>>> [ 6558.812214]  [<ffffffff8108e000>] ? SyS_setgroups+0x1a0/0x1a0
>>> [ 6558.812214]  [<ffffffff8108a5a2>] kthread+0xd2/0xf0
>>> [ 6558.812214]  [<ffffffff8108a4d0>] ? kthread_create_on_node+0x180/0x180
>>> [ 6558.812214]  [<ffffffff81729e3c>] ret_from_fork+0x7c/0xb0
>>> [ 6558.812214]  [<ffffffff8108a4d0>] ? kthread_create_on_node+0x180/0x180
>>> [ 6558.812214] Code: 8b 44 24 70 44 8b 4c 24 30 44 8b 5c 24 18 8b 54 24 08 48 8b 0c 24 0f 85 0f fd ff ff e9 06 fd ff ff 0f 1f 84 00 00 00 00 00 0f 0b <0f> 0b 0f 0b c6 44 24 3b 01 e9 28 f7 ff ff e8 76 db 10 00 0f 0b
>>> [ 6558.812214] RIP  [<ffffffff81616bc2>] skb_segment+0x9d2/0xa00
>>> [ 6558.812214]  RSP <ffff880139ed3610>
>>>
>>>         I'm not sure if this is an error on the part of the RX / GRO
>>> processing in assembling the GRO skb, or in how OVS calls skb_segment.
>>>
>>
>> I think this is related skb_segment() issue where it is not able to
>> handle this type of skb geometry. We need to fix skb-segmentation. I
>> will investigate it more.
>
> One problem that I see is that vxlan_gro_complete() doesn't add
> SKB_GSO_UDP_TUNNEL to gso_type. This causes us to attempt
> fragmentation as UDP rather than continuing down to do TCP
> segmentation. That probably screws up the skb geometry.

I sent out a patch to fix this issue. I'm pretty sure that it is the
root cause of the originally reported case but I don't have a good way
to reproduce it so it would be great if you could test it Jay.
