From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v3 1/3] sctp: Add Auto-ASCONF support
Date: Fri, 8 Apr 2011 14:18:48 +0900
Message-ID: <701EB2FD-B100-4DFE-B013-C9D57CBCDA5E@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:53956 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751418Ab1DHFSt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 01:18:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP reconfigure the IP addresses in the association by using ASCONF chunks as mentioned in RFC5061.  
For example, we can start to use the newly configured IP address in the existing association.  
ASCONF operation is invoked in two ways: 
First is done by the application to call sctp_bindx() system call.  
Second is automatic operation in the SCTP stack with address events in the host computer (called auto_asconf) .  
The former is already implemented, but the latter is not yet. This patch enables it with one sysctl parameter and setsockopt() system call.  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 11684d9..11c3060 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -767,6 +767,7 @@ enum {
 	NET_SCTP_SNDBUF_POLICY		 = 15,
 	NET_SCTP_SACK_TIMEOUT		 = 16,
 	NET_SCTP_RCVBUF_POLICY		 = 17,
+	NET_SCTP_AUTO_ASCONF_ENABLE	 = 18,
 };
 
 /* /proc/sys/net/bridge */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 505845d..75ba6a4 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -121,6 +121,7 @@ extern int sctp_copy_local_addr_list(struct sctp_bind_addr *,
 				     int flags);
 extern struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
 extern int sctp_register_pf(struct sctp_pf *, sa_family_t);
+void sctp_addr_wq_mgmt(union sctp_addr *, int);
 
 /*
  * sctp/socket.c
@@ -135,6 +136,7 @@ void sctp_sock_rfree(struct sk_buff *skb);
 void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 		    struct sctp_association *asoc);
 extern struct percpu_counter sctp_sockets_allocated;
+int sctp_asconf_mgmt(struct sctp_endpoint *);
 
 /*
  * sctp/primitive.c
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index cc9185c..3e0351a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -205,6 +205,11 @@ extern struct sctp_globals {
 	 * It is a list of sctp_sockaddr_entry.
 	 */
 	struct list_head local_addr_list;
+	int auto_asconf_enable;
+	struct list_head addr_waitq;
+	struct timer_list addr_wq_timer;
+	struct list_head auto_asconf_eplist;
+	spinlock_t addr_wq_lock;
 
 	/* Lock that protects the local_addr_list writers */
 	spinlock_t addr_list_lock;
