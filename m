From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 20:37:58 -0700
Message-ID: <CAHA+R7NpbQaWdXzdu24FZdRFn1VJvf6q14JyfCpD2dXkx-mz6w@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-3-git-send-email-ast@plumgrid.com>
	<CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>
	<55381F14.4070708@plumgrid.com>
	<553959E3.9070209@mojatatu.com>
	<55396E70.2080908@plumgrid.com>
	<5539775E.6070704@mojatatu.com>
	<5539956D.5070506@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33665 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbbDXDiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 23:38:00 -0400
Received: by wgin8 with SMTP id n8so37407745wgi.0
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 20:37:58 -0700 (PDT)
In-Reply-To: <5539956D.5070506@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2015 at 5:59 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 4/23/15 3:51 PM, Jamal Hadi Salim wrote:
>>
>>
>> So you are planning to add queues? If you are that is a different
>> discussion (and the use case needs some clarity).
>
>
> nope. I wasn't planning to do that.
>
>> For packets being forwarded we already had egress qdiscs which had
>> queues so it didnt seem to make sense to enqueue on ingress for such
>> use cases.
>> There was a use case later where multiple ingress ports had to be
>> shared
>> and ifb was born - which is pseudo temporary enqueueing on ingress.
>
> agree. imo ifb approach is more flexible, since it has full hierarchy
> of qdiscs. As you're saying above and from the old ifb logs I thought
> that ifb is _temporary_ and long term plan is to use ingress_queue,
> but looks like this is not the case. Also not too long ago we decided
> that we don't want another ingress qdisc. Therefore I think it makes
> sense to simplify the code and boost performance.

Which performance problem did you see? Did you hit the spinlock
bottleneck? That spinlock should be eliminated before you
try to do more, and it can be replaced by RCU read lock after
John's work (I am still waiting for his patch btw).


> I'm not proposing to change tooling, of course.
> From iproute2 point of view we'll still have ingress qdisc.
> Right now we're pointlessly allocating memory for it and for
> ingress_queue, whereas we only need to call cls/act.
> I'm proposing to kill them and used tcf_proto in net_device instead.
> Right now to reach cls in critical path on ingress we do:
> rxq = skb->dev->ingress_queue
> sch = rxq->qdisc
> sch->enqueue
> sch->filter_list
> with a bunch of 'if' conditions and useless memory accesses in-between.
> If we add 'ingress_filter_list' directly to net_device,
> it will be just:
> skb->dev->ingress_filter_list
> which is huge performance boost. Code size will shrink as well.
> iproute2 and all existing tools will work as-is. Looks as win-win to me.

Nope, it breaks Qdisc abstraction, filters never attach to netdevice
directly. You should stop, since you really don't understand the code.
