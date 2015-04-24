From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 17:59:25 -0700
Message-ID: <5539956D.5070506@plumgrid.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com> <CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com> <55381F14.4070708@plumgrid.com> <553959E3.9070209@mojatatu.com> <55396E70.2080908@plumgrid.com> <5539775E.6070704@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35417 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbbDXA71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 20:59:27 -0400
Received: by pabtp1 with SMTP id tp1so32830581pab.2
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 17:59:26 -0700 (PDT)
In-Reply-To: <5539775E.6070704@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/23/15 3:51 PM, Jamal Hadi Salim wrote:
>
> So you are planning to add queues? If you are that is a different
> discussion (and the use case needs some clarity).

nope. I wasn't planning to do that.

 > For packets being forwarded we already had egress qdiscs which had
 > queues so it didnt seem to make sense to enqueue on ingress for such
 > use cases.
 > There was a use case later where multiple ingress ports had to be
 > shared
 > and ifb was born - which is pseudo temporary enqueueing on ingress.

agree. imo ifb approach is more flexible, since it has full hierarchy
of qdiscs. As you're saying above and from the old ifb logs I thought
that ifb is _temporary_ and long term plan is to use ingress_queue,
but looks like this is not the case. Also not too long ago we decided
that we don't want another ingress qdisc. Therefore I think it makes
sense to simplify the code and boost performance.
I'm not proposing to change tooling, of course.
 From iproute2 point of view we'll still have ingress qdisc.
Right now we're pointlessly allocating memory for it and for
ingress_queue, whereas we only need to call cls/act.
I'm proposing to kill them and used tcf_proto in net_device instead.
Right now to reach cls in critical path on ingress we do:
rxq = skb->dev->ingress_queue
sch = rxq->qdisc
sch->enqueue
sch->filter_list
with a bunch of 'if' conditions and useless memory accesses in-between.
If we add 'ingress_filter_list' directly to net_device,
it will be just:
skb->dev->ingress_filter_list
which is huge performance boost. Code size will shrink as well.
iproute2 and all existing tools will work as-is. Looks as win-win to me.

>>> The fact that qdiscs dealt with these codes directly
>>> allows for specialized handling. Moving them to a generic function
>>> seems to defeat that purpose. So I am siding with Cong on this.
>>
>> that's not what patch 1 is doing. It is still doing specialized
>> handling... but in light of what you said above, it looks like much
>> bigger cleanup is needed. We'll continue arguing when I refactor
>> this set and resubmit when net-next reopens.
>
> Sorry - i was refereing to the patch where you agregated things after
> the qdisc invokes a classifier.

hmm. There I also didn't convert all qdiscs into single helper.
Only those that have exactly the same logic after tc_classify.
All other qdiscs have custom handling.
No worries, it's hard to review things while traveling. Been there :)
