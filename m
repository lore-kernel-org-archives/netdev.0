From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: always use adapter->itr as EITR value
Date: Thu, 23 Apr 2009 14:20:29 -0700
Message-ID: <20090423212029.29591.16562.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:52094 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553AbZDWVUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 17:20:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb driver was switching between adapter->itr containing the EITR value
and the number of interrupts per second.  This resulted in high latencies
being seen after brining the interface down and then back up.  To resolve
the issue the itr value will now only contain the value that should be
programmed into EITR.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 183235d..ab846ec 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2898,13 +2898,13 @@ static void igb_set_itr(struct igb_adapter *adapter)
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
 	case lowest_latency:
-		new_itr = 70000;
+		new_itr = 56;  /* aka 70,000 ints/sec */
 		break;
 	case low_latency:
-		new_itr = 20000; /* aka hwitr = ~200 */
+		new_itr = 196; /* aka 20,000 ints/sec */
 		break;
 	case bulk_latency:
-		new_itr = 4000;
+		new_itr = 980; /* aka 4,000 ints/sec */
 		break;
 	default:
 		break;
@@ -2923,7 +2923,8 @@ set_itr_now:
 		 * by adding intermediate steps when interrupt rate is
 		 * increasing */
 		new_itr = new_itr > adapter->itr ?
-			     min(adapter->itr + (new_itr >> 2), new_itr) :
+			     max((new_itr * adapter->itr) /
+			         (new_itr + (adapter->itr >> 2)), new_itr) :
 			     new_itr;
 		/* Don't write the value here; it resets the adapter's
 		 * internal timer, and causes us to delay far longer than
@@ -2932,7 +2933,7 @@ set_itr_now:
 		 * ends up being correct.
 		 */
 		adapter->itr = new_itr;
-		adapter->rx_ring->itr_val = 1000000000 / (new_itr * 256);
+		adapter->rx_ring->itr_val = new_itr;
 		adapter->rx_ring->set_itr = 1;
 	}
 

