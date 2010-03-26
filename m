From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Do not run all Diagnostic offline tests when
	VFs are active
Date: Thu, 25 Mar 2010 20:06:48 -0700
Message-ID: <20100326030647.10085.16720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:49062
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753859Ab0CZDHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 23:07:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When running the offline diagnostic tests check to see if any VFs are
online.  If so then only run the link test.  This is necessary because
the VFs running in guest VMs aren't aware of when the PF is taken
offline for a diagnostic test.  Also put a message to the system log
telling the system administrator to take the VFs offline manually if
(s)he wants to run a full diagnostic.  Return 1 on each of the tests
not run to alert the user of the condition.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 7949a44..1959ef7 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1853,6 +1853,26 @@ static void ixgbe_diag_test(struct net_device *netdev,
 		if (ixgbe_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
+		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+			int i;
+			for (i = 0; i < adapter->num_vfs; i++) {
+				if (adapter->vfinfo[i].clear_to_send) {
+					netdev_warn(netdev, "%s",
+						    "offline diagnostic is not "
+						    "supported when VFs are "
+						    "present\n");
+					data[0] = 1;
+					data[1] = 1;
+					data[2] = 1;
+					data[3] = 1;
+					eth_test->flags |= ETH_TEST_FL_FAILED;
+					clear_bit(__IXGBE_TESTING,
+						  &adapter->state);
+					goto skip_ol_tests;
+				}
+			}
+		}
+
 		if (if_running)
 			/* indicate we're in test mode */
 			dev_close(netdev);
@@ -1908,6 +1928,7 @@ skip_loopback:
 
 		clear_bit(__IXGBE_TESTING, &adapter->state);
 	}
+skip_ol_tests:
 	msleep_interruptible(4 * 1000);
 }
 

