From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 22/25] wimax: wimax_msg_alloc() returns ERR_PTR not null
Date: Fri, 14 May 2010 14:45:21 -0700
Message-ID: <3e02a06ae3dce2eb804bb4afadb7067c80d6c096.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: Dan Carpenter <error27@gmail.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:17451 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932564Ab0ENVtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:21 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

wimax_msg_alloc() returns an ERR_PTR and not null.  I changed it to test
for ERR_PTR instead of null.  I also added a check in front of the
kfree() because kfree() can handle null but not ERR_PTR.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
 drivers/net/wimax/i2400m/rx.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 66f968a..0004c68 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -300,17 +300,16 @@ void i2400m_rx_ctl_ack(struct i2400m *i2400m,
 		d_printf(1, dev, "Huh? waiter for command reply cancelled\n");
 		goto error_waiter_cancelled;
 	}
-	if (ack_skb == NULL) {
+	if (IS_ERR(ack_skb))
 		dev_err(dev, "CMD/GET/SET ack: cannot allocate SKB\n");
-		i2400m->ack_skb = ERR_PTR(-ENOMEM);
-	} else
-		i2400m->ack_skb = ack_skb;
+	i2400m->ack_skb = ack_skb;
 	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 	complete(&i2400m->msg_completion);
 	return;
 
 error_waiter_cancelled:
-	kfree_skb(ack_skb);
+	if (!IS_ERR(ack_skb))
+		kfree_skb(ack_skb);
 error_no_waiter:
 	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 	return;
-- 
1.6.6.1

