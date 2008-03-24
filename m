From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/11 net-2.6.25] [NETNS]: Add namespace parameter to ip_options_get(...).
Date: Mon, 24 Mar 2008 17:36:05 +0300
Message-ID: <1206369372-27711-4-git-send-email-den@openvz.org>
References: <1206369185.23705.7.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:63159 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758668AbYCXOfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 10:35:51 -0400
In-Reply-To: <1206369185.23705.7.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the init_net there for now.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ip.h       |    4 ++--
 net/ipv4/ip_options.c  |   14 ++++++++------
 net/ipv4/ip_sockglue.c |    4 ++--
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index bcc3afa..531270d 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -349,9 +349,9 @@ extern int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb);
 extern void ip_options_fragment(struct sk_buff *skb);
 extern int ip_options_compile(struct net *net,
 			      struct ip_options *opt, struct sk_buff *skb);
-extern int ip_options_get(struct ip_options **optp,
+extern int ip_options_get(struct net *net, struct ip_options **optp,
 			  unsigned char *data, int optlen);
-extern int ip_options_get_from_user(struct ip_options **optp,
+extern int ip_options_get_from_user(struct net *net, struct ip_options **optp,
 				    unsigned char __user *data, int optlen);
 extern void ip_options_undo(struct ip_options * opt);
 extern void ip_forward_options(struct sk_buff *skb);
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index f0949b4..59f7ddf 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -507,13 +507,13 @@ static struct ip_options *ip_options_get_alloc(const int optlen)
 		       GFP_KERNEL);
 }
 
-static int ip_options_get_finish(struct ip_options **optp,
+static int ip_options_get_finish(struct net *net, struct ip_options **optp,
 				 struct ip_options *opt, int optlen)
 {
 	while (optlen & 3)
 		opt->__data[optlen++] = IPOPT_END;
 	opt->optlen = optlen;
-	if (optlen && ip_options_compile(&init_net, opt, NULL)) {
+	if (optlen && ip_options_compile(net, opt, NULL)) {
 		kfree(opt);
 		return -EINVAL;
 	}
@@ -522,7 +522,8 @@ static int ip_options_get_finish(struct ip_options **optp,
 	return 0;
 }
 
-int ip_options_get_from_user(struct ip_options **optp, unsigned char __user *data, int optlen)
+int ip_options_get_from_user(struct net *net, struct ip_options **optp,
+			     unsigned char __user *data, int optlen)
 {
 	struct ip_options *opt = ip_options_get_alloc(optlen);
 
@@ -532,10 +533,11 @@ int ip_options_get_from_user(struct ip_options **optp, unsigned char __user *dat
 		kfree(opt);
 		return -EFAULT;
 	}
-	return ip_options_get_finish(optp, opt, optlen);
+	return ip_options_get_finish(net, optp, opt, optlen);
 }
 
-int ip_options_get(struct ip_options **optp, unsigned char *data, int optlen)
+int ip_options_get(struct net *net, struct ip_options **optp,
+		   unsigned char *data, int optlen)
 {
 	struct ip_options *opt = ip_options_get_alloc(optlen);
 
@@ -543,7 +545,7 @@ int ip_options_get(struct ip_options **optp, unsigned char *data, int optlen)
 		return -ENOMEM;
 	if (optlen)
 		memcpy(opt->__data, data, optlen);
-	return ip_options_get_finish(optp, opt, optlen);
+	return ip_options_get_finish(net, optp, opt, optlen);
 }
 
 void ip_forward_options(struct sk_buff *skb)
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index bb3cbe5..1b86a50 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -176,7 +176,7 @@ int ip_cmsg_send(struct msghdr *msg, struct ipcm_cookie *ipc)
 		switch (cmsg->cmsg_type) {
 		case IP_RETOPTS:
 			err = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
-			err = ip_options_get(&ipc->opt, CMSG_DATA(cmsg), err < 40 ? err : 40);
+			err = ip_options_get(&init_net, &ipc->opt, CMSG_DATA(cmsg), err < 40 ? err : 40);
 			if (err)
 				return err;
 			break;
@@ -449,7 +449,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		struct ip_options * opt = NULL;
 		if (optlen > 40 || optlen < 0)
 			goto e_inval;
-		err = ip_options_get_from_user(&opt, optval, optlen);
+		err = ip_options_get_from_user(&init_net, &opt, optval, optlen);
 		if (err)
 			break;
 		if (inet->is_icsk) {
-- 
1.5.3.rc5

