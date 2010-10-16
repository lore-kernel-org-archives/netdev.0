From: Jesse Gross <jesse@nicira.com>
Subject: Re: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch datapath
Date: Sat, 16 Oct 2010 12:33:25 -0700
Message-ID: <AANLkTin-zmQdMC_nRvgRr5KdWQvee5xga5sjOfRN2McN@mail.gmail.com>
References: <20100830062755.GA22396@verge.net.au>
	<87k4n8ow1r.fsf@benpfaff.org>
	<1287142292.3642.19.camel@bigi>
	<AANLkTim2LsFUOVSVss6HqGTxuyGH6eBKQdYabjMoWiaB@mail.gmail.com>
	<1287228959.3664.72.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Pfaff <blp@nicira.com>, netdev@vger.kernel.org,
	ovs-team@nicira.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63717 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832Ab0JPTd0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 15:33:26 -0400
Received: by gyg13 with SMTP id 13so396380gyg.19
        for <netdev@vger.kernel.org>; Sat, 16 Oct 2010 12:33:25 -0700 (PDT)
In-Reply-To: <1287228959.3664.72.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 16, 2010 at 4:35 AM, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2010-10-15 at 14:35 -0700, Jesse Gross wrote:
>
>>
>> You're right, at a high level, it appears that there is a bit of an
>> overlap between bridging, tc, and Open vSwitch.
>
> It looks like openvswitch rides on top of openflow, correct?
> earlier i was looking at =A0openflow/datapath but gleaning
> openvswitch/datapath it still looks conceptually the same
> at the lower level.

Yes, Open vSwitch supports the OpenFlow protocol.  However, the Open
vSwitch kernel portion is completely different from the OpenFlow
reference implementation datapath and in fact does not speak OpenFlow
at the kernel level.  You brought up the point of keeping the kernel
simple and making policy decisions in userspace.  I completely agree
and, in fact, that is the reason why Open vSwitch is designed the way
it is.

I think it might be helpful if I gave a high level overview of packet
processing:

When a packet is received it, the relevant fields from the packet are
extracted and matched against a hash table.  The most interesting part
is actually what happens when the packets don't match a hash entry:
they get sent up to userspace.  It is userspace that makes a policy
decision about the traffic and then pushes down a flow entry for
future packets to match.  Some of the things that those decisions can
be based on include: OpenFlow rules, wildcarded entries, normal L2
learning, etc.  From then on, packets in that flow can be processed on
the fast path in the kernel with minimal overhead, while still getting
the benefit of the knowledge of userspace.

So I think that we are actually in agreement on quite a number of
points: the kernel should be kept as simple as possible, the control
plane should be abstracted out and handled in userspace, and it should
be possible to map the control rules (from OpenFlow or anywhere
really) onto a simpler set of primitives for handling packets.

So with those goals in mind, here's what is needed:
1. Packet field extraction and classification.  Realistically speaking
a new, specialized classifier would probably be needed, as you
mention.
2. A mechanism to send/receive packets to/from userspace.  This is an
important component that Open vSwitch adds to the pipeline.  This will
probably expand in the future to suit different applications, like the
security processing that I talked about.
3. Output actions.  A few exist today, at least some new ones will
need to be added.

So in reality, all of major components of Open vSwitch are actually
not present in the kernel today.  I know the argument could be made
that certains parts can be replicated in different ways but that's
back to the simplicity point that I was making earlier.  The u32
classifier isn't well suited for these types of rules and neither is
pedit.  If we're going to add the needed components either way, let's
not make everyone's lives more complicated by mixing everything
together.
