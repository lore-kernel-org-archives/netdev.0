From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Wed, 11 Mar 2015 16:37:40 -0700
Message-ID: <20150311233738.GA5566@codeaurora.org>
References: <20150310190129.GB5636@codeaurora.org>
 <20150310193151.GE10838@lunn.ch>
 <20150310204021.GA2740@codeaurora.org>
 <CAGVrzcZcLgMWuNJ9R_izuBRyyY21=ZJw+2Dk8RfxijGd2fMXNQ@mail.gmail.com>
 <20150311011802.GA10875@codeaurora.org>
 <20150311133057.GA9601@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Jonas Gorski <jogo@openwrt.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53490 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbbCKXhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 19:37:43 -0400
Content-Disposition: inline
In-Reply-To: <20150311133057.GA9601@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 02:30:57PM +0100, Andrew Lunn wrote:
> > We already have existing interface for eth0/eth1. Maybe we should
> > consider allowing them to be bridge. User configuration would look like
> > this:
> > 
> > brctl addbr br-lan
> > brctl addif br-lan eth1
> > brctl addif br-lan lan1
> > brctl addif br-lan lan2
> > brctl addif br-lan lan3
> > brctl addif br-lan lan4
> 
> Think about this from the perspective of somebody how does not know
> there is a switch.  When i look at this, to me it means packets from
> lan1, lan2, lan3, lan4 and eth1 are bridged together. So we are going
> to get packets sent out eth1 without a tag on it, and the switch is
> very likely to drop it, since the port is in a mode which expects a
> tag. You are not using the brctl command with its normal meaning,
> which is bad.
> 
> Configuring this at the bridge layer is also wrong. What conduit a DSA
> slave interfaces uses is a DSA layer issue.
> 
> Before we can come up with a nice solution, i think we first need to
> understand what the switches are capable off. If trunking does work,
> it is a relatively nice system for the user to configure, in that
> there is nothing for the user to configure! Assuming the switch can do
> reasonable load balancing, we also get near optimal usage of the two
> conduits.
> 

Agreed. The switches I'm talking about (QCA8xxx/AR8xxx) don't support
a mode which would allow them to use all the CPU ports as one logical
bonding interface. I'm not sure how many of the switches in OpenWrt do.

I know some of these switches don't even support tagging. So I'd be
surprised if they're all capable of bonding.

The base usage scenario for these switches is using port based vlan.
The user knows very well there is a switch (OpenWrt even has a webpage
for it), and he provides a static configuration by telling it how he
want the ports to be connected to each other.
In the previous example, it would be something like creating 2 logical
switches: P0/P1 and P2/P3/P4/P5/P6. Or it could be something like
(lan1 - P0/P1/P2) and (lan2 - P3/P4) and (lan3 - P5/P6). Or anything else.
That's the mode that OpenWrt is using in pretty much all its target. It is
also the way they get configured in most home routers in general.

I understand the value of using bonding. But we should also have a way to
configure more simple hardware - which is typically using port based vlan.

> I don't know when i will have time to play with this, and if somebody
> comes along with a better idea, i'm very open to adopting that idea
> over mine.

I think DSA should probably support both. I think it should allow
bonding for switches who support it, but it should also allow for port
based vlan mapped by the user.

Another way to support these could be to make the cpu port "optional".
These switches would have no cpu port, all the ports would have a
net_device (including the xMII ones). They would get bridged, and
packets that are sent to interface connected to cpu would be dropped by
the switch xmit function.
I didn't try that, but it should work.

> 
>       Andrew
