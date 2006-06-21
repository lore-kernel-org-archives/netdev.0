From: paul.moore@hp.com
Subject: [RFC 2/7] NetLabel: core network changes
Date: Wed, 21 Jun 2006 15:42:37 -0400
Message-ID: <20060621200030.880930000@flek.zko.hp.com>
References: <20060621194234.979661000@flek.zko.hp.com>
Cc: sds@epoch.ncsc.mil, jmorris@redhat.com, sgrubb@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
To: redhat-lspp@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline; filename=netlabel-net_core-2.6.17
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes to the core network stack to support the NetLabel subsystem.  This
includes changes to support the NetLabel NETLINK communication mechanism,
changes to the IPv4 option handling to support CIPSO labels, minor changes
to the socket_post_create() LSM hook so that it can return error codes, and
a new NetLabel hook in inet_accept() to handle NetLabel attributes across
an accept().
---
 include/linux/ip.h       |    1 +
 include/linux/netlink.h  |    1 +
 include/linux/security.h |   16 ++++++++--------
 include/net/inet_sock.h  |    2 +-
 net/ipv4/Makefile        |    3 +++
 net/ipv4/af_inet.c       |    3 +++
 net/ipv4/ah4.c           |    2 +-
 net/ipv4/ip_options.c    |   19 +++++++++++++++++++
 net/socket.c             |   13 +++++++++++--
 security/dummy.c         |   12 ++++++------
 10 files changed, 54 insertions(+), 18 deletions(-)

Index: linux-2.6.17.i686-quilt/include/linux/ip.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/include/linux/ip.h
+++ linux-2.6.17.i686-quilt/include/linux/ip.h
@@ -57,6 +57,7 @@
 #define IPOPT_SEC	(2 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_LSRR	(3 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_TIMESTAMP	(4 |IPOPT_MEASUREMENT)
+#define IPOPT_CIPSO	(6 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_RR	(7 |IPOPT_CONTROL)
 #define IPOPT_SID	(8 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_SSRR	(9 |IPOPT_CONTROL|IPOPT_COPY)
Index: linux-2.6.17.i686-quilt/include/linux/netlink.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/include/linux/netlink.h
+++ linux-2.6.17.i686-quilt/include/linux/netlink.h
@@ -21,6 +21,7 @@
 #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
 #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
 #define NETLINK_GENERIC		16
+#define NETLINK_NETLABEL	17	/* Network packet labeling */
 
 #define MAX_LINKS 32		
 
