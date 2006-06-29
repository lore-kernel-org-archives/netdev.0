From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 10:51:11 +0200
Message-ID: <20060629085111.GY1376@postel.suug.ch>
References: <44A0138F.8050208@trash.net> <20060626.104654.98552111.davem@davemloft.net> <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net> <20060627100309.GU1376@postel.suug.ch> <1151413670.6516.57.camel@jzny2> <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:4240 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751543AbWF2Iuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 04:50:50 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151502408.5203.94.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-28 09:46
> Why not use iflink?
> It exists, by definition, specifically as "the ifindex of the down muxed
> netdevice" (should probably add that definition in the .h).
> 
> This is semantically different from a message to the stack which says
> "this came to you from input device X" (represented by input_dev).

I disagree, iflink information is bogus once we start redirecting.

> > What's special about that? It seems a perfectly fine and simple way
> > to create namespaces for sockets without enforcing applications to
> > bind to the correct vlan devices directly.
> > 
> 
> Can you achieve the same by binding to any arbitrary netdevice? If you
> can then i would agree.

It was your request to not update input_dev in netif_receive_skb()
but rather have each netdevice handle it manually. What's currently
done in ifb:

	skb->dev = skb->input_dev;
	skb->input_dev = dev;

Confusing, isn't it? I really don't get input_dev/iif is supposed to
be updated in ifb. If a packet is to be redirected, the mirred action
shall take care of providing this information to the next netdevice.
My additional request is to provide a flag to disable this for special
purposes not hurting anyone.

> Please refer to what i said above in that you could end up redirecting
> many times. I have not added yet the code which allows mirred to also do
> ingress redirection which would make it even more interesting.
> The challenge is this, and if you can solve it we would be fine:
> - I need to access both the input_dev and dev and their metadata.
> I could clearly find them by their ifindices and then reference them
> after that. For performance reasons that is not optimal in the fast
> path.  

Nice, you forget that while redirecting the device pointed to by
input_dev can disappear leaving behind an illegal reference. The
purpose of this patch is to fix this.
