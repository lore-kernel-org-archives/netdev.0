From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 0/3] net: Add GRO support for UDP encapsulating protocols
Date: Wed,  8 Jan 2014 22:34:35 +0200
Message-ID: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43102 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757000AbaAHUep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 15:34:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds GRO handlers for protocols that do UDP encapsulation, with the
intent of being able to coalesce packets which encapsulate packets belonging to
the same TCP session.

For GRO purposes, the destination UDP port takes the role of the ether type
field in the ethernet header or the next protocol in the IP header.

The UDP GRO handler will only attempt to coalesce packets whose destination
port is registered to have gro handler.

On my setup, which is net-next (now with the mlx4 vxlan offloads patches) --
for single TCP session that goes through vxlan tunneling I got nice improvement
from 6.8Gbs to 11.5Gbs

patches done against net-next 80077935cad "Merge branch 'master' of
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next"

v2 --> v3 changes:

 - moved to use linked list to store the udp gro handlers, this solves the
   problem of consuming 512KB of memory for the handlers.

 - use a mark on the skb GRO CB data to disallow running the udp gro_receive twice
   on a packet, this solves the problem of udp encapsulated packets whose inner VM
   packet is udp and happen to carry a port which has registered offloads - and flush it.

 - invoke the udp offload protocol registration and de-registration from the vxlan driver
   in a sleepable context 

For unclear some reason I got this warning when the vxlan driver deletes the
udp offload structure 

-----------[ cut here ]------------
WARNING: CPU: 2 PID: 19 at kernel/rcu/tree.c:2127 rcu_do_batch+0x359/0x370()
Modules linked in: veth vxlan ip_tunnel bridge stp llc rdma_ucm rdma_cm ib_cm iw_cm ib_addr ib_uverbs ib_umad mlx4_en ptp pps_core mlx4_ib ib_sa ib_mad ib_core mlx4_core nfsv3 nfs_acl auth_rpcgss oid_registry nfsv4 nfs lockd autofs4 sunrpc ipv6 dm_mirror dm_region_hash dm_log dm_mod joydev microcode pcspkr virtio_balloon virtio_net i2c_piix4 button ext3 jbd virtio_pci virtio_ring virtio uhci_hcd [last unloaded: ib_core]
CPU: 2 PID: 19 Comm: rcuc/2 Not tainted 3.13.0-rc6+ #278
Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
 000000000000084f ffff88021651dd68 ffffffff81498b52 000000000000084f
 0000000000000000 ffff88021651dda8 ffffffff81059f2c ffff88021651dd98
 ffff88022010d6a0 ffff88022010d6c8 0000000000000246 ffffffff81844200
Call Trace:
 [<ffffffff81498b52>] dump_stack+0x51/0x77
 [<ffffffff81059f2c>] warn_slowpath_common+0x8c/0xc0
 [<ffffffff81059f7a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff810a49c9>] rcu_do_batch+0x359/0x370
 [<ffffffff810a4ade>] rcu_cpu_kthread+0xfe/0x2b0
 [<ffffffff81083697>] smpboot_thread_fn+0x167/0x260
 [<ffffffff81083530>] ? smpboot_create_threads+0x80/0x80
 [<ffffffff8107c36e>] kthread+0xce/0xf0
 [<ffffffff8107c2a0>] ? kthread_freezable_should_stop+0x70/0x70
 [<ffffffff8149de7c>] ret_from_fork+0x7c/0xb0
 [<ffffffff8107c2a0>] ? kthread_freezable_should_stop+0x70/0x70
---[ end trace f98588ea45ef3f4c ]---

Or


Or Gerlitz (3):
  net: Add GRO support for UDP encapsulating protocols
  net: Export gro_find_by_type helpers
  net: Add GRO support for vxlan traffic

 drivers/net/vxlan.c       |  129 ++++++++++++++++++++++++++++++++++++++++++---
 include/linux/netdevice.h |   10 +++-
 include/net/protocol.h    |    3 +
 include/net/vxlan.h       |    1 +
 net/core/dev.c            |    3 +
 net/ipv4/udp_offload.c    |  129 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 267 insertions(+), 8 deletions(-)
