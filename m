From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [v2.6.34-stable 157/213] epoll: prevent missed events on EPOLL_CTL_MOD
Date: Wed, 5 Feb 2014 15:01:52 -0500
Message-ID: <1391630568-49251-158-git-send-email-paul.gortmaker@windriver.com>
References: <1391630568-49251-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Wong <normalperson@yhbt.net>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	<netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: <stable@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391630568-49251-1-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Wong <normalperson@yhbt.net>

                   -------------------
    This is a commit scheduled for the next v2.6.34 longterm release.
    http://git.kernel.org/?p=linux/kernel/git/paulg/longterm-queue-2.6.34.git
    If you see a problem with using this for longterm, please comment.
                   -------------------

commit 128dd1759d96ad36c379240f8b9463e8acfd37a1 upstream.

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
Cc: Andreas Voellmy <andreas.voellmy@yale.edu>
Tested-by: "Junchang(Jason) Wang" <junchang.wang@yale.edu>
Cc: netdev@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 fs/eventpoll.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 34ca5ca9c3e8..f8a6c0876a7a 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1033,10 +1033,30 @@ static int ep_modify(struct eventpoll *ep, struct epitem *epi, struct epoll_even
 	 * otherwise we might miss an event that happens between the
 	 * f_op->poll() call and the new event set registering.
 	 */
-	epi->event.events = event->events;
+	epi->event.events = event->events; /* need barrier below */
 	epi->event.data = event->data; /* protected by mtx */
 
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
1.8.5.2
