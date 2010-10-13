From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: Question about PHY-less board and "fixed_phy"
Date: Wed, 13 Oct 2010 19:21:23 +0000 (UTC)
Message-ID: <i950ri$od1$1@dough.gmane.org>
References: <i94oag$epv$1@dough.gmane.org>
 <4CB6032A.8020908@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46408 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751744Ab0JMTVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 15:21:33 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1P66tH-0007fg-6j
	for netdev@vger.kernel.org; Wed, 13 Oct 2010 21:21:31 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 21:21:31 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 21:21:31 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-10-13, David Daney <ddaney@caviumnetworks.com> wrote:
> On 10/13/2010 09:55 AM, Grant Edwards wrote:
>
>> I'm working with an Atmel ARM9 board (macb driver), that doesn't have
>> a PHY.
>>
>> The MAC is connected to a switch via MII.  That MII link is hard-wired
>> to be 100M full-duplex.
>>
>>> From what I've been able to google, the "fixed_phy" driver is intended
>> for this situation.  But from looking at the fixed.c source code it
>> appears to provide an emulated MDIO bus.
>>
>> I don't want an emulated MDIO bus.
>>
>> I have a real, working MDIO bus.
>>
>> What I don't have is a PHY.
>>
>> The switch presents a bunch of logical slave devices (23, IIRC)
>> attached to the MDIO bus, and I need use the MDIO bus to access those
>> "devices" (mainly from user-space via ioctl() calls).  If I use the
>> fixed_phy driver, it appears that it will hide the real MDIO bus and
>> replace it with a fake one that's connected to a fake set of PHY
>> registers.  That means I won't be able to access the the registers in
>> the switch to which my MAC is connected.
>>
>> The ethernet/phy architecture seems to be based on several assumptions
>> that aren't true in my case:
>>
>>   1) Every MAC is connected to a PHY.
>
> As long as you handle calling netif_carrier_{on,off}() and some of
> the ndo_do_ioctl commands, I don't think you need a PHY.

Thanks.  I'll look into that.

>>   2) An MDIO bus is a point-to-point link between the MAC and the PHY.
>
> This I don't think is the case.  See phy_connect() for example.  It 
> certianly allows for multiple PHYs per bus.
>
> We have a SOC device (Octeon) that has many PHYs on a single MDIO
> bus, and have a separate MDIO bus driver (mdio-octeon.c) that is
> shared between all the Ethernet devices/drivers.

Do you bypass the ioctl code in phy.c that ignores the device id in
the request and instead routes all read/write operations to the PHY's
id?

>>   3) The MDIO bus belongs to the PHY.
>
> ??, The mdio bus lock is taken for some operations, but how does it 
> 'belong to' the PHY?

I said that because the ioctl() to do read/write operations on the
mdio bus is a "phy" ioctl() that is handled by phy.c code (in the
drivers I've looked at), and it overwrites any user-provided device ID
with that of the PHY, thus turning the mdio bus into a point-to-point
link to the PHY whose use is controlled by the PHY driver.  In my mind
I guess that equates to the mdio bus "belonging to" the PHY.

It looks like I need to change the macb driver to handle those ioctl
requests directly instead of having the phy.c code handle them.

>>   4) It's OK to go out and read arbitrary registers from every device
>>      on the MDIO bus when that bus is registered using mdiobus_register().
>
> You can set the struct mii_bus phy_mask element to prevent probing of
> specific addresses.

Ah, I hadn't figured that out yet.

Thanks for the hints!

-- 
Grant Edwards               grant.b.edwards        Yow! I know things about
                                  at               TROY DONAHUE that can't
                              gmail.com            even be PRINTED!!

