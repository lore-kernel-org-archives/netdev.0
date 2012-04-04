From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v2] marvell sky2 driver: fix so it works without unaligned accesses
Date: Wed, 4 Apr 2012 10:13:32 -0400
Message-ID: <201204041419.q34EJ49H025297@farm-0012.internal.tilera.com>
References: <20120403.174610.2089715131687430500.davem@davemloft.net> <1333469916.18626.284.camel@edumazet-glaptop> <201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403.174610.2089715131687430500.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver uses a receive_new() routine that ends up requiring unaligned
accesses in IP header processing.  If the architecture doesn't support
efficient unaligned accesses, and SKY2_HW_RAM_BUFFER is set,
just copy all ingress packets to the bounce buffers instead.
Thanks to Eric Dumazet for pointing out the SKY2_HW_RAM_BUFFER issue.

This allows the driver to be used on the Tilera TILEmpower-Gx, since
the tile architecture doesn't currently handle kernel unaligned accesses,
just userspace.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/marvell/sky2.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 423a1a2..2bc6a78 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2598,7 +2598,11 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 		goto error;
 
 okay:
-	if (length < copybreak)
+	if ((length < copybreak)
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	    || (sky2->hw->flags & SKY2_HW_RAM_BUFFER)
+#endif
+	    )
 		skb = receive_copy(sky2, re, length);
 	else
 		skb = receive_new(sky2, re, length);
-- 
1.6.5.2
