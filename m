From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] csum experts, csum_replace2() is too expensive
Date: Thu, 20 Mar 2014 11:49:01 -0700
Message-ID: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33424 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964846AbaCTStD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 14:49:03 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so1342945pab.10
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 11:49:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

csum_replace2() uses about 29 cycles, while a plain ip_send_check() is
way faster (16 cycles)

csum_partial() is not really meant for doing checksums over 8 bytes !

Any idea how to make the thing really fast as intended ?

I saw csum_partial() consuming 1% of cpu cycles in a GRO workload, that
is insane...

Following patch might be the fastest thing ?

(At this point we already have validated IP checksum)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870db792..86c924c16f3c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1434,8 +1434,8 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
 	int proto = iph->protocol;
 	int err = -ENOSYS;
 
-	csum_replace2(&iph->check, iph->tot_len, newlen);
 	iph->tot_len = newlen;
+	ip_send_check(&iph);
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
