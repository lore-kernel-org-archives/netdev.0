From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/6) ipvs -- use reader locks and refcounts correctly.
Date: Tue, 16 Sep 2003 14:21:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916142116.58a05005.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The code to get the service table was not taking a reader lock
because it needed to copy_to_user.

Do it right:
	- hold refcnt when copying out, and use a read lock
	- make lock local to ip_svc
	- get rid of IP_VS_WAIT_WHILE, use proper read locks and refcounts.
	- move write_lock_bh in flush to outside of loop
	- tag user pointers (for sparse).

diff -Nru a/include/net/ip_vs.h b/include/net/ip_vs.h
--- a/include/net/ip_vs.h	Tue Sep 16 14:08:55 2003
+++ b/include/net/ip_vs.h	Tue Sep 16 14:08:55 2003
@@ -319,8 +319,6 @@
 #define LeaveFunction(level)   do {} while (0)
 #endif
 
-#define	IP_VS_WAIT_WHILE(expr)	while (expr) { cpu_relax(); }
-
 
 /*
  *      The port number of FTP service (in network order).
diff -Nru a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
--- a/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:55 2003
+++ b/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:55 2003
@@ -48,7 +48,7 @@
 static DECLARE_MUTEX(__ip_vs_mutex);
 
 /* lock for service table */
-rwlock_t __ip_vs_svc_lock = RW_LOCK_UNLOCKED;
+static rwlock_t __ip_vs_svc_lock = RW_LOCK_UNLOCKED;
 
 /* lock for table with the real services */
 static rwlock_t __ip_vs_rs_lock = RW_LOCK_UNLOCKED;
@@ -808,11 +808,6 @@
 
 		write_lock_bh(&__ip_vs_svc_lock);
 
-		/*
-		 * Wait until all other svc users go away.
-		 */
-		IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
-
 		list_add(&dest->n_list, &svc->destinations);
 		svc->num_dests++;
 
@@ -838,11 +833,6 @@
 
 	write_lock_bh(&__ip_vs_svc_lock);
 
-	/*
-	 * Wait until all other svc users go away.
-	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
-
 	list_add(&dest->n_list, &svc->destinations);
 	svc->num_dests++;
 
@@ -980,12 +970,6 @@
 	}
 
 	write_lock_bh(&__ip_vs_svc_lock);
-
-	/*
-	 *	Wait until all other svc users go away.
-	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
-
 	/*
 	 *	Unlink dest from the service
 	 */
@@ -1118,11 +1102,6 @@
 	write_lock_bh(&__ip_vs_svc_lock);
 
 	/*
-	 * Wait until all other svc users go away.
-	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
-
-	/*
 	 * Set the flags and timeout value
 	 */
 	svc->flags = u->flags | IP_VS_SVC_F_HASHED;
@@ -1235,11 +1214,6 @@
 
 	ip_vs_svc_unhash(svc);
 
-	/*
-	 * Wait until all the svc users go away.
-	 */
-	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
-
 	__ip_vs_del_service(svc);
 
 	write_unlock_bh(&__ip_vs_svc_lock);
@@ -1259,16 +1233,11 @@
 	/*
 	 * Flush the service table hashed by <protocol,addr,port>
 	 */
+	write_lock_bh(&__ip_vs_svc_lock);
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx], s_list) {
-			write_lock_bh(&__ip_vs_svc_lock);
 			ip_vs_svc_unhash(svc);
-			/*
-			 * Wait until all the svc users go away.
-			 */
-			IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
 			__ip_vs_del_service(svc);
-			write_unlock_bh(&__ip_vs_svc_lock);
 		}
 	}
 
@@ -1278,16 +1247,11 @@
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry_safe(svc, nxt, 
 					 &ip_vs_svc_fwm_table[idx], f_list) {
-			write_lock_bh(&__ip_vs_svc_lock);
 			ip_vs_svc_unhash(svc);
-			/*
-			 * Wait until all the svc users go away.
-			 */
-			IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 0);
 			__ip_vs_del_service(svc);
-			write_unlock_bh(&__ip_vs_svc_lock);
 		}
 	}
+	write_unlock_bh(&__ip_vs_svc_lock);
 
 	return 0;
 }
@@ -1926,7 +1890,7 @@
 
 static inline int
 __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
-			    struct ip_vs_get_services *uptr)
+			    struct ip_vs_get_services __user *uptr)
 {
 	int idx, count=0;
 	struct ip_vs_service *svc;
@@ -1966,7 +1930,7 @@
 
 static inline int
 __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
-			 struct ip_vs_get_dests *uptr)
+			 struct ip_vs_get_dests __user *uptr)
 {
 	struct ip_vs_service *svc;
 	int ret = 0;
@@ -1981,6 +1945,7 @@
 		struct ip_vs_dest *dest;
 		struct ip_vs_dest_entry entry;
 
+		read_lock_bh(&__ip_vs_svc_lock);
 		list_for_each_entry(dest, &svc->destinations, n_list) {
 			if (count >= get->num_dests)
 				break;
@@ -1994,15 +1959,25 @@
 			entry.activeconns = atomic_read(&dest->activeconns);
 			entry.inactconns = atomic_read(&dest->inactconns);
 			entry.persistconns = atomic_read(&dest->persistconns);
+
 			ip_vs_copy_stats(&entry.stats, &dest->stats);
+
+			atomic_inc(&dest->refcnt);
+			read_unlock_bh(&__ip_vs_svc_lock);
 			if (copy_to_user(&uptr->entrytable[count],
 					 &entry, sizeof(entry))) {
 				ret = -EFAULT;
 				break;
 			}
 			count++;
+
+			read_lock_bh(&__ip_vs_svc_lock);
+			if (atomic_dec_and_test(&dest->refcnt)) 
+				kfree(dest);
+
 		}
 		ip_vs_service_put(svc);
+		read_unlock_bh(&__ip_vs_svc_lock);
 	} else
 		ret = -ESRCH;
 	return ret;
@@ -2043,7 +2018,7 @@
 };
 
 static int
-do_ip_vs_get_ctl(struct sock *sk, int cmd, void *user, int *len)
+do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
 	unsigned char arg[128];
 	int ret = 0;
