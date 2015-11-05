From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: use sk_fullsock() in ipv4_conntrack_defrag()
Date: Thu, 05 Nov 2015 11:34:06 -0800
Message-ID: <1446752046.4184.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36385 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbbKETeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:34:08 -0500
Received: by pacdm15 with SMTP id dm15so71753326pac.3
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 11:34:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Before converting a 'socket pointer' into inet socket,
use sk_fullsock() to detect timewait or request sockets.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Tested-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
Please David merge this directly into net tree, I am sure Pablo
wont object for a fast track. Thanks !

 net/ipv4/netfilter/nf_defrag_ipv4.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 0e5591c2ee9f..6fb869f646bf 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -67,10 +67,9 @@ static unsigned int ipv4_conntrack_defrag(void *priv,
 					  const struct nf_hook_state *state)
 {
 	struct sock *sk = skb->sk;
-	struct inet_sock *inet = inet_sk(skb->sk);
 
-	if (sk && (sk->sk_family == PF_INET) &&
-	    inet->nodefrag)
+	if (sk && sk_fullsock(sk) && (sk->sk_family == PF_INET) &&
+	    inet_sk(sk)->nodefrag)
 		return NF_ACCEPT;
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
