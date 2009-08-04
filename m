From: Mike McCormack <mikem@ring3k.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 04 Aug 2009 20:18:36 +0900
Message-ID: <4A78190C.1080909@ring3k.org>
References: <4A65EC3F.4050400@gibraltar.at> <20090723102848.00a56ad1@nehalam>	 <4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam>	 <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>	 <4A77E56B.9030804@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:36530 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbZHDLV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 07:21:29 -0400
Received: by rv-out-0506.google.com with SMTP id f6so1214426rvb.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 04:21:30 -0700 (PDT)
In-Reply-To: <4A77E56B.9030804@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


2009/8/4 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:

> Does anybody have an idea on what might be wrong in sky2_down?

I had a look into this, and noticed that we don't hold phy_lock when calling 
sky2_phy_power_down() in sky2_down(). sky2_phy_power_down() does some PCI
manipulation, so it's possible this could cause bad things to happen...

Does the following patch help?

Mike



Subject: [PATCH] sky2: Hold phy_lock when powering down phy

Make sure to hold phy_lock when calling sky2_phy_power_down(),
 as is done when calling sky2_phy_power_up(),

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index e9cb1e7..47e5bae 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1894,7 +1894,9 @@ static int sky2_down(struct net_device *dev)
        synchronize_irq(hw->pdev->irq);
        napi_synchronize(&hw->napi);
 
+       spin_lock_bh(&sky2->phy_lock);
        sky2_phy_power_down(hw, port);
+       spin_unlock_bh(&sky2->phy_lock);
 
        /* turn off LED's */
        sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
-- 
1.5.6.5
