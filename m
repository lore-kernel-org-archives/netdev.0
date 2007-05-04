From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 4/4] [SCTP]: Re-order SCTP initializations to avoid race with sctp_rcv()
Date: Fri,  4 May 2007 16:22:55 -0400
Message-ID: <11783101752806-git-send-email-vladislav.yasevich@hp.com>
References: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:52346 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031530AbXEDUW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 16:22:57 -0400
In-Reply-To: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sctp.h |    4 ++
 net/sctp/ipv6.c         |   49 ++++++++++++++++------------
 net/sctp/protocol.c     |   79 ++++++++++++++++++++++++++++-------------------
 3 files changed, 79 insertions(+), 53 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 28af680..dda72bf 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -378,11 +378,15 @@ static inline int sctp_sysctl_jiffies_ms(ctl_table *table, int __user *name, int
 
 int sctp_v6_init(void);
 void sctp_v6_exit(void);
+int sctp_v6_add_protocol(void);
+void sctp_v6_del_protocol(void);
 
 #else /* #ifdef defined(CONFIG_IPV6) */
 
 static inline int sctp_v6_init(void) { return 0; }
 static inline void sctp_v6_exit(void) { return; }
+static inline int sctp_v6_add_protocol(void) { return 0; }
+static inline void sctp_v6_del_protocol(void) { return; }
 
 #endif /* #if defined(CONFIG_IPV6) */
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index ca527a2..84cd536 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -992,45 +992,52 @@ static struct sctp_pf sctp_pf_inet6_specific = {
 	.af            = &sctp_ipv6_specific,
 };
 
-/* Initialize IPv6 support and register with inet6 stack.  */
+/* Initialize IPv6 support and register with socket layer.  */
 int sctp_v6_init(void)
 {
-	int rc = proto_register(&sctpv6_prot, 1);
+	int rc;
 
+	/* Register the SCTP specific PF_INET6 functions. */
+	sctp_register_pf(&sctp_pf_inet6_specific, PF_INET6);
+
+	/* Register the SCTP specific AF_INET6 functions. */
+	sctp_register_af(&sctp_ipv6_specific);
+
+	rc = proto_register(&sctpv6_prot, 1);
 	if (rc)
-		goto out;
-	/* Register inet6 protocol. */
-	rc = -EAGAIN;
-	if (inet6_add_protocol(&sctpv6_protocol, IPPROTO_SCTP) < 0)
-		goto out_unregister_sctp_proto;
+		return rc;
 
 	/* Add SCTPv6(UDP and TCP style) to inetsw6 linked list. */
 	inet6_register_protosw(&sctpv6_seqpacket_protosw);
 	inet6_register_protosw(&sctpv6_stream_protosw);
 
-	/* Register the SCTP specific PF_INET6 functions. */
-	sctp_register_pf(&sctp_pf_inet6_specific, PF_INET6);
-
-	/* Register the SCTP specific AF_INET6 functions. */
-	sctp_register_af(&sctp_ipv6_specific);
+	return 0;
+}
 
+/* Register with inet6 layer. */
+int sctp_v6_add_protocol(void)
+{
 	/* Register notifier for inet6 address additions/deletions. */
 	register_inet6addr_notifier(&sctp_inet6addr_notifier);
-	rc = 0;
-out:
-	return rc;
-out_unregister_sctp_proto:
-	proto_unregister(&sctpv6_prot);
-	goto out;
+
+	if (inet6_add_protocol(&sctpv6_protocol, IPPROTO_SCTP) < 0)
+		return -EAGAIN;
+
+	return 0;
 }
 
 /* IPv6 specific exit support. */
 void sctp_v6_exit(void)
 {
-	list_del(&sctp_ipv6_specific.list);
-	inet6_del_protocol(&sctpv6_protocol, IPPROTO_SCTP);
 	inet6_unregister_protosw(&sctpv6_seqpacket_protosw);
 	inet6_unregister_protosw(&sctpv6_stream_protosw);
-	unregister_inet6addr_notifier(&sctp_inet6addr_notifier);
 	proto_unregister(&sctpv6_prot);
+	list_del(&sctp_ipv6_specific.list);
+}
+
+/* Unregister with inet6 layer. */
+void sctp_v6_del_protocol(void)
+{
+	inet6_del_protocol(&sctpv6_protocol, IPPROTO_SCTP);
+	unregister_inet6addr_notifier(&sctp_inet6addr_notifier);
 }
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d4afafc..34bab36 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -975,28 +975,14 @@ SCTP_STATIC __init int sctp_init(void)
 	if (!sctp_sanity_check())
 		goto out;
 
-	status = proto_register(&sctp_prot, 1);
-	if (status)
-		goto out;
-
-	/* Add SCTP to inet_protos hash table.  */
-	status = -EAGAIN;
-	if (inet_add_protocol(&sctp_protocol, IPPROTO_SCTP) < 0)
-		goto err_add_protocol;
-
-	/* Add SCTP(TCP and UDP style) to inetsw linked list.  */
-	inet_register_protosw(&sctp_seqpacket_protosw);
-	inet_register_protosw(&sctp_stream_protosw);
-
-	/* Allocate a cache pools. */
+	/* Allocate bind_bucket and chunk caches. */
 	status = -ENOBUFS;
 	sctp_bucket_cachep = kmem_cache_create("sctp_bind_bucket",
 					       sizeof(struct sctp_bind_bucket),
 					       0, SLAB_HWCACHE_ALIGN,
 					       NULL, NULL);
-
 	if (!sctp_bucket_cachep)
-		goto err_bucket_cachep;
+		goto out;
 
 	sctp_chunk_cachep = kmem_cache_create("sctp_chunk",
 					       sizeof(struct sctp_chunk),
@@ -1153,6 +1139,14 @@ SCTP_STATIC __init int sctp_init(void)
 	INIT_LIST_HEAD(&sctp_address_families);
 	sctp_register_af(&sctp_ipv4_specific);
 
+	status = proto_register(&sctp_prot, 1);
+	if (status)
+		goto err_proto_register;
+
+	/* Register SCTP(UDP and TCP style) with socket layer.  */
+	inet_register_protosw(&sctp_seqpacket_protosw);
+	inet_register_protosw(&sctp_stream_protosw);
+
 	status = sctp_v6_init();
 	if (status)
 		goto err_v6_init;
@@ -1166,19 +1160,39 @@ SCTP_STATIC __init int sctp_init(void)
 
 	/* Initialize the local address list. */
 	INIT_LIST_HEAD(&sctp_local_addr_list);
-
 	sctp_get_local_addr_list();
 
 	/* Register notifier for inet address additions/deletions. */
 	register_inetaddr_notifier(&sctp_inetaddr_notifier);
 
+	/* Register SCTP with inet layer.  */
+	if (inet_add_protocol(&sctp_protocol, IPPROTO_SCTP) < 0) {
+		status = -EAGAIN;
+		goto err_add_protocol;
+	}
+
+	/* Register SCTP with inet6 layer.  */
+	status = sctp_v6_add_protocol();
+	if (status)
+		goto err_v6_add_protocol;
+
 	__unsafe(THIS_MODULE);
 	status = 0;
 out:
 	return status;
+err_v6_add_protocol:
+	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
+	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
+err_add_protocol:
+	sctp_free_local_addr_list();
+	sock_release(sctp_ctl_socket);
 err_ctl_sock_init:
 	sctp_v6_exit();
 err_v6_init:
+	inet_unregister_protosw(&sctp_stream_protosw);
+	inet_unregister_protosw(&sctp_seqpacket_protosw);
+	proto_unregister(&sctp_prot);
+err_proto_register:
 	sctp_sysctl_unregister();
 	list_del(&sctp_ipv4_specific.list);
 	free_pages((unsigned long)sctp_port_hashtable,
@@ -1192,19 +1206,13 @@ err_ehash_alloc:
 			     sizeof(struct sctp_hashbucket)));
 err_ahash_alloc:
 	sctp_dbg_objcnt_exit();
-err_init_proc:
 	sctp_proc_exit();
+err_init_proc:
 	cleanup_sctp_mibs();
 err_init_mibs:
 	kmem_cache_destroy(sctp_chunk_cachep);
 err_chunk_cachep:
 	kmem_cache_destroy(sctp_bucket_cachep);
-err_bucket_cachep:
-	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
-	inet_unregister_protosw(&sctp_seqpacket_protosw);
-	inet_unregister_protosw(&sctp_stream_protosw);
-err_add_protocol:
-	proto_unregister(&sctp_prot);
 	goto out;
 }
 
