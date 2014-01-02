From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] vxlan: distribute vxlan tunneled traffic
 across multiple TXQs
Date: Wed, 01 Jan 2014 21:56:46 -0800
Message-ID: <1388642206.12212.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
	 <20131223112854.572b11aa@nehalam.linuxnetplumber.net>
	 <1387910346.12212.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131231.135636.1587787263812667419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, sathya.perla@emulex.com,
	netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:52685 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaABF4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 00:56:49 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so13857870pdj.9
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 21:56:48 -0800 (PST)
In-Reply-To: <20131231.135636.1587787263812667419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-31 at 13:56 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 24 Dec 2013 10:39:06 -0800
> 
> > On Mon, 2013-12-23 at 11:28 -0800, Stephen Hemminger wrote:
> > 
> >> The idea is good, but without the destructor there is nothing to keep
> >> the UDP socket from being destroyed while packet is being sent on another
> >> CPU.
> > 
> > I see no requirement of holding a reference on the vxlan UDP socket in
> > transmit path.
> 
> I'm trying to figure out how leaving a dangling socket attached to
> skb->sk, as in this original patch, can be OK.

Sorry, I lost track here (vacation time...), what patch are you
referring to ?

> 
> If skb->sk is there, anyone can reference it, and meanwhile anyone can
> destroy and free it.
> 
> That's Stephens' objection.

Not really. Stephen told us he copied code from L2TP.
(But IPIP, GRE tunnels do not do that..._

He thought it was needed to hold a reference on vxlan socket, while it
is not needed for any valid reason. RCU locking is more than enough to
be able to build the encapsulation.

> 
> Are you saying that we have something that allows this to be valid?


Once we pass the tunnel, we can either :

1) Leave skb->sk set to the original socket sk1 (Say TCP or UDP
producer)

2) Assign skb->sk to the 'socket' used in vxlan (after orphaning and
releasing reference on socket sk1)

  Current vxlan code chose 2), but it makes no sense because :

We use skb->sk to 

A) control amount of bytes/packets queued on behalf a socket, but
current vxlan code does the skb->sk transfert without any limit/control
on vxlan socket sk_sndbuf.

B) security puposes (as selinux) or netfilter uses, and I do not think
anything is prepared to handle vxlan stacked case in this area.


If we chose 1), it makes more sense, because each producer will be
effectively limited by the proper sk->sk_sndbuf limit.

And a socket cannot be destroyed anyway as long as at least one skb is
in flight (with skb->sk set to this socket)

Really, I do not think vxlan should behave in a different way than other
tunnels (GRE, IPIP, SIT, ...), which chose 1) 
