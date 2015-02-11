From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [GIT] Networking
Date: Wed, 11 Feb 2015 04:01:13 +0000
Message-ID: <20150211040113.GC29656@ZenIV.linux.org.uk>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
 <CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
 <20150209.205209.1524645061817000265.davem@davemloft.net>
 <CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
 <CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
 <CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
 <CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
 <20150211014502.GB29656@ZenIV.linux.org.uk>
 <CA+55aFwdXNYMWGGNsAzyRiZ60HE_G=CJesLShPHGxtADJd2TPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwdXNYMWGGNsAzyRiZ60HE_G=CJesLShPHGxtADJd2TPQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 06:01:32PM -0800, Linus Torvalds wrote:
> On Tue, Feb 10, 2015 at 5:45 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > Could you check if
> >
> > diff --git a/crypto/af_alg.c b/crypto/af_alg.c
> > index eb78fe8..5b11d64 100644
> > --- a/crypto/af_alg.c
> > +++ b/crypto/af_alg.c
> > @@ -348,7 +348,7 @@ int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len)
> >         if (n < 0)
> >                 return n;
> >
> > -       npages = PAGE_ALIGN(off + n);
> > +       npages = DIV_ROUND_UP(off + n, PAGE_SIZE);
> >         if (WARN_ON(npages == 0))
> >                 return -EINVAL;
> >
> > on top of what went into Dave's tree is enough to fix what you are seeing?
> 
> So quite frankly, considering that we already know that 'used' was
> also calculated wrong (it stays at zero) and that the one-liner above
> is not sufficient on its own, by now I'd like somebody with an actual
> test-case to check this thing out., and send me a proper tested patch.
> That somebody preferably being you.
> 
> Are there no tests for that crypto interface?

I hoped LTP would have them, but it doesn't ;-/  The best I'd been able to
find had been in libkcapi, modulo bunch of
	let result=($result + 1)
(in a bash script; replacing with result=$(($result+1)) has dealt with that)
and algif-aead module it supplies and wants to test.

It reproduces the oopsen just fine and patch below seems to fix things.

> Also, I'm unhappy that you made these unrelated and broken changes at
> all. Both wrt 'used' and this 'npages' thing, the original code wasn't
> wrong, and the pointless changes to correct code not only broke
> things, but had nothing to do with the iovec conversion that was the
> stated reason for the commit.

I've fucked up on those, no arguments, but they *were* very much related
to the conversion in question - original code in skcipher_recvmsg()
was a loop over iovec segments, with inner loop over each segment.
With iov_iter conversion we need a flat loop, and I'd screwed up while
massaging the code into that form.  And af_alg_make_sg() change had been
a consequence of the same - we used to feed it the next subset of the
range covered by ->msg_iter.iov[...] in the inner loop there.

npages thing is _not_ a replacement of (similar) line you've picked out
of that diff - it replaced
	npages = err;
after get_user_pages_fast().  Calling conventions of iov_iter_get_pages()
differ - it returns offset of the beginning within the first page (via
*start) and amount of data it picked from iterator (as return value).

> Grr. I really hate it when I find bugs during the merge window. My
> test environment is *not* odd. If _I_ end up being the one finding the
> bugs, that means that things must have gotten basically no testing at
> all.

Out of curiosity - what has triggered that oops on your userland?  I certainly
_did_ the "allmodconfig and see if it boots" on those; in my usual test
image (jessie-amd64 in KVM) nothing has stepped into that one.  Again,
I'm not trying to excuse the fuckup - just wondering what to add to tests...

The patch below appears to fix the problems on the reproducer I'd
been able to find.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index eb78fe8..5b11d64 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -348,7 +348,7 @@ int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len)
 	if (n < 0)
 		return n;
 
-	npages = PAGE_ALIGN(off + n);
+	npages = DIV_ROUND_UP(off + n, PAGE_SIZE);
 	if (WARN_ON(npages == 0))
 		return -EINVAL;
 
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 37110fd..0eb31a6 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -427,11 +427,11 @@ static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
 	struct skcipher_sg_list *sgl;
 	struct scatterlist *sg;
 	int err = -EAGAIN;
-	int used;
 	long copied = 0;
 
 	lock_sock(sk);
 	while (iov_iter_count(&msg->msg_iter)) {
+		int used;
 		sgl = list_first_entry(&ctx->tsgl,
 				       struct skcipher_sg_list, list);
 		sg = sgl->sg;
@@ -439,14 +439,13 @@ static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
 		while (!sg->length)
 			sg++;
 
-		used = ctx->used;
-		if (!used) {
+		if (!ctx->used) {
 			err = skcipher_wait_for_data(sk, flags);
 			if (err)
 				goto unlock;
 		}
 
-		used = min_t(unsigned long, used, iov_iter_count(&msg->msg_iter));
+		used = min_t(unsigned long, ctx->used, iov_iter_count(&msg->msg_iter));
 
 		used = af_alg_make_sg(&ctx->rsgl, &msg->msg_iter, used);
 		err = used;
