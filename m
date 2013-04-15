From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH V5 7/7] xen-netback: don't disconnect frontend when seeing oversize packet
Date: Mon, 15 Apr 2013 18:06:21 +0100
Message-ID: <1366045581-31349-8-git-send-email-wei.liu2@citrix.com>
References: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <annie.li@oracle.com>, <konrad.wilk@oracle.com>,
	<jbeulich@suse.com>, <ian.campbell@citrix.com>,
	<wdauchy@gmail.com>, <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:26001 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311Ab3DORGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:06:39 -0400
In-Reply-To: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some frontend drivers are sending packets > 64 KiB in length. This length
overflows the length field in the first slot making the following slots have
an invalid length.

Turn this error back into a non-fatal error by dropping the packet. To avoid
having the following slots having fatal errors, consume all slots in the
packet.

This does not reopen the security hole in XSA-39 as if the packet as an
invalid number of slots it will still hit fatal error case.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/netback.c |   22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 86d533a..8b25124 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -981,12 +981,22 @@ static int netbk_count_requests(struct xenvif *vif,
 
 		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
 		       sizeof(*txp));
-		if (txp->size > first->size) {
-			netdev_err(vif->dev,
-				   "Invalid tx request, slot size %u > remaining size %u\n",
-				   txp->size, first->size);
-			netbk_fatal_tx_err(vif);
-			return -EIO;
+
+		/* If the guest submitted a frame >= 64 KiB then
+		 * first->size overflowed and following slots will
+		 * appear to be larger than the frame.
+		 *
+		 * This cannot be fatal error as there are buggy
+		 * frontends that do this.
+		 *
+		 * Consume all slots and drop the packet.
+		 */
+		if (!drop_err && txp->size > first->size) {
+			if (net_ratelimit())
+				netdev_dbg(vif->dev,
+					   "Invalid tx request, slot size %u > remaining size %u\n",
+					   txp->size, first->size);
+			drop_err = -EIO;
 		}
 
 		first->size -= txp->size;
-- 
1.7.10.4
