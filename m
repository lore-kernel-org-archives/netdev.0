From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Tue, 09 Jun 2015 07:41:10 +0200
Message-ID: <1433828470.2142845.290464145.2861B867@webmail.messagingengine.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
 <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
 <1433793517.4616.4.camel@stressinduktion.org>
 <CAJmoNQG7vfuQAnZKN4+=NO7VQywC1=eXnumj2yG14KK5HS+TZw@mail.gmail.com>
 <1433795618.1990780.290127633.2EC447D9@webmail.messagingengine.com>
 <CAJmoNQHFK4YvaC4EqPB1yvoHRU3QBYYft2TNkGKhwpk_=GDhKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:51454 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752901AbbFIFlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 01:41:11 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id DC2CB211BB
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2015 01:41:10 -0400 (EDT)
In-Reply-To: <CAJmoNQHFK4YvaC4EqPB1yvoHRU3QBYYft2TNkGKhwpk_=GDhKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2015, at 00:44, Shrijeet Mukherjee wrote:
> On Mon, Jun 8, 2015 at 1:33 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Mon, Jun 8, 2015, at 22:22, Shrijeet Mukherjee wrote:
> >> On Mon, Jun 8, 2015 at 12:58 PM, Hannes Frederic Sowa
> >> <hannes@stressinduktion.org> wrote:
> >> > Hi Shrijeet,
> >> >
> >> > This let's incoming and arp requests use routing table 100. The system
> >> > will stop responding to arp requests as we don't have any entries in
> >> > this routing table.
> >>
> >>
> >> I like this model in general, as it addresses the issue that I have
> >> not addressed around connected routes.
> >>
> >> This would force local and directly connected host routes to be learnt
> >> into the correct table.
> >>
> >> It does bring the question up then.
> >>
> >> 1. The driver already knows the vrf device to table map
> >> 2. If the device also knows the final device to table map
> >>
> >> then do we need to use fib_rules and just lookup the table directly.
> >> It does make the configuration a little longer since each component
> >> device now needs configuration when you add/del a member from a vrf.
> >
> > This model is usable on its own, especially if one does not need routing
> > daemons
> > or user space software dealing with VRFs and sending out packets.
> >
> >> If people generally agree and we want to skip the fib_rule lookup,
> >> then I can make it such that enslaving already takes the dev-table id
> >> as well, and then the process of enslaving in the nominal VRF case
> >> becomes
> >>
> >> ip link add vrf-dev type vrf table foo ipv4-rt-table-id bar
> >> ip link set eth2 master vrf-dev
> >
> > I think this would be great.
> >
> > Last time I looked into the patches it was not yet clear if we can do
> > that
> > without holding strong references to the other interfaces. Hopefully
> > this can
> > be done by just passing down the table ids to the slaves during
> > initializing
> > and teardown of the master vrf interface.
> >
> > Bye,
> > Hannes
> 
> We can do that, and the hooks are all available. But do we want to cut
> out the fib_rules ? this would close out the opportunity for someone
> to insert a fib_rule to override the rule which directs to a VRF
> device.
> 
> Personally don't have a strong opinion, but want to make sure we
> understand that choice.

Hmm, wouldn't that still work with a target I added in my patch?

The only problem I see is that people might build up rules which are not
symmetric and thus vrf behavior differs from input and output path. One
addition to ease this is to add a interface selector which matches on
both, iif and oif. Also we must still keep in mind that rules are
matched linearly by using a list, hundreds of vrfs would thus first have
match hundreds of ip rules.

Bye,
Hannes