Index: linux-2.6.17.i686-quilt/include/linux/security.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/include/linux/security.h
+++ linux-2.6.17.i686-quilt/include/linux/security.h
@@ -1267,8 +1267,8 @@ struct security_operations {
 	int (*unix_may_send) (struct socket * sock, struct socket * other);
 
 	int (*socket_create) (int family, int type, int protocol, int kern);
-	void (*socket_post_create) (struct socket * sock, int family,
-				    int type, int protocol, int kern);
+	int (*socket_post_create) (struct socket * sock, int family,
+				   int type, int protocol, int kern);
 	int (*socket_bind) (struct socket * sock,
 			    struct sockaddr * address, int addrlen);
 	int (*socket_connect) (struct socket * sock,
@@ -2677,13 +2677,13 @@ static inline int security_socket_create
 	return security_ops->socket_create(family, type, protocol, kern);
 }
 
-static inline void security_socket_post_create(struct socket * sock, 
-					       int family,
-					       int type, 
-					       int protocol, int kern)
+static inline int security_socket_post_create(struct socket * sock,
+					      int family,
+					      int type,
+					      int protocol, int kern)
 {
-	security_ops->socket_post_create(sock, family, type,
-					 protocol, kern);
+	return security_ops->socket_post_create(sock, family, type,
+						protocol, kern);
 }
 
 static inline int security_socket_bind(struct socket * sock, 
Index: linux-2.6.17.i686-quilt/include/net/inet_sock.h
===================================================================
--- linux-2.6.17.i686-quilt.orig/include/net/inet_sock.h
+++ linux-2.6.17.i686-quilt/include/net/inet_sock.h
@@ -52,7 +52,7 @@ struct ip_options {
 			ts_needtime:1,
 			ts_needaddr:1;
 	unsigned char	router_alert;
-	unsigned char	__pad1;
+	unsigned char	cipso;
 	unsigned char	__pad2;
 	unsigned char	__data[0];
 };
Index: linux-2.6.17.i686-quilt/net/ipv4/Makefile
===================================================================
--- linux-2.6.17.i686-quilt.orig/net/ipv4/Makefile
+++ linux-2.6.17.i686-quilt/net/ipv4/Makefile
@@ -42,6 +42,9 @@ obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybl
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
+ifeq ($(CONFIG_NETLABEL_CIPSOV4),y)
+obj-y += cipso_ipv4.o
+endif
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
Index: linux-2.6.17.i686-quilt/net/ipv4/af_inet.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/net/ipv4/af_inet.c
+++ linux-2.6.17.i686-quilt/net/ipv4/af_inet.c
@@ -114,6 +114,7 @@
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
+#include <net/netlabel.h>
 
 DEFINE_SNMP_STAT(struct linux_mib, net_statistics) __read_mostly;
 
@@ -616,6 +617,8 @@ int inet_accept(struct socket *sock, str
 
 	sock_graft(sk2, newsock);
 
+	netlbl_socket_inet_accept(sock, newsock);
+
 	newsock->state = SS_CONNECTED;
 	err = 0;
 	release_sock(sk2);
Index: linux-2.6.17.i686-quilt/net/ipv4/ah4.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/net/ipv4/ah4.c
+++ linux-2.6.17.i686-quilt/net/ipv4/ah4.c
@@ -35,7 +35,7 @@ static int ip_clear_mutable_options(stru
 		switch (*optptr) {
 		case IPOPT_SEC:
 		case 0x85:	/* Some "Extended Security" crap. */
-		case 0x86:	/* Another "Commercial Security" crap. */
+		case IPOPT_CIPSO:
 		case IPOPT_RA:
 		case 0x80|21:	/* RFC1770 */
 			break;
Index: linux-2.6.17.i686-quilt/net/ipv4/ip_options.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/net/ipv4/ip_options.c
+++ linux-2.6.17.i686-quilt/net/ipv4/ip_options.c
@@ -24,6 +24,7 @@
 #include <net/ip.h>
 #include <net/icmp.h>
 #include <net/route.h>
+#include <net/cipso_ipv4.h>
 
 /* 
  * Write options to IP header, record destination address to
@@ -194,6 +195,13 @@ int ip_options_echo(struct ip_options * 
 			dopt->is_strictroute = sopt->is_strictroute;
 		}
 	}
+	if (sopt->cipso) {
+		optlen  = sptr[sopt->cipso+1];
+		dopt->cipso = dopt->optlen+sizeof(struct iphdr);
+		memcpy(dptr, sptr+sopt->cipso, optlen);
+		dptr += optlen;
+		dopt->optlen += optlen;
+	}
 	while (dopt->optlen & 3) {
 		*dptr++ = IPOPT_END;
 		dopt->optlen++;
@@ -435,6 +443,17 @@ int ip_options_compile(struct ip_options
 			if (optptr[2] == 0 && optptr[3] == 0)
 				opt->router_alert = optptr - iph;
 			break;
+		      case IPOPT_CIPSO:
+		        if (opt->cipso) {
+				pp_ptr = optptr;
+				goto error;
+			}
+			opt->cipso = optptr - iph;
+		        if (cipso_v4_validate(&optptr)) {
+				pp_ptr = optptr;
+				goto error;
+			}
+			break;
 		      case IPOPT_SEC:
 		      case IPOPT_SID:
 		      default:
Index: linux-2.6.17.i686-quilt/net/socket.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/net/socket.c
+++ linux-2.6.17.i686-quilt/net/socket.c
@@ -976,11 +976,18 @@ int sock_create_lite(int family, int typ
 		goto out;
 	}
 
-	security_socket_post_create(sock, family, type, protocol, 1);
 	sock->type = type;
+	err = security_socket_post_create(sock, family, type, protocol, 1);
+	if (err)
+		goto out_release;
+
 out:
 	*res = sock;
 	return err;
+out_release:
+	sock_release(sock);
+	sock = NULL;
+	goto out;
 }
 
 /* No kernel lock held - perfect */
@@ -1218,7 +1225,9 @@ static int __sock_create(int family, int
 	 */
 	module_put(net_families[family]->owner);
 	*res = sock;
-	security_socket_post_create(sock, family, type, protocol, kern);
+	err = security_socket_post_create(sock, family, type, protocol, kern);
+	if (err)
+		goto out_release;
 
 out:
 	net_family_read_unlock();
Index: linux-2.6.17.i686-quilt/security/dummy.c
===================================================================
--- linux-2.6.17.i686-quilt.orig/security/dummy.c
+++ linux-2.6.17.i686-quilt/security/dummy.c
@@ -692,10 +692,10 @@ static int dummy_socket_create (int fami
 	return 0;
 }
 
-static void dummy_socket_post_create (struct socket *sock, int family, int type,
-				      int protocol, int kern)
+static int dummy_socket_post_create (struct socket *sock, int family, int type,
+				     int protocol, int kern)
 {
-	return;
+	return 0;
 }
 
 static int dummy_socket_bind (struct socket *sock, struct sockaddr *address,
@@ -720,10 +720,10 @@ static int dummy_socket_accept (struct s
 	return 0;
 }
 
-static void dummy_socket_post_accept (struct socket *sock, 
-				      struct socket *newsock)
+static int dummy_socket_post_accept (struct socket *sock,
+				     struct socket *newsock)
 {
-	return;
+	return 0;
 }
 
 static int dummy_socket_sendmsg (struct socket *sock, struct msghdr *msg,

--
paul moore
linux security @ hp
