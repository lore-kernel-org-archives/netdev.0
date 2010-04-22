From: Dan Carpenter <error27@gmail.com>
Subject: [patch] wimax: wimax_msg_alloc() returns ERR_PTR not null
Date: Thu, 22 Apr 2010 11:46:32 +0200
Message-ID: <20100422094632.GM29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wimax@intel.com,
	=?iso-8859-1?Q?Andr=E9?= Goddard Rosa <andre.goddard@gmail.com>,
	wimax@linuxwimax.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:41565 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab0DVJqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 05:46:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wimax_msg_alloc() returns an ERR_PTR and not null.  I changed it to test
for ERR_PTR instead of null.  I also added a check in front of the
kfree() because kfree() can handle null but not ERR_PTR.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index fa2e11e..05e2247 100644
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
