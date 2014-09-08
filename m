From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net] sunvnet - add missing rmb() for sunvnet driver
Date: Mon, 08 Sep 2014 16:23:01 -0400
Message-ID: <1410207781.24238.5.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44062 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512AbaIHUXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 16:23:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The sunvnet driver does not have an rmb() in the ring consumer corresponding
to the wmb() in the producer. According to Documentation/memory-barriers.txt:

"When dealing with CPU-CPU interactions, certain types of memory barrier should
always be paired.  A lack of appropriate pairing is almost certainly an error."

In cases where an rmb() is not a no-op and a consumer is removing data from
the ring while a producer is adding new entries, a load reorder would allow

CPU1						CPU2
----						----
						LOAD desc.size [e.g]
STORE desc.size
<wmb>
set desc.hdr.state = VIO_DESC_READY
						LOAD desc.hdr.state
						[because VIO_DESC_READY, use
						 old desc.size, already loaded
						 out of order]

[CPU2 has reordered apparently unrelated LOADs]

To ensure other desc fields are not loaded before checking VIO_DESC_READY, we
need an rmb() between the check and desc data accesses.

I've also moved the viodbg() call to after the rmb() so that it, too, has
current descriptor data even with reordering, which has the side effect that
it won't print anything for descriptors that are not VIO_DESC_READY as before.
That's a) probably a good thing, since the fields are not necessarily set and,
b) better than adding another rmb() just for viodbg().

This would not be possible if strict-ordering is enforced, but then the
memory barriers should be no-ops in that case.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 23c89ab..f675396 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -350,14 +350,17 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 	if (IS_ERR(desc))
 		return PTR_ERR(desc);
 
+	if (desc->hdr.state != VIO_DESC_READY)
+		return 1;
+
+	rmb();
+
 	viodbg(DATA, "vio_walk_rx_one desc[%02x:%02x:%08x:%08x:%llx:%llx]\n",
 	       desc->hdr.state, desc->hdr.ack,
 	       desc->size, desc->ncookies,
 	       desc->cookies[0].cookie_addr,
 	       desc->cookies[0].cookie_size);
 
-	if (desc->hdr.state != VIO_DESC_READY)
-		return 1;
 	err = vnet_rx_one(port, desc->size, desc->cookies, desc->ncookies);
 	if (err == -ECONNRESET)
 		return err;
-- 
1.7.1
