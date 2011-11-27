From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Sun, 27 Nov 2011 20:34:38 +0100
Message-ID: <20111127193438.GV795@wantstofly.org>
References: <20111123075433.GA7928@gondor.apana.org.au>
 <1322035942.1298.56.camel@edumazet-laptop>
 <1322052463.2039.135.camel@mojatatu>
 <1322052938.17693.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1322055858.2039.188.camel@mojatatu>
 <4ECD19AC.8090505@intel.com>
 <1322140779.1949.191.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:49583 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358Ab1K0Tel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 14:34:41 -0500
Content-Disposition: inline
In-Reply-To: <1322140779.1949.191.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2011 at 08:19:39AM -0500, Jamal Hadi Salim wrote:

> > I assume you mean something like setup_tc() which we have
> > today to call into into the driver at qdisc create time. This
> > happens with the RTNL held. I don't see any reason not to also
> > call into the hardware on qdisc_change() I just haven't done
> > it yet.
> 
> Yes, the operative piece is "also". In other words, I should be
> able to run tc qdisc blah and not see the difference.
> In the distant past what i have done in the case of absence of software
> support is to write the "hwardware" scheduler in the kernel. If we
> already have the hardware support, then there is no need for that step.
> Let tc be responsible for controlling this "hardware" qdisc. It doesnt
> talk to the hardware.
> A user space helper app listens to things being added and deleted by
> tc in the kernel and synchronizes them via a driver-specific call.
> Different drivers tend to have different lower layer "hard-coded" 
> ways of setting up the hardware; so you may end up with different
> backends.
> The challenge is synchronizing stats.
> 
> > Although I'm pretty sure we don't want to add a new ndo_ops
> > ever time we have some hardware feature we want to expose.
> > Assuming there are more than 1 or 2 hw features. So maybe
> > we could convert to something more generic. A setup_qos()
> > call that passes an skb with nl attributes.
> 
> You only need one - call it "hardware_setup" so you can do
> other esoteric things with it.
> 
> > Is that what you were asking?
> 
> Something like that. I described how i did it - but thats because
> I wanted to make zero changes to the kernel. It is better to have
> kernel support of some sort but you dont want to do too much
> otherwise you start adding a lot of shit in the kernel like
> the infiniband guys. Have a user space helper when in doubt.
> I almost forgot, a good example (of good work in the kernel already)
> you wanna take  a look at is something Lennert (added to CC) did for
> Marvel chips (i think it is called DSA). 

The problem that net/dsa/ tries to solve is that of managing
multi-port hardware ethernet switch chips (such as those found in
wifi routers and such).

The basic idea was to expose each port on the switch chip as a
separate Linux netdev, and to mirror the Linux networking config
into the switch chip, to enable offloading of as many tasks as
possible to the hardware.

E.g., adding two of the ports on the switch to the same bridge port
group with brctl should program the switch chip to use the same
address and VLAN database for the two ports, and enable forwarding
of packets in hardware.  A working-but-not-very-clean implementation
of this is at:

	http://patchwork.ozlabs.org/patch/16578/

(And things like enabling promiscuous mode on a subinterface can be
emulated by enabling port mirroring from the given port to the CPU
port, etc.)

There's a bunch of features that the hardware supports that have no
analog in the Linux networking stack (e.g. port mirroring a non-CPU
port to another non-CPU port), which is similar to your scenario, I
guess.  For those, we mostly end up with some ad-hoc sysfs interface
or so, which is partly because there probably isn't enough interest
in having a generic way of doing this in the upstream kernel.
