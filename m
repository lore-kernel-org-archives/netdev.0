From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] e1000e: stop unnecessary polling when using msi-x
Date: Thu, 18 Jun 2009 17:57:37 -0400
Message-ID: <20090618215737.GF8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org
To: netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58574 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134AbZFRV63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 17:58:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The last hunk of this commit:

    commit 12d04a3c12b420f23398b4d650127642469a60a6
    Author: Alexander Duyck <alexander.h.duyck@intel.com>
    Date:   Wed Mar 25 22:05:03 2009 +0000

        e1000e: commonize tx cleanup routine to match e1000 & igb

changed the logic for determining if we should call napi_complete or
not at then end of a napi poll.

If the NIC is using MSI-X with no work to do in ->poll, net_rx_action
can just spin indefinitely on older kernels and for 2 jiffies on newer
kernels since napi_complete is never called and budget isn't
decremented.

Discovered and verified while testing driver backport to an older
kernel.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---

 netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 677f604..679885a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1997,7 +1997,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *poll_dev = adapter->netdev;
-	int tx_cleaned = 0, work_done = 0;
+	int tx_cleaned = 1, work_done = 0;
 
 	adapter = netdev_priv(poll_dev);


