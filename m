From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 23:04:34 +0200
Message-ID: <20110628210434.GD2121496@jupiter.n2.diac24.net>
References: <BANLkTin4XOCmpFaETsjkYb2kk+psZUBKcA@mail.gmail.com>
 <BANLkTimD+fvhrhpc+kPXt1qMnQvVi2dw=Q@mail.gmail.com>
 <20110628150257.GB126252@jupiter.n2.diac24.net>
 <20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
 <20110628160018.GC126252@jupiter.n2.diac24.net>
 <BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
 <20110628185811.GA2121496@jupiter.n2.diac24.net>
 <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
 <20110628202200.GB2121496@jupiter.n2.diac24.net>
 <BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:41455 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720Ab1F1VEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 17:04:44 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2011 at 09:54:01PM +0100, Nick Carter wrote:
> > 'reinject' isn't possible when it hits that code path - which is pretty
> > much why I'm saying we should be forwarding everything in the non-STP
> > case.
> I'm not sure I like this turn off STP and suddenly start forwarding
> random groups.  There is no connection between wanting STP on / off
> and forwarding pae on / off.

I beg to differ, there very much is. You never ever ever want to be
running STP with 802.1X packets passing through... some client will shut
down your upstream port, your STP will break and you will die in a fire.

The general idea, though, is that a STP-enabled switch is an intelligent
switch. And an intelligent switch can speak all those pesky small 
side-dish protocols.

With STP disabled on the other hand, it depends on site policy. Now
policy...

> There is no dependencies between the protocols.
> Also on reflection I think a knob per mac group would be better.

.... policy can be done nice and good with ebtables. You can match the
groups you want, or the protocols, or the phase of the moon.

> We are only interested in 3 and if I enable pae forwarding so I can
> connect virtual machine supplicants, i don't then want to turn on LDP
> forwarding which will needlessly hit my virtual machines.
> So how about sysfs
> ../bridge/pae_forwarding
> ../bridge/ldp_forwarding
> ../bridge/mvrp_forwarding

It's not like either LLDP or MVRP will trash your VMs. Those protocols
send a packet once per a few seconds.

MVRP is interesting for the STP-enabled case though. I'm not aware of
any userspace *VRP implementations, and dropping *VRP without an
userspace daemon to speak it on our behalf means we're creating a *VRP
border/break.

I would however say that doing an userspace *VRP implementation is a
better solution than kernel hacks for this particular case.

> > (Some quick googling reveals that hardware switch chips special-drop
> > 01:80:c2:00:00:01 [802.3x/pause] and :02 [802.3ad/lacp] and nothing
> > else - for the dumb ones anyway. It also seems like the match for pause
> > frames usually works on the address, not on the protocol field like we
> > do it...)
> 'Enterprise' switches drop :03 [802.1x]

They also speak STP, see above about never STP+1X :)

-David

