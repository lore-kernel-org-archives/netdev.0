From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPCOMP] Use per-cpu buffers
Date: Fri, 10 Sep 2004 21:10:47 +1000
Sender: linux-ppp-owner@vger.kernel.org
Message-ID: <20040910111047.GA29330@gondor.apana.org.au>
References: <20040909122202.GA3170@gondor.apana.org.au> <20040909091652.490c7833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com,
	linux-ppp@vger.kernel.org, paulus@samba.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040909091652.490c7833.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

On Thu, Sep 09, 2004 at 09:16:52AM -0700, David S. Miller wrote:
> 
> > With per-cpu buffers this goes down to 300K per CPU.
> 
> That amount of space just for decompression state is
> rediculious.

Actually most of that space is for compression.  The space for
decompression is only 32K if I read the zlib comment correctly.
However, due to the current crypto interface, you always have
to allocate both and you have to reserve a 64K buffer just in
case the packet is large.

There's gotta be a better way though.  What if the packet length
field was 32 bits? Surely we aren't going to allocate a 4G buffer :)

James, can you think of a general solution to the 64K buffer in
terms of the crypto decompression interface?

> A second thought is that we may not be the only part
> of the kernel interested in a per-cpu zlib scratch
> buffer, no?

There are two other users.  JFFS2 is already using one global copy
accessed through a semaphore.  Maybe we should move the IPCOMP
processing into process context as well since it's so slow.

PPP is the other user and allocates one for each device that requests
for deflate compression.

The problem isn't as bad for PPP as it is for IPsec because firstly
PPP is less scalable anyway due to the device/process overhead.  More
importantly if compression allocation fails PPP can still carry on.

Unfortunately for IPsec, the compression allocation is done after the
negotiation so there is no room for recovery (you'll have to redo the
negotiation).

On a totally orthogonal topic, has any body thought of doing a PPP
daemon like the IPsec daemons? That is, have one process that manages
all PPP sessions.  This could be useful for large L2TP servers and
alike.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
