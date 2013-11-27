From: Fan Du <fan.du@windriver.com>
Subject: [PATCH] {vxlan,inet6} Mark vxlan_dev flags with VXLAN_F_IPV6
Date: Wed, 27 Nov 2013 16:46:31 +0800
Message-ID: <5295B167.9040205@windriver.com>
References: <CAM3m09T2tuFCMjzdJq7AVBDnPeK0kVKt51JXsE954cHO6u_u2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <amwang@redhat.com>
To: Ryan Whelan <rcwhelan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57273 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab3K0Iqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 03:46:36 -0500
In-Reply-To: <CAM3m09T2tuFCMjzdJq7AVBDnPeK0kVKt51JXsE954cHO6u_u2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B411=E6=9C=8827=E6=97=A5 05:41, Ryan Whelan wrote:
> I'm not sure if this is the right place to report this- please correc=
t
> me if I'm mistaken.
>
> When creating a vxlan interface with an IPv6 multicast group but not
> specifying an underlying device, the kernel panics when the vxlan
> interface is brought up.  This doesn't happen with an IPv4 multicast
> group.  Linux 3.12.1 x86_64
>
> `ip link add vxlan0 type vxlan id 42 group ff0e::110`
> `ip link set vxlan0 up`
>
> [  192.037669] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000080

ok, without attaching physical netdev to vxlan is not a big crime to
crash kernel safely every time. Could you please test this patch?


 From ae2121bb0e0becbec340bcf199ad0250402ea4c3 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Wed, 27 Nov 2013 16:31:49 +0800
Subject: [PATCH] {vxlan,inet6} Mark vxlan_dev flags with VXLAN_F_IPV6
  properly

Even if user don't supply the physical netdev to attach vxlan dev
to, and at the same time user want to vxlan sit top of IPv6, mark
vxlan_dev flags with VXLAN_F_IPV6 to create IPv6 based socket,
otherwise kernel spit below messages, and host totally stuck!

[   62.656266] BUG: unable to handle kernel NULL pointer dereference[  =
 62.656320] ip (3008) used greatest stack depth: 3912 bytes left
  at 0000000000000046
