From: Artem Germanov <agermanov@anchorfree.com>
Subject: [PATCH] tcp: cwnd does not increase in TCP YeAH
Date: Sun, 4 Sep 2016 21:03:27 -0700
Message-ID: <c5290080-8b14-e711-a972-3d2c49d0bdd1@anchorfree.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <nanditad@google.com>, <edumazet@google.com>,
        <ncardwell@google.com>, <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from afmail2.anchorfree.com ([74.115.4.40]:48378 "EHLO
        afmail2.anchorfree.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbcIEEG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 00:06:26 -0400
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
---
--- net/ipv4/tcp_yeah.c.orig    2016-09-04 09:53:01.000000000 -0700
+++ net/ipv4/tcp_yeah.c 2016-09-04 09:53:40.000000000 -0700
@@ -76,7 +76,7 @@ static void tcp_yeah_cong_avoid(struct s
         if (!tcp_is_cwnd_limited(sk))
                 return;

-       if (tp->snd_cwnd <= tp->snd_ssthresh)
+       if (tcp_in_slow_start(tp))
                 tcp_slow_start(tp, acked);

         else if (!yeah->doing_reno_now) {
