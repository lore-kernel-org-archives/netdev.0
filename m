From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v2 3/3] sctp: Add a valid address list in association local
Date: Fri, 8 Apr 2011 14:19:13 +0900
Message-ID: <115A4380-6E63-4014-BD24-04A29472ACCD@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:53961 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751334Ab1DHFTO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 01:19:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the SCTP association transmits an ASCONF with ADD_IP_ADDRESS, that association cannot use the adding address until it receives ASCONF-ACK.  
This patch prevents that associations that do not receive ASCONF-ACK use the adding address.

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 505845d..f1f439c 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -135,6 +135,7 @@ void sctp_sock_rfree(struct sk_buff *skb);
 void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 		    struct sctp_association *asoc);
 extern struct percpu_counter sctp_sockets_allocated;
+void sctp_add_addr_to_laddr(struct sockaddr *, struct sctp_association *);
 
 /*
  * sctp/primitive.c
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index cc9185c..f6ca775 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1901,6 +1901,14 @@ struct sctp_association {
 	 * after reaching 4294967295.
 	 */
 	__u32 addip_serial;
+	/* list of valid addresses in association local
+	 * This list is needed to ensure base.bind_addr being a valid address
+	 * list of the endpoint-wide.  When one of associations receives
+	 * ASCONF-ACK, that address is added to this list.  When all
+	 * associations belonging to the same endpoint receive ASCONF-ACKs,
+	 * that address is added to base.bind_addr
+	 */
+	struct list_head asoc_laddr_list;
 
 	/* SCTP AUTH: list of the endpoint shared keys.  These
 	 * keys are provided out of band by the user applicaton
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 6b04287..614834f 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -279,6 +279,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->peer.asconf_capable = 0;
 	if (sctp_addip_noauth)
 		asoc->peer.asconf_capable = 1;
+	INIT_LIST_HEAD(&asoc->asoc_laddr_list);
 
 	/* Create an input queue.  */
 	sctp_inq_init(&asoc->base.inqueue);
@@ -446,6 +447,15 @@ void sctp_association_free(struct sctp_association *asoc)
 	/* Free any cached ASCONF_ACK chunk. */
 	sctp_assoc_free_asconf_acks(asoc);
 
+	if (!list_empty(&asoc->asoc_laddr_list)) {
+		struct sctp_sockaddr_entry *laddr, *tmp;
+		list_for_each_entry_safe(laddr, tmp, &asoc->asoc_laddr_list, \
+		    list) {
+			list_del(&laddr->list);
+			kfree(laddr);
+		}
+	}
+
 	/* Free any cached ASCONF chunk. */
 	if (asoc->addip_last_asconf)
 		sctp_chunk_free(asoc->addip_last_asconf);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 865ce7b..bbf3152 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -333,6 +333,18 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 			}
 		}
 	}
+	if (baddr == NULL) {
+		/* We don't have a valid src addr in "endpoint-wide".
+		 * Looking up in assoc-locally valid address list.
+		 */
+		list_for_each_entry(laddr, &asoc->asoc_laddr_list, list) {
+			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
+			if (!baddr || (matchlen < bmatchlen)) {
+				baddr = &laddr->a;
+				matchlen = bmatchlen;
+			}
+		}
+	}
 
 	if (baddr) {
 		memcpy(saddr, baddr, sizeof(union sctp_addr));
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 152976e..918a62e 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -516,6 +516,13 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 				goto out_unlock;
 		}
 		rcu_read_unlock();
+		/* We don't have a valid src addr in "endpoint-wide".
+		 * Looking up in assoc-locally valid address list.
+		 */
+		list_for_each_entry(laddr, &asoc->asoc_laddr_list, list) {
+			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
+				goto out_unlock;
+		}
 
 		/* None of the bound addresses match the source address of the
 		 * dst. So release it.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index de98665..1a44f88 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3171,7 +3171,6 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 	struct sctp_bind_addr *bp = &asoc->base.bind_addr;
 	union sctp_addr_param *addr_param;
 	struct sctp_transport *transport;
-	struct sctp_sockaddr_entry *saddr;
 
 	addr_param = (union sctp_addr_param *)
 			((void *)asconf_param + sizeof(sctp_addip_param_t));
@@ -3186,10 +3185,10 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 		 * held, so the list can not change.
 		 */
 		local_bh_disable();
-		list_for_each_entry(saddr, &bp->address_list, list) {
-			if (sctp_cmp_addr_exact(&saddr->a, &addr))
-				saddr->state = SCTP_ADDR_SRC;
-		}
+		/* Until this ASCONF is acked on all associations, we cannot
+		 * consider this address as ADDR_SRC
+		 */
+		sctp_add_addr_to_laddr(&addr.sa, asoc);
 		local_bh_enable();
 		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
 				transports) {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 3951a10..1a06469 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -807,6 +807,145 @@ out:
 	return retval;
 }
 
