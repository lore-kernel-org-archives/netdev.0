From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH] virtio_net: Fix open <-> interrupt race
Date: Tue, 5 Feb 2008 14:36:10 +0100
Message-ID: <200802051436.10841.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>, dor.laor@qumranet.com,
	Anthony Liguori <aliguori@us.ibm.com>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:7124 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbYBENgQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 08:36:16 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m15DaEV3029862
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 13:36:14 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m15DaERh917684
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 14:36:14 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m15DaDNd025027
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 14:36:14 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got the following oops during interface ifup. Unfortunately its not=20
easily reproducable so I cant say for sure that my fix fixes this
problem, but I am confident and I think its correct anyway:

   <2>kernel BUG at /space/kvm/drivers/virtio/virtio_ring.c:234!
    <4>illegal operation: 0001 [#1] PREEMPT SMP
    <4>Modules linked in:
    <4>CPU: 0 Not tainted 2.6.24zlive-guest-07293-gf1ca151-dirty #91
    <4>Process swapper (pid: 0, task: 0000000000800938, ksp: 0000000000=
84ddb8)
    <4>Krnl PSW : 0404300180000000 0000000000466374 (vring_disable_cb+0=
x30/0x34)
    <4>           R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:3 PM:0 EA=
:3
    <4>Krnl GPRS: 0000000000000001 0000000000000001 0000000010003800 00=
00000000466344
    <4>           000000000e980900 00000000008848b0 000000000084e748 00=
00000000000000
    <4>           000000000087b300 0000000000001237 0000000000001237 00=
0000000f85bdd8
    <4>           000000000e980920 00000000001137c0 0000000000464754 00=
0000000f85bdd8
    <4>Krnl Code: 0000000000466368: e3b0b0700004        lg      %r11,11=
2(%r11)
    <4>           000000000046636e: 07fe                bcr     15,%r14
    <4>           0000000000466370: a7f40001            brc     15,4663=
72
    <4>          >0000000000466374: a7f4fff6            brc     15,4663=
60
    <4>           0000000000466378: eb7ff0500024        stmg    %r7,%r1=
5,80(%r15)
    <4>           000000000046637e: a7f13e00            tmll    %r15,15=
872
    <4>           0000000000466382: b90400ef            lgr     %r14,%r=
15
    <4>           0000000000466386: a7840001            brc     8,46638=
8
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
in the same way as skb_recv_done.=20


Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 drivers/net/virtio_net.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: kvm/drivers/net/virtio_net.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- kvm.orig/drivers/net/virtio_net.c
+++ kvm/drivers/net/virtio_net.c
@@ -321,10 +321,12 @@ static int virtnet_open(struct net_devic
=20
 	/* If all buffers were filled by other side before we napi_enabled, w=
e
 	 * won't get another interrupt, so process any outstanding packets
-	 * now.  virtnet_poll wants re-enable the queue, so we disable here. =
*/
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
--=20
IBM Deutschland Entwicklung GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=E4ftsf=FChrung: Herbert Kircher=20
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294

