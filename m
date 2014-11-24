From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 08/17] {macvtap,tun}_get_user(): switch to iov_iter
Date: Mon, 24 Nov 2014 10:15:46 +0000
Message-ID: <20141124101546.GE7996@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
 <20141122042856.GZ7996@ZenIV.linux.org.uk>
 <20141122043352.GH30478@ZenIV.linux.org.uk>
 <1416788862.7215.65.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	hch@infradead.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416788862.7215.65.camel@decadent.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 12:27:42AM +0000, Ben Hutchings wrote:
> >  		copylen = vnet_hdr.hdr_len ? vnet_hdr.hdr_len : GOODCOPY_LEN;
> >  		if (copylen > good_linear)
> >  			copylen = good_linear;
> >  		linear = copylen;
> > -		if (iov_pages(iv, vnet_hdr_len + copylen, count)
> > -		    <= MAX_SKB_FRAGS)
> > +		i = *from;
> > +		iov_iter_advance(&i, copylen);
> > +		if (iov_iter_npages(&i, INT_MAX) <= MAX_SKB_FRAGS)
> 
> The maxpages argument should be MAX_SKB_FRAGS + 1 as we don't need the
> exact number.

In principle, that's true, but...  Do we really care?  It only buys you
anything if you have a monstrously fragmented iovec.  And if you end up
spending too considerable amount of time in that loop in iov_iter_npages,
you are by definition on the slow path - it *will* fail, since we do not
even try to merge adjacent iovec segments.  Never had...
