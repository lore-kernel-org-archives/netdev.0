From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Wed, 26 Jun 2013 01:36:47 +0200
Message-ID: <51CA298F.7060600@xdin.com>
References: <1902752B0C92F943AB7EA9EE13E2DEEC126CC8C873@HQ1-EXCH02.corp.brocade.com> <20130624170727.4d7893a1@nehalam.linuxnetplumber.net> <51CA1A1B.5080700@xdin.com> <20130625154638.357e4764@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	Arvid Brodin <Arvid.Brodin@xdin.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:50889 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab3FYXgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 19:36:49 -0400
In-Reply-To: <20130625154638.357e4764@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-06-26 00:46, Stephen Hemminger wrote:
> On Wed, 26 Jun 2013 00:30:51 +0200
> Arvid Brodin <arvid.brodin@xdin.com> wrote:
>=20
>> On 2013-06-25 02:07, Stephen Hemminger wrote:
>>> On Mon, 24 Jun 2013 09:44:01 -0700
>>> Arvid Brodin <arvid.brodin@xdin.com> wrote:
>>>
>>>> +
>>>> +
>>>> +static bool is_admin_up(struct net_device *dev)
>>>> +{
>>>> +       return dev && (dev->flags & IFF_UP);
>>>> +}
>>>> +
>>>> +static bool is_operstate_up(struct net_device *dev)
>>>> +{
>>>> +       return (dev && (dev->operstate =3D=3D IF_OPER_UP));
>>>> +}
>>>> +
>>>
>>> Isn't is_admin_up the same as netif_running()?
>>
>> I don't think so (but I'm unsure). This is netif_running() (from inc=
lude/linux/netdevice.h):
>>
>> static inline bool netif_running(const struct net_device *dev)
>> {
>> 	return test_bit(__LINK_STATE_START, &dev->state);
>> }
>>
>> I'm not sure what this does. I don't think it's the same as checking=
 whether the admin has
>> issued an UP command?
>>
>>
>>> And is_operstate_up the same as netif_oper_up()?
>>
>> netif_oper_up() also returns true if the device state is IF_OPER_UNK=
NOWN. A device can
>> have that state without even having carrier, so that's not OK for th=
e HSR driver.
>>
>=20
> Then use netif_oper_up(dev) && netif_carrier_on(dev)

That would be very weird since netif_carrier_on() signals that the carr=
ier is on (and
returns void). :) But I get your point - i.e. check for carrier state.


This is netif_oper_up() in include/linux/netdevice.h:

static inline bool netif_oper_up(const struct net_device *dev)
{
	return (dev->operstate =3D=3D IF_OPER_UP ||
		dev->operstate =3D=3D IF_OPER_UNKNOWN /* backward compat */);
}

I'm guessing that IF_OPER_UNKNOWN is just a default state and that some=
 (old or buggy)
network drivers simply does not set this as they should? I.e. they shou=
ld call
netif_carrier_off() on open, but they don't. The "backward compat" may =
be a way around
that? (We had problems with this on an old version of the macb driver; =
I think that's why
we wrote our own is_operstate_up().)

If so, I guess you are right and I should use netif_oper_up() (and any =
problems arising
from that would be due to bugs in the respective device driver). Does t=
his sound reasonable?


--=20
Arvid Brodin | Consultant (Linux)
T: +46-8-56254286 | M: +46-70-9714286 | arvid.brodin@xdin.com
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
