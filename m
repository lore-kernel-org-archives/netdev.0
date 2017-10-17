From: Richard Haines <richard_c_haines@btinternet.com>
Subject: [RFC PATCH 5/5] selinux: Add SCTP support
Date: Tue, 17 Oct 2017 14:59:53 +0100
Message-ID: <20171017135953.4419-1-richard_c_haines@btinternet.com>
Cc: paul@paul-moore.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
        sds@tycho.nsa.gov, eparis@parisplace.org,
        marcelo.leitner@gmail.com,
        Richard Haines <richard_c_haines@btinternet.com>
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgout0104.bt.lon5.cpcloud.co.uk ([65.20.0.124]:37331 "EHLO
        rgout01.bt.lon5.cpcloud.co.uk" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758741AbdJQOAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 10:00:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SELinux SCTP implementation is explained in:
Documentation/security/SELinux-sctp.txt

Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
---
 Documentation/security/SELinux-sctp.txt | 108 +++++++++++++
 security/selinux/hooks.c                | 268 ++++++++++++++++++++++++++++++--
 security/selinux/include/classmap.h     |   3 +-
 security/selinux/include/netlabel.h     |   9 +-
 security/selinux/include/objsec.h       |   5 +
 security/selinux/netlabel.c             |  52 ++++++-
 6 files changed, 427 insertions(+), 18 deletions(-)
 create mode 100644 Documentation/security/SELinux-sctp.txt

diff --git a/Documentation/security/SELinux-sctp.txt b/Documentation/security/SELinux-sctp.txt
new file mode 100644
index 0000000..32e0255
--- /dev/null
+++ b/Documentation/security/SELinux-sctp.txt
@@ -0,0 +1,108 @@
+                               SCTP SELinux Support
+                              ======================
+
+Security Hooks
+===============
+
+The Documentation/security/LSM-sctp.txt document describes how the following
+sctp security hooks are utilised:
+    security_sctp_assoc_request()
+    security_sctp_bind_connect()
+    security_sctp_sk_clone()
+
+    security_inet_conn_established()
+
+
+Policy Statements
+==================
+The following class and permissions to support SCTP are available within the
+kernel:
+    class sctp_socket inherits socket { node_bind }
+
+whenever the following policy capability is enabled:
+    policycap extended_socket_class;
+
+The SELinux SCTP support adds the additional permissions that are explained
+in the sections below:
+    association bindx connectx
+
+If userspace tools have been updated, SCTP will support the portcon
+statement as shown in the following example:
+    portcon sctp 1024-1036 system_u:object_r:sctp_ports_t:s0
+
+
+SCTP Bind, Connect and ASCONF Chunk Parameter Permission Checks
+================================================================
+The hook security_sctp_bind_connect() is called by SCTP to check permissions
+required for ipv4/ipv6 addresses based on the @optname as follows:
+
+  ------------------------------------------------------------------
+  |                      BINDX Permission Check                    |
+  |       @optname             |         @address contains         |
+  |----------------------------|-----------------------------------|
+  | SCTP_SOCKOPT_BINDX_ADD     | One or more ipv4 / ipv6 addresses |
+  ------------------------------------------------------------------
+
+  ------------------------------------------------------------------
+  |                  BIND Permission Checks                        |
+  |       @optname             |         @address contains         |
+  |----------------------------|-----------------------------------|
+  | SCTP_PRIMARY_ADDR          | Single ipv4 or ipv6 address       |
+  | SCTP_SET_PEER_PRIMARY_ADDR | Single ipv4 or ipv6 address       |
+  ------------------------------------------------------------------
+
+  ------------------------------------------------------------------
+  |                 CONNECTX Permission Check                      |
+  |       @optname             |         @address contains         |
+  |----------------------------|-----------------------------------|
+  | SCTP_SOCKOPT_CONNECTX      | One or more ipv4 / ipv6 addresses |
+  ------------------------------------------------------------------
+
+  ------------------------------------------------------------------
+  |                 CONNECT Permission Checks                      |
+  |       @optname             |         @address contains         |
+  |----------------------------|-----------------------------------|
+  | SCTP_SENDMSG_CONNECT       | Single ipv4 or ipv6 address       |
+  | SCTP_PARAM_ADD_IP          | One or more ipv4 / ipv6 addresses |
+  | SCTP_PARAM_SET_PRIMARY     | Single ipv4 or ipv6 address       |
+  ------------------------------------------------------------------
+
+SCTP Peer Labeling
+===================
+An SCTP socket will only have one peer label assigned to it. This will be
+assigned during the establishment of the first association. Once the peer
+label has been assigned, any new associations will have the "association"
+permission validated by checking the socket peer sid against the received
+packets peer sid to determine whether the association should be allowed or
+denied.
+
+NOTES:
+   1) If peer labeling is not enabled, then the peer context will always be
+      SECINITSID_UNLABELED (unlabeled_t in Reference Policy).
+
+   2) As SCTP supports multiple endpoints with multi-homing on a single socket
+      it is recommended that peer labels are consistent.
+
+   3) getpeercon(3) may be used by userspace to retrieve the sockets peer
+       context.
+
+   4) If using NetLabel be aware that if a label is assigned to a specific
+      interface, and that interface 'goes down', then the NetLabel service
+      will remove the entry. Therefore ensure that the network startup scripts
+      call netlabelctl(8) to set the required label (see netlabel-config(8)
+      helper script for details).
+
+   5) The NetLabel SCTP peer labeling rules apply as discussed in the following
+      set of posts tagged "netlabel" at: http://www.paul-moore.com/blog/t.
+
+   6) CIPSO is only supported for IPv4 addressing: socket(AF_INET, ...)
+      CALIPSO is only supported for IPv6 addressing: socket(AF_INET6, ...)
+
+      Note the following when testing CIPSO/CALIPSO:
+         a) CIPSO will send an ICMP packet if an SCTP packet cannot be
+            delivered because of an invalid label.
+         b) CALIPSO does not send an ICMP packet, just silently discards it.
+
+   7) IPSEC is not supported as rfc3554 - sctp/ipsec support has not been
+      implemented in userspace (racoon(8) or ipsec_pluto(8)), although the
+      kernel supports SCTP/IPSEC.
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 33fd061..c3e9600 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -67,6 +67,8 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/dccp.h>
+#include <linux/sctp.h>
+#include <net/sctp/structs.h>
 #include <linux/quota.h>
 #include <linux/un.h>		/* for Unix socket types */
 #include <net/af_unix.h>	/* for Unix socket types */
