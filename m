From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP] FRTO: Limit snd_cwnd if TCP was application limited
Date: Wed, 14 Nov 2007 00:08:18 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711140004210.3997@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-733907344-1194991698=:3997"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33429 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760182AbXKMWIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 17:08:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-733907344-1194991698=:3997
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Otherwise TCP might violate packet ordering principles that FRTO
is based on. If conventional recovery path is chosen, this won't
be significant at all. In practice, any small enough value will
be sufficient to provide proper operation for FRTO, yet other
users of snd_cwnd might benefit from a "close enough" value.

FRTO's formula is now equal to what tcp_enter_cwr() uses.

FRTO used to check application limitedness a bit differently but
I changed that in commit 575ee7140dabe9b9c4f66f4f867039b97e548867
and as a result checking for application limitedness became
completely non-existing.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

Noticed this unrelated problem while thinking LOST bits and stuff...

 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cc358d4..3f126ec 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1674,6 +1674,9 @@ void tcp_enter_frto(struct sock *sk)
 	}
 	tcp_verify_left_out(tp);
 
+	/* Too bad if TCP was application limited */
+	tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp) + 1);
+
 	/* Earlier loss recovery underway (see RFC4138; Appendix B).
 	 * The last condition is necessary at least in tp->frto_counter case.
 	 */
-- 
1.5.0.6

---696243703-733907344-1194991698=:3997--
