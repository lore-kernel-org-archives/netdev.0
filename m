From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Fri, 21 May 2010 06:51:28 -0400
Message-ID: <20100521105128.GA29521@hmsreliant.think-freely.org>
References: <20100520172918.GA17613@shamino.rdu.redhat.com>
 <20100520231630.GA22593@gondor.apana.org.au>
 <20100521003939.GA2223@localhost.localdomain>
 <20100520.224944.102694876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36676 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab0EUKvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 06:51:42 -0400
Content-Disposition: inline
In-Reply-To: <20100520.224944.102694876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 10:49:44PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu, 20 May 2010 20:39:39 -0400
> 
> > On Fri, May 21, 2010 at 09:16:30AM +1000, Herbert Xu wrote:
> >> On Thu, May 20, 2010 at 01:29:18PM -0400, Neil Horman wrote:
> >> >
> >> > So, I'm testing this patch out now, and unfotunately it doesn't seem to be
> >> > working.  Every frame seems to be holding a classid of 0.  Trying to figure out
> >> > why now.
> >> 
> >> Not very surprising since tun.c doesn't go through the normal
> >> socket interface.  I'll send a additional patch for that.
> >> 
> > I don't think thats it.  I think its a chicken and egg situation.  I think the
> > problem is that tasks can't be assigned to cgroups until their created, and in
> > that time a sock can be created.  Its a natural race.  If you create a socket
> > before you assign it to a cgroup, that socket retains a classid of zero.  I'm
> > going to try modify the patch to update sockets owned by tasks when the cgroup
> > is assigned.
> 
> Neil, you must not be using Herbert's most recent patch.
> 
I'm not, I was testing the version prior. I wrote my note before he posted the
update for the tun driver

> Either that or you haven't even read it.
> 
I read it, we just described the issue in diferent terms.

Neil

> Herbert's most recent patch doesn't create this chicken and egg
> problem you mention because it explicitly watches for cgroupid changes
> at all socket I/O operations including sendmsg() and sendmsg().  And
> if it sees a different cgroupid at a socket I/O call, it updates the
> cgroupid value in the socket.
> 
> So you very much can change the cgroup of the process mid-socket
> ownership and it will work.
> 
> The only problem is, as Herbert stated, tun.  Because it does it's
> networking I/O directly by calling netif_receive_skb() so it won't
> hit any of Herbert's cgroup check points.
> 
