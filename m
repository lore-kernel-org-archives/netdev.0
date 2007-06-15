From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Fri, 15 Jun 2007 11:34:30 +0200
Message-ID: <20070615093429.GQ6149@kernel.dk>
References: <20070611115926.GB18832@kernel.dk> <20070612181717.GA1600@2ka.mipt.ru> <20070612181731.GQ18832@kernel.dk> <20070613080103.GA24701@2ka.mipt.ru> <20070614115720.GA14840@2ka.mipt.ru> <20070614115902.GG6149@kernel.dk> <20070615080618.GA22234@2ka.mipt.ru> <20070615084318.GP6149@kernel.dk> <20070615091445.GA27451@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:25338 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbXFOJeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 05:34:19 -0400
Content-Disposition: inline
In-Reply-To: <20070615091445.GA27451@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 15 2007, Evgeniy Polyakov wrote:
> On Fri, Jun 15, 2007 at 10:43:18AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > > So, things turned down to be not in the __splice_from_pipe(), but
> > > splice_to_pipe(). Attached patch fixes a leak for me.
> > > It was tested with different data files and all were received correctly.
> > > 
> > > Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> > > 
> > > diff --git a/fs/splice.c b/fs/splice.c
> > > index bc481f1..365bfd9 100644
> > > --- a/fs/splice.c
> > > +++ b/fs/splice.c
> > > @@ -211,8 +211,6 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
> > >  				break;
> > >  			if (pipe->nrbufs < PIPE_BUFFERS)
> > >  				continue;
> > > -
> > > -			break;
> > >  		}
> > >  
> > >  		if (spd->flags & SPLICE_F_NONBLOCK) {
> > > 
> > 
> > Hmm, curious. If we hit that location, then two conditions are true:
> > 
> > - Pipe is full
> > - We transferred some data
> 
> Yep.
> 
> > if you remove the break, then you'll end up blocking in pipe_wait()
> > (unless you have SPLICE_F_NONBLOCK also set). And we don't want to block
> > waiting for more room, if we already transferred some data. In that case
> > we just want to return a short splice. Looking at pipe_write(), it'll
> > block as well though. Just doesn't seem optimal to me, but...
> > 
> > So the question is why would doing the break there cause a leak? I just
> > don't yet see how it can happen, I'd love to fix that condition instead.
> > For the case you describe, we should have page_nr == 1 and spd->nr_pages
> > == 2. Is the:
> > 
> >         while (page_nr < spd->nr_pages)
> >                 spd->spd_release(spd, page_nr++);
> > 
> > not dropping the right reference?
> 
> Both spd->nr_pages and page_nr are equal to 1. When spd->nr_pages
> was 2 there was only 1 free slot in pipe_buffer.

Ah duh, indeed, it is a dumb bug indeed. This should work.

diff --git a/fs/splice.c b/fs/splice.c
index 89871c6..5327cbf 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -172,6 +172,7 @@ static const struct pipe_buf_operations user_page_pipe_buf_ops = {
 ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 		       struct splice_pipe_desc *spd)
 {
+	unsigned int spd_pages = spd->nr_pages;
 	int ret, do_wakeup, page_nr;
 
 	ret = 0;
@@ -252,7 +253,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 		}
 	}
 
-	while (page_nr < spd->nr_pages)
+	while (page_nr < spd_pages)
 		spd->spd_release(spd, page_nr++);
 
 	return ret;

-- 
Jens Axboe

