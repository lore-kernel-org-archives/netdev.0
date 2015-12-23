From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 00/28] DSA: Restructure probing
Date: Wed, 23 Dec 2015 15:13:13 -0800
Message-ID: <567B2A89.7000803@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <567B07CB.5080308@gmail.com> <20151223223303.GD25485@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34219 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134AbbLWXNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 18:13:16 -0500
Received: by mail-ob0-f172.google.com with SMTP id iw8so174315358obc.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 15:13:16 -0800 (PST)
In-Reply-To: <20151223223303.GD25485@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 14:33, Andrew Lunn a =C3=A9crit :
> On Wed, Dec 23, 2015 at 12:44:59PM -0800, Florian Fainelli wrote:
>> Hi Andrew,
>>
>> Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
>>> As noted in Documentation/networking/dsa/dsa.txt, the current DSA
>>> architecture has a few architecture problems:
>>>
>>> DSA is implemented as a DSA platform device driver which is conveni=
ent because
>>> it will register the entire DSA switch tree attached to a master ne=
twork device
>>> in one-shot, facilitating the device creation and simplifying the d=
evice driver
>>> model a bit, this comes however with a number of limitations:
>>>
>>> - building DSA and its switch drivers as modules is currently not w=
orking
>>> - the device driver parenting does not necessarily reflect the orig=
inal
>>>   bus/device the switch can be created from
>>> - supporting non-MDIO and non-MMIO (platform) switches is not possi=
ble
>>>
>>> This RFC patchset attempts to address this. It allows the switch
>>> device to be true Linux devices, and use of the device component
>>> framework to bind the switch devices to the DSA framework, similar =
to
>>> the way GPU engines are bound to the master GPU driver. The drivers
>>> are now modules, which can be loaded and unloaded. Reloading howeve=
r
>>> currently causes an Opps, hence RFC.
>>>
>>> The code remains backwards compatible with the old binding, and add=
s a
>>> new property to facilitate the component framework. Switch drivers =
get
>>> there own binding, allowing them to be probed independent of DSA.
>=20
> Hi Florian
>=20
>> Well, sort of, and that is the part that gives me mixed feelings rig=
ht
>> now. Your conversion of the bcm_sf2 driver, although it looks good a=
nd
>> gets us where we should go, still poses a major problem for my platf=
orms
>> where a wrong DTB is frozen (at least for some time).
>=20
> I hope i've not broken backwards compatibility, so your old DT blobs
> should still work. If they don't work, we should debug why.
>=20
>> I still think that using a 'dsa' platform device and having to bind
>> other drivers to it is just an artifact and relic from the original
>> design that we do not necessarily need anymore but with the componen=
ts
>> framework, it seems to get us in a better shape.
>=20
> I don't really see how we can do without a dsa platform driver. We
> need something that brings together all the switches in a cluster. We
> need somewhere which holds the information about how these switches
> are connected together and connected to the host.

I do not think you need the platform device because ultimately what the
DSA platform device does is bind some data to the master network device
the DSA switch tree is hanging off. Sure you need some piece of code
that is resident in kernel or module space to be able to parse and
allocate that data structure and bind multiple switch drivers together,
but that could be a consequence of probing switch driver using their bu=
s
probe function.

The way I would imagine this in a cluster configuration is that you
probe switches in the order in which they should appear in the final
switch tree (if this order cannot be guaranteed, then defer until it
is), and as you parse Device Tree for these switches you allocate their
resources and update the dsa_switch_tree structure "live".

So for the first switch in tree:
- master network device has no dsa_ptr assigned yet, allocate
dsa_platform_data and this switch's platform data, assign dev->dsa_ptr
so subsequent switches can be attached

=46or secondary switches in tree:
- locate their index, fetch the master network device dsa_ptr and add
them to the switch tree

If we are using Device Tree this is relatively easy since we can lookup
the entire Device Tree to know the switch tree topology whenever we
probe a switch device driver. If we are using platform data, then, we
should have a way to associate a given MDIO bus address with
supplementary information, very much like what this patch does:

https://dev.openwrt.org/browser/trunk/target/linux/generic/patches-4.3/=
710-phy-add-mdio_register_board_info.patch

Does that make sense?
--=20
=46lorian
