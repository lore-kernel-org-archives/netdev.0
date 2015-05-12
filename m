From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: [PATCH] xen-netfront: reset skb transport header before checksum
Date: Mon, 11 May 2015 18:34:24 -0700
Message-ID: <20150512013424.GA7960@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, david.vrabel@citrix.com,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com
To: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46495 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbbELBeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 21:34:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ed1f50c3a ("net: add skb_checksum_setup") some checksum functions
were introduced in core. Subsequent change b5cf66cd1 ("xen-netfront:
use new skb_checksum_setup function") made use of those functions to
replace its own implementation. With that change ip_hdr() and tcp_hdr()
were not pointing at the right place. d554f73df ("xen-netfront: reset
skb network header before checksum") fixed the ip_hdr().

This patch fixes tcp_hdr().

We saw this problem when LRO was enabled on the host and it results in
netfront setting skb->ip_summed to CHECKSUM_UNNECESSARY.

Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
---
 drivers/net/xen-netfront.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 3f45afd..ed5c242 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -889,6 +889,7 @@ static int handle_incoming_queue(struct netfront_queue *queue,
 		/* Ethernet work: Delayed to here as it peeks the header. */
 		skb->protocol = eth_type_trans(skb, queue->info->netdev);
 		skb_reset_network_header(skb);
+		skb_set_transport_header(skb, ip_hdrlen(skb));
 
 		if (checksum_setup(queue->info->netdev, skb)) {
 			kfree_skb(skb);
-- 
1.8.2.1
