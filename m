From: Santwona.Behera@Sun.COM
Subject: PATCH[1/1] niu: panic on reset
Date: Fri, 12 Sep 2008 12:58:38 -0700
Message-ID: <48CAC9EE.1000700@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_mldPe8FQmE4SDKpPeO0gNg)"
Cc: Matheos Worku <Matheos.Worku@Sun.COM>, agospoda@redhat.com,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:44766 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbYILT6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 15:58:46 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m8CJweoG024966
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 12:58:41 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K7300B01LW4O600@fe-sfbay-10.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Fri,
 12 Sep 2008 12:58:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_mldPe8FQmE4SDKpPeO0gNg)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT

The reset_task function in the niu driver does not reset the tx and rx 
buffers
properly. This leads to panic on reset. This patch is a modified 
implementation
of the previously posted fix.


--Boundary_(ID_mldPe8FQmE4SDKpPeO0gNg)
Content-type: text/x-patch; name=niu-panic-on-reset.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=niu-panic-on-reset.patch

Signed-off-by: Santwona Behera <santwona.behera@sun.com>
---
 drivers/net/niu.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index e4765b7..e3be81e 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -5984,6 +5984,56 @@ static void niu_netif_start(struct niu *np)
 	niu_enable_interrupts(np, 1);
 }
 
+static void niu_reset_buffers(struct niu *np)
+{
+	int i, j, k, err;
+
+	if (np->rx_rings) {
+		for (i = 0; i < np->num_rx_rings; i++) {
+			struct rx_ring_info *rp = &np->rx_rings[i];
+
+			for (j = 0, k = 0; j < MAX_RBR_RING_SIZE; j++) {
+				struct page *page;
+
+				page = rp->rxhash[j];
+				while (page) {
+					struct page *next =
+						(struct page *) page->mapping;
+					u64 base = page->index;
+					base = base >> RBR_DESCR_ADDR_SHIFT;
+					rp->rbr[k++] = cpu_to_le32(base);
+					page = next;
+				}
+			}
+			for (; k < MAX_RBR_RING_SIZE; k++) {
+				err = niu_rbr_add_page(np, rp, GFP_ATOMIC, k);
+				if (unlikely(err))
+					break;
+			}
+
+			rp->rbr_index = rp->rbr_table_size - 1;
+			rp->rcr_index = 0;
+			rp->rbr_pending = 0;
+			rp->rbr_refill_pending = 0;
+		}
+	}
+	if (np->tx_rings) {
+		for (i = 0; i < np->num_tx_rings; i++) {
+			struct tx_ring_info *rp = &np->tx_rings[i];
+
+			for (j = 0; j < MAX_TX_RING_SIZE; j++) {
+				if (rp->tx_buffs[j].skb)
+					(void) release_tx_packet(np, rp, j);
+			}
+
+			rp->pending = MAX_TX_RING_SIZE;
+			rp->prod = 0;
+			rp->cons = 0;
+			rp->wrap_bit = 0;
+		}
+	}
+}
+
 static void niu_reset_task(struct work_struct *work)
 {
 	struct niu *np = container_of(work, struct niu, reset_task);
@@ -6006,6 +6056,12 @@ static void niu_reset_task(struct work_struct *work)
 
 	niu_stop_hw(np);
 
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	niu_reset_buffers(np);
+
+	spin_lock_irqsave(&np->lock, flags);
+
 	err = niu_init_hw(np);
 	if (!err) {
 		np->timer.expires = jiffies + HZ;
-- 
1.5.2


--Boundary_(ID_mldPe8FQmE4SDKpPeO0gNg)--
