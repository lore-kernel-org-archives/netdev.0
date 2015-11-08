From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 4/6] sched: cls_flow: use skb_to_full_sk() helper
Date: Sun,  8 Nov 2015 10:54:10 -0800
Message-ID: <1447008853-16060-5-git-send-email-edumazet@google.com>
References: <1447008853-16060-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paul Moore <paul@paul-moore.com>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36825 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbKHSyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 13:54:37 -0500
Received: by pacdm15 with SMTP id dm15so150500106pac.3
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 10:54:37 -0800 (PST)
In-Reply-To: <1447008853-16060-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYNACK packets might be attached to request sockets.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/cls_flow.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 536838b657bf..fbfec6a18839 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -22,6 +22,7 @@
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <net/inet_sock.h>
 
 #include <net/pkt_cls.h>
 #include <net/ip.h>
@@ -197,8 +198,11 @@ static u32 flow_get_rtclassid(const struct sk_buff *skb)
 
 static u32 flow_get_skuid(const struct sk_buff *skb)
 {
-	if (skb->sk && skb->sk->sk_socket && skb->sk->sk_socket->file) {
-		kuid_t skuid = skb->sk->sk_socket->file->f_cred->fsuid;
+	struct sock *sk = skb_to_full_sk(skb);
+
+	if (sk && sk->sk_socket && sk->sk_socket->file) {
+		kuid_t skuid = sk->sk_socket->file->f_cred->fsuid;
+
 		return from_kuid(&init_user_ns, skuid);
 	}
 	return 0;
@@ -206,8 +210,11 @@ static u32 flow_get_skuid(const struct sk_buff *skb)
 
 static u32 flow_get_skgid(const struct sk_buff *skb)
 {
-	if (skb->sk && skb->sk->sk_socket && skb->sk->sk_socket->file) {
-		kgid_t skgid = skb->sk->sk_socket->file->f_cred->fsgid;
+	struct sock *sk = skb_to_full_sk(skb);
+
+	if (sk && sk->sk_socket && sk->sk_socket->file) {
+		kgid_t skgid = sk->sk_socket->file->f_cred->fsgid;
+
 		return from_kgid(&init_user_ns, skgid);
 	}
 	return 0;
-- 
2.6.0.rc2.230.g3dd15c0
