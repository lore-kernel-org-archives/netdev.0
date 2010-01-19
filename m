From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Tue, 19 Jan 2010 13:40:59 -0800
Message-ID: <20100119134059.63b355e4@nehalam>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
	<20100116.012004.166836523.davem@davemloft.net>
	<14385191E87B904DBD836449AA30269D580A76@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753021Ab0ASVlU@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D580A76@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Jan 2010 12:03:20 -0800
"Ha, Tristram" <Tristram.Ha@Micrel.Com> wrote:

> David Miller wrote:
> > From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
> > Date: Fri, 15 Jan 2010 18:57:59 -0800
> > 
> >> The KSZ8842 has a switch with lots of hardware configurations.  The =
> >> driver uses the proc system to allow users to configure the switch.
> >> If = this is not desired the whole thing can be removed by not
> calling the =
> >> init_proc() function.
> > 
> > I think there needs to be a serious discussion about how this driver
> uses bridge layer internals
> > by doing things like: 
> > 
> > +/* Needed for STP support. */
> > +#ifdef CONFIG_KSZ8842_STP
> > +#include <../net/bridge/br_private.h>
> > +#endif
> > 
> > and uses procfs to configure the ports.
> > 
> > Stephen please look this over and make suggestions for better ways to
> support and configure
> > these kinds of devices. 
> > 
> > Thanks.
> 
> I like to explain a little bit about this Spanning Tree Protocol
> support.
> 
> Micrel KSZ8842's 3-port switch and Micrel's other 5-port switches have
> port controls to enable/disable tx and rx and stop MAC address learning.
> They are supposed to help run STP more efficiently, but somebody needs
> to control those ports.
> 
> From my observation of how the brctl application controls the network
> devices when running STP, I know the kernel bridge puts all the devices
> under it in promiscuous mode and declares the state of each bridge port
> associated with the device blocked or forwarding depending on the BPDU
> frames received.  When the port is blocked, the device is still active
> and passes all frames to the host.  The bridge only looks at BPDU frames
> and drops all other frames.  It is better to just shut off the port.

Ok.

> From the time when the KSZ8842 driver was developed for the Linux 2.4
> kernel I looked for a kernel API to tell the bridge port's state so the
> device driver can shut off the port if necessary.  I could not find one
> and so I came up with this hack to look at the bridge port's structure
> directly.  It looks dangerous but is quite safe.  The driver only looks
> at the bridge port state variable and finds out the MAC address
> associated with the bridge device.  It can get the state definitions
> from the if_bridge header.  The private bridge structure may change in
> the future and break the code, but as kernel network interfaces are
> changing all the time, the driver just needs to be modified for the new
> version.  To avoid this situation, the kernel may need to export two
> functions to tell the bridge port state and bridge device address and
> put the prototypes in the if_bridge header.

There was one added for user level RSTP support.
RSTP is where Linux STP is headed, so adding more hooks into
existing STP is going backwards.

> Now for the driver implementation for STP support.  I programmed the
> switch's static MAC table to always pass the following frames to the
> host: BPDU frames with specific multicast address, broadcast frames,
> unicast frames with the device bridge's MAC address, and multicast
> frames with ICMPv6 multicast address.  All other frames are not passed
> to the host and are handled by the switch, forwarding each frame with
> its standard forwarding logic.  The port can be shut off if it is
> blocked and those frames will not pass through that port.  The host gets
> BPDU frames so that the bridge can determine each port's state.  The
> other broadcast, unicast, and multicast frames passed to the host are
> necessary if some other network devices want to communicate with the
> host.  As the forwarding is done by hardware rather than software,
> overall performance does increase.

What about LACP needed by bridging?

> I did verify the driver disables or enables the port appropriately when
> the bridge port state changes, but as I do not have the experience of
> running a full-scale Spanning Tree, I do not know if this hardware
> implementation behaves the same as the software one provided by the
> kernel and brctl.  I also did not try using VLAN.


-- 
