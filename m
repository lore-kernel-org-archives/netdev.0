From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH v3 0/3] net: dsa: mv88e6xxx: add support for VLAN Table Unit
Date: Mon, 6 Jul 2015 20:46:10 -0700
Message-ID: <CAE4R7bALqVsV7nTH0r+AqbxE8z2ScG=_FfaBkpzrfXyw0A9DJg@mail.gmail.com>
References: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150706233804.GE469@lunn.ch> <20150707020047.GA5540@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:32926 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbbGGDqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 23:46:30 -0400
In-Reply-To: <20150707020047.GA5540@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 7:00 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, Jul 07, 2015 at 01:38:04AM +0200, Andrew Lunn wrote:
>> On Sun, Jul 05, 2015 at 10:14:50PM -0400, Vivien Didelot wrote:
>> > Hi all,
>> >
>> > This patchset brings full support for hardware VLANs in DSA, and the Marvell
>> > 88E6xxx compatible switch chips.
>>
>> Hi Vivien
>>
>> I just booted these patches on my board, and i'm getting WARNINGS:
>>
>> [   61.111302] WARNING: CPU: 0 PID: 2751 at net/switchdev/switchdev.c:265 switchdev_port_obj_add+0xd4/0xdc()
>
> Hi Vivien
>
> I debugged this a bit.
>
> The problem comes from:
>
> static int dsa_slave_port_obj_add(struct net_device *dev,
>                                   struct switchdev_obj *obj)
> {
>         int err;
>
>         /*
>          * Skip the prepare phase, since currently the DSA drivers don't need to
>          * allocate any memory for operations and they will not fail to HW
>          * (unless something horrible goes wrong on the MDIO bus, in which case
>          * the prepare phase wouldn't have been able to predict anyway).
>          */
>         if (obj->trans != SWITCHDEV_TRANS_COMMIT)
>                 return 0;
>
>         switch (obj->id) {
>         case SWITCHDEV_OBJ_PORT_VLAN:
>                 err = dsa_slave_port_vlans_add(dev, obj);
>                 break;
>         default:
>                 err = -EOPNOTSUPP;
>                 break;
>         }
>
>         return err;
> }
>
> It is being called with obj->id of 2, which is
> SWITCHDEV_OBJ_IPV4_FIB. This function is called twice. The first time
> it is with SWITCHDEV_TRANS_PREPARE and we are allowed to return an
> error. The second time, with SWITCHDEV_TRANS_COMMIT, errors are not
> allowed.
>
> EOPNOTSUPP is considered an error, so since we don't support
> SWITCHDEV_OBJ_IPV4_FIB we error out the COMMIT phase.
>
> Not sure which is cleaner. Test to see if we support the object during
> the prepare, or allow the commit to accept EOPNOTSUPP as not being an
> error?

I think we should return EOPNOTSUPP on PREPARE, so move the trans !=
COMMIT test inside the case for PORT_VLAN.  That would future-proof
the func when new objects are added to switchdev (and not supported by
dsa_slave).

Does that sound OK?

-scott
