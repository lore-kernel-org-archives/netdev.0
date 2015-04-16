From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 18:13:25 +0200
Message-ID: <1429200805.1141475.254665081.0E1724C4@webmail.messagingengine.com>
References: <20150416052357.GA3285@acer.localdomain>
 <20150416052904.GA12648@gondor.apana.org.au>
 <1429186302.1075929.254563877.238D8F77@webmail.messagingengine.com>
 <20150416.114323.2122666447487730641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net, fw@strlen.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:36568 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753744AbbDPQN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:13:26 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 596D720925
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 12:13:25 -0400 (EDT)
In-Reply-To: <20150416.114323.2122666447487730641.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, Apr 16, 2015, at 17:43, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 16 Apr 2015 14:11:42 +0200
> 
> > On Thu, Apr 16, 2015, at 07:29, Herbert Xu wrote:
> >> On Thu, Apr 16, 2015 at 06:24:00AM +0100, Patrick McHardy wrote:
> >> >
> >> > Netfilter may change the contents of the packet, even change its size.
> >> > It is *really* hard to do this while keeping the original fragments
> >> > intact.
> >> 
> >> Perhaps we should provide better helpers to facilitate this?
> >> 
> >> So instead of directly manipulating the content of the skb you
> >> would so so through helpers and the helpers can then try to do
> >> sensible things with the fragments.
> > 
> > When Florian and me started discussing how to solve this we also wanted
> > to be as transparent as possible. But looking at all possible
> > fragmentation scenarios, this seems to be too complicated.
> > 
> > Even imagine a fragment with overlapping offsets and some of the
> > fragments got duplicated. If we had to keep this in frag_list and now
> > netfilter has to change any of this contents, this will become a total
> > mess, like changing one port in multiple skbs at different offsets.
> > 
> > I doubt it is worth the effort.
> 
> You guys keep talking about exceptional cases rather than what is
> unquestionable the common case, and the one worth handling in the
> fast paths.

So currently we have one fast path, that is: we are not fragmented, we
get out non-fragmented, none of this code is ever touched and no
problem.

We don't want to mak this more complex, but

every other solution would need to first expand sk_buff with a new
member(!), then:
  1) push the original fragments through netfilter - I think this will
  definitely break user space compatibility
  2) add new wrappers into the fast path which now will make sure that
  we access the correct skb from the frag_list instead of just
      dereference the pointer - we will make fast path also more slowly
      and a lot more complex
  3) use the reassembled skb for netfilter and emit the original ones -
  seems like a security hazard to me, discrepancy what is 
      checked and what is used
  4) just use the frag_list skb->len's to restore the reassembled skb to
  the original sizes, this would be possible but we would still harm 
      fast-path with that (new skb member) we could switch to
      dynamically allocated array of int[] to store sizes and DF bit
      information
      In particular, even this would not achieve the goal to have
      perfect transparency.

I can give you a more fundamental problem:
We cannot even be transparent if asymmetric routing is in effect and we
don't see all fragments. In case we have contrack rules active, we clear
fragment queues after some time. So a bridge actually will toss
offset!=0 packets if it never sees the head. If we let the packet pass,
we might have a security problem. We can never become fully transparent.

Bye,
Hannes
