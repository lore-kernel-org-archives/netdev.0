From: James Morris <jmorris@namei.org>
Subject: [PATCH] SELinux: Add support for DCCP
Date: Mon, 13 Nov 2006 16:15:06 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611131612490.9577@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:8162 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S933049AbWKMVPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 16:15:09 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements SELinux kernel support for DCCP
(http://linux-net.osdl.org/index.php/DCCP), which is similar in operation
to TCP in terms of connected state between peers.

The SELinux support for DCCP is thus modeled on existing handling of TCP.

A new DCCP socket class is introduced, to allow protocol differentation.
The permissions for this class inherit all of the socket permissions, as
well as the current TCP permissions (node_bind, name_bind etc). IPv4 and
IPv6 are supported, although labeled networking is not, at this stage.

Patches for SELinux userspace are at:
http://people.redhat.com/jmorris/selinux/dccp/user/

I've performed some basic testing, and it seems to be working as expected.
Adding policy support is similar to TCP, the only real difference being
that it's a different protocol.

Please apply for 2.6.20.

Also available via git:
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-net-2.6.20.git

Acked-by: Stephen Smalley <sds@tycho.nsa.gov>
Signed-off-by: James Morris <jmorris@namei.org>

---

 security/selinux/hooks.c                     |   66 +++++++++++++++++++++++---
 security/selinux/include/av_inherit.h        |    1 
 security/selinux/include/av_perm_to_string.h |    8 +++
 security/selinux/include/av_permissions.h    |   32 +++++++++++++
 security/selinux/include/class_to_string.h   |    2 +
 security/selinux/include/flask.h             |    2 +
 6 files changed, 103 insertions(+), 8 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5846b34..07e174c 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -58,6 +58,7 @@ #include <linux/netdevice.h>	/* for netw
 #include <linux/netlink.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
+#include <linux/dccp.h>
 #include <linux/quota.h>
 #include <linux/un.h>		/* for Unix socket types */
 #include <net/af_unix.h>	/* for Unix socket types */
@@ -751,6 +752,8 @@ static inline u16 socket_type_to_securit
 				return SECCLASS_UDP_SOCKET;
 			else
 				return SECCLASS_RAWIP_SOCKET;
+		case SOCK_DCCP:
+			return SECCLASS_DCCP_SOCKET;
 		default:
 			return SECCLASS_RAWIP_SOCKET;
 		}
@@ -2943,6 +2946,22 @@ static int selinux_parse_skb_ipv4(struct
         	break;
         }
 
+	case IPPROTO_DCCP: {
+		struct dccp_hdr _dccph, *dh;
+
+		if (ntohs(ih->frag_off) & IP_OFFSET)
+			break;
+
+		offset += ihlen;
+		dh = skb_header_pointer(skb, offset, sizeof(_dccph), &_dccph);
+		if (dh == NULL)
+			break;
+
+		ad->u.net.sport = dh->dccph_sport;
+		ad->u.net.dport = dh->dccph_dport;
+		break;
+        }
+
         default:
         	break;
         }
@@ -3003,6 +3022,18 @@ static int selinux_parse_skb_ipv6(struct
 		break;
 	}
 
+	case IPPROTO_DCCP: {
+		struct dccp_hdr _dccph, *dh;
+
+		dh = skb_header_pointer(skb, offset, sizeof(_dccph), &_dccph);
+		if (dh == NULL)
+			break;
+
+		ad->u.net.sport = dh->dccph_sport;
+		ad->u.net.dport = dh->dccph_dport;
+		break;
+        }
+
 	/* includes fragments */
 	default:
 		break;
