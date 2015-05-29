From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC 0/3] DSA and Marvell 88E6352 802.1q support
Date: Thu, 28 May 2015 22:02:57 -0700
Message-ID: <CAE4R7bA43Jg5e+DSySvG4X2ka0CXEk9K6eVv5fdN37EcLBoF_A@mail.gmail.com>
References: <556723FF.7030606@roeck-us.net>
	<1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35910 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbbE2FC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 01:02:58 -0400
Received: by qkx62 with SMTP id 62so38760868qkx.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 22:02:57 -0700 (PDT)
In-Reply-To: <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 2:37 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> This RFC is based on v4.1-rc3.
>
> It is meant to get a glance to the commits responsible to implement the
> necessary NDOs between DSA and the Marvell 88E6352 switch driver.
>
> With this support, I am able to create VLANs with (un)tagged ports, setting
> their default VID, from a bridge.
>
> To create a bridge containing all switch ports, with a VLAN ID 400, swp2 and
> swp3 untagged (pvid), and swp4 tagged, the userspace commands look like this:
>
>     ip link add name br0 type bridge
>     [...]
>     ip link set dev swp2 up master br0
>     [...]
>     bridge vlan add vid 400 pvid untagged dev swp2
>     bridge vlan add vid 400 pvid untagged dev swp3
>     bridge vlan add vid 400 dev swp4
>     [...]
>     ip link add link br0 name br0.400 type vlan id 400
>     [...]
>     bridge vlan add dev br0 vid 400 self
>
> The code is currently being rebased to the latest net-next/master.
>
> Seems like the way to go now is through switchdev attr getter/setter...

Indeed, for dsa_slave you should be able to port this to switchdev and
set your ndo_bridge_setlink/dellink handlers to
switchdev_port_bridge_setlink/dellink.  (And also implement the
switchdev ops for vlans).

If you use switchdev_port_bridge_setlink/dellink, you shouldn't need
to implement ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid at all.  The
setlink/dellink callbacks will give the same info (and more, e.g.
pvid, untagged flags) and you'll automatically get support for stacked
drivers, for example if you bonded swp2/3 and then included that bond
in your vlan bridge.  Your commands will be slightly modified: when
adding the vid to the port, specify master and self:

bridge vlan add vid 400 dev swp4 master self

-scott
