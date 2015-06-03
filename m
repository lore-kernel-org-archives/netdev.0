From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 7/9] net: dsa: mv88e6352: lock CPU port from learning
 addresses
Date: Wed, 3 Jun 2015 22:51:12 +0200
Message-ID: <20150603205112.GD22878@lunn.ch>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1433208470-25338-8-git-send-email-vivien.didelot@savoirfairelinux.com>
 <556DBCA4.10203@roeck-us.net>
 <1317462817.952931.1433293575321.JavaMail.zimbra@savoirfairelinux.com>
 <20150603022451.GB932@roeck-us.net>
 <CAFXsbZo7DAhbUErMfKas_KUtXMHTURgOxwz-GSr=fuAHLWToEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	David <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	=?iso-8859-1?Q?J=E9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	kernel <kernel@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50822 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755202AbbFCU4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 16:56:44 -0400
Content-Disposition: inline
In-Reply-To: <CAFXsbZo7DAhbUErMfKas_KUtXMHTURgOxwz-GSr=fuAHLWToEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2015 at 07:31:56PM -0700, Chris Healy wrote:
> Guenter,
> 
> That's a very valid concern.  I have a configuration with a 6352 controlled
> by a low end ARM core with a 100mbps connection on the CPU port.  This
> switch needs to support passing multicast streams that are more than
> 100mbps on GigE links.  (The ARM does not need to consume the multicast, it
> just manages the switch.)

Hi Chris

Thinking out load here...

There are two use cases:

1) Without bridging. The switch ports are seen as host interfaces.
   Host interfaces are expected to accept packets for there own MAC
   address and the broadcast address. Additional multicast addresses
   can be added and the ndo_set_rx_mode() method of the driver is
   called to get to hardware to accept these MAC addresses. DSA has an
   implementation of ndo_set_rx_mode(), but all it does is ask the
   kernel to do the filtering. We need to extend it to program the
   hardware to only pass frames which match the addresses on the
   lists.  This should be just adding some static forwarding
   entries. Then, so long as an application on the host does not join
   any of the multicast groups, the frames should never be passed to
   the host.

2) With bridging, things are a bit different. Interfaces in a bridge
   are expected to be in promiscuous mode, receiving everything and
   passing it to the bridge. With the hardware bridging support
   Guenter added, we can off load unicast forwarding to the hardware.
   However, we currently don't have full support for off-loading of
   multicast. This falls into at a few different pieces:

   a) Get the hardware to do a dumb flood to all ports in the bridge
      group. However, the host is a member of the bridge, so it will
      still get a copy of all the packets. It has to, there could be
      members of the multicast groups on interfaces not accelerated by
      the hardware.

   b) Add limited IGMP snooping, so that the host bridge knows if it
      needs to see multicast frames for a specific MAC address from
      DSA interfaces or not, and program this into the hardware to
      reduce the load on the host.

   c) Add full IGMP snooping, so that the hardware no longer performs
      dumb flooding, but only forwards out ports where there has been
      an interest in the frames.

   Until we get at least b) implemented, i would expect all multicast
   packets to hit the host. In order to be correct in the general
   case, they have to.

   Andrew
