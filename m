From: Eric Wong <normalperson@yhbt.net>
Subject: [PATCH] epoll: prevent missed events on EPOLL_CTL_MOD
Date: Tue, 1 Jan 2013 23:56:05 +0000
Message-ID: <20130101235605.GA17168@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
 <1357065750.21409.12527.camel@edumazet-glaptop>
 <20130101210033.GA13255@dcvr.yhbt.net>
 <20130101211728.GA13380@dcvr.yhbt.net>
 <CA+55aFwP3Tvmfh23KDDXhB3k=RS8pNhqasw5vuBUHw4TxrakOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>,
	Network Development <netdev@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwP3Tvmfh23KDDXhB3k=RS8pNhqasw5vuBUHw4TxrakOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> wrote:
> Please document the barrier that this mb() pairs with, and then give
> an explanation for the fix in the commit message, and I'll happily
> take it. Even if it's just duplicating the comments above the
> wq_has_sleeper() function, except modified for the ep_modify() case.

Hopefully my explanation is correct and makes sense below,
I think both effects of the barrier are needed

> Of course, it would be good to get verification from Jason and Andreas
> that the alternate patch also works for them.

Jason just confirmed it.

------------------------------- 8< ----------------------------
>From 02f43757d04bb6f2786e79eecf1cfa82e6574379 Mon Sep 17 00:00:00 2001
From: Eric Wong <normalperson@yhbt.net>
Date: Tue, 1 Jan 2013 21:20:27 +0000
Subject: [PATCH] epoll: prevent missed events on EPOLL_CTL_MOD

EPOLL_CTL_MOD sets the interest mask before calling f_op->poll() to
ensure events are not missed.  Since the modifications to the interest
mask are not protected by the same lock as ep_poll_callback, we need to
ensure the change is visible to other CPUs calling ep_poll_callback.

We also need to ensure f_op->poll() has an up-to-date view of past
events which occured before we modified the interest mask.  So this
barrier also pairs with the barrier in wq_has_sleeper().

This should guarantee either ep_poll_callback or f_op->poll() (or both)
will notice the readiness of a recently-ready/modified item.

This issue was encountered by Andreas Voellmy and Junchang(Jason) Wang in:
http://thread.gmane.org/gmane.linux.kernel/1408782/

Signed-off-by: Eric Wong <normalperson@yhbt.net>
Cc: Hans Verkuil <hans.verkuil@cisco.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Davide Libenzi <davidel@xmailserver.org>
Cc: Hans de Goede <hdegoede@redhat.com>
Cc: Mauro Carvalho Chehab <mchehab@infradead.org>
Cc: David Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andreas Voellmy <andreas.voellmy@yale.edu>
Tested-by: "Junchang(Jason) Wang" <junchang.wang@yale.edu>
Cc: netdev@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
---
 fs/eventpoll.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index cd96649..39573ee 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1285,7 +1285,7 @@ static int ep_modify(struct eventpoll *ep, struct epitem *epi, struct epoll_even
 	 * otherwise we might miss an event that happens between the
 	 * f_op->poll() call and the new event set registering.
 	 */
-	epi->event.events = event->events;
+	epi->event.events = event->events; /* need barrier below */
 	pt._key = event->events;
 	epi->event.data = event->data; /* protected by mtx */
 	if (epi->event.events & EPOLLWAKEUP) {
@@ -1296,6 +1296,26 @@ static int ep_modify(struct eventpoll *ep, struct epitem *epi, struct epoll_even
 	}
 
 	/*
+	 * The following barrier has two effects:
+	 *
+	 * 1) Flush epi changes above to other CPUs.  This ensures
+	 *    we do not miss events from ep_poll_callback if an
+	 *    event occurs immediately after we call f_op->poll().
+	 *    We need this because we did not take ep->lock while
+	 *    changing epi above (but ep_poll_callback does take
+	 *    ep->lock).
+	 *
+	 * 2) We also need to ensure we do not miss _past_ events
+	 *    when calling f_op->poll().  This barrier also
+	 *    pairs with the barrier in wq_has_sleeper (see
+	 *    comments for wq_has_sleeper).
+	 *
+	 * This barrier will now guarantee ep_poll_callback or f_op->poll
+	 * (or both) will notice the readiness of an item.
+	 */
+	smp_mb();
+
+	/*
 	 * Get current event bits. We can safely use the file* here because
 	 * its usage count has been increased by the caller of this function.
 	 */
-- 
Eric Wong
