From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/4] net: dsa: mv88e6xxx: fix hardware bridging
Date: Thu, 15 Oct 2015 00:46:17 +0200
Message-ID: <20151014224617.GA10146@lunn.ch>
References: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40039 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156AbbJNWqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 18:46:20 -0400
Content-Disposition: inline
In-Reply-To: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 11, 2015 at 06:08:34PM -0400, Vivien Didelot wrote:
> DSA and its drivers currently hook the NETDEV_CHANGEUPPER net_device event in
> order to configure the VLAN map of every port.
> 
> This VLAN map is a feature of these switch chips to hardcode and restrict which
> output ports a given input port can egress frames to.
> 
> A Linux bridge is a simple untagged VLAN propagated by the bridge code itself.
> With a proper 802.1Q support, a driver does not need this hook anymore, and
> will simply program the related VLAN object.
> 
> This patchset improves the hardware bridging code in the mv88e6xxx driver with
> a strict 802.1Q mode.

Hi Vivien

I just tested this as part of net-next/master, and found a problem....

If i do:

ip link set lan0 up
ip addr add 192.168.10.2/24 dev lan0

It will not ping. Looking in sys/kernel/debug/dsa0/stats i see
broadcast packets, probably ARP, being received at the port.
But they are not being forwarded out the CPU port.

If however i do

brctl addbr br0
brctl addif br0 lan0
ip addr add 192.168.10.2/24 dev br0
ip link set br0 up

i can ping.

So it looks like we are too restrictive by default. You should be able
to use interfaces as they are, without a bridge.

   Andrew
