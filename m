From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 14:21:22 -0400
Message-ID: <20140326182122.GC31370@hmsreliant.think-freely.org>
References: <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
 <20140326111031.GB31370@hmsreliant.think-freely.org>
 <20140326112903.GG15723@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43285 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbaCZSWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 14:22:03 -0400
Content-Disposition: inline
In-Reply-To: <20140326112903.GG15723@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 11:29:03AM +0000, Thomas Graf wrote:
> On 03/26/14 at 07:10am, Neil Horman wrote:
> > But by creating net_devices that are registered in the current fashion we
> > implicitly agree to levels of functionality that are assumed to be available and
> > as such are not within the purview of a net_device to reject.  E.g. it is
> > assumed that a netdevice can filter frames using iptables/ebtables, limit
> > traffic using tc, etc.
> 
> I think this is the point where we disagree. We already have several
> devices that hook into the rx handler and never have their packets
> pass through either iptables or ebtables. Better examples of this are
> macvtap or OVS.
> 
Yes, this is the point of contention, you're right.  And you're also correct in
that we do have several devices that bypass the network stack on the.  My
concern is that, in all of those cases its being bypassed because we know that
other software is handling that functionality (in the case of macvtap we know
that we're passing it off to a guest to be processed via the full network stack
available in the guest, and in the case of OVS, we know that we are passing
traffic to a software defined switch for handling).  In the case of having a
switch fabric available, we're explicitly hiding the fact that traffic we are
passing between ports never touches the cpu, and that just rubs me the wrong
way.  I suppose I'm looking at switch fabrics in the same way that I look at
TOE.  In offloading forwaring functionality we remove from the cpu activity
which an administrator may reasonably expect to see handled in the cpu, but they
wont.  In the case of macvlan, the admin knows thats a macvlan device, and
packet handling for frames bound to it occurs in the guest.  for OVS, packets
recieved on the cpu with the proper encapsulation are clearly handled in the
OVS bridge.  But in the case of a hardware switch, all they see are 4 net device
interfaces that seem like any other net device.  

Perhaps I need to let go of this notion, but it seems to me, if we're going to
allow cpu stack bypass, then we need to make that very obvious to an
administrator.  Maybe a flag like IFF_L2ONLY (or perhaps better still
IFF_LOCALDATAONLY, to indicate that only data directly addressed to the
interface, or to a multi/broadcast address will be received by it, despite the
promisc or other settings is sufficient). I really don't know.  Thats where my
hang up is though.

> What should happen is that these devices are given a chance to implement
> the ACL in their own flow table. If no such facility exists, the rule
> insertion should fall back to software mode if that is possible (an
> OF capable switching chip could insert a 'upcall' flow), or as
> a last resort return an error to indicate EOPNOTSUPP.
> 
> > And if a switch fabric is short cutting traffic so that
> > the cpu doesn't see them, those bits of functionality won't work.  I agree we
> > can likely work around that with richer feature capabilities, but such an
> > infrastructure would both require extensive kernel changes to fully cover the
> > set of existing features at a sufficient granularity, and require user space
> > changes to grok the feature set of a given device.  Not saying its impossibible
> > or even undesireable mind you, just thats its not any less invasive than what
> > I'm proposing.
> 
> What I don't understand at this point is how hiding the ports behind
> a master device would buy us anything. We would still need to abstract
> the filtering capabilities of the ports at some level and hiding that
> behind existing tools seems to most convenient way.
> 

If we agree that inconsistent frame reception / stack bypass is acceptable, then
hiding the ports buys us nothing.  My only goal with that suggestion was to
differentiate ports on a switch device so that the ports were differentiated in
such a way as to make it clear that they didn't behave like typical NIC ports
that were meant to receive host terminated traffic only.  If the consensus is
to allows sparse reception of forwarded traffic at the cpu, then no, its not
worthwhile and can be ignored.

Best
Neil
