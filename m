From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] net: frag queue per hash bucket locking
Date: Thu, 28 Mar 2013 15:19:10 -0400 (EDT)
Message-ID: <20130328.151910.540325879819648208.davem@davemloft.net>
References: <20130328185721.GA20223@order.stressinduktion.org>
	<20130328.150359.1119974430252894273.davem@davemloft.net>
	<20130328191050.GB20223@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, brouer@redhat.com, netdev@vger.kernel.org,
	fw@strlen.de, dborkman@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab3C1TTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 15:19:12 -0400
In-Reply-To: <20130328191050.GB20223@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 28 Mar 2013 20:10:50 +0100

> On Thu, Mar 28, 2013 at 03:03:59PM -0400, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Thu, 28 Mar 2013 19:57:21 +0100
>> 
>> > On Wed, Mar 27, 2013 at 10:25:59AM -0700, Eric Dumazet wrote:
>> >> On Wed, 2013-03-27 at 16:56 +0100, Jesper Dangaard Brouer wrote:
>> >> > This patch implements per hash bucket locking for the frag queue
>> >> > hash.  This removes two write locks, and the only remaining write
>> >> > lock is for protecting hash rebuild.  This essentially reduce the
>> >> > readers-writer lock to a rebuild lock.
>>  ...
>> >> I am not sure why you added _bh suffix to spin_lock()/spin_unlock()
>> >> here ?
>> > 
>> > I assume that it has to do with the usage of this code in
>> > ipv6/netfilter/nf_conntrack_reasm.c, which could be invoked from process
>> > context, if I read it correctly.
>> 
>> That appears to be the case yes.
>> 
>> That's an odd environment for these routines to be invoked from,
>> so longer term we should probably make the nf conntrack code do
>> the BH disabling around the inet frag calls, rather than make the
>> inet frag code eat the extra overhead for the more common invocations.
> 
> My idea was a bh-safe flag in struct inet_frags and conditionally use
> spin_lock and spin_unlock_bh (these could be wrapped in inline functions just
> for inet_fragment.c).

That's an extra check eaten by all users.  Really, put the overhead into
the call sites that need it, and nowhere else.
