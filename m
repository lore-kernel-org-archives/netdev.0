From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 11 May 2009 09:32:34 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
References: <200902262310.12791.elendil@planet.nl> <20090506230240.GA10373@merlin.emma.line.org>
 <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
 <200905092014.35642.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1596760030-1242023554=:10047"
Cc: Matthias Andree <matthias.andree@gmx.de>,
	Netdev <netdev@vger.kernel.org>
To: Frans Pop <elendil@planet.nl>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41377 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501AbZEKGcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 02:32:35 -0400
In-Reply-To: <200905092014.35642.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1596760030-1242023554=:10047
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 9 May 2009, Frans Pop wrote:

> On Thursday 07 May 2009, Ilpo Järvinen wrote:
> > [RFC PATCH] tcp: fix MSG_PEEK race check
> >
> > Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
> > blocking behavior) lets the loop run longer than this check
> > did previously expect, so we need to be more careful with
> > this check and consider the work we have been doing.
> >
> > I'm a bit unsure if this improved check can still fail as
> >         if (!sock_flag(sk, SOCK_URGINLINE)) {
> >                 ++*seq;
> >                 ...
> > does not increment copied.
> >
> > Compile tested.
> >
> > Signed-off-by: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
> 
> I've been running with the patch for 2 days now and have not seen any more 
> MSG_PEEK errors, so as far as I'm concerned the patch does fix the issue 
> (needed the time in order to be confident of that).
>
> So:
> Tested-by: Frans Pop <elendil@planet.nl>

Added.

> Suggest to also add a CC for stable.

DaveM will take care of stable submissions by himself.


I took my time to fix the urg_hole madness too. The patch below.

--
[PATCH v2] tcp: fix MSG_PEEK race check

Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
blocking behavior) lets the loop run longer than the race check
did previously expect, so we need to be more careful with this
check and consider the work we have been doing.

I tried my best to deal with urg hole madness too which happens
here:
	if (!sock_flag(sk, SOCK_URGINLINE)) {
		++*seq;
		...
by using additional offset by one but I certainly have very
little interest in testing that part.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Tested-by: Frans Pop <elendil@planet.nl>
---
 net/ipv4/tcp.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1d7f49c..7a0f0b2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1321,6 +1321,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct task_struct *user_recv = NULL;
 	int copied_early = 0;
 	struct sk_buff *skb;
+	u32 urg_hole = 0;
 
 	lock_sock(sk);
 
@@ -1532,7 +1533,8 @@ do_prequeue:
 				}
 			}
 		}
-		if ((flags & MSG_PEEK) && peek_seq != tp->copied_seq) {
+		if ((flags & MSG_PEEK) &&
+		    (peek_seq - copied - urg_hole != tp->copied_seq)) {
 			if (net_ratelimit())
 				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PEEK.\n",
 				       current->comm, task_pid_nr(current));
@@ -1553,6 +1555,7 @@ do_prequeue:
 				if (!urg_offset) {
 					if (!sock_flag(sk, SOCK_URGINLINE)) {
 						++*seq;
+						urg_hole++;
 						offset++;
 						used--;
 						if (!used)
-- 
tg: (4d5b78c..) fix/msgpeek-race-chk (depends on: origin/master)
---696208474-1596760030-1242023554=:10047--
