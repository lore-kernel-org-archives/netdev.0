From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH] virtio_net: Fix open <-> interrupt race
Date: Wed, 6 Feb 2008 08:50:11 +0100
Message-ID: <200802060850.11923.borntraeger@de.ibm.com>
References: <200802051436.10841.borntraeger@de.ibm.com> <200802061500.04138.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:28628 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759086AbYBFHuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 02:50:54 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m167oYOe149050
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 07:50:34 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m167oY3w4530364
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 07:50:34 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m167oPfl014775
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 07:50:26 GMT
In-Reply-To: <200802061500.04138.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Rusty is (supposed to be) on vacation. Can you send this fix against
virtio_net with your next network driver fixes for 2.6.25? 

Thank you

-

I got the following oops during interface ifup. Unfortunately its not 
easily reproducable so I cant say for sure that my fix fixes this
problem, but I am confident and I think its correct anyway:

   <2>kernel BUG at /space/kvm/drivers/virtio/virtio_ring.c:234!
    <4>illegal operation: 0001 [#1] PREEMPT SMP
    <4>Modules linked in:
    <4>CPU: 0 Not tainted 2.6.24zlive-guest-07293-gf1ca151-dirty #91
    <4>Process swapper (pid: 0, task: 0000000000800938, ksp: 000000000084ddb8)
    <4>Krnl PSW : 0404300180000000 0000000000466374 (vring_disable_cb+0x30/0x34)
    <4>           R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:3 PM:0 EA:3
    <4>Krnl GPRS: 0000000000000001 0000000000000001 0000000010003800 0000000000466344
    <4>           000000000e980900 00000000008848b0 000000000084e748 0000000000000000
    <4>           000000000087b300 0000000000001237 0000000000001237 000000000f85bdd8
    <4>           000000000e980920 00000000001137c0 0000000000464754 000000000f85bdd8
    <4>Krnl Code: 0000000000466368: e3b0b0700004        lg      %r11,112(%r11)
    <4>           000000000046636e: 07fe                bcr     15,%r14
    <4>           0000000000466370: a7f40001            brc     15,466372
    <4>          >0000000000466374: a7f4fff6            brc     15,466360
    <4>           0000000000466378: eb7ff0500024        stmg    %r7,%r15,80(%r15)
    <4>           000000000046637e: a7f13e00            tmll    %r15,15872
    <4>           0000000000466382: b90400ef            lgr     %r14,%r15
    <4>           0000000000466386: a7840001            brc     8,466388
    <4>Call Trace:
    <4>([<000201500f85c000>] 0x201500f85c000)
    <4> [<0000000000466556>] vring_interrupt+0x72/0x88
    <4> [<00000000004801a0>] kvm_extint_handler+0x34/0x44
    <4> [<000000000010d22c>] do_extint+0xbc/0xf8
    <4> [<0000000000113f98>] ext_no_vtime+0x16/0x1a
    <4> [<000000000010a182>] cpu_idle+0x216/0x238
    <4>([<000000000010a162>] cpu_idle+0x1f6/0x238)
    <4> [<0000000000568656>] rest_init+0xaa/0xb8
    <4> [<000000000084ee2c>] start_kernel+0x3fc/0x490
    <4> [<0000000000100020>] _stext+0x20/0x80
    <4>
    <4> <0>Kernel panic - not syncing: Fatal exception in interrupt
    <4>

After looking at the code and the dump I think the following scenario
happened: Ifup was running on cpu2 and the interrupt arrived on cpu0.
Now virtnet_open on cpu 2 managed to execute napi_enable and disable_cb
but did not execute rx_schedule. Meanwhile on cpu 0 skb_recv_done was
called by vring_interrupt, executed netif_rx_schedule_prep, which
succeeded and therefore called disable_cb. This triggered the BUG_ON,
as interrupts were already disabled by cpu 2.

I think the proper solution is to make the call to disable_cb depend on
the atomic update of NAPI_STATE_SCHED by using netif_rx_schedule_prep
in the same way as skb_recv_done. 


Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Acked-by: Rusty Russell <rusty@rustcorp.com.au>

---
 drivers/net/virtio_net.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: kvm/drivers/net/virtio_net.c
===================================================================
--- kvm.orig/drivers/net/virtio_net.c
+++ kvm/drivers/net/virtio_net.c
@@ -321,10 +321,12 @@ static int virtnet_open(struct net_devic
 
 	/* If all buffers were filled by other side before we napi_enabled, we
 	 * won't get another interrupt, so process any outstanding packets
-	 * now.  virtnet_poll wants re-enable the queue, so we disable here. */
-	vi->rvq->vq_ops->disable_cb(vi->rvq);
-	netif_rx_schedule(vi->dev, &vi->napi);
-
+	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
+	 * We synchronize against interrupts via NAPI_STATE_SCHED */
+	if (netif_rx_schedule_prep(dev, &vi->napi)) {
+		vi->rvq->vq_ops->disable_cb(vi->rvq);
+		__netif_rx_schedule(dev, &vi->napi);
+	}
 	return 0;
 }
 
