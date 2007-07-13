From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Fri, 13 Jul 2007 11:25:30 +0200
Message-ID: <20070713092529.GA5328@kernel.dk>
References: <Line.LNX.4.64.0707121608100.10773@d.namei> <20070712.135254.112289065.davem@davemloft.net> <Line.LNX.4.64.0707122225470.13816@d.namei> <20070713053648.GX4587@kernel.dk> <20070713062624.GE4587@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:20446 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757971AbXGMJZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 05:25:44 -0400
Content-Disposition: inline
In-Reply-To: <20070713062624.GE4587@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13 2007, Jens Axboe wrote:
> On Fri, Jul 13 2007, Jens Axboe wrote:
> > On Thu, Jul 12 2007, James Morris wrote:
> > > On Thu, 12 Jul 2007, David Miller wrote:
> > > 
> > > > From: James Morris <jmorris@namei.org>
> > > > Date: Thu, 12 Jul 2007 16:12:25 -0400 (EDT)
> > > > 
> > > > > I'm seeing TCP connection stalls with current git, and a bisect found the 
> > > > > following as a possible cause:
> > > > 
> > > > To add to this James is seeing this with distcc I believe.
> > > 
> > > Correct.
> > 
> > I'll try and reproduce.
> 
> You didn't happen to get a sysrq-t backtrace of that distcc being hung,
> did you?

Does this work for you?

diff --git a/fs/splice.c b/fs/splice.c
index ed2ce99..92646aa 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -491,7 +491,7 @@ ssize_t generic_file_splice_read(struct file *in, loff_t *ppos,
 
 	ret = 0;
 	spliced = 0;
-	while (len) {
+	while (len && !spliced) {
 		ret = __generic_file_splice_read(in, ppos, pipe, len, flags);
 
 		if (ret < 0)
@@ -1051,15 +1051,10 @@ ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
 	sd->flags &= ~SPLICE_F_NONBLOCK;
 
 	while (len) {
-		size_t read_len, max_read_len;
-
-		/*
-		 * Do at most PIPE_BUFFERS pages worth of transfer:
-		 */
-		max_read_len = min(len, (size_t)(PIPE_BUFFERS*PAGE_SIZE));
+		size_t read_len;
 
-		ret = do_splice_to(in, &sd->pos, pipe, max_read_len, flags);
-		if (unlikely(ret < 0))
+		ret = do_splice_to(in, &sd->pos, pipe, len, flags);
+		if (unlikely(ret <= 0))
 			goto out_release;
 
 		read_len = ret;
@@ -1071,26 +1066,17 @@ ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
 		 * could get stuck data in the internal pipe:
 		 */
 		ret = actor(pipe, sd);
-		if (unlikely(ret < 0))
+		if (unlikely(ret <= 0))
 			goto out_release;
 
 		bytes += ret;
 		len -= ret;
 
-		/*
-		 * In nonblocking mode, if we got back a short read then
-		 * that was due to either an IO error or due to the
-		 * pagecache entry not being there. In the IO error case
-		 * the _next_ splice attempt will produce a clean IO error
-		 * return value (not a short read), so in both cases it's
-		 * correct to break out of the loop here:
-		 */
-		if ((flags & SPLICE_F_NONBLOCK) && (read_len < max_read_len))
-			break;
+		if (ret < read_len)
+			goto out_release;
 	}
 
 	pipe->nrbufs = pipe->curbuf = 0;
-
 	return bytes;
 
 out_release:
@@ -1152,10 +1138,12 @@ long do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
 		.pos		= *ppos,
 		.u.file		= out,
 	};
-	size_t ret;
+	long ret;
 
 	ret = splice_direct_to_actor(in, &sd, direct_splice_actor);
-	*ppos = sd.pos;
+	if (ret > 0)
+		*ppos += ret;
+
 	return ret;
 }
 

-- 
Jens Axboe

