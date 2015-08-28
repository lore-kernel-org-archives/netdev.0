From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [RFC PATCH kernel] Revert "net/mlx4_core: Add port attribute when tracking counters"
Date: Sat, 29 Aug 2015 00:06:16 +1000
Message-ID: <1440770776-27951-1-git-send-email-aik@ozlabs.ru>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
	Richard Yang <weiyang@linux.vnet.ibm.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>
To: Eran Ben Elisha <eranbe@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:55452 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbbH1OHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 10:07:23 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <aik@ozlabs.ru>;
	Sat, 29 Aug 2015 00:07:21 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 910A22CE8057
	for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 00:07:16 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7SE79oU45220040
	for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 00:07:17 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7SE6gPY006738
	for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 00:06:44 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

68230242cdb breaks SRIOV on POWER8 system. I am not really suggesting
reverting the patch, rather asking for a fix.

To reproduce it:

1. boot latest upstream kernel (v4.2-rc8 sha1 4941b8f, ppc64le)

2. Run:
sudo rmmod mlx4_en mlx4_ib mlx4_core
sudo modprobe mlx4_core num_vfs=4 probe_vf=4 port_type_array=2,2 debug_level=1

3. Run QEMU (just to give a complete picture):
/home/aik/qemu-system-ppc64 -enable-kvm -m 2048 -machine pseries \
-nodefaults \
-chardev stdio,id=id0,signal=off,mux=on \
-device spapr-vty,id=id1,chardev=id0,reg=0x71000100 \
-mon id=id2,chardev=id0,mode=readline -nographic -vga none \
-initrd dhclient.cpio -kernel vml400bedbg \
-device vfio-pci,id=id3,host=0003:03:00.1
What guest is used does not matter at all.

4. Wait till guest boots and then run:
dhclient
This assigns IPs to both interfaces just fine. This is essential -
if interface was not brought up since guest started, the bug does not appear.
If interface was up and then down, this still causes the problem
(less likely though).

5. Run in the guest: shutdown -h 0
Guest prints:
mlx4_en: eth0: Close port called
mlx4_en: eth1: Close port called
mlx4_core 0000:00:00.0: mlx4_shutdown was called
And then the host hangs. After 10-30 seconds the host console prints:
NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [qemu-system-ppc:5095]
OR
INFO: rcu_sched detected stalls on CPUs/tasks:
or some other random stuff but always related to some sort of lockup.
Backtraces are like these:

[c000001e492a7ac0] [c000000000135b84] smp_call_function_many+0x2f4/0x3fable)
[c000001e492a7b40] [c000000000135db8] kick_all_cpus_sync+0x38/0x50
[c000001e492a7b60] [c000000000048f38] pmdp_huge_get_and_clear+0x48/0x70
[c000001e492a7b90] [c00000000023181c] change_huge_pmd+0xac/0x210
[c000001e492a7bf0] [c0000000001fb9e8] change_protection+0x678/0x720
[c000001e492a7d00] [c000000000217d38] change_prot_numa+0x28/0xa0
[c000001e492a7d30] [c0000000000e0e40] task_numa_work+0x2a0/0x370
[c000001e492a7db0] [c0000000000c5fb4] task_work_run+0xe4/0x160
[c000001e492a7e00] [c0000000000169a4] do_notify_resume+0x84/0x90
[c000001e492a7e30] [c0000000000098b8] ret_from_except_lite+0x64/0x68

OR

