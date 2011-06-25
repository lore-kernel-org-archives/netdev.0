From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] net, llc: Avoid undefined behaviour in
 llc_conn_ac_inc_vr_by_1()
Date: Sun, 26 Jun 2011 00:11:12 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106260009530.23991@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:18883 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700Ab1FYWUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 18:20:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a sequence point (;) between two writes to llc_sk(sk)->vR in
net/llc/llc_c_ac.c:llc_conn_ac_inc_vr_by_1() so that the order in
which the writes happen become well defined.

While the code may work fine now it may break at any time with a
different compiler, a new version of current compiler or even just a
different optimization level of the current compiler. Much better to
clearly express what's intended in a way that guarantees the result.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/llc/llc_c_ac.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
index ea225bd..e535ca4 100644
--- a/net/llc/llc_c_ac.c
+++ b/net/llc/llc_c_ac.c
@@ -1296,7 +1296,14 @@ int llc_conn_ac_set_vr_0(struct sock *sk, struct sk_buff *skb)
 
 int llc_conn_ac_inc_vr_by_1(struct sock *sk, struct sk_buff *skb)
 {
-	llc_sk(sk)->vR = PDU_GET_NEXT_Vr(llc_sk(sk)->vR);
+	/* Do not consolidate this on one line. Since the PDU_GET_NEXT_Vr
+	   macro increments its argument which is the same as what we are
+	   writing to, then we'll have two writes to the same variable
+	   without an intervening sequence point, which leads to the
+	   situation where we can't really know what gets stored as the
+	   result since the compiler is free to do those in any order. */
+	const u8 new_vr = PDU_GET_NEXT_Vr(llc_sk(sk)->vR);
+	llc_sk(sk)->vR = new_vr;
 	return 0;
 }
 
-- 
1.7.5.2


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

