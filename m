From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take 2] Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 8 Apr 2008 21:26:52 +0400
Message-ID: <20080408172652.GA4877@2ka.mipt.ru>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru> <20080408122545.GA31729@2ka.mipt.ru> <47FB6C03.3070708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jens Axboe <axboe@kernel.dk>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43162 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752387AbYDHR1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 13:27:17 -0400
Content-Disposition: inline
In-Reply-To: <47FB6C03.3070708@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2008 at 02:58:43PM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> >With this patch it is now guaranteed that data was transferred over the
> >wire after splice/sendfile returns.
> >
> 1) So a nonblocking operation (O_NDELAY) can become a blocking one now ?

No, it should not - ->sendpage() will return -EAGAIN and we will break
from the main loop before going into sleep.

> >P.S. Previous patch was not an April 1 joke as long as this one :)
> >
> >  
> Hum, I see you forgot me in CC list, dont try to escape :)

My fault, sorry :)

> >+static void skb_splice_destructor(struct skb_shared_info *shi)
> >+{
> >+	if (shi->nr_frags) {
> >+		int i;
> >+		struct pipe_inode_info *pipe;
> >+
> >+		for (i = 0; i < shi->nr_frags; i++) {
> >+			struct page *page = shi->frags[i].page;
> >+
> >+			if (page->lru.prev == (struct list_head *)page) {
> >+				pipe = (struct pipe_inode_info 
> >*)page->lru.next;
> >  
>    Unless I mistaken, you store in page->lru.next some info to find 
> your pipe pointer, assuming it is unique for this page.
> 
> What happens if two threads are doing a splice()/sendfile() using the 
> same underlying (source) file (and same pages in this file)

Page will be referenced twice (for each thread) and each thread will
have own pipe_inode_info structure, so each one will sleep on own wait
queue and will be awakened separately, where its release counter will be
dropped.

> >diff --git a/fs/splice.c b/fs/splice.c
> >index 0670c91..dcda32e 100644
> >--- a/fs/splice.c
> >+++ b/fs/splice.c
> >@@ -29,6 +29,7 @@
> > #include <linux/syscalls.h>
> > #include <linux/uio.h>
> > #include <linux/security.h>
> >+#include <net/sock.h>
> > 
> > /*
> >  * Attempt to steal a page from a pipe buffer. This should perhaps go into
> >@@ -535,6 +536,8 @@ static int pipe_to_sendpage(struct pipe_inode_info 
> >*pipe,
> > 	if (!ret) {
> > 		more = (sd->flags & SPLICE_F_MORE) || sd->len < 
> > 		sd->total_len;
> > 
> >+		buf->page->lru.next = (void *)pipe;
> >  
> is it really allowed here, are you the only user ot this page ?

Yes, it should be safe - afaics no slab pages or slab allocated data are
allowed in ->sendpage() (there is even BUG_ON() somewhere in
tcp_sendpage()/release code), so both lru pointers can be reused.

-- 
	Evgeniy Polyakov
