From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 7/7] xen-netback: don't disconnect frontend when seeing oversize packet
Date: Tue, 9 Apr 2013 12:07:35 +0100
Message-ID: <1365505655-8021-8-git-send-email-wei.liu2@citrix.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>,
	<konrad.wilk@oracle.com>, <annie.li@oracle.com>,
	<wdauchy@gmail.com>, Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:52765 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935763Ab3DILWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 07:22:07 -0400
In-Reply-To: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some frontend drivers are sending packets > 64 KiB in length. This length
overflows the length field in the first slot making the following slots have
an invalid length ("Packet is bigger than frame").

Turn this error back into a non-fatal error by dropping the packet. To avoid
having the following slots having fatal errors, consume all slots in the
packet.

This does not reopen the security hole in XSA-39 as if the packet as an
invalid number of slots it will still hit fatal error case.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 3490b2c..acd057b 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -986,10 +986,21 @@ static int netbk_count_requests(struct xenvif *vif,
 
 		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
 		       sizeof(*txp));
-		if (txp->size > first->size) {
-			netdev_err(vif->dev, "Packet is bigger than frame.\n");
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
+					   "Packet is bigger than frame.\n");
+			drop_err = -EIO;
 		}
 
 		first->size -= txp->size;
-- 
1.7.10.4
