From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: 16 Jul 2003 01:02:02 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1058328537.1797.24.camel@jzny.localdomain>
References: <200307141045.40999.nf@hipac.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: nf@hipac.org
In-Reply-To: <200307141045.40999.nf@hipac.org>
List-Id: netdev.vger.kernel.org

Hi Michael,

I noticed you guys like to post to the kernel list at times without
even ccing netdev based on my browsing just now. Please send msgs to
netdev first; ccing lk is optional.Infact i took it out of the cc.

On Mon, 2003-07-14 at 04:45, Michael Bellion and Thomas Heinz wrote:
> Hi
> 
> We are planning to port our HIPAC algorithm to the tc framework and we
> ask you for some comments about several issues.
> 

This is good.I may have emailed you about this topic before?

[..]

> 
> Certainly, we'd like to know first whether HIPAC makes sense for the
> tc framework at all. 

It's a classifier therefore it makes sense ;->

> From the nf-hipac worst case performance tests
> we know that our algorithm should be faster in all cases as soon as
> you have approx. 20 filters. Below 20 filters there is no difference
> between nf-hipac and the iptables filter table.

nice. What would be interesting is to see your rule update rates vs
iptables (i expect iptables to suck) - but how do you compare aginst any
of the tc classifiers for example?
  
> So basically the question is: Are people using the tc framework with
> lots of filters? Some numbers would be helpful.
> 

I am not sure anybody could give you numbers; i have seen a posting once
which talked about 1K rules. I hardly use more than 10 in my setup
however there amy be people who will be looking (even if it is for
benchmarking purposes) in the 100K range. Short answer - go for the max
you can.

> Since we can only improve performance of u32 and fw filters it's also
> interesting whether such rulesets typically consist of those filters
> in the main.
> 

Actually theres a _lot_ of room for improvement for u32. I have played
with a few tricks which will greatly up the numbers for high number of
rules.

> The tc framework is very flexible with respect to where filters can be
> attached. Unfortunately this cannot be mapped into one HIPAC data
> structure. Our current design allows to attach filters anywhere but
> only the filters attached to the top level qdisc would benefit from the
> HIPAC algorithm. Would this be a noticeable restriction?
> 

I dont think so, but can ytou describe this restriction?

> 
> Here is a short overview of the main design goals:
> 
> - new qdisc for HIPAC which is basically a container for the filters;
>   it can only be attached as top level qdisc

why?

> - new HIPAC classifier which supports all native nf-hipac matches
>   (src/dst ip, proto, src/dst port, ttl, state, in_iface, icmp type,
>   tcpflags, fragments) and additionally fwmark

I would think for cleanliness fwmark or any metadata related
classification would be separate from one that is based on packet bits.

> - the HIPAC classifier can only be attached to the HIPAC qdisc and vice
>   versa the HIPAC qdisc only accepts HIPAC classifiers

<puke> 
We do have an issue with being able to do extended classification
but building a qdisc for it is a no no. Building a qdisc that will force
other classifier to structure themselves after it is even a bigger sin.
Look at the action code i have (i can send you an updated patch); a
better idea is to make extended classifiers an action based on another
filter match. At least this is what i have been toying with and i dont
think it is clean enough. what we need is to extend the filtering
framework itself to have extended classifiers.

> - the HIPAC qdisc consists of only one single class to which the "next"
>   qdisc must be attached
> - the HIPAC classifier can contain a number of existing classifiers
>   (u32, fw, route, rsvp, tcindex) whereby the semantics is as follows:
>   a HIPAC classifier matches if the native matches and also each of the
>   embedded classifiers match; the returned tcf_result is the one from
>   the final classifier (=> intermediate classifiers are reduced to a
>   match)
> - it is still possible to attach non-hipac classifiers to other qdiscs
>   and classes
> 

Please junk this idea. Study the classification framework code and come
up with something that is based on that. Second best option is to take
a look at the action code. We dont want to force other classifiers in
research to be constrained to your structures. This is not trying to put
down work you are doing - i think you have something good.

cheers,
jamal

