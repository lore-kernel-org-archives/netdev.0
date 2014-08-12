From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/3] sunvnet: Do not ask for an ACK for every dring
 transmit
Date: Tue, 12 Aug 2014 10:27:24 -0400
Message-ID: <20140812142724.GH2404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com, davem@davemloft.net,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21094 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbaHLO1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 10:27:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



No need to ask for an ack with every vnet_start_xmit()- the single
ACK with DRING_STOPPED is sufficient for the protocol, and we free
the sk_buff in vnet_start_xmit itself, so we dont need an ACK back.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>

---
 drivers/net/ethernet/sun/sunvnet.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index d813bfb..b489dd0 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -691,7 +691,15 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		memset(tx_buf+VNET_PACKET_SKIP+skb->len, 0, len - skb->len);
 	}
 
-	d->hdr.ack = VIO_ACK_ENABLE;
+	/* We don't rely on the ACKs to free the skb in vnet_start_xmit(),
+	 * thus it is safe to not set VIO_ACK_ENABLE for each transmission:
+	 * the protocol itself does not require it as long as the peer
+	 * sends a VIO_SUBTYPE_ACK for VIO_DRING_STOPPED.
+	 *
+	 * An ACK for every packet in the ring is expensive as the
+	 * sending of LDC messages is slow and affects performance.
+	 */
+	d->hdr.ack = VIO_ACK_DISABLE;
 	d->size = len;
 	d->ncookies = port->tx_bufs[dr->prod].ncookies;
 	for (i = 0; i < d->ncookies; i++)
-- 
1.8.4.2
