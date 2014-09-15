From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Subject: [PATCHv2] ipv4: Do not cache routing failures due to disabled forwarding.
Date: Mon, 15 Sep 2014 12:28:13 +0200
Message-ID: <1410776893-5284-1-git-send-email-nicolas.cavallari@green-communications.fr>
References: <54143FB2.9000600@green-communications.fr>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:55849 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbaIOKbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 06:31:22 -0400
In-Reply-To: <54143FB2.9000600@green-communications.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we cache them, the kernel will reuse them, independently of
whether forwarding is enabled or not.  Which means that if forwarding is
disabled on the input interface where the first routing request comes
from, then that unreachable result will be cached and reused for
other interfaces, even if forwarding is enabled on them.

This can be verified with two interfaces A and B and an output interface
C, where B has forwarding enabled, but not A and trying
ip route get $dst iif A from $src && ip route get $dst iif B from $src

Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
---
v2: simplify patch using julian anastasov's suggestion.

 net/ipv4/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 234a43e..b09fda8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1798,6 +1798,7 @@ local_input:
 no_route:
 	RT_CACHE_STAT_INC(in_no_route);
 	res.type = RTN_UNREACHABLE;
+	res.fi = NULL;
 	goto local_input;
 
 	/*
-- 
2.1.0
