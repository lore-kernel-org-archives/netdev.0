From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netback: fix guest Rx stall detection (after guest Rx refactor)
Date: Tue, 11 Oct 2016 16:48:27 +0100
Message-ID: <1476200907-16085-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
        <xen-devel@lists.xenproject.org>,
        Paul Durrant <paul.durrant@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:16854 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752357AbcJKPsb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 11:48:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a VIF has been ready for rx_stall_timeout (60s by default) and an
Rx ring is drained of all requests an Rx stall will be incorrectly
detected.  When this occurs and the guest Rx queue is empty, the Rx
ring's event index will not be set and the frontend will not raise an
event when new requests are placed on the ring, permanently stalling
the VIF.

This is a regression introduced by eb1723a29b9a7 (xen-netback:
refactor guest rx).

Fix this by reinstating the setting of queue->last_rx_time when
placing a packet onto the guest Rx ring.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/rx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
index 8e9ade6..d69f2a9 100644
--- a/drivers/net/xen-netback/rx.c
+++ b/drivers/net/xen-netback/rx.c
@@ -425,6 +425,8 @@ void xenvif_rx_skb(struct xenvif_queue *queue)
 
 	xenvif_rx_next_skb(queue, &pkt);
 
+	queue->last_rx_time = jiffies;
+
 	do {
 		struct xen_netif_rx_request *req;
 		struct xen_netif_rx_response *rsp;
-- 
2.1.4
