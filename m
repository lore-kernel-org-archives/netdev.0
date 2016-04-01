From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 0/6] net: dsa: mv88e6131: HW bridging support for 6185
Date: Fri, 01 Apr 2016 09:38:42 -0400
Message-ID: <87oa9tphy5.fsf@ketchup.mtl.sfl>
References: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20160401124518.GB32554@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36495 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833AbcDANis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 09:38:48 -0400
In-Reply-To: <20160401124518.GB32554@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Thu, Mar 31, 2016 at 04:53:40PM -0400, Vivien Didelot wrote:
>> All packets passing through a switch of the 6185 family are currently all
>> directed to the CPU port. This means that port bridging is software driven.
>> 
>> To enable hardware bridging for this switch family, we need to implement the
>> port mapping operations, the FDB operations, and optionally the VLAN operations
>> (for 802.1Q and VLAN filtering aware systems).
>
> Hi Vivien
>
> I ran these patches with my tests and got some interesting
> results. Not sure if its a feature or a bug.
>
> Hardware looks like
>
> CPU<--->Switch0<--->Switch1<--->Switch2
>          6352        6352        6185 
>
> and the test sets up a bridge spanning the three switches. Packets are
> sent between ports on this bridge.

Please note that this patchset aims to add support for in-chip hardware
bridging within the 6185 only, i.e. your Switch2.

Can you setup a bridge spanning only 2 ports of Switch2 and confirm me
that the CPU port never sees any packet during a ping between these two
ports in any of the 3 configurations below?

If that is true, we're good to go with this patchset.

> I build three different kernel configurations for these tests:
>
> 1) 802.1D
> 2) 802.1D + 802.1Q
> 3) 802.1D + 802.1Q + VLAN filtering

Question: does 3) implies that you enable filtering with the following?

    # echo 0 > /sys/class/net/<bridge>/bridge/vlan_filtering

Otherwise the bridged ports remain with 802.1Q mode disabled, and thus
they should not care about any programmed hardware VLAN rules (VTU).

I'm not sure about what Linux does differently between 2) and 3) though.

> With all three configurations, cross chip frames get forwarded and go
> out the port they are supposed to. With kernel configuration 1) & 2),
> frames from switch2 go via the CPU and are SW bridged back to Switch0
> or Switch1.
>
> However, with kernel configuration 3), the CPU never sees the
> frames. The bridging is all happening in hardware. Why does this
> kernel configuration do something different?

With 3) and the vlan_filtering enabled, the switching logic is
VLAN-based, which means that the switch and its ports must care about
what is programmed in the VTU. The default VID of each port is important
here. Unless the user changed it, it is set with the content of
/sys/class/net/<bridge>/bridge/default_pvid.

With the VTU correctly programmed *in every switch*, that would make
sense that cross-chip hardware bridging works in this setup.

To verify that, you can try spanning a bridge over Switch0 and Switch2,
but not Switch1. I don't expect this to work since the VTU of Switch1
would not be programmed.

Thanks,
Vivien