@@ -1215,8 +1223,9 @@ SCTP_STATIC __exit void sctp_exit(void)
 	 * up all the remaining associations and all that memory.
 	 */
 
-	/* Unregister notifier for inet address additions/deletions. */
-	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
+	/* Unregister with inet6/inet layers. */
+	sctp_v6_del_protocol();
+	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
 
 	/* Free the local address list.  */
 	sctp_free_local_addr_list();
@@ -1224,7 +1233,16 @@ SCTP_STATIC __exit void sctp_exit(void)
 	/* Free the control endpoint.  */
 	sock_release(sctp_ctl_socket);
 
+	/* Cleanup v6 initializations. */
 	sctp_v6_exit();
+
+	/* Unregister with socket layer. */
+	inet_unregister_protosw(&sctp_stream_protosw);
+	inet_unregister_protosw(&sctp_seqpacket_protosw);
+
+	/* Unregister notifier for inet address additions/deletions. */
+	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
+
 	sctp_sysctl_unregister();
 	list_del(&sctp_ipv4_specific.list);
 
@@ -1236,16 +1254,13 @@ SCTP_STATIC __exit void sctp_exit(void)
 		   get_order(sctp_port_hashsize *
 			     sizeof(struct sctp_bind_hashbucket)));
 
-	kmem_cache_destroy(sctp_chunk_cachep);
-	kmem_cache_destroy(sctp_bucket_cachep);
-
 	sctp_dbg_objcnt_exit();
 	sctp_proc_exit();
 	cleanup_sctp_mibs();
 
-	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
-	inet_unregister_protosw(&sctp_seqpacket_protosw);
-	inet_unregister_protosw(&sctp_stream_protosw);
+	kmem_cache_destroy(sctp_chunk_cachep);
+	kmem_cache_destroy(sctp_bucket_cachep);
+
 	proto_unregister(&sctp_prot);
 }
 
-- 
1.5.0.3.438.gc49b2

