From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Tue, 06 Jan 2015 20:59:13 +0100
Message-ID: <1420574353.15181.19.camel@stressinduktion.org>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com>
	 <1420552709.32369.50.camel@stressinduktion.org>
	 <CAE4R7bCOnYL1bat39UivcyAG-S1hx-EJpwC_hWNv8prjZqV3fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Ji=C5=99=C3=AD_P=C3=ADrko?= <jiri@resnulli.us>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33215 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755821AbbAFT7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:59:17 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 0E2B52097D
	for <netdev@vger.kernel.org>; Tue,  6 Jan 2015 14:59:17 -0500 (EST)
In-Reply-To: <CAE4R7bCOnYL1bat39UivcyAG-S1hx-EJpwC_hWNv8prjZqV3fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-06 at 09:51 -0800, Scott Feldman wrote:
> On Tue, Jan 6, 2015 at 5:58 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > At this point I would like to start the discussion about handling of the
> > table ids/vrfs (again :) ): as I can see it, this version just passes
> > table ids down to the driver layer and the rocker driver filters them by
> > local/main table? This seems to be mostly fine for a first version but
> > does not feel like it will integrate well with the rest of the linux
> > networking ecosystem.
> >
> > Will hardware have the capabilities to do programmable matches like "ip
> > rule" is currently capable to do? Should we plan for that? Do we want to
> > support hardware which does support multiple tables/VRFs?
> 
> Good questions, thanks for bringing these up.
> >
> > I would like to present a first suggestion:
> > My take on this would be strive towards an integration with ip-rule, so
> > we add tables which will be offloaded to hardware. This happens only in
> > situations where those tables will be the first match for incoming
> > packets specified with an in-interface filter which has the capability
> > to do the offloading (for example). The determination if the table is
> > capable for hardware offloading should be done automatically, so if
> > later hardware will be capable of doing ip rule like matches, we can
> > just expand the check which flags the tables accordingly.
> 
> Sounds like a good suggestion to me.  We need to think about what the
> swdev API looks like to the switch device driver.  Could you take a
> stab at defining what integration with ip-rule looks like, code-wise,
> at the swdev API layer?
> 
> With the rocker device we're prototyping with, the standard LPM on IP
> dst is the normal L3 routing table structure.  Within that, table
> priorities could be handled, so routes in one table take precedence
> over routes in another table.  If we want to do policy routing, then
> we'd need to use the ACL table in rocker to match on other fields
> besides just IP dst.

Sorry, I haven't fully understood this. Does rocker first do a L3
routing table lookup and *after* that does decide which nexthop to chose
based on preferences in the action-set found at the leaf? My gut tells
me that we cannot do a semantically equivalent to ip rules then, we
would have to use ACLs then. Hmm...

For the first idea, I'll try to make an example:

Initial setup:
# ip rule ls
0:	from all lookup local 
32766:	from all lookup main 
32767:	from all lookup default 

# ip rule add pref 100 iif swdev0 table 5
# ip rule ls
0:	from all lookup local 
100:	from all iif swdev0 [detached] lookup 5
> maybe we can show which rules are being able to get offloaded here
32766:	from all lookup main 
32767:	from all lookup default 

table 5 should be the table we can insert routes into which are
offloaded to hardware.

During table modifications we linearly scan the rules if we find
selectors which cannot be represented by hardware.

In case we have a iif selector, we simply can use this table and just
synthesize it into the particular interface.

A ip-rule-from would need all the hardware being capable of matching
source addresses, otherwise we cannot offload all routing tables with
higher preference, same for a to/tos rule. If we encounter a fwmark
rule, we certainly cannot represent it in hardware, so skip it (here we
can think about entangling those with ACLs, but it feels hard to do).

If rules are inserted or changed we must again validate the complete
list of rules and decide if we need to flush all the routes and install
a slow path via kernel.

What do you think? Does that make sense? I could try to come up with an
API for that. ;)

Bye,
Hannes
