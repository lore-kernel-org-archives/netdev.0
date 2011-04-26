From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v7 1/5] sctp: Add Auto-ASCONF support
Date: Tue, 26 Apr 2011 17:35:52 +0900
Message-ID: <2418F0AB-37A2-4B85-8723-32D92A48B7DA@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:56610 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751676Ab1DZIfx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 04:35:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP reconfigure the IP addresses in the association by using ASCONF chunks as mentioned in RFC5061.  
For example, we can start to use the newly configured IP address in the existing association.  
ASCONF operation is invoked in two ways: 
First is done by the application to call sctp_bindx() system call.  
Second is automatic operation in the SCTP stack with address events in the host computer (called auto_asconf) .  
The former is already implemented, and this patch implement the latter.  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 7e8e34c..872ffa0 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -121,6 +121,8 @@ extern int sctp_copy_local_addr_list(struct sctp_bind_addr *,
 				     int flags);
 extern struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
 extern int sctp_register_pf(struct sctp_pf *, sa_family_t);
+void sctp_addr_wq_mgmt(struct sctp_sockaddr_entry *, int);
+void sctp_free_addr_wq(void);
 
 /*
  * sctp/socket.c
@@ -135,6 +137,7 @@ void sctp_sock_rfree(struct sk_buff *skb);
 void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 		    struct sctp_association *asoc);
 extern struct percpu_counter sctp_sockets_allocated;
+int sctp_asconf_mgmt(struct sctp_sock *, struct sctp_sockaddr_entry *);
 
 /*
  * sctp/primitive.c
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 5c9bada..f7f6add 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -205,6 +205,11 @@ extern struct sctp_globals {
 	 * It is a list of sctp_sockaddr_entry.
 	 */
 	struct list_head local_addr_list;
+	int default_auto_asconf;
+	struct list_head addr_waitq;
+	struct timer_list addr_wq_timer;
+	struct list_head auto_asconf_splist;
+	spinlock_t addr_wq_lock;
 
 	/* Lock that protects the local_addr_list writers */
 	spinlock_t addr_list_lock;
@@ -264,6 +269,11 @@ extern struct sctp_globals {
 #define sctp_port_hashtable		(sctp_globals.port_hashtable)
 #define sctp_local_addr_list		(sctp_globals.local_addr_list)
 #define sctp_local_addr_lock		(sctp_globals.addr_list_lock)
+#define sctp_auto_asconf_splist		(sctp_globals.auto_asconf_splist)
+#define sctp_addr_waitq			(sctp_globals.addr_waitq)
+#define sctp_addr_wq_timer		(sctp_globals.addr_wq_timer)
+#define sctp_addr_wq_lock		(sctp_globals.addr_wq_lock)
+#define sctp_default_auto_asconf	(sctp_globals.default_auto_asconf)
 #define sctp_scope_policy		(sctp_globals.ipv4_scope_policy)
 #define sctp_addip_enable		(sctp_globals.addip_enable)
 #define sctp_addip_noauth		(sctp_globals.addip_noauth_enable)
@@ -341,6 +351,8 @@ struct sctp_sock {
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
 	struct sk_buff_head pd_lobby;
+	struct list_head auto_asconf_list;
+	int do_auto_asconf;
 };
 
 static inline struct sctp_sock *sctp_sk(const struct sock *sk)
@@ -796,6 +808,8 @@ struct sctp_sockaddr_entry {
 	__u8 valid;
 };
 
+#define SCTP_ADDRESS_TICK_DELAY	500
+
 typedef struct sctp_chunk *(sctp_packet_phandler_t)(struct sctp_association *);
 
 /* This structure holds lists of chunks as we are assembling for
@@ -1239,6 +1253,7 @@ sctp_scope_t sctp_scope(const union sctp_addr *);
 int sctp_in_scope(const union sctp_addr *addr, const sctp_scope_t scope);
 int sctp_is_any(struct sock *sk, const union sctp_addr *addr);
 int sctp_addr_is_valid(const union sctp_addr *addr);
+int sctp_is_ep_boundall(struct sock *sk);
 
 
 /* What type of endpoint?  */
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index faf71d1..869267b 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -536,6 +536,21 @@ int sctp_in_scope(const union sctp_addr *addr, sctp_scope_t scope)
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
+	}
+	return 0;
+}
+
 /********************************************************************
  * 3rd Level Abstractions
  ********************************************************************/
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 321f175..233eb3a 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -105,6 +105,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 			addr->valid = 1;
 			spin_lock_bh(&sctp_local_addr_lock);
 			list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
