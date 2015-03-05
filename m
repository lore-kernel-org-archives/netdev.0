From: Vivek Venkatraman <vivek@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/7] mpls: Add a sysctl to control the size of
 the mpls label table
Date: Thu, 5 Mar 2015 08:49:30 -0800
Message-ID: <CAMs_D19OFkz1VtUsGohgoE0Rrfh3oGbZi4R38szdTuR7viNuPQ@mail.gmail.com>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
	<87egp5tvlz.fsf_-_@x220.int.ebiederm.org>
	<CAMs_D1-Ohar0CbgaB08jM0iGcORJxx_B9Ta778nd4m5unT6wMg@mail.gmail.com>
	<878ufbh93t.fsf@x220.int.ebiederm.org>
	<87bnk7bjby.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:38470 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757590AbbCEQtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 11:49:32 -0500
Received: by wevk48 with SMTP id k48so7555095wev.5
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 08:49:30 -0800 (PST)
In-Reply-To: <87bnk7bjby.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 6:38 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> ebiederm@xmission.com (Eric W. Biederman) writes:
>
>> Vivek Venkatraman <vivek@cumulusnetworks.com> writes:
>>
>>> On Tue, Mar 3, 2015 at 5:11 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>>>>
>>>> This sysctl gives two benefits.  By defaulting the table size to 0
>>>> mpls even when compiled in and enabled defaults to not forwarding
>>>> any packets.  This prevents unpleasant surprises for users.
>>>>
>>>> The other benefit is that as mpls labels are allocated locally a dense
>>>> table a small dense label table may be used which saves memory and
>>>> is extremely simple and efficient to implement.
>>>>
>>>
>>> The label space is often partitioned into multiple sets in MPLS and
>>> used for different purposes - for example, LSP labels, VPN labels,
>>> Segment labels. This in turn means that the table may no longer be
>>> dense. A sysctl allowing min and max label that spans the sets of
>>> labels may be useful. Or should the ILM be made a hash table?
>>
>> Good question.
>>
>> These kinds of labels are a local label management problem.
>>
>> Given how nice it is to have a reasonably dense label space I am not
>> keen to abandon the notion of having a dense label space, as it makes
>> the code simple and fast for forwarding mpls packets.
>>

That's true. I guess this can be considered a local label management issue.

>> That said my code is a starting point.  If you have a real world use
>> case and you can show a better way to deal with it.  Go for it.
>> Now is definitely time to evolve the API.
>
> A couple more thoughts.
>
> The rtnetlink interface and my implementation carries a type field so it
> is possible to mark which routing protocol uses an mpls route.
>
> The global routing table is already over 500,000 routes so the 1 million
> forward equivalanece classes of mpls with a single label may be
> exhausted in the not too distant future so a dense label space may be a
> necessity.
>
> In a similar vein.  When I look at top of rack switches and their
> hardware forwarding capacity it looks like they are in the ballpark
> of 32K MPLS routes.
>
> All of which says to me that the MPLS label space is limited and it
> should be managed as a precious resource.  (A good example of why I
> might want to rethink my mpls ingress path).
>
> So while I can see arguments for one use of labels getting one quota of
> labels and another use of labels getting another quota when I look at
> the space there are not that many labels and I don't see how or why it
> would make sense to manage the labels explicitly with ranges.
>

The ability to impose a label stack and the way a FEC is defined at
the edge is what may help against the exhaustion of the label space.
It is usually for the label stack that multiple ranges of labels are
used. Again, I guess that can be handled by the application and the
dataplane can treat the entire set of labels as a single flat range.

> At some point for MPLS multicast traffic and MPLS source specific
> addresses if we choose to support those we will need a hash table
> as those addresses are assigned by others, though in that case
> we will be limited in our egress set of labels we can use.
>
> So I think MPLS interfaces need to encourage thrifty label use,
> which in my mind almost certainly means not manually allocated
> label use.
>
> Eric
