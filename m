From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: refresh rt6i_genid in ip6_pol_route()
Date: Sun, 07 Sep 2014 21:43:54 -0700
Message-ID: <1410151434.11872.82.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410116703.11872.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140907.155446.2293591154334558042.davem@davemloft.net>
	 <1410149905.11872.73.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140907.212742.893555292268057160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, therbert@google.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:38764 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaIHEn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 00:43:56 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so3942478pdb.39
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 21:43:55 -0700 (PDT)
In-Reply-To: <20140907.212742.893555292268057160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-07 at 21:27 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 07 Sep 2014 21:18:25 -0700
> 
> > On Sun, 2014-09-07 at 15:54 -0700, David Miller wrote:
> > 
> >> This might be broken.
> >> 
> >> We are dealing here with persistent entries in the ipv6 routine trie.
> >> 
> >> If you just bump the genid on the next person to look it up, other
> >> sockets and cached entities might not have validated the route yet,
> >> and now will falsely see the route as valid.  We have to ensure that
> >> they too drop this route and perform a relookup.
> > 
> > I am confused, I thought it was the role of the cookie.
> > 
> > (Ie socket has to store its own cookie to be able to validate a route)
> > 
> > Before 6f3118b571b8 patch, how was this done anyway ?
> > 
> > If persistent routes cannot refresh the genid, then they are useless ?
> 
> I just speak about the genid aspect.
> 
> I understand that cookie (via node->fn_sernum) invalidates the path
> in the fib_trie, but the genid protects against other circumstances
> (matching IPSEC rule, f.e.)
> 
> You have to make sure all other sockets did a full route lookup
> (including IPSEC) before you can safely adjust the genid.
> 
> I could be wrong, recheck my analysis please :-)

So this whole genid protection can not work, unless we make sure a
socket cannot share a route with another socket.

This means we have to clone all routes.
