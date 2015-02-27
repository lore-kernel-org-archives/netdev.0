From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Flows! Offload them.
Date: Fri, 27 Feb 2015 13:37:29 -0500
Message-ID: <20150227183729.GD1611@hmsreliant.think-freely.org>
References: <20150226074214.GF2074@nanopsycho.orion>
 <54EF74E0.7060502@gmail.com>
 <54EF8911.9080203@intel.com>
 <54EF9401.6080405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	jpettit@nicira.com, joestringer@nicira.com, jhs@mojatatu.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, simon.horman@netronome.com,
	shrijeet@gmail.com, gospo@cumulusnetworks.com, bcrl@kvack.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53924 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbbB0Shw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 13:37:52 -0500
Content-Disposition: inline
In-Reply-To: <54EF9401.6080405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 01:45:37PM -0800, Florian Fainelli wrote:
> On 26/02/15 12:58, John Fastabend wrote:
> > On 02/26/2015 11:32 AM, Florian Fainelli wrote:
> >> Hi Jiri,
> >>
> >> On 25/02/15 23:42, Jiri Pirko wrote:
> >>> Hello everyone.
> >>>
> >>> I would like to discuss big next step for switch offloading. Probably
> >>> the most complicated one we have so far. That is to be able to offload flows.
> >>> Leaving nftables aside for a moment, I see 2 big usecases:
> >>> - TC filters and actions offload.
> >>> - OVS key match and actions offload.
> >>>
> >>> I think it might sense to ignore OVS for now. The reason is ongoing efford
> >>> to replace OVS kernel datapath with TC subsystem. After that, OVS offload
> >>> will not longer be needed and we'll get it for free with TC offload
> >>> implementation. So we can focus on TC now.
> >>
> >> What is not necessarily clear to me, is if we leave nftables aside for
> >> now from flow offloading, does that mean the entire flow offloading will
> >> now be controlled and going with the TC subsystem necessarily?
> >>
> >> I am not questioning the choice for TC, I am just wondering if
> >> ultimately there is the need for a lower layer, which is below, such
> >> that both tc and e.g: nftables can benefit from it?
> > 
> > My thinking on this is to use the FlowAPI ndo_ops as the bottom layer.
> > What I would much prefer (having to actually write drivers) is that
> > we have one API to the driver and tc, nft, whatever map onto that API.
> 
> Ok, I think this is indeed the right approach.
> 
> > 
> > Then my driver implements a ndo_set_flow op and a ndo_del_flow op. What
> > I'm working on now is the map from tc onto the flow API I'm hoping this
> > sounds like a good idea to folks.
> 
> Sounds good to me.
> 
> > 
> > Neil, suggested we might need a reservation concept where tc can reserve
> > some space in a TCAM, similarly nft can reserve some space. Also I have
> > applications in user space that want to reserve some space to offload
> > their specific data structures. This idea seems like a good one to me.
> 
> Humm, I guess the question is how and when do we do this reservation, is
> it upon first potential access from e.g: tc or nft to an offloading
> capable hardware, and if so, upon first attempt to offload an operation?
> 
I think we do this using administrative direction.  It seems to me like the
approach would be to enhance tools like iproute2 to indicate the desire to
offload various functions to hardware.  That is to say, I could envision a
command like the following:

tc offload dev eth0 enable policy strict 

This would cause the tc subsytem to call through johns flow api to reserve
whatever hw dataplace resources are needed to fully offload all the tc
qdiscs/actions/filters to the hardware, using the strict policy (strict being a
made up token to indicate a policy in which the entirety of the tc state for
that device should be moved into the hardware or fail).

This can likewise be done with l2 forarding (via the bridge command) or l3
forwarding (via the ip command).

> If we are to interface with a TCAM, some operations might require more
> slices than others, which will limit the number of actions available,
> but it is hard to know ahead of time.
> 
Yes, thats correct, resource size estimations will have to be made by the
administrator, and might lead to failed offload attempts, or under-utilized
hardware.  But I think thats the price we pay for having higher level
functionality offloaded.  If someone wants to be more efficient, then they use
the low level flow api to get better performance (and deal with any of the
behavioral quirks that might arise)

Neil
