From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Thu, 02 Apr 2015 14:05:22 +0200
Message-ID: <1427976322.2102693.248509005.00F7A326@webmail.messagingengine.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
 <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
 <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHA+R7NXpuSOAwWpetFA+TyLh1d_v9kwiKxhPq4f=vowJJKb1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:33544 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753112AbbDBMFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 08:05:23 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 1697E209A9
	for <netdev@vger.kernel.org>; Thu,  2 Apr 2015 08:05:19 -0400 (EDT)
In-Reply-To: <CAHA+R7NXpuSOAwWpetFA+TyLh1d_v9kwiKxhPq4f=vowJJKb1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 2, 2015, at 04:55, Cong Wang wrote:
> On Wed, Apr 1, 2015 at 5:27 PM, Eric Dumazet <eric.dumazet@gmail.com>
> wrote:
> > On Wed, 2015-04-01 at 17:06 -0700, Cong Wang wrote:
> >
> >> Shouldn't these skb's be orphaned for tunnel cases? Or we still have
> >> to keep skb->sk for other valid use?
> >
> > skb should not be orphaned, until the very last stage.
> >
> > Many layers depend on this, really.
> >
> > Simply ask the question to yourself :
> >
> > What if I do not associate skb to a socket at first. What possibly
> > breaks ?
> >
> > orphaning skb just because they traverse a tunnel would be quite
> > horrible.
> >
> 
> I didn't make it clear, I meant to say "resetting the skb->sk to tunnel
> socket". I know sch_fq uses skb->sk for flow classification, but
> if skb->sk still points to the user-space socket, its meaning is already
> changed after encapsulation, with regarding to this, all traffic goes
> out of this tunnel should be one flow.

We cannot block/stop a tunnel submitting more packets into the stack via
its socket. We have to close the feedback loop directly to user space.
If we need this tunnel socket available it has to be passed either as an
additional field in sk_buff or via arguments down the stack.
In case of forwarding this works without skb->sk because we mostly
always run to completion and submit the packet in one softirq call.

> This also means ipv6 should not use any socket setting for routing
> lookup, since after resetting skb->sk in encapsulation skb's belong
> to one kernel socket which doesn't have any socket options set.

Yes, this is right. But besides xfrm6 layer I am currently looking after
I haven't seen problematic code here.

Bye,
Hannes
