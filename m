From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 13:17:45 -0700 (PDT)
Message-ID: <20060630.131745.15264335.davem@davemloft.net>
References: <1151688732.5270.101.camel@jzny2>
	<44A56294.7030309@trash.net>
	<1151696426.5270.224.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7066
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750914AbWF3URn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 16:17:43 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151696426.5270.224.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 30 Jun 2006 15:40:26 -0400

> My arguement was:
> dev get by index per device will involve a a) lookup + b) incrementing
> the refcount. 
> if i use the dev pointer in that path then it becomes only #b
> 
> in both cases, you need to increment the counter and then somewhere
> decrement it.

The position is that ->input_dev usage is not fast path.

It may be a fast path in your mirred and ifb devices, but for the rest
of the networking and %99 of users it is totally unused.  We have a
lot of bits of state that sit in the sk_buff but which are used by
a tiny minority, yet the space consumption is eaten by everyone.

Maybe when the IFB and mirred are in more widespread use we can
investigate a different approach.

But at this time any change that makes fringe sk_buff state objects
shrink or disappear will be seriously considered.

Another part of this issue is that if you use a pointer there is no
clean place to clean up the input_dev reference within the scope it is
actually used.  The only reliable place is kfree_skb() which is far
beyond the scope that this ->input_dev thing is used.  We have a lot
of problems in some parts of the networking because object references
are held for too long.  One example is all the awful side effects of
the way the bridge netfilter code holds onto object references for
long periods of time in the netfilter call chains.

And we know the refcounting is broken.  And one way we know to fix
the refcounting without incurring the cost upon everyone is to
use an interface index and only make the input_dev users eat the
atomic operation incurred by grabbing the reference.

And even for the input_dev users, it isn't such a big deal, there
are other costs already associated with hitting these actions and
devices that use input_dev, the atomic reference grab there should
be lost in the noise I think.
