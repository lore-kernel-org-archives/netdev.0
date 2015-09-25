From: Robb Manes <rmanes@redhat.com>
Subject: [PATCH] net/mlx4: Handle return codes in mlx4_qp_attach_common
Date: Fri, 25 Sep 2015 10:39:21 -0400
Message-ID: <CAM5t4r_uaRPJT0kiaqNkygu1ciCoVSVQhj5MLkn69uieXx1MHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, Eyal Perry <eyalpe@mellanox.com>,
	ogerlitz@mellanox.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35466 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:39:22 -0400
Received: by obbzf10 with SMTP id zf10so83354249obb.2
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:39:21 -0700 (PDT)
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
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c
b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index bd9ea0d..1d4e2e0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1184,10 +1184,11 @@ out:
     if (prot == MLX4_PROT_ETH) {
         /* manage the steering entry for promisc mode */
         if (new_entry)
-            new_steering_entry(dev, port, steer, index, qp->qpn);
+            err = new_steering_entry(dev, port, steer,
+                         index, qp->qpn);
         else
-            existing_steering_entry(dev, port, steer,
-                        index, qp->qpn);
+            err = existing_steering_entry(dev, port, steer,
+                              index, qp->qpn);
     }
     if (err && link && index != -1) {
         if (index < dev->caps.num_mgms)
-- 
2.4.3
