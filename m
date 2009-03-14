From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 07/11] ixgbe: Cleanup on the Rx init path
Date: Sat, 14 Mar 2009 01:14:30 -0700
Message-ID: <20090314081430.4687.54482.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:33436
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754626AbZCNIOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:14:50 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This cleans up the following pieces of the Rx initialization path:

- Enable the ECC memory fault interrupt in OTHER causes.

- Fix an 82598 initialization of RDRXCTL when depending on RSS and VMDq to
be enabled.  We don't need these features enabled to safely set the MVMEN
bit to allow multiple SRRCTL register mappings into the RXDCTL registers.

- Fix the RSS initialization path to not stomp on DCB accidentally.  When
configuring the MRQC (multiple Rx queue contol) register, we want to make
sure we only OR in features as necessary, instead of full assignment.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c4e5fd3..78b0357 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1464,6 +1464,7 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		mask |= IXGBE_EIMS_GPI_SDP1;
 	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		mask |= IXGBE_EIMS_ECC;
 		mask |= IXGBE_EIMS_GPI_SDP1;
 		mask |= IXGBE_EIMS_GPI_SDP2;
 	}
@@ -1795,12 +1796,9 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		 * effects of setting this bit are only that SRRCTL must be
 		 * fully programmed [0..15]
 		 */
-		if (adapter->flags &
-		    (IXGBE_FLAG_RSS_ENABLED | IXGBE_FLAG_VMDQ_ENABLED)) {
-			rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
-			rdrxctl |= IXGBE_RDRXCTL_MVMEN;
-			IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
-		}
+		rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+		rdrxctl |= IXGBE_RDRXCTL_MVMEN;
+		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
 	}
 
 	/* Program MRQC for the distribution of queues */
@@ -1837,16 +1835,17 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		for (i = 0; i < 10; i++)
 			IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), seed[i]);
 
-		mrqc = IXGBE_MRQC_RSSEN
+		if (hw->mac.type == ixgbe_mac_82598EB)
+			mrqc |= IXGBE_MRQC_RSSEN;
 		    /* Perform hash on these packet types */
-		       | IXGBE_MRQC_RSS_FIELD_IPV4
-		       | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
-		       | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
-		       | IXGBE_MRQC_RSS_FIELD_IPV6
-		       | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
-		       | IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
-		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
-	}
+		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4
+		      | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
+		      | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
+		      | IXGBE_MRQC_RSS_FIELD_IPV6
+		      | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
+		      | IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
+	}
+	IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 
 	rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
 

