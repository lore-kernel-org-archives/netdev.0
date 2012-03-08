From: mdsmith@partychief.com
Subject: Re: Marvell DSA switch 88E6165 - CPU port in PHY mode
Date: Thu, 08 Mar 2012 14:57:57 +0100
Message-ID: <3e74a9ae578a434094cbb4036e0423d9@partychief.com>
References: <516EEEFC-DEEC-4CF5-BEF6-C5F3F86FCDD5@partychief.com>
 <20120305171224.GU12271@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpauth-vit.online.net ([88.190.253.76]:51347 "EHLO
	smtpauth-vit.online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab2CHN6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 08:58:00 -0500
In-Reply-To: <20120305171224.GU12271@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 2012-03-05 18:12, Lennert Buytenhek a =C3=A9crit=C2=A0:
> On Sun, Mar 04, 2012 at 03:11:53PM +0100, Matthew D. Smith wrote:
>
>> Hello - have a question about CPU port configuration in the net/dsa
>> driver code. Can't seem to work out how to bring up the CPU=20
>> connected
>> port on the switch (in our case this is Port 4 hardware strapped=20
>> with
>> its embedded PHY enabled).
>
> Hello!  I know of at least a couple of platforms that have a DSA chip
> connected to the CPU via an MDI type link, but I'm not sure why it's
> not working for you.  I'd suggest double-checking all the port 5 PHY
> registers against the chip documentation..
>

Hi - perhaps I misunderstood something about the built-in PHY on Port=20
4. We expected to see the PHY enabled in hardware by setting logic on=20
the P4_MODE pins. But this doesn't seem to be sufficient as I guess one=
=20
still has to enable the PHY in the driver code (like how you do it for=20
the LAN interfaces in net/dsa/slave.c).

So, after digging through the net/dsa source I found that there is=20
nothing explicit in the code to enable the CPU port if it needs a PHY. =
I=20
would like to say that way it is written assumes that it is always RGMI=
I=20
so I guess the other platforms you refer to above use customized=20
(non-mainline) driver code?

I have managed to get the DSA switch working by making the following=20
changes:

--- ./kernel/linux-source-3.2-csb1724/net/dsa/dsa.c
+++ ./kernel/linux-source-3.2-csb1724/net/dsa/dsa.c (unsaved)
@@ -124,7 +124,6 @@
  			}
  			dst->cpu_switch =3D index;
  			dst->cpu_port =3D i;
+			ds->phys_port_mask |=3D 1 << i;
  		} else if (!strcmp(name, "dsa")) {
  			ds->dsa_port_mask |=3D 1 << i;
  		} else {

--- ./kernel/linux-source-3.2-csb1724/net/dsa/mv88e6123_61_65.c
+++ ./kernel/linux-source-3.2-csb1724/net/dsa/mv88e6123_61_65.c=20
(unsaved)
@@ -193,7 +193,12 @@
  	 * full duplex.
  	 */
  	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p)) {
-		REG_WRITE(addr, 0x01, 0x003e);
+		REG_WRITE(addr, 0x01, 0x0003);
  	}
  	else
  		REG_WRITE(addr, 0x01, 0x0003);

Basically this tells the DSA driver to create an interface for the CPU=20
port. Perhaps overkill but it does bring up the built-in PHY in the sam=
e=20
way it brings up the LAN slave interfaces. As slave.c sets autoneg on I=
=20
needed to change the register value from 1000FD to autoneg. Likewise fo=
r=20
the CPU GE01 port in my platform init code.

I don't really like this, but it works. Is there a better way?

regards
Matthew
