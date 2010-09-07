From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 22:07:40 +0800
Message-ID: <20100907140740.GA6903@gondor.apana.org.au>
References: <1590523029.1055831283858598965.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com> <815047906.1056041283858867555.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Miloslav Trmac <mitr@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <815047906.1056041283858867555.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2010 at 07:27:47AM -0400, Miloslav Trmac wrote:
> Hello,
> ----- "Herbert Xu" <herbert@gondor.hengli.com.au> wrote:
> > First of all let's have a quick look at what the user-space side
> > looks like for AEAD:
> > 
> > 	/* Each listen call generates one or more fds for input/output
> > 	 * that behave like pipes.
> > 	 */
> > 	listen(tfmfd, 0);
> > 	/* fd for encryption/decryption */
> > 	opfd = accept(tfmfd, NULL, 0);
> > 	/* fd for associated data */
> > 	adfd = accept(tfmfd, NULL, 0);
> If nothing else, two consecutive accept() calls with different semantics go rather strongly against the spirit of the socket API IMHO.

If you have a better suggestion of obtaining multiple fds for
multiple input streams please let us know.

> > 	/* These may also be set through sendmsg(2) cmsgs. */
> > 	op = ALG_AEAD_OP_ENCRYPT;
> > 	setsockopt(opfd, SOL_ALG, ALG_AEAD_OP, op, sizeof(op));
> > 	setsockopt(opfd, SOL_ALG, ALG_AEAD_SET_IV, iv, ivlen);
> So that is 8 syscalls to initialize a single AEAD operation.

If this interface is fast enough for TCP, it ought to be fast
enough for crypto.

> > 	/* Like pipes, larges writes will block!
> > 	 * For AEAD, ensure the socket buffer is large enough.
> > 	 * For ciphers, whenever the write blocks start reading.
> > 	 * For hashes, writes should never block.
> > 	 */
> How does one know the buffer is large enough?

For anything other than AEAD you don't have to know.  As I said
it behaves just like a pipe.  If you know how to use a pipe you'll
know how to deal with this.

For AEAD we need this as otherwise you can chew up an unlimited
amount of kernel memory.

> "Whenever the write blocks start reading" turns a trivial loop submitting one buffer-size at a time into something that would be much easier to get wrong.

We don't have a choice.  We cannot allow user-space to use up
an unlimted amount of kernel memory.  At some point you've got
to say stop.

Now the usual socket limits should be good enough for most users.
That is, if you're encrypting anything less than 128K you shouldn't
care.

If you need more just do a setsockopt (subject to limits set by
the admin of course).

> > 	/* Zero-copy */
> > 	splice(cryptfd, NULL, opfd, NULL, datalen,
> > SPLICE_F_MOVE|SPLIFE_F_MORE);
> So that is "zero copy on input if your data come from a file descriptor"?  I'm not sure many applications will be able to take advantage of that, and there's still the output copy.
> 
> Also, is SPLICE_F_MOVE actually implemented?

Actually it doesn't matter, it'll do zero-copy by default.

> Why use splice() at all?  Simple write() gives the driver the __user pointers that can be used to access the underlying pages directly.  Yanking user-space pages out from the process address space to make them "owned" by the crypto driver, causing more page faults when the process wants to reuse the buffer, does not seem like a performance improvement.

For someone working on security I thought you would've considered
the pitfalls of inventing yet another interface for moving data
between the kernel/user-space.

Also you're wrong about the page faults, splicing does not cause
additional page faults at all.  This is the whole point of the
vmsplice(2) interface, we don't play with page tables.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
