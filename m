From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Thu, 26 Mar 2015 15:49:22 +0100
Message-ID: <20150326144922.GC2010@nanopsycho.orion>
References: <20150324160126.GA17104@roeck-us.net>
 <5511A29F.5010006@cumulusnetworks.com>
 <20150324175825.GA1465@roeck-us.net>
 <CAE4R7bAoGeFdNAUqMR-RmQWTtfSy0t+e4f187an_BVVVR2tDnw@mail.gmail.com>
 <CAGVrzcZ+QywZxe4P2bcnBLG9mXUDARNzNyXF1yTOV9tnAcx=PQ@mail.gmail.com>
 <CAE4R7bBeFg9v-CnUJU-0pe8ZS4AYXQNAGNTcvCrHdZ1ggYmOPA@mail.gmail.com>
 <5512E9EC.5020504@cumulusnetworks.com>
 <CAE4R7bCtpaonLeRiX9s3yFisONDQUv9z_EOBcGTdgTGLEjC7vA@mail.gmail.com>
 <20150326082011.GA2010@nanopsycho.orion>
 <CAE4R7bCYe1c2dT0V3tDjUvVuzB28WabAjbt=sQreK=3WM+60Nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36301 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbbCZOt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 10:49:27 -0400
Received: by wibg7 with SMTP id g7so151452669wib.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 07:49:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bCYe1c2dT0V3tDjUvVuzB28WabAjbt=sQreK=3WM+60Nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 26, 2015 at 03:28:28PM CET, sfeldma@gmail.com wrote:
>On Thu, Mar 26, 2015 at 1:20 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Thu, Mar 26, 2015 at 08:44:27AM CET, sfeldma@gmail.com wrote:
>>>On Wed, Mar 25, 2015 at 10:01 AM, roopa <roopa@cumulusnetworks.com> wrote:
>>>
>>>[cut]
>>>
>>>So just to keep the discussion alive (because we really need to solve
>>>this problem), my current thinking is back to Roopa's RFC patch to
>>>mark the skb to avoid fwding in bridge driver.  One idea (sorry if
>>>this was already suggested, thread is long) is to use
>>>swdev_parent_id_get op in the following way:
>>>
>>>1) when port interface is added to bridge, bridge calls
>>>swdev_parent_id_get() on port to get switch id.
>>>swdev_parent_id_get() needs to be modified to work on stacked drivers.
>>>For example, if a bond is the new bridge port, swdev_parent_id_get()
>>>on the bond interface should get switch_id for bond member.  We stash
>>>the switch_id in the bridge port private structure for later
>>>comparison.
>>
>> Nope, that cannot work. You can bond 2 ports each belonging to a
>> different switch.
>
>Are you thinking about two switch ASICs in the same box, and bonding
>ports from each?  Or are you thinking about bonding ports from
>different boxes, ala MLAG?

One machine, 2 switches.

>
>In the first case the bond would report NULL switch_id if the member
>ports don't all have the same switch_id.  If bond switch_id is NULL,
>the bridge driver would fwd pkts to bond and now bond would make same
>check as bridge: if dst port switch_id is same as skb switch_id, then
>drop pkt.  In bridge, if bond switch_id is non-NULL and matches skb
>switch_id, then drop pkt.  So it works as desired for this case.  It
>requires the bonding/teaming driver to modify the default behavior for
>swdev_parent_id_get() to only return switch_id if all ports agree on
>switch_id.
>
>For second case using MLAG, I suspect bond member port switch_ids
>would likely be different, and so with same logic in bonding/bridge
>drivers as above in first case, the pkt would be fwded down.
>
>Is there another case to consider?  I think converting
>swdev_parent_id_get() to use same algo we have for stp, allowing for
>any layer to override like in my bonding example, will have benefits
>down the road.
>
>What is the argument for not allowing stacked version of swdev_parent_id_get()?

That was suppose wo identify a switch port. "ip link" will show you that
and you see right away what is going on. If bond implements that, that
brigs a mess. I don't like that.

>
>-scott
