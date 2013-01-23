From: Richard Guy Briggs <rbriggs@redhat.com>
Subject: [PATCH] netlink: add send and receive capability requirement and capability flags
Date: Wed, 23 Jan 2013 09:52:24 -0500
Message-ID: <1358952744-29288-1-git-send-email-rbriggs@redhat.com>
Cc: Richard Guy Briggs <rgb@redhat.com>,
	Richard Guy Briggs <rbriggs@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094Ab3AWOxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:53:55 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NErtOj015132
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 09:53:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Guy Briggs <rgb@redhat.com>

Currently netlink socket permissions are controlled by the
NL_CFG_F_NONROOT_{RECV,SEND} flags in the kernel socket configuration or by the
CAP_NET_ADMIN capability of the client.  The former allows non-root users
access to the socket.  The latter allows all network admin clients access to
the socket.  It would be useful to be able to further restrict this access to
send or receive capabilities individually within specific subsystems with a
more targetted capability.  Two more flags, NL_CFG_F_CAPABILITY_{RECV,SEND},
have been added to specifically require a named capability should the subsystem
request it, allowing the client to drop other broad unneeded capabilities.

Signed-off-by: Richard Guy Briggs <rbriggs@redhat.com>
---

Hi,

This is a feature addition in preparation to add a multicast netlink socket to
kaudit for read-only userspace clients such as systemd, in addition to the
bidirectional unicast auditd userspace client.

Currently, auditd has the CAP_AUDIT_CONTROL and CAP_AUDIT_WRITE capabilities
(bot uses CAP_NET_ADMIN).  The CAP_AUDIT_READ capability will be added for use
by read-only AUDIT_NLGRP_READLOG multicast group clients to the kaudit
subsystem.

I already have a test app working with this patch.

Can I get some feedback as to whether this is the best way to go about adding
this feature?

Sorry for exceeding the 80-char line limit, but breaking up those two lines
would have been a bit ugly.

Most of the credit for this patch goes to Eric Paris.

Thanks!

 include/linux/netlink.h  |  4 ++++
 net/netlink/af_netlink.c | 35 +++++++++++++++++++++++++++++------
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index e0f746b..30daf11 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -31,6 +31,8 @@ extern void netlink_table_ungrab(void);
 
 #define NL_CFG_F_NONROOT_RECV	(1 << 0)
 #define NL_CFG_F_NONROOT_SEND	(1 << 1)
+#define NL_CFG_F_CAPABILITY_RECV (1 << 2)
+#define NL_CFG_F_CAPABILITY_SEND (1 << 3)
 
 /* optional Netlink kernel configuration parameters */
 struct netlink_kernel_cfg {
@@ -39,6 +41,8 @@ struct netlink_kernel_cfg {
 	void		(*input)(struct sk_buff *skb);
 	struct mutex	*cb_mutex;
 	void		(*bind)(int group);
+	int		cap_send_requires;
+	int		cap_recv_requires;
 };
 
 extern struct sock *__netlink_kernel_create(struct net *net, int unit,
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c0353d5..cce1fe3 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -127,6 +127,8 @@ struct netlink_table {
 	struct module		*module;
 	void			(*bind)(int group);
 	int			registered;
+	int			cap_send_requires;
+	int			cap_recv_requires;
 };
 
 static struct netlink_table *nl_table;
@@ -552,6 +554,8 @@ static int netlink_release(struct socket *sock)
 			nl_table[sk->sk_protocol].bind = NULL;
 			nl_table[sk->sk_protocol].flags = 0;
 			nl_table[sk->sk_protocol].registered = 0;
+			nl_table[sk->sk_protocol].cap_send_requires = 0;
+			nl_table[sk->sk_protocol].cap_recv_requires = 0;
 		}
 	} else if (nlk->subscriptions) {
 		netlink_update_listeners(sk);
@@ -611,8 +615,20 @@ retry:
 
 static inline int netlink_capable(const struct socket *sock, unsigned int flag)
 {
-	return (nl_table[sock->sk->sk_protocol].flags & flag) ||
-		ns_capable(sock_net(sock->sk)->user_ns, CAP_NET_ADMIN);
+	struct netlink_table *nlt = &nl_table[sock->sk->sk_protocol];
+
+	switch (flag & nlt->flags) {
+	case NL_CFG_F_NONROOT_RECV:
+	case NL_CFG_F_NONROOT_SEND:
+		return true;
+	case NL_CFG_F_CAPABILITY_RECV:
+		return capable(nlt->cap_recv_requires);
+	case NL_CFG_F_CAPABILITY_SEND:
+		return capable(nlt->cap_send_requires);
+	default:
+		return capable(CAP_NET_ADMIN);
+	}
+	return false;
 }
 
 static void
@@ -677,7 +693,8 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 
 	/* Only superuser is allowed to listen multicasts */
 	if (nladdr->nl_groups) {
-		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
+		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV |
+					   NL_CFG_F_CAPABILITY_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -739,7 +756,9 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 		return -EINVAL;
 
 	/* Only superuser is allowed to send multicasts */
-	if (nladdr->nl_groups && !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
+	if (nladdr->nl_groups &&
+	    !netlink_capable(sock, NL_CFG_F_NONROOT_SEND |
+				   NL_CFG_F_CAPABILITY_SEND))
 		return -EPERM;
 
 	if (!nlk->portid)
@@ -1262,7 +1281,8 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
 	case NETLINK_DROP_MEMBERSHIP: {
-		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV))
+		if (!netlink_capable(sock, NL_CFG_F_NONROOT_RECV |
+					   NL_CFG_F_CAPABILITY_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
 		if (err)
@@ -1394,7 +1414,8 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		dst_group = ffs(addr->nl_groups);
 		err =  -EPERM;
 		if ((dst_group || dst_portid) &&
-		    !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
+		    !netlink_capable(sock, NL_CFG_F_NONROOT_SEND |
+					   NL_CFG_F_CAPABILITY_SEND))
 			goto out;
 	} else {
 		dst_portid = nlk->dst_portid;
@@ -1600,6 +1621,8 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 		if (cfg) {
 			nl_table[unit].bind = cfg->bind;
 			nl_table[unit].flags = cfg->flags;
+			nl_table[unit].cap_send_requires = cfg->cap_send_requires;
+			nl_table[unit].cap_recv_requires = cfg->cap_recv_requires;
 		}
 		nl_table[unit].registered = 1;
 	} else {
-- 
1.8.0.2