@@ -4119,6 +4121,23 @@ static int selinux_parse_skb_ipv4(struct sk_buff *skb,
 		break;
 	}
 
+#if IS_ENABLED(CONFIG_IP_SCTP)
+	case IPPROTO_SCTP: {
+		struct sctphdr _sctph, *sh;
+
+		if (ntohs(ih->frag_off) & IP_OFFSET)
+			break;
+
+		offset += ihlen;
+		sh = skb_header_pointer(skb, offset, sizeof(_sctph), &_sctph);
+		if (sh == NULL)
+			break;
+
+		ad->u.net->sport = sh->source;
+		ad->u.net->dport = sh->dest;
+		break;
+	}
+#endif
 	default:
 		break;
 	}
@@ -4192,6 +4211,19 @@ static int selinux_parse_skb_ipv6(struct sk_buff *skb,
 		break;
 	}
 
+#if IS_ENABLED(CONFIG_IP_SCTP)
+	case IPPROTO_SCTP: {
+		struct sctphdr _sctph, *sh;
+
+		sh = skb_header_pointer(skb, offset, sizeof(_sctph), &_sctph);
+		if (sh == NULL)
+			break;
+
+		ad->u.net->sport = sh->source;
+		ad->u.net->dport = sh->dest;
+		break;
+	}
+#endif
 	/* includes fragments */
 	default:
 		break;
@@ -4381,6 +4413,10 @@ static int selinux_socket_post_create(struct socket *sock, int family,
 		sksec = sock->sk->sk_security;
 		sksec->sclass = sclass;
 		sksec->sid = sid;
+		/* Allows detection of the first association on this socket */
+		if (sksec->sclass == SECCLASS_SCTP_SOCKET)
+			sksec->sctp_assoc_state = SCTP_ASSOC_UNSET;
+
 		err = selinux_netlbl_socket_post_create(sock->sk, family);
 	}
 
@@ -4401,11 +4437,7 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 	if (err)
 		goto out;
 
