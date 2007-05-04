From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6] [TCP] FRTO: Add missing ECN CWR sending to one of
 the responses
Date: Fri, 4 May 2007 10:24:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705041016580.4235@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1121009756-1178263485=:4235"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60962 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577AbXEDHYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 03:24:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1121009756-1178263485=:4235
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

The conservative spurious RTO response did not queue CWR even
though the sending rate was lowered. Whenever reduction happens
regardless of reason, CWR should be sent. Forgetting to send it
is not very fatal though.

A better approach would be to queue CWR already at RTO when one
of the sending rate reducing responses is used (rate-halving one
or this conservative response). Doing that would allow CWR to
be sent along with the two new data segments that are sent
during FRTO. However, it's a bit racy because userland could
tune the response sysctl to a more aggressive one in between,
thus queue it not until in the response...

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7641b27..7ecdc89 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2608,6 +2608,7 @@ static void tcp_conservative_spur_to_res
 {
 	tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
 	tp->snd_cwnd_cnt = 0;
+	TCP_ECN_queue_cwr(tp);
 	tcp_moderate_cwnd(tp);
 }
 
-- 
1.4.2

---696243703-1121009756-1178263485=:4235--
