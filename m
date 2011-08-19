From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [PATCH] ipv6: Fix ipv6_getsockopt for IPV6_2292PKTOPTIONS
Date: Fri, 19 Aug 2011 12:55:58 +0300
Message-ID: <1313747758-10063-1-git-send-email-dbaluta@ixiacom.com>
Cc: netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>,
	Sorin Dumitru <sdumitru@ixiacom.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57289 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab1HSJyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 05:54:55 -0400
Received: by fxh19 with SMTP id 19so1831350fxh.19
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 02:54:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPV6_2292PKTOPTIONS is broken for 32-bit applications running
in COMPAT mode on 64-bit kernels.

The same problem was fixed for IPv4 with the patch:
ipv4: Fix ip_getsockopt for IP_PKTOPTIONS,
commit dd23198e58cd35259dd09e8892bbdb90f1d57748

Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/ipv6/ipv6_sockglue.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 9cb191e..71ce053 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -913,7 +913,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 }
 
 static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int __user *optlen)
+		    char __user *optval, int __user *optlen, unsigned flags)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	int len;
@@ -962,7 +962,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 
 		msg.msg_control = optval;
 		msg.msg_controllen = len;
-		msg.msg_flags = 0;
+		msg.msg_flags = flags;
 
 		lock_sock(sk);
 		skb = np->pktoptions;
@@ -1222,7 +1222,7 @@ int ipv6_getsockopt(struct sock *sk, int level, int optname,
 	if(level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
-	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
+	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen, 0);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IPV6_2292PKTOPTIONS) {
@@ -1264,7 +1264,8 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		return compat_mc_getsockopt(sk, level, optname, optval, optlen,
 			ipv6_getsockopt);
 
-	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
+	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen, 
+				 MSG_CMSG_COMPAT);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IPV6_2292PKTOPTIONS) {
-- 
1.7.1

