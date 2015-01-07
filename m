From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Wed, 07 Jan 2015 12:23:12 +0100
Message-ID: <1420629792.26870.59.camel@stressinduktion.org>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com>
	 <1420552709.32369.50.camel@stressinduktion.org>
		 <CAE4R7bCOnYL1bat39UivcyAG-S1hx-EJpwC_hWNv8prjZqV3fg@mail.gmail.com>
	 <1420574353.15181.19.camel@stressinduktion.org>
	 <98433f41e1876041471cdb513ca53fe5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Ji=C5=99=C3=AD_P=C3=ADrko?= <jiri@resnulli.us>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:56765 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752038AbbAGLXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 06:23:15 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 2221320807
	for <netdev@vger.kernel.org>; Wed,  7 Jan 2015 06:23:15 -0500 (EST)
In-Reply-To: <98433f41e1876041471cdb513ca53fe5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-06 at 18:08 -0800, Shrijeet Mukherjee wrote:
> >For the first idea, I'll try to make an example:
> >
> >Initial setup:
> ># ip rule ls
> >0:	from all lookup local
> >32766:	from all lookup main
> >32767:	from all lookup default
> >
> ># ip rule add pref 100 iif swdev0 table 5 # ip rule ls
> >0:	from all lookup local
> >100:	from all iif swdev0 [detached] lookup 5
> >> maybe we can show which rules are being able to get offloaded here
> >32766:	from all lookup main
> >32767:	from all lookup default
> >
> >table 5 should be the table we can insert routes into which are offloaded
> >to
> >hardware.
> >
> >During table modifications we linearly scan the rules if we find selectors
> >which
> >cannot be represented by hardware.
> >
> >In case we have a iif selector, we simply can use this table and just
> >synthesize it
> >into the particular interface.
> >
> >A ip-rule-from would need all the hardware being capable of matching source
> >addresses, otherwise we cannot offload all routing tables with higher
> >preference,
> >same for a to/tos rule. If we encounter a fwmark rule, we certainly cannot
> >represent it in hardware, so skip it (here we can think about entangling
> >those with
> >ACLs, but it feels hard to do).
> >
> >If rules are inserted or changed we must again validate the complete list
> >of rules
> >and decide if we need to flush all the routes and install a slow path via
> >kernel.
> >
> >What do you think? Does that make sense? I could try to come up with an API
> >for
> >that. ;)
> >
> 
> This sounds really good, but I suspect the real problem is the case where
> the rule evaluation is in the hardware path right. If it is purely IF based
> there is no issue .. but any other policy like missed in table 1, then use
> table 2 will not work with this model .. or did I miss something ?

I could come up with several ways how to model hardware. Depending on
that the integration with rules is easy or nearly impossible:

1) it simply cannot deal with ip rules, so there is no way an ACL can
influence the outcome of a routing table lookup - if the feature should
be used, it has to use the slow-path in the kernel.

2) ACLs can influence which routing table will get queried - this sounds
very much like the ip rule model and it seems not too hard to model
that.

3) Routing implementations in the hardware have a single routing table
and the leafs carry different actions with priorities: making this kind
of model working with the ip rule concept will become very difficult and
it might require lots of algorithmic code by every driver to adapt to a
single API provided by Linux. It might be possible, if the hardware
provides actions like backtrack and retrack and can keep state of
priorities during walking the tree, I really doubt that.

Implementations of type 3) would look naturally to do in hardware (see
different Cisco policy routing configurations or ipv6 subtree feature),
so it seems it won't be possible to find a simple way to fuse rules and
offloading in case of point 3).

Rocker sounds a lot like model 2) and this seems possible and should be
a matter of API design. It should merely be a matter of nicely model the
data structures. ;)

Also, @Scott: if you build drivers with l3 offloading as modules, don't
you need to push the full routing tables to the hw once? Maybe we should
think about the drivers pulling routing information from the kernel, the
kernel only notifying something changed?

Bye,
Hannes
