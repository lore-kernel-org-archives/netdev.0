From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to NOBALANCING and
	set affinity
Date: Tue, 20 Oct 2009 19:27:14 -0700
Message-ID: <20091021022713.32449.54868.stgit@localhost.localdomain>
References: <20091021022626.32449.73883.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:47977
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752612AbZJUCaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 22:30:16 -0400
In-Reply-To: <20091021022626.32449.73883.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch will set each MSI-X vector to IRQF_NOBALANCING to
prevent autobalance of the interrupts, then applies a CPU
affinity.  This will only be done when Flow Director is enabled,
which needs interrupts to be processed on the same CPUs where the
applications are running.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   34 +++++++++++++++++++++++++++++-----
 1 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4c8a449..d2280c3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1565,8 +1565,10 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	irqreturn_t (*handler)(int, void *);
-	int i, vector, q_vectors, err;
+	int i, vector, q_vectors, cpu, err;
 	int ri=0, ti=0;
+	u32 intr_flags = 0;
+	u32 num_cpus = num_online_cpus();
 
 	/* Decrement for Other and TCP Timer vectors */
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
@@ -1576,17 +1578,22 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	if (err)
 		goto out;
 
+	/* If Flow Director is enabled, we want to affinitize vectors */
+	if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
+	    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+		intr_flags = IRQF_NOBALANCING;
+
 #define SET_HANDLER(_v) ((!(_v)->rxr_count) ? &ixgbe_msix_clean_tx : \
                          (!(_v)->txr_count) ? &ixgbe_msix_clean_rx : \
                          &ixgbe_msix_clean_many)
-	for (vector = 0; vector < q_vectors; vector++) {
+	for (vector = 0, cpu = 0; vector < q_vectors; vector++) {
 		handler = SET_HANDLER(adapter->q_vector[vector]);
 
-		if(handler == &ixgbe_msix_clean_rx) {
+		if (handler == &ixgbe_msix_clean_rx) {
 			sprintf(adapter->name[vector], "%s-%s-%d",
 				netdev->name, "rx", ri++);
 		}
-		else if(handler == &ixgbe_msix_clean_tx) {
+		else if (handler == &ixgbe_msix_clean_tx) {
 			sprintf(adapter->name[vector], "%s-%s-%d",
 				netdev->name, "tx", ti++);
 		}
@@ -1595,7 +1602,8 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 				netdev->name, "TxRx", vector);
 
 		err = request_irq(adapter->msix_entries[vector].vector,
-		                  handler, 0, adapter->name[vector],
+		                  handler, intr_flags,
+		                  adapter->name[vector],
 		                  adapter->q_vector[vector]);
 		if (err) {
 			DPRINTK(PROBE, ERR,
@@ -1603,9 +1611,25 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 			        "Error: %d\n", err);
 			goto free_queue_irqs;
 		}
+		if (intr_flags) {
+			/*
+			 * We're not balancing the vector, so affinitize it.
+			 * Best default layout is try and assign one vector
+			 * per CPU.  If we have more vectors than online
+			 * CPUs, then try to first affinitize Rx, then lay
+			 * Tx over the same Rx CPU map.  This can always be
+			 * overridden using smp_affinity in /proc
+			 */
+
+			irq_set_affinity(adapter->msix_entries[vector].vector,
+			                 cpumask_of(cpu));
+			if (++cpu >= num_cpus)
+				cpu = 0;
+		}
 	}
 
 	sprintf(adapter->name[vector], "%s:lsc", netdev->name);
+	/* We don't care if this vector is irqbalanced or not */
 	err = request_irq(adapter->msix_entries[vector].vector,
 	                  &ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
 	if (err) {