[c000001def1b7280] [c000000ff941d368] 0xc000000ff941d368 (unreliable)
[c000001def1b7450] [c00000000001512c] __switch_to+0x1fc/0x350
[c000001def1b7490] [c000001def1b74e0] 0xc000001def1b74e0
[c000001def1b74e0] [c00000000011a50c] try_to_del_timer_sync+0x5c/0x90
[c000001def1b7520] [c00000000011a590] del_timer_sync+0x50/0x70
[c000001def1b7550] [c0000000009136fc] schedule_timeout+0x15c/0x2b0
[c000001def1b7620] [c000000000910e6c] wait_for_common+0x12c/0x230
[c000001def1b7660] [c0000000000fa22c] up+0x4c/0x80
[c000001def1b76a0] [d000000016323e60] __mlx4_cmd+0x320/0x940 [mlx4_core]
[c000001def1b7760] [c000001def1b77a0] 0xc000001def1b77a0
[c000001def1b77f0] [d0000000163528b4] mlx4_2RST_QP_wrapper+0x154/0x1e0 [mlx4_core]
[c000001def1b7860] [d000000016324934] mlx4_master_process_vhcr+0x1b4/0x6c0 [mlx4_core]
[c000001def1b7930] [d000000016324170] __mlx4_cmd+0x630/0x940 [mlx4_core]
[c000001def1b79f0] [d000000016346fec] __mlx4_qp_modify.constprop.8+0x1ec/0x350 [mlx4_core]
[c000001def1b7ac0] [d000000016292228] mlx4_ib_destroy_qp+0xd8/0x5d0 [mlx4_ib]
[c000001def1b7b60] [d000000013c7305c] ib_destroy_qp+0x1cc/0x290 [ib_core]
[c000001def1b7bb0] [d000000016284548] destroy_pv_resources.isra.14.part.15+0x48/0xf0 [mlx4_ib]
[c000001def1b7be0] [d000000016284d28] mlx4_ib_tunnels_update+0x168/0x170 [mlx4_ib]
[c000001def1b7c20] [d0000000162876e0] mlx4_ib_tunnels_update_work+0x30/0x50 [mlx4_ib]
[c000001def1b7c50] [c0000000000c0d34] process_one_work+0x194/0x490
[c000001def1b7ce0] [c0000000000c11b0] worker_thread+0x180/0x5a0
[c000001def1b7d80] [c0000000000c8a0c] kthread+0x10c/0x130
[c000001def1b7e30] [c0000000000095a8] ret_from_kernel_thread+0x5c/0xb4

i.e. may or may not mention mlx4.
The issue may not happen on a first try but maximum on the second.


This is the function I am passing to the guest:
0003:03:00.1 Ethernet controller: Mellanox Technologies MT27500/MT27520 Family [ConnectX-3/ConnectX-3 Pro Virtual Function]
        Subsystem: IBM Device 61b0
        Flags: bus master, fast devsel, latency 0
        [virtual] Memory at 3c1080000000 (64-bit, prefetchable) [size=128M]
        Capabilities: <access denied>
        Kernel driver in use: mlx4_core

And ideas? Some patches to try? Thanks!



---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 90 +---------------------
 1 file changed, 3 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 73db584..802eb2a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -723,9 +723,6 @@ static void update_gid(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *inbox,
 	}
 }
 
-static int handle_counter(struct mlx4_dev *dev, struct mlx4_qp_context *qpc,
-			  u8 slave, int port);
-
 static int update_vport_qp_param(struct mlx4_dev *dev,
 				 struct mlx4_cmd_mailbox *inbox,
 				 u8 slave, u32 qpn)
@@ -741,10 +738,6 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 	qp_type	= (be32_to_cpu(qpc->flags) >> 16) & 0xff;
 
