From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 14:32:31 -0700
Message-ID: <CAKgT0UeBZYP-Ax-iv-++9ODmf_F3Z3x1A_AGHgcuhEK21HsqPg@mail.gmail.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com> <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35406 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcFVVcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 17:32:33 -0400
Received: by mail-io0-f169.google.com with SMTP id f30so55523573ioj.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 14:32:32 -0700 (PDT)
In-Reply-To: <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 11:22 AM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>>>>> This series adds driver support for the processing of tunnel
>>>>> [specifically vxlan/geneve/gre tunnels] packets which are
>>>>> aggregated [GROed] by the hardware before driver passes
>>>>> such packets upto the stack.
>>>> First off I am pretty sure this isn't GRO.  This is LRO.
>>> Nopes. This is GRO - each MSS-sized frame will arrive on its
>>> own frag, whereas the headers [both  internal & external]
>>> would arrive on the linear part of the SKB.
>
>> No it is LRO, it just very closely mimics GRO.  If it is in hardware
>> it is LRO.  GRO is extensible in software and bugs can be fixed in
>> kernel, LRO is not extensible and any bugs in it are found in hardware
>> or the driver and would have to be fixed there.  It all comes down to
>> bug isolation.  If we find that disabling LRO makes the bug go away we
>> know the hardware aggregation has an issue.  Both features should not
>> operate on the same bit.  Otherwise when some bug is found in your
>> implementation it will be blamed on GRO when the bug is actually in
>> LRO.
> I'm not aware of a definition stating GRO *has* to be extensible in SW;
> AFAIK the LRO/GRO distinction revolves around multiple areas [criteria
> for aggregation, method of aggregation, etc.].

The idea behind GRO was to make it so that we had a generic way to
handle this in software.  For the most part drivers doing LRO in
software were doing the same thing that the GRO was doing.  The only
reason it was deprecated is because GRO was capable of doing more than
LRO could since we add one parser and suddenly all devices saw the
benefit instead of just one specific device.  It is best to keep those
two distinct solutions and then let the user sort out if they want to
have the aggregation done by the device or the kernel.

>> I realize this causes some pain when routing or bridging as LRO is
>> disabled but that is kind of the point.  We don't want the hardware to
>> be mangling frames when we are attempting to route packets between any
>> two given devices.

> Actually, while I might disagree on whether this is LRO/GRO, I don't think
> there's any problem for us to base this on the LRO feature - I.e., when we
> started working on qede we didn't bother implementing LRO as we understood
> it was deprecated, but this encapsulated aggregation is configurable; If it
> makes life easier for everyone if we make the configuration based on the LRO
> configuration, so that when LRO is disabled we won't have this turned on
> it can be easily done.

If you can move this over to an LRO feature I think it would go a long
way towards cleaning up many of my complaints with this.  LRO really
isn't acceptable for routing or bridging scenarios whereas GRO
sometimes is.  If we place your code under the same limitations as the
LRO feature bit then we can probably look at allowing the tunnel
aggregation to be performed since we can be more certain that the
tunnel will be terminating at the local endpoint.

>>>> Also I don't know if you have been paying attention to recent
>>>> discussions on the mailing list but the fact is GRO over UDP tunnels
>>>> is still a subject for debate.  This patch takes things in the
>>>> opposite direction of where we are currently talking about going with
>>>> GRO.  I've added Hannes and Tom to this discussion just to make sure I
>>>> have the proper understanding of all this as my protocol knowledge is
>>>> somewhat lacking.
>>> I guess we're on the exact opposite side of the discussion - I.e., we're
>>> the vendor that tries pushing offload capabilities to the device.
>>> Do notice however that we're not planning on pushing anything new
>>> feature-wise, just like we haven't done anything for regular TCP GRO -
>>> All we do is allow our HW/FW to aggregate packets instead of stack.
>
>> If you have been following the list then arguably you didn't fully
>> understand what has been going on.  I just went through and cleaned up
>> all the VXLAN, GENEVE, and VXLAN-GPE mess that we have been creating
>> and tried to get this consolidated so that we could start to have
>> conversations about this without things being outright rejected.  I
>> feel like you guys have just prooven the argument for the other side
>> that said as soon as we start support any of it, the vendors were
>> going to go nuts and try to stuff everything and the kitchen sink into
>> the NICs.  The fact is I am starting to think they were right.

> You hurt my feeling; I started going nuts ages ago ;-)

I'm not saying anything about going nuts, I'm just saying you kind of
decided to sprint out into a mine-field where I have been treading the
last week or so.  I'm just wanting to avoid having to see all this
code getting ripped out.

> But seriously, this isn't really anything new but rather a step forward in
> the direction we've already taken - bnx2x/qede are already performing
> the same for non-encapsulated TCP.

