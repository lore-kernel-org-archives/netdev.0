From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH RFC 2/3] dsa: Add support for multiple cpu ports.
Date: Sat, 30 May 2015 14:09:55 +0200
Message-ID: <871thyfer0.fsf@nemi.mork.no>
References: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
	<1432926814-22648-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>, mathieu@codeaurora.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51887 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757563AbbE3MKK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 08:10:10 -0400
In-Reply-To: <1432926814-22648-3-git-send-email-andrew@lunn.ch> (Andrew Lunn's
	message of "Fri, 29 May 2015 21:13:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> Some boards have two CPU interfaces connected to the switch, e.g. WiF=
i
> access points, with 1 port labeled WAN, 4 ports labeled lan1-lan4, an=
d
> two port connected to the SoC.
>
> This patch extends DSA to allows both CPU ports to be used. The "cpu"
> node in the DSA tree can now have a phandle to the host interface it
> connects to. Each user port can have a phandle to a cpu port which
> should be used for traffic between the port and the CPU. Thus simple
> load sharing over the two CPU ports can be achieved.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  Documentation/devicetree/bindings/net/dsa/dsa.txt |  66 ++++++++++++=
-
>  drivers/net/dsa/mv88e6xxx.c                       |   8 +-
>  include/net/dsa.h                                 |  28 +++++-
>  net/dsa/dsa.c                                     | 109 ++++++++++++=
++++++----
>  net/dsa/dsa_priv.h                                |   6 ++
>  net/dsa/slave.c                                   |  10 +-
>  net/dsa/tag_brcm.c                                |   2 +-
>  net/dsa/tag_dsa.c                                 |   2 +-
>  net/dsa/tag_edsa.c                                |   2 +-
>  net/dsa/tag_trailer.c                             |   2 +-
>  10 files changed, 206 insertions(+), 29 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Docu=
mentation/devicetree/bindings/net/dsa/dsa.txt
> index f0b4cd72411d..34f7f18026e5 100644
> --- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
> +++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> @@ -58,13 +58,24 @@ Optionnal property:
>  			  Documentation/devicetree/bindings/net/ethernet.txt
>  			  for details.
> =20
> +- ethernet		: Optional for "cpu" ports. A phandle to an ethernet
> +                          device which will be used by this CPU port=
 for
> +			  passing packets to/from the host. If not present,
> +			  the port will use the "dsa,ethernet" property
> +			  defined above.
> +
> +- cpu			: Option for non "cpu"/"dsa" ports. A phandle to a
> +			  "cpu" port, which will be used for passing packets
> +			  from this port to the host. If not present, the first
> +			  "cpu" port will be used.
> +

I'm in deep water here, but this scheme sounds a little too static to m=
e
if I understand your proposal correctly.  Why would you want to create =
a
static mapping of CPU ports to external ports for any given device?  To
me, that's part of the switch VLAN configuration.

My experience with these devices is limited to running OpenWRT on an
WRT1900AC, having a Marvell 88E6172 switch.  And using the OpenWRT
switch API of course. There I've found it very useful to be able to mix
and match the two CPU ports as I like with the external ports. How you
want the CPU ports used is not as much depeing on device properties as
on your network configuration, IMHO.  How many and which links do you
have?  What bandwith are they? Trunks or not?  Etc.  You cannot describ=
e
these answers as device properties, because they aren't.

You can currently configure this as you like in OpenWRT using their
usual swconfig tool.  The CPU ports are added or removed from VLANs lik=
e
any other port on the switch, and that feels very natural for me as an
end user.  The only distinction necessary to know, is your 'ethernet'
property above:  Which host device is this switch port connected to.

So I wonder: Do you plan to put all of the switch config into DT?  Wher=
e
does that stop? How about trunking between external ports and CPU ports=
?
Will every VLAN in the trunk have to go into DT too?


Bj=C3=B8rn
