From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Fri, 15 Jun 2007 12:06:18 +0400
Message-ID: <20070615080618.GA22234@2ka.mipt.ru>
References: <20070611115926.GB18832@kernel.dk> <20070612181717.GA1600@2ka.mipt.ru> <20070612181731.GQ18832@kernel.dk> <20070613080103.GA24701@2ka.mipt.ru> <20070614115720.GA14840@2ka.mipt.ru> <20070614115902.GG6149@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48148 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513AbXFOIGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 04:06:38 -0400
Content-Disposition: inline
In-Reply-To: <20070614115902.GG6149@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 14, 2007 at 01:59:02PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> On Thu, Jun 14 2007, Evgeniy Polyakov wrote:
> > On Wed, Jun 13, 2007 at 12:01:04PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > I will rebase my tree, likely something was not merged correctly.
> > 
> > Ok, I've just rebased a tree from recent git and pulled from brick -
> > things seems to be settled. I've ran several tests with different
> > filesizes and all files were received correctly without kernel crashes.
> > There is skb leak indeed, and it looks like it is in the
> > __splice_from_pipe() for the last page.
> 
> Uh, the leak, right - I had forgotten about that, was working on getting
> vmsplice into shape the last two days. Interesting that you mention the
> last page, I'll dig in now! Any more info on this (how did you notice
> the leak originates from there)?

I first observed leak via slabinfo data (not a leak, but number of skbs
did not dropped after quite huge files were transferred), then added
number of allocated and freed objects in skbuff.c, they did not match
for big files, so I started to check splice source and found that
sometimes ->release callback is not called, but code breaks out of the
loop. I've put some printks in __splice_from_pipe() and found following
case, when skb is leaked:
when the same cloned skb was shared multiple times (no more than 2 though),
only one copy was freed.

Further analysis description requires some splice background (obvious
for you, but that clears it for me):
pipe_buffer only contains 16 pages.
There is a code, which copies pages (pointers) from spd to pipe_buffer
(splice_to_pipe()).
skb allocations happens in chunks of different size (i.e. with different
number of skbs/pages per call), so it is possible that number of
allocated skbs will be less than pipe_buffer size (16), and then the
rest of the pages will be put into different (or the same) pipe_buffer later.
Sometimes two skbs from above example happens to be on the boundary of
the pipe buffer, so only one of them is being copied into pipe_buffer,
which is then transferred over the pipe.
So, we have a case, when spd has (it had more, but this two are special) 
2 pages (actually the same page, but two references to it), but pipe_buffer 
has a place only for one. In that case second page from spd will be missed.

So, things turned down to be not in the __splice_from_pipe(), but
splice_to_pipe(). Attached patch fixes a leak for me.
It was tested with different data files and all were received correctly.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/fs/splice.c b/fs/splice.c
index bc481f1..365bfd9 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -211,8 +211,6 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 				break;
 			if (pipe->nrbufs < PIPE_BUFFERS)
 				continue;
-
-			break;
 		}
 
 		if (spd->flags & SPLICE_F_NONBLOCK) {

-- 
	Evgeniy Polyakov
