From: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Subject: [ 3.5.y.z extended stable ] Patch "epoll: prevent missed events on EPOLL_CTL_MOD" has been added to staging queue
Date: Mon, 14 Jan 2013 18:57:34 -0200
Message-ID: <1358197054-17276-1-git-send-email-herton.krzesinski@canonical.com>
Cc: Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Eric Wong <normalperson@yhbt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:53851 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756987Ab3ANU5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:57:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    epoll: prevent missed events on EPOLL_CTL_MOD

to the linux-3.5.y-queue branch of the 3.5.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.5.y-queue

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.5.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Herton

------

>From 318ea9d60ee27838448a04a898ef67249f2e79bb Mon Sep 17 00:00:00 2001
From: Eric Wong <normalperson@yhbt.net>
Date: Tue, 1 Jan 2013 21:20:27 +0000
Subject: [PATCH] epoll: prevent missed events on EPOLL_CTL_MOD

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
Signed-off-by: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
---
 fs/eventpoll.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 1c8b556..dd1a55d 100644
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
1.7.9.5
