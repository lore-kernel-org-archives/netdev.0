From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 14:29:36 +0200
Message-ID: <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:46345 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751715AbdHaM3m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 08:29:42 -0400
In-Reply-To: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/2017 02:49, Florian Fainelli wrote:

> This reverts commit 7ad813f208533cebfcc32d3d7474dc1677d1b09a ("net: phy:
> Correctly process PHY_HALTED in phy_stop_machine()") because it is
> creating the possibility for a NULL pointer dereference.
> 
> David Daney provide the following call trace and diagram of events:
> 
> When ndo_stop() is called we call:
> 
>  phy_disconnect()
>     +---> phy_stop_interrupts() implies: phydev->irq = PHY_POLL;

What does this mean?

On the contrary, phy_stop_interrupts() is only called when *not* polling.

	if (phydev->irq > 0)
		phy_stop_interrupts(phydev);

>     +---> phy_stop_machine()
>     |      +---> phy_state_machine()
>     |              +----> queue_delayed_work(): Work queued.

You're referring to the fact that, at the end of phy_state_machine()
(in polling mode) the code reschedules itself through:

	if (phydev->irq == PHY_POLL)
		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, PHY_STATE_TIME * HZ);

>     +--->phy_detach() implies: phydev->attached_dev = NULL;
> 
> Now at a later time the queued work does:
> 
>  phy_state_machine()
>     +---->netif_carrier_off(phydev->attached_dev): Oh no! It is NULL:

I tested a sequence of 500 link up / link down in polling mode,
and saw no such issue. Race condition?

For what case in phy_state_machine() is netif_carrier_off()
being called? Surely not PHY_HALTED?


> The original motivation for this change originated from Marc Gonzales
> indicating that his network driver did not have its adjust_link callback
> executing with phydev->link = 0 while he was expecting it.

I expect the core to call phy_adjust_link() for link changes.
This used to work back in 3.4 and was broken somewhere along
the way.

> PHYLIB has never made any such guarantees ever because phy_stop() merely
> just tells the workqueue to move into PHY_HALTED state which will happen
> asynchronously.

My original proposal was to fix the issue in the driver.
I'll try locating it in my archives.

Regards.
