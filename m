From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 3/6] netfilter: xt_owner: use skb_to_full_sk() helper
Date: Sun,  8 Nov 2015 10:54:09 -0800
Message-ID: <1447008853-16060-4-git-send-email-edumazet@google.com>
References: <1447008853-16060-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paul Moore <paul@paul-moore.com>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34083 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbKHSye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 13:54:34 -0500
Received: by padhx2 with SMTP id hx2so166373843pad.1
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 10:54:33 -0800 (PST)
In-Reply-To: <1447008853-16060-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYNACK packets might be attached to a request socket,
xt_owner wants to gte the listener in this case.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/xt_owner.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index ca2e577ed8ac..1302b475abcb 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -14,6 +14,7 @@
 #include <linux/skbuff.h>
 #include <linux/file.h>
 #include <net/sock.h>
+#include <net/inet_sock.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_owner.h>
 
@@ -33,8 +34,9 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_owner_match_info *info = par->matchinfo;
 	const struct file *filp;
+	struct sock *sk = skb_to_full_sk(skb);
 
-	if (skb->sk == NULL || skb->sk->sk_socket == NULL)
+	if (sk == NULL || sk->sk_socket == NULL)
 		return (info->match ^ info->invert) == 0;
 	else if (info->match & info->invert & XT_OWNER_SOCKET)
 		/*
@@ -43,7 +45,7 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		 */
 		return false;
 
-	filp = skb->sk->sk_socket->file;
+	filp = sk->sk_socket->file;
 	if (filp == NULL)
 		return ((info->match ^ info->invert) &
 		       (XT_OWNER_UID | XT_OWNER_GID)) == 0;
-- 
2.6.0.rc2.230.g3dd15c0
