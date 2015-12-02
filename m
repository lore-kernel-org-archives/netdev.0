From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Wed, 02 Dec 2015 17:35:14 +0100
Message-ID: <1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
 <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
 <20151129.222138.1582847465760563254.davem@davemloft.net>
 <CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
 <CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
 <CAEh+42gvn=cjZ4E3nACR7=-_a4iFS7OwEsSb+SQGme2k19kVAA@mail.gmail.com>
 <CALx6S37EoLM=bZ6sSAiiF81X=SvTvoNAmkbH5Dmn9zSvR2oiUA@mail.gmail.com>
 <20151201154445.GF29497@tuxdriver.com>
 <1448984968.3382143.454794705.68D88B7D@webmail.messagingengine.com>
 <CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:53831 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751294AbbLBQfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 11:35:16 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 5733120B6D
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2015 11:35:15 -0500 (EST)
In-Reply-To: <CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 2, 2015, at 04:50, Tom Herbert wrote:
> On Tue, Dec 1, 2015 at 7:49 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Tue, Dec 1, 2015, at 16:44, John W. Linville wrote:
> >> On Mon, Nov 30, 2015 at 09:26:51PM -0800, Tom Herbert wrote:
> >> > On Mon, Nov 30, 2015 at 5:28 PM, Jesse Gross <jesse@kernel.org> wrote:
> >>
> >> > > Based on what we can do today, I see only two real choices: do some
> >> > > refactoring to clean up the stack a bit or remove the existing VXLAN
> >> > > offloading altogether. I think this series is trying to do the former
> >> > > and the result is that the stack is cleaner after than before. That
> >> > > seems like a good thing.
> >> >
> >> > There is a third choice which is to do nothing. Creating an
> >> > infrastructure that claims to "Generalize udp based tunnel offload"
> >> > but actually doesn't generalize the mechanism is nothing more than
> >> > window dressing-- this does nothing to help with the VXLAN to
> >> > VXLAN-GPE transition for instance. If geneve specific offload is
> >> > really needed now then that can be should with another ndo function,
> >> > or alternatively ntuple filter with a device specific action would at
> >> > least get the stack out of needing to be concerned with that.
> >> > Regardless, we will work optimize the rest of the stack for devices
> >> > that implement protocol agnostic mechanisms.
> >>
> >> Is there no concern about NDO proliferation? Does the size of the
> >> netdev_ops structure matter? Beyond that, I can see how a single
> >> entry point with an enum specifying the offload type isn't really any
> >> different in the grand scheme of things than having multiple NDOs,
> >> one per offload.
> >>
> >> Given the need to live with existing hardware offloads, I would lean
> >> toward a consolidated NDO. But if a different NDO per tunnel type is
> >> preferred, I can be satisified with that.
> >
> > Having per-offloading NDOs helps the stack to gather further information
> > what kind of offloads the driver has even maybe without trying to call
> > down into the layer (just by comparing to NULL). Checking this inside
> > the driver offload function clearly does not have this feature. So we
> > finally can have "ip tunnel please-recommend-type" feature. :)
> >
> That completely misses the whole point of the rest of this thread.
> Protocol specific offloads are what we are trying to discourage not
> encourage. Adding any more ndo functions for this purpose should be an
> exception, not the norm. The bar should be naturally high considering
> the cost of exposing this to ndo.

Why?

I wonder why we need protocol generic offloads? I know there are
currently a lot of overlay encapsulation protocols. Are there many more
coming?

Besides, this offload is about TSO and RSS and they do need to parse the
packet to get the information where the inner header starts. It is not
only about checksum offloading.

If those protocols always carry an option length in the header we
probably could make it a little bit more generic, so the protocol
implementation could sound like:

  "Generic Tunnel Offloading besides protocols with chained options"

Unfortunately IPv6 extension headers are exactly a very good example
were this generic offloading would fail horribly as hardware has to
parse the header chain to reach the final (inner) protocol.

How to deal with the next protocol field in vxlan-gpe in a protocol
agnostic way (whoever came up with this)? (it has a special numbering
based on the ietf draft and I don't see any other way to say a network
card please interpret this field as specified by that rfcxxxx and this
is not protocol agnostic at all any more). I don't see how this
technically makes any sense and to implement this protocol agnostic.

Checksums maybe can, rest really does not make sense. Especially for NSH
I currently don't see how this can be done in general.

Please provide a sketch up for a protocol generic api that can tell
hardware where a inner protocol header starts that supports vxlan,
vxlan-gpe, geneve and ipv6 extension headers and knows which protocol is
starting at that point.

Bye,
Hannes
