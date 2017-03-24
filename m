From: greearb@candelatech.com
Subject: [PATCH] igb:  add module param to set max-rss-queues.
Date: Fri, 24 Mar 2017 13:58:47 -0700
Message-ID: <1490389127-23171-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:58520 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936085AbdCXU6z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:58:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

In systems where you may have a very large number of network
adapters, certain drivers may consume an unfair amount of
IRQ resources.  So, allow a module param that will limit the
number of IRQs at driver load time.  This way, other drivers
(40G Ethernet, for instance), which probably will need the
multiple IRQs more, will not be starved of IRQ resources.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index f9f2874..fdb12e0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -218,6 +218,10 @@ module_param(max_vfs, uint, 0);
 MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate per physical function");
 #endif /* CONFIG_PCI_IOV */
 
+static unsigned int max_rss_qs;
+module_param(max_rss_qs, uint, 0);
+MODULE_PARM_DESC(max_rss_qs, "Maximum number of RSS queues.  Forcing lower will use less IRQ resources.");
+
 static pci_ers_result_t igb_io_error_detected(struct pci_dev *,
 		     pci_channel_state_t);
 static pci_ers_result_t igb_io_slot_reset(struct pci_dev *);
@@ -2993,6 +2997,9 @@ static void igb_init_queue_configuration(struct igb_adapter *adapter)
 		break;
 	}
 
+	if (max_rss_qs && max_rss_qs < max_rss_queues)
+		max_rss_queues = max_rss_qs;
+
 	adapter->rss_queues = min_t(u32, max_rss_queues, num_online_cpus());
 
 	igb_set_flag_queue_pairs(adapter, max_rss_queues);
-- 
2.4.11
