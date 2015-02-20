From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Port STP state after removing port from bridge
Date: Fri, 20 Feb 2015 11:00:46 +0100
Message-ID: <20150220100046.GB2008@nanopsycho.orion>
References: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com>
 <CAE4R7bBSbwi93t05Z+rB2JgzFYdZ+m44AFSzU7JkwdHRWzz1Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:47212 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631AbbBTKAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:00:50 -0500
Received: by mail-wi0-f169.google.com with SMTP id em10so5400808wid.0
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 02:00:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAE4R7bBSbwi93t05Z+rB2JgzFYdZ+m44AFSzU7JkwdHRWzz1Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Feb 20, 2015 at 05:45:01AM CET, sfeldma@gmail.com wrote:
>On Wed, Feb 18, 2015 at 11:39 PM, Florian Fainelli <f.fainelli@gmail.c=
om>
>wrote:
>
>> Hi,
>>
>> It just occured to me that the following sequence:
>>
>> brctl addbr br0
>> brctl addif br0 port0
>> ... STP happens
>> brctl delif br0 port0
>>
>> will leave port0 in STP disabled state, because the bridge code will
>> set the STP state to DISABLED, and only a down/up sequence can bring
>> it back to FORWARDING.
>>
>> Is this something that we should somehow fix? As an user it seems a
>> little convoluted having to do a down/up sequence to restore things.=
 I
>> believe however that it is valid for the bridge layer to mark a port
>> as DISABLED when removing it. This is typically not noticed or even
>> remotely a problem with software bridges because we cannot enforce a=
n
>> actual STP state at the HW level.
>>
>> Let me know your thoughts.
>>
>>
>=E2=80=8BThe fix in rocker would be:
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c
>b/drivers/net/ethernet/rocker/rocker.c
>index 34389b6a..e2004fb 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -4456,8 +4456,10 @@ static int rocker_port_bridge_leave(struct
>rocker_port *rocker_port)
>                rocker_port_internal_vlan_id_get(rocker_port,
>                                                 rocker_port->dev->ifi=
ndex);
>        err =3D rocker_port_vlan(rocker_port, 0, 0);
>+       if (err)
>+               return err;
>
>-       return err;
>+       return rocker_port_stp_update(rocker_port, BR_STATE_FORWARDING=
);
> }
>
>
>=E2=80=8BThis will return the port back to it's initial state of
>BR_STATE_FORWARDING, after it's removed from the bridge.
>
>I'll include this patch in the rocker pile to be pushed later.
>
>-scott=E2=80=8B


I'm not sure, but wouldn't it be nicer it the bridge code would set
state to disabled before the port is removed from the bridge?=20
