From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 3/3] net: frag queue per hash bucket locking
Date: Thu, 28 Mar 2013 20:10:50 +0100
Message-ID: <20130328191050.GB20223@order.stressinduktion.org>
References: <20130327155601.15203.25289.stgit@dragon> <1364405159.15753.26.camel@edumazet-glaptop> <20130328185721.GA20223@order.stressinduktion.org> <20130328.150359.1119974430252894273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, brouer@redhat.com, netdev@vger.kernel.org,
	fw@strlen.de, dborkman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37135 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331Ab3C1TKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 15:10:51 -0400
Content-Disposition: inline
In-Reply-To: <20130328.150359.1119974430252894273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 03:03:59PM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 28 Mar 2013 19:57:21 +0100
> 
> > On Wed, Mar 27, 2013 at 10:25:59AM -0700, Eric Dumazet wrote:
> >> On Wed, 2013-03-27 at 16:56 +0100, Jesper Dangaard Brouer wrote:
> >> > This patch implements per hash bucket locking for the frag queue
> >> > hash.  This removes two write locks, and the only remaining write
> >> > lock is for protecting hash rebuild.  This essentially reduce the
> >> > readers-writer lock to a rebuild lock.
>  ...
> >> I am not sure why you added _bh suffix to spin_lock()/spin_unlock()
> >> here ?
> > 
> > I assume that it has to do with the usage of this code in
> > ipv6/netfilter/nf_conntrack_reasm.c, which could be invoked from process
> > context, if I read it correctly.
> 
> That appears to be the case yes.
> 
> That's an odd environment for these routines to be invoked from,
> so longer term we should probably make the nf conntrack code do
> the BH disabling around the inet frag calls, rather than make the
> inet frag code eat the extra overhead for the more common invocations.

My idea was a bh-safe flag in struct inet_frags and conditionally use
spin_lock and spin_unlock_bh (these could be wrapped in inline functions just
for inet_fragment.c).
