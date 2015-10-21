From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Wed, 21 Oct 2015 19:12:58 +0200
Message-ID: <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
References: <20151021164613.24650836@griffin>
 <20151021.083214.534622235927401863.davem@davemloft.net>
 <20151021172502.63220dbb@griffin>
 <20151021.085635.1582760365341524949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: David Miller <davem@davemloft.net>, jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:40702 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751735AbbJURNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 13:13:02 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id E86A020307
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 13:12:58 -0400 (EDT)
In-Reply-To: <20151021.085635.1582760365341524949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Oct 21, 2015, at 17:56, David Miller wrote:
> From: Jiri Benc <jbenc@redhat.com>
> Date: Wed, 21 Oct 2015 17:25:02 +0200
> 
> > On Wed, 21 Oct 2015 08:32:14 -0700 (PDT), David Miller wrote:
> >> As you say the apps are broken, so file a bug and have them fixed.
> >> 
> >> The assumption is clearly invalid, so apps cannot make such an
> >> assumption.
> > 
> > Does it mean you would be okay with a patch that always allocates and
> > assigns a new ifindex in the target netns when interface is moved
> > between name spaces?
> 
> I think you're misunderstanding me if you're still recommending
> kernel changes.
> 
> I'm plainly saying to remove the assumption in the apps.
> 
> If you don't show me exactly how some kernel change can lead to
> the apps implementing things properly, without the invalid
> assumptions, then I can only assume you didn't hear what I
> said.

I think the reason why ifindexes exists as ints is that we want to have
lightweight way to refer to interfaces without taking references or
timestamps or generation ids which completely remove the possibility for
races. But the racy nature in ifindexes is something we actually want,
otherwise a user space program acquiring an ifindex would need to get a
reference on the device and either during socket close or program
termination release it, that would be very costly.

This patch minimizes the race quite a lot, from something we could
actually see in everydays container creation to probably something only
some users will expire with depleting the ifindex pool or playing around
with CRIU.

We could come up with more heavy machinery to close the race further for
CRIU by keeping track of "poisoned" ifindexes, which would need a
hashmap which could become pretty big and we could recycle when ifindex
wraps around, but this seems too heavy weight to me.

I am in favor of a solution to minimize this race in the kernel even
though we cannot ever close it completely.

Bye,
Hannes
