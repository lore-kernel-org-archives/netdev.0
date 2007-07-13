From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Fri, 13 Jul 2007 13:05:35 +0200
Message-ID: <20070713110534.GF5328@kernel.dk>
References: <Line.LNX.4.64.0707121608100.10773@d.namei> <1184320965.30334.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:11544 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757569AbXGMLFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 07:05:51 -0400
Content-Disposition: inline
In-Reply-To: <1184320965.30334.2.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13 2007, Johannes Berg wrote:
> On Thu, 2007-07-12 at 16:12 -0400, James Morris wrote:
> > I'm seeing TCP connection stalls with current git, and a bisect found the 
> > following as a possible cause:
> 
> I'm also seeing stalls with synergy.

Please try the below.

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

