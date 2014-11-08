From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] udptunnel: Add SKB_GSO_UDP_TUNNEL during gro_complete.
Date: Fri, 07 Nov 2014 17:51:31 -0800
Message-ID: <28743.1415411491@famine>
References: <1415391969-108511-1-git-send-email-jesse@nicira.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37615 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbaKHBvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 20:51:38 -0500
In-reply-to: <1415391969-108511-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse@nicira.com> wrote:

>When doing GRO processing for UDP tunnels, we never add
>SKB_GSO_UDP_TUNNEL to gso_type - only the type of the inner protocol
>is added (such as SKB_GSO_TCPV4). The result is that if the packet is
>later resegmented we will do GSO but not treat it as a tunnel. This
>results in UDP fragmentation and since that is not the original layout
>of the skb, a panic in skb_segment().
>
>Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>Signed-off-by: Jesse Gross <jesse@nicira.com>
>---
>This problem occurs back to 3.14 for VXLAN but the FOU portion needs to
>be removed for kernels other than the 'net' tree.

	This patch does not resolve the problem when applied to a
3.17-ish kernel; the panic message is below, and appears to be
unchanged.

	-J

[  146.960891] kernel BUG at net/core/skbuff.c:3011!
[  146.960891] invalid opcode: 0000 [#1] SMP
[  146.960891] Modules linked in: veth 8021q garp mrp bonding xt_tcpudp bridge s
tp llc iptable_filter ip_tables x_tables openvswitch vxlan udp_tunnel gre libcrc
32c i915 video drm_kms_helper coretemp kvm_intel drm kvm gpio_ich serio_raw i2c_
algo_bit ppdev lpc_ich parport_pc lp parport mac_hid hid_generic usbhid hid psmo
use r8169 mii sky2
[  146.960891] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.17.0-rc7 #11
[  146.960891] Hardware name: LENOVO 0829F3U/To be filled by O.E.M., BIOS 90KT15
AUS 07/21/2010
[  146.960891] task: ffffffff81c1d480 ti: ffffffff81c00000 task.ti: ffffffff81c0
0000
[  146.960891] RIP: 0010:[<ffffffff816117d2>]  [<ffffffff816117d2>] skb_segment+
0x962/0x990
[  146.960891] RSP: 0018:ffff88013fc03908  EFLAGS: 00010216
[  146.960891] RAX: 00000000000002dc RBX: ffff8800a62f0a00 RCX: ffff88003215e4f0
[  146.960891] RDX: 0000000000000074 RSI: ffff88003215e400 RDI: ffff88003215f800
[  146.960891] RBP: ffff88013fc039d0 R08: 0000000000000022 R09: 0000000000000000
[  146.960891] R10: ffff8800a62f0b00 R11: 00000000000005ca R12: ffff88003215f8f0
[  146.960891] R13: 0000000000000000 R14: ffff8800320e4100 R15: 0000000000000074
[  146.960891] FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) knlGS:00000
00000000000
[  146.960891] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  146.960891] CR2: 000000000218c818 CR3: 00000000b1e4e000 CR4: 00000000000407f0
[  146.960891] Stack:
[  146.960891]  ffff8800320e4c00 ffffffffffffffde ffff8800000005ca 0000000000000
022
[  146.960891]  0000000000000040 ffff8800a62f0b00 00000001000005a8 0000000000000
000
[  146.960891]  0000000000000022 00000000000005a8 ffff8800a62f0a00 ffff88003215e
4f0
[  146.960891] Call Trace:
[  146.960891]  <IRQ>
[  146.960891]  [<ffffffff81686612>] udp4_ufo_fragment+0xc2/0x130
[  146.960891]  [<ffffffff8168f372>] inet_gso_segment+0x132/0x360
[  146.960891]  [<ffffffff8161fbe6>] ? dev_hard_start_xmit+0x316/0x5c0
[  146.960891]  [<ffffffff8161f5cb>] skb_mac_gso_segment+0x9b/0x170
[  146.960891]  [<ffffffff8161f700>] __skb_gso_segment+0x60/0xc0
[  147.148004]  [<ffffffffa01a7231>] queue_gso_packets+0x41/0x1b0 [openvswitch]
[  147.148004]  [<ffffffff81616ab3>] ? skb_flow_dissect+0x173/0x430
[  147.148004]  [<ffffffff81616d90>] ? __skb_get_hash+0x20/0x140
[  147.148004]  [<ffffffffa01a7c6e>] ovs_dp_upcall+0x2e/0x70 [openvswitch]      [  147.148004]  [<ffffffffa01a7d9e>] ovs_dp_process_received_packet+0xee/0x110 [
openvswitch]
[  147.148004]  [<ffffffffa01adaea>] ovs_vport_receive+0x2a/0x30 [openvswitch]
[  147.148004]  [<ffffffffa01ae381>] netdev_frame_hook+0xc1/0x120 [openvswitch]
[  147.148004]  [<ffffffff8161daf2>] __netif_receive_skb_core+0x1b2/0x790
[  147.148004]  [<ffffffff8161e0e8>] __netif_receive_skb+0x18/0x60
[  147.148004]  [<ffffffff8161e153>] netif_receive_skb_internal+0x23/0x90
[  147.148004]  [<ffffffff81685e5b>] ? udp_gro_complete+0x5b/0x70
[  147.148004]  [<ffffffff8161e2d4>] napi_gro_complete+0xa4/0xe0
[  147.148004]  [<ffffffff8161e82f>] dev_gro_receive+0x1ef/0x2f0
[  147.148004]  [<ffffffff8161ec1c>] napi_gro_receive+0x2c/0xf0
[  147.148004]  [<ffffffffa001f28f>] sky2_poll+0x78f/0xd70 [sky2]
[  147.148004]  [<ffffffff8161e542>] net_rx_action+0x152/0x250
[  147.148004]  [<ffffffff81070925>] __do_softirq+0xf5/0x2e0
[  147.148004]  [<ffffffff81070de5>] irq_exit+0x105/0x110
[  147.148004]  [<ffffffff81724a78>] do_IRQ+0x58/0xf0
[  147.148004]  [<ffffffff817228ed>] common_interrupt+0x6d/0x6d
[  147.148004]  <EOI>
[  147.148004]  [<ffffffff810c9578>] ? rcu_nocb_kthread+0x158/0x510
[  147.148004]  [<ffffffff81055056>] ? native_safe_halt+0x6/0x10
[  147.148004]  [<ffffffff8101d1af>] default_idle+0x1f/0xc0
[  147.148004]  [<ffffffff8101db1f>] arch_cpu_idle+0xf/0x20
[  147.148004]  [<ffffffff810aadcd>] cpu_startup_entry+0x30d/0x340
[  147.148004]  [<ffffffff8170b307>] rest_init+0x77/0x80
[  147.148004]  [<ffffffff81d37084>] start_kernel+0x42f/0x43a
[  147.148004]  [<ffffffff81d36a4e>] ? set_init_arg+0x53/0x53
[  147.148004]  [<ffffffff81d36120>] ? early_idt_handlers+0x120/0x120
[  147.148004]  [<ffffffff81d365ee>] x86_64_start_reservations+0x2a/0x2c
[  147.148004]  [<ffffffff81d36733>] x86_64_start_kernel+0x143/0x152
[  147.148004] Code: 24 70 4c 8b 54 24 58 44 8b 44 24 68 44 8b 4c 24 28 48 8b 4c
 24 10 44 8b 5c 24 04 8b 14 24 0f 85 19 fd ff ff e9 10 fd ff ff 0f 0b <0f> 0b 0f
 0b c6 44 24 33 01 e9 92 f7 ff ff e8 33 ad 10 00 0f 0b
