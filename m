From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: ipv4: initialize unicast_sock sk_pacing_rate
Date: Wed, 28 Jan 2015 05:47:11 -0800
Message-ID: <1422452831.29618.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:50196 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbbA1Uyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:54:43 -0500
Received: by mail-ie0-f172.google.com with SMTP id rd18so24830194iec.3
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 12:54:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When I added sk_pacing_rate field, I forgot to initialize its value
in the per cpu unicast_sock used in ip_send_unicast_reply()

This means that for sch_fq users, RST packets, or ACK packets sent
on behalf of TIME_WAIT sockets might be sent to slowly or even dropped
once we reach the per flow limit.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 95bd09eb2750 ("tcp: TSO packets automatic sizing")
---
 net/ipv4/ip_output.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b50861b22b6bea036b1a99ddf141d7ed2d6cf6cd..38a20a9cca1af327618c816e0695e92e8e152bb5 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1517,6 +1517,7 @@ static DEFINE_PER_CPU(struct inet_sock, unicast_sock) = {
 		.sk_wmem_alloc	= ATOMIC_INIT(1),
 		.sk_allocation	= GFP_ATOMIC,
 		.sk_flags	= (1UL << SOCK_USE_WRITE_QUEUE),
+		.sk_pacing_rate = ~0U,
 	},
 	.pmtudisc	= IP_PMTUDISC_WANT,
 	.uc_ttl		= -1,
