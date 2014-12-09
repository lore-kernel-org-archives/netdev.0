From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netfront: use correct linear area after linearizing an skb
Date: Tue, 9 Dec 2014 18:43:28 +0000
Message-ID: <1418150608-26180-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:5455 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587AbaLISnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 13:43:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 97a6d1bb2b658ac85ed88205ccd1ab809899884d (xen-netfront: Fix
handling packets on compound pages with skb_linearize) attempted to
fix a problem where an skb that would have required too many slots
would be dropped causing TCP connections to stall.

However, it filled in the first slot using the original buffer and not
the new one and would use the wrong offset and grant access to the
wrong page.

Netback would notice the malformed request and stop all traffic on the
VIF, reporting:

    vif vif-3-0 vif3.0: txreq.offset: 85e, size: 4002, end: 6144
    vif vif-3-0 vif3.0: fatal error; disabling device

Reported-by: Anthony Wright <anthony@overnetdata.com>
Tested-by: Anthony Wright <anthony@overnetdata.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index ece8d18..eeed0ce 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -627,6 +627,9 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				    slots, skb->len);
 		if (skb_linearize(skb))
 			goto drop;
+		data = skb->data;
+		offset = offset_in_page(data);
+		len = skb_headlen(skb);
 	}
 
 	spin_lock_irqsave(&queue->tx_lock, flags);
-- 
1.7.10.4
