From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Wed, 30 Oct 2013 15:28:04 +0100
Message-ID: <1383143284.29021.48.camel@sakura.staff.proxad.net>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
		 <1382466229-15123-2-git-send-email-f.fainelli@gmail.com>
		 <5266D7D6.9000309@intel.com>
		 <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com>
		 <20131022202537.GA16336@hmsreliant.think-freely.org>
		 <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>
		 <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org>
		 <5267C6B9.4000704@mojatatu.com>
	 <1383088365.16822.22.camel@sakura.staff.proxad.net>
	 <5270F282.6000708@mojatatu.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:53603 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab3J3O2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 10:28:06 -0400
In-Reply-To: <5270F282.6000708@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2013-10-30 at 07:50 -0400, Jamal Hadi Salim wrote:

> The important part is all the APIs stay consistent. I can use
> same netlink calls. ifconfig works.
> iproute2 works. People have written books on this stuff - we dont

these books usually start by telling people to assign IP address to
interfaces, not applicable here.

> If i can get stats by doing ifconfig - that should provide illusion that
> the netdevice is sending/receiving packets.

4 separated netdevices looks like 4 ethernet segments to me, and nothing
will prevent me from setting a different ip network on each device.

ENOTSUPP cannot be returned by ndo_start_xmit, the ability for a
netdevice to be able to receive/send packet from host is IMO
fundamental.

> This is a good arguement.
> Can we hear a little more about this?

see this kind of old threads:

http://rt2x00.serialmonkey.com/phpBB/viewtopic.php?f=5&t=4378
http://www.linuxquestions.org/questions/linux-networking-3/what-is-wmaster0-728708/
http://forums.debian.net/viewtopic.php?p=219440

> I think that would be a reasonable thing to do if it becomes
> necessary.

with rough naming:

- struct netdevice
- struct netdev_queue
- struct network_port (something to call ethtool on)
- struct bridge_dev (something you create/destroy vlan on, control FDB)
- struct bridge_port (something you set path cost on, ...)
- struct sw_bridge_dev (netdevice + underlying bridge_dev)
- struct sw_bridge_port (netdevice + underlying bridge_port)

old netdevice => (netdevice + netdev_queue * x + network_port)

ethtool works on netdevice or network_port

brctl addbr/addif creates sw_bridge_dev/sw_bridge_port, other commands
work on bridge_dev/bridge_port

drivers can register bridge_dev / bridge_port / network_port

simple case of a system with single ethernet mac & directly attached 4
ports switch:

netdevice: eth0
bridge_dev: hwbr0
bridge_port: hwbr0p0, hwbr0p1, hwbr0p2, hwbr0p3
network ports: eth0np0, hwbr0np0, hwbr0np1, hwbr0np2, hwbr0np3

ifconfig, ip link show only eth0
brctl show hwbr0
ethtool works on eth0 or eth0p0, hwbr0npX

-- 
Maxime
