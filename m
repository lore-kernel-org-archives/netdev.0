From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Netlink, route monitoring, RTM_DELROUTE not issued for ppp peer
 address. Bug or feature?
Date: Mon, 16 Apr 2012 08:19:54 -0700
Message-ID: <20120416081954.1bb994db@nehalam.linuxnetplumber.net>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
	<023e01cd197d$a9faba40$fdf02ec0$@no>
	<3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stian Skjelstad <stian@nixia.no>, <eric.dumazet@gmail.com>,
	<stephen.hemminger@vyatta.com>, <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38003 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883Ab2DPPT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 11:19:57 -0400
In-Reply-To: <3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Apr 2012 13:37:14 +0300
Denys Fedoryshchenko <denys@visp.net.lb> wrote:

> After digging the code, i came to conclusion:
> fib_del_ifaddr, will check if deleted address are exist as prefsrc or 
> interface are shut down, they will do fi->fib_flags |= RTNH_F_DEAD;
> Then fib_flush -> fib_table_flush -> trie_flush_leaf -> trie_flush_list 
> will delete such routes.
> But trie_flush_list won't notify over netlink that route are deleted.
> 
> So the only solution is to fetch first, then keep full routing table in 
> userspace also, and keep tracking if local addresses deleted, and do the 
> same in userspace and check for prefsrc...
> 
> Maybe it should be fixed? E.g. netlink message sent when any route are 
> deleted, even over the flush
> 
> On 2012-04-13 16:59, Stian Skjelstad wrote:
> > I've seen the same issue, and got no response so far to that very
> > same question. Have you tested this on older kernels? I have worked
> > around this issue by testing my local copy of routing entries that 
> > use
> > 'via'. If they are not routable when after the RTM_DELROUTE event, I
> > autoremove them from my local copy.
> >
> > Stian Skjelstad
> >


Looking at Quagga, it knows that deleting interface address
removes connected routes and silently cleans up.

You have to be really careful here making any changes to not break
applications that expect existing behavior.
