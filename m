From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40evf: don't go further down
Date: Wed, 11 Jun 2014 09:33:15 -0700
Message-ID: <1402504404-8954-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55591 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932520AbaFKQda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:30 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the device is down, there's no place to go but up, so don't try to go
down even more. This prevents a CPU soft lock in napi_disable().

Change-ID: I8b058b9ee974dfa01c212fae2597f4f54b333314
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d415785..f454b58 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -968,6 +968,9 @@ void i40evf_down(struct i40evf_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct i40evf_mac_filter *f;
 
+	if (adapter->state == __I40EVF_DOWN)
+		return;
+
 	/* remove all MAC filters */
 	list_for_each_entry(f, &adapter->mac_filter_list, list) {
 		f->remove = true;
@@ -1785,12 +1788,11 @@ static int i40evf_close(struct net_device *netdev)
 	if (adapter->state <= __I40EVF_DOWN)
 		return 0;
 
-	/* signal that we are down to the interrupt handler */
-	adapter->state = __I40EVF_DOWN;
 
 	set_bit(__I40E_DOWN, &adapter->vsi.state);
 
 	i40evf_down(adapter);
+	adapter->state = __I40EVF_DOWN;
 	i40evf_free_traffic_irqs(adapter);
 
 	i40evf_free_all_tx_resources(adapter);
-- 
1.9.3
