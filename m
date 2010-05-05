From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH] compat-wireless: updates for orinoco
Date: Tue, 4 May 2010 18:47:54 -0700
Message-ID: <z2s43e72e891005041847g6147acfdm1efc8c752dbe94c@mail.gmail.com>
References: <1273012850-8359-1-git-send-email-hauke@hauke-m.de>
	<v2u43e72e891005041626n14deaca5z284f2472e909c923@mail.gmail.com>
	<20100504170409.46914a88@nehalam> <20100505001830.GO2624@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luis Rodriguez <Luis.Rodriguez@atheros.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	David Miller <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"mcgrof@kernel.org" <mcgrof@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:44588 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933657Ab0EEBsP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 21:48:15 -0400
In-Reply-To: <20100505001830.GO2624@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 4, 2010 at 5:18 PM, Luis R. Rodriguez
<lrodriguez@atheros.com> wrote:
> On Tue, May 04, 2010 at 05:04:09PM -0700, Stephen Hemminger wrote:
>> On Tue, 4 May 2010 16:26:53 -0700
>> "Luis R. Rodriguez" <lrodriguez@atheros.com> wrote:
>>
>> > First of all, thanks a lot! Some comments below.
>> >
>> > On Tue, May 4, 2010 at 3:40 PM, Hauke Mehrtens <hauke@hauke-m.de> =
wrote:
>> > > * Make all the patches apply again.
>> > > * rename read_pda to avoid conflicts with definitions in kernel =
<=3D 2.6.29
>> >
>> > I'm going to apply these two changes, if you get time can you send=
 a
>> > patch to rename read_pda upstream as well, that way we don't have =
to
>> > carry this?
>> >
>> > > * add orinoco usb
>> >
>> > Thanks for this but I've grown tired of updating these netdev ops =
and
>> > I think we can do better. I'll add a netdev_attach_ops() which wou=
ld
>> > simply do all the backport stuff for us, this way for backporting
>> > purposes all we have to do is replace the old lines with a
>> > netdev_attach_ops() call. In fact if we *really* wanted to we coul=
d
>> > add a dummy netdev_attach_ops() upstream and just backport that on
>> > older kernels, this would mean 0 line changes to backport a newer
>> > driver.
>> >
>> > Something like this maybe on the generic compat module, it builds =
for
>> > me, will commit soon.
>> >
>> > /*
>> > =C2=A0* Expand this as drivers require more ops, for now this
>> > =C2=A0* only sets the ones we need.
>> > =C2=A0*/
>> > void netdev_attach_ops(struct net_device *dev,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 const struct net_device_ops *ops)
>> > {
>> > #define SET_NETDEVOP(_op) (_op ? _op : NULL)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->open =3D SET_NETDEVOP(ops->ndo_ope=
n);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->stop =3D SET_NETDEVOP(ops->ndo_sto=
p);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->hard_start_xmit =3D SET_NETDEVOP(o=
ps->ndo_start_xmit);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->set_multicast_list =3D SET_NETDEVO=
P(ops->ndo_set_multicast_list);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->change_mtu =3D SET_NETDEVOP(ops->n=
do_change_mtu);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->set_mac_address =3D SET_NETDEVOP(o=
ps->ndo_set_mac_address);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->tx_timeout =3D SET_NETDEVOP(ops->n=
do_tx_timeout);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->get_stats =3D SET_NETDEVOP(ops->nd=
o_get_stats);
>> > #undef SET_NETDEVOP
>> > }
>> > EXPORT_SYMBOL(netdev_attach_ops);
>> >
>> > For newer kernels then this would just be:
>> >
>> > static inline void netdev_attach_ops(struct net_device *dev,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 const struct net_device_ops *ops)
>> > {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->netdev_ops =3D ops;
>> > }
>> >
>> > Stephen, would the above be acceptable upstream on netdevice.h ? I=
t
>> > would eliminate all needs from having to #ifdef network drivers wh=
en
>> > backporting. If so I can send a respective patch and spatch all th=
e
>> > setters I think. An example of the nasty ifdef crap we have to do =
for
>> > the current backport of netdevop'able drivers is below.
>> >
>>
>> No. supporting backporting is not part of the upstream kernel
>> mission. Honestly, we try for forward compatibility but intentionall=
y
>> ignore carrying extra backport baggage.
>
> Sure, understood, just had to try :), if only I could find a *good*
> non-backport reason to have the netdev_attach_ops()...

=46WIW, it helped a lot, porting an Ethernet driver for example consist=
s
of a 1 line change to the driver, this goes down to 2.6.21 even. With
a netdev_attach_ops() upstream this would require 0 lines of code
changes. But --- I understand, I'll try to find a real value for it on
existing kernels.

 patches/01-netdev.patch |  625 ++++++---------------------------------=
--------
 1 files changed, 75 insertions(+), 550 deletions(-)

  Luis
