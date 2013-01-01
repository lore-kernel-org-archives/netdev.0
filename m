From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] poll: prevent missed events if _qproc is NULL
Date: Tue, 1 Jan 2013 21:00:33 +0000
Message-ID: <20130101210033.GA13255@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
 <1357065750.21409.12527.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dcvr.yhbt.net ([64.71.152.64]:35684 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448Ab3AAVAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2013 16:00:34 -0500
Content-Disposition: inline
In-Reply-To: <1357065750.21409.12527.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2012-12-31 at 13:21 +0000, Eric Wong wrote:
> > This patch seems to fix my issue with ppoll() being stuck on my
> > SMP machine: http://article.gmane.org/gmane.linux.file-systems/70414
> > 
> > The change to sock_poll_wait() in
> > commit 626cf236608505d376e4799adb4f7eb00a8594af
> >   (poll: add poll_requested_events() and poll_does_not_wait() functions)
> > seems to have allowed additional cases where the SMP memory barrier
> > is not issued before checking for readiness.
> > 
> > In my case, this affects the select()-family of functions
> > which register descriptors once and set _qproc to NULL before
> > checking events again (after poll_schedule_timeout() returns).
> > The set_mb() barrier in poll_schedule_timeout() appears to be
> > insufficient on my SMP x86-64 machine (as it's only an xchg()).
> > 
> > This may also be related to the epoll issue described by
> > Andreas Voellmy in http://thread.gmane.org/gmane.linux.kernel/1408782/
> 
> Hmm, the change seems not very logical to me.

My original description was not complete and I'm still bisecting
my problem (ppoll + send stuck).  However, my patch does solve the
issue Andreas encountered and I now understand why.

> If it helps, I would like to understand the real issue.
>
> commit 626cf236608505d376e4799adb4f7eb00a8594af should not have this
> side effect, at least for poll()/select() functions. The epoll() changes
> I am not yet very confident.

I have a better explanation of the epoll problem below.

An alternate version (limited to epoll) would be:

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index cd96649..ca5f3d0 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1299,6 +1299,7 @@ static int ep_modify(struct eventpoll *ep, struct epitem *epi, struct epoll_even
 	 * Get current event bits. We can safely use the file* here because
 	 * its usage count has been increased by the caller of this function.
 	 */
+	smp_mb();
 	revents = epi->ffd.file->f_op->poll(epi->ffd.file, &pt);
 
 	/*

> I suspect a race already existed before this commit, it would be nice to
> track it properly.

I don't believe this race existed before that change.

Updated commit message below:

>From 87bca82bc39a941d9b8d5b8bc08b39a071a9884f Mon Sep 17 00:00:00 2001
From: Eric Wong <normalperson@yhbt.net>
Date: Mon, 31 Dec 2012 13:20:23 +0000
Subject: [PATCH] epoll: prevent missed events on EPOLL_CTL_MOD

ep_modify() works on files that are already registered with a wait queue
(and thus should not reregister).  For sockets, this means sk_sleep()
will return a non-NULL wait address.

ep_modify() must check for events that were received and ignored
_before_ ep_modify() was called.  So it must call f_op->poll() to
fish for events _after_ changing epi->event.events.

When f_op->poll() calls tcp_poll() (and thus sock_poll_wait()),
wait_address is non-NULL because the socket was already registered by
epoll.  Thus, ep_modify() passes a NULL pt to prevent re-registration.

When ep_modify() is called, sock_poll_wait() will see a wait_address,
but a NULL pt, and this caused the memory barrier to get skipped and
events to be missed (this memory barrier is described in the
documentation for wq_has_sleeper).

This regression appeared with the change to sock_poll_wait() in
commit 626cf236608505d376e4799adb4f7eb00a8594af
  (poll: add poll_requested_events() and poll_does_not_wait() functions)

This issue was encountered by Andreas Voellmy and Junchang(Jason) Wang:
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
Tested-by: Andreas Voellmy <andreas.voellmy@yale.edu>
Tested-by: "Junchang(Jason) Wang" <junchang.wang@yale.edu>
Cc: netdev@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
---
 include/net/sock.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c945fba..1923e48 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1925,8 +1925,9 @@ static inline bool wq_has_sleeper(struct socket_wq *wq)
 static inline void sock_poll_wait(struct file *filp,
 		wait_queue_head_t *wait_address, poll_table *p)
 {
-	if (!poll_does_not_wait(p) && wait_address) {
-		poll_wait(filp, wait_address, p);
+	if (wait_address) {
+		if (!poll_does_not_wait(p))
+			poll_wait(filp, wait_address, p);
 		/* We need to be sure we are in sync with the
 		 * socket flags modification.
 		 *
-- 
Eric Wong
