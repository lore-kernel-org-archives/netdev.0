From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 1/2] flow dissector: ND
 support
Date: Mon, 6 Feb 2017 10:12:54 +0100
Message-ID: <20170206091253.GB20384@penelope.horms.nl>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
 <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
 <1486038693.13103.20.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170202155849.GA28482@penelope.horms.nl>
 <CALx6S37b00GfUBQ5imVfOhg2Rbp_GtDntkwqyj3cN8kzt6gG0w@mail.gmail.com>
 <20170202174803.GF1845@nanopsycho.orion>
 <CALx6S37QtKgc14DFway-Ajme7JhbAN71M+83w28+4FELdv7Xew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36792 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdBFJM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 04:12:57 -0500
Received: by mail-wm0-f50.google.com with SMTP id c85so110770107wmi.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 01:12:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S37QtKgc14DFway-Ajme7JhbAN71M+83w28+4FELdv7Xew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 10:36:31AM -0800, Tom Herbert wrote:
> On Thu, Feb 2, 2017 at 9:48 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> > Thu, Feb 02, 2017 at 06:24:40PM CET, tom@herbertland.com wrote:
> >>On Thu, Feb 2, 2017 at 7:58 AM, Simon Horman <simon.horman@netronome.com> wrote:
> >>> [Repost due to gmail account problem]
> >>>
> >>> On Thu, Feb 02, 2017 at 04:31:33AM -0800, Eric Dumazet wrote:
> >>>> On Thu, 2017-02-02 at 11:37 +0100, Simon Horman wrote:
> >>>> > Allow dissection of Neighbour Discovery target IP, and source and
> >>>> > destination link-layer addresses for neighbour solicitation and
> >>>> > advertisement messages.
> >>>> >
> >>>> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >>>> > ---
> >>>>
> >>>> Hi Simon
> >>>>
> >>>> Why is this needed ?
> >>>>
> >>>> Any code added in flow dissector needs to be extra careful,
> >>>> we had various packet of deaths errors recently in this area.
> >>>
> >>> Hi Eric,
> >>>
> >>> there some activity to allow programming of OvS flows in hardware via TC
> >>> with the flower classifier. As the ND fields in this patch are part of the
> >>> OvS flow key I would like them considered for additions to flower and thus
> >>> the dissector to allow compatibility with OvS.
> >>>
> >>Given that ARP is already there it seems only "fair" to have ND also.
> >>But Eric is correct, this is quite a sensitive area of code.
> >>
> >>> I apologise if any 'deaths' have resulted from my recent work on the
> >>> dissector. I am of course very open to ideas on how to avoid any future
> >>> incidents.
> >>
> >>That's a tough problem. flow_dissector started off as simple mechanism
> >>to just identify actual flows (really just TCP and UDP packets) for
> >>the purposes of packet steering. But given the benefits of its
> >>location low in the stack and the open ended capabilities for parsing
> >>it seems to have mushroomed into a general catchall to parse a whole
> >>bunch of different protocols. A lot of these go beyond simply
> >>identifying flows (ICMP parsing, ARP, or ND as in your patches). These
> >>new use cases may be valid, but the result is a convoluted function (>
> >>500 LOC by my count) and it seems to be quite easy to have subtle bugs
> >>mostly in edge cases, several of which could have been exploited in
> >>DDOS attacks.
> >
> > Agreed that we probably came to a point when we need to split
> > __skb_flow_dissect into modular and pluggable pieces. Will not be
> > trivial though.
> >
> > Also note that it depends on the __skb_flow_dissect user which code is
> > actually used or not. For the critical path, that keys are defined by:
> > flow_keys_dissector_keys
> >
> True, but the code doesn't separate out the critical path from all
> these extended features which is resulted in a jumbled mess with no
> modularity to speak of :-(
> 
> > Most of the code Simon is adding is noop for non-flower usecase if:
> > dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ND) == false
> >
> Sure, but that just makes this code corner cases which means it's hard
> to maintain and harder to find bugs in the long run.

I think that there is a bit of tension here between having generic reusable
code on the one hand and having a small robust implementation for critical
code.

>From my point of view having the flow dissector shared makes complete sense
when all the users need a similar set of keys. This was mostly the case
until one user, flower, started growing the number of keys it can use - I am
partly responsible for that. So now we have one user that is placing a
burden on the complexity and recently the robustness of code that is relied
on by many users.

I think that Jiri's point regarding dissector_uses_key() is the nub of the
issue. On the one hand I believe, given my recent updates to the code in
question, that covering more code by such conditionals - without necessarily
adding more instances of the conditionals - would lead to more robust code
for the current users. But as Tom points out paradoxically it may also lead
to less robust code for paths that aren't executed much - specifically
paths being added to support keys only used by flower.

I suspect a similar paradox would exists for other, likely more complex,
refactoring efforts.

>From my side I think that using dissector_uses_key() to cover more code
makes sense as it allow features to be added to flower and for bugs in them
to be ironed out with lower risk of effecting other users along the way.

> >>At some point we need to stop adding new protocols to parse in
> >>__skb_flow_dissect and push the processing back into the protocol
> >>modules with a callout interface from flow_dissector (for instance if
> >>we ever want VXLAN parsing in flow dissector this is the only
> >>reasonable way to do it). That moves the complexity but doesn't solve
> >>the problem of buggy code in this critical path. An alternative might
> >>be to put a cap on flow_dissector and add a hook to BPF program to
> >
> > Loks like BPF is becoming an answer for everything these days :O
> >
> In this case it makes sense though, we can't just continue accepting
> every poor little narrow use-case protocol that comes along into the
> kernel :-)

Maybe. I'm not sure that I think we should exclude narrow cases. But
I have no strong feeling on that at this time.

To lay my intentions on the table: I am interested in enhancing flower and
by implication the flow dissector to support the header fields and
protocols supported by OvS. I can check the list but possibly ND is the
narrowest case protocol there.

> >>allow parsing of new protocols. This has the advantage of providing an
> >>constrained interface that could eliminate possibility of some types
> >>of bugs we've seen. Also, this allows adding support for "user"
> >>protocols that the kernel might not even know about (QUIC comes to
> >>mind).
> >
> > Not sure it is wise to make life easier for the proprietary
> > out-of-tree beasts...
> 
> It's going to be a problem with a whole host of application level
> protocols especially those run over UDP. QUIC is a great example. The
> actual protocol will probably only ever run in userspace, but it is
> inevitable that we want to provide targeted kernel support for packet
> steering. filtering, GRO/GSO if they have such things. Instead of
> implementing this in a specialized QUIC module, it will most likely
> make everyone happier to add these in a generic protocol-agnostic way.
> From QUIC POV they want to minimize any dependencies on the kernel and
> be able to iterate quickly, from a kernel POV we really don't want to
> have to explicitly support an endless stream of protocols like this.
> 
> Tom
