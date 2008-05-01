From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Fix fackets corruption during transitional state
Date: Thu, 1 May 2008 23:31:14 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805012328570.29396@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1080025771-1209673874=:29396"
Cc: Netdev <netdev@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Arjan van de Ven <arjan@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Andy Furniss <lists@andyfurniss.entadsl.com>,
	Georgi Chorbadzhiyski <gf@unixsol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59576 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027AbYEAUbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 16:31:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1080025771-1209673874=:29396
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Ingrediments:

- Sacktag can call tcp_fragment() for those skbs that will get
  discard in tcp_clean_rtx_queue(), even though some of the
  other things are "optimized away".
- snd_una is advanced very early in tcp_ack()
- tcp_highest_sack_seq() uses tp->snd_una when sacked_out is
  zero

These together make it possible to get fackets_out adjusted
while sacked_out remains zero (it can then later on be
incremented as well but then incorrect fackets_out is already
getting happily used). The corruption can occur only when no
SACK info is previously known and a DSACK below snd_una arrives.
I think an old ACK with some SACK info could do the same as
well.

Significant corruption is not likely to happen in practice
(explains the rareness of reports) because it requires quite
complex things to end up into a situation where fragmentation due
to arriving SACK block does actually cause packets_out (and the
related fackets_out) adjustment to become necessary.

In addition to above, we fix fackets_out in fastretrans_alert if
sacked_out remained zero (at the same place where the WARN_ON
triggers), so some SACK info above snd_una must arrive too to
make the incorrect state to have some persistency.

In general, this causes mainly off-by-one error in fackets_out
(though it might occur "twice in a row" to get it more off).
That can cause premature entry to recovery and minor miscounts
of other state that depends on fackets_out amount. However,
quite often we'd immediately hit the WARN_ON trap and fix the
invariant. Even if persistent for a short duration, threat of
this bug is quite low, couple of extra packets at most,
sometimes it could have even made the recovery to begin more
timely, which normally isn't done to avoid spurious recoveries
due to potential reordering (which didn't occur near the majority
of the recoveries anyway).

To be honest, so far I've not been able to find out a scenario
where it would be caused by something that isn't either buggy or
malicious SACK block (not that it wouldn't exists, I'm just too
dumb to find that :-)). Win in malicious case would really be
close to zero, besides spamming the log.

We could optimize fragmenting of soon to be discarded part away
from sacktag as well (it might still be necessary for DSACKs
though, so not much gain currently). However, I don't want to do
such, more scary thing now due to stable potential of this fix,
and such optimization approach requires more thinking to not
introduce other problems.

Heh, it helped nothing to verify whether those fackets_out
touching functions successfully kept invariants intact (did
that at least twenty times and never found anything) because
the function they depended on weas breaking the other thing
(I though that it would be an invariant too) during update
snd_una in tcp_ack->sacktag->clean_rtx_queue period.

Reported by couple of people in the past and finally Andy
Furniss <lists@andyfurniss.entadsl.com> who had a
reproducable setup for this (with some amount of waiting of
course :-)) and was able to try with my debug patches.

Should fix Bugzilla #10346.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Andy Furniss <lists@andyfurniss.entadsl.com>
Reported-by: Georgi Chorbadzhiyski <gf@unixsol.org>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Arjan van de Ven <arjan@infradead.org>
---
 net/ipv4/tcp_output.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d29ef79..8c1578b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -783,7 +783,14 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 			tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
 			tcp_verify_left_out(tp);
 		}
-		tcp_adjust_fackets_out(sk, skb, diff);
+
+		/* Sacktag may use tcp_fragment for skb with seq < snd_una
+		 * which is incompatible what tcp_highest_sack_seq() used in
+		 * tcp_adjust_fackets_out assumes. Under non-trivial
+		 * conditions that would cause problems.
+		 */
+		if (tp->sacked_out)
+			tcp_adjust_fackets_out(sk, skb, diff);
 	}
 
 	/* Link BUFF into the send queue. */
-- 
1.5.2.2

---696208474-1080025771-1209673874=:29396--