-	/*
-	 * If PF_INET or PF_INET6, check name_bind permission for the port.
-	 * Multiple address binding for SCTP is not supported yet: we just
-	 * check the first address now.
-	 */
+	/* If PF_INET or PF_INET6, check name_bind permission for the port. */
 	family = sk->sk_family;
 	if (family == PF_INET || family == PF_INET6) {
 		char *addrp;
@@ -4417,7 +4449,13 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 		unsigned short snum;
 		u32 sid, node_perm;
 
-		if (family == PF_INET) {
+		/*
+		 * sctp_bindx(3) calls via selinux_sctp_bind_connect()
+		 * that validates multiple binding addresses. Because of this
+		 * need to check address->sa_family as it is possible to have
+		 * sk->sk_family = PF_INET6 with addr->sa_family = AF_INET.
+		 */
+		if (family == PF_INET || address->sa_family == AF_INET) {
 			if (addrlen < sizeof(struct sockaddr_in)) {
 				err = -EINVAL;
 				goto out;
@@ -4471,6 +4509,10 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 			node_perm = DCCP_SOCKET__NODE_BIND;
 			break;
 
+		case SECCLASS_SCTP_SOCKET:
+			node_perm = SCTP_SOCKET__NODE_BIND;
+			break;
+
 		default:
 			node_perm = RAWIP_SOCKET__NODE_BIND;
 			break;
@@ -4485,7 +4527,7 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 		ad.u.net->sport = htons(snum);
 		ad.u.net->family = family;
 
-		if (family == PF_INET)
+		if (family == PF_INET || address->sa_family == AF_INET)
 			ad.u.net->v4info.saddr = addr4->sin_addr.s_addr;
 		else
 			ad.u.net->v6info.saddr = addr6->sin6_addr;
@@ -4510,10 +4552,12 @@ static int selinux_socket_connect(struct socket *sock, struct sockaddr *address,
 		return err;
 
 	/*
-	 * If a TCP or DCCP socket, check name_connect permission for the port.
+	 * If a TCP, DCCP or SCTP socket, check name_connect permission
+	 * for the port.
 	 */
 	if (sksec->sclass == SECCLASS_TCP_SOCKET ||
-	    sksec->sclass == SECCLASS_DCCP_SOCKET) {
+	    sksec->sclass == SECCLASS_DCCP_SOCKET ||
+	    sksec->sclass == SECCLASS_SCTP_SOCKET) {
 		struct common_audit_data ad;
 		struct lsm_network_audit net = {0,};
 		struct sockaddr_in *addr4 = NULL;
@@ -4521,7 +4565,14 @@ static int selinux_socket_connect(struct socket *sock, struct sockaddr *address,
 		unsigned short snum;
 		u32 sid, perm;
 
-		if (sk->sk_family == PF_INET) {
+		/* sctp_connectx(3) calls via
+		 *selinux_sctp_bind_connect() that validates multiple
+		 * connect addresses. Because of this need to check
+		 * address->sa_family as it is possible to have
+		 * sk->sk_family = PF_INET6 with addr->sa_family = AF_INET.
+		 */
+		if (sk->sk_family == PF_INET ||
+					address->sa_family == AF_INET) {
 			addr4 = (struct sockaddr_in *)address;
 			if (addrlen < sizeof(struct sockaddr_in))
 				return -EINVAL;
@@ -4534,11 +4585,21 @@ static int selinux_socket_connect(struct socket *sock, struct sockaddr *address,
 		}
 
 		err = sel_netport_sid(sk->sk_protocol, snum, &sid);
+
 		if (err)
 			goto out;
 
-		perm = (sksec->sclass == SECCLASS_TCP_SOCKET) ?
-		       TCP_SOCKET__NAME_CONNECT : DCCP_SOCKET__NAME_CONNECT;
+		switch (sksec->sclass) {
+		case SECCLASS_TCP_SOCKET:
+			perm = TCP_SOCKET__NAME_CONNECT;
+			break;
+		case SECCLASS_DCCP_SOCKET:
+			perm = DCCP_SOCKET__NAME_CONNECT;
+			break;
+		case SECCLASS_SCTP_SOCKET:
+			perm = SCTP_SOCKET__NAME_CONNECT;
+			break;
+		}
 
 		ad.type = LSM_AUDIT_DATA_NET;
 		ad.u.net = &net;
@@ -4815,7 +4876,8 @@ static int selinux_socket_getpeersec_stream(struct socket *sock, char __user *op
 	u32 peer_sid = SECSID_NULL;
 
 	if (sksec->sclass == SECCLASS_UNIX_STREAM_SOCKET ||
-	    sksec->sclass == SECCLASS_TCP_SOCKET)
+	    sksec->sclass == SECCLASS_TCP_SOCKET ||
+	    sksec->sclass == SECCLASS_SCTP_SOCKET)
 		peer_sid = sksec->peer_sid;
 	if (peer_sid == SECSID_NULL)
 		return -ENOPROTOOPT;
@@ -4928,6 +4990,183 @@ static void selinux_sock_graft(struct sock *sk, struct socket *parent)
 	sksec->sclass = isec->sclass;
 }
 
+/* Called whenever SCTP receives an INIT or INIT_ACK chunk */
+static int selinux_sctp_assoc_request(struct sctp_endpoint *ep,
+				      struct sk_buff *skb,
+				      int sctp_cid)
+{
+	struct sk_security_struct *sksec = ep->base.sk->sk_security;
+	struct common_audit_data ad;
+	struct lsm_network_audit net = {0,};
+	u8 peerlbl_active;
+	u32 peer_sid = SECINITSID_UNLABELED;
+	u32 conn_sid;
+	int err;
+
+	if (!selinux_policycap_extsockclass)
+		return 0;
+
+	peerlbl_active = selinux_peerlbl_enabled();
+
+	if (peerlbl_active) {
+		/* This will return peer_sid = SECSID_NULL if there are
+		 * no peer labels, see security_net_peersid_resolve().
+		 */
+		err = selinux_skb_peerlbl_sid(skb, ep->base.sk->sk_family,
+					      &peer_sid);
+
+		if (err)
+			return err;
+
+		if (peer_sid == SECSID_NULL)
+			peer_sid = SECINITSID_UNLABELED;
+	}
+
+	if (sksec->sctp_assoc_state == SCTP_ASSOC_UNSET) {
+		sksec->sctp_assoc_state = SCTP_ASSOC_SET;
+
+		/* Here as first association on socket. As the peer SID
+		 * was allowed by peer recv (and the netif/node checks),
+		 * then it is approved by policy and used as the primary
+		 * peer SID for getpeercon(3).
+		 */
+		sksec->peer_sid = peer_sid;
+	} else if  (sksec->peer_sid != peer_sid) {
+		/* Other association peer SIDs are checked to enforce
+		 * consistency among the peer SIDs.
+		 */
+		ad.type = LSM_AUDIT_DATA_NET;
+		ad.u.net = &net;
+		ad.u.net->sk = ep->base.sk;
+		err = avc_has_perm(sksec->peer_sid, peer_sid, sksec->sclass,
+				   SCTP_SOCKET__ASSOCIATION, &ad);
+		if (err)
+			return err;
+	}
+
+	if (sctp_cid == SCTP_CID_INIT) {
+		/* Have INIT when incoming connect(2), sctp_connectx(3)
+		 * or sctp_sendmsg(3) (with no association already present),
+		 * so compute the MLS component for the connection and store
+		 * the information in ep. This will be used by SCTP TCP type
+		 * sockets and peeled off connections as they cause a new
+		 * socket to be generated. selinux_sctp_sk_clone() will then
+		 * plug this into the new socket.
+		 */
+		err = selinux_conn_sid(sksec->sid, peer_sid, &conn_sid);
+		if (err)
+			return err;
+
+		ep->secid = conn_sid;
+		ep->peer_secid = peer_sid;
+
+		/* Set any NetLabel labels including CIPSO/CALIPSO options. */
+		return selinux_netlbl_sctp_assoc_request(ep, skb);
+	}
+
+	return 0;
+}
+
+/*
+ * Check if sctp IPv4/IPv6 addresses are valid for binding or connecting
+ * based on their @optname.
+ */
+static int selinux_sctp_bind_connect(struct sock *sk, int optname,
+				     struct sockaddr *address,
+				     int addrlen)
+{
+	int len, err = 0, walk_size = 0;
+	void *addr_buf;
+	struct sockaddr *addr;
+	struct socket *sock;
+
+	if (!selinux_policycap_extsockclass)
+		return 0;
+
+	switch (optname) {
+	case SCTP_SOCKOPT_BINDX_ADD:
+		err = sock_has_perm(sk, SCTP_SOCKET__BINDX);
+		break;
+	case SCTP_SOCKOPT_CONNECTX:
+		err = sock_has_perm(sk, SCTP_SOCKET__CONNECTX);
+		break;
+	/* These need SOCKET__BIND or SOCKET__CONNECT permissions that will
+	 * be checked later.
+	 */
+	case SCTP_PRIMARY_ADDR:
+	case SCTP_SET_PEER_PRIMARY_ADDR:
+	case SCTP_PARAM_SET_PRIMARY:
+	case SCTP_PARAM_ADD_IP:
+	case SCTP_SENDMSG_CONNECT:
+		break;
+	default:
+		err = -EINVAL;
+	}
+	if (err)
+		return err;
+
+	/* Process one or more addresses that may be IPv4 or IPv6 */
+	sock = sk->sk_socket;
+	addr_buf = address;
+
+	while (walk_size < addrlen) {
+		addr = addr_buf;
+		switch (addr->sa_family) {
+		case AF_INET:
+			len = sizeof(struct sockaddr_in);
+			break;
+		case AF_INET6:
+			len = sizeof(struct sockaddr_in6);
+			break;
+		default:
+			return -EAFNOSUPPORT;
+		}
+
+		err = -EINVAL;
+		switch (optname) {
+		/* Bind checks */
+		case SCTP_PRIMARY_ADDR:
+		case SCTP_SET_PEER_PRIMARY_ADDR:
+		case SCTP_SOCKOPT_BINDX_ADD:
+			err = selinux_socket_bind(sock, addr, len);
+			break;
+		/* Connect checks */
+		case SCTP_SOCKOPT_CONNECTX:
+		case SCTP_PARAM_SET_PRIMARY:
+		case SCTP_PARAM_ADD_IP:
+		case SCTP_SENDMSG_CONNECT:
+			err = selinux_socket_connect(sock, addr, len);
+			break;
+		}
+
+		if (err)
+			return err;
+
+		addr_buf += len;
+		walk_size += len;
+	}
+	return 0;
+}
+
+/* Called whenever a new socket is created by accept(2) or sctp_peeloff(3). */
+static void selinux_sctp_sk_clone(struct sctp_endpoint *ep, struct sock *sk,
+				  struct sock *newsk)
+{
+	struct sk_security_struct *sksec = sk->sk_security;
+	struct sk_security_struct *newsksec = newsk->sk_security;
+
+	/* If policy does not support SECCLASS_SCTP_SOCKET then call
+	 * the non-sctp clone version.
+	 */
+	if (!selinux_policycap_extsockclass)
+		return selinux_sk_clone_security(sk, newsk);
+
+	newsksec->sid = ep->secid;
+	newsksec->peer_sid = ep->peer_secid;
+	newsksec->sclass = sksec->sclass;
+	newsksec->nlbl_state = sksec->nlbl_state;
+}
+
 static int selinux_inet_conn_request(struct sock *sk, struct sk_buff *skb,
 				     struct request_sock *req)
 {
@@ -6416,6 +6655,9 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(sk_clone_security, selinux_sk_clone_security),
 	LSM_HOOK_INIT(sk_getsecid, selinux_sk_getsecid),
 	LSM_HOOK_INIT(sock_graft, selinux_sock_graft),
+	LSM_HOOK_INIT(sctp_assoc_request, selinux_sctp_assoc_request),
+	LSM_HOOK_INIT(sctp_sk_clone, selinux_sctp_sk_clone),
+	LSM_HOOK_INIT(sctp_bind_connect, selinux_sctp_bind_connect),
 	LSM_HOOK_INIT(inet_conn_request, selinux_inet_conn_request),
 	LSM_HOOK_INIT(inet_csk_clone, selinux_inet_csk_clone),
 	LSM_HOOK_INIT(inet_conn_established, selinux_inet_conn_established),
diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
index b9fe343..b4b10da 100644
--- a/security/selinux/include/classmap.h
+++ b/security/selinux/include/classmap.h
@@ -173,7 +173,8 @@ struct security_class_mapping secclass_map[] = {
 	  { COMMON_CAP2_PERMS, NULL } },
 	{ "sctp_socket",
 	  { COMMON_SOCK_PERMS,
-	    "node_bind", NULL } },
+	    "node_bind", "name_connect", "association", "bindx",
+	    "connectx", NULL } },
 	{ "icmp_socket",
 	  { COMMON_SOCK_PERMS,
 	    "node_bind", NULL } },
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index 75686d5..835a0d6 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -33,6 +33,7 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/request_sock.h>
+#include <net/sctp/structs.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -53,7 +54,8 @@ int selinux_netlbl_skbuff_getsid(struct sk_buff *skb,
 int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 				 u16 family,
 				 u32 sid);
-
+int selinux_netlbl_sctp_assoc_request(struct sctp_endpoint *ep,
+				     struct sk_buff *skb);
 int selinux_netlbl_inet_conn_request(struct request_sock *req, u16 family);
 void selinux_netlbl_inet_csk_clone(struct sock *sk, u16 family);
 int selinux_netlbl_socket_post_create(struct sock *sk, u16 family);
@@ -114,6 +116,11 @@ static inline int selinux_netlbl_conn_setsid(struct sock *sk,
 	return 0;
 }
 
+static inline int selinux_netlbl_sctp_assoc_request(struct sctp_endpoint *ep,
+						    struct sk_buff *skb)
+{
+	return 0;
+}
 static inline int selinux_netlbl_inet_conn_request(struct request_sock *req,
 						   u16 family)
 {
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 6ebc61e..660f270 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -130,6 +130,11 @@ struct sk_security_struct {
 	u32 sid;			/* SID of this object */
 	u32 peer_sid;			/* SID of peer */
 	u16 sclass;			/* sock security class */
+
+	enum {				/* SCTP association state */
+		SCTP_ASSOC_UNSET = 0,
+		SCTP_ASSOC_SET,
+	} sctp_assoc_state;
 };
 
 struct tun_security_struct {
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index aaba667..7d5aa15 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -250,6 +250,7 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 	sk = skb_to_full_sk(skb);
 	if (sk != NULL) {
 		struct sk_security_struct *sksec = sk->sk_security;
+
 		if (sksec->nlbl_state != NLBL_REQSKB)
 			return 0;
 		secattr = selinux_netlbl_sock_getattr(sk, sid);
@@ -271,6 +272,41 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 }
 
 /**
+ * selinux_netlbl_sctp_assoc_request - Label an incoming sctp association.
+ * @ep: incoming association endpoint.
+ * @skb: the packet.
+ *
+ * Description:
+ * A new incoming connection is represented by @ep, ......
+ * Returns zero on success, negative values on failure.
+ *
+ */
+int selinux_netlbl_sctp_assoc_request(struct sctp_endpoint *ep,
+				     struct sk_buff *skb)
+{
+	int rc;
+	struct netlbl_lsm_secattr secattr;
+	struct sk_security_struct *sksec = ep->base.sk->sk_security;
+
+	if (ep->base.sk->sk_family != PF_INET &&
+				ep->base.sk->sk_family != PF_INET6)
+		return 0;
+
+	netlbl_secattr_init(&secattr);
+	rc = security_netlbl_sid_to_secattr(ep->secid, &secattr);
+	if (rc != 0)
+		goto assoc_request_return;
+
+	rc = netlbl_sctp_setattr(ep->base.sk, skb, &secattr);
+	if (rc == 0)
+		sksec->nlbl_state = NLBL_LABELED;
+
+assoc_request_return:
+	netlbl_secattr_destroy(&secattr);
+	return rc;
+}
+
+/**
  * selinux_netlbl_inet_conn_request - Label an incoming stream connection
  * @req: incoming connection request socket
  *
@@ -481,7 +517,7 @@ int selinux_netlbl_socket_setsockopt(struct socket *sock,
  */
 int selinux_netlbl_socket_connect(struct sock *sk, struct sockaddr *addr)
 {
-	int rc;
+	int rc, already_owned_by_user = 0;
 	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr *secattr;
 
@@ -489,7 +525,16 @@ int selinux_netlbl_socket_connect(struct sock *sk, struct sockaddr *addr)
 	    sksec->nlbl_state != NLBL_CONNLABELED)
 		return 0;
 
-	lock_sock(sk);
+	/* Note: When called via connect(2) this happens before the socket
+	 * protocol layer connect operation and @sk is not locked, HOWEVER,
+	 * when called by the SCTP protocol layer via sctp_connectx(3),
+	 * sctp_sendmsg(3) or sendmsg(2), @sk is locked. Therefore check if
+	 * @sk owned already.
+	 */
+	if (sock_owned_by_user(sk) && sksec->sclass == SECCLASS_SCTP_SOCKET)
+		already_owned_by_user = 1;
+	else
+		lock_sock(sk);
 
 	/* connected sockets are allowed to disconnect when the address family
 	 * is set to AF_UNSPEC, if that is what is happening we want to reset
@@ -510,6 +555,7 @@ int selinux_netlbl_socket_connect(struct sock *sk, struct sockaddr *addr)
 		sksec->nlbl_state = NLBL_CONNLABELED;
 
 socket_connect_return:
-	release_sock(sk);
+	if (!already_owned_by_user)
+		release_sock(sk);
 	return rc;
 }
-- 
2.13.6
