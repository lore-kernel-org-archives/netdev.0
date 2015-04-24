From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Fri, 24 Apr 2015 10:12:57 +0200
Message-ID: <5539FB09.4050103@iogearbox.net>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com>	<CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>	<55381F14.4070708@plumgrid.com>	<553959E3.9070209@mojatatu.com>	<55396E70.2080908@plumgrid.com>	<5539775E.6070704@mojatatu.com>	<5539956D.5070506@plumgrid.com> <CAHA+R7NpbQaWdXzdu24FZdRFn1VJvf6q14JyfCpD2dXkx-mz6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35226 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965517AbbDXINF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 04:13:05 -0400
In-Reply-To: <CAHA+R7NpbQaWdXzdu24FZdRFn1VJvf6q14JyfCpD2dXkx-mz6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2015 05:37 AM, Cong Wang wrote:
> On Thu, Apr 23, 2015 at 5:59 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On 4/23/15 3:51 PM, Jamal Hadi Salim wrote:
...
>> agree. imo ifb approach is more flexible, since it has full hierarchy
>> of qdiscs. As you're saying above and from the old ifb logs I thought
>> that ifb is _temporary_ and long term plan is to use ingress_queue,
>> but looks like this is not the case. Also not too long ago we decided
>> that we don't want another ingress qdisc. Therefore I think it makes
>> sense to simplify the code and boost performance.
>
> Which performance problem did you see? Did you hit the spinlock
> bottleneck? That spinlock should be eliminated before you
> try to do more  [...]

Those are already the next steps for improving performance after
that, by attempting to get rid of these additional indirections
and shrinking code.

>> I'm not proposing to change tooling, of course.
>>  From iproute2 point of view we'll still have ingress qdisc.
>> Right now we're pointlessly allocating memory for it and for
>> ingress_queue, whereas we only need to call cls/act.
>> I'm proposing to kill them and used tcf_proto in net_device instead.
>> Right now to reach cls in critical path on ingress we do:
>> rxq = skb->dev->ingress_queue
>> sch = rxq->qdisc
>> sch->enqueue
>> sch->filter_list
>> with a bunch of 'if' conditions and useless memory accesses in-between.
>> If we add 'ingress_filter_list' directly to net_device,
>> it will be just:
>> skb->dev->ingress_filter_list
>> which is huge performance boost. Code size will shrink as well.
>> iproute2 and all existing tools will work as-is. Looks as win-win to me.
>
> Nope, it breaks Qdisc abstraction, filters never attach to netdevice
> directly. You should stop, since you really don't understand the code.

Would be great if you make netdev a better place, stop such immature
comments, and keep it technical as everyone else.

The point here is to try thinking outside the box, so lets see how
the result in the end looks like, then we can discuss.
