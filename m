From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Fri, 1 Jan 2010 19:31:55 +0100
Message-ID: <20100101183155.GA8519@del.dom.local>
References: <4B3C8323.1080301@ring3k.org>
 <4B3CF2C4.5070203@gmail.com>
 <4B3D38FB.40105@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	flyboy@gmail.com, dhazelton@enter.net, mbreuer@majjas.com
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:43273 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab0AAScI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jan 2010 13:32:08 -0500
Received: by fxm25 with SMTP id 25so7314889fxm.21
        for <netdev@vger.kernel.org>; Fri, 01 Jan 2010 10:32:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B3D38FB.40105@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 01, 2010 at 08:51:23AM +0900, Mike McCormack wrote:
> Another way to solve the problem would be to take the transmit lock in 
> netif_device_detach() to make sure that any in progress transmits have
> completed before returning.

Yes, it seems this lock might be needed around this place, but I'd
like to check another idea: if it's not about awakening too early.
Berck, could you try this patch?

Thanks,
Jarek P.
---

 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 1c01b96..31f1629 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1844,7 +1844,7 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 	sky2->tx_cons = idx;
 	smp_mb();
 
-	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
+	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4 && netif_device_present(dev))
 		netif_wake_queue(dev);
 }
 
