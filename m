From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 1/3] udp6: respect IPV6_DONTFRAG sockopt in case there are pending frames
Date: Sat, 19 Oct 2013 12:29:15 +0200
Message-ID: <1382178557-14737-2-git-send-email-jiri@resnulli.us>
References: <1382178557-14737-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, jdmason@kudzu.us,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:56891 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab3JSK3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 06:29:24 -0400
Received: by mail-ea0-f170.google.com with SMTP id q10so2070186eaj.1
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 03:29:21 -0700 (PDT)
In-Reply-To: <1382178557-14737-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if up->pending != 0 dontfrag is left with default value -1. That
causes that application that do:
sendto len>mtu flag MSG_MORE
sendto len>mtu flag 0
will receive EMSGSIZE errno as the result of the second sendto.

This patch fixes it by respecting IPV6_DONTFRAG socket option.

introduced by:
commit 4b340ae20d0e2366792abe70f46629e576adaf5e "IPv6: Complete IPV6_DONTFRAG support"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/udp.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 72b7eaa..1878609 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1225,9 +1225,6 @@ do_udp_sendmsg:
 	if (tclass < 0)
 		tclass = np->tclass;
 
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
-
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
 back_from_confirm:
@@ -1246,6 +1243,8 @@ back_from_confirm:
 	up->pending = AF_INET6;
 
 do_append_data:
+	if (dontfrag < 0)
+		dontfrag = np->dontfrag;
 	up->len += ulen;
 	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
-- 
1.8.3.1
