From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 16:21:42 +0200
Message-ID: <986d76a0-0972-c99d-b87b-ca6924ec03c0@sigmadesigns.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Daney <ddaney.cavm@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:59636 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751205AbdHaOVs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 10:21:48 -0400
In-Reply-To: <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/2017 14:29, Marc Gonzalez wrote:

> On 31/08/2017 02:49, Florian Fainelli wrote:
> 
>> The original motivation for this change originated from Marc Gonzalez
>> indicating that his network driver did not have its adjust_link callback
>> executing with phydev->link = 0 while he was expecting it.
> 
> I expect the core to call phy_adjust_link() for link changes.
> This used to work back in 3.4 and was broken somewhere along
> the way.
> 
>> PHYLIB has never made any such guarantees ever because phy_stop() merely
>> just tells the workqueue to move into PHY_HALTED state which will happen
>> asynchronously.
> 
> My original proposal was to fix the issue in the driver.
> I'll try locating it in my archives.

The original proposal was:
(I.e. basically a copy of phy_state_machine()'s PHY_HALTED case)
Is this what I need to submit, now that the synchronous call to
phy_state_machine() has been removed?

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 607064a6d7a1..8b9a981c55c1 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1017,6 +1017,10 @@ static int nb8800_stop(struct net_device *dev)
 
        phy_disconnect(phydev);
 
+       phydev->link = 0;
+       netif_carrier_off(dev);
+       nb8800_link_reconfigure(dev);
+
        free_irq(dev->irq, dev);
 
        nb8800_dma_free(dev);
