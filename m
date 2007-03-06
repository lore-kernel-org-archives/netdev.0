From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/3] e1000: FIX: Stop raw interrupts disabled nag from RT
Date: Tue, 06 Mar 2007 08:57:26 -0800
Message-ID: <20070306165726.27434.54353.stgit@localhost.localdomain>
References: <20070306165721.27434.23796.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965951AbXCFQ5i@vger.kernel.org>
In-Reply-To: <20070306165721.27434.23796.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Huth <mhuth@mvista.com>

Current e1000_xmit_frame spews raw interrupt disabled nag messages when
used with RT kernel patches.  This patch uses spin_trylock_irqsave,
which allows RT patches to properly manage the irq semantics.

Signed-off-by: Mark Huth <mhuth@mvista.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 3492f0b..7bbefca 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3378,12 +3378,9 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	    (adapter->hw.mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	local_irq_save(flags);
-	if (!spin_trylock(&tx_ring->tx_lock)) {
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
 		/* Collision - tell upper layer to requeue */
-		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
-	}
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
