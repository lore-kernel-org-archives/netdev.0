From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Fri, 30 Mar 2007 16:59:47 +0200
Message-ID: <200703301659.48047.IvDoorn@gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com> <200701311220.51971.IvDoorn@gmail.com> <200703300127.40849.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Dmitry Torokhov <dtor@insightbb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:42591 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbXC3PA3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 11:00:29 -0400
Received: by ug-out-1314.google.com with SMTP id 44so839689uga
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2007 08:00:27 -0700 (PDT)
In-Reply-To: <200703300127.40849.dtor@insightbb.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I am very sorry for taking so much time to respond but finally I went
> through the patch and I still have the same objection as before -
> it mixes two logically (and often physically) separated objects into
> a single entity. I think that RF switch and button should be separate
> entities, created and destroyed independently of each other. This way
> everything handled uniformly by the kernel.

ok. Sounds good as well. :)

> I attempted to rework the rfkill core supprt and simplify it and
> came up with the patch below. Network card drivers that are able
> to control state of their RF transmitters allocate and register
> rfkill structures. Every rfkill structure belongs to one of
> RF classes (WLAN, Bluetooth or IRDA) and exports its name, type,
> state and "user_claim" through sysfs.
>=20
> There is also an input handler that catces KEY_WLAN and KEY_BLUETOOTH
> events passing through input system and toggles state of all RF
> switches of appropriate type registered with rfkill system (unless
> a switch was claimed by userspace in which case it is left alone).
> I think this provides basic functionality that most of the users need
> and any advanced control will have to be done from userspace.

Shouldn't a KEY_IRDA be added as well?
It isn't currently defined in input.h yet, but perhaps it actually shou=
ld?
Or is IRDA treated differently for a specific reason?

> In a followup patch there is a skeleton code for creating polled
> input devices. For cards that have button physically connected
> their drivers will have to register a separate input device and
> let either input handler or userspace application take care of
> switching RF state appropriately.
>
> My only concern is where rfkill code should live. Since it is no
> longer dependent on input core (embedded systems might disable
> rfkill-input and use bare rfkill and control state from userspace)
> it does not need to live in drivers/input.

How about:
rfkill -> drivers/misc
rfkill_input -> input/misc
input_polldev -> lib/ (perhaps small namechange to rfkill_polldev?)
It would scatter the components a bit, but since each of those modules
has its own specific task this would make the most sense.
And by setting the depends and select fields for the menu entries corre=
ctly
it shouldn't be too big of a problem.

> Please let me know what you think.

Just to get it straight on how these 3 modules would cooperate (before =
I start mixing things up) ;)

 - rfkill
	- Drivers register to the rfkill module, rfkill=20
	- Provides the sysfs interface
	- Drivers that don't require polling should report the events to this =
module

 - rfkill_input
	- Provides input device visible to userspace

 - input_polldev
	- Handlers polling, where the driver should check what the previous st=
ate was and the driver
	  should send the event to rfkill.

Could input_polldev perhaps not be setup to poll, and keep track of the=
 current button status
and send the signal directly to rfkill?

What I am also not sure of is that input_polldev and rfkill_input both =
register a input device.
Instead of starting and stopping the polling through the input device i=
t would perhaps make more
sense to either use the input device from rfkill_input and/or make use =
of a sysfs attribute.

> +/**
> + * rfkill_unregister - Uegister a rfkill structure.
> + * @rfkill: rfkill structure to be unregistered
> + *
> + * This function should be called by the network driver during devic=
e
> + * teardown to destroy rfkill structure. Note that rfkill_free() sho=
uld
> + * _not_ be called after rfkill_unregister().
> + */
> +void rfkill_unregister(struct rfkill *rfkill)
> +{
> +=A0=A0=A0=A0=A0=A0=A0device_del(&rfkill->dev);
> +=A0=A0=A0=A0=A0=A0=A0rfkill_remove_switch(rfkill);
> +=A0=A0=A0=A0=A0=A0=A0put_device(&rfkill->dev);
> +}
> +EXPORT_SYMBOL(rfkill_unregister);

personally I would prefer enforcing drivers to call
allocate()
register()
unregister()
free()

Especially with unregister() doing the same steps as free() (put_device=
)
might be somwhat confusing. But might be just me. ;)

The remainder looks good, unfortunately I can't test it since the lapto=
p with an rfkill button I have
requires isn't in a state for testing at this moment, and I would need =
to figure out how button status
reading happens in bcm43xx.

Ivo
