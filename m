From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 07:34:55 -0800
Message-ID: <54C26A1F.6060603@gmail.com>
References: <20150122151316.GB25797@casper.infradead.org> <54C11703.7030702@mojatatu.com> <20150122153727.GC25797@casper.infradead.org> <54C11ACC.5010005@mojatatu.com> <20150123101019.GF25797@casper.infradead.org> <20150123102421.GB2065@nanopsycho.orion> <20150123110821.GH25797@casper.infradead.org> <20150123113934.GD2065@nanopsycho.orion> <20150123122838.GI25797@casper.infradead.org> <20150123134315.GF2065@nanopsycho.orion> <20150123140724.GJ25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:60497 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbbAWPfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:35:13 -0500
Received: by mail-oi0-f43.google.com with SMTP id z81so7026615oif.2
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 07:35:12 -0800 (PST)
In-Reply-To: <20150123140724.GJ25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2015 06:07 AM, Thomas Graf wrote:
> On 01/23/15 at 02:43pm, Jiri Pirko wrote:
>> Fri, Jan 23, 2015 at 01:28:38PM CET, tgraf@suug.ch wrote:
>>> If I understand this correctly then you propose to do the decision on
>>> whether to implement a flow in software or offload it to hardware in the
>>> xflows classifier and action. I had exactly the same architecture in mind
>>> initially when I first approached this and wanted to offload OVS
>>> datapath flows transparently to hardware.
>>
>> Think about xflows as an iface to multiple backends, some sw and some hw.
>> User will be able to specify which backed he wants to use for particular
>> "commands".
>>
>> So for example, ovs kernel datapath module will implement an xflows
>> backend and register it as "ovsdp". Rocker will implement another xflows
>> backend and register it as "rockerdp". Then, ovs userspace will use xflows
>> api to setup both backends independently, but using the same xflows api.
>>
>> It is still up to userspace to decide what should be put where (what
>> backend to use).
>
> OK, sounds good so far. Although we can't completely ditch the existing
> genl based OVS flow API for obvious backwards compatibility reasons ;-)
>
> How does John's API fit into this? How would you expose capabilities
> through xflows? How would it differ from what John proposes?
>
> Since this would be a regular tc classifier I assume it could be
> attached to any tc class and interface and then combined with other
> classifiers which OVS would not be aware of. How do you intend to
> resolve such conflicts?
>
> Example:
>   eth0:
>     ingress qdisc:
>       cls prio 20 u32 match [...]
>       cls prio 10 xflows [...]
>
> If xflows offloads to hardware, the u32 classifier with higher
> priority is hidden unintentionally.
>

I thought about this at length. And I'm not opposed to pulling my API
into a 'tc classifier' but I its not 100% clear to me the reason it
helps.

First 'tc' infrastructure doesn't have any classifier that would map
well to this today so you are talking about a new classifier looks like
Jiri is calling it xflows. This is fine.

Now 'xflows' needs to implement the same get operations that exist in
this flow API otherwise writing meaningful policies as Thomas points out
is crude at best. So this tc classifier supports 'get headers',
'get actions', and 'get tables' and then there associated graphs. All
good so far. This is just an embedding of the existing API in the 'tc'
netlink family. I've never had any issues with this. Finally you build
up the 'get_flow' and 'set_flow' operations I still so no issue with
this and its just an embedding of the existing API into a 'tc
classifier'. My flow tool becomes one of the classifier tools.

Now what should I attach my filter to? Typically we attach it to qdiscs
today. But what does that mean for a switch device? I guess I need an
_offloaded qdisc_? I don't want to run the same qdisc in my dataplane
of the switch as I run on the ports going into/out of the sw dataplane.
Similarly I don't want to run the same set of filters. So at this point
I have a set of qdiscs per port to represent the switch dataplane and
a set of qdiscs attached to the software dataplane. If people think this
is worth doing lets do it. It may get you a nice way to manage QOS while
your @ it.

At this point we have the above xflows filter that works on hardware and
some qdisc abstraction to represent hardware great.

What I don't have a lot of use for at the moment is an xflows that runs
in software? Conceptually it sounds fine but why would I want to mirror
hardware limitations into software? And if I make it completely generic
it becomes u32 more or less. I could create an optimized version of the
hardware dataplane in userspace which sits somewhere between u32 and the
other classifiers on flexility and maybe gains some performance but I'm
at a loss as to why this is useful. I would rather spend my time getting
better performance out of u32 and dropping qdisc_lock completely then
writing some partially useful filter for software.

My original conclusion was not to worry about embedding it inside 'tc'
and I didn't mind having another netlink family but I'm not opposed to
doing the embedding also if it helps someone, even if just resolves some
cognitive dissonance.

.John


-- 
John Fastabend         Intel Corporation
