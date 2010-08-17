From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH] ibmveth: Fix opps during MTU change on an active device
Date: Tue, 17 Aug 2010 14:15:45 -0500
Message-ID: <20100817191543.GA5016@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Santiago Leon <santil@linux.vnet.ibm.com>,
	Brian King <brking@linux.vnet.ibm.com>,
	Rafael Camarda Silva Folco <rfolco@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:52118 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746Ab0HQTPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 15:15:54 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7HIuwtf030210
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 14:56:58 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7HJFki0132550
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 15:15:46 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7HJFjTP014806
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 16:15:45 -0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following opps which can occur when trying to deallocate
receive buffer pools when changing the MTU of an active ibmveth device.

Oops: Kernel access of bad area, sig: 11 [#1]
NIP: d000000004db00e8 LR: d000000004db00ac CTR: 0000000000591038
REGS: c00000007fff39d0 TRAP: 0300   Not tainted  (2.6.36-rc1)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 22248244  XER: 00000002
DAR: 0000000000000488, DSISR: 0000000042000000
TASK = c00000007c463790[6531] 'netserver' THREAD: c00000007a154000 CPU: 0
GPR00: 0000000000000000 c00000007fff3c50 d000000004dbd360 0000000000000001 
GPR04: 0000000000000001 1fffffffffffffff 000000000000043c c00000007a8e9f60 
GPR08: c00000007a8e9e20 0000000000000245 0000000000000488 0000000000000000 
GPR12: 00000000000000c0 c000000006d70000 c00000007bfec098 c00000007bfebc2c 
GPR16: c00000007a157c78 0000000000000000 0000000000000001 0000000000000000 
GPR20: 0000000000000001 0000000000000010 c000000000b51180 c00000007a8e9d90 
GPR24: c00000007a8e9da0 c00000007a8e9580 00000000000005ea 00000000000002ff 
GPR28: 0000000000000004 0000000000000080 c000000000a946f8 c00000007a8e9d80 
NIP [d000000004db00e8] .ibmveth_remove_buffer_from_pool+0xe8/0x130 [ibmveth]
LR [d000000004db00ac] .ibmveth_remove_buffer_from_pool+0xac/0x130 [ibmveth]
Call Trace:
[c00000007fff3c50] [d000000004db00ac] .ibmveth_remove_buffer_from_pool+0xac/0x130 [ibmveth] (unreliable)
[c00000007fff3cf0] [d000000004db31dc] .ibmveth_poll+0x30c/0x460 [ibmveth]
[c00000007fff3dd0] [c00000000042c4b8] .net_rx_action+0x178/0x278
[c00000007fff3eb0] [c000000000093cf0] .__do_softirq+0x118/0x1f8
[c00000007fff3f90] [c00000000002ab3c] .call_do_softirq+0x14/0x24
[c00000007a157600] [c00000000000e3e4] .do_softirq+0xec/0x110
[c00000007a1576a0] [c000000000093394] .local_bh_enable_ip+0xb4/0xe0
[c00000007a157720] [c0000000004f0bac] ._raw_spin_unlock_bh+0x3c/0x50
[c00000007a157790] [c0000000004186e0] .release_sock+0x158/0x188
[c00000007a157840] [c000000000479660] .tcp_recvmsg+0x560/0x9b8
[c00000007a157970] [c0000000004a0d78] .inet_recvmsg+0x80/0xd8
[c00000007a157a00] [c000000000413e28] .sock_recvmsg+0x128/0x178
[c00000007a157bf0] [c0000000004164ac] .SyS_recvfrom+0xb4/0x148
[c00000007a157d70] [c000000000411f3c] .SyS_socketcall+0x274/0x360
[c00000007a157e30] [c0000000000085b4] syscall_exit+0x0/0x40

Reported-by: Rafael Camarda Silva Folco <rfolco@linux.vnet.ibm.com>
Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

---
 drivers/net/ibmveth.c |   32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

Index: linux-2.6/drivers/net/ibmveth.c
===================================================================
--- linux-2.6.orig/drivers/net/ibmveth.c	2010-07-28 10:21:25.189339177 -0500
+++ linux-2.6/drivers/net/ibmveth.c	2010-08-12 08:46:33.378488391 -0500
@@ -1113,7 +1113,8 @@
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	struct vio_dev *viodev = adapter->vdev;
 	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
-	int i;
+	int i, rc;
+	int need_restart = 0;
 
 	if (new_mtu < IBMVETH_MAX_MTU)
 		return -EINVAL;
@@ -1127,35 +1128,32 @@
 
 	/* Deactivate all the buffer pools so that the next loop can activate
 	   only the buffer pools necessary to hold the new MTU */
-	for (i = 0; i < IbmVethNumBufferPools; i++)
-		if (adapter->rx_buff_pool[i].active) {
-			ibmveth_free_buffer_pool(adapter,
-						 &adapter->rx_buff_pool[i]);
-			adapter->rx_buff_pool[i].active = 0;
-		}
+	if (netif_running(adapter->netdev)) {
+		need_restart = 1;
+		adapter->pool_config = 1;
+		ibmveth_close(adapter->netdev);
+		adapter->pool_config = 0;
+	}
 
 	/* Look for an active buffer pool that can hold the new MTU */
 	for(i = 0; i<IbmVethNumBufferPools; i++) {
 		adapter->rx_buff_pool[i].active = 1;
 
 		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size) {
-			if (netif_running(adapter->netdev)) {
-				adapter->pool_config = 1;
-				ibmveth_close(adapter->netdev);
-				adapter->pool_config = 0;
-				dev->mtu = new_mtu;
-				vio_cmo_set_dev_desired(viodev,
-						ibmveth_get_desired_dma
-						(viodev));
-				return ibmveth_open(adapter->netdev);
-			}
 			dev->mtu = new_mtu;
 			vio_cmo_set_dev_desired(viodev,
 						ibmveth_get_desired_dma
 						(viodev));
+			if (need_restart) {
+				return ibmveth_open(adapter->netdev);
+			}
 			return 0;
 		}
 	}
+
+	if (need_restart && (rc = ibmveth_open(adapter->netdev)))
+		return rc;
+
 	return -EINVAL;
 }
 
