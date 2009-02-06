From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: copyless virtio net thoughts?
Date: Fri, 6 Feb 2009 16:40:54 +1100
Message-ID: <20090206054054.GA4824@gondor.apana.org.au>
References: <20090205020732.GA27684@sequoia.sous-sol.org> <498ADD73.3060906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, Arnd Bergmann <arnd@arndb.de>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42898 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754851AbZBFFlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 00:41:18 -0500
Content-Disposition: inline
In-Reply-To: <498ADD73.3060906@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 02:37:07PM +0200, Avi Kivity wrote:
>
> I believe that copyless networking is absolutely essential.

I used to think it was important, but I'm now of the opinion
that it's quite useless for virtualisation as it stands.

> For transmit, copyless is needed to properly support sendfile() type  
> workloads - http/ftp/nfs serving.  These are usually high-bandwidth,  
> cache-cold workloads where a copy is most expensive.

This is totally true for baremetal, but useless for virtualisation
right now because the block layer is not zero-copy.  That is, the
data is going to be cache hot anyway so zero-copy networking doesn't
buy you much at all.

Please also recall that for the time being, block speeds are
way slower than network speeds.  So the really interesting case
is actually network-to-network transfers.  Again due to the
RX copy this is going to be cache hot.

> For receive, the guest will almost always do an additional copy, but it  
> will most likely do the copy from another cpu.  Xen netchannel2  

That's what we should strive to avoid.  The best scenario with
modern 10GbE NICs is to stay on one CPU if at all possible.  The
NIC will pick a CPU when it delivers the packet into one of the
RX queues and we should stick with it for as long as possible.

So what I'd like to see next in virtualised networking is virtual
multiqueue support in guest drivers.  No I'm not talking about
making one or more of the physical RX/TX queues available to the
guest (aka passthrough), but actually turning something like the
virtio-net interface into a multiqueue interface.

This is the best way to get cache locality and minimise CPU waste.

So I'm certainly not rushing out to do any zero-copy virtual
networking.  However, I would like to start working on a virtual
multiqueue NIC interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
