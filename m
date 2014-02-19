From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net] xen-netfront: reset skb network header before checksum
Date: Wed, 19 Feb 2014 18:48:34 +0000
Message-ID: <1392835714-26480-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux@eikelenboom.it>, Wei Liu <wei.liu2@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Paul Durrant <paul.durrant@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:64209 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbaBSSsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 13:48:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ed1f50c3a ("net: add skb_checksum_setup") we introduced some checksum
functions in core driver. Subsequent change b5cf66cd1 ("xen-netfront:
use new skb_checksum_setup function") made use of those functions to
replace its own implementation.

However with that change netfront is broken. It sees a lot of checksum
error. That's because its own implementation of checksum function was a
bit hacky (dereferencing skb->data directly) while the new function was
implemented using ip_hdr(). The network header is not reset before skb
is passed to the new function. When the new function tries to do its
job, it's confused and reports error.

The fix is simple, we need to reset network header before passing skb to
checksum function. Netback is not affected as it already does the right
thing.

Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Paul Durrant <paul.durrant@citrix.com>
---
 drivers/net/xen-netfront.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index ff04d4f..95041b6 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -907,6 +907,7 @@ static int handle_incoming_queue(struct net_device *dev,
 
 		/* Ethernet work: Delayed to here as it peeks the header. */
 		skb->protocol = eth_type_trans(skb, dev);
+		skb_reset_network_header(skb);
 
 		if (checksum_setup(dev, skb)) {
 			kfree_skb(skb);
-- 
1.7.10.4
