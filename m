From: jamal <hadi@cyberus.ca>
Subject: Re: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch
 datapath
Date: Mon, 18 Oct 2010 08:16:57 -0400
Message-ID: <1287404217.3664.182.camel@bigi>
References: <20100830062755.GA22396@verge.net.au>
	 <87k4n8ow1r.fsf@benpfaff.org> <1287142292.3642.19.camel@bigi>
	 <AANLkTim2LsFUOVSVss6HqGTxuyGH6eBKQdYabjMoWiaB@mail.gmail.com>
	 <1287228959.3664.72.camel@bigi>
	 <AANLkTin-zmQdMC_nRvgRr5KdWQvee5xga5sjOfRN2McN@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Pfaff <blp@nicira.com>, netdev@vger.kernel.org,
	ovs-team@nicira.com
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:35569 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab0JRMRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 08:17:00 -0400
Received: by qyk2 with SMTP id 2so958419qyk.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 05:17:00 -0700 (PDT)
In-Reply-To: <AANLkTin-zmQdMC_nRvgRr5KdWQvee5xga5sjOfRN2McN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2010-10-16 at 12:33 -0700, Jesse Gross wrote:
> On Sat, Oct 16, 2010 at 4:35 AM, jamal <hadi@cyberus.ca> wrote:

> Yes, Open vSwitch supports the OpenFlow protocol.  However, the Open
> vSwitch kernel portion is completely different from the OpenFlow
> reference implementation datapath and in fact does not speak OpenFlow
> at the kernel level. 

Excellent. 
Sorry - I may have misread the openflow code to be openvswitch.

>  You brought up the point of keeping the kernel
> simple and making policy decisions in userspace.  I completely agree
> and, in fact, that is the reason why Open vSwitch is designed the way
> it is.
> 
> I think it might be helpful if I gave a high level overview of packet
> processing:
> 
> When a packet is received it, the relevant fields from the packet are
> extracted and matched against a hash table.  The most interesting part
> is actually what happens when the packets don't match a hash entry:
> they get sent up to userspace.  It is userspace that makes a policy
> decision about the traffic and then pushes down a flow entry for
> future packets to match.  Some of the things that those decisions can
> be based on include: OpenFlow rules, wildcarded entries, normal L2
> learning, etc.  From then on, packets in that flow can be processed on
> the fast path in the kernel with minimal overhead, while still getting
> the benefit of the knowledge of userspace.

Ok, pretty classical stuff - exception handling in control path, update
policy to data path based on exception, subsequent stuff happens in data
path.

> So I think that we are actually in agreement on quite a number of
> points: the kernel should be kept as simple as possible, the control
> plane should be abstracted out and handled in userspace, and it should
> be possible to map the control rules (from OpenFlow or anywhere
> really) onto a simpler set of primitives for handling packets.
> 
> So with those goals in mind, here's what is needed:
> 1. Packet field extraction and classification.  Realistically speaking
> a new, specialized classifier would probably be needed, as you
> mention.

I think a new classifier would make life simpler here.

> 2. A mechanism to send/receive packets to/from userspace.  This is an
> important component that Open vSwitch adds to the pipeline.  This will
> probably expand in the future to suit different applications, like the
> security processing that I talked about.

There are many ways to skin that proverbial cat. I guess it will depend
on whether you are redirecting or merely copying a whole packet, or part
of it (while storing a part in the kernel) etc. Example for a scheme
that works using netlink look at the netfilter examples. You could use
pf_packet if merely requiring copies. One simple scheme i have used is
to have the mirred action redirect to a tun device on which a user space
daemon is listening. If you look at the mirred action - there is an
option to redirect to a named socket which was never implemented because
workarounds exist.

> 3. Output actions.  A few exist today, at least some new ones will
> need to be added.

Agreed.

> So in reality, all of major components of Open vSwitch are actually
> not present in the kernel today.  I know the argument could be made
> that certains parts can be replicated in different ways but that's
> back to the simplicity point that I was making earlier.  The u32
> classifier isn't well suited for these types of rules and neither is
> pedit.  If we're going to add the needed components either way, let's
> not make everyone's lives more complicated by mixing everything
> together.

I have to say it is a pleasant suprise that we agree. When i looked at
the openflow code i was worried. I always believe in improving what we
have in Linux than trying to add parallel competing interfaces.
[You'd be suprised for example on the number of vendors who put forward
the claim that they can route faster on Linux[1] by writing a little
barebone driver which ignores 99% of reality.]

cheers,
jamal
[1] I am forgiving on academics 

