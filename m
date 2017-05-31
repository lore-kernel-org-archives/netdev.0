From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] ixgbevf: Resolve truncation warning for q_vector->name
Date: Wed, 31 May 2017 14:19:30 -0700
Message-ID: <20170531211936.63417-10-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38747 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751129AbdEaVTv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:51 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

The following warning is now shown as a result of new checks added for
gcc 7:

drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c: In function ‘ixgbevf_open’:
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:1363:13: warning: ‘%d’ directive output may be truncated writing between 1 and 10 bytes into a region of size between 3 and 18 [-Wformat-truncation=]
      "%s-%s-%d", netdev->name, "TxRx", ri++);
             ^~
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:1363:6: note: directive argument in the range [0, 2147483647]
      "%s-%s-%d", netdev->name, "TxRx", ri++);
      ^~~~~~~~~~
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:1362:4: note: ‘snprintf’ output between 8 and 32 bytes into a destination of size 24
    snprintf(q_vector->name, sizeof(q_vector->name) - 1,
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      "%s-%s-%d", netdev->name, "TxRx", ri++);
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Resolve this warning by making a couple of changes.
 - Don't reserve space for the null terminator.  Since snprintf adds the
   null terminator automatically, there is no need for us to reserve a byte
   for it.

 - Change a couple variables that can never be negative from int to
   unsigned int.

While we're making changes to the format string, move the constant strings
into the format string instead of providing them as specifiers.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 706d868a778d..aced91c9c034 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1351,23 +1351,23 @@ static int ixgbevf_request_msix_irqs(struct ixgbevf_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+	unsigned int ri = 0, ti = 0;
 	int vector, err;
-	int ri = 0, ti = 0;
 
 	for (vector = 0; vector < q_vectors; vector++) {
 		struct ixgbevf_q_vector *q_vector = adapter->q_vector[vector];
 		struct msix_entry *entry = &adapter->msix_entries[vector];
 
 		if (q_vector->tx.ring && q_vector->rx.ring) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				 "%s-%s-%d", netdev->name, "TxRx", ri++);
+			snprintf(q_vector->name, sizeof(q_vector->name),
+				 "%s-TxRx-%u", netdev->name, ri++);
 			ti++;
 		} else if (q_vector->rx.ring) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				 "%s-%s-%d", netdev->name, "rx", ri++);
+			snprintf(q_vector->name, sizeof(q_vector->name),
+				 "%s-rx-%u", netdev->name, ri++);
 		} else if (q_vector->tx.ring) {
-			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-				 "%s-%s-%d", netdev->name, "tx", ti++);
+			snprintf(q_vector->name, sizeof(q_vector->name),
+				 "%s-tx-%u", netdev->name, ti++);
 		} else {
 			/* skip this unused q_vector */
 			continue;
-- 
2.12.2
