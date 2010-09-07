From: Miloslav Trmac <mitr@redhat.com>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 07:27:47 -0400 (EDT)
Message-ID: <815047906.1056041283858867555.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
References: <1590523029.1055831283858598965.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:55140 "EHLO
	mx02.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756493Ab0IGL1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 07:27:51 -0400
In-Reply-To: <1590523029.1055831283858598965.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
----- "Herbert Xu" <herbert@gondor.hengli.com.au> wrote:
> First of all let's have a quick look at what the user-space side
> looks like for AEAD:
> 
> 	/* Each listen call generates one or more fds for input/output
> 	 * that behave like pipes.
> 	 */
> 	listen(tfmfd, 0);
> 	/* fd for encryption/decryption */
> 	opfd = accept(tfmfd, NULL, 0);
> 	/* fd for associated data */
> 	adfd = accept(tfmfd, NULL, 0);
If nothing else, two consecutive accept() calls with different semantics go rather strongly against the spirit of the socket API IMHO.

> 	/* These may also be set through sendmsg(2) cmsgs. */
> 	op = ALG_AEAD_OP_ENCRYPT;
> 	setsockopt(opfd, SOL_ALG, ALG_AEAD_OP, op, sizeof(op));
> 	setsockopt(opfd, SOL_ALG, ALG_AEAD_SET_IV, iv, ivlen);
So that is 8 syscalls to initialize a single AEAD operation.
 
> 	/* Like pipes, larges writes will block!
> 	 * For AEAD, ensure the socket buffer is large enough.
> 	 * For ciphers, whenever the write blocks start reading.
> 	 * For hashes, writes should never block.
> 	 */
How does one know the buffer is large enough?

"Whenever the write blocks start reading" turns a trivial loop submitting one buffer-size at a time into something that would be much easier to get wrong.


> 	/* Zero-copy */
> 	splice(cryptfd, NULL, opfd, NULL, datalen,
> SPLICE_F_MOVE|SPLIFE_F_MORE);
So that is "zero copy on input if your data come from a file descriptor"?  I'm not sure many applications will be able to take advantage of that, and there's still the output copy.

Also, is SPLICE_F_MOVE actually implemented?

Why use splice() at all?  Simple write() gives the driver the __user pointers that can be used to access the underlying pages directly.  Yanking user-space pages out from the process address space to make them "owned" by the crypto driver, causing more page faults when the process wants to reuse the buffer, does not seem like a performance improvement.

> Please comment.
I can't really see any advantage in trying to use existing syscalls for crypto when the syscalls were clearly not intended for the purpose.  setsockopt() is fine for sockets because options are set up once per connection, and the connection very rarely lasts less than several milliseconds; crypto operation options have to be configured much more often.

7 syscalls to compute a single hash is very difficult to accept.
     Mirek
