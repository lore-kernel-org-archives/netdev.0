From: Richard Haines <richard_c_haines@btinternet.com>
Subject: [RFC PATCH 1/5] security: Add support for SCTP security hooks
Date: Tue, 17 Oct 2017 15:02:47 +0100
Message-ID: <20171017140247.4604-1-richard_c_haines@btinternet.com>
Cc: paul@paul-moore.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
        sds@tycho.nsa.gov, eparis@parisplace.org,
        marcelo.leitner@gmail.com,
        Richard Haines <richard_c_haines@btinternet.com>
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgout0701.bt.lon5.cpcloud.co.uk ([65.20.0.141]:61836 "EHLO
        rgout0701.bt.lon5.cpcloud.co.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755269AbdJQODS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 10:03:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SCTP security hooks are explained in:
Documentation/security/LSM-sctp.txt

Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
---
 Documentation/security/LSM-sctp.txt | 212 ++++++++++++++++++++++++++++++++++++
 include/linux/lsm_hooks.h           |  37 +++++++
 include/linux/security.h            |  27 +++++
 security/security.c                 |  23 ++++
 4 files changed, 299 insertions(+)
 create mode 100644 Documentation/security/LSM-sctp.txt

diff --git a/Documentation/security/LSM-sctp.txt b/Documentation/security/LSM-sctp.txt
new file mode 100644
index 0000000..30fe9b5
--- /dev/null
+++ b/Documentation/security/LSM-sctp.txt
@@ -0,0 +1,212 @@
+                               SCTP LSM Support
+                              ==================
+
+For security module support, three sctp specific hooks have been implemented:
+    security_sctp_assoc_request()
+    security_sctp_bind_connect()
+    security_sctp_sk_clone()
+
+Also the following security hook has been utilised:
+    security_inet_conn_established()
+
+The usage of these hooks are described below with the SELinux implementation
+described in Documentation/security/SELinux-sctp.txt
+
+
+security_sctp_assoc_request()
+------------------------------
+This new hook has been added to net/sctp/sm_statefuns.c where it passes the
+@ep and @chunk->skb (the association INIT or INIT ACK packet) to the security
+module. Returns 0 on success, error on failure.
+
+    @ep - pointer to sctp endpoint structure.
+    @skb - pointer to skbuff of association packet.
+    @sctp_cid - set to sctp packet type (SCTP_CID_INIT or SCTP_CID_INIT_ACK).
+
+The security module performs the following operations:
+  1) If this is the first association on @ep->base.sk, then set the peer sid
+     to that in @skb. This will ensure there is only one peer sid assigned
+     to @ep->base.sk that may support multiple associations.
+
+  2) If not the first association, validate the @ep->base.sk peer_sid against
+     the @skb peer sid to determine whether the association should be allowed
+     or denied.
+
+  3) If @sctp_cid = SCTP_CID_INIT, then set the sctp @ep sid to socket's sid
+     (from ep->base.sk) with MLS portion taken from @skb peer sid. This will
+     only be used by SCTP TCP style sockets and peeled off connections as they
+     cause a new socket to be generated.
+
+     If IP security options are configured (CIPSO/CALIPSO), then the ip options
+     are set on the socket.
+
+     To support this hook include/net/sctp/structs.h "struct sctp_endpoint"
+     has been updated with the following:
+
+	/* Security identifiers from incoming (INIT). These are set by
+	 * security_sctp_assoc_request(). These will only be used by
+	 * SCTP TCP type sockets and peeled off connections as they
+	 * cause a new socket to be generated. security_sctp_sk_clone()
+	 * will then plug these into the new socket.
+	 */
+	u32 secid;
+	u32 peer_secid;
+
+
+security_sctp_bind_connect()
+-----------------------------
+This new hook has been added to net/sctp/socket.c and net/sctp/sm_make_chunk.c.
+It passes one or more ipv4/ipv6 addresses to the security module for
+validation based on the @optname that will result in either a bind or connect
+service as shown in the permission check tables below.
+Returns 0 on success, error on failure.
+
+    @sk      - Pointer to sock structure.
+    @optname - Name of the option to validate.
+    @address - One or more ipv4 / ipv6 addresses.
+    @addrlen - The total length of address(s). This is calculated on each
+               ipv4 or ipv6 address using sizeof(struct sockaddr_in) or
+               sizeof(struct sockaddr_in6).
+
+  ------------------------------------------------------------------
+  |                     BIND Type Checks                           |
+  |       @optname             |         @address contains         |
+  |----------------------------|-----------------------------------|
+  | SCTP_SOCKOPT_BINDX_ADD     | One or more ipv4 / ipv6 addresses |
+  | SCTP_PRIMARY_ADDR          | Single ipv4 or ipv6 address       |
+  | SCTP_SET_PEER_PRIMARY_ADDR | Single ipv4 or ipv6 address       |
+  ------------------------------------------------------------------
+
+  ------------------------------------------------------------------
+  |                   CONNECT Type Checks                          |
+  |       @optname             |         @address contains         |
+  |----------------------------|-----------------------------------|
+  | SCTP_SOCKOPT_CONNECTX      | One or more ipv4 / ipv6 addresses |
+  | SCTP_PARAM_ADD_IP          | One or more ipv4 / ipv6 addresses |
+  | SCTP_SENDMSG_CONNECT       | Single ipv4 or ipv6 address       |
+  | SCTP_PARAM_SET_PRIMARY     | Single ipv4 or ipv6 address       |
+  ------------------------------------------------------------------
+
+A summary of the @optname entries is as follows:
+
+    SCTP_SOCKOPT_BINDX_ADD - Allows additional bind addresses to be
+                             associated after (optionally) calling
+                             bind(3).
+                             sctp_bindx(3) adds a set of bind
+	                     addresses on a socket.
+
+    SCTP_SOCKOPT_CONNECTX - Allows the allocation of multiple
+                            addresses for reaching a peer
+                            (multi-homed).
+                            sctp_connectx(3) initiates a connection
+                            on an SCTP socket using multiple
+                            destination addresses.
+
+    SCTP_SENDMSG_CONNECT  - Initiate a connection that is generated by a
+                            sendmsg(2) or sctp_sendmsg(3) on a new asociation.
+
+    SCTP_PRIMARY_ADDR     - Set local primary address.
+
+    SCTP_SET_PEER_PRIMARY_ADDR - Request peer sets address as
+                                 association primary.
+
+    SCTP_PARAM_ADD_IP          - These are used when Dynamic Address
+    SCTP_PARAM_SET_PRIMARY     - Reconfiguration is enabled as explained below.
+
+
+To support Dynamic Address Reconfiguration the following parameters must be
+enabled on both endpoints (or use the appropriate setsockopts):
+    /proc/sys/net/sctp/addip_enable
+    /proc/sys/net/sctp/addip_noauth_enable
+
+then the following *_PARAM_*'s are sent to the peer in an
+ASCONF chunk when the corresponding @optname's are present:
+
+          @optname                ASCONF Parameter
+    SCTP_SOCKOPT_BINDX_ADD     -> SCTP_PARAM_ADD_IP
+    SCTP_SET_PEER_PRIMARY_ADDR -> SCTP_PARAM_SET_PRIMARY
+
+
+security_sctp_sk_clone()
+-------------------------
+This new hook has been added to net/sctp/socket.c sctp_sock_migrate() that is
+called whenever a new socket is created by accept(2) (i.e. a TCP style socket)
+or when a socket is 'peeled off' e.g userspace calls sctp_peeloff(3).
+security_sctp_sk_clone() will set the new sockets sid and peer sid to that
+contained in the @ep sid and @ep peer sid respectively.
+
+    @ep - pointer to old sctp endpoint structure.
+    @sk - pointer to old sock structure.
+    @sk - pointer to new sock structure.
+
+security_inet_conn_established()
+---------------------------------
+This hook has been added to net/sctp/sm_statefuns.c COOKIE ECHO processing
+where it sets the connection's peer sid to that in @skb.
+
+    @sk  - pointer to sock structure.
+    @skb - pointer to skbuff of the COOKIE ECHO packet.
+
+
+Security Hooks used for Association Establishment
+==================================================
+The following diagram shows the use of security_sctp_connect_bind(),
+security_sctp_assoc_request(), security_inet_conn_established() in
+net/sctp/sm_statefuns.c and security_sctp_sk_clone() in net/sctp/socket.c,
+when establishing an association.
+
+      SCTP endpoint "A"                                SCTP endpoint "Z"
+      =================                                =================
+    sctp_sf_do_prm_asoc()
+ Association setup can be initiated
+ by a connect(2), sctp_connectx(3),
+ sendmsg(2) or sctp_sendmsg(3).
+ These will result in a call to
+ security_sctp_bind_connect() to
+ initiate an association to
+ SCTP peer endpoint "Z".
+         INIT --------------------------------------------->
+                                                   sctp_sf_do_5_1B_init()
+                                                 Respond to an INIT chunk.
+                                             SCTP peer endpoint "A" is
+                                             asking for an association. Call
+                                             security_sctp_assoc_request()
+                                             to set the peer label if first
+                                             association.
+                                             If not first association, check
+                                             whether allowed, IF so send:
+          <----------------------------------------------- INIT ACK
+          |                                  ELSE audit event and silently
+          |                                       discard the packet.
+    sctp_sf_do_5_1C_ack
+ Respond to an INIT ACK chunk.
+ SCTP peer endpoint"A" initiated
+ this association to SCTP peer
+ endpoint "Z". Call
+ security_sctp_assoc_request()
+ to set the peer label if first
+ association. If not first
+ association, check whether
+ allowed, IF so send:
+    COOKIE ECHO ------------------------------------------>
+ ELSE audit event and silently                            |
+      discard the packet.                                 |
+                                                          |
+          <------------------------------------------- COOKIE ACK
+          |                                               |
+    sctp_sf_do_5_1E_ca                                    |
+ Call security_inet_conn_established()                    |
+ to set the correct peer sid.                             |
+          |                                               |
+          |                               net/sctp/socket.c sctp_copy_sock()
+          |                               If SCTP_SOCKET_TCP or peeled off
+          |                               socket security_sctp_sk_clone() is
+          |                               called to clone the new socket.
+          |                                               |
+      ESTABLISHED                                    ESTABLISHED
+          |                                               |
+    ------------------------------------------------------------------
+    |                     Association Established                    |
+    ------------------------------------------------------------------
+
+
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 3a90feb..42370a7 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -913,6 +913,33 @@
  *	associated with the TUN device's security structure.
  *	@security pointer to the TUN devices's security structure.
  *