[   62.656423] IP: [<ffffffff816d822d>] ip6_route_output+0xbd/0xe0
[   62.656525] PGD 2c966067 PUD 2c9a2067 PMD 0
[   62.656674] Oops: 0000 [#1] SMP
[   62.656781] Modules linked in: vxlan netconsole deflate zlib_deflate=
 af_key
[   62.657083] CPU: 1 PID: 2128 Comm: whoopsie Not tainted 3.12.0+ #182
[   62.657083] Hardware name: innotek GmbH VirtualBox, BIOS VirtualBox =
12/01/2006
[   62.657083] task: ffff88002e2335d0 ti: ffff88002c94c000 task.ti: fff=
f88002c94c000
[   62.657083] RIP: 0010:[<ffffffff816d822d>]  [<ffffffff816d822d>] ip6=
_route_output+0xbd/0xe0
[   62.657083] RSP: 0000:ffff88002fd038f8  EFLAGS: 00210296
[   62.657083] RAX: 0000000000000000 RBX: ffff88002fd039e0 RCX: 0000000=
000000000
[   62.657083] RDX: ffff88002fd0eb68 RSI: ffff88002fd0d278 RDI: ffff880=
02fd0d278
[   62.657083] RBP: ffff88002fd03918 R08: 0000000002000000 R09: 0000000=
000000000
[   62.657083] R10: 00000000000001ff R11: 0000000000000000 R12: 0000000=
000000001
[   62.657083] R13: ffff88002d96b480 R14: ffffffff81c8e2c0 R15: 0000000=
000000001
[   62.657083] FS:  0000000000000000(0000) GS:ffff88002fd00000(0063) kn=
lGS:00000000f693b740
[   62.657083] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[   62.657083] CR2: 0000000000000046 CR3: 000000002c9d2000 CR4: 0000000=
0000006e0
[   62.657083] Stack:
[   62.657083]  ffff88002fd03a40 ffffffff81c8e2c0 ffff88002fd039e0 ffff=
88002d96b480
[   62.657083]  ffff88002fd03958 ffffffff816cac8b ffff880019277cc0 ffff=
8800192b5d00
[   62.657083]  ffff88002d5bc000 ffff880019277cc0 0000000000001821 0000=
000000000001
[   62.657083] Call Trace:
[   62.657083]  <IRQ>
[   62.657083]  [<ffffffff816cac8b>] ip6_dst_lookup_tail+0xdb/0xf0
[   62.657083]  [<ffffffff816caea0>] ip6_dst_lookup+0x10/0x20
[   62.657083]  [<ffffffffa0020c13>] vxlan_xmit_one+0x193/0x9c0 [vxlan]
[   62.657083]  [<ffffffff8137b3b7>] ? account+0xc7/0x1f0
[   62.657083]  [<ffffffffa0021513>] vxlan_xmit+0xd3/0x400 [vxlan]
[   62.657083]  [<ffffffff8161390d>] dev_hard_start_xmit+0x49d/0x5e0
[   62.657083]  [<ffffffff81613d29>] dev_queue_xmit+0x2d9/0x480
[   62.657083]  [<ffffffff817cb854>] ? _raw_write_unlock_bh+0x14/0x20
[   62.657083]  [<ffffffff81630565>] ? eth_header+0x35/0xe0
[   62.657083]  [<ffffffff8161bc5e>] neigh_resolve_output+0x11e/0x1e0
[   62.657083]  [<ffffffff816ce0e0>] ? ip6_fragment+0xad0/0xad0
[   62.657083]  [<ffffffff816cb465>] ip6_finish_output2+0x2f5/0x470
[   62.657083]  [<ffffffff816ce166>] ip6_finish_output+0x86/0xc0
[   62.657083]  [<ffffffff816ce218>] ip6_output+0x78/0xb0
[   62.657083]  [<ffffffff816eadd6>] mld_sendpack+0x256/0x2a0
[   62.657083]  [<ffffffff816ebd8c>] mld_ifc_timer_expire+0x17c/0x290
[   62.657083]  [<ffffffff816ebc10>] ? igmp6_timer_handler+0x80/0x80
[   62.657083]  [<ffffffff816ebc10>] ? igmp6_timer_handler+0x80/0x80
[   62.657083]  [<ffffffff81051065>] call_timer_fn+0x45/0x150
[   62.657083]  [<ffffffff816ebc10>] ? igmp6_timer_handler+0x80/0x80
[   62.657083]  [<ffffffff81052353>] run_timer_softirq+0x1f3/0x2a0
[   62.657083]  [<ffffffff8102dfd8>] ? lapic_next_event+0x18/0x20
[   62.657083]  [<ffffffff8109e36f>] ? clockevents_program_event+0x6f/0=
x110
[   62.657083]  [<ffffffff8104a2f6>] __do_softirq+0xd6/0x2b0
[   62.657083]  [<ffffffff8104a75e>] irq_exit+0x7e/0xa0
[   62.657083]  [<ffffffff8102ea15>] smp_apic_timer_interrupt+0x45/0x60
[   62.657083]  [<ffffffff817d3eca>] apic_timer_interrupt+0x6a/0x70
[   62.657083]  <EOI>
[   62.657083]  [<ffffffff817d4a35>] ? sysenter_dispatch+0x7/0x1a
[   62.657083] Code: 4d 8b 85 a8 02 00 00 4c 89 e9 ba 03 04 00 00 48 c7=
 c6 c0 be 8d 81 48 c7 c7 48 35 a3 81 31 c0 e8 db 68 0e 00 49 8b 85 a8 0=
2 00 00 <0f> b6 40 46 c0 e8 05 0f b6 c0 c1 e0 03 41 09 c4 e9 77 ff ff f=
f
[   62.657083] RIP  [<ffffffff816d822d>] ip6_route_output+0xbd/0xe0
[   62.657083]  RSP <ffff88002fd038f8>
[   62.657083] CR2: 0000000000000046
[   62.657083] ---[ end trace ba8a9583d7cd1934 ]---
[   62.657083] Kernel panic - not syncing: Fatal exception in interrupt


Signed-off-by: Fan Du <fan.du@windriver.com>
---
  drivers/net/vxlan.c |    3 ++-
  1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 78df8f3..8e7ceb7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2432,7 +2432,8 @@ static int vxlan_newlink(struct net *net, struct =
net_device *dev,
  		/* update header length based on lower device */
  		dev->hard_header_len =3D lowerdev->hard_header_len +
  				       (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
-	}
+	} else if (use_ipv6)
+		vxlan->flags |=3D VXLAN_F_IPV6;

  	if (data[IFLA_VXLAN_TOS])
  		vxlan->tos  =3D nla_get_u8(data[IFLA_VXLAN_TOS]);
--=20
1.7.9.5



--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan fan
