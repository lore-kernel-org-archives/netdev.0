From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 17:46:09 +0000
Message-ID: <20150123174609.GA23242@casper.infradead.org>
References: <20150123155653.GK2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48250 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbbAWRqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 12:46:12 -0500
Content-Disposition: inline
In-Reply-To: <20150123155653.GK2065@nanopsycho.orion>
 <54C26A1F.6060603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm pulling in both branches of the thread here:

On 01/23/15 at 04:56pm, Jiri Pirko wrote:
> Fri, Jan 23, 2015 at 04:43:48PM CET, john.fastabend@gmail.com wrote:
> >But with the current API its clear that the rules managed by the
> >Flow API are in front of 'tc' and 'ovs' on ingress. Just the same
> >as it is clear 'tc' ingress rules are walked before 'ovs' ingress
> >rules. On egress it is similarly clear that 'ovs' does a forward
> >rule to a netdev, then 'tc' fiters+qdisc is run, and finally the
> >hardware flow api is hit.
> 
> 
> Seems like this would be resolved by the separe "offload" qdisc.

I'm not sure I understand the offload qdisc yet. My interpretation
so far is that it would contain childs which *must* be offloaded.

How would one transparently offload tc in this model? e.g. let's
assume we have a simple prio qdisc with u32 cls:

eth0
  prio
      class
      class
      ...
    u32 ...
    u32 ...

Would you need to attach the prio to an "offload qdisc" to offload
it or would that happen automatically? How would this looks like to
user space?

eth0
  offload
    prio
      u32
      u32
  prio
   u32
   u32

Like this?

> >The cases I've been experimenting with using Flow API it is clear
> >on the priority and what rules are being used by looking at counters
> >and "knowing" the above pipeline mode.
> >
> >Although as I type this I think a picture would help and some
> >documentation.

+1

We need one of those awesome graphs as the netfilter guys had it with
where the hooks are attached to ;-)

On 01/23/15 at 07:34am, John Fastabend wrote:
> Now 'xflows' needs to implement the same get operations that exist in
> this flow API otherwise writing meaningful policies as Thomas points out
> is crude at best. So this tc classifier supports 'get headers',
> 'get actions', and 'get tables' and then there associated graphs. All
> good so far. This is just an embedding of the existing API in the 'tc'
> netlink family. I've never had any issues with this. Finally you build
> up the 'get_flow' and 'set_flow' operations I still so no issue with
> this and its just an embedding of the existing API into a 'tc
> classifier'. My flow tool becomes one of the classifier tools.

.... if we can get rid of the rtnl lock in the flow mod path ;-)

> Now what should I attach my filter to? Typically we attach it to qdiscs
> today. But what does that mean for a switch device? I guess I need an
> _offloaded qdisc_? I don't want to run the same qdisc in my dataplane
> of the switch as I run on the ports going into/out of the sw dataplane.
> Similarly I don't want to run the same set of filters. So at this point
> I have a set of qdiscs per port to represent the switch dataplane and
> a set of qdiscs attached to the software dataplane. If people think this
> is worth doing lets do it. It may get you a nice way to manage QOS while
> your @ it.

If I interpret this correctly then this would imply that each switch
port is represented with a net_device as this is what the tc API
understands.
