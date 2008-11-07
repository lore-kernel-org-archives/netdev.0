From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [BUG] rmmod bfin_mac netdev driver module will cause system crash.
Date: Sat, 8 Nov 2008 00:43:29 +0800
Message-ID: <386072610811070843q25c3988dx3ef7848c89d09cd3@mail.gmail.com>
References: <386072610811040045w2944a856jd55809f0a7532dbd@mail.gmail.com>
	 <20081107092450.GG32552@xi.wantstofly.org>
	 <386072610811070836i2be6083dy8534fd26b1201769@mail.gmail.com>
	 <20081107164118.GO32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Lennert Buytenhek" <buytenh@wantstofly.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.190]:38297 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbYKGQna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 11:43:30 -0500
Received: by rn-out-0910.google.com with SMTP id k40so333245rnd.17
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 08:43:29 -0800 (PST)
In-Reply-To: <20081107164118.GO32552@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 8, 2008 at 12:41 AM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Sat, Nov 08, 2008 at 12:36:08AM +0800, Bryan Wu wrote:
>
>> >> I got a regression since I update our blackfin kernel to the lastest
>> >> 2.6.28-rc2 which includes your phylib patches.
>> >> Please find the tracker here:
>> >> https://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_id=141&tracker_item_id=4595
>> >>
>> >> Briefly, the calling chain is:
>> >> in bfin_mac_remove(), mdiobus_unregister() ->
>> >> device_unregister(&bus->dev); -> put_device() -> kobject_put() ->
>> >> kref_put(&kobj->kref, kobject_release); -> kobject_release() ->
>> >> kobject_cleanup() -> mdiobus_release().
>> >> So in mdiobus_unregister() bus->state = MDIOBUS_UNREGISTERED; but in
>> >> mdiobus_release(), this BUG_ON will fire:
>> >> BUG_ON(bus->state != MDIOBUS_RELEASED);
>> >>
>> >> How about this patch?
>> >>
>> >> ---
>> >> Index: drivers/net/phy/mdio_bus.c
>> >> ===================================================================
>> >> --- drivers/net/phy/mdio_bus.c        (revision 5575)
>> >> +++ drivers/net/phy/mdio_bus.c        (working copy)
>> >> @@ -134,13 +134,16 @@
>> >>       int i;
>> >>
>> >>       BUG_ON(bus->state != MDIOBUS_REGISTERED);
>> >> -     bus->state = MDIOBUS_UNREGISTERED;
>> >>
>> >> +     bus->state = MDIOBUS_RELEASED;
>> >> +
>> >>       device_unregister(&bus->dev);
>> >>       for (i = 0; i < PHY_MAX_ADDR; i++) {
>> >>               if (bus->phy_map[i])
>> >>                       device_unregister(&bus->phy_map[i]->dev);
>> >>       }
>> >> +
>> >> +     bus->state = MDIOBUS_UNREGISTERED;
>> >>  }
>> >>  EXPORT_SYMBOL(mdiobus_unregister);
>> >> ---
>> >
>> > Actually, what I think should be done is this.  Can you try that?
>> >
>> >
>> > diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
>> > index d0ed1ef..536bda1 100644
>> > --- a/drivers/net/phy/mdio_bus.c
>> > +++ b/drivers/net/phy/mdio_bus.c
>> > @@ -136,7 +136,7 @@ void mdiobus_unregister(struct mii_bus *bus)
>> >        BUG_ON(bus->state != MDIOBUS_REGISTERED);
>> >        bus->state = MDIOBUS_UNREGISTERED;
>> >
>> > -       device_unregister(&bus->dev);
>> > +       device_del(&bus->dev);
>> >        for (i = 0; i < PHY_MAX_ADDR; i++) {
>> >                if (bus->phy_map[i])
>> >                        device_unregister(&bus->phy_map[i]->dev);
>> > --
>>
>> Right, that's the right way. Our tester confirmed that this bug was
>> fixed with this patch.
>> Need I send a patch or you patched this youself?
>
> Can you please confirm on netdev@ that that patch fixes it and then
> I'll submit it with your Tested-by, is that okay with you?
>

Sorry for just clicking reply not reply-all. Tested-by is OK for me
definitely, -:))

-Bryan
