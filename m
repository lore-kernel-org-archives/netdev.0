From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: FRTO undo response falls back to ratehalving one if
 ECEd
Date: Fri, 2 Mar 2007 14:14:19 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703021329520.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-606204201-1172835271=:19465"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45455 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423051AbXCBMOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 07:14:21 -0500
Content-ID: <Pine.LNX.4.64.0703021411060.3770@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-606204201-1172835271=:19465
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0703021411061.3770@kivilampi-30.cs.helsinki.fi>

Undoing ssthresh is disabled in fastretrans_alert whenever
FLAG_ECE is set by clearing prior_ssthresh. This clearing does
not protect FRTO because FRTO operates before fastretrans_alert.
Moving the clearing of prior_ssthresh earlier seems to be a
suboptimal solution to the FRTO case because then FLAG_ECE will
cause a second ssthresh reduction in try_to_open (the first
occurred when FRTO was entered). So instead, FRTO falls back
immediately to the rate halving response, which switches TCP to
CA_CWR state preventing the latter reduction of ssthresh.

If the first ECE arrived before the ACK after which FRTO is able
to decide RTO as spurious, prior_ssthresh is already cleared.
Thus no undoing for ssthresh occurs. Besides, FLAG_ECE should be
set also in the following ACKs resulting in rate halving response
that sees TCP already in CA_CWR, which again prevents an extra
ssthresh reduction on that round-trip.

If the first ECE arrived before RTO, ssthresh has already been
adapted and prior_ssthresh remains cleared on entry because TCP
is in CA_CWR (the same applies also to a case where FRTO is
entered more than once and ECE comes in the middle).

I believe that after this patch, FRTO should be ECN-safe and
even able to take advantage of synergy benefits.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index dc221a3..bdd6172 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2592,9 +2592,12 @@ static void tcp_ratehalving_spur_to_resp
 	tp->high_seq = tp->frto_highmark; 	/* Smoother w/o this? - ij */
 }
 
-static void tcp_undo_spur_to_response(struct sock *sk)
+static void tcp_undo_spur_to_response(struct sock *sk, int flag)
 {
-	tcp_undo_cwr(sk, 1);
+	if (flag&FLAG_ECE)
+		tcp_ratehalving_spur_to_response(sk);
+	else
+		tcp_undo_cwr(sk, 1);
 }
 
 /* F-RTO spurious RTO detection algorithm (RFC4138)
@@ -2680,7 +2683,7 @@ static int tcp_process_frto(struct sock 
 		return 1;
 	} else /* frto_counter == 2 */ {
 		switch (sysctl_tcp_frto_response) {
-		case 2: tcp_undo_spur_to_response(sk); break;
+		case 2: tcp_undo_spur_to_response(sk, flag); break;
 		case 1: tcp_conservative_spur_to_response(tp); break;
 		default: tcp_ratehalving_spur_to_response(sk); break;
 		}
-- 
1.4.2
---696243703-606204201-1172835271=:19465--
