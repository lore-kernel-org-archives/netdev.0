From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Oops in 2.6.22.1: skb_copy_and_csum_datagram_iovec()
Date: Thu, 6 Sep 2007 04:55:54 +0800
Message-ID: <20070905205554.GA17326@gondor.apana.org.au>
References: <46CB453B.5040005@redhat.com> <E1INkpM-00007x-00@gondolin.me.apana.org.au> <18142.39804.387020.852675@notabene.brown> <18142.42509.447265.575323@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, netdev@vger.kernel.org
To: Neil Brown <neilb@suse.de>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3984 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1749667AbXIEU4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 16:56:17 -0400
Content-Disposition: inline
In-Reply-To: <18142.42509.447265.575323@notabene.brown>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil:

On Wed, Sep 05, 2007 at 01:50:21PM +0100, Neil Brown wrote:
>
> > iov == NULL used to work.

Well it used to work mostly.  In fact, it still does work
mostly too.

> > I think it stopped working at 
> >    commit 759e5d006462d53fb708daa8284b4ad909415da1
> > 
> > Previously, as len==0, MSG_TRUNC would get set, so copy_only would get
> > set, so skb_copy_datagram_iovec would get called, and that handles a
> > len of 0.
> > 
> > Now, skb_copy_and_csum_datagram_iovec gets called unless
> > skb_csum_unnecessary(skb), which now kills us.

Not quite.  If MSG_TRUNC is set, then we'll just call
udp_lib_checksum_complete.  If it fails we'll bail, if
it succeeds then skb_csum_unnecessary(skb) is guaranteed
to be true.

So in this respect the new code behaves identically with
the old code.

> However earlier there is:
> 	ulen = skb->len - sizeof(struct udphdr);
> 	copied = len;
> 	if (copied > ulen)
> 		copied = ulen;
> 
> so if the 'len' (of the iovec) is too small, we end up with "copied == ulen", 

Nope, if len (== copied) is too small, we simply set MSG_TRUNC
as we did before.

Where this all falls apart is when the UDP payload is
empty (ulen == 0).  In that case MSG_TRUNC is not set
and we end up calling skb_copy_and_csum_datagram_iovec
which oopses.  I've looked up the original crash and
indeed %edi there which corresponds to the UDP payload
length is zero.

However, I can see where you're coming from in that we
shouldn't dereference msg_iov at all if msg_iovlen is 0.
This never happens with sys_recvmsg so we never bothered
checking it.  The following patch should fix the problem.

[NET]: Do not dereference iov if length is zero

When msg_iovlen is zero we shouldn't try to dereference
msg_iov.  Right now the only thing that tries to do so
is skb_copy_and_csum_datagram_iovec.  Since the total
length should also be zero if msg_iovlen is zero, it's
sufficient to check the total length there and simply
return if it's zero.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/datagram.c b/net/core/datagram.c
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -450,6 +450,9 @@ int skb_copy_and_csum_datagram_iovec(str
 	__wsum csum;
 	int chunk = skb->len - hlen;
 
+	if (!chunk)
+		return 0;
+
 	/* Skip filled elements.
 	 * Pretty silly, look at memcpy_toiovec, though 8)
 	 */
