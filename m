From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: restore conditional call to
 napi_complete_done()
Date: Mon, 10 Nov 2014 14:07:20 -0800
Message-ID: <1415657240.9613.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415337011.13896.103.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141107.170053.1003349690694025765.davem@redhat.com>
	 <1415642488.9613.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ogerlitz@mellanox.com,
	willemb@google.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34326 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbaKJWHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 17:07:22 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so9888543iec.7
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 14:07:21 -0800 (PST)
In-Reply-To: <1415642488.9613.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 1a28817282 ("mlx4: use napi_complete_done()") we ended up
calling napi_complete_done() in the case NAPI poll consumed all its
budget.

This added extra interrupt pressure, this patch restores proper
behavior.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 1a28817282 ("mlx4: use napi_complete_done()")
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 46ee78326f1fecb14f42d1afcc113fa18087cfa6..5a193f40a14c2a89fecfbac5dce0771e15e69861 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -910,13 +910,14 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 		cpu_curr = smp_processor_id();
 		aff = irq_desc_get_irq_data(cq->irq_desc)->affinity;
 
-		if (unlikely(!cpumask_test_cpu(cpu_curr, aff))) {
-			/* Current cpu is not according to smp_irq_affinity -
-			 * probably affinity changed. need to stop this NAPI
-			 * poll, and restart it on the right CPU
-			 */
-			done = 0;
-		}
+		if (likely(cpumask_test_cpu(cpu_curr, aff)))
+			return budget;
+
+		/* Current cpu is not according to smp_irq_affinity -
+		 * probably affinity changed. need to stop this NAPI
+		 * poll, and restart it on the right CPU
+		 */
+		done = 0;
 	}
 	/* Done for now */
 	napi_complete_done(napi, done);
