From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [GIT] Networking
Date: Wed, 11 Feb 2015 01:45:02 +0000
Message-ID: <20150211014502.GB29656@ZenIV.linux.org.uk>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
 <CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
 <20150209.205209.1524645061817000265.davem@davemloft.net>
 <CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
 <CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
 <CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
 <CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 01:50:16PM -0800, Linus Torvalds wrote:
> On Tue, Feb 10, 2015 at 1:26 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Just to confirm that yes, it's that particular commit 1d10eb2f156f.
> >
> > I reverted it and things work again. So it's not the miscalculation of
> > "used" , but it's certainly *something* in that commit.
> 
> How about this?
> 
> -       npages = (off + len + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +       npages = PAGE_ALIGN(off + n);
> 
> The two are not even *remotely* the same thing.

The latter isn't a replacement for the former, but yes, it is bogus - bytes
instead of pages.  

Could you check if

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
 

on top of what went into Dave's tree is enough to fix what you are seeing?
