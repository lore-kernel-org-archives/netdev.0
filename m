From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: Fix return of invalid txq
Date: Wed, 03 Feb 2010 15:13:10 -0800
Message-ID: <20100203231309.15352.12337.stgit@localhost.localdomain>
References: <20100203231224.15352.27988.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:41558 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757614Ab0BCXNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 18:13:32 -0500
In-Reply-To: <20100203231224.15352.27988.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

a developer had complained of getting lots of warnings:

"eth16 selects TX queue 98, but real number of TX queues is 64"

http://www.mail-archive.com/e1000-devel@lists.sourceforge.net/msg02200.html

As there was no follow up on that bug, I am submitting this
patch assuming that the other return points will not return
invalid txq's, and also that this fixes the bug (not tested).

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 37e2af0..7b7c848 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5329,8 +5329,11 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	int txq = smp_processor_id();
 
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
+		while (unlikely(txq >= dev->real_num_tx_queues))
+			txq -= dev->real_num_tx_queues;
 		return txq;
+	}
 
 #ifdef IXGBE_FCOE
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&

