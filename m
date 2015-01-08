From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Thu, 08 Jan 2015 14:03:59 +0100
Message-ID: <1420722239.810.23.camel@stressinduktion.org>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com>
	 <1420552709.32369.50.camel@stressinduktion.org>
			 <CAE4R7bCOnYL1bat39UivcyAG-S1hx-EJpwC_hWNv8prjZqV3fg@mail.gmail.com>
	 <1420574353.15181.19.camel@stressinduktion.org>
		 <98433f41e1876041471cdb513ca53fe5@mail.gmail.com>
	 <1420629792.26870.59.camel@stressinduktion.org>
	 <1b5a5a02b187fde4c2491ce757cb0045@mail.gmail.com>
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
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:39097 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754103AbbAHNEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 08:04:02 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id C1A8120707
	for <netdev@vger.kernel.org>; Thu,  8 Jan 2015 08:04:01 -0500 (EST)
In-Reply-To: <1b5a5a02b187fde4c2491ce757cb0045@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mi, 2015-01-07 at 09:54 -0800, Shrijeet Mukherjee wrote:
> >
> >I could come up with several ways how to model hardware. Depending on that
> >the integration with rules is easy or nearly impossible:
> >
> >1) it simply cannot deal with ip rules, so there is no way an ACL can
> >influence the
> >outcome of a routing table lookup - if the feature should be used, it has
> >to use
> >the slow-path in the kernel.
> 
> As Scott was saying, most hardware has table id's and the ability to
> identify and prioritize that way.

I saw Scott only talking about Rocker - maybe I missed it?

> >2) ACLs can influence which routing table will get queried - this sounds
> >very much
> >like the ip rule model and it seems not too hard to model that.
> 
> This clearly can be made to work .. the problem is really the space of
> policy routing (i.e jump across VRF's incase of a lookup failure) when
> combined with the space of ip rule flexibility.

This very much depends on the hardware, I guess. The complexity is
increased by the routing offloading knowing about the ACL datastructures
and vice versa.

> >3) Routing implementations in the hardware have a single routing table and
> >the
> >leafs carry different actions with priorities: making this kind of model
> >working
> >with the ip rule concept will become very difficult and it might require
> >lots of
> >algorithmic code by every driver to adapt to a single API provided by
> >Linux. It
> >might be possible, if the hardware provides actions like backtrack and
> >retrack and
> >can keep state of priorities during walking the tree, I really doubt that.
> 
> 
> In the short term .. this maybe a good way to go but with a simplication.
> Some tables are offloaded and the rest at the full table level is in
> software. Finally then you can put a "default route" in the hardware table
> to punt to cpu and then keep the software model clever and the hardware
> model fast ?

Yes, the algorithm I described in my prior mail implicitly does that, we
can extend it bit by bit as new hardware supports more filter features.
Especially the default configuration with only the RT_TABLE_LOCAL and
RT_TABLE_MAIN allows complete offloading, which should be desirable.

To deal with the RT_TABLE_LOCAL, we might walk the whole routing table
and verify that all routes have full prefix length (32 ipv4 or 128
ipv6).

Bye,
Hannes
