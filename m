From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Fix link down message when interface is brought up
Date: Fri, 29 Sep 2017 17:44:55 -0700
Message-ID: <20170930004507.20072-4-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23279 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752571AbdI3Aps (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:48 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>

i40e_print_link_message() is intended to compare new
link state with current link state and print log message
only if the new state is different from current state.

However in current driver the new state does not get updated
when link is going down because of the if condition. When an
interface is brought down, vsi->state is set to I40E_VSI_DOWN
in i40e_vsi_close() and later i40e_print_link_message() does
not get invoked in i40e_link_event due to if condition. Hence
link down message doesn't appear when link is going down. The
down state is seen  later during i40e_open() and old state
gets printed. The actual link state doesn't get updated in
i40e_close() or i40e_open() but when i40e_handle_link_event is
called inside i40e_clean_adminq_subtask.

This change allows i40e_print_link_message() to be called when
interface is going down and keeps the state information updated.

Signed-off-by: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b235a27232a8..2e8fe6186b38 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6420,8 +6420,7 @@ static void i40e_link_event(struct i40e_pf *pf)
 	     new_link == netif_carrier_ok(vsi->netdev)))
 		return;
 
-	if (!test_bit(__I40E_VSI_DOWN, vsi->state))
-		i40e_print_link_message(vsi, new_link);
+	i40e_print_link_message(vsi, new_link);
 
 	/* Notify the base of the switch tree connected to
 	 * the link.  Floating VEBs are not notified.
-- 
2.14.1
