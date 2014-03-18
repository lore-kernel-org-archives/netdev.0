From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: What's the status of TCP friends?
Date: Tue, 18 Mar 2014 02:21:20 +0100
Message-ID: <20140318012120.GG12291@order.stressinduktion.org>
References: <20140316090744.GA14572@gmail.com> <1394978619.9668.14.camel@edumazet-glaptop2.roam.corp.google.com> <20140317031605.GA22502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, Li Yu <bingtian.ly@taobao.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Brutus Curtis <brutus@google.com>,
	Weiping Pan <panweiping3@gmail.com>, tmorvai@gmail.com
To: Zheng Liu <gnehzuil.liu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42314 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbaCRBVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 21:21:22 -0400
Content-Disposition: inline
In-Reply-To: <20140317031605.GA22502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 11:16:05AM +0800, Zheng Liu wrote:
> On Sun, Mar 16, 2014 at 07:03:39AM -0700, Eric Dumazet wrote:
> > On Sun, 2014-03-16 at 17:07 +0800, Zheng Liu wrote:
> > > Hi all,
> > > 
> > > Until now the TCP friends patch set doesn't be applied.  Now what's the
> > > status of TCP friends?  Is it applicable to be merged into upstream
> > > kernel?  Any problem that needs to be fixed?  Please let me know if I
> > > can help.
> > 
> > Well, last attempts showed that while the idea sounded cool,
> > implementation opened many races and added quite a lot of complexity in
> > fast path.
> 
> Thanks for letting me know the current status of this patch set.
> 
> > 
> > We have AF_UNIX with a lot of problems in it, do we really want to bring
> > these AF_UNIX problems to AF_INET ?
> 
> Please bear with me because I am a newbie.  Out of curiosity, what's the
> problem in AF_UNIX?

AFAIK AF_UNIX/SOCK_STREAM is fine.

I currently know about two problems with AF_UNIX datagram modes:

1) Not correclty handling socket receive buffer limits. SOCK_DGRAM simply
   relies on the sending window only and socket receive queue is only limited
   by the number of packets enqueued. A DoS against another UNIX/DGRAM server
   is possible by not freeing its sending window if the client doesn't simply
   pick up its packets.

2) POLLOUT handling seems a bit messed up. This problem was reported by Tamas
   Morvai. We simply trigger POLLOUT too often thus waking up the sending side
   unnecessarily.

Patch for 1) was rightfully rejected because it could easily break
backwards compatibility.

There were some ideas floating around which I discussed with Tamas but
nothing definite for 2), as I got stuck to work on 1) and I am still
unsure what side-effects could have the needed removal of the per-packet
socket-receive limit, which seems to be needed for solving 2). The total
amount of memory in use by AF_UNIX/DGRAM sockets would be limited by
the sending buffers and rlimits, but it still seems unwise to do so.

Also solving 2) could make problems regarding backwards-compatibility.

> > I would rather spend time on AF_UNIX if it doesn't fit your needs right
> > now, or consider jumping to KDBUS modern design.
> > 
> > Using AF_INET for IPC is poor choice.
> 
> The reason why we use AF_INET for IPC rather than use AF_UNIX is that we
> have two applications that need to communicate with each other.  They
> could be deployed on the same server or different servers.  So obviously
> if we use AF_INET, we just need to indicate a IP address in config file.
> That sounds rational and maintainable for our operation team.

As soon as we are allowed to silently drop packets in AF_UNIX/DGRAM some
problems would vanish, too. ;)

Greetings,

  Hannes
