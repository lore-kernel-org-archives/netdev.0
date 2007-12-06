From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH] virtio_net: Fix stalled inbound traffic on early packets
Date: Thu, 6 Dec 2007 16:59:44 +0100
Message-ID: <200712061659.44803.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Anthony Liguori <aliguori@us.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:29463 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbXLFP7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 10:59:50 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB6Fxns5040844
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 15:59:49 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB6Fxmqo2150440
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 16:59:48 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB6Fxm5f014875
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 16:59:48 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current virtio_net driver has a startup race, which prevents any
incoming traffic:

If try_fill_recv submits buffers to the host system data might be
filled in and an interrupt is sent, before napi_enable finishes.
In that case the interrupt will kick skb_recv_done which will then
call netif_rx_schedule. netif_rx_schedule checks, if NAPI_STATE_SCHED
is set - which is not as we did not run napi_enable. No poll routine
is scheduled. Furthermore, skb_recv_done returns false, we disables
interrupts for this device.

One solution is the enable napi before inbound buffer are available.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 drivers/net/virtio_net.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: kvm/drivers/net/virtio_net.c
===================================================================
--- kvm.orig/drivers/net/virtio_net.c
+++ kvm/drivers/net/virtio_net.c
@@ -285,13 +285,15 @@ static int virtnet_open(struct net_devic
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
+	napi_enable(&vi->napi);
 	try_fill_recv(vi);
 
 	/* If we didn't even get one input buffer, we're useless. */
-	if (vi->num == 0)
+	if (vi->num == 0) {
+		napi_disable(&vi->napi);
 		return -ENOMEM;
+	}
 
-	napi_enable(&vi->napi);
 	return 0;
 }
 
