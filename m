From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] e1000: Do not overestimate descriptor counts in Tx pre-check
Date: Tue,  5 Apr 2016 15:30:50 -0700
Message-ID: <1459895451-45300-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459895451-45300-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:46171 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933819AbcDEWay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 18:30:54 -0400
In-Reply-To: <1459895451-45300-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The current code path is capable of grossly overestimating the number of
descriptors needed to transmit a new frame.  This specifically occurs if
the skb contains a number of 4K pages.  The issue is that the logic for
determining the descriptors needed is ((S) >> (X)) + 1.  When X is 12 it
means that we were indicating that we required 2 descriptors for each 4K
page when we only needed one.

This change corrects this by instead adding (1 << (X)) - 1 to the S value
instead of adding 1 after the fact.  This way we get an accurate descriptor
needed count as we are essentially doing a DIV_ROUNDUP().

Reported-by: Ivan Suzdal <isuzdal@mirantis.com>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 3fc7bde..d213fb4 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3106,7 +3106,7 @@ static int e1000_maybe_stop_tx(struct net_device *netdev,
 	return __e1000_maybe_stop_tx(netdev, size);
 }
 
-#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1)
+#define TXD_USE_COUNT(S, X) (((S) + ((1 << (X)) - 1)) >> (X))
 static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    struct net_device *netdev)
 {
-- 
2.5.5