@@ -264,6 +269,11 @@ extern struct sctp_globals {
 #define sctp_port_hashtable		(sctp_globals.port_hashtable)
 #define sctp_local_addr_list		(sctp_globals.local_addr_list)
 #define sctp_local_addr_lock		(sctp_globals.addr_list_lock)
+#define sctp_auto_asconf_eplist		(sctp_globals.auto_asconf_eplist)
+#define sctp_addr_waitq			(sctp_globals.addr_waitq)
+#define sctp_addr_wq_timer		(sctp_globals.addr_wq_timer)
+#define sctp_addr_wq_lock		(sctp_globals.addr_wq_lock)
+#define sctp_auto_asconf_enable		(sctp_globals.auto_asconf_enable)
 #define sctp_scope_policy		(sctp_globals.ipv4_scope_policy)
 #define sctp_addip_enable		(sctp_globals.addip_enable)
 #define sctp_addip_noauth		(sctp_globals.addip_noauth_enable)
@@ -796,6 +806,15 @@ struct sctp_sockaddr_entry {
 	__u8 valid;
 };
 
+#define SCTP_NEWADDR	1
+#define SCTP_DELADDR	2
+#define SCTP_ADDRESS_TICK_DELAY	500
+struct sctp_addr_wait {
+	struct list_head list;
+	union sctp_addr a;
+	int	cmd;
+};
+
 typedef struct sctp_chunk *(sctp_packet_phandler_t)(struct sctp_association *);
 
 /* This structure holds lists of chunks as we are assembling for
@@ -1239,6 +1258,7 @@ sctp_scope_t sctp_scope(const union sctp_addr *);
 int sctp_in_scope(const union sctp_addr *addr, const sctp_scope_t scope);
 int sctp_is_any(struct sock *sk, const union sctp_addr *addr);
 int sctp_addr_is_valid(const union sctp_addr *addr);
+int sctp_is_ep_boundall(struct sock *sk);
 
 
 /* What type of endpoint?  */
@@ -1267,6 +1287,7 @@ struct sctp_ep_common {
 	/* Fields to help us manage our entries in the hash tables. */
 	struct hlist_node node;
 	int hashent;
+	struct list_head auto_asconf_list;
 
 	/* Runtime type information.  What kind of endpoint is this? */
 	sctp_endpoint_type_t type;
@@ -1369,6 +1390,7 @@ struct sctp_endpoint {
 	/* SCTP-AUTH: endpoint shared keys */
 	struct list_head endpoint_shared_keys;
 	__u16 active_key_id;
+	int do_auto_asconf;
 };
 
 /* Recover the outter endpoint structure. */
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index e73ebda..75c96b1 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -91,6 +91,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PEER_AUTH_CHUNKS	26	/* Read only */
 #define SCTP_LOCAL_AUTH_CHUNKS	27	/* Read only */
 #define SCTP_GET_ASSOC_NUMBER	28	/* Read only */
+#define SCTP_AUTO_ASCONF	29
 
 /* Internal Socket Options. Some of the sctp library functions are
  * implemented using these socket options.
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index faf71d1..426715f 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -536,6 +536,23 @@ int sctp_in_scope(const union sctp_addr *addr, sctp_scope_t scope)
 	return 0;
 }
 
+int sctp_is_ep_boundall(struct sock *sk)
+{
+	struct sctp_bind_addr *bp;
+	struct sctp_sockaddr_entry *addr;
+
+	bp = &sctp_sk(sk)->ep->base.bind_addr;
+	if (sctp_list_single_entry(&bp->address_list)) {
+		addr = list_entry(bp->address_list.next,
+				  struct sctp_sockaddr_entry, list);
+		if (sctp_is_any(sk, &addr->a))
+			return 1;
+		else
+			return 0;
+	}
+	return 1;
+}
+
 /********************************************************************
  * 3rd Level Abstractions
  ********************************************************************/
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 865ce7b..1b31b4d 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -105,6 +105,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 			addr->valid = 1;
 			spin_lock_bh(&sctp_local_addr_lock);
 			list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
+			sctp_addr_wq_mgmt(&addr->a, SCTP_NEWADDR);
 			spin_unlock_bh(&sctp_local_addr_lock);
 		}
 		break;
@@ -115,6 +116,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 			if (addr->a.sa.sa_family == AF_INET6 &&
 					ipv6_addr_equal(&addr->a.v6.sin6_addr,
 						&ifa->addr)) {
+				sctp_addr_wq_mgmt(&addr->a, SCTP_DELADDR);
 				found = 1;
 				addr->valid = 0;
 				list_del_rcu(&addr->list);
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 152976e..f9e0bd6 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -636,6 +636,194 @@ static void sctp_v4_ecn_capable(struct sock *sk)
 	INET_ECN_xmit(sk);
 }
 
+void sctp_addr_wq_timeout_handler(unsigned long arg)
+{
+	struct sctp_addr_wait *addrw = NULL;
+	union sctp_addr *addr = NULL;
+	struct sctp_ep_common *epb = NULL;
+	struct sctp_endpoint *ep = NULL;
+
+	spin_lock_bh(&sctp_addr_wq_lock);
+retry_wq:
+	if (list_empty(&sctp_addr_waitq)) {
+		SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: nothing in addr waitq\n");
+		spin_unlock_bh(&sctp_addr_wq_lock);
+		return;
+	}
+	addrw = list_first_entry(&sctp_addr_waitq, struct sctp_addr_wait, list);
+	if (addrw->cmd != SCTP_NEWADDR && addrw->cmd != SCTP_DELADDR) {
+		SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: cmd is neither NEWADDR nor DELADDR\n");
+		list_del(&addrw->list);
+		kfree(addrw);
+		goto retry_wq;
+	}
+
+	addr = &addrw->a;
+	SCTP_DEBUG_PRINTK_IPADDR("sctp_addrwq_timo_handler: the first ent in wq %p is ",
+	    " for cmd %d at entry %p\n", &sctp_addr_waitq, addr, addrw->cmd,
+	    addrw);
+
+	/* Now we send an ASCONF for each association */
+	/* Note. we currently don't handle link local IPv6 addressees */
+	if (addr->sa.sa_family == AF_INET6) {
+		struct in6_addr *in6 = (struct in6_addr *)&addr->v6.sin6_addr;
+
+		if (ipv6_addr_type(&addr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
+			SCTP_DEBUG_PRINTK("sctp_timo_handler: link local, hence don't tell eps\n");
+			list_del(&addrw->list);
+			kfree(addrw);
+			goto retry_wq;
+		}
+		if (ipv6_chk_addr(&init_net, in6, NULL, 0) == 0 &&
+		    addrw->cmd == SCTP_NEWADDR) {
+			unsigned long timeo_val;
+
+			SCTP_DEBUG_PRINTK("sctp_timo_handler: this is on DAD, trying %d sec later\n",
+			    SCTP_ADDRESS_TICK_DELAY);
+			timeo_val = jiffies;
+			timeo_val += msecs_to_jiffies(SCTP_ADDRESS_TICK_DELAY);
+			(void)mod_timer(&sctp_addr_wq_timer, timeo_val);
+			spin_unlock_bh(&sctp_addr_wq_lock);
+			return;
+		}
+	}
+	list_for_each_entry(epb, &sctp_auto_asconf_eplist, auto_asconf_list) {
+		if (epb == NULL) {
+			SCTP_DEBUG_PRINTK("addrwq_timo_handler: no epb\n");
+			continue;
+		}
+		if (!sctp_is_ep_boundall(epb->sk))
+			/* ignore bound-specific endpoints */
+			continue;
+		ep = sctp_ep(epb);
+		sctp_bh_lock_sock(epb->sk);
+		if (sctp_asconf_mgmt(ep) < 0) {
+			SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: sctp_asconf_mgmt failed\n");
+			sctp_bh_unlock_sock(epb->sk);
+			continue;
+		}
+		sctp_bh_unlock_sock(epb->sk);
+	}
+
+	list_del(&addrw->list);
+	kfree(addrw);
+
+	if (list_empty(&sctp_addr_waitq)) {
+		spin_unlock_bh(&sctp_addr_wq_lock);
+		return;
+	} else
+		goto retry_wq;
+
+	spin_unlock_bh(&sctp_addr_wq_lock);
+}
+
+static void sctp_free_addr_wq()
+{
+	struct sctp_addr_wait *addrw = NULL;
+	struct sctp_addr_wait *temp = NULL;
+
+	spin_lock_bh(&sctp_addr_wq_lock);
+	(void)del_timer(&sctp_addr_wq_timer);
+	list_for_each_entry_safe(addrw, temp, &sctp_addr_waitq, list) {
+		list_del(&addrw->list);
+		kfree(addrw);
+	}
+	spin_unlock_bh(&sctp_addr_wq_lock);
+}
+
+void sctp_addr_wq_mgmt(union sctp_addr *reqaddr, int cmd)
+{
+	struct sctp_addr_wait *addrw = NULL;
+	struct sctp_addr_wait *addrw_new = NULL;
+	unsigned long timeo_val;
+	union sctp_addr *tmpaddr;
+
+	/* first, we check if an opposite message already exist in the queue.
+	 * If we found such message, it is removed.
+	 * This operation is a bit stupid, but the DHCP client attaches the
+	 * new address after a couple of addition and deletion of that address
+	 */
+
+	if (reqaddr == NULL) {
+		SCTP_DEBUG_PRINTK("sctp_addr_wq_mgmt: no address message?\n");
+		return;
+	}
+
+	spin_lock_bh(&sctp_addr_wq_lock);
+	/* Offsets existing events in addr_wq */
+	list_for_each_entry(addrw, &sctp_addr_waitq, list) {
+		if (addrw->a.sa.sa_family != reqaddr->sa.sa_family)
+			continue;
+		if (reqaddr->sa.sa_family == AF_INET) {
+			if (reqaddr->v4.sin_addr.s_addr ==
+			    addrw->a.v4.sin_addr.s_addr) {
+				if (cmd != addrw->cmd) {
+					tmpaddr = &addrw->a;
+					SCTP_DEBUG_PRINTK_IPADDR("sctp_addr_wq_mgmt offsets existing entry for %d ",
+					    " in waitq %p\n", addrw->cmd,
+					    tmpaddr, &sctp_addr_waitq);
+					list_del(&addrw->list);
+					kfree(addrw);
+					/* nothing to do anymore */
+					spin_unlock_bh(&sctp_addr_wq_lock);
+					return;
+				}
+			}
+		} else if (reqaddr->sa.sa_family == AF_INET6) {
+			if (ipv6_addr_equal(&reqaddr->v6.sin6_addr,
+			    &addrw->a.v6.sin6_addr)) {
+				if (cmd != addrw->cmd) {
+					tmpaddr = &addrw->a;
+					SCTP_DEBUG_PRINTK_IPADDR("sctp_addr_wq_mgmt: offsets existing entry for %d ",
+					    " in waitq %p\n", addrw->cmd,
+					    tmpaddr, &sctp_addr_waitq);
+					list_del(&addrw->list);
+					kfree(addrw);
+					spin_unlock_bh(&sctp_addr_wq_lock);
+					return;
+				}
+			}
+		}
+	}
+
+	/* OK, we have to add the new address to the wait queue */
+	addrw_new = kzalloc(sizeof(struct sctp_addr_wait), GFP_ATOMIC);
+	if (addrw_new == NULL) {
+		SCTP_DEBUG_PRINTK("sctp_addr_weitq_mgmt no memory? return\n");
+		spin_unlock_bh(&sctp_addr_wq_lock);
+		return;
+	}
+	if (reqaddr->sa.sa_family == AF_INET) {
+		addrw_new->a.v4.sin_family = AF_INET;
+		addrw_new->a.v4.sin_addr.s_addr = reqaddr->v4.sin_addr.s_addr;
+	} else if (reqaddr->sa.sa_family == AF_INET6) {
+		addrw_new->a.v6.sin6_family = AF_INET6;
+		ipv6_addr_copy(&addrw_new->a.v6.sin6_addr,
+		    &reqaddr->v6.sin6_addr);
+	} else {
+		SCTP_DEBUG_PRINTK("sctp_addr_waitq_mgmt: Unknown family of request addr, return\n");
+		kfree(addrw_new);
+		spin_unlock_bh(&sctp_addr_wq_lock);
+		return;
+	}
+	addrw_new->cmd = cmd;
+	list_add_tail(&addrw_new->list, &sctp_addr_waitq);
+	tmpaddr = &addrw_new->a;
+	SCTP_DEBUG_PRINTK_IPADDR("sctp_addr_wq_mgmt add new entry for cmd:%d ",
+	    " in waitq %p, start a timer\n",
+	    addrw_new->cmd, tmpaddr, &sctp_addr_waitq);
+
+	if (timer_pending(&sctp_addr_wq_timer)) {
+		SCTP_DEBUG_PRINTK("sctp_addr_wq_mgmt: addr_wq timer is already running\n");
+		spin_unlock_bh(&sctp_addr_wq_lock);
+		return;
+	}
+	timeo_val = jiffies;
+	timeo_val += msecs_to_jiffies(SCTP_ADDRESS_TICK_DELAY);
+	(void)mod_timer(&sctp_addr_wq_timer, timeo_val);
+	spin_unlock_bh(&sctp_addr_wq_lock);
+}
+
 /* Event handler for inet address addition/deletion events.
  * The sctp_local_addr_list needs to be protocted by a spin lock since
  * multiple notifiers (say IPv4 and IPv6) may be running at the same
@@ -663,6 +851,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 			addr->valid = 1;
 			spin_lock_bh(&sctp_local_addr_lock);
 			list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
+			sctp_addr_wq_mgmt(&addr->a, SCTP_NEWADDR);
 			spin_unlock_bh(&sctp_local_addr_lock);
 		}
 		break;
@@ -673,6 +862,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 			if (addr->a.sa.sa_family == AF_INET &&
 					addr->a.v4.sin_addr.s_addr ==
 					ifa->ifa_local) {
+				sctp_addr_wq_mgmt(&addr->a, SCTP_DELADDR);
 				found = 1;
 				addr->valid = 0;
 				list_del_rcu(&addr->list);
@@ -1280,6 +1470,14 @@ SCTP_STATIC __init int sctp_init(void)
 	spin_lock_init(&sctp_local_addr_lock);
 	sctp_get_local_addr_list();
 
+	/* Initialize the address event list */
+	INIT_LIST_HEAD(&sctp_addr_waitq);
+	INIT_LIST_HEAD(&sctp_auto_asconf_eplist);
+	spin_lock_init(&sctp_addr_wq_lock);
+	sctp_addr_wq_timer.expires = 0;
+	setup_timer(&sctp_addr_wq_timer, sctp_addr_wq_timeout_handler,
+	    (unsigned long)NULL);
+
 	status = sctp_v4_protosw_init();
 
 	if (status)
@@ -1344,6 +1542,7 @@ err_chunk_cachep:
 /* Exit handler for the SCTP protocol.  */
 SCTP_STATIC __exit void sctp_exit(void)
 {
+	sctp_free_addr_wq();
 	/* BUG.  This should probably do something useful like clean
 	 * up all the remaining associations and all that memory.
 	 */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 3951a10..27dffa3 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -807,6 +807,47 @@ out:
 	return retval;
 }
 
+/* set addr events to assocs in the endpoint.  ep and addr_wq must be locked */
+int
+sctp_asconf_mgmt(struct sctp_endpoint *ep)
+{
+	struct sock *sk = ep->base.sk;
+	struct sctp_addr_wait *addrw = NULL;
+	union sctp_addr *addr = NULL;
+	int cmd;
+	int error = 0;
+
+	if (ep == NULL || sk == NULL)
+		return -EINVAL;
+	if (list_empty(&sctp_addr_waitq)) {
+		SCTP_DEBUG_PRINTK("asconf_mgmt: nothing in the wq\n");
+		return -EINVAL;
+	}
+	addrw = list_first_entry(&sctp_addr_waitq, struct sctp_addr_wait, list);
+	if (addrw->cmd != SCTP_NEWADDR && addrw->cmd != SCTP_DELADDR)
+		return -EINVAL;
+	addr = &addrw->a;
+	addr->v4.sin_port = htons(ep->base.bind_addr.port);
+	cmd = addrw->cmd;
+
+	SCTP_DEBUG_PRINTK("sctp_asconf_mgmt sk:%p ep:%p\n", sk, ep);
+	if (cmd == SCTP_NEWADDR) {
+		error = sctp_send_asconf_add_ip(sk, (struct sockaddr *)addr, 1);
+		if (error) {
+			SCTP_DEBUG_PRINTK("asconf_mgmt: send_asconf_add_ip returns %d\n", error);
+			return error;
+		}
+	} else if (cmd == SCTP_DELADDR) {
+		error = sctp_send_asconf_del_ip(sk, (struct sockaddr *)addr, 1);
+		if (error) {
+			SCTP_DEBUG_PRINTK("asconf_mgmt: send_asconf_del_ip returns %d\n", error);
+			return error;
+		}
+	}
+
+	return 0;
+}
+
 /* Helper for tunneling sctp_bindx() requests through sctp_setsockopt()
  *
  * API 8.1
@@ -3341,6 +3382,45 @@ static int sctp_setsockopt_del_key(struct sock *sk,
 
 }
 
+/*
+ * 8.1.23 SCTP_AUTO_ASCONF
+ *
+ * This option will enable or disable the use of the automatic generation of
+ * ASCONF chunks to add and delete addresses to an existing association.  Note
+ * that this option has two caveats namely: a) it only affects sockets that
+ * are bound to all addresses available to the SCTP stack, and b) the system
+ * administrator may have an overriding control that turns the ASCONF feature
+ * off no matter what setting the socket option may have.
+ * This option expects an integer boolean flag, where a non-zero value turns on
+ * the option, and a zero value turns off the option.
+ * Note. In this implementation, socket operation overrides default parameter
+ * being set by sysctl as well as FreeBSD implementation
+ */
+static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
+					unsigned int optlen)
+{
+	int val;
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+	if (!sctp_is_ep_boundall(sk) && val)
+		return -EINVAL;
+	if ((val && ep->do_auto_asconf) || (!val && !ep->do_auto_asconf))
+		return 0;
+
+	if (val == 0 && ep->do_auto_asconf) {
+		list_del(&ep->base.auto_asconf_list);
+		ep->do_auto_asconf = 0;
+	} else if (val && !ep->do_auto_asconf) {
+		list_add_tail(&ep->base.auto_asconf_list,
+		    &sctp_auto_asconf_eplist);
+		ep->do_auto_asconf = 1;
+	}
+	return 0;
+}
 
 /* API 6.2 setsockopt(), getsockopt()
  *
@@ -3488,6 +3568,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_AUTH_DELETE_KEY:
 		retval = sctp_setsockopt_del_key(sk, optval, optlen);
 		break;
+	case SCTP_AUTO_ASCONF:
+		retval = sctp_setsockopt_auto_asconf(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -3770,6 +3853,13 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	local_bh_disable();
 	percpu_counter_inc(&sctp_sockets_allocated);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	if (sctp_auto_asconf_enable) {
+		list_add_tail(&ep->base.auto_asconf_list,
+		    &sctp_auto_asconf_eplist);
+		ep->do_auto_asconf = 1;
+	} else
+		ep->do_auto_asconf = 0;
+	SCTP_DEBUG_PRINTK("sctp_init_sk sk:%p ep:%p\n", sk, ep);
 	local_bh_enable();
 
 	return 0;
@@ -3784,6 +3874,10 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 
 	/* Release our hold on the endpoint. */
 	ep = sctp_sk(sk)->ep;
+	if (ep->do_auto_asconf) {
+		ep->do_auto_asconf = 0;
+		list_del(&ep->base.auto_asconf_list);
+	}
 	sctp_endpoint_free(ep);
 	local_bh_disable();
 	percpu_counter_dec(&sctp_sockets_allocated);
@@ -5283,6 +5377,28 @@ static int sctp_getsockopt_assoc_number(struct sock *sk, int len,
 	return 0;
 }
 
+/*
+ * 8.1.23 SCTP_AUTO_ASCONF
+ * See the corresponding setsockopt entry as description
+ */
+static int sctp_getsockopt_auto_asconf(struct sock *sk, int len,
+				   char __user *optval, int __user *optlen)
+{
+	int val = 0;
+
+	if (len < sizeof(int))
+		return -EINVAL;
+
+	len = sizeof(int);
+	if (sctp_sk(sk)->ep->do_auto_asconf && sctp_is_ep_boundall(sk))
+		val = 1;
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+	return 0;
+}
+
 SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
@@ -5415,6 +5531,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_GET_ASSOC_NUMBER:
 		retval = sctp_getsockopt_assoc_number(sk, len, optval, optlen);
 		break;
+	case SCTP_AUTO_ASCONF:
+		retval = sctp_getsockopt_auto_asconf(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 50cb57f..df39789 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -183,6 +183,13 @@ static ctl_table sctp_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "auto_asconf_enable",
+		.data		= &sctp_auto_asconf_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "prsctp_enable",
 		.data		= &sctp_prsctp_enable,
 		.maxlen		= sizeof(int),

