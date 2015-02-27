From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Driver level interface WAS(Re: Flows! Offload them.
Date: Fri, 27 Feb 2015 09:01:05 -0500
Message-ID: <54F078A1.6030008@mojatatu.com>
References: <20150226074214.GF2074@nanopsycho.orion> <54EF74E0.7060502@gmail.com> <54EF8911.9080203@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, jpettit@nicira.com, joestringer@nicira.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, simon.horman@netronome.com,
	shrijeet@gmail.com, gospo@cumulusnetworks.com, bcrl@kvack.org
To: John Fastabend <john.r.fastabend@intel.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35886 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbB0OBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 09:01:09 -0500
Received: by igkb16 with SMTP id b16so444858igk.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 06:01:08 -0800 (PST)
In-Reply-To: <54EF8911.9080203@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/15 15:58, John Fastabend wrote:

> My thinking on this is to use the FlowAPI ndo_ops as the bottom layer.
> What I would much prefer (having to actually write drivers) is that
> we have one API to the driver and tc, nft, whatever map onto that API.
>
> Then my driver implements a ndo_set_flow op and a ndo_del_flow op. What
> I'm working on now is the map from tc onto the flow API I'm hoping this
> sounds like a good idea to folks.
>

In the name of starting simple (just like we did with L2 and upcoming
L3), I think the idea is sane.
If a driver exposes a "5 tuple classifier" - that is a hell lot
easier to deal with from a policy perspective. I dont need to know
that when you tell me "I can handle 10K rules" that somehow in your
clever magic (or "IPR" as some people like to claim it) you managed
to use only 20K Tcam entries or 5K compressed Sram  entries. That
becomes your problem as a driver. IOW:
the driver should be in charge of the hardware resource management.
In my experience, it is a nightmare having to deal with a situation
where i just installed a rule and now in some bizare twisted
plot i just lost or gained 100 entries.
So a strategy for a driver interface depending on underlying hardware
is the right thing to do; in such a case i think tcam based hardware
offload would be fine fit for your API. There may be other strategies
to deal with different hardware - however, as long as we are consistent
we should be able to replace things when necessary.

Likewise i find the simple "set" thing to be a usability challenge
(we have done it in tc with pedit, but why the fsck would i use that
to change an ip address? could easily have done the nat action with it,
but there is a point where usability becomes paramount)

> Neil, suggested we might need a reservation concept where tc can reserve
> some space in a TCAM, similarly nft can reserve some space. Also I have
> applications in user space that want to reserve some space to offload
> their specific data structures. This idea seems like a good one to me.
>

I think this is treading into "advanced territory" as well.
Who gets to decide on what app uses what is reserved?
 From a kernel perspective:
I can understand conceptually we could label the entries to an owner.
We already do this with routing (look for field "protocol" in rtm).
However, theres a big can of worms that will need to be opened - what
happens when the owner of such reservation dies etc?
is tc/nftables allowed to add rules or it is based on user id?
You need to deal not just with such issues but authentication,
authorization etc of individual apps - such richness belongs to user
space imo.

cheers,
jamal
