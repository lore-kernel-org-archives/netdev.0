From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [RFC] [TCP]: Catch skb with S+L bugs earlier
Date: Wed, 28 Mar 2007 17:02:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0703281650150.27182@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2127767299-1175090567=:27182"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40451 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbXC1OCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 10:02:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2127767299-1175090567=:27182
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

SACKED_ACKED and LOST are mutually exclusive, thus this
condition is bug with SACK (IMHO). NewReno, however, could get
enough duplicate ACKs which increment sacked_out, so it makes
sense to do this kind of limitting for non-SACK TCP but not for
SACK-enabled one. Perhaps the author had that in mind but did
the logic accidently wrong way around?

Eventually these bugs trigger traps in the tcp_clean_rtx_queue
but it's much more informative to do this here (excludes some
other possible bugs).

Maybe this BUG_TRAP is too expensive to be included everywhere
in the TCP code. Should there be some #if to surround it?

Compile tested. Sadly enough I don't have time for couple of
weeks to test this as it would require some setuping, and besides,
my test machines are occupied currently to other work, but this 
might also be net-2.6 (or even stable) material if it really
works (feel free to cut this paragraph or part of it if you
decide to include this :-)).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index fe1c4f0..3c8dd13 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -733,9 +733,10 @@ static inline __u32 tcp_current_ssthresh
 
 static inline void tcp_sync_left_out(struct tcp_sock *tp)
 {
-	if (tp->rx_opt.sack_ok &&
-	    (tp->sacked_out >= tp->packets_out - tp->lost_out))
+	if (tp->sacked_out + tp->lost_out > tp->packets_out) {
+		BUG_TRAP(!tp->rx_opt.sack_ok);
 		tp->sacked_out = tp->packets_out - tp->lost_out;
+	}
 	tp->left_out = tp->sacked_out + tp->lost_out;
 }
 
-- 
1.4.2

---696243703-2127767299-1175090567=:27182--
