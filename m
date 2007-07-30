From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 2/2] [TCP]: Bidir flow must not disregard SACK blocks
 for lost marking
Date: Mon, 30 Jul 2007 20:19:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707302019110.8788@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-240892254-1185815980=:8788"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48420 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965796AbXG3RTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 13:19:44 -0400
In-Reply-To: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-240892254-1185815980=:8788
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


It's possible that new SACK blocks that should trigger new LOST
markings arrive with new data (which previously made is_dupack
false). In addition, I think this fixes a case where we get
a cumulative ACK with enough SACK blocks to trigger the fast
recovery (is_dupack would be false there too).

I'm not completely pleased with this solution because readability
of the code is somewhat questionable as 'is_dupack' in SACK case
is no longer about dupacks only but would mean something like
'lost_marker_work_todo' too... But because of Eifel stuff done
in CA_Recovery, the FLAG_DATA_SACKED check cannot be placed to
the if statement which seems attractive solution. Nevertheless,
I didn't like adding another variable just for that either... :-)

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 767f92c..cfe6ac7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2109,7 +2109,10 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior_snd_una,
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	int is_dupack = (tp->snd_una == prior_snd_una && !(flag&FLAG_NOT_DUP));
+	int is_dupack = (tp->snd_una == prior_snd_una &&
+			 (!(flag&FLAG_NOT_DUP) ||
+			  ((flag&FLAG_DATA_SACKED) &&
+			   (tp->fackets_out > tp->reordering))));
 
 	/* Some technical things:
 	 * 1. Reno does not count dupacks (sacked_out) automatically. */
-- 
1.5.0.6

---696243703-240892254-1185815980=:8788--