[  147.148004] RIP  [<ffffffff816117d2>] skb_segment+0x962/0x990
[  147.148004]  RSP <ffff88013fc03908>


> drivers/net/vxlan.c      | 2 ++
> include/net/udp_tunnel.h | 9 +++++++++
> net/ipv4/fou.c           | 2 ++
> 3 files changed, 13 insertions(+)
>
>diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>index ca30982..cfb892b 100644
>--- a/drivers/net/vxlan.c
>+++ b/drivers/net/vxlan.c
>@@ -621,6 +621,8 @@ static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
> 	int vxlan_len  = sizeof(struct vxlanhdr) + sizeof(struct ethhdr);
> 	int err = -ENOSYS;
> 
>+	udp_tunnel_gro_complete(skb, nhoff);
>+
> 	eh = (struct ethhdr *)(skb->data + nhoff + sizeof(struct vxlanhdr));
> 	type = eh->h_proto;
> 
>diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
>index a47790b..2a50a70 100644
>--- a/include/net/udp_tunnel.h
>+++ b/include/net/udp_tunnel.h
>@@ -100,6 +100,15 @@ static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
> 	return iptunnel_handle_offloads(skb, udp_csum, type);
> }
> 
>+static inline void udp_tunnel_gro_complete(struct sk_buff *skb, int nhoff)
>+{
>+	struct udphdr *uh;
>+
>+	uh = (struct udphdr *)(skb->data + nhoff - sizeof(struct udphdr));
>+	skb_shinfo(skb)->gso_type |= uh->check ?
>+				SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
>+}
>+
> static inline void udp_tunnel_encap_enable(struct socket *sock)
> {
> #if IS_ENABLED(CONFIG_IPV6)
>diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
>index 32e7892..606c520 100644
>--- a/net/ipv4/fou.c
>+++ b/net/ipv4/fou.c
>@@ -133,6 +133,8 @@ static int fou_gro_complete(struct sk_buff *skb, int nhoff)
> 	int err = -ENOSYS;
> 	const struct net_offload **offloads;
> 
>+	udp_tunnel_gro_complete(skb, nhoff);
>+
> 	rcu_read_lock();
> 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
> 	ops = rcu_dereference(offloads[proto]);
>-- 
>1.9.1

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
