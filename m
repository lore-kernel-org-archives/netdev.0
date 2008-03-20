From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH]: [SCTP]: Fix a race between module load and protosw access
Date: Thu, 20 Mar 2008 09:30:52 -0400
Message-ID: <47E2670C.1040900@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers <lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:10826 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbYCTNaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 09:30:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race is SCTP between the loading of the module
and the access by the socket layer to the protocol functions.
In particular, a list of addresss that SCTP maintains is
not initialized prior to the registration with the protosw.
Thus it is possible for a user application to gain access
to SCTP functions before everything has been initialized.
The problem shows up as odd crashes during connection
initializtion when we try to access the SCTP address list.

The solution is to refactor how we do registration and
initialize the lists prior to registering with the protosw.
Care must be taken since the address list initialization
depends on some other pieces of SCTP initialization.  Also
the clean-up in case of failure now also needs to be refactored.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Acked-by: Sridhar Samudrala <sri@us.ibm.com>
---
 include/net/sctp/sctp.h |   12 +++--
 net/sctp/ipv6.c         |   32 +++++++----
 net/sctp/protocol.c     |  129 ++++++++++++++++++++++++++++++----------------
 3 files changed, 112 insertions(+), 61 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 57df27f..57ed3e3 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -380,15 +380,19 @@ static inline int sctp_sysctl_jiffies_ms(ctl_table *table, int __user *name, int
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 
-int sctp_v6_init(void);
-void sctp_v6_exit(void);
+void sctp_v6_pf_init(void);
+void sctp_v6_pf_exit(void);
+int sctp_v6_protosw_init(void);
+void sctp_v6_protosw_exit(void);
 int sctp_v6_add_protocol(void);
 void sctp_v6_del_protocol(void);
 
 #else /* #ifdef defined(CONFIG_IPV6) */
 
-static inline int sctp_v6_init(void) { return 0; }
-static inline void sctp_v6_exit(void) { return; }
+static inline void sctp_v6_pf_init(void) { return 0; }
+static inline void sctp_v6_pf_exit(void) { return; }
+static inline int sctp_v6_protosw_init(void) { return 0; }
+static inline void sctp_v6_protosw_exit(void) { return; }
 static inline int sctp_v6_add_protocol(void) { return 0; }
 static inline void sctp_v6_del_protocol(void) { return; }
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 9aa0733..248d960 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -1014,15 +1014,24 @@ static struct sctp_pf sctp_pf_inet6 = {
 };
 
 /* Initialize IPv6 support and register with socket layer.  */
-int sctp_v6_init(void)
+void sctp_v6_pf_init(void)
 {
-	int rc;
-
 	/* Register the SCTP specific PF_INET6 functions. */
 	sctp_register_pf(&sctp_pf_inet6, PF_INET6);
 
 	/* Register the SCTP specific AF_INET6 functions. */
 	sctp_register_af(&sctp_af_inet6);
+}
+
+void sctp_v6_pf_exit(void)
+{
+	list_del(&sctp_af_inet6.list);
+}
+ 
+/* Initialize IPv6 support and register with socket layer.  */
+int sctp_v6_protosw_init(void)
+{
+	int rc;
 
 	rc = proto_register(&sctpv6_prot, 1);
 	if (rc)
@@ -1035,6 +1044,14 @@ int sctp_v6_init(void)
 	return 0;
 }
 
+void sctp_v6_protosw_exit(void)
+{
+	inet6_unregister_protosw(&sctpv6_seqpacket_protosw);
+	inet6_unregister_protosw(&sctpv6_stream_protosw);
+	proto_unregister(&sctpv6_prot);
+}
+
+
 /* Register with inet6 layer. */
 int sctp_v6_add_protocol(void)
 {
@@ -1047,15 +1064,6 @@ int sctp_v6_add_protocol(void)
 	return 0;
 }
 
-/* IPv6 specific exit support. */
-void sctp_v6_exit(void)
-{
-	inet6_unregister_protosw(&sctpv6_seqpacket_protosw);
-	inet6_unregister_protosw(&sctpv6_stream_protosw);
-	proto_unregister(&sctpv6_prot);
-	list_del(&sctp_af_inet6.list);
-}
-
 /* Unregister with inet6 layer. */
 void sctp_v6_del_protocol(void)
 {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index ad0a406..353f837 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -992,6 +992,58 @@ static void cleanup_sctp_mibs(void)
 	free_percpu(sctp_statistics[1]);
 }
 
+static void sctp_v4_pf_init(void)
+{
+	/* Initialize the SCTP specific PF functions. */
+	sctp_register_pf(&sctp_pf_inet, PF_INET);
+	sctp_register_af(&sctp_af_inet);
+}
+
+static void sctp_v4_pf_exit(void)
+{
+	list_del(&sctp_af_inet.list);
+}
+
+static int sctp_v4_protosw_init(void)
+{
+	int rc;
+
+	rc = proto_register(&sctp_prot, 1);
+	if (rc)
+		return rc;
+
+	/* Register SCTP(UDP and TCP style) with socket layer.  */
+	inet_register_protosw(&sctp_seqpacket_protosw);
+	inet_register_protosw(&sctp_stream_protosw);
+
+	return 0;
+}
+
+static void sctp_v4_protosw_exit(void)
+{
+	inet_unregister_protosw(&sctp_stream_protosw);
+	inet_unregister_protosw(&sctp_seqpacket_protosw);
+	proto_unregister(&sctp_prot);
+}
+
+static int sctp_v4_add_protocol(void)
+{
+	/* Register notifier for inet address additions/deletions. */
+	register_inetaddr_notifier(&sctp_inetaddr_notifier);
+
+	/* Register SCTP with inet layer.  */
+	if (inet_add_protocol(&sctp_protocol, IPPROTO_SCTP) < 0)
+		return -EAGAIN;
+
+	return 0;
+}
+
+static void sctp_v4_del_protocol(void)
+{
+	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
+	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
+}
+
 /* Initialize the universe into something sensible.  */
 SCTP_STATIC __init int sctp_init(void)
 {
@@ -1035,8 +1087,6 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Initialize object count debugging.  */
 	sctp_dbg_objcnt_init();
 
-	/* Initialize the SCTP specific PF functions. */
-	sctp_register_pf(&sctp_pf_inet, PF_INET);
 	/*
 	 * 14. Suggested SCTP Protocol Parameter Values
 	 */
@@ -1194,19 +1244,22 @@ SCTP_STATIC __init int sctp_init(void)
 	sctp_sysctl_register();
 
 	INIT_LIST_HEAD(&sctp_address_families);
-	sctp_register_af(&sctp_af_inet);
+	sctp_v4_pf_init();
+	sctp_v6_pf_init();
+	
+	/* Initialize the local address list. */
+	INIT_LIST_HEAD(&sctp_local_addr_list);
+	spin_lock_init(&sctp_local_addr_lock);
+	sctp_get_local_addr_list();
 
-	status = proto_register(&sctp_prot, 1);
+	status = sctp_v4_protosw_init();
+	
 	if (status)
-		goto err_proto_register;
+		goto err_protosw_init;
 
-	/* Register SCTP(UDP and TCP style) with socket layer.  */
-	inet_register_protosw(&sctp_seqpacket_protosw);
-	inet_register_protosw(&sctp_stream_protosw);
-
-	status = sctp_v6_init();
+	status = sctp_v6_protosw_init();
 	if (status)
-		goto err_v6_init;
+		goto err_v6_protosw_init;
 
 	/* Initialize the control inode/socket for handling OOTB packets.  */
 	if ((status = sctp_ctl_sock_init())) {
@@ -1215,19 +1268,9 @@ SCTP_STATIC __init int sctp_init(void)
 		goto err_ctl_sock_init;
 	}
 
-	/* Initialize the local address list. */
-	INIT_LIST_HEAD(&sctp_local_addr_list);
-	spin_lock_init(&sctp_local_addr_lock);
-	sctp_get_local_addr_list();
-
-	/* Register notifier for inet address additions/deletions. */
-	register_inetaddr_notifier(&sctp_inetaddr_notifier);
-
-	/* Register SCTP with inet layer.  */
-	if (inet_add_protocol(&sctp_protocol, IPPROTO_SCTP) < 0) {
-		status = -EAGAIN;
+	status = sctp_v4_add_protocol();
+	if (status)
 		goto err_add_protocol;
-	}
 
 	/* Register SCTP with inet6 layer.  */
 	status = sctp_v6_add_protocol();
@@ -1238,18 +1281,18 @@ SCTP_STATIC __init int sctp_init(void)
 out:
 	return status;
 err_v6_add_protocol:
-	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
-	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
+	sctp_v6_del_protocol();
 err_add_protocol:
-	sctp_free_local_addr_list();
+	sctp_v4_del_protocol();
 	sock_release(sctp_ctl_socket);
 err_ctl_sock_init:
-	sctp_v6_exit();
-err_v6_init:
-	inet_unregister_protosw(&sctp_stream_protosw);
-	inet_unregister_protosw(&sctp_seqpacket_protosw);
-	proto_unregister(&sctp_prot);
-err_proto_register:
+	sctp_v6_protosw_exit();
+err_v6_protosw_init:
+	sctp_v4_protosw_exit();
+err_protosw_init:
+	sctp_free_local_addr_list();
+	sctp_v4_pf_exit();
+	sctp_v6_pf_exit();
 	sctp_sysctl_unregister();
 	list_del(&sctp_af_inet.list);
 	free_pages((unsigned long)sctp_port_hashtable,
@@ -1282,23 +1325,21 @@ SCTP_STATIC __exit void sctp_exit(void)
 
 	/* Unregister with inet6/inet layers. */
 	sctp_v6_del_protocol();
-	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
-
-	/* Unregister notifier for inet address additions/deletions. */
-	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
-
-	/* Free the local address list.  */
-	sctp_free_local_addr_list();
+	sctp_v4_del_protocol();
 
 	/* Free the control endpoint.  */
 	sock_release(sctp_ctl_socket);
 
-	/* Cleanup v6 initializations. */
-	sctp_v6_exit();
+	/* Free protosw registrations */
+	sctp_v6_protosw_exit();
+	sctp_v4_protosw_exit();
+
+	/* Free the local address list.  */
+	sctp_free_local_addr_list();
 
 	/* Unregister with socket layer. */
-	inet_unregister_protosw(&sctp_stream_protosw);
-	inet_unregister_protosw(&sctp_seqpacket_protosw);
+	sctp_v6_pf_exit();
+	sctp_v4_pf_exit();
 
 	sctp_sysctl_unregister();
 	list_del(&sctp_af_inet.list);
@@ -1317,8 +1358,6 @@ SCTP_STATIC __exit void sctp_exit(void)
 
 	kmem_cache_destroy(sctp_chunk_cachep);
 	kmem_cache_destroy(sctp_bucket_cachep);
-
-	proto_unregister(&sctp_prot);
 }
 
 module_init(sctp_init);
-- 
1.5.3.5

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

