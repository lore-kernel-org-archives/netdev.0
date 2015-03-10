From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: RFC: dsa: add support for multiple CPU ports
Date: Tue, 10 Mar 2015 12:01:29 -0700
Message-ID: <20150310190129.GB5636@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux@roeck-us.net, andrew@lunn.ch, jogo@openwrt.org,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56902 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbbCJTBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 15:01:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I=E2=80=99m writing a DSA driver for some QCA network switches already =
supported in
OpenWrt using swconfig. They connect to the CPU using MDIO for configur=
ation,
and xMII ports for data. The main difference with what is supported com=
es from
the fact that most of these switches actually have multiple xMII connec=
tions to
the same CPU. Something like this:
(extending the picture from http://lwn.net/Articles/302333/)

	+-----------+       +-----------+
	|           | RGMII |           |
	|       eth0+-------+           +------ 1000baseT MDI ("WAN")
	|        wan|       |  7-port   +------ 1000baseT MDI ("LAN1")
	|   CPU     |       |  ethernet +------ 1000baseT MDI ("LAN2")
	|           | RGMII |  switch   +------ 1000baseT MDI ("LAN3")
	|       eth1+-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
	|        lan|       |           |
	+-----------+       +-----------+
	          |   MDIO     |
	          \------------/

In a typical configuration, we configure the switch to isolate WAN & LA=
N from
each other.

The current DSA implementation is based on the assumption that there ca=
n be only
one xMII connection between the switch and the CPU (this switch port is=
 known as
the CPU port), which obviously doesn't work anymore in that case. So I'=
m trying
to figure out the best way to extend DSA to support these hardware.

Here is my proposal. I was hoping to get feedback before i get too much=
 down the
implementation path:
*add an optional phandle (cpu_dev) to the existing port device node, wh=
ich would
 reference the ethernet device node this port is connected to
*save the corresponding net_device in the "ports" field of "struct dsa_=
switch"
*instrument the network layer to be able to look-up which switch port i=
s
 connected to a particular net_device.

The third point would allow to perform operations currently limited to =
switch
ports. Typically, "ethtool -S eth0" could return the corresponding port=
's MIB
statistics in addition to the eth0 statistics.

Thoughts?

Thanks,
Mathieu
