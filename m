From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 08/13] e1000: remove races when changing mtu
Date: Fri, 25 Sep 2009 15:19:02 -0700
Message-ID: <20090925221901.26715.21741.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:40913
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753019AbZIYWTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:19:18 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

this patch fixes a bug that occurs when routing packets and simultaneously
changing the mtu.  the rx_buffer_len variable is used during the rx cleanup
and if that changes on the fly without stopping traffic bad things happen

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cdbf4fb..2178e0d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3141,6 +3141,13 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		break;
 	}
 
+	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
+		msleep(1);
+	/* e1000_down has a dependency on max_frame_size */
+	hw->max_frame_size = max_frame;
+	if (netif_running(netdev))
+		e1000_down(adapter);
+
 	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
 	 * larger slab size.
@@ -3169,11 +3176,16 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE)))
 		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 
+	printk(KERN_INFO "e1000: %s changing MTU from %d to %d\n",
+	       netdev->name, netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
-	hw->max_frame_size = max_frame;
 
 	if (netif_running(netdev))
-		e1000_reinit_locked(adapter);
+		e1000_up(adapter);
+	else
+		e1000_reset(adapter);
+
+	clear_bit(__E1000_RESETTING, &adapter->flags);
 
 	return 0;
 }

