From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/11] inet_diag: Partly rename inet_ to sock_
Date: Tue, 06 Dec 2011 21:56:43 +0400
Message-ID: <4EDE575B.3010507@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11969 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169Ab1LFR4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:56:49 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ultimate goal is to get the sock_diag module, that works in
family+protocol terms. Currently this is suitable to do on the
inet_diag basis, so rename parts of the code. It will be moved
to sock_diag.c later.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/netlink.h  |    2 +-
 net/dccp/diag.c          |    2 +-
 net/ipv4/inet_diag.c     |   33 +++++++++++++++++++--------------
 net/ipv4/tcp_diag.c      |    2 +-
 security/selinux/hooks.c |    2 +-
 5 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 8374d29..9827ebf 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -8,7 +8,7 @@
 #define NETLINK_UNUSED		1	/* Unused number				*/
 #define NETLINK_USERSOCK	2	/* Reserved for user mode socket protocols 	*/
 #define NETLINK_FIREWALL	3	/* Firewalling hook				*/
-#define NETLINK_INET_DIAG	4	/* INET socket monitoring			*/
+#define NETLINK_SOCK_DIAG	4	/* socket monitoring				*/
 #define NETLINK_NFLOG		5	/* netfilter/iptables ULOG */
 #define NETLINK_XFRM		6	/* ipsec */
 #define NETLINK_SELINUX		7	/* SELinux event notifications */
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index b21f261..d92ba7d 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -71,4 +71,4 @@ module_exit(dccp_diag_fini);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arnaldo Carvalho de Melo <acme@mandriva.com>");
 MODULE_DESCRIPTION("DCCP inet_diag handler");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_INET_DIAG, DCCPDIAG_GETSOCK);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, DCCPDIAG_GETSOCK);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 0a46c54..a5f3c40 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -45,7 +45,7 @@ struct inet_diag_entry {
 	u16 userlocks;
 };
 
-static struct sock *idiagnl;
+static struct sock *sdiagnl;
 
 #define INET_DIAG_PUT(skb, attrtype, attrlen) \
 	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
@@ -56,7 +56,7 @@ static const struct inet_diag_handler *inet_diag_lock_handler(int type)
 {
 	if (!inet_diag_table[type])
 		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-			       NETLINK_INET_DIAG, type);
+			       NETLINK_SOCK_DIAG, type);
 
 	mutex_lock(&inet_diag_table_mutex);
 	if (!inet_diag_table[type])
@@ -312,7 +312,7 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 		kfree_skb(rep);
 		goto out;
 	}
-	err = netlink_unicast(idiagnl, rep, NETLINK_CB(in_skb).pid,
+	err = netlink_unicast(sdiagnl, rep, NETLINK_CB(in_skb).pid,
 			      MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
@@ -870,20 +870,25 @@ static int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				return -EINVAL;
 		}
 
-		return netlink_dump_start(idiagnl, skb, nlh,
+		return netlink_dump_start(sdiagnl, skb, nlh,
 					  inet_diag_dump, NULL, 0);
 	}
 
 	return inet_diag_get_exact(skb, nlh);
 }
 
-static DEFINE_MUTEX(inet_diag_mutex);
+static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	return inet_diag_rcv_msg(skb, nlh);
+}
+
+static DEFINE_MUTEX(sock_diag_mutex);
 
-static void inet_diag_rcv(struct sk_buff *skb)
+static void sock_diag_rcv(struct sk_buff *skb)
 {
-	mutex_lock(&inet_diag_mutex);
-	netlink_rcv_skb(skb, &inet_diag_rcv_msg);
-	mutex_unlock(&inet_diag_mutex);
+	mutex_lock(&sock_diag_mutex);
+	netlink_rcv_skb(skb, &sock_diag_rcv_msg);
+	mutex_unlock(&sock_diag_mutex);
 }
 
 int inet_diag_register(const struct inet_diag_handler *h)
@@ -929,9 +934,9 @@ static int __init inet_diag_init(void)
 	if (!inet_diag_table)
 		goto out;
 
-	idiagnl = netlink_kernel_create(&init_net, NETLINK_INET_DIAG, 0,
-					inet_diag_rcv, NULL, THIS_MODULE);
-	if (idiagnl == NULL)
+	sdiagnl = netlink_kernel_create(&init_net, NETLINK_SOCK_DIAG, 0,
+					sock_diag_rcv, NULL, THIS_MODULE);
+	if (sdiagnl == NULL)
 		goto out_free_table;
 	err = 0;
 out:
@@ -943,11 +948,11 @@ out_free_table:
 
 static void __exit inet_diag_exit(void)
 {
-	netlink_kernel_release(idiagnl);
+	netlink_kernel_release(sdiagnl);
 	kfree(inet_diag_table);
 }
 
 module_init(inet_diag_init);
 module_exit(inet_diag_exit);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_INET_DIAG);
+MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_SOCK_DIAG);
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 939edb3..9e276b8 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -54,4 +54,4 @@ static void __exit tcp_diag_exit(void)
 module_init(tcp_diag_init);
 module_exit(tcp_diag_exit);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_INET_DIAG, TCPDIAG_GETSOCK);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, TCPDIAG_GETSOCK);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index cca09bb..86305c2 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -1090,7 +1090,7 @@ static inline u16 socket_type_to_security_class(int family, int type, int protoc
 			return SECCLASS_NETLINK_ROUTE_SOCKET;
 		case NETLINK_FIREWALL:
 			return SECCLASS_NETLINK_FIREWALL_SOCKET;
-		case NETLINK_INET_DIAG:
+		case NETLINK_SOCK_DIAG:
 			return SECCLASS_NETLINK_TCPDIAG_SOCKET;
 		case NETLINK_NFLOG:
 			return SECCLASS_NETLINK_NFLOG_SOCKET;
-- 
1.5.5.6
