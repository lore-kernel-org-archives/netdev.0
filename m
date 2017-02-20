From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][CFT] Saner error handling in skb_copy_datagram_iter()
 et.al.
Date: Mon, 20 Feb 2017 10:14:04 -0500 (EST)
Message-ID: <20170220.101404.1931404813887976325.davem@davemloft.net>
References: <20170217.105420.2167024053308682803.davem@davemloft.net>
        <20170217170315.GE29622@ZenIV.linux.org.uk>
        <20170218000214.GA19777@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rlwinm@sdf.org,
        alexmcwhirter@triadic.us, chunkeey@googlemail.com
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38270 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753450AbdBTPWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:22:30 -0500
In-Reply-To: <20170218000214.GA19777@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 18 Feb 2017 00:02:14 +0000

> On Fri, Feb 17, 2017 at 05:03:15PM +0000, Al Viro wrote:
>> On Fri, Feb 17, 2017 at 10:54:20AM -0500, David Miller wrote:
>> > From: Al Viro <viro@ZenIV.linux.org.uk>
>> > Date: Tue, 14 Feb 2017 01:33:06 +0000
>> > 
>> > > OK...  Remaining interesting question is whether it adds a noticable
>> > > overhead.  Could somebody try it on assorted benchmarks and see if
>> > > it slows the things down?  The patch in question follows:
>> > 
>> > That's about a 40 byte copy onto the stack for each invocation of this
>> > thing.  You can benchmark all you want, but it's clear that this is
>> > non-trivial amount of work and will take some operations from fitting
>> > in the cache to not doing so for sure.
>> 
>> In principle, that could be reduced a bit (32 bytes - ->type is never
>> changed, so we don't need to restore it), but that's not much of improvement...
> 
> Actually, I've a better solution.  Namely, analogue of iov_iter_advance()
> for going backwards.  The restriction is that you should never unroll
> further than where you've initially started *or* have the iovec, etc.
> array modified under you.  For iovec/kvec/bio_vec it's trivial, for pipe -
> a bit more convoluted, but still doable.  Then net/core/datagram.c stuff
> could simply use iov_iter_unroll() in case of error - all we need to keep
> track of is how much had we copied and that's easy to do.
> 
> The patch below is completely untested, but if it works it should avoid
> buggering the fast paths at all, still giving the same semantics re
> reverting ->msg_iter both on EINVAL and EFAULT.  Comments?

This looks a lot better to me.
