From: Eric Wong <normalperson@yhbt.net>
Subject: [PATCH] poll: prevent missed events if _qproc is NULL
Date: Mon, 31 Dec 2012 13:21:00 +0000
Message-ID: <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
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
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121228014503.GA5017@dcvr.yhbt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch seems to fix my issue with ppoll() being stuck on my
SMP machine: http://article.gmane.org/gmane.linux.file-systems/70414

The change to sock_poll_wait() in
commit 626cf236608505d376e4799adb4f7eb00a8594af
  (poll: add poll_requested_events() and poll_does_not_wait() functions)
seems to have allowed additional cases where the SMP memory barrier
is not issued before checking for readiness.

In my case, this affects the select()-family of functions
which register descriptors once and set _qproc to NULL before
checking events again (after poll_schedule_timeout() returns).
The set_mb() barrier in poll_schedule_timeout() appears to be
insufficient on my SMP x86-64 machine (as it's only an xchg()).

This may also be related to the epoll issue described by
Andreas Voellmy in http://thread.gmane.org/gmane.linux.kernel/1408782/

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
Cc: "Junchang(Jason) Wang" <junchang.wang@yale.edu>
Cc: netdev@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
---
 If this patch is correct, I think we can just drop the
 poll_does_not_wait() function entirely since poll_wait()
 does the same check anyways...

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
