From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Sat, 29 Mar 2014 11:29:18 +0300
Message-ID: <20140329082918.GA5720@zed>
References: <OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
 <CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
 <CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
 <20140325.205324.1845346581147557473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: or.gerlitz@gmail.com, dlstevens@us.ibm.com, cwang@twopensource.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:58757 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbaC2I3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 04:29:24 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so4863440eei.14
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2014 01:29:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140325.205324.1845346581147557473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Mar 25, 2014 at 08:53:24PM -0400, David Miller wrote:
> 
> It turns out we are going to partially revert that commit and
> iptunnel_pull_header() will start doing the skb_dst_drop() again.
> 
> See:
> 
> 	http://patchwork.ozlabs.org/patch/332956/
> 
> for details.
> 
> Will that fix this bug too?

I've found some more corner cases in the vxlan driver and the patch
below fixes them and my custom configuration case as well.

> Thanks.


>From 455a1b42e12695e9b6860c8a337a1497374870bd Mon Sep 17 00:00:00 2001
From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Sat, 29 Mar 2014 10:43:58 +0300
Subject: [PATCH] net: vxlan: fix crash when interface is created with no group

If the vxlan interface is created without explicit group definition,
there are corner cases which may cause kernel panic.

For instance, in the following scenario:

node A:
$ ip link add dev vxlan42  address 2c:c2:60:00:10:20 type vxlan id 42
$ ip addr add dev vxlan42 10.0.0.1/24
$ ip link set up dev vxlan42
$ arp -i vxlan42 -s 10.0.0.2 2c:c2:60:00:01:02
$ bridge fdb add dev vxlan42 to 2c:c2:60:00:01:02 dst <IPv4 address>
$ ping 10.0.0.2

node B:
$ ip link add dev vxlan42 address 2c:c2:60:00:01:02 type vxlan id 42
$ ip addr add dev vxlan42 10.0.0.2/24
$ ip link set up dev vxlan42
$ arp -i vxlan42 -s 10.0.0.1 2c:c2:60:00:10:20

