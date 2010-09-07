From: Tomas Mraz <tmraz@redhat.com>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 07 Sep 2010 11:18:46 +0200
Message-ID: <1283851126.11103.35.camel@vespa.frost.loc>
References: <20100907084213.GA4610@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20100907084213.GA4610@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-09-07 at 16:42 +0800, Herbert Xu wrote: 
> Hi:
> 
> This is what I am proposing for the Crypto API user-interface.
> 
> Note that this is the interface for operations.  There will be
> a separate interface (most likely netlink) for configuring crypto
> algorithms, e.g., picking a specific AES implementation as the
> system default.
> 
> First of all let's have a quick look at what the user-space side
> looks like for AEAD:
> 
> 	int op;
> 
> 	/* This fd corresponds to a tfm object. */
> 	tfmfd = socket(AF_ALG, SOCK_STREAM, 0);
> 
> 	alg.type = "aead";
> 	alg.name = "ccm(aes)";
> 	bind(tfmfd, &alg, sizeof(alg));
> 
> 	setsockopt(tfmfd, SOL_ALG, ALG_AEAD_SET_KEY, key, keylen);
> 
> The idea here is that each tfm corresponds to a listening socket.
> 
> 	/* Each listen call generates one or more fds for input/output
> 	 * that behave like pipes.
> 	 */
> 	listen(tfmfd, 0);
> 	/* fd for encryption/decryption */
> 	opfd = accept(tfmfd, NULL, 0);
> 	/* fd for associated data */
> 	adfd = accept(tfmfd, NULL, 0);

This has much much higher overhead in terms of number of needed syscalls
than the previously proposed ioctl interface. Of course in case of large
data operation the overhead converges to just one or two (for AEAD) more
syscalls (1. ioctl vs. 2. write+read). But there will be many real
use-cases where all the setup of the fds will be done again and again.
And of course it adds an overhead in terms of number of file descriptors
needed for each crypto operation. Where the old interface had just
constant one fd overhead per lifetime of the process, this interface has
3 fds per crypto context in use.

> Each session corresponds to one or more connections obtained from
> that socket.  The number depends on the number of inputs/outputs
> of that particular type of operation.  For most types, there will
> be a s ingle connection/file descriptor that is used for both input
> and output.  AEAD is one of the few that require two inputs.
> 
> 	/* These may also be set through sendmsg(2) cmsgs. */
> 	op = ALG_AEAD_OP_ENCRYPT;
> 	setsockopt(opfd, SOL_ALG, ALG_AEAD_OP, op, sizeof(op));
> 	setsockopt(opfd, SOL_ALG, ALG_AEAD_SET_IV, iv, ivlen);
> 
> 	/* Like pipes, larges writes will block!
> 	 * For AEAD, ensure the socket buffer is large enough.
> 	 * For ciphers, whenever the write blocks start reading.
> 	 * For hashes, writes should never block.
> 	 */
> 	write(opfd, plain, datalen);
> 	write(adfd, ad, adlen);
> 
> 	/* The first read triggers the operation. */
> 	read(opfd, crypt, datalen);
> 
> 	op = ALG_AEAD_OP_DECRYPT;
> 	setsockopt(opfd, SOL_ALG, ALG_AEAD_OP, op, sizeof(op));
> 
> 	write(opfd, crypt, datalen);
> 	write(adfd, ad, adlen);
> 
> 	/* Returns -1 with errno EBADMSG if auth fails */
> 	read(defd, plain, datalen);
> 
> 	/* Zero-copy */
> 	splice(cryptfd, NULL, opfd, NULL, datalen, SPLICE_F_MOVE|SPLIFE_F_MORE);
> 	/* We allow writes to be split into multiple system calls. */
> 	splice(cryptfd2, NULL, opfd, NULL, datalen, SPLICE_F_MOVE);
> 	splice(adatafd, NULL, adfd, NULL, adlen, SPLICE_F_MOVE);
> 
> 	/* For now reading is copy-only, if and when vmsplice
> 	 * starts supporting zero-copy to user then we can do it
> 	 * as well.
This is also serious performance penalty for now.

> 	read(opfd, plain, datalen);
> 
> Ciphers/compression are pretty much the same sans adfd.
> 
> For hashes:
> 
> 	/* This fd corresponds to a tfm object. */
> 	tfmfd = socket(AF_ALG, SOCK_STREAM, 0);
> 
> 	alg.type = "hash";
> 	alg.name = "xcbc(aes)";
> 	bind(tfmfd, &alg, sizeof(alg));
> 
> 	setsockopt(tfmfd, SOL_ALG, ALG_HASH_SET_KEY, key, keylen);
> 
> 	/* Each listen call generates one or more fds for input/output
> 	 * that behave like pipes.
> 	 */
> 	listen(tfmfd, 0);
> 	/* fd for hashing */
> 	opfd = accept(tfmfd, NULL, 0);
> 
> 	/* MSG_MORE prevents finalisation */
> 	send(opfd, plain, datalen, MSG_MORE);
> 
> 	/* Reads partial hash state */
> 	read(opfd, state, statelen);
> 
> 	/* Restore from a partial hash state */
> 	send(opfd, state, statelen, MSG_OOB);
> 
> 	/* Finalise */
> 	send(opfd, plain, 0, 0);
> 	read(opfd, hash, hashlen);
Note, that one of frequent hash operations is duplicating the internal
hash state. How this would be done with this API?

-- 
Tomas Mraz
No matter how far down the wrong road you've gone, turn back.
                                              Turkish proverb