+ * Security hooks for SCTP
+ *
+ * @sctp_assoc_request:
+ *	If first association, then set the peer sid to that in @skb. If
+ *	@sctp_cid is from an INIT chunk, then set the sctp endpoint sid to
+ *	socket's sid (ep->base.sk) with MLS portion taken from peer sid.
+ *	@ep pointer to sctp endpoint structure.
+ *	@skb pointer to skbuff of association packet.
+ *	@sctp_cid whether association from INIT or INIT_ACK chunk.
+ *	Return 0 on success, error on failure.
+ * @sctp_bind_connect:
+ *	Validiate permissions required for each address associated with sock
+ *	@sk. Depending on @optname, the addresses will be treated as either
+ *	for a connect or bind service. The @addrlen is calculated on each
+ *	ipv4 and ipv6 address using sizeof(struct sockaddr_in) or
+ *	sizeof(struct sockaddr_in6).
+ *	@sk pointer to sock structure.
+ *	@optname name of the option to validate.
+ *	@address list containing one or more ipv4/ipv6 addresses.
+ *	@addrlen total length of address(s).
+ *	Return 0 on success, error on failure.
+ * @sctp_sk_clone:
+ *	Sets the new child socket's sid to the old endpoint sid.
+ *	@ep pointer to old sctp endpoint structure.
+ *	@sk pointer to old sock structure.
+ *	@sk pointer to new sock structure.
+ *
  * Security hooks for Infiniband
  *
  * @ib_pkey_access:
