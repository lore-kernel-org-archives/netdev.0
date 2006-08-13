From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/16] Add block cipher operations
Date: Sun, 13 Aug 2006 22:17:22 +1000
Message-ID: <20060813121722.GA16115@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:9 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751025AbWHMMRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2006 08:17:35 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

Dave, please don't apply this series of patches as it's going into
cryptodev-2.6 :)

This series of patches adds a new type of operations (the existing ones
are cipher, digest and compress).  The idea is to differentiate between
block chaining ciphers versus simple block ciphers from both a user point
of view and an implementation point of view.

>From the user's perspective, the block cipher type is really identical
to the existing cipher type.  However, the revamped cipher type is quite
different in that it now offers just two main operations, encrypt_one
and decrypt_one.

Both of these take just a plain kernel pointer as opposed to a
scatterlist.  This greatly simplifies the places that actually
need simple ciphers since a block is tiny (usually 8 to 16 bytes)
and describing it using a scatterlist is really overkill.

We never want to offload a simple cipher operation to hardware
because of the tiny amount of data that's in a single block.  Even
if we did copying 8 bytes/16 bytes where necessary would be trivial
in terms of cost.

>From the algorithm writer's perspective, the block cipher type is quite
different in that it presents and only presents an SG interface as
opposed to the plain pointer (one or multiple blocks) interface provided
by the current cipher type.  This is one of the main motiviations since
we need this for offload crypto.

For software algorithms, the two existing block chaining algorithms
(CBC/ECB) have been rewritten as a template that takes a simple cipher
as a parameter.  Incidentally, I took the opportunity to optimise the
software CBC implementation which gives a 10% boost in case of in-place
encryption and not-in-place decryption (by avoiding the copy of the IV).

This puts them on a level playing field with other algorithms that
implement block chaining operations, that is, padlock and s390.  Because
these all operate in the CPU address space, they need assistance to walk
the scatterlists.  These are provided in the form of blkcipher_walk_virt()
and blkcipher_walk_done() .  There is also blkcipher_walk_phys() which
will be used by offload drivers since they do not require a virtual
mapping of the input or output.

The main user-visible change is that instead of allocating aes with
a CBC mode argument you now allocate a block cipher object called
cbc(aes).  All existing users have been converted to this scheme.

I've also taken the opportunity to start the move towards a more strongly
typed crypto_tfm structure.  Previously in time we relied on run-time
checks to make sure that the crypto_tfm object supplied by the user is
suitable for the operation requested.  This is now done at compile-time
for ciphers and block ciphers.  Digest and compress will follow soon.

I'm in the process of converting digest across to a new format (in fact
it'll get a new name too -- "hash" due to the conversion process).
That's why I've temporarily reverted the hmac template code that I posted
before.  It should return within a few days.

Once the digest/compress conversion is complete, I will add the first
asynchronous algorithm and then begin converting IPsec over.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
