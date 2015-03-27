From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Fri, 27 Mar 2015 07:02:15 +0100
Message-ID: <20150327060215.GA2073@nanopsycho.orion>
References: <20150324175825.GA1465@roeck-us.net>
 <CAE4R7bAoGeFdNAUqMR-RmQWTtfSy0t+e4f187an_BVVVR2tDnw@mail.gmail.com>
 <CAGVrzcZ+QywZxe4P2bcnBLG9mXUDARNzNyXF1yTOV9tnAcx=PQ@mail.gmail.com>
 <CAE4R7bBeFg9v-CnUJU-0pe8ZS4AYXQNAGNTcvCrHdZ1ggYmOPA@mail.gmail.com>
 <5512E9EC.5020504@cumulusnetworks.com>
 <CAE4R7bCtpaonLeRiX9s3yFisONDQUv9z_EOBcGTdgTGLEjC7vA@mail.gmail.com>
 <20150326082011.GA2010@nanopsycho.orion>
 <CAE4R7bCYe1c2dT0V3tDjUvVuzB28WabAjbt=sQreK=3WM+60Nw@mail.gmail.com>
 <20150326144922.GC2010@nanopsycho.orion>
 <20150327010821.GA10514@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37688 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbC0GCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 02:02:19 -0400
Received: by wiaa2 with SMTP id a2so17136283wia.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 23:02:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150327010821.GA10514@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 27, 2015 at 02:08:23AM CET, simon.horman@netronome.com wrote:
>On Thu, Mar 26, 2015 at 03:49:22PM +0100, Jiri Pirko wrote:
>> Thu, Mar 26, 2015 at 03:28:28PM CET, sfeldma@gmail.com wrote:
>> >On Thu, Mar 26, 2015 at 1:20 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> >> Thu, Mar 26, 2015 at 08:44:27AM CET, sfeldma@gmail.com wrote:
>> >>>On Wed, Mar 25, 2015 at 10:01 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> >>>
>> >>>[cut]
>> >>>
>> >>>So just to keep the discussion alive (because we really need to solve
>> >>>this problem), my current thinking is back to Roopa's RFC patch to
>> >>>mark the skb to avoid fwding in bridge driver.  One idea (sorry if
>> >>>this was already suggested, thread is long) is to use
>> >>>swdev_parent_id_get op in the following way:
>> >>>
>> >>>1) when port interface is added to bridge, bridge calls
>> >>>swdev_parent_id_get() on port to get switch id.
>> >>>swdev_parent_id_get() needs to be modified to work on stacked drivers.
>> >>>For example, if a bond is the new bridge port, swdev_parent_id_get()
>> >>>on the bond interface should get switch_id for bond member.  We stash
>> >>>the switch_id in the bridge port private structure for later
>> >>>comparison.
>> >>
>> >> Nope, that cannot work. You can bond 2 ports each belonging to a
>> >> different switch.
>> >
>> >Are you thinking about two switch ASICs in the same box, and bonding
>> >ports from each?  Or are you thinking about bonding ports from
>> >different boxes, ala MLAG?
>> 
>> One machine, 2 switches.
>> 
>> >
>> >In the first case the bond would report NULL switch_id if the member
>> >ports don't all have the same switch_id.  If bond switch_id is NULL,
>> >the bridge driver would fwd pkts to bond and now bond would make same
>> >check as bridge: if dst port switch_id is same as skb switch_id, then
>> >drop pkt.  In bridge, if bond switch_id is non-NULL and matches skb
>> >switch_id, then drop pkt.  So it works as desired for this case.  It
>> >requires the bonding/teaming driver to modify the default behavior for
>> >swdev_parent_id_get() to only return switch_id if all ports agree on
>> >switch_id.
>> >
>> >For second case using MLAG, I suspect bond member port switch_ids
>> >would likely be different, and so with same logic in bonding/bridge
>> >drivers as above in first case, the pkt would be fwded down.
>> >
>> >Is there another case to consider?  I think converting
>> >swdev_parent_id_get() to use same algo we have for stp, allowing for
>> >any layer to override like in my bonding example, will have benefits
>> >down the road.
>> >
>> >What is the argument for not allowing stacked version of swdev_parent_id_get()?
>> 
>> That was suppose wo identify a switch port. "ip link" will show you that
>> and you see right away what is going on. If bond implements that, that
>> brigs a mess. I don't like that.
>
>I'm not sure that I follow how this messes things up from a bridging point
>of view. Would it help if bonds consistently returned a NULL parent id
>even if all its slaves have the same parent id?

It's not about bridging point of view. Now, it is clear that if switchid
is defined for a device, that device is a switch port. According to the
switchid, you can find out multiple ports are part of single switch
chip. It is very clear for user.
