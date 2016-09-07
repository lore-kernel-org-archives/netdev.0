From: Artem Germanov <agermanov@anchorfree.com>
Subject: [PATCH v2] tcp: cwnd does not increase in TCP YeAH
Date: Wed, 7 Sep 2016 10:49:36 -0700
Message-ID: <b4685d52-7fa0-5fac-b361-a20b610674d7@anchorfree.com>
References: <c5290080-8b14-e711-a972-3d2c49d0bdd1@anchorfree.com>
 <20160906.135846.2108420188600081714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <nanditad@google.com>, <edumazet@google.com>,
        <ncardwell@google.com>, <ycheng@google.com>,
        "Dmitry Adamushko" <d.adamushko@anchorfree.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from afmail2.anchorfree.com ([74.115.4.40]:57474 "EHLO
        afmail2.anchorfree.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752301AbcIGRrP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 13:47:15 -0400
In-Reply-To: <20160906.135846.2108420188600081714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 76174004a0f19785a328f40388e87e982bbf69b9
(tcp: do not slow start when cwnd equals ssthresh )
introduced regression in TCP YeAH. Using 100ms delay 1% loss virtual 
ethernet link kernel 4.2 shows bandwidth ~500KB/s for single TCP 
connection and kernel 4.3 and above (including 4.8-rc4) shows bandwidth 
~100KB/s.
   That is caused by stalled cwnd when cwnd equals ssthresh. This patch 
fixes it by proper increasing cwnd in this case.

Signed-off-by: Artem Germanov <agermanov@anchorfree.com>
Acked-by: Dmitry Adamushko <d.adamushko@anchorfree.com>
---
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 028eb04..9c5fc97 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -76,7 +76,7 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (!tcp_is_cwnd_limited(sk))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
+	if (tcp_in_slow_start(tp))
 		tcp_slow_start(tp, acked);
 
 	else if (!yeah->doing_reno_now) {
