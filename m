From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net v4 2/2] xen-netback: napi: don't prematurely request a tx event
Date: Wed, 11 Dec 2013 10:57:16 +0000
Message-ID: <1386759436-46737-3-git-send-email-paul.durrant@citrix.com>
References: <1386759436-46737-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"Ian Campbell" <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43921 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058Ab3LKK5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 05:57:20 -0500
In-Reply-To: <1386759436-46737-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the RING_FINAL_CHECK_FOR_REQUESTS in
xenvif_build_tx_gops to a check for RING_HAS_UNCONSUMED_REQUESTS as the
former call has the side effect of advancing the ring event pointer and
therefore inviting another interrupt from the frontend before the napi
poll has actually finished, thereby defeating the point of napi.

The event pointer is updated by RING_FINAL_CHECK_FOR_REQUESTS in
xenvif_poll, the napi poll function, if the work done is less than the
budget i.e. when actually transitioning back to interrupt mode.

Reported-by: Malcolm Crossley <malcolm.crossley@citrix.com>
Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 83b4e5b..fb512a9 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1381,7 +1381,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 			continue;
 		}
 
-		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, work_to_do);
+		work_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
 		if (!work_to_do)
 			break;
 
-- 
1.7.10.4
