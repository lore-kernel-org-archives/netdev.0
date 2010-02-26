From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ixgbe: do not stop tx queues in ixgbe_set_tso
Date: Fri, 26 Feb 2010 01:14:58 -0800
Message-ID: <20100226091456.19796.53149.stgit@localhost.localdomain>
References: <20100226091318.19796.70225.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:58535
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935633Ab0BZJPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:15:19 -0500
In-Reply-To: <20100226091318.19796.70225.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Disabling TSO can cause the dev_watchdog timer to be triggered because
when TSO is disabled netif_tx_stop_all_queues is called.  If the watchdog
timer fires while the queues are stopped and traffic has not recently been
sent on a paticular queue this is falsly identified as a hang and
ndo_tx_timeout() is called.  This is ocossionally seen during testing.

This removes the netif_tx_stop_all_queues() it is not needed.  The scheduler
submits skb's with dev_hard_start_xmit(), this checks if netif_needs_gso and
if so it calls dev_gso_segment.  Disabling TSO will cause dev_hard_start_xmit()
to do the gso processing.   However ixgbe does not use the features flags to
determine if it needs to use tso or not instead it uses skb->gso_size so
ixgbe will process these frames correctly regardless of the netdev features
flag.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 0d23434..7949a44 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -441,10 +441,8 @@ static int ixgbe_set_tso(struct net_device *netdev, u32 data)
 		netdev->features |= NETIF_F_TSO;
 		netdev->features |= NETIF_F_TSO6;
 	} else {
-		netif_tx_stop_all_queues(netdev);
 		netdev->features &= ~NETIF_F_TSO;
 		netdev->features &= ~NETIF_F_TSO6;
-		netif_tx_start_all_queues(netdev);
 	}
 	return 0;
 }

