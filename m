From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 12:28:38 +0000
Message-ID: <20150123122838.GI25797@casper.infradead.org>
References: <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
 <54C11ACC.5010005@mojatatu.com>
 <20150123101019.GF25797@casper.infradead.org>
 <20150123102421.GB2065@nanopsycho.orion>
 <20150123110821.GH25797@casper.infradead.org>
 <20150123113934.GD2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46735 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754015AbbAWM2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 07:28:41 -0500
Content-Disposition: inline
In-Reply-To: <20150123113934.GD2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 at 12:39pm, Jiri Pirko wrote:
> Maybe I did not express myself correctly. I do not care if this is
> exposed by rtnl or a separate genetlink. The issue still stands. And the
> issue is that the user have to use "the way A" to setup sw datapath and
> "the way B" to setup hw datapath. The preferable would be to have
> "the way X" which can be used to setup both sw and hw.
> 
> And I believe that could be achieved. Consider something like this:
> 
> - have cls_xflows tc classifier and act_xflows tc action as a wrapper
>   (or api) for John's work. With possibility for multiple backends. The
>   backend iface would looke very similar to what John has now.
> - other tc clses and acts will implement xflows backend
> - openvswitch datapath will implement xflows backend
> - rocker switch will implement xflows backend
> - other drivers will implement xflows backend
> 
> Now if user wants to manipulate with any flow setting, he can just use
> cls_xflows and act_xflows to to that.
> 
> This is very rough, but I just wanted to draw the picture. This would
> provide single entry to flow world manipulation in kernel, no matter if
> sw or hw.

If I understand this correctly then you propose to do the decision on
whether to implement a flow in software or offload it to hardware in the
xflows classifier and action. I had exactly the same architecture in mind
initially when I first approached this and wanted to offload OVS
datapath flows transparently to hardware.

If you look at this from the existing tc world then that makes a lot
of sense, in particular if you only support a single flat table with
wildcard flows and no priorities.

If you want to support priorities it already gets complicated. If flow
A, B, C are offloaded to hardware and the user then inserts a new flow
D with higher priority that can't be offloaded you need to figure out
whether you have to remove any of A, B, C from the hardware tables again
on the basis whether D overlaps with A, B, or C. If you have to remove
any of them you then have to verify whether that removal needs to
remove other already offloaded flows as well. It's certainly doable but
already adds considerable complexity to the kernel.

If you want to support multiple tables it gets even more complicated
because a flow in table 2 which can be offloaded might depend on a
flow in table 1 which can't be offloaded. You somehow need to track
that dependency and ensure that table 1 sends that flow to the CPU so
that the flow in table 2 sees it. The answer to this might be to maybe
only support  offload to a single table but that decreases the value
of the offload dramatically because the capabilities of each table are
very different.

If you bring the full programmability of OVS into the picture you might
have a pipeline consisting of multiple tables like this:

 +-------+   +------+   +-----+   +-------+
 | Decap |-->| L2   |-->| L3  |-->| Encap |
 +-------+   +------+   +-----+   +-------+

Each table contains flows and metadata registers plus header matches
are used to talk among the tables. The pipeline builds a chain of
actions which may be executed at any point in the pipeline or at the
end. If you want to map such a software pipeline to a set of hardware
tables you need to have full visbility into this table structure at
the point where you make the offload decision. This means that all of
this complexity would have to move into xflows.

Another aspect is that you might want to split a flow X into a hardware
and software part, e.g. consider the following flow:

in_port=vxlan0,vni=10,ip_dst=10.1.1.1,actions=decap(),nfqueue(10),output(tap0)

The hardware might be capable of matching on the VXLAN VNI, IP dst and
it might also capable of deencap. It obviously doesn't know about
netfilter queues. Ideally what you want is to split this into the
following flows:

Hardware table (offloaded):
in_port=vxlan0,vni=10,ip_dst=10.1.1.1,actions=decap(),metadata=1

Software table:
metadata=1,actions=nfqueue(10),output(tap0)

If the hardware capabilities are not exported to OVS then xflows would
need to encode such logic and xflows would need to be made aware of the
full software pipeline with all tables as you need to see all flows in
order to decide what to offload where.

I would love to see a tc interface to John's flow API and I see
tremendous value but I don't think it's appropriate to offload OVS.
