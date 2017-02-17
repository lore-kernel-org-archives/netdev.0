From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH][CFT] Saner error handling in skb_copy_datagram_iter()
 et.al.
Date: Fri, 17 Feb 2017 17:03:15 +0000
Message-ID: <20170217170315.GE29622@ZenIV.linux.org.uk>
References: <20170212054209.GQ13195@ZenIV.linux.org.uk>
 <2337836.67BmyCWMtR@debian64>
 <20170214013306.GS13195@ZenIV.linux.org.uk>
 <20170217.105420.2167024053308682803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rlwinm@sdf.org,
        alexmcwhirter@triadic.us, chunkeey@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53330 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933900AbdBQRDW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 12:03:22 -0500
Content-Disposition: inline
In-Reply-To: <20170217.105420.2167024053308682803.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 10:54:20AM -0500, David Miller wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Tue, 14 Feb 2017 01:33:06 +0000
> 
> > OK...  Remaining interesting question is whether it adds a noticable
> > overhead.  Could somebody try it on assorted benchmarks and see if
> > it slows the things down?  The patch in question follows:
> 
> That's about a 40 byte copy onto the stack for each invocation of this
> thing.  You can benchmark all you want, but it's clear that this is
> non-trivial amount of work and will take some operations from fitting
> in the cache to not doing so for sure.

In principle, that could be reduced a bit (32 bytes - ->type is never
changed, so we don't need to restore it), but that's not much of improvement...

Hell knows; at the very least, we need to restore the original position in
case of csum failure.  EFAULT is a separate story (and I'm still not sure
if tcp_input is handling it right), but csum mismatch will be retried and
we want the payload of retransmitted packet to go into the same place, not
past what we'd managed to copy.  AFAICS, original logics used to be
	* skb_copy_and_csum_...() never copied more than one iovec worth of
data.
	* iovec had been drained only on success; during the copy we kept
pointer + remaining length in local variables
	* if copying would have to go into skb fragments, we would just
calculate the checksum separately and then go for plain copy.

Not crossing from iovec to iovec reduced the amount of state to carry/revert
and AFAICS recursive call into skb fragments on the checksum-as-we-copy
path had been dead code all along - we went for separate checksum path in
cases when it would be reached.

Is my reading of pre-e5a4b0bb803b logics correct?  Was the recursive call
of skb_copy_and_csum_datagram() ever reached?
