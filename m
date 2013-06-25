From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Wed, 26 Jun 2013 00:57:10 +0200
Message-ID: <51CA2046.9090809@xdin.com>
References: <1902752B0C92F943AB7EA9EE13E2DEEC126CC8C873@HQ1-EXCH02.corp.brocade.com> <20130624171151.7b2b342a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:58954 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059Ab3FYW5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 18:57:13 -0400
In-Reply-To: <20130624171151.7b2b342a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-06-25 02:11, Stephen Hemminger wrote:
> On Mon, 24 Jun 2013 09:44:01 -0700
> Arvid Brodin <arvid.brodin@xdin.com> wrote:
>=20
>> +
>> +static void __hsr_set_operstate(struct net_device *dev, int transit=
ion)
>> +{
>> +       if (dev->operstate !=3D transition) {
>> +               write_lock_bh(&dev_base_lock);
>> +               dev->operstate =3D transition;
>> +               write_unlock_bh(&dev_base_lock);
>> +               netdev_state_change(dev);
>> +       }
>> +}
>=20
> Don't use dev_base_lock, you need to use rtnl_mutex() instead when
> making state changes.

This code is exactly what set_operstate() does net/core/rtnetlink.c. Ar=
e you sure I should
change it to use rtnl_lock()/rtnl_unlock()?


> Also, don't set operstate directly, it doesn't run link watch events
> which services can see. Instead use this to propogate up changes.
>=20
> void netif_stacked_transfer_operstate(const struct net_device *rootde=
v,
> 					struct net_device *dev)

That function does not work for devices with more than one underlying p=
hysical interface.
A HSR device works (is OPER_UP) as long as at least one of its two phys=
ical interfaces is
up. Using that function to set carrier state on a HSR device would defe=
at the whole
purpose with HSR (redundancy). I haven't been able to find an existing =
interface that sets
operstate for devices that use multiple physical interfaces.

As for link watch events, doesn't the call to netdev_state_change() tak=
e care of that?


--=20
Arvid Brodin | Consultant (Linux)
T: +46-8-56254286 | M: +46-70-9714286 | arvid.brodin@xdin.com
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
