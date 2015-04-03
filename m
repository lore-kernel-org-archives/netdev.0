From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mvneta: implement SGMII-based in-band link state
 signaling
Date: Fri, 03 Apr 2015 15:04:10 -0400 (EDT)
Message-ID: <20150403.150410.1238626255318297531.davem@davemloft.net>
References: <551AA02B.2050104@list.ru>
	<20150402.205131.1699226515102250937.davem@davemloft.net>
	<551DE6F9.9020903@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stsp@list.ru, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	thomas.petazzoni@free-electrons.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbDCTEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 15:04:12 -0400
In-Reply-To: <551DE6F9.9020903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 02 Apr 2015 18:03:53 -0700

> On 02/04/15 17:51, David Miller wrote:
>> From: Stas Sergeev <stsp@list.ru>
>> Date: Tue, 31 Mar 2015 16:24:59 +0300
>> 
>>> @@ -2590,6 +2651,7 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)
>>>
>>>  static void mvneta_mdio_remove(struct mvneta_port *pp)
>>>  {
>>> +	fixed_phy_set_link_update(pp->phy_dev, NULL);
>> 
>> I do not see any other driver doing this on shutdown.
>> Please show me why it is necessary.
> 
> The primary reason is that if you do not do that, past the point where
> you call phy_disconnect(), we stop the PHY state machine, detach from
> the net_device, such that it won't invoke the adjust_link callback
> anymore. The fixed PHY driver, though will still keep calling the
> fixed_link_update callback asking the driver whether the link parameters
> need to be updated, and that will just cause a NULL pointer de-reference
> phydev->attached_dev, since we are now in detached state.
> 
> I guess another way to fix that is to look for the PHY state in
> fixed_mdio_read() and do nothing if it is PHY_HALTED.

Ok I'll apply this mvneta patch to net-next then, thanks.

>> And if it is, all other drivers registering a fixed phy link update
>> function need to be adjusted to do the same thing.
> 
> I think the bcmgenet driver is now doing this as a result of Petri's
> latest changes, and I meant to comment on that before the patch got in.
> drivers/net/dsa/bcm_sf2.c has a similar construct but does not invoke
> phy_disconnect() nor can be rmmod'd, so a lesser issue.

I just seems insane to me that phy_disconnect() doesn't stop the
callbacks from running.

Fixed PHY seems to me to suffer from a lack of proper integration
into the PHY layer.