@@ -1640,6 +1667,13 @@ union security_list_options {
 	int (*tun_dev_attach_queue)(void *security);
 	int (*tun_dev_attach)(struct sock *sk, void *security);
 	int (*tun_dev_open)(void *security);
+	int (*sctp_assoc_request)(struct sctp_endpoint *ep,
+				  struct sk_buff *skb,
+				  int sctp_cid);
+	int (*sctp_bind_connect)(struct sock *sk, int optname,
+				 struct sockaddr *address, int addrlen);
+	void (*sctp_sk_clone)(struct sctp_endpoint *ep, struct sock *sk,
+			      struct sock *newsk);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_INFINIBAND
@@ -1880,6 +1914,9 @@ struct security_hook_heads {
 	struct list_head tun_dev_attach_queue;
 	struct list_head tun_dev_attach;
 	struct list_head tun_dev_open;
+	struct list_head sctp_assoc_request;
+	struct list_head sctp_bind_connect;
+	struct list_head sctp_sk_clone;
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_INFINIBAND
 	struct list_head ib_pkey_access;
diff --git a/include/linux/security.h b/include/linux/security.h
index 834b355..2054023 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -114,6 +114,7 @@ struct xfrm_policy;
 struct xfrm_state;
 struct xfrm_user_sec_ctx;
 struct seq_file;
+struct sctp_endpoint;
 
 #ifdef CONFIG_MMU
 extern unsigned long mmap_min_addr;
@@ -1240,6 +1241,12 @@ int security_tun_dev_create(void);
 int security_tun_dev_attach_queue(void *security);
 int security_tun_dev_attach(struct sock *sk, void *security);
 int security_tun_dev_open(void *security);
+int security_sctp_assoc_request(struct sctp_endpoint *ep, struct sk_buff *skb,
+				int sctp_cid);
+int security_sctp_bind_connect(struct sock *sk, int optname,
+			       struct sockaddr *address, int addrlen);
+void security_sctp_sk_clone(struct sctp_endpoint *ep, struct sock *sk,
+			    struct sock *newsk);
 
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct sock *sock,
@@ -1432,6 +1439,26 @@ static inline int security_tun_dev_open(void *security)
 {
 	return 0;
 }
+
+static inline int security_sctp_assoc_request(struct sctp_endpoint *ep,
+					      struct sk_buff *skb,
+					      int sctp_cid)
+{
+	return 0;
+}
+
+static inline int security_sctp_bind_connect(struct sock *sk, int optname,
+					     struct sockaddr *address,
+					     int addrlen)
+{
+	return 0;
+}
+
+static inline void security_sctp_sk_clone(struct sctp_endpoint *ep,
+					  struct sock *sk,
+					  struct sock *newsk)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_INFINIBAND
diff --git a/security/security.c b/security/security.c
index 3013237..798fc6e 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1482,6 +1482,7 @@ void security_inet_conn_established(struct sock *sk,
 {
 	call_void_hook(inet_conn_established, sk, skb);
 }
+EXPORT_SYMBOL(security_inet_conn_established);
 
 int security_secmark_relabel_packet(u32 secid)
 {
@@ -1537,6 +1538,28 @@ int security_tun_dev_open(void *security)
 }
 EXPORT_SYMBOL(security_tun_dev_open);
 
+int security_sctp_assoc_request(struct sctp_endpoint *ep, struct sk_buff *skb,
+				int sctp_cid)
+{
+	return call_int_hook(sctp_assoc_request, 0, ep, skb, sctp_cid);
+}
+EXPORT_SYMBOL(security_sctp_assoc_request);
+
+int security_sctp_bind_connect(struct sock *sk, int optname,
+			       struct sockaddr *address, int addrlen)
+{
+	return call_int_hook(sctp_bind_connect, 0, sk, optname,
+			     address, addrlen);
+}
+EXPORT_SYMBOL(security_sctp_bind_connect);
+
+void security_sctp_sk_clone(struct sctp_endpoint *ep, struct sock *sk,
+			    struct sock *newsk)
+{
+	call_void_hook(sctp_sk_clone, ep, sk, newsk);
+}
+EXPORT_SYMBOL(security_sctp_sk_clone);
+
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_INFINIBAND
-- 
2.13.6
