From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40evf: fix mac filter removal timing issue
Date: Mon,  9 Oct 2017 15:38:30 -0700
Message-ID: <20171009223841.2557-4-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36088 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755252AbdJIWjF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:05 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Due to the asynchronous nature in which mac filters are added and
deleted, there exists a bug in which filters are erroneously removed if
removed then added again quickly.

The events are as such:
    - filter marked for removal
    - same filter is re-added before watchdog that cleans up filters
    - we skip re-adding the filter because we have it already in the
list
    - watchdog filter cleanup kicks off and filter is removed

So when we were re-adding the same filter, it didn't actually get added
because it already existed in the list, but was marked for removal and
had yet to actually be removed.

This patch fixes the issue by making sure that when adding a filter, if
we find it already existing in our list, make sure it is not marked to
be removed.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1d2fc898b664..f62d9565c7b5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -880,6 +880,8 @@ i40evf_mac_filter *i40evf_add_filter(struct i40evf_adapter *adapter,
 		list_add_tail(&f->list, &adapter->mac_filter_list);
 		f->add = true;
 		adapter->aq_required |= I40EVF_FLAG_AQ_ADD_MAC_FILTER;
+	} else {
+		f->remove = false;
 	}
 
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
-- 
2.14.2