+/* Add a new address to the list contains available addresses only in the
+ * association.  If the new address is also available on the other associations
+ * on the endpoint, it is marked as SCTP_ADDR_SRC in the bind address list on
+ * the endpoint.  This situation is possible when some of associations receive
+ * ASCONF-ACK for ADD_IP at the endpoint
+ */
+void
+sctp_add_addr_to_laddr(struct sockaddr *sa, struct sctp_association *asoc)
+{
+	struct sctp_endpoint *ep = asoc->ep;
+	struct sctp_association *tmp = NULL;
+	struct sctp_bind_addr *bp;
+	struct sctp_sockaddr_entry *addr;
+	struct sockaddr_in *sin = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
+	int local;
+	int found;
+
+	union sctp_addr *tmpaddr = NULL;
+	tmpaddr = (union sctp_addr *)sa;
+	SCTP_DEBUG_PRINTK_IPADDR("add_addr_to_laddr: asoc: %p ", " ep: %p",
+	    asoc, tmpaddr, ep);
+	if (sa->sa_family == AF_INET)
+		sin = (struct sockaddr_in *)sa;
+	else if (sa->sa_family == AF_INET6)
+		sin6 = (struct sockaddr_in6 *)sa;
+
+	/* Check if this address is locally available in the other asocs */
+	local = 0;
+	list_for_each_entry(tmp, &ep->asocs, asocs) {
+		if (tmp == asoc)
+			continue;
+		found = 0;
+		list_for_each_entry(addr, &tmp->asoc_laddr_list, list) {
+			tmpaddr = &addr->a;
+			if (sa->sa_family != addr->a.sa.sa_family)
+				continue;
+			if (sa->sa_family == AF_INET) {
+				if (sin->sin_addr.s_addr ==
+				    addr->a.v4.sin_addr.s_addr)
+					found = 1;
+			} else if (sa->sa_family == AF_INET6) {
+				if (ipv6_addr_equal(&sin6->sin6_addr,
+				    &addr->a.v6.sin6_addr))
+					found = 1;
+
+			}
+		}
+		if (!found) {
+			SCTP_DEBUG_PRINTK("add_addr_to_laddr: not found in asoc %p\n", tmp);
+			local = 1;
+			break;
+		}
+	}
+	addr = NULL;
+
+	if (local) {
+		/* this address is not available in some of the other
+		 * associations.  So add as locally-available in this
+		 * asocciation
+		 */
+		addr = kmalloc(sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
+		if  (addr == NULL) {
+			SCTP_DEBUG_PRINTK("add_addr_to_laddr: failed to allocate memory for this address\n");
+			return;
+		}
+		memset(addr, 0, sizeof(struct sctp_sockaddr_entry));
+		if (sa->sa_family == AF_INET) {
+			addr->a.sa.sa_family = AF_INET;
+			addr->a.v4.sin_port = sin->sin_port;
+			addr->a.v4.sin_addr.s_addr = sin->sin_addr.s_addr;
+		} else if (sa->sa_family == AF_INET6) {
+			addr->a.sa.sa_family = AF_INET6;
+			addr->a.v6.sin6_port = sin6->sin6_port;
+			memcpy(&addr->a.v6.sin6_addr, &sin6->sin6_addr,
+			    sizeof(struct in6_addr));
+		}
+		list_add_tail(&addr->list, &asoc->asoc_laddr_list);
+		SCTP_DEBUG_PRINTK("add_addr_to_laddr: now we added this address to the local list on asoc %p\n", asoc);
+	} else {
+		/* this address is also available in all other asocs.  So set
+		 * it as ADDR_SRC in the bind-addr list in the endpoint, then
+		 * remove from the asoc_laddr_list on the associations.
+		 */
+		SCTP_DEBUG_PRINTK("add_addr_to_laddr: this address is available in all other asocs\n");
+		bp = &asoc->base.bind_addr;
+
+		/* change state of the new address in the bind list */
+		list_for_each_entry(addr, &bp->address_list, list) {
+			if (addr->state != SCTP_ADDR_NEW)
+				continue;
+			if (addr->a.sa.sa_family != sa->sa_family)
+				continue;
+			if (addr->a.sa.sa_family == AF_INET) {
+				if (sin->sin_port != addr->a.v4.sin_port)
+					continue;
+				if (sin->sin_addr.s_addr !=
+				    addr->a.v4.sin_addr.s_addr)
+					continue;
+			} else if (addr->a.sa.sa_family == AF_INET6) {
+				if (sin6->sin6_port != addr->a.v6.sin6_port)
+					continue;
+				if (!ipv6_addr_equal(&sin6->sin6_addr,
+				    &addr->a.v6.sin6_addr))
+					continue;
+			}
+			SCTP_DEBUG_PRINTK("add_addr_to_laddr: found the entry for this address with ADDR_NEW flag, set to ADDR_SRC\n");
+			addr->state = SCTP_ADDR_SRC;
+		}
+
+		/* remove the entry of this address from the asoc-local list */
+		list_for_each_entry(tmp, &ep->asocs, asocs) {
+			if (tmp == asoc)
+				continue;
+			addr = NULL;
+			list_for_each_entry(addr, &tmp->asoc_laddr_list, list) {
+				if (sa->sa_family != addr->a.sa.sa_family)
+					continue;
+				if (sa->sa_family == AF_INET) {
+					if (sin->sin_addr.s_addr !=
+					    addr->a.v4.sin_addr.s_addr)
+						continue;
+				} else if (sa->sa_family == AF_INET6) {
+					if (!ipv6_addr_equal(&sin6->sin6_addr,
+					    &addr->a.v6.sin6_addr))
+						continue;
+				}
+				break;
+			}
+			if (addr == NULL) {
+				SCTP_DEBUG_PRINTK("add_addr_to_laddr: Huh, asoc %p doesn't have the entry for this address?\n", asoc);
+				continue;
+			}
+			list_del(&addr->list);
+			kfree(addr);
+		}
+	}
+}
+
 /* Helper for tunneling sctp_bindx() requests through sctp_setsockopt()
  *
  * API 8.1

