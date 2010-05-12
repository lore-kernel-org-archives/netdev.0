From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/2] ioat2,3: convert to producer/consumer locking
Date: Wed, 12 May 2010 09:36:05 +0100
Message-ID: <31229.1273653365@redhat.com>
References: <20100511185141.6139.98842.stgit@localhost.localdomain> <20100511184949.6139.96826.stgit@localhost.localdomain>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100511185141.6139.98842.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Out of interest, does it make the code smaller if you mark
ioat2_get_ring_ent() and ioat2_ring_mask() with __attribute_const__?

I'm not sure whether it'll affect how long gcc is willing to cache these, but
once computed, I would guess they won't change within the calling function.

Also, is the device you're driving watching the ring and its indices?  If so,
does it modify the indices?  If that is the case, you might need to use
read_barrier_depends() rather than smp_read_barrier_depends().

> +		prefetch(ioat2_get_ring_ent(ioat, idx + i + 1));
> +		desc = ioat2_get_ring_ent(ioat, idx + i);
>  		dump_desc_dbg(ioat, desc);
>  		tx = &desc->txd;
>  		if (tx->cookie) {

Is this right, I wonder?  You're prefetching [i+1] before reading [i]?  Doesn't
this mean that you might have to wait for [i+1] to be retrieved from RAM before
[i] can be read?  Should you instead read tx->cookie before issuing the
prefetch?  Admittedly, this is only likely to affect the reading of the head of
the queue - subsequent reads in the same loop will, of course, have been
prefetched.

David