-	err = handle_counter(dev, qpc, slave, port);
-	if (err)
-		goto out;
-
 	if (MLX4_VGT != vp_oper->state.default_vlan) {
 		/* the reserved QPs (special, proxy, tunnel)
 		 * do not operate over vlans
@@ -889,83 +882,6 @@ static void put_res(struct mlx4_dev *dev, int slave, u64 res_id,
 	spin_unlock_irq(mlx4_tlock(dev));
 }
 
-static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			     u64 in_param, u64 *out_param, int port);
-
-static int handle_existing_counter(struct mlx4_dev *dev, u8 slave, int port,
-				   int counter_index)
-{
-	struct res_common *r;
-	struct res_counter *counter;
-	int ret = 0;
-
-	if (counter_index == MLX4_SINK_COUNTER_INDEX(dev))
-		return ret;
-
-	spin_lock_irq(mlx4_tlock(dev));
-	r = find_res(dev, counter_index, RES_COUNTER);
-	if (!r || r->owner != slave)
-		ret = -EINVAL;
-	counter = container_of(r, struct res_counter, com);
-	if (!counter->port)
-		counter->port = port;
-
-	spin_unlock_irq(mlx4_tlock(dev));
-	return ret;
-}
-
-static int handle_unexisting_counter(struct mlx4_dev *dev,
-				     struct mlx4_qp_context *qpc, u8 slave,
-				     int port)
-{
-	struct mlx4_priv *priv = mlx4_priv(dev);
-	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
-	struct res_common *tmp;
-	struct res_counter *counter;
-	u64 counter_idx = MLX4_SINK_COUNTER_INDEX(dev);
-	int err = 0;
-
-	spin_lock_irq(mlx4_tlock(dev));
-	list_for_each_entry(tmp,
-			    &tracker->slave_list[slave].res_list[RES_COUNTER],
-			    list) {
-		counter = container_of(tmp, struct res_counter, com);
-		if (port == counter->port) {
-			qpc->pri_path.counter_index  = counter->com.res_id;
-			spin_unlock_irq(mlx4_tlock(dev));
-			return 0;
-		}
-	}
-	spin_unlock_irq(mlx4_tlock(dev));
-
-	/* No existing counter, need to allocate a new counter */
-	err = counter_alloc_res(dev, slave, RES_OP_RESERVE, 0, 0, &counter_idx,
-				port);
-	if (err == -ENOENT) {
-		err = 0;
-	} else if (err && err != -ENOSPC) {
-		mlx4_err(dev, "%s: failed to create new counter for slave %d err %d\n",
-			 __func__, slave, err);
-	} else {
-		qpc->pri_path.counter_index = counter_idx;
-		mlx4_dbg(dev, "%s: alloc new counter for slave %d index %d\n",
-			 __func__, slave, qpc->pri_path.counter_index);
-		err = 0;
-	}
-
-	return err;
-}
-
-static int handle_counter(struct mlx4_dev *dev, struct mlx4_qp_context *qpc,
-			  u8 slave, int port)
-{
-	if (qpc->pri_path.counter_index != MLX4_SINK_COUNTER_INDEX(dev))
-		return handle_existing_counter(dev, slave, port,
-					       qpc->pri_path.counter_index);
-
-	return handle_unexisting_counter(dev, qpc, slave, port);
-}
-
 static struct res_common *alloc_qp_tr(int id)
 {
 	struct res_qp *ret;
@@ -2109,7 +2025,7 @@ static int vlan_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 }
 
 static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			     u64 in_param, u64 *out_param, int port)
+			     u64 in_param, u64 *out_param)
 {
 	u32 index;
 	int err;
@@ -2127,7 +2043,7 @@ static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		return err;
 	}
 
-	err = add_res_range(dev, slave, index, 1, RES_COUNTER, port);
+	err = add_res_range(dev, slave, index, 1, RES_COUNTER, 0);
 	if (err) {
 		__mlx4_counter_free(dev, index);
 		mlx4_release_resource(dev, slave, RES_COUNTER, 1, 0);
@@ -2209,7 +2125,7 @@ int mlx4_ALLOC_RES_wrapper(struct mlx4_dev *dev, int slave,
 
 	case RES_COUNTER:
 		err = counter_alloc_res(dev, slave, vhcr->op_modifier, alop,
-					vhcr->in_param, &vhcr->out_param, 0);
+					vhcr->in_param, &vhcr->out_param);
 		break;
 
 	case RES_XRCD:
-- 
2.4.0.rc3.8.gfb3e7d5
