From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 03/26] igb: move initialization of number of queues
	into set_interrupt_capability
Date: Sat, 07 Feb 2009 01:15:45 -0800
Message-ID: <20090207091544.15697.99817.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:43103 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751980AbZBGJQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:16:05 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch moves the initialization of the number of queues into
set_interrupt_capability.  This allows the number of queues to increase in
the unlikely event that the system initially fails to allocate enough msi-x
interrupts, does a suspend/resume, and then can allocate enough interrupts
on resume.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ec5855a..6ef0adb 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -543,6 +543,11 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 	int err;
 	int numvecs, i;
 
+	/* Number of supported queues. */
+	/* Having more queues than CPUs doesn't make sense. */
+	adapter->num_rx_queues = min_t(u32, IGB_MAX_RX_QUEUES, num_online_cpus());
+	adapter->num_tx_queues = min_t(u32, IGB_MAX_TX_QUEUES, num_online_cpus());
+
 	numvecs = adapter->num_tx_queues + adapter->num_rx_queues + 1;
 	adapter->msix_entries = kcalloc(numvecs, sizeof(struct msix_entry),
 					GFP_KERNEL);
@@ -1450,11 +1455,6 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
-	/* Number of supported queues. */
-	/* Having more queues than CPUs doesn't make sense. */
-	adapter->num_rx_queues = min_t(u32, IGB_MAX_RX_QUEUES, num_online_cpus());
-	adapter->num_tx_queues = min_t(u32, IGB_MAX_TX_QUEUES, num_online_cpus());
-
 	/* This call may decrease the number of queues depending on
 	 * interrupt mode. */
 	igb_set_interrupt_capability(adapter);

