From: Robb Manes <rmanes@redhat.com>
Subject: [PATCH v2] net/mlx4: Handle return codes in mlx4_qp_attach_common
Date: Tue, 29 Sep 2015 11:03:37 -0400
Message-ID: <1443539017-4851-1-git-send-email-rmanes@redhat.com>
References: <20150928.222642.1395622340146984028.davem@davemloft.net>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, eyalpe@mellanox.com,
	ogerlitz@mellanox.com, Robb Manes <rmanes@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34349 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756328AbbI2PEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 11:04:04 -0400
Received: by qgez77 with SMTP id z77so8480661qge.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 08:04:03 -0700 (PDT)
In-Reply-To: <20150928.222642.1395622340146984028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both new_steering_entry() and existing_steering_entry() return values
based on their success or failure, but currently they fall through
silently.  This can make troubleshooting difficult, as we were unable
to tell which one of these two functions returned errors or
specifically what code was returned.  This patch remedies that
situation by passing the return codes to err, which is returned by
mlx4_qp_attach_common() itself.

This also addresses a leak in the call to mlx4_bitmap_free() as well.

Signed-off-by: Robb Manes <rmanes@redhat.com>
---
Sorry about the poor formatting; I should have used git-send properly.

 drivers/net/ethernet/mellanox/mlx4/mcg.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index bd9ea0d..1d4e2e0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1184,10 +1184,11 @@ out:
 	if (prot == MLX4_PROT_ETH) {
 		/* manage the steering entry for promisc mode */
 		if (new_entry)
-			new_steering_entry(dev, port, steer, index, qp->qpn);
+			err = new_steering_entry(dev, port, steer,
+						 index, qp->qpn);
 		else
-			existing_steering_entry(dev, port, steer,
-						index, qp->qpn);
+			err = existing_steering_entry(dev, port, steer,
+						      index, qp->qpn);
 	}
 	if (err && link && index != -1) {
 		if (index < dev->caps.num_mgms)
-- 
2.4.3
