From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp4: Don't take socket reference in receive path
Date: Thu, 06 Feb 2014 15:08:58 -0800
Message-ID: <1391728138.10160.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1402061154580.17707@tomh.mtv.corp.google.com>
	 <1391720338.10160.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx9Zovogvnc0_J2Xrf-B+yjxV4Of-24SDLNTt5WGsL5Qhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:45443 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201AbaBFXJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 18:09:01 -0500
Received: by mail-pd0-f178.google.com with SMTP id y13so2328658pdi.23
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 15:09:00 -0800 (PST)
In-Reply-To: <CA+mtBx9Zovogvnc0_J2Xrf-B+yjxV4Of-24SDLNTt5WGsL5Qhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-06 at 14:40 -0800, Tom Herbert wrote:

> >
> The rationale for SLAB_DESTROY_BY_RCU might be different for UDP than
> TCP. For instance, in the DNS example small connected UDP flows are
> more an issue on the client, the server (which is likely to have much
> greater load) should be using unconnected sockets.
> 

I know some servers have a non connected UDP socket acting as a
'listener' and instancing a new connected socket for ever incoming flow.

You cannot really know what model is used.

> In any case, I am still looking for a way to address this. Like I said
> in the commit log, this per packet cost for UDP processing is far too
> high at least in encapsulation path. I thought about extending
> SO__REUSEPORT to provide CPU affinity but that seems like overkill
> with its own performance implications. Alternatively, we could have
> fast path for the encapsulation using UDP offload model which bypass
> sockets completely which seems unpleasant.

Note that you can solve this before UDP layer, in GRO for example.

If layers before UDP already provide skb->sk (early demux), this could
be a socket that is plainly using call_rcu() for its destruction, and
you do not need to touch socket refcount.

Alternative would be to use a percpu refcnt for these special 'sockets'
that potentially are receiving XX millions frames per second using 48
cpus...

Kent Overstreet designed Percpu refcounts, maybe you should take a look
at this.