Right.  That goes on for other NICs as well.  Most of them use the LRO
feature flag for it tough.  Odds are bnx2x and qede should probably be
updated to do so as well.  I didn't realize we had NICs that were
re-purposing the GRO bit this way.  It would be a recipe for us to run
into issues from the software side as well because if we change
something in the requirements for GRO there is no guarantee that we
could support it in your hardware so that would be another argument
for forking your feature off into LRO on the hardware.

> And while I understand why you're being suspicious of such an addition,
> I don't entirely see how it affects any of that discussion - I already yielded
> that we can make this configurable, so if any routing decision would be
> added that result in packets NOT supposed to be aggregated, the feature
> can be turned off [at worst, at the expanse of it not having its benefit
> on other connections].

It basically just increased the scope of all the VXLAN, GENEVE, and
VXLAN-GPE offloads.  Most NICs were only using this for Rx checksum,
RSS, and a couple unfortunately to identify Tx flows for offload.  We
want to try and keep the scope of the offloads enabled via port
identification to the bare minimum.  Some of the community are still
of the opinion that we shouldn't support them at all and should just
rip them out.

>>>> Ideally we need to be able to identify that a given packet terminates
>>>> on a local socket in our namespace before we could begin to perform
>>>> any sort of mangling on the local packets.  It is always possible that
>>>> we could be looking at a frame that uses the same UDP port but is not
>>>> the tunnel protocol if we are performing bridging or routing.  The
>>>> current GRO implementation fails in that regard and there are
>>>> discussions between several of us on how to deal with that.  It is
>>>> likely that we would be forcing GRO for tunnels to move a bit further
>>>>> up the stack if bridging or routing so that we could verify that the
>>>> frame is not being routed back out before we could aggregate it.
>
>>> I'm aware of the on-going discussion, but I'm not sure this should
>>> bother us greatly - the aggregation is done based on the
>>> inner TCP connection; I.e., it's guaranteed all the frames belong to
>>> the same TCP connection. While HW requires the UDP port for the
>>> initial classification effort, it doesn't take decision solely on that.
>
>> I realize that UDP port is only one piece of this.  Exactly what
>> fields are being taken into account.  That information would be useful
>> as we could then go though and determine what the probability is of us
>> having a false match between any two packets in a given UDP flow.

> While we can surely do that, I think that's really beside the point;
> I.e., I don't expect any of you to debug issues arising from a bad HW/FW
> implementation. But if you REALLY want, I can go and ask for exact
> details.

I don't need the exact details but it is something that you should
probably look into from your side.  I can tell you that I have seen a
number of firmware bugs from various NICs over the last year or two.
Debugging them can be a real pain when features are running in the
background that you aren't aware of.  That is another reason for
wanting LRO and GRO separated so that I know I am dealing with
hardware versus software without having to know the details of your
NIC.

>> Also I would still argue this is LRO.  If we are doing routing it
>> should be disabled for us to later re-enable if we feel it is safe.
>> Having a feature like this enabled by default with GRO is a really bad
>> idea.

> Which is exactly what happens in qede/bnx2x for regular TCP.

I'm not sure I follow you here.  Are you saying this feature is
disabled by default or that it is supposed to be disabled when routing
or bridging?  From what I can tell it looks like what you are saying
is true for the bnx2x as it appears to be using the NETIF_F_LRO bit
based on a quick grep, but I don't see this bit used anywhere in qede.

> [I understand this area is a much hotter potato at the moment then
> simple GRO when we've submitted that content for both drivers;
> But I won't mention it again - the sins of the fathers are not excuses
> for any wrong-doings today].

Yeah, I don't really care about if this is how it was before.
Basically I just want it to be configured in such a way that somebody
doesn't have to have proprietary knowledge about the driver in order
to debug it if we end up finding a firmware bug.  I should be able to
clear the LRO bit and have hardware aggregation stop and hand
everything off to the kernel for aggregation so I can determine if the
issue is the kernel or the device/driver.

>>>> Also I would be interested in knowing how your hardware handles
>>>> tunnels with outer checksums.  Is it just ignoring the frames in such
>>>> a case, ignoring the checksum, or is it actually validating the frames
>>>> and then merging the resulting checksum?
>
>>> HW is validating both inner and outer csum; if it wouldn't be able to
>>> due to some limitation, it would not try to pass the packet as a GRO
>>> aggregation but rather as regular seperated packets.
>>> But I don't believe it merges the checksum, only validate each
>>> independently [CSUM_UNNECESSARY].
>
>>So it is mangling the packets then.
> Obviously - you can't aggregate things without touching them.

Right.  Just making the point for those that might not be following
the conversation since we are on a public list.

Still I would have probably preferred to have the checksum repopulated
after aggregation, but the fact that it isn't is not really all that
big a deal.  It just is painful for those what would prefer that we
were using CHECKSUM_COMPLETE for all these tunnels.

I hope this helps to clarify where I stand on this.

- Alex
