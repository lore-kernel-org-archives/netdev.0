From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 27 Apr 2007 08:45:41 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902BCE1E4@orsmsx414.amr.corp.intel.com>
References: <1177686598.4059.79.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63435 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755905AbXD0Ppo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 11:45:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1177686598.4059.79.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, 2007-26-04 at 09:30 -0700, Waskiewicz Jr, Peter P wrote:
> > > jamal wrote:
> > > > On Wed, 2007-25-04 at 10:45 -0700, Waskiewicz Jr, Peter P wrote:
> 
> > We have plans to write a new qdisc that has no priority 
> given to any 
> > skb's being sent to the driver.  The reasoning for providing a 
> > multiqueue mode for PRIO is it's a well-known qdisc, so the 
> hope was 
> > people could quickly associate with what's going on.  The other 
> > reasoning is we wanted to provide a way to prioritize 
> various network 
> > flows (ala PRIO), and since hardware doesn't currently exist that 
> > provides flow prioritization, we decided to allow it to continue 
> > happening in software.
> > 
> 
> Reading the above validates my fears that we have some strong 
> differences (refer to my email to Patrick). To be fair to 
> you, i would have to look at your patches. Now i am actually 
> thinking not to look at them at all incase they influence 
> me;-> I think the thing for me to do is provide alternative 
> patches and then we can have smoother discussion.
> The way i see it is you dont touch any qdisc code. qdiscs 
> that are provided by Linux cover a majority of those provided 
> by hardware (Heck, I have was involved on an ethernet switch 
> chip from your company that provided strict prion multiqueues 
> in hardware and didnt need to touch the qdisc code)

I agree, that to be fair for discussing the code that you should look at
the patches before drawing conclusions.  I appreciate the fact you have
a different idea for your approach for multiqueue, but without having
specific things to discuss in terms of implementation, I'm at a loss for
what you want to see done.  These patches have been released in the
community for a few months now, and the general approach has been
accepted for the most part.

That being said, my approach was to provide an API for drivers to
implement multiqueue support.  We originally went with an idea to do the
multiqueue support in the driver.  However, many questions came up that
were answered by pulling things into the qdisc / netdev layer.
Specifically, if all the multiqueue code is in the driver, how would you
ensure one flow of traffic (say on queue 0) doesn't interfere with
another flow (say on queue 1)?  If queue 1 on your NIC ran out of
descriptors, the driver will set dev->queue_lock to __LINK_STATE_XOFF,
which will cause all entry points into the scheduler to stop (i.e. - no
more packets going to the NIC).  That will also shut down queue 0.  As
soon as that happens, that is not multiqueue network support.  The other
question was how to classify traffic.  We're proposing to use tc filters
to do it, since the user has control over that; having flexibility to
meet different network needs is a plus.  We had tried doing queue
selection in the driver, and it killed performance.  Hence why we pulled
it into the qdisc layer.

> 
> > > 
> > > > The driver should be configurable to be X num of queues via
> > > probably
> > > > ethtool. It should default to single ring to maintain 
> old behavior.
> > > 
> > > 
> > > That would probably make sense in either case.
> > 
> > This shouldn't be something enforced by the OS, rather, an 
> > implementation detail for the driver you write.  If you 
> want this to 
> > be something to be configured at run-time, on the fly, then the OS 
> > would need to support it.  However, I'd rather see people try the 
> > multiqueue support as-is first to make sure the simple 
> things work as 
> > expected, then we can get into run-time reconfiguration 
> issues (like 
> > queue draining if you shrink available queues, etc.).  This 
> will also 
> > require some heavy lifting by the driver to tear down queues, etc.
> > 
> 
> It could be probably a module insertion/boot time operation.

This is how the API that I am proposing works.

> 
> > > 
> > > > Ok, i see; none of those other intel people put you through
> > > the hazing
> > > > yet? ;-> This is a netdev matter - so i have taken off lkml
> > > > 
> > 
> > I appreciate the desire to lower clutter from mailing 
> lists, but I see 
> > 'tc' as a kernel configuration utility, and as such, people should 
> > know what we're doing outside of netdev, IMO.  But I'm fine with 
> > keeping this off lkml if that's what people think.
> > 
> 
> All of netdev has to do with the kernel - that doesnt justify 
> cross posting.
> People interested in network related subsystem development 
> will subscribe to netdev. Interest in scsi =. subscribe to 
> scsi mailing lists etc.
> 
> 
> cheers,
> 
> 
