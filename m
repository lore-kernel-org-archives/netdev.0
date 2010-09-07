From: Miloslav Trmac <mitr@redhat.com>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 10:34:25 -0400 (EDT)
Message-ID: <421339997.1082251283870065826.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
References: <1847066281.1081601283869883727.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1847066281.1081601283869883727.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- "Herbert Xu" <herbert@gondor.hengli.com.au> wrote:
> On Tue, Sep 07, 2010 at 07:27:47AM -0400, Miloslav Trmac wrote:
> > Hello,
> > ----- "Herbert Xu" <herbert@gondor.hengli.com.au> wrote:
> > > First of all let's have a quick look at what the user-space side
> > > looks like for AEAD:
> > > 
> > > 	/* Each listen call generates one or more fds for input/output
> > > 	 * that behave like pipes.
> > > 	 */
> > > 	listen(tfmfd, 0);
> > > 	/* fd for encryption/decryption */
> > > 	opfd = accept(tfmfd, NULL, 0);
> > > 	/* fd for associated data */
> > > 	adfd = accept(tfmfd, NULL, 0);
> > If nothing else, two consecutive accept() calls with different
> semantics go rather strongly against the spirit of the socket API
> IMHO.
> 
> If you have a better suggestion of obtaining multiple fds for
> multiple input streams please let us know.
- Don't use a FD for associated data that is limited to 16? bytes

- Don't use file descriptors for input data at all, if it makes the interface so complex.

> > > 	/* These may also be set through sendmsg(2) cmsgs. */
> > > 	op = ALG_AEAD_OP_ENCRYPT;
> > > 	setsockopt(opfd, SOL_ALG, ALG_AEAD_OP, op, sizeof(op));
> > > 	setsockopt(opfd, SOL_ALG, ALG_AEAD_SET_IV, iv, ivlen);
> > So that is 8 syscalls to initialize a single AEAD operation.
> 
> If this interface is fast enough for TCP, it ought to be fast
> enough for crypto.
Crypto has much smaller granularity than TCP.  A single TLS handshake involves something on the order of 20 separate crypto operations in addition to setting up the four transforms used throughout the life of the session.

A single SHA-256 password verification is more than 5000 hash operations by default.

> > Why use splice() at all?  Simple write() gives the driver the __user
> pointers that can be used to access the underlying pages directly. 
> Yanking user-space pages out from the process address space to make
> them "owned" by the crypto driver, causing more page faults when the
> process wants to reuse the buffer, does not seem like a performance
> improvement.
> 
> For someone working on security I thought you would've considered
> the pitfalls of inventing yet another interface for moving data
> between the kernel/user-space.
The data will in the usual case be in user-space memory, not in file descriptors.  Existing low-level crypto libraries have no access to the file descriptors that are used to work with the data.  And even in the case of TLS where the data does come through a file descriptor, a MAC is then computed on it - so at most half of the (steady-state) crypto is coming through a file descriptor.

Finally, when the application uses file descriptors, it uses them to transfer the _encrypted_ form of the data; it keeps plaintext in memory in order to use it.  So avoiding the trip to userspace protects primarily the kind of data that does not need protecting.
    Mirek
