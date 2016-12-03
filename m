From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/18] i40e: fix panic on SPARC while changing num of desc
Date: Sat,  3 Dec 2016 01:19:21 -0800
Message-ID: <20161203091930.14268-10-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6457 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751892AbcLCJUr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:47 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>

On SPARC, writel() should not be used to write directly to memory
address but only to memory mapped I/O address otherwise it causes
data access exception.

Commit 147e81ec75689 ("i40e: Test memory before ethtool alloc
succeeds") introduced a code that uses memory address to fake the HW
tail address and attempt to write to that address using writel()
causes kernel panic on SPARC. The issue is reproduced while changing
number of descriptors using ethtool.

This change resolves the panic by using HW read-only memory mapped
I/O register to fake HW tail address instead memory address.

e.g.
> ethtool -G eth2 tx 2048 rx 2048
i40e 0000:03:00.2 eth2: Changing Tx descriptor count from 512 to 2048.
i40e 0000:03:00.2 eth2: Changing Rx descriptor count from 512 to 2048
sun4v_data_access_exception: ADDR[fff8001f9734a000] CTX[0000]
TYPE[0004], going.
              \|/ ____ \|/
              "@'/ .. \`@"
              /_| \__/ |_\
                 \__U_/
ethtool(3273): Dax [#1]
CPU: 9 PID: 3273 Comm: ethtool Tainted: G            E
4.8.0-linux-net_temp+ #7
task: fff8001f96d7a660 task.stack: fff8001f97348000
TSTATE: 0000009911001601 TPC: 00000000103189e4 TNPC: 00000000103189e8 Y:
00000000    Tainted: G            E
TPC: <i40e_alloc_rx_buffers+0x124/0x260 [i40e]>
g0: fff8001f4eb64000 g1: 00000000000007ff g2: fff8001f9734b92c g3:
00203e0000000000
g4: fff8001f96d7a660 g5: fff8001fa6704000 g6: fff8001f97348000 g7:
0000000000000001
o0: 0006000046706928 o1: 00000000db3e2000 o2: fff8001f00000000 o3:
0000000000002000
o4: 0000000000002000 o5: 0000000000000001 sp: fff8001f9734afc1 ret_pc:
0000000010318a64
RPC: <i40e_alloc_rx_buffers+0x1a4/0x260 [i40e]>
l0: fff8001f4e8bffe0 l1: fff8001f4e8cffe0 l2: 00000000000007ff l3:
00000000ff000000
l4: 0000000000ff0000 l5: 000000000000ff00 l6: 0000000000cda6a8 l7:
0000000000e822f0
i0: fff8001f96380000 i1: 0000000000000000 i2: 00203edb00000000 i3:
0006000046706928
i4: 0000000002086320 i5: 0000000000e82370 i6: fff8001f9734b071 i7:
00000000103062d4
I7: <i40e_set_ringparam+0x3b4/0x540 [i40e]>
Call Trace:
 [00000000103062d4] i40e_set_ringparam+0x3b4/0x540 [i40e]
 [000000000094e2f8] dev_ethtool+0x898/0xbe0
 [0000000000965570] dev_ioctl+0x250/0x300
 [0000000000923800] sock_do_ioctl+0x40/0x60
 [000000000092427c] sock_ioctl+0x7c/0x280
 [00000000005ef040] vfs_ioctl+0x20/0x60
 [00000000005ef5d4] do_vfs_ioctl+0x194/0x4c0
 [00000000005ef974] SyS_ioctl+0x74/0xa0
 [0000000000406214] linux_sparc_syscall+0x34/0x44
Disabling lock debugging due to kernel taint
Caller[00000000103062d4]: i40e_set_ringparam+0x3b4/0x540 [i40e]
Caller[000000000094e2f8]: dev_ethtool+0x898/0xbe0
Caller[0000000000965570]: dev_ioctl+0x250/0x300
Caller[0000000000923800]: sock_do_ioctl+0x40/0x60
Caller[000000000092427c]: sock_ioctl+0x7c/0x280
Caller[00000000005ef040]: vfs_ioctl+0x20/0x60
Caller[00000000005ef5d4]: do_vfs_ioctl+0x194/0x4c0
Caller[00000000005ef974]: SyS_ioctl+0x74/0xa0
Caller[0000000000406214]: linux_sparc_syscall+0x34/0x44
Caller[0000000000107154]: 0x107154
Instruction DUMP: e43620c8
 e436204a  c45e2038
<c2a083a0> 82102000
 81cfe008  90086001
 82102000  81cfe008

Kernel panic - not syncing: Fatal exception

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index f99c135..92a2f03 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1217,6 +1217,7 @@ static int i40e_set_ringparam(struct net_device *netdev,
 {
 	struct i40e_ring *tx_rings = NULL, *rx_rings = NULL;
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_hw *hw = &np->vsi->back->hw;
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	u32 new_rx_count, new_tx_count;
@@ -1309,10 +1310,6 @@ static int i40e_set_ringparam(struct net_device *netdev,
 		}
 
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
-			/* this is to allow wr32 to have something to write to
-			 * during early allocation of Rx buffers
-			 */
-			u32 __iomem faketail = 0;
 			struct i40e_ring *ring;
 			u16 unused;
 
@@ -1324,7 +1321,10 @@ static int i40e_set_ringparam(struct net_device *netdev,
 			 */
 			rx_rings[i].desc = NULL;
 			rx_rings[i].rx_bi = NULL;
-			rx_rings[i].tail = (u8 __iomem *)&faketail;
+			/* this is to allow wr32 to have something to write to
+			 * during early allocation of Rx buffers
+			 */
+			rx_rings[i].tail = hw->hw_addr + I40E_PRTGEN_STATUS;
 			err = i40e_setup_rx_descriptors(&rx_rings[i]);
 			if (err)
 				goto rx_unwind;
-- 
2.9.3
