From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general][PATCH] mlx4: FIX error flow when initializing EQ table
Date: Tue, 09 Jun 2009 13:46:23 -0700
Message-ID: <adavdn53zkw.fsf@cisco.com>
References: <4A2BD9B9.6000802@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	Christoph Lameter <cl@linux-foundation.org>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:41529 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbZFIUqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 16:46:21 -0400
In-Reply-To: <4A2BD9B9.6000802@mellanox.co.il> (Yevgeny Petrilin's message of
	"Sun, 07 Jun 2009 18:16:09 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > If mlx4_create_eq() would fail for one of EQ's assigned for
 > completion handling, the code would try to free the same EQ
 > we failed to create.
 > The crash was found by Christoph Lameter

Thanks, good catch.  However looking at the code it seems that a simpler
way to fix this would be as below.  Can you confirm that this works too?
---
 drivers/net/mlx4/eq.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 8830dcb..033817e 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -677,12 +677,12 @@ err_out_async:
 	mlx4_free_eq(dev, &priv->eq_table.eq[dev->caps.num_comp_vectors]);
 
 err_out_comp:
-	i = dev->caps.num_comp_vectors - 1;
+	i = dev->caps.num_comp_vectors;
 
 err_out_unmap:
-	while (i >= 0) {
-		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
+	while (i > 0) {
 		--i;
+		mlx4_free_eq(dev, &priv->eq_table.eq[i]);
 	}
 	mlx4_unmap_clr_int(dev);
 	mlx4_free_irqs(dev);
