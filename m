From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next] dsa: slave: support phy devices on external MII bus
Date: Wed, 18 Oct 2017 11:54:40 -0700
Message-ID: <3b972ab8-3d3e-7666-5c26-f111f5cdd61a@gmail.com>
References: <20171018162138.GA15371@lunn.ch>
 <ad992ed8-37b8-9c52-848c-78fa0368de8f@gmail.com>
 <8994adaa-6223-20f1-9221-49e9b644d03f@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Martin_Hundeb=c3=b8ll?= <mnhu@prevas.dk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:50534 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751060AbdJRSyr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 14:54:47 -0400
Received: by mail-wr0-f173.google.com with SMTP id q42so6048530wrb.7
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:54:46 -0700 (PDT)
In-Reply-To: <8994adaa-6223-20f1-9221-49e9b644d03f@prevas.dk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2017 10:30 AM, Martin Hundebøll wrote:
> 
> 
> On 2017-10-18 18:51, Florian Fainelli wrote:
>> On 10/18/2017 09:21 AM, Andrew Lunn wrote:
>>> Hi Martin
>>>
>>> Sorry for starting a new thread. I deleted the patchset from my mailbox.
>>>
>>> Florian said:
>>>
>>>> The logic goes like this:
>>>>
>>>> - try to connect to the PHY via phy-handle
>>>> - if we have a PHY we are connecting via phy-handle but we need to
>>>>    divert MDIO reads/writes connect using its address on the diverted
>>>>    bus
>>>> - connect using a fixed PHY
>>>> - finally try using the DSA slave MII bus which would connect to the
>>>> switch internal PHYs
>>>
>>> This is not quite correct. Looking at the code:
>>>
>>>          phy_dn = of_parse_phandle(port_dn, "phy-handle", 0);
>>>   ...
>>>
>>>          if (phy_dn) {
>>>                  int phy_id = of_mdio_parse_addr(&slave_dev->dev,
>>> phy_dn);
>>>
>>>                  /* If this PHY address is part of phys_mii_mask,
>>> which means
>>>                   * that we need to divert reads and writes to/from
>>> it, then we
>>>                   * want to bind this device using the slave MII bus
>>> created by
>>>                   * DSA to make that happen.
>>>                   */
>>>                  if (!phy_is_fixed && phy_id >= 0 &&
>>>                      (ds->phys_mii_mask & (1 << phy_id))) {
>>>                          ret = dsa_slave_phy_connect(p, slave_dev,
>>> phy_id);
>>>                          if (ret) {
>>>                                  netdev_err(slave_dev, "failed to
>>> connect to phy%d: %d\n", phy_id, ret);
>>>                                  of_node_put(phy_dn);
>>>                                  return ret;
>>>                          }
>>>                  } else {
>>>                          p->phy = of_phy_connect(slave_dev, phy_dn,
>>>
>>> The first point really is:
>>>
>>> - try to connect to the PHY via phy-handle, if the phy_id is not
>>> valid, or if the phy_id does not map to a phy that the switch says
>>> does not exist.
>>>
>>> In your case, all these points are true, so it uses
>>> dsa_slave_phy_connect().  But we actually want it to use
>>> of_phy_connect(), which will use the correct bus.
>>>
>>> For some Marvell chips, you cannot actually go on ds->phys_mii_mask.
>>> These devices can have in built PHYs and SERDES interfaces which can
>>> be assigned to ports. These SERDES interfaces could have external PHYs
>>> connected to them, and be on the external MDIO bus. So
>>> ds->phys_mii_mask indicates there is a PHY, but the phy-handle points
>>> to a different phy.
>>>
>>> So i think this code block needs to change. If we have a phy-handle,
>>> use it.  i.e. what Florian _thinks_ it should be doing. If not, then
>>> use dsa_slave_phy_connect().
>>
>> I see what you mean now, the logic above gets defeated because it does
>> not concern itself with the MDIO controller parent of the PHY node
>> pointed to by phy-handle. So if like Martin you have two MDIO busses,
>> but both happen to have MDIO addresses that are valid for both busses,
>> the logic above gets defeated and we wrongly try to attach to the switch
>> internal MDIO bus under ds->slave_mii_bus.
>>
>> The easiest fix would certainly to lookup the parent MDIO bus and do
>> that only if ds->slave_mii_bus->of_node and the parent of the node
>> pointed to 'phy-handle' match.
>>
>> Does that work for you?
>>
> 
> As Andrew implies, I think we should rewrite the entire block to make it
> more intuitive.

I don't particularly care what the fate of that code is, as long as it
does not break on my systems, you break it, you fix it.

> 
> Are these the cases that should be handled?
> 
> 0) Fixed link
> Register using of_phy_register_fixed_link().

Yes.

> 
> 1) No phy-handle
> Use dsa_slave_phy_connect() to connect on internal MDIO bus with phy
> address from index/port-reg property.

Yes.

> 
> 2) Valid phy handle
> Use of_phy_connect() to connect using parent MDIO bus handle.

Yes, but with the caveat already covered today: there is a possible
problem with having to divert MDIO accesses of a PHY pointed by
phy-handle towards the internal switch bus because of specific problems
such as those explained in drivers/net/bcm_sf2.c, I don't mind trying to
do things smarter or in a different way, but that needs to be something
possible.
-- 
Florian
