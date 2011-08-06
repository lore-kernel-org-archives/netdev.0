From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [PATCH] ipv4: Fix ip_getsockopt for IP_PKTOPTIONS
Date: Sun,  7 Aug 2011 02:20:50 +0300
Message-ID: <1312672850-13676-1-git-send-email-dbaluta@ixiacom.com>
Cc: netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>,
	Tiberiu Szocs-Mihai <tszocs@ixiacom.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38625 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab1HFXU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 19:20:59 -0400
Received: by fxh19 with SMTP id 19so4046439fxh.19
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2011 16:20:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP_PKTOPTIONS is broken for 32-bit applications running
in COMPAT mode on 64-bit kernels.

This happens because msghdr's msg_flags field is always
set to zero. When running in COMPAT mode this should be
set to MSG_CMSG_COMPAT instead.

Signed-off-by: Tiberiu Szocs-Mihai <tszocs@ixiacom.com>
Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/ipv4/ip_sockglue.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ab0c9ef..c77f5a8 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1067,7 +1067,7 @@ EXPORT_SYMBOL(compat_ip_setsockopt);
  */
 
 static int do_ip_getsockopt(struct sock *sk, int level, int optname,
-			    char __user *optval, int __user *optlen)
+			    char __user *optval, int __user *optlen, unsigned flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	int val;
@@ -1240,7 +1240,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 
 		msg.msg_control = optval;
 		msg.msg_controllen = len;
-		msg.msg_flags = 0;
+		msg.msg_flags = flags;
 
 		if (inet->cmsg_flags & IP_CMSG_PKTINFO) {
 			struct in_pktinfo info;
@@ -1294,7 +1294,7 @@ int ip_getsockopt(struct sock *sk, int level,
 {
 	int err;
 
-	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
+	err = do_ip_getsockopt(sk, level, optname, optval, optlen, 0);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS &&
@@ -1327,7 +1327,8 @@ int compat_ip_getsockopt(struct sock *sk, int level, int optname,
 		return compat_mc_getsockopt(sk, level, optname, optval, optlen,
 			ip_getsockopt);
 
-	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
+	err = do_ip_getsockopt(sk, level, optname, optval, optlen, 
+		MSG_CMSG_COMPAT);
 
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
-- 
1.7.2.5

