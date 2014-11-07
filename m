From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Fri, 7 Nov 2014 23:42:53 +0000
Message-ID: <20141107234253.GE7996@ZenIV.linux.org.uk>
References: <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141107.164859.951682597018909290.davem@redhat.com>
 <20141107221114.GB7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141107221114.GB7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 07, 2014 at 10:11:14PM +0000, Al Viro wrote:

> I'm looking through the tree right now; so far it looks like we can just
> move those suckers to the point where we validate iovec and lose them
> from low-level iovec and csum copying completely.  I still haven't finished
> tracing all possible paths for address to arrive at the points where we
> currently check that stuff, but so far it looks very doable.

Definitely doable.  The only remaining interesting part is drivers/vhost
with the stuff it puts in vq->iov[].  If we can guarantee that it satisfies
the sanity checks (access_ok() and size-related ones), we are done -
making verify_iovec() use rw_copy_check_uvector() (and verify_compat_iov()
use compat_rw_copy_check_uvector()) will suffice to guarantee that none of
	csum_partial_copy_fromiovecend
	memcpy_fromiovec
	memcpy_toiovec
	memcpy_toiovecend
	memcpy_fromiovecend
	skb_copy_datagram_iovec
	skb_copy_datagram_iter
	skb_copy_datagram_from_iter
	zerocopy_sg_from_iter
	skb_copy_and_csum_datagram
	skb_copy_and_csum_datagram_iovec
	csum_and_copy_from_user
	csum_and_copy_to_user
	csum_partial_copy_from_user
will ever see an address that doesn't satisfy access_ok() checks.  And
having looked at the data flow...  we definitely want to do those checks
on intake of iovec - as it is, we usually repeat them quite a few times
for the same iovec segment, and we practically never end up _not_ doing them
for some segment of iovec, unless we hit a failure exit before we get around
to copying any data at all.

I'll finish RTFS drivers/vhost and if it turns out to be OK I'll post the
series moving those checks to the moment of copying iovec from userland,
so that kernel-side we could always rely on ->msg_iov elements having been
verified.