+			sctp_addr_wq_mgmt(addr, SCTP_ADDR_NEW);
 			spin_unlock_bh(&sctp_local_addr_lock);
 		}
 		break;
@@ -115,6 +116,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 			if (addr->a.sa.sa_family == AF_INET6 &&
 					ipv6_addr_equal(&addr->a.v6.sin6_addr,
 						&ifa->addr)) {
+				sctp_addr_wq_mgmt(addr, SCTP_ADDR_DEL);
 				found = 1;
 				addr->valid = 0;
 				list_del_rcu(&addr->list);
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d5bf91d..638bafc 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -636,6 +636,160 @@ static void sctp_v4_ecn_capable(struct sock *sk)
 	INET_ECN_xmit(sk);
 }
 
+void sctp_addr_wq_timeout_handler(unsigned long arg)
+{
+	struct sctp_sockaddr_entry *addrw = NULL;
+	union sctp_addr *addr = NULL;
+	struct sctp_sock *sp = NULL;
+
+	spin_lock_bh(&sctp_addr_wq_lock);
+retry_wq:
+	if (list_empty(&sctp_addr_waitq)) {
+		SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: nothing in addr waitq\n");
+		spin_unlock_bh(&sctp_addr_wq_lock);
+		return;
+	}
+	addrw = list_first_entry(&sctp_addr_waitq, struct sctp_sockaddr_entry,
+			list);
+	addr = &addrw->a;
+	SCTP_DEBUG_PRINTK_IPADDR("sctp_addrwq_timo_handler: the first ent in wq %p is ",
+	    " for cmd %d at entry %p\n", &sctp_addr_waitq, addr, addrw->state,
+	    addrw);
+
+	/* Now we send an ASCONF for each association */
+	/* Note. we currently don't handle link local IPv6 addressees */
+	if (addr->sa.sa_family == AF_INET6) {
+		struct in6_addr *in6 = (struct in6_addr *)&addr->v6.sin6_addr;
+
+		if (ipv6_addr_type(&addr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
+			SCTP_DEBUG_PRINTK("sctp_timo_handler: link local, hence don't tell sockets\n");
+			list_del(&addrw->list);
+			kfree(addrw);
+			goto retry_wq;
+		}
+		if (ipv6_chk_addr(&init_net, in6, NULL, 0) == 0 &&
+		    addrw->state == SCTP_ADDR_NEW) {
+			unsigned long timeo_val;
+
+			SCTP_DEBUG_PRINTK("sctp_timo_handler: this is on DAD, trying %d sec later\n",
+			    SCTP_ADDRESS_TICK_DELAY);
+			timeo_val = jiffies;
+			timeo_val += msecs_to_jiffies(SCTP_ADDRESS_TICK_DELAY);
+			mod_timer(&sctp_addr_wq_timer, timeo_val);
+			spin_unlock_bh(&sctp_addr_wq_lock);
+			return;
+		}
+	}
+	list_for_each_entry(sp, &sctp_auto_asconf_splist, auto_asconf_list) {
+		struct sock *sk;
+
+		sk = sctp_opt2sk(sp);
+		/* ignore bound-specific endpoints */
+		if (!sctp_is_ep_boundall(sk))
+			continue;
+		sctp_bh_lock_sock(sk);
+		if (sctp_asconf_mgmt(sp, addrw) < 0) {
+			SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: sctp_asconf_mgmt failed\n");
+			sctp_bh_unlock_sock(sk);
+			continue;
+		}
+		sctp_bh_unlock_sock(sk);
+	}
+
+	list_del(&addrw->list);
+	kfree(addrw);
+
+	if (!list_empty(&sctp_addr_waitq))
+		goto retry_wq;
+
+	spin_unlock_bh(&sctp_addr_wq_lock);
+}
+
+void sctp_free_addr_wq()
+{
+	struct sctp_sockaddr_entry *addrw = NULL;
+	struct sctp_sockaddr_entry *temp = NULL;
+
+	spin_lock_bh(&sctp_addr_wq_lock);
+	del_timer(&sctp_addr_wq_timer);
+	list_for_each_entry_safe(addrw, temp, &sctp_addr_waitq, list) {
+		list_del(&addrw->list);
+		kfree(addrw);
+	}
+	spin_unlock_bh(&sctp_addr_wq_lock);
+}
+
+/* lookup the entry for the same address in the addr_waitq
+ * sctp_addr_wq MUST be locked
+ */
+static struct sctp_sockaddr_entry *sctp_addr_wq_lookup(struct sctp_sockaddr_entry *addr)
+{
+	struct sctp_sockaddr_entry *addrw;
+
+	list_for_each_entry(addrw, &sctp_addr_waitq, list) {
+		if (addrw->a.sa.sa_family != addr->a.sa.sa_family)
+			continue;
+		if (addrw->a.sa.sa_family == AF_INET) {
+			if (addrw->a.v4.sin_addr.s_addr ==
+			    addr->a.v4.sin_addr.s_addr)
+				return addrw;
+		} else if (addrw->a.sa.sa_family == AF_INET6) {
+			if (ipv6_addr_equal(&addrw->a.v6.sin6_addr,
+			    &addr->a.v6.sin6_addr))
+				return addrw;
+		}
+	}
+	return NULL;
+}
+
+void sctp_addr_wq_mgmt(struct sctp_sockaddr_entry *addr, int cmd)
+{
+	struct sctp_sockaddr_entry *addrw = NULL;
+	unsigned long timeo_val;
+	union sctp_addr *tmpaddr;
+
+	/* first, we check if an opposite message already exist in the queue.
+	 * If we found such message, it is removed.
+	 * This operation is a bit stupid, but the DHCP client attaches the
+	 * new address after a couple of addition and deletion of that address
+	 */
+
+	spin_lock_bh(&sctp_addr_wq_lock);
+	/* Offsets existing events in addr_wq */
+	addrw = sctp_addr_wq_lookup(addr);
+	tmpaddr = &addrw->a;
+	if (addrw) {
+		if (addrw->state != cmd) {
+			SCTP_DEBUG_PRINTK_IPADDR("sctp_addr_wq_mgmt offsets existing entry for %d ",
+			    " in wq %p\n", addrw->state, tmpaddr,
+			    &sctp_addr_waitq);
+			list_del(&addrw->list);
+			kfree(addrw);
+		}
+		spin_unlock_bh(&sctp_addr_wq_lock);
+		return;
+	}
+
+	/* OK, we have to add the new address to the wait queue */
+	addrw = kmemdup(addr, sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
+	if (addrw == NULL) {
+		spin_unlock_bh(&sctp_addr_wq_lock);
+		return;
+	}
+	addrw->state = cmd;
+	list_add_tail(&addrw->list, &sctp_addr_waitq);
+	tmpaddr = &addrw->a;
+	SCTP_DEBUG_PRINTK_IPADDR("sctp_addr_wq_mgmt add new entry for cmd:%d ",
+	    " in wq %p\n", addrw->state, tmpaddr, &sctp_addr_waitq);
+
+	if (!timer_pending(&sctp_addr_wq_timer)) {
+		timeo_val = jiffies;
+		timeo_val += msecs_to_jiffies(SCTP_ADDRESS_TICK_DELAY);
+		mod_timer(&sctp_addr_wq_timer, timeo_val);
+	}
+	spin_unlock_bh(&sctp_addr_wq_lock);
+}
+
 /* Event handler for inet address addition/deletion events.
  * The sctp_local_addr_list needs to be protocted by a spin lock since
  * multiple notifiers (say IPv4 and IPv6) may be running at the same
@@ -663,6 +817,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 			addr->valid = 1;
 			spin_lock_bh(&sctp_local_addr_lock);
 			list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
+			sctp_addr_wq_mgmt(addr, SCTP_ADDR_NEW);
 			spin_unlock_bh(&sctp_local_addr_lock);
 		}
 		break;
@@ -673,6 +828,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 			if (addr->a.sa.sa_family == AF_INET &&
 					addr->a.v4.sin_addr.s_addr ==
 					ifa->ifa_local) {
+				sctp_addr_wq_mgmt(addr, SCTP_ADDR_DEL);
 				found = 1;
 				addr->valid = 0;
 				list_del_rcu(&addr->list);
@@ -1256,6 +1412,7 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Disable ADDIP by default. */
 	sctp_addip_enable = 0;
 	sctp_addip_noauth = 0;
+	sctp_default_auto_asconf = 0;
 
 	/* Enable PR-SCTP by default. */
 	sctp_prsctp_enable = 1;
@@ -1280,6 +1437,13 @@ SCTP_STATIC __init int sctp_init(void)
 	spin_lock_init(&sctp_local_addr_lock);
 	sctp_get_local_addr_list();
 
+	/* Initialize the address event list */
+	INIT_LIST_HEAD(&sctp_addr_waitq);
+	INIT_LIST_HEAD(&sctp_auto_asconf_splist);
+	spin_lock_init(&sctp_addr_wq_lock);
+	sctp_addr_wq_timer.expires = 0;
+	setup_timer(&sctp_addr_wq_timer, sctp_addr_wq_timeout_handler, 0);
+
 	status = sctp_v4_protosw_init();
 
 	if (status)
@@ -1351,6 +1515,7 @@ SCTP_STATIC __exit void sctp_exit(void)
 	/* Unregister with inet6/inet layers. */
 	sctp_v6_del_protocol();
 	sctp_v4_del_protocol();
+	sctp_free_addr_wq();
 
 	/* Free the control endpoint.  */
 	inet_ctl_sock_destroy(sctp_ctl_sock);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f694ee1..fb183c5 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -811,6 +811,37 @@ out:
 	return retval;
 }
 
+/* set addr events to assocs in the endpoint.  ep and addr_wq must be locked */
+int
+sctp_asconf_mgmt(struct sctp_sock *sp, struct sctp_sockaddr_entry *addrw)
+{
+	struct sock *sk = sctp_opt2sk(sp);
+	union sctp_addr *addr = NULL;
+	int cmd;
+	int error = 0;
+
+	addr = &addrw->a;
+	addr->v4.sin_port = htons(sp->ep->base.bind_addr.port);
+	cmd = addrw->state;
+
+	SCTP_DEBUG_PRINTK("sctp_asconf_mgmt sp:%p\n", sp);
+	if (cmd == SCTP_ADDR_NEW) {
+		error = sctp_send_asconf_add_ip(sk, (struct sockaddr *)addr, 1);
+		if (error) {
+			SCTP_DEBUG_PRINTK("asconf_mgmt: send_asconf_add_ip returns %d\n", error);
+			return error;
+		}
+	} else if (cmd == SCTP_ADDR_DEL) {
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
@@ -3764,6 +3795,13 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	local_bh_disable();
 	percpu_counter_inc(&sctp_sockets_allocated);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	if (sctp_default_auto_asconf) {
+		list_add_tail(&sp->auto_asconf_list,
+		    &sctp_auto_asconf_splist);
+		sp->do_auto_asconf = 1;
+	} else
+		sp->do_auto_asconf = 0;
+	SCTP_DEBUG_PRINTK("sctp_init_sk sk:%p ep:%p\n", sk, ep);
 	local_bh_enable();
 
 	return 0;
@@ -3773,11 +3811,17 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 {
 	struct sctp_endpoint *ep;
+	struct sctp_sock *sp;
 
 	SCTP_DEBUG_PRINTK("sctp_destroy_sock(sk: %p)\n", sk);
 
 	/* Release our hold on the endpoint. */
-	ep = sctp_sk(sk)->ep;
+	sp = sctp_sk(sk);
+	ep = sp->ep;
+	if (sp->do_auto_asconf) {
+		sp->do_auto_asconf = 0;
+		list_del(&sp->auto_asconf_list);
+	}
 	sctp_endpoint_free(ep);
 	local_bh_disable();
 	percpu_counter_dec(&sctp_sockets_allocated);

