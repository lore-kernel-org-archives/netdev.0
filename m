From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 07/15] user namespace: use net->user_ns for some capable calls under net/
Date: Fri,  2 Sep 2011 19:56:32 +0000
Message-ID: <1314993400-6910-10-git-send-email-serge@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Cc: Serge Hallyn <serge.hallyn@ubuntu.com>
To: akpm@osdl.org, segooon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	dhowells@redhat.com, ebiederm@xmission.com, rdunlap@xenotime.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge Hallyn <serge.hallyn@ubuntu.com>

Just a partial conversion to show how the previous patch is expected to
be used.

Changelog:
  6/28/11: fix typo in net/core/sock.c
  7/08/11: don't target capability which authorizes module loading

Signed-off-by: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c  |    4 ++--
 net/core/sock.c |   14 ++++++++------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 17d67b5..6ae955f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5014,7 +5014,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSIFNAME:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		dev_load(net, ifr.ifr_name);
 		rtnl_lock();
@@ -5053,7 +5053,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCBRADDIF:
 	case SIOCBRDELIF:
 	case SIOCSHWTSTAMP:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		/* fall through */
 	case SIOCBONDSLAVEINFOQUERY:
diff --git a/net/core/sock.c b/net/core/sock.c
index bc745d0..0f31675 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -420,7 +420,7 @@ static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 
 	/* Sorry... */
 	ret = -EPERM;
-	if (!capable(CAP_NET_RAW))
+	if (!ns_capable(net->user_ns, CAP_NET_RAW))
 		goto out;
 
 	ret = -EINVAL;
@@ -488,6 +488,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	int valbool;
 	struct linger ling;
 	int ret = 0;
+	struct net *net = sock_net(sk);
 
 	/*
 	 *	Options without arguments
@@ -508,7 +509,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 
 	switch (optname) {
 	case SO_DEBUG:
-		if (val && !capable(CAP_NET_ADMIN))
+		if (val && !ns_capable(net->user_ns, CAP_NET_ADMIN))
 			ret = -EACCES;
 		else
 			sock_valbool_flag(sk, SOCK_DBG, valbool);
@@ -551,7 +552,7 @@ set_sndbuf:
 		break;
 
 	case SO_SNDBUFFORCE:
-		if (!capable(CAP_NET_ADMIN)) {
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
 			ret = -EPERM;
 			break;
 		}
@@ -589,7 +590,7 @@ set_rcvbuf:
 		break;
 
 	case SO_RCVBUFFORCE:
-		if (!capable(CAP_NET_ADMIN)) {
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
 			ret = -EPERM;
 			break;
 		}
@@ -612,7 +613,8 @@ set_rcvbuf:
 		break;
 
 	case SO_PRIORITY:
-		if ((val >= 0 && val <= 6) || capable(CAP_NET_ADMIN))
+		if ((val >= 0 && val <= 6) ||
+		     ns_capable(net->user_ns, CAP_NET_ADMIN))
 			sk->sk_priority = val;
 		else
 			ret = -EPERM;
@@ -729,7 +731,7 @@ set_rcvbuf:
 			clear_bit(SOCK_PASSSEC, &sock->flags);
 		break;
 	case SO_MARK:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			ret = -EPERM;
 		else
 			sk->sk_mark = val;
-- 
1.7.5.4
