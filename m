From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/16] i40evf: don't delete all the filters
Date: Tue, 14 Jul 2015 18:30:36 -0700
Message-ID: <1436923840-24455-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22319 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627AbbGOBas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 21:30:48 -0400
In-Reply-To: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Due to an inverted conditional, the driver was marking all of its MAC
filters for deletion every time set_rx_mode was called. Depending upon
the timing of the calls to set_rx_mode and the processing of the admin
queue, the driver would (accidentally) end up with a varying number of
functional filters.

Correct this logic so that MAC filters are added and removed correctly.
Add a check for the driver's "hardware" MAC address so that this filter
doesn't get removed incorrectly.

Change-ID: Ib3e7c4a5b53df6835f164fe44cb778cb71f8aff8
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
v2: fix indentation based on feedback from Sergei Shtylyov

 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 94eff4a..1c2ee97 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -892,8 +892,10 @@ static void i40evf_set_rx_mode(struct net_device *netdev)
 					break;
 				}
 			}
+			if (ether_addr_equal(f->macaddr, adapter->hw.mac.addr))
+				found = true;
 		}
-		if (found) {
+		if (!found) {
 			f->remove = true;
 			adapter->aq_required |= I40EVF_FLAG_AQ_DEL_MAC_FILTER;
 		}
-- 
2.4.3