@@ -3187,7 +3218,11 @@ static int selinux_socket_bind(struct so
 		case SECCLASS_UDP_SOCKET:
 			node_perm = UDP_SOCKET__NODE_BIND;
 			break;
-			
+
+		case SECCLASS_DCCP_SOCKET:
+			node_perm = DCCP_SOCKET__NODE_BIND;
+			break;
+
 		default:
 			node_perm = RAWIP_SOCKET__NODE_BIND;
 			break;
@@ -3225,16 +3260,17 @@ static int selinux_socket_connect(struct
 		return err;
 
 	/*
-	 * If a TCP socket, check name_connect permission for the port.
+	 * If a TCP or DCCP socket, check name_connect permission for the port.
 	 */
 	isec = SOCK_INODE(sock)->i_security;
-	if (isec->sclass == SECCLASS_TCP_SOCKET) {
+	if (isec->sclass == SECCLASS_TCP_SOCKET ||
+	    isec->sclass == SECCLASS_DCCP_SOCKET) {
 		struct sock *sk = sock->sk;
 		struct avc_audit_data ad;
 		struct sockaddr_in *addr4 = NULL;
 		struct sockaddr_in6 *addr6 = NULL;
 		unsigned short snum;
-		u32 sid;
+		u32 sid, perm;
 
 		if (sk->sk_family == PF_INET) {
 			addr4 = (struct sockaddr_in *)address;
@@ -3253,11 +3289,13 @@ static int selinux_socket_connect(struct
 		if (err)
 			goto out;
 
+		perm = (isec->sclass == SECCLASS_TCP_SOCKET) ?
+		       TCP_SOCKET__NAME_CONNECT : DCCP_SOCKET__NAME_CONNECT;
+
 		AVC_AUDIT_DATA_INIT(&ad,NET);
 		ad.u.net.dport = htons(snum);
 		ad.u.net.family = sk->sk_family;
-		err = avc_has_perm(isec->sid, sid, isec->sclass,
-				   TCP_SOCKET__NAME_CONNECT, &ad);
+		err = avc_has_perm(isec->sid, sid, isec->sclass, perm, &ad);
 		if (err)
 			goto out;
 	}
@@ -3445,7 +3483,13 @@ static int selinux_sock_rcv_skb_compat(s
 		node_perm = NODE__TCP_RECV;
 		recv_perm = TCP_SOCKET__RECV_MSG;
 		break;
-	
+
+	case SECCLASS_DCCP_SOCKET:
+		netif_perm = NETIF__DCCP_RECV;
+		node_perm = NODE__DCCP_RECV;
+		recv_perm = DCCP_SOCKET__RECV_MSG;
+		break;
+
 	default:
 		netif_perm = NETIF__RAWIP_RECV;
 		node_perm = NODE__RAWIP_RECV;
@@ -3776,7 +3820,13 @@ static int selinux_ip_postroute_last_com
 		node_perm = NODE__TCP_SEND;
 		send_perm = TCP_SOCKET__SEND_MSG;
 		break;
-	
+
+	case SECCLASS_DCCP_SOCKET:
+		netif_perm = NETIF__DCCP_SEND;
+		node_perm = NODE__DCCP_SEND;
+		send_perm = DCCP_SOCKET__SEND_MSG;
+		break;
+
 	default:
 		netif_perm = NETIF__RAWIP_SEND;
 		node_perm = NODE__RAWIP_SEND;
diff --git a/security/selinux/include/av_inherit.h b/security/selinux/include/av_inherit.h
index a68fdd5..8377a4b 100644
--- a/security/selinux/include/av_inherit.h
+++ b/security/selinux/include/av_inherit.h
@@ -30,3 +30,4 @@
    S_(SECCLASS_NETLINK_DNRT_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_APPLETALK_SOCKET, socket, 0x00400000UL)
+   S_(SECCLASS_DCCP_SOCKET, socket, 0x00400000UL)
diff --git a/security/selinux/include/av_perm_to_string.h b/security/selinux/include/av_perm_to_string.h
index 09fc8a2..ad9fb2d 100644
--- a/security/selinux/include/av_perm_to_string.h
+++ b/security/selinux/include/av_perm_to_string.h
@@ -35,12 +35,16 @@
    S_(SECCLASS_NODE, NODE__RAWIP_RECV, "rawip_recv")
    S_(SECCLASS_NODE, NODE__RAWIP_SEND, "rawip_send")
    S_(SECCLASS_NODE, NODE__ENFORCE_DEST, "enforce_dest")
+   S_(SECCLASS_NODE, NODE__DCCP_RECV, "dccp_recv")
+   S_(SECCLASS_NODE, NODE__DCCP_SEND, "dccp_send")
    S_(SECCLASS_NETIF, NETIF__TCP_RECV, "tcp_recv")
    S_(SECCLASS_NETIF, NETIF__TCP_SEND, "tcp_send")
    S_(SECCLASS_NETIF, NETIF__UDP_RECV, "udp_recv")
    S_(SECCLASS_NETIF, NETIF__UDP_SEND, "udp_send")
    S_(SECCLASS_NETIF, NETIF__RAWIP_RECV, "rawip_recv")
    S_(SECCLASS_NETIF, NETIF__RAWIP_SEND, "rawip_send")
+   S_(SECCLASS_NETIF, NETIF__DCCP_RECV, "dccp_recv")
+   S_(SECCLASS_NETIF, NETIF__DCCP_SEND, "dccp_send")
    S_(SECCLASS_UNIX_STREAM_SOCKET, UNIX_STREAM_SOCKET__CONNECTTO, "connectto")
    S_(SECCLASS_UNIX_STREAM_SOCKET, UNIX_STREAM_SOCKET__NEWCONN, "newconn")
    S_(SECCLASS_UNIX_STREAM_SOCKET, UNIX_STREAM_SOCKET__ACCEPTFROM, "acceptfrom")
@@ -252,3 +256,7 @@
    S_(SECCLASS_KEY, KEY__LINK, "link")
    S_(SECCLASS_KEY, KEY__SETATTR, "setattr")
    S_(SECCLASS_KEY, KEY__CREATE, "create")
+   S_(SECCLASS_CONTEXT, CONTEXT__TRANSLATE, "translate")
+   S_(SECCLASS_CONTEXT, CONTEXT__CONTAINS, "contains")
+   S_(SECCLASS_DCCP_SOCKET, DCCP_SOCKET__NODE_BIND, "node_bind")
+   S_(SECCLASS_DCCP_SOCKET, DCCP_SOCKET__NAME_CONNECT, "name_connect")
diff --git a/security/selinux/include/av_permissions.h b/security/selinux/include/av_permissions.h
index 81f4f52..2de4b5f 100644
--- a/security/selinux/include/av_permissions.h
+++ b/security/selinux/include/av_permissions.h
@@ -312,6 +312,8 @@ #define NODE__UDP_SEND                  
 #define NODE__RAWIP_RECV                          0x00000010UL
 #define NODE__RAWIP_SEND                          0x00000020UL
 #define NODE__ENFORCE_DEST                        0x00000040UL
+#define NODE__DCCP_RECV                           0x00000080UL
+#define NODE__DCCP_SEND                           0x00000100UL
 
 #define NETIF__TCP_RECV                           0x00000001UL
 #define NETIF__TCP_SEND                           0x00000002UL
@@ -319,6 +321,8 @@ #define NETIF__UDP_RECV                 
 #define NETIF__UDP_SEND                           0x00000008UL
 #define NETIF__RAWIP_RECV                         0x00000010UL
 #define NETIF__RAWIP_SEND                         0x00000020UL
+#define NETIF__DCCP_RECV                          0x00000040UL
+#define NETIF__DCCP_SEND                          0x00000080UL
 
 #define NETLINK_SOCKET__IOCTL                     0x00000001UL
 #define NETLINK_SOCKET__READ                      0x00000002UL
@@ -970,3 +974,31 @@ #define KEY__SEARCH                     
 #define KEY__LINK                                 0x00000010UL
 #define KEY__SETATTR                              0x00000020UL
 #define KEY__CREATE                               0x00000040UL
+
+#define CONTEXT__TRANSLATE                        0x00000001UL
+#define CONTEXT__CONTAINS                         0x00000002UL
+
+#define DCCP_SOCKET__IOCTL                        0x00000001UL
+#define DCCP_SOCKET__READ                         0x00000002UL
+#define DCCP_SOCKET__WRITE                        0x00000004UL
+#define DCCP_SOCKET__CREATE                       0x00000008UL
+#define DCCP_SOCKET__GETATTR                      0x00000010UL
+#define DCCP_SOCKET__SETATTR                      0x00000020UL
+#define DCCP_SOCKET__LOCK                         0x00000040UL
+#define DCCP_SOCKET__RELABELFROM                  0x00000080UL
+#define DCCP_SOCKET__RELABELTO                    0x00000100UL
+#define DCCP_SOCKET__APPEND                       0x00000200UL
+#define DCCP_SOCKET__BIND                         0x00000400UL
+#define DCCP_SOCKET__CONNECT                      0x00000800UL
+#define DCCP_SOCKET__LISTEN                       0x00001000UL
+#define DCCP_SOCKET__ACCEPT                       0x00002000UL
+#define DCCP_SOCKET__GETOPT                       0x00004000UL
+#define DCCP_SOCKET__SETOPT                       0x00008000UL
+#define DCCP_SOCKET__SHUTDOWN                     0x00010000UL
+#define DCCP_SOCKET__RECVFROM                     0x00020000UL
+#define DCCP_SOCKET__SENDTO                       0x00040000UL
+#define DCCP_SOCKET__RECV_MSG                     0x00080000UL
+#define DCCP_SOCKET__SEND_MSG                     0x00100000UL
+#define DCCP_SOCKET__NAME_BIND                    0x00200000UL
+#define DCCP_SOCKET__NODE_BIND                    0x00400000UL
+#define DCCP_SOCKET__NAME_CONNECT                 0x00800000UL
diff --git a/security/selinux/include/class_to_string.h b/security/selinux/include/class_to_string.h
index 24303b6..9f3ebb1 100644
--- a/security/selinux/include/class_to_string.h
+++ b/security/selinux/include/class_to_string.h
@@ -61,3 +61,5 @@
     S_("appletalk_socket")
     S_("packet")
     S_("key")
+    S_("context")
+    S_("dccp_socket")
diff --git a/security/selinux/include/flask.h b/security/selinux/include/flask.h
index 95887ae..67cef37 100644
--- a/security/selinux/include/flask.h
+++ b/security/selinux/include/flask.h
@@ -63,6 +63,8 @@ #define SECCLASS_NETLINK_KOBJECT_UEVENT_
 #define SECCLASS_APPLETALK_SOCKET                        56
 #define SECCLASS_PACKET                                  57
 #define SECCLASS_KEY                                     58
+#define SECCLASS_CONTEXT                                 59
+#define SECCLASS_DCCP_SOCKET                             60
 
 /*
  * Security identifier indices for initial entities
-- 
1.4.2.1