node B crashes:

 vxlan42: 2c:c2:60:00:10:20 migrated from 4011:eca4:c0a8:6466:c0a8:6415:8e09:2118 to (invalid address)
 vxlan42: 2c:c2:60:00:10:20 migrated from 4011:eca4:c0a8:6466:c0a8:6415:8e09:2118 to (invalid address)
 BUG: unable to handle kernel NULL pointer dereference at 0000000000000046
 IP: [<ffffffff8143c459>] ip6_route_output+0x58/0x82
 PGD 7bd89067 PUD 7bd4e067 PMD 0
 Oops: 0000 [#1] SMP
 Modules linked in:
 CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.14.0-rc8-hvx-xen-00019-g97a5221-dirty #154
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 task: ffff88007c774f50 ti: ffff88007c79c000 task.ti: ffff88007c79c000
 RIP: 0010:[<ffffffff8143c459>]  [<ffffffff8143c459>] ip6_route_output+0x58/0x82
 RSP: 0018:ffff88007fd03668  EFLAGS: 00010282
 RAX: 0000000000000000 RBX: ffffffff8186a000 RCX: 0000000000000040
 RDX: 0000000000000000 RSI: ffff88007b0e4a80 RDI: ffff88007fd03754
 RBP: ffff88007fd03688 R08: ffff88007b0e4a80 R09: 0000000000000000
 R10: 0200000a0100000a R11: 0001002200000000 R12: ffff88007fd03740
 R13: ffff88007b0e4a80 R14: ffff88007b0e4a80 R15: ffff88007bba0c50
 FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: 0000000000000046 CR3: 000000007bb60000 CR4: 00000000000006e0
 Stack:
  0000000000000000 ffff88007fd037a0 ffffffff8186a000 ffff88007fd03740
  ffff88007fd036c8 ffffffff814320bb 0000000000006e49 ffff88007b8b7360
  ffff88007bdbf200 ffff88007bcbc000 ffff88007b8b7000 ffff88007b8b7360
 Call Trace:
  <IRQ>
  [<ffffffff814320bb>] ip6_dst_lookup_tail+0x2d/0xa4
  [<ffffffff814322a5>] ip6_dst_lookup+0x10/0x12
  [<ffffffff81323b4e>] vxlan_xmit_one+0x32a/0x68c
  [<ffffffff814a325a>] ? _raw_spin_unlock_irqrestore+0x12/0x14
  [<ffffffff8104c551>] ? lock_timer_base.isra.23+0x26/0x4b
  [<ffffffff8132451a>] vxlan_xmit+0x66a/0x6a8
  [<ffffffff8141a365>] ? ipt_do_table+0x35f/0x37e
  [<ffffffff81204ba2>] ? selinux_ip_postroute+0x41/0x26e
  [<ffffffff8139d0c1>] dev_hard_start_xmit+0x2ce/0x3ce
  [<ffffffff8139d491>] __dev_queue_xmit+0x2d0/0x392
  [<ffffffff813b380f>] ? eth_header+0x28/0xb5
  [<ffffffff8139d569>] dev_queue_xmit+0xb/0xd
  [<ffffffff813a5aa6>] neigh_resolve_output+0x134/0x152
  [<ffffffff813db741>] ip_finish_output2+0x236/0x299
  [<ffffffff813dc074>] ip_finish_output+0x98/0x9d
  [<ffffffff813dc749>] ip_output+0x62/0x67
  [<ffffffff813da9f2>] dst_output+0xf/0x11
  [<ffffffff813dc11c>] ip_local_out+0x1b/0x1f
  [<ffffffff813dcf1b>] ip_send_skb+0x11/0x37
  [<ffffffff813dcf70>] ip_push_pending_frames+0x2f/0x33
  [<ffffffff813ff732>] icmp_push_reply+0x106/0x115
  [<ffffffff813ff9e4>] icmp_reply+0x142/0x164
  [<ffffffff813ffb3b>] icmp_echo.part.16+0x46/0x48
  [<ffffffff813c1d30>] ? nf_iterate+0x43/0x80
  [<ffffffff813d8037>] ? xfrm4_policy_check.constprop.11+0x52/0x52
  [<ffffffff813ffb62>] icmp_echo+0x25/0x27
  [<ffffffff814005f7>] icmp_rcv+0x1d2/0x20a
  [<ffffffff813d8037>] ? xfrm4_policy_check.constprop.11+0x52/0x52
  [<ffffffff813d810d>] ip_local_deliver_finish+0xd6/0x14f
  [<ffffffff813d8037>] ? xfrm4_policy_check.constprop.11+0x52/0x52
  [<ffffffff813d7fde>] NF_HOOK.constprop.10+0x4c/0x53
  [<ffffffff813d82bf>] ip_local_deliver+0x4a/0x4f
  [<ffffffff813d7f7b>] ip_rcv_finish+0x253/0x26a
  [<ffffffff813d7d28>] ? inet_add_protocol+0x3e/0x3e
  [<ffffffff813d7fde>] NF_HOOK.constprop.10+0x4c/0x53
  [<ffffffff813d856a>] ip_rcv+0x2a6/0x2ec
  [<ffffffff8139a9a0>] __netif_receive_skb_core+0x43e/0x478
  [<ffffffff812a346f>] ? virtqueue_poll+0x16/0x27
  [<ffffffff8139aa2f>] __netif_receive_skb+0x55/0x5a
  [<ffffffff8139aaaa>] process_backlog+0x76/0x12f
  [<ffffffff8139add8>] net_rx_action+0xa2/0x1ab
  [<ffffffff81047847>] __do_softirq+0xca/0x1d1
  [<ffffffff81047ace>] irq_exit+0x3e/0x85
  [<ffffffff8100b98b>] do_IRQ+0xa9/0xc4
  [<ffffffff814a37ad>] common_interrupt+0x6d/0x6d
  <EOI>
  [<ffffffff810378db>] ? native_safe_halt+0x6/0x8
  [<ffffffff810110c7>] default_idle+0x9/0xd
  [<ffffffff81011694>] arch_cpu_idle+0x13/0x1c
  [<ffffffff8107480d>] cpu_startup_entry+0xbc/0x137
  [<ffffffff8102e741>] start_secondary+0x1a0/0x1a5
 Code: 24 14 e8 f1 e5 01 00 31 d2 a8 32 0f 95 c2 49 8b 44 24 2c 49 0b 44 24 24 74 05 83 ca 04 eb 1c 4d 85 ed 74 17 49 8b 85 a8 02 00 00 <66> 8b 40 46 66 c1 e8 07 83 e0 07 c1 e0 03 09 c2 4c 89 e6 48 89
 RIP  [<ffffffff8143c459>] ip6_route_output+0x58/0x82
  RSP <ffff88007fd03668>
 CR2: 0000000000000046
 ---[ end trace 4612329caab37efd ]---

When vxlan interface is created without explicit group definition, the
default_dst protocol family is initialiazed to AF_UNSPEC and the driver
assumes IPv4 configuration. On the other side, the default_dst protocol
family is used to differentiate between IPv4 and IPv6 cases and, since,
AF_UNSPEC != AF_INET, the processing takes the IPv6 path.

Making the IPv4 assumption explicit by settting default_dst protocol
family to AF_INET4 and preventing mixing of IPv4 and IPv6 addresses in
snooped fdb entries fixes the corner case crashes.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1236812..d091e52 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -871,6 +871,9 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (err)
 		return err;
 
+	if (vxlan->default_dst.remote_ip.sa.sa_family != ip.sa.sa_family)
+		return -EAFNOSUPPORT;
+
 	spin_lock_bh(&vxlan->hash_lock);
 	err = vxlan_fdb_create(vxlan, addr, &ip, ndm->ndm_state, flags,
 			       port, vni, ifindex, ndm->ndm_flags);
@@ -2612,9 +2615,10 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
 	dst->remote_vni = vni;
 
+	/* Unless IPv6 is explicitly requested, assume IPv4 */
+	dst->remote_ip.sa.sa_family = AF_INET;
 	if (data[IFLA_VXLAN_GROUP]) {
 		dst->remote_ip.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
-		dst->remote_ip.sa.sa_family = AF_INET;
 	} else if (data[IFLA_VXLAN_GROUP6]) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
-- 
1.8.1.5
