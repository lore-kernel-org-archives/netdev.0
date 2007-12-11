From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH resent] virtio_net: Fix stalled inbound traffic on early packets
Date: Tue, 11 Dec 2007 12:42:28 +0100
Message-ID: <200712111242.28843.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm-devel <kvm-devel@lists.sourceforge.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:53424 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbXLKLnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 06:43:05 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBBBh3vV308798
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 11:43:03 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBBBh3BK4935720
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 11:43:03 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBBBgkPS025781
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 11:42:47 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Rusty,

while implementing and testing virtio on s390 I found a problem in
virtio_net: The current virtio_net driver has a startup race, which
prevents any incoming traffic:

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
 
