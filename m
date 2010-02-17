From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 16/18] igb: use igb_free_q_vectors to cleanup
	failure in igb_alloc_q_vectors
Date: Wed, 17 Feb 2010 03:05:35 -0800
Message-ID: <20100217110533.17723.6435.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:50237
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755576Ab0BQLFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:05:54 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This change makes it so that igb_free_q_vectors is reused in
igb_alloc_q_vectors to handle the cleanup instead of unwinding
through the allocations.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a9f4e02..ab7c5e9 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -649,6 +649,8 @@ static void igb_free_q_vectors(struct igb_adapter *adapter)
 	for (v_idx = 0; v_idx < adapter->num_q_vectors; v_idx++) {
 		struct igb_q_vector *q_vector = adapter->q_vector[v_idx];
 		adapter->q_vector[v_idx] = NULL;
+		if (!q_vector)
+			continue;
 		netif_napi_del(&q_vector->napi);
 		kfree(q_vector);
 	}
@@ -768,13 +770,7 @@ static int igb_alloc_q_vectors(struct igb_adapter *adapter)
 	return 0;
 
 err_out:
-	while (v_idx) {
-		v_idx--;
-		q_vector = adapter->q_vector[v_idx];
-		netif_napi_del(&q_vector->napi);
-		kfree(q_vector);
-		adapter->q_vector[v_idx] = NULL;
-	}
+	igb_free_q_vectors(adapter);
 	return -ENOMEM;
 }
 

