From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Thu, 23 Oct 2014 10:38:47 -0700
Message-ID: <20141023173847.GA22988@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
 <1414037002-25528-7-git-send-email-linux@roeck-us.net>
 <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
 <54488CE1.2000106@roeck-us.net>
 <20141023134706.GB25190@lunn.ch>
 <20141023162754.GA21343@roeck-us.net>
 <20141023165459.GE25190@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:36392 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbaJWRi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 13:38:59 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XhMLi-000XDi-Ng
	for netdev@vger.kernel.org; Thu, 23 Oct 2014 17:38:58 +0000
Content-Disposition: inline
In-Reply-To: <20141023165459.GE25190@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 06:54:59PM +0200, Andrew Lunn wrote:
> On Thu, Oct 23, 2014 at 09:27:55AM -0700, Guenter Roeck wrote:
> > On Thu, Oct 23, 2014 at 03:47:06PM +0200, Andrew Lunn wrote:
> > > > >>+static DEVICE_ATTR_RO(temp1_input);
> > > > >
> > > > >You probably want the number of temperature sensors to come fr=
om the
> > > > >switch driver, and support arbitrary number of temperature sen=
sors?
> > > >=20
> > > > In that case we would need the number of sensors, pass a sensor=
 index,
> > > > and create a dynamic number of attributes. The code would get m=
uch more
> > > > complex without real benefit unless there is such a chip=20
> > >=20
> > > We are two different use cases here:
> > >=20
> > > One switch chip with multiple temperature sensors
> >=20
> > I understand this case. However, quite frankly, I consider this qui=
te
> > unlikely to happen.
> >=20
> > > Multiple switch chips, each with its own temperature sensor.
> > >=20
> > I don't really see the problem. My understanding is that each of th=
ose
> > switch chips will instantiate itself, dsa_switch_setup will be call=
ed,
> > which will create a new hwmon device with its own sensors. That is
> > how all other hwmon devices do it, and it works just fine.
> > Why would that approach not work for switches in the dsa infrastruc=
ture ?
> > Am I missing something ?
> >=20
> > If the concern or assumption is that there can not be more than one
> > "temp1_input" attribute, here is an example from a system with a la=
rge
> > number of chips with temperature sensors.
> >=20
> > root@evo-xb49:/sys/class/hwmon# ls hwmon*/temp1_input
> > hwmon1/temp1_input   hwmon22/temp1_input  hwmon35/temp1_input
> > hwmon10/temp1_input  hwmon23/temp1_input  hwmon36/temp1_input
> > hwmon11/temp1_input  hwmon24/temp1_input  hwmon37/temp1_input
> > hwmon12/temp1_input  hwmon25/temp1_input  hwmon38/temp1_input
> > hwmon13/temp1_input  hwmon26/temp1_input  hwmon39/temp1_input
> > hwmon14/temp1_input  hwmon27/temp1_input  hwmon4/temp1_input
> > hwmon15/temp1_input  hwmon28/temp1_input  hwmon40/temp1_input
> > hwmon16/temp1_input  hwmon29/temp1_input  hwmon5/temp1_input
> > hwmon17/temp1_input  hwmon3/temp1_input   hwmon6/temp1_input
> > hwmon18/temp1_input  hwmon30/temp1_input  hwmon7/temp1_input
> > hwmon19/temp1_input  hwmon31/temp1_input  hwmon8/temp1_input
> > hwmon2/temp1_input   hwmon32/temp1_input  hwmon9/temp1_input
> > hwmon20/temp1_input  hwmon33/temp1_input
> > hwmon21/temp1_input  hwmon34/temp1_input
>=20
> So are you saying it is impossible to map a hwmon device to a physica=
l
> sensor? I can know there is a hotspot somewhere in my machine, but it
> is impossible to figure where that hot spot is using hwmon?
>=20
No, I am not saying that. The hwmon device's parent device will tell,
which is how it works for all other hwmon devices.

> > > If we are not doing the generic implementation now, how about avo=
iding
> > > an ABI break in the future, by hard coding the sensors with .0.0 =
on
> > > the end?
> >=20
> > I am a little lost. What would that be for, and what would the ABI =
breakage
> > be ?
>=20
> I assumed you would want to be able to map a temperature sensor to a
> switch package. You want a unique identifier, maybe its hwman name? S=
o
> name "dsa.0.0" would be the temperature sensor 0 on switch 0. If we
> don't name them like this now, whenever somebody does add support for
> this will cause that name to change and we have an ABI break.
>=20
Not really. Again, the parent device provides that information. libsens=
ors,
which is the preferred way of accessing sensors information from user s=
pace,
provides the parent device instance as part of the logical sensor devic=
e
name. In this case, the names will end up being dsa-isa-0000, dsa-isa-0=
001,
and so on. With your added tags it would be dsa.0.0-isa-0000, dsa.0.1-i=
sa-0001,
and so on. I don't see how this would add any value.

Also, temperature sensor 2 on switch 1 would be named temp2_input. Ther=
e would
not be a sepate hwmon device for the same chip.

This is all quite similar to, say, the CPU temperature, which is report=
ed=20
by the sensors command as

coretemp-isa-0000
Adapter: ISA adapter
Physical id 0:  +28.0=B0C  (high =3D +80.0=B0C, crit =3D +100.0=B0C)
Core 0:         +28.0=B0C  (high =3D +80.0=B0C, crit =3D +100.0=B0C)
Core 1:         +24.0=B0C  (high =3D +80.0=B0C, crit =3D +100.0=B0C)
Core 2:         +24.0=B0C  (high =3D +80.0=B0C, crit =3D +100.0=B0C)
Core 3:         +26.0=B0C  (high =3D +80.0=B0C, crit =3D +100.0=B0C)

on my system at home.

The raw data in this case is

name:coretemp
temp1_crit:100000
temp1_crit_alarm:0
temp1_input:31000
temp1_label:Physical id 0
temp1_max:80000
temp2_crit:100000
temp2_crit_alarm:0
temp2_input:31000
temp2_label:Core 0
temp2_max:80000
temp3_crit:100000
temp3_crit_alarm:0
temp3_input:26000
temp3_label:Core 1
temp3_max:80000
temp4_crit:100000
temp4_crit_alarm:0
temp4_input:24000
temp4_label:Core 2
temp4_max:80000
temp5_crit:100000
temp5_crit_alarm:0
temp5_input:27000
temp5_label:Core 3
temp5_max:80000

In this case, the parent device symlink is

device -> ../../../coretemp.0

A second CPU in a multi-CPU server system would have pretty much
the same information in its hwmon device directory, except that
the parent device would point to coretemp.1, and the sensors command
would display "coretemp-isa-0001". The "name" attribute for that
second CPU's hwmon device node would still be "coretemp".

Thanks,
Guenter
