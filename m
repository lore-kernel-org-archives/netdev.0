From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 09:46:23 +1000
Message-ID: <20050603234623.GA20088@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi:

I was looking at how we can move the IPsec input/output processing out
of the critical section protected by the spin locks on the xfrm_state.
This is useful because it would allow concurrent processing of IPsec
packets for the same SA.  It is also necessary if we're ever going to
add support for asynchronous crypto to IPsec.

The first requirement for this is that we need to stop using data that
is shared across a single SA in the IPsec input/output routines.  The
biggest hurdle there as it stands is sgbuf in esp_data.  This was
introduced to reduce stack usage in esp_input/esp_output as sgbuf
would consume up to 64 bytes of space.

In order to move it back onto the stack (so we can run these things
in parallel), I'm thinking of reducing the size of the scatterlist
structure itself.

The Crypto API doesn't need all the data contained in a scatterlist
structure.  For instance, it has no need for anything to do with DMA.
When we implement hardware crypto (which might do DMA), they're going
to have their own lists of descriptors so they can't use the scatterlist
as is anyway.

The skb_frag_t structure on the other hand is much more suited for
our purpose.  It is only half the size of scatterlist on i386.

So what do you think about introducing a new crypto_frag structure
which looks like this:

struct crypto_frag {
	struct page *page;
	u16 offset;
	u16 length;
};

We could then move sgbuf back into esp_input/esp_output at the cost
of 32 bytes of stack.  Is this stack cost acceptable?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
