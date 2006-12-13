From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/4][SCTP]: Handle address add/delete events in a more
	efficient way.
Date: Wed, 13 Dec 2006 12:44:44 -0800
Message-ID: <1166042684.4670.10.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:53876 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794AbWLMUpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 15:45:03 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDKjKcF011882
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:45:20 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDKirHI243154
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:53 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDKiqnb030462
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 15:44:53 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Handle address add/delete events in a more efficient way.

Currently in SCTP, we maintain a local address list by rebuilding the whole
list from the device list whenever we get a address add/delete event.

This patch fixes it by only adding/deleting the address for which we
receive the event.

Also removed the sctp_local_addr_lock() which is no longer needed as we
now use list_for_each_safe() to traverse this list. This fixes the bugs
in sctp_copy_laddrs_xxx() routines where we do copy_to_user() while
holding this lock.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/structs.h |    6 +---
 net/sctp/ipv6.c            |   38 ++++++++++++++++++++++++
 net/sctp/protocol.c        |   69 ++++++++++++++++++++------------------------
 net/sctp/socket.c          |   34 ++++++----------------
 4 files changed, 81 insertions(+), 66 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index c089f93..b00d85e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -201,13 +201,12 @@ extern struct sctp_globals {
 	struct sctp_bind_hashbucket *port_hashtable;
 
 	/* This is the global local address list.
-	 * We actively maintain this complete list of interfaces on
-	 * the system by catching routing events.
+	 * We actively maintain this complete list of addresses on
+	 * the system by catching address add/delete events.
 	 *
 	 * It is a list of sctp_sockaddr_entry.
 	 */
 	struct list_head local_addr_list;
-	spinlock_t local_addr_lock;
 	
 	/* Flag to indicate if addip is enabled. */
 	int addip_enable;
@@ -243,7 +242,6 @@ #define sctp_port_rover			(sctp_globals.
 #define sctp_port_alloc_lock		(sctp_globals.port_alloc_lock)
 #define sctp_port_hashtable		(sctp_globals.port_hashtable)
 #define sctp_local_addr_list		(sctp_globals.local_addr_list)
-#define sctp_local_addr_lock		(sctp_globals.local_addr_lock)
 #define sctp_addip_enable		(sctp_globals.addip_enable)
 #define sctp_prsctp_enable		(sctp_globals.prsctp_enable)
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 3c3e560..d8d36de 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -78,8 +78,44 @@ #include <net/sctp/sctp.h>
 
 #include <asm/uaccess.h>
 
+/* Event handler for inet6 address addition/deletion events.  */
+int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
+                        void *ptr)
+{
+	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
+	struct sctp_sockaddr_entry *addr;
+	struct list_head *pos, *temp;
+
+	switch (ev) {
+	case NETDEV_UP:
+		addr = kmalloc(sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
+		if (addr) {
+			addr->a.v6.sin6_family = AF_INET6;
+			addr->a.v6.sin6_port = 0;
+			memcpy(&addr->a.v6.sin6_addr, &ifa->addr,
+				 sizeof(struct in6_addr));
+			addr->a.v6.sin6_scope_id = ifa->idev->dev->ifindex;
+			list_add_tail(&addr->list, &sctp_local_addr_list);
+		}
+		break;
+	case NETDEV_DOWN:
+		list_for_each_safe(pos, temp, &sctp_local_addr_list) {
+			addr = list_entry(pos, struct sctp_sockaddr_entry, list);
+			if (ipv6_addr_equal(&addr->a.v6.sin6_addr, &ifa->addr)) {
+				list_del(pos);
+				kfree(addr);
+				break;
+			}
+		}
+
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
 static struct notifier_block sctp_inet6addr_notifier = {
-	.notifier_call = sctp_inetaddr_event,
+	.notifier_call = sctp_inet6addr_event,
 };
 
 /* ICMP error handler. */
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index f2ba861..b61f334 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -163,7 +163,7 @@ static void sctp_v4_copy_addrlist(struct
 /* Extract our IP addresses from the system and stash them in the
  * protocol structure.
  */
-static void __sctp_get_local_addr_list(void)
+static void sctp_get_local_addr_list(void)
 {
 	struct net_device *dev;
 	struct list_head *pos;
@@ -179,17 +179,8 @@ static void __sctp_get_local_addr_list(v
 	read_unlock(&dev_base_lock);
 }
 
-static void sctp_get_local_addr_list(void)
-{
-	unsigned long flags;
-
-	sctp_spin_lock_irqsave(&sctp_local_addr_lock, flags);
-	__sctp_get_local_addr_list();
-	sctp_spin_unlock_irqrestore(&sctp_local_addr_lock, flags);
-}
-
 /* Free the existing local addresses.  */
-static void __sctp_free_local_addr_list(void)
+static void sctp_free_local_addr_list(void)
 {
 	struct sctp_sockaddr_entry *addr;
 	struct list_head *pos, *temp;
@@ -201,27 +192,15 @@ static void __sctp_free_local_addr_list(
 	}
 }
 
-/* Free the existing local addresses.  */
-static void sctp_free_local_addr_list(void)
-{
-	unsigned long flags;
-
-	sctp_spin_lock_irqsave(&sctp_local_addr_lock, flags);
-	__sctp_free_local_addr_list();
-	sctp_spin_unlock_irqrestore(&sctp_local_addr_lock, flags);
-}
-
 /* Copy the local addresses which are valid for 'scope' into 'bp'.  */
 int sctp_copy_local_addr_list(struct sctp_bind_addr *bp, sctp_scope_t scope,
 			      gfp_t gfp, int copy_flags)
 {
 	struct sctp_sockaddr_entry *addr;
 	int error = 0;
-	struct list_head *pos;
-	unsigned long flags;
+	struct list_head *pos, *temp;
 
-	sctp_spin_lock_irqsave(&sctp_local_addr_lock, flags);
-	list_for_each(pos, &sctp_local_addr_list) {
+	list_for_each_safe(pos, temp, &sctp_local_addr_list) {
 		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
 		if (sctp_in_scope(&addr->a, scope)) {
 			/* Now that the address is in scope, check to see if
@@ -242,7 +221,6 @@ int sctp_copy_local_addr_list(struct sct
 	}
 
 end_copy:
-	sctp_spin_unlock_irqrestore(&sctp_local_addr_lock, flags);
 	return error;
 }
 
@@ -622,18 +600,36 @@ static void sctp_v4_seq_dump_addr(struct
 	seq_printf(seq, "%d.%d.%d.%d ", NIPQUAD(addr->v4.sin_addr));
 }
 
-/* Event handler for inet address addition/deletion events.
- * Basically, whenever there is an event, we re-build our local address list.
- */
+/* Event handler for inet address addition/deletion events.  */
 int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
                         void *ptr)
 {
-	unsigned long flags;
+	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
+	struct sctp_sockaddr_entry *addr;
+	struct list_head *pos, *temp;
 
-	sctp_spin_lock_irqsave(&sctp_local_addr_lock, flags);
-	__sctp_free_local_addr_list();
-	__sctp_get_local_addr_list();
-	sctp_spin_unlock_irqrestore(&sctp_local_addr_lock, flags);
+	switch (ev) {
+	case NETDEV_UP:
+		addr = kmalloc(sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
+		if (addr) {
+			addr->a.v4.sin_family = AF_INET;
+			addr->a.v4.sin_port = 0;
+			addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
+			list_add_tail(&addr->list, &sctp_local_addr_list);
+		}
+		break;
+	case NETDEV_DOWN:
+		list_for_each_safe(pos, temp, &sctp_local_addr_list) {
+			addr = list_entry(pos, struct sctp_sockaddr_entry, list);
+			if (addr->a.v4.sin_addr.s_addr == ifa->ifa_local) {
+				list_del(pos);
+				kfree(addr);
+				break;
+			}
+		}
+
+		break;
+	}
 
 	return NOTIFY_DONE;
 }
@@ -1172,13 +1168,12 @@ SCTP_STATIC __init int sctp_init(void)
 
 	/* Initialize the local address list. */
 	INIT_LIST_HEAD(&sctp_local_addr_list);
-	spin_lock_init(&sctp_local_addr_lock);
+
+	sctp_get_local_addr_list();
 
 	/* Register notifier for inet address additions/deletions. */
 	register_inetaddr_notifier(&sctp_inetaddr_notifier);
 
-	sctp_get_local_addr_list();
-
 	__unsafe(THIS_MODULE);
 	status = 0;
 out:
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1e8132b..fa29eae 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3821,10 +3821,9 @@ static int sctp_getsockopt_local_addrs_n
 	sctp_assoc_t id;
 	struct sctp_bind_addr *bp;
 	struct sctp_association *asoc;
-	struct list_head *pos;
+	struct list_head *pos, *temp;
 	struct sctp_sockaddr_entry *addr;
 	rwlock_t *addr_lock;
-	unsigned long flags;
 	int cnt = 0;
 
 	if (len != sizeof(sctp_assoc_t))
@@ -3859,8 +3858,7 @@ static int sctp_getsockopt_local_addrs_n
 		addr = list_entry(bp->address_list.next,
 				  struct sctp_sockaddr_entry, list);
 		if (sctp_is_any(&addr->a)) {
-			sctp_spin_lock_irqsave(&sctp_local_addr_lock, flags);
-			list_for_each(pos, &sctp_local_addr_list) {
+			list_for_each_safe(pos, temp, &sctp_local_addr_list) {
 				addr = list_entry(pos,
 						  struct sctp_sockaddr_entry,
 						  list);
@@ -3869,8 +3867,6 @@ static int sctp_getsockopt_local_addrs_n
 					continue;
 				cnt++;
 			}
-			sctp_spin_unlock_irqrestore(&sctp_local_addr_lock,
-						    flags);
 		} else {
 			cnt = 1;
 		}
@@ -3892,15 +3888,13 @@ done:
 static int sctp_copy_laddrs_to_user_old(struct sock *sk, __u16 port, int max_addrs,
 					void __user *to)
 {
-	struct list_head *pos;
+	struct list_head *pos, *next;
 	struct sctp_sockaddr_entry *addr;
-	unsigned long flags;
 	union sctp_addr temp;
 	int cnt = 0;
 	int addrlen;
 
-	sctp_spin_lock_irqsave(&sctp_local_addr_lock, flags);
-	list_for_each(pos, &sctp_local_addr_list) {
+	list_for_each_safe(pos, next, &sctp_local_addr_list) {
 		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
 		if ((PF_INET == sk->sk_family) && 
 		    (AF_INET6 == addr->a.sa.sa_family))
@@ -3909,16 +3903,13 @@ static int sctp_copy_laddrs_to_user_old(
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
 								&temp);
 		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
-		if (copy_to_user(to, &temp, addrlen)) {
-			sctp_spin_unlock_irqrestore(&sctp_local_addr_lock,
-						    flags);
+		if (copy_to_user(to, &temp, addrlen))
 			return -EFAULT;
-		}
+
 		to += addrlen;
 		cnt ++;
 		if (cnt >= max_addrs) break;
 	}
-	sctp_spin_unlock_irqrestore(&sctp_local_addr_lock, flags);
 
 	return cnt;
 }
@@ -3926,15 +3917,13 @@ static int sctp_copy_laddrs_to_user_old(
 static int sctp_copy_laddrs_to_user(struct sock *sk, __u16 port,
 				    void __user **to, size_t space_left)
 {
-	struct list_head *pos;
+	struct list_head *pos, *next;
 	struct sctp_sockaddr_entry *addr;
-	unsigned long flags;
 	union sctp_addr temp;
 	int cnt = 0;
 	int addrlen;
 
-	sctp_spin_lock_irqsave(&sctp_local_addr_lock, flags);
-	list_for_each(pos, &sctp_local_addr_list) {
+	list_for_each_safe(pos, next, &sctp_local_addr_list) {
 		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
 		if ((PF_INET == sk->sk_family) && 
 		    (AF_INET6 == addr->a.sa.sa_family))
@@ -3945,16 +3934,13 @@ static int sctp_copy_laddrs_to_user(stru
 		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
 		if(space_left<addrlen)
 			return -ENOMEM;
-		if (copy_to_user(*to, &temp, addrlen)) {
-			sctp_spin_unlock_irqrestore(&sctp_local_addr_lock,
-						    flags);
+		if (copy_to_user(*to, &temp, addrlen))
 			return -EFAULT;
-		}
+
 		*to += addrlen;
 		cnt ++;
 		space_left -= addrlen;
 	}
-	sctp_spin_unlock_irqrestore(&sctp_local_addr_lock, flags);
 
 	return cnt;
 }


