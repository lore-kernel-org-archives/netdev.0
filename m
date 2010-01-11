From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Mon, 11 Jan 2010 23:03:41 +0900
Message-ID: <4B4B2FBD.5090007@ring3k.org>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera> <omZ8aBZReyD.A.I-H.eNlSLB@chimera> <4B4A729E.9060805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	Jarek Poplawski <jarkao2@gmail.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "Berck E. Nash" <flyboy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:60427 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab0AKOHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 09:07:41 -0500
Received: by pzk26 with SMTP id 26so12241962pzk.4
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 06:07:40 -0800 (PST)
In-Reply-To: <4B4A729E.9060805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Berck E. Nash wrote:
> 
> During TX timeout procedure dev could be awoken too early, e.g. by
> sky2_complete_tx() called from sky2_down(). Then sky2_xmit_frame()
> can run while buffers are freed causing an oops. This patch fixes it
> by adding netif_device_present() test in sky2_tx_complete().
> 
> Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=14925
> 
> With debugging by: Mike McCormack <mikem@ring3k.org>
> 
> Reported-by: Berck E. Nash <flyboy@gmail.com>
> Tested-by: Berck E. Nash <flyboy@gmail.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> ---
> 
>  drivers/net/sky2.c |    3 ++-

Perhaps only sky2_tx_done should wake the queue?
Does the patch below fix the problem too?

thanks,

Mike



Subject: [PATCH] sky2: Don't wake queue in sky2_tx_complete()

We should only wake the tx queue on completion of
transmits, not after cleaning the tx ring.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 93d9635..6d9111d 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1843,9 +1843,6 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 
 	sky2->tx_cons = idx;
 	smp_mb();
-
-	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
-		netif_wake_queue(dev);
 }
 
 static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
@@ -2416,8 +2413,11 @@ static inline void sky2_tx_done(struct net_device *dev, u16 last)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (netif_running(dev))
+	if (netif_running(dev)) {
 		sky2_tx_complete(sky2, last);
+		if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
+			netif_wake_queue(dev);
+	}
 }
 
 static inline void sky2_skb_rx(const struct sky2_port *sky2,
-- 1.5.6.5 

