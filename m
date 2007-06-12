From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 1/1] [TCP]: Fix left_out setting during FRTO
Date: Tue, 12 Jun 2007 11:50:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706121147020.22843@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-634505766-1181638229=:22843"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45236 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbXFLIub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 04:50:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-634505766-1181638229=:22843
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Without FRTO, the tcp_try_to_open is never called with
lost_out > 0 (see tcp_time_to_recover). However, when FRTO is
enabled, the !tp->lost condition is not used until end of FRTO
because that way TCP avoids premature entry to fast recovery
during FRTO.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

This case was found during left_out drop audit (only relevant to
net-2.6 since tcp-2.6 does a right thing after left_out drop).


diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 74683d8..ed4a1bd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2037,7 +2037,7 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	tp->left_out = tp->sacked_out;
+	tcp_sync_left_out(tp);
 
 	if (tp->retrans_out == 0)
 		tp->retrans_stamp = 0;
-- 
1.5.0.6

---696243703-634505766-1181638229=:22843--
