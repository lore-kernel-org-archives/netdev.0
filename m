From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress
 qdisc
Date: Tue, 14 Apr 2015 14:05:06 -0400 (EDT)
Message-ID: <20150414.140506.401099074422805944.davem@davemloft.net>
References: <5528C4FC.5020207@iogearbox.net>
	<CAHA+R7N1oPoZBgtF0WOa=aXveT4T=26yfL73Temdp+qWxkxfug@mail.gmail.com>
	<552C65F1.8010402@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, daniel@iogearbox.net, edumazet@google.com,
	tgraf@suug.ch, jiri@resnulli.us, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449AbbDNSFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:05:10 -0400
In-Reply-To: <552C65F1.8010402@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 13 Apr 2015 17:57:21 -0700

> On 4/13/15 3:44 PM, Cong Wang wrote:
>>
>> My suggestion is fairly simple: move skb_pull() out of
>> eth_type_trans()
>> and move it to netif_receive_skb(), it apparently needs much more work
>> but it worth the effort. This would eliminate the skb_push() in mirred
>> and in ifb too, dev_forward_skb() would benefit too.
> 
> wow. That would be massive. We're talking months worth of work here.

I think it's worth the effort.

Alexei I cannot apply your needs_l2 patch, it's fundamentally broken
because it assumes the whole chain of classifiers and actions starting
from a given qdisc root want the skb->data in one place or another.
It can be mixed, and quite easily so, and for that scenerio it's
broken.

You've been told multiple ways to keep the existing stuff working
yet give cls_bpf what it wants.  I'll add another one so you'll have
three options:

1) Firstly, to propagate the packet offset into the code generated
   for the BPF classifier when being attached to the ingress qdisc.
   Not only is this doable, you'll know you aren't being shared with
   other kinds of qdiscs so it'll just work.

2) Adjust where skb_pull() happens, Cong's idea.

3) Do the SKB share_check/pull/push in cls_bpf.  No impact on anyone
   else in the qdisc paths, mixed configurations handled in a guaranteed
   way.

I know none of these fit into your unreasonable idealistic model of
how you want all of this to work, but surprise this is the real world
and you'll need to compromise some of your absolute requirements in
order to meet your goals of proper functionality.

Thanks.
