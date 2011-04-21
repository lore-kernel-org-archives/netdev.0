From: Ben Gardiner <bengardiner@nanometrics.ca>
Subject: [PATCH] [RFC] davinci_emac: don't WARN_ON cpdma_chan_submit -ENOMEM
Date: Thu, 21 Apr 2011 13:30:32 -0400
Message-ID: <1303407032-7526-1-git-send-email-bengardiner@nanometrics.ca>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Sriramakrishnan A G <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:39572 "EHLO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755104Ab1DURah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 13:30:37 -0400
Received: by gxk21 with SMTP id 21so527882gxk.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 10:30:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation of emac_rx_handler, when the host is
flooded, will result in a great deal of WARNs on the console; due to
the return value of cpdma_chan_submit. This function can error with
EINVAL and ENOMEM; the former when the channel is in an invalid
state, in which case the caller is in error. The latter when a cpdma
descriptor cannot be allocated.

When flooded, cpdma_chan_submit will return -ENOMEM;
treat the inability to allocate a cpdma descriptor as an rx error
similar in behaviour to when emac_rx_alloc returns NULL.

No Signed-off-by yet; not complete fix (see below).
CC: Sriramakrishnan A G <srk@ti.com>

---
I'm new to network drivers -- and kernel development, really. I'd be
happy to receive feedback on this approach of resolving the -ENOMEM
when flooded. Is there a more conventional approach? Shoud these frames
be recorded as 'dropped'?

Testing was performed on da850evm both with and without  "net:
davinci_emac: fix spinlock bug with dma channel cleanup" from
Sriramakrishnan A G applied. The behaviour was the same: the emac is
not able to receive any frames after being flooded -- but it can still
send. I would appreciate any insight into the potential causes of the
lockup.

Best Regards,
Ben Gardiner

Nanometrics Inc.
http://www.nanometrics.ca

---
 drivers/net/davinci_emac.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 7018bfe..17c48d6 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1037,8 +1037,12 @@ static void emac_rx_handler(void *token, int len, int status)
 recycle:
 	ret = cpdma_chan_submit(priv->rxchan, skb, skb->data,
 			skb_tailroom(skb), GFP_KERNEL);
-	if (WARN_ON(ret < 0))
+	WARN_ON(ret == -EINVAL);
+	if (ret < 0) {
+		if (netif_msg_rx_err(priv) && net_ratelimit())
+			dev_err(emac_dev, "failed cpdma submit\n");
 		dev_kfree_skb_any(skb);
+	}
 }
 
 static void emac_tx_handler(void *token, int len, int status)
-- 
1.7.1

