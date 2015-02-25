From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v2 net] e1000: add dummy allocator to fix race condition between mtu change and netpoll
Date: Wed, 25 Feb 2015 12:03:14 +0100
Message-ID: <1424862194-15770-1-git-send-email-sd@queasysnail.net>
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:64962 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbbBYLDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 06:03:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race condition between e1000_change_mtu's cleanups and
netpoll, when we change the MTU across jumbo size:

Changing MTU frees all the rx buffers:
    e1000_change_mtu -> e1000_down -> e1000_clean_all_rx_rings ->
        e1000_clean_rx_ring

Then, close to the end of e1000_change_mtu:
    pr_info -> ... -> netpoll_poll_dev -> e1000_clean ->
        e1000_clean_rx_irq -> e1000_alloc_rx_buffers -> e1000_alloc_frag

And when we come back to do the rest of the MTU change:
    e1000_up -> e1000_configure -> e1000_configure_rx ->
        e1000_alloc_jumbo_rx_buffers

alloc_jumbo finds the buffers already != NULL, since data (shared with
page in e1000_rx_buffer->rxbuf) has been re-alloc'd, but it's garbage,
or at least not what is expected when in jumbo state.

This results in an unusable adapter (packets don't get through), and a
NULL pointer dereference on the next call to e1000_clean_rx_ring
(other mtu change, link down, shutdown):

BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<ffffffff81194d6e>] put_compound_page+0x7e/0x330

    [...]

Call Trace:
 [<ffffffff81195445>] put_page+0x55/0x60
 [<ffffffff815d9f44>] e1000_clean_rx_ring+0x134/0x200
 [<ffffffff815da055>] e1000_clean_all_rx_rings+0x45/0x60
 [<ffffffff815df5e0>] e1000_down+0x1c0/0x1d0
 [<ffffffff811e2260>] ? deactivate_slab+0x7f0/0x840
 [<ffffffff815e21bc>] e1000_change_mtu+0xdc/0x170
 [<ffffffff81647050>] dev_set_mtu+0xa0/0x140
 [<ffffffff81664218>] do_setlink+0x218/0xac0
 [<ffffffff814459e9>] ? nla_parse+0xb9/0x120
 [<ffffffff816652d0>] rtnl_newlink+0x6d0/0x890
 [<ffffffff8104f000>] ? kvm_clock_read+0x20/0x40
 [<ffffffff810a2068>] ? sched_clock_cpu+0xa8/0x100
 [<ffffffff81663802>] rtnetlink_rcv_msg+0x92/0x260

By setting the allocator to a dummy version, netpoll can't mess up our
rx buffers.  The allocator is set back to a sane value in
e1000_configure_rx.

Fixes: edbbb3ca1077 ("e1000: implement jumbo receive with partial descriptors")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---

v2: Eric Dumazet suggested to remove the forward declaration of
       e1000_alloc_dummy_rx_buffers

 drivers/net/ethernet/intel/e1000/e1000_main.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 7f997d36948f..6527e4c2b1b6 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -144,6 +144,11 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				     struct e1000_rx_ring *rx_ring,
 				     int *work_done, int work_to_do);
+static void e1000_alloc_dummy_rx_buffers(struct e1000_adapter *adapter,
+					 struct e1000_rx_ring *rx_ring,
+					 int cleaned_count)
+{
+}
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 				   struct e1000_rx_ring *rx_ring,
 				   int cleaned_count);
@@ -3552,8 +3557,11 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		msleep(1);
 	/* e1000_down has a dependency on max_frame_size */
 	hw->max_frame_size = max_frame;
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
+		/* prevent buffers from being reallocated */
+		adapter->alloc_rx_buf = e1000_alloc_dummy_rx_buffers;
 		e1000_down(adapter);
+	}
 
 	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
@@ -4481,6 +4489,7 @@ next_desc:
 	return cleaned;
 }
 
+
 /**
  * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
  * @adapter: address of board private structure
-- 
2.3.0
