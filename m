From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35] wimax/i2400m: fix bad race condition check in RX path
Date: Tue, 25 May 2010 10:45:13 -0700
Message-ID: <3a24934f065d23145f1c9c70da9f630c7a37795f.1274809476.git.inaky.perez-gonzalez@intel.com>
References: <cover.1274809476.git.inaky.perez-gonzalez@intel.com>
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:26854 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754710Ab0EYRsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 13:48:55 -0400
In-Reply-To: <cover.1274809476.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

The i2400m->rx_roq data structure is protected against race conditions
with a reference count (i2400m->rx_roq_refcount); the pointer can be
read-referenced under the i2400m->rx_lock spinlock.

The code in i2400m_rx_edata() wasn't properly following access
protocol, performing an invalid check on i2400m->rx_roq (which is
cleared to NULL when the refcount drops to zero). As such, it was
missing to detect when the data structure is no longer valid and
oopsing with a NULL pointer dereference.

This commit fixes said check by verifying, under the rx_lock spinlock,
that i2400m->rx_roq is non-NULL and then increasing the reference
count before dropping the spinlock.

Signed-off-by: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
---
 drivers/net/wimax/i2400m/rx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index c835ae8..6cd12d6 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -1033,12 +1033,12 @@ void i2400m_rx_edata(struct i2400m *i2400m, struct sk_buff *skb_rx,
 		ro_sn = (reorder >> I2400M_RO_SN_SHIFT) & I2400M_RO_SN;
 
 		spin_lock_irqsave(&i2400m->rx_lock, flags);
-		roq = &i2400m->rx_roq[ro_cin];
-		if (roq == NULL) {
+		if (i2400m->rx_roq == NULL) {
 			kfree_skb(skb);	/* rx_roq is already destroyed */
 			spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 			goto error;
 		}
+		roq = &i2400m->rx_roq[ro_cin];
 		kref_get(&i2400m->rx_roq_refcount);
 		spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 
-- 
1.6.6.1

