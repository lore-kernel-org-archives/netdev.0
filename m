From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Wed, 14 Nov 2007 11:02:11 +1100
Message-ID: <200711141102.11477.nickpiggin@yahoo.com.au>
References: <200711140514.28159.nickpiggin@yahoo.com.au> <20071114.031022.183117678.davem@davemloft.net> <20071114114844.GA13927@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, clameter@sgi.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759578AbXKNMEr@vger.kernel.org>
In-Reply-To: <20071114114844.GA13927@gondor.apana.org.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 14 November 2007 22:48, Herbert Xu wrote:
> On Wed, Nov 14, 2007 at 03:10:22AM -0800, David Miller wrote:
> > So the thing that's being effected here in TCP is
> > net/ipv4/tcp.c:select_size(), specifically the else branch:
>
> Thanks for the pointer.  Indeed there is a bug in that area.
> I'm not sure whether it's causing the problem at hand but it's
> certainly suboptimal.
>
> [TCP]: Fix size calculation in sk_stream_alloc_pskb

This looks like it fixes the problem!

Still interested to know why SLAB didn't see the same thing...


> We round up the header size in sk_stream_alloc_pskb so that
> TSO packets get zero tail room.  Unfortunately this rounding
> up is not coordinated with the select_size() function used by
> TCP to calculate the second parameter of sk_stream_alloc_pskb.
>
> As a result, we may allocate more than a page of data in the
> non-TSO case when exactly one page is desired.
>
> In fact, rounding up the head room is detrimental in the non-TSO
> case because it makes memory that would otherwise be available to
> the payload head room.  TSO doesn't need this either, all it wants
> is the guarantee that there is no tail room.
>
> So this patch fixes this by adjusting the skb_reserve call so that
> exactly the requested amount (which all callers have calculated in
> a precise way) is made available as tail room.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Cheers,
