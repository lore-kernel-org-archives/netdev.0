From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 18 May 2009 10:24:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905180958150.3381@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
 <200905092014.35642.elendil@planet.nl> <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
 <20090517.154137.104422195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1086652719-1242631463=:3381"
Cc: elendil@planet.nl, matthias.andree@gmx.de,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56910 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755786AbZERHYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 03:24:22 -0400
In-Reply-To: <20090517.154137.104422195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1086652719-1242631463=:3381
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 17 May 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 11 May 2009 09:32:34 +0300 (EEST)
> 
> > [PATCH v2] tcp: fix MSG_PEEK race check
> > 
> > Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
> > blocking behavior) lets the loop run longer than the race check
> > did previously expect, so we need to be more careful with this
> > check and consider the work we have been doing.
> > 
> > I tried my best to deal with urg hole madness too which happens
> > here:
> > 	if (!sock_flag(sk, SOCK_URGINLINE)) {
> > 		++*seq;
> > 		...
> > by using additional offset by one but I certainly have very
> > little interest in testing that part.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > Tested-by: Frans Pop <elendil@planet.nl>
> 
> Ok, now that I've looked at this, the urg_hole part of this change has
> to be removed.

Thanks for taking a look... :-) The first patch btw was with RFC and 
without urg bits btw but you put that into some discarded like(?) state in 
patchwork... :-/

> That case being accounted for with urg_hole is exactly what the
> debugging message is trying to catch, where we are doing MSG_PEEK and
> tcp_check_urg() advances ->copied_seq on us during one of those
> "release_sock();/lock_sock();" sequences (which thus invoke TCP input
> processing).

Sorry, I'm not sure you thought this fully through here. What my patch 
with urg_hole does is that it keeps peek_seq non-advancing using the 
offsets. Now without the urg offsetting, the peek_seq side of the race 
check advances, which means that we didn't catch the race when it happened 
for real as copied_seq advanced too?!?

>From another perspective when the race didn't happen but potential for it 
existed, the current check should catch that since peek_seq advanced and 
copied_seq stayed where it was. But that certainly doesn't match to your 
description above.

I wonder why all this fuzz about this particular race as we will do our 
best anyway to skip the hole on MSG_PEEK side (if I read the code right)? 
Either we never see the hole in MSG_PEEK side, or we're happily past it 
already, does it make any difference anymore in the latter case? <insert 
some "not that I fully understand all of that multipage function" 
disclaimer here though, I may think too simple scenarios here>. Not that 
I'm too interested in "improving" urg or so anywa, I'm just curious... :-)

> Could you please respin this patch with the URG bits removed?

Below.

-- 
 i.

--
[PATCH] tcp: fix MSG_PEEK race check

Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
blocking behavior) lets the loop run longer than the race check
did previously expect, so we need to be more careful with this
check and consider the work we have been doing.

URG hole things postponed to another patch (if needed at all)
as per requested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Tested-by: Frans Pop <elendil@planet.nl>

---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1d7f49c..ccbd69b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1532,7 +1532,7 @@ do_prequeue:
 				}
 			}
 		}
-		if ((flags & MSG_PEEK) && peek_seq != tp->copied_seq) {
+		if ((flags & MSG_PEEK) && (peek_seq - copied != tp->copied_seq)) {
 			if (net_ratelimit())
 				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PEEK.\n",
 				       current->comm, task_pid_nr(current));
-- 
tg: (4d5b78c..) fix/msgpeek-race-chk (depends on: origin/master)
---696208474-1086652719-1242631463=:3381--
