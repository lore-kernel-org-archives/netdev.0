From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/7] e1000e: Set InterruptThrottleRate to default when invalid
	value used
Date: Fri, 08 Aug 2008 18:35:51 -0700
Message-ID: <20080809013551.23913.68807.stgit@localhost.localdomain>
References: <20080809013544.23913.47157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7933 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752839AbYHIBfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 21:35:52 -0400
In-Reply-To: <20080809013544.23913.47157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

During module load, seting the InterruptThrottleRate parameter to an
invalid value would result in the itr/itr_setting pair being set to
unexpected values which would result in poor performance.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/param.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 8effc31..b0499f2 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -327,11 +327,26 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 				e1000_validate_option(&adapter->itr, &opt,
 					adapter);
 				/*
-				 * save the setting, because the dynamic bits
-				 * change itr. clear the lower two bits
-				 * because they are used as control
+				 * Save the setting, because the dynamic bits
+				 * change itr.
 				 */
-				adapter->itr_setting = adapter->itr & ~3;
+				if (e1000_validate_option(&adapter->itr, &opt,
+							  adapter) &&
+				    (adapter->itr == 3)) {
+					/*
+					 * In case of invalid user value,
+					 * default to conservative mode.
+					 */
+					adapter->itr_setting = adapter->itr;
+					adapter->itr = 20000;
+				} else {
+					/*
+					 * Clear the lower two bits because
+					 * they are used as control.
+					 */
+					adapter->itr_setting =
+						adapter->itr & ~3;
+				}
 				break;
 			}
 		} else {

