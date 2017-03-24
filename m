From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] i40e: make use of hlist_for_each_entry_continue
Date: Thu, 23 Mar 2017 22:14:32 -0700
Message-ID: <20170324051432.79216-11-jeffrey.t.kirsher@intel.com>
References: <20170324051432.79216-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:12130 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751406AbdCXFOo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 01:14:44 -0400
In-Reply-To: <20170324051432.79216-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Replace a complex if->continue->else->break construction in
i40e_next_filter. We can simply use hlist_for_each_entry_continue
instead. This drops a lot of confusing code. The resulting code is much
easier to understand the intention, and follows the more normal pattern
for using hlist loops. We could have also used a break with a "return
next" at the end of the function, instead of return NULL, but the
current implementation is explicitly clear that when you reach the end
of the loop you get a NULL value. The alternative construction is less
clear since the reader would have to know that next is NULL at the end
of the loop.

Change-Id: Ife74ca451dd79d7f0d93c672bd42092d324d4a03
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 114481b67ad8..1d8febd721ac 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1883,19 +1883,12 @@ static void i40e_undo_add_filter_entries(struct i40e_vsi *vsi,
 static
 struct i40e_new_mac_filter *i40e_next_filter(struct i40e_new_mac_filter *next)
 {
-	while (next) {
-		next = hlist_entry(next->hlist.next,
-				   typeof(struct i40e_new_mac_filter),
-				   hlist);
-
-		/* keep going if we found a broadcast filter */
-		if (next && is_broadcast_ether_addr(next->f->macaddr))
-			continue;
-
-		break;
+	hlist_for_each_entry_continue(next, hlist) {
+		if (!is_broadcast_ether_addr(next->f->macaddr))
+			return next;
 	}
 
-	return next;
+	return NULL;
 }
 
 /**
-- 
2.12.0
