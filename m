From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: pci: Correctly determine if descriptor queue is full
Date: Mon,  7 Mar 2016 09:24:52 +0100
Message-ID: <1457339092-2878-3-git-send-email-jiri@resnulli.us>
References: <1457339092-2878-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:32832 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbcCGIY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 03:24:59 -0500
Received: by mail-wm0-f48.google.com with SMTP id l68so97581160wml.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 00:24:58 -0800 (PST)
In-Reply-To: <1457339092-2878-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The descriptor queues for sending (SDQs) and receiving (RDQs) packets
are managed by two counters - producer and consumer - which are both
16-bit in size. A queue is considered full when the difference between
the two equals the queue's maximum number of descriptors.

However, if the producer counter overflows, then it's possible for the
full queue check to fail, as it doesn't take the overflow into account.
In such a case, descriptors already passed to the device - but for which
a completion has yet to be posted - will be overwritten, thereby causing
undefined behavior. The above can be achieved under heavy load (~30
netperf instances).

Fix that by casting the substraction result to u16, preventing it from
being treated as a signed integer.

Fixes: eda6500a987a ("mlxsw: Add PCI bus implementation")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index c071077..7992c55 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -215,7 +215,7 @@ mlxsw_pci_queue_elem_info_producer_get(struct mlxsw_pci_queue *q)
 {
 	int index = q->producer_counter & (q->count - 1);
 
-	if ((q->producer_counter - q->consumer_counter) == q->count)
+	if ((u16) (q->producer_counter - q->consumer_counter) == q->count)
 		return NULL;
 	return mlxsw_pci_queue_elem_info_get(q, index);
 }
-- 
2.5.0
