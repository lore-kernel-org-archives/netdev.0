From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] NULL pointer deref in tcp_do_twkill_work()
Date: Fri, 27 Feb 2004 14:34:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040227143445.27dd03bf.davem@redhat.com>
References: <Pine.A41.4.44.0402271256450.50098-200000@forte.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com,
        anton@samba.org, milliner@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: olof@austin.ibm.com, davidm@napali.hpl.hp.com, akpm@osdl.org
In-Reply-To: <Pine.A41.4.44.0402271256450.50098-200000@forte.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Feb 2004 16:09:21 -0600 (CST)
olof@austin.ibm.com wrote:

> This bug has been encountered before (ref http://bugme.osdl.org/show_bug.cgi?id=1627),
> but that time it went away by itself. We're now seeing it again with
> another heavy network load on 2.6.3.

Olaf, you are a life saver.

David Mosberger just recently told me that ia64 is hitting this  problem
again too and I believe your analysis is perfect.

Yes, we cannot cache the 'safe' pointer in tcp_do_twkill_work() while the lock
is not held, and YES another cpu can kill off the bucket that 'safe' points to.

This patch should fix everything up.  Let me know how it goes.

===== include/net/tcp.h 1.56 vs edited =====
--- 1.56/include/net/tcp.h	Sun Feb  1 11:17:41 2004
+++ edited/include/net/tcp.h	Fri Feb 27 14:31:03 2004
@@ -263,7 +263,10 @@
 #define tw_for_each(tw, node, head) \
 	hlist_for_each_entry(tw, node, head, tw_node)
 
-#define tw_for_each_inmate(tw, node, safe, jail) \
+#define tw_for_each_inmate(tw, node, jail) \
+	hlist_for_each_entry(tw, node, jail, tw_death_node)
+
+#define tw_for_each_inmate_safe(tw, node, safe, jail) \
 	hlist_for_each_entry_safe(tw, node, safe, jail, tw_death_node)
 
 #define tcptw_sk(__sk)	((struct tcp_tw_bucket *)(__sk))
===== net/ipv4/tcp_minisocks.c 1.43 vs edited =====
--- 1.43/net/ipv4/tcp_minisocks.c	Tue Oct 28 03:10:47 2003
+++ edited/net/ipv4/tcp_minisocks.c	Fri Feb 27 14:30:01 2004
@@ -427,7 +427,7 @@
 static int tcp_do_twkill_work(int slot, unsigned int quota)
 {
 	struct tcp_tw_bucket *tw;
-	struct hlist_node *node, *safe;
+	struct hlist_node *node;
 	unsigned int killed;
 	int ret;
 
@@ -439,8 +439,8 @@
 	 */
 	killed = 0;
 	ret = 0;
-	tw_for_each_inmate(tw, node, safe,
-			   &tcp_tw_death_row[slot]) {
+rescan:
+	tw_for_each_inmate(tw, node, &tcp_tw_death_row[slot]) {
 		__tw_del_dead_node(tw);
 		spin_unlock(&tw_death_lock);
 		tcp_timewait_kill(tw);
@@ -451,6 +451,14 @@
 			ret = 1;
 			break;
 		}
+
+		/* While we dropped tw_death_lock, another cpu may have
+		 * killed off the next TW bucket in the list, therefore
+		 * do a fresh re-read of the hlist head node with the
+		 * lock reacquired.  We still use the hlist traversal
+		 * macro in order to get the prefetches.
+		 */
+		goto rescan;
 	}
 
 	tcp_tw_count -= killed;
@@ -637,7 +645,7 @@
 			struct hlist_node *node, *safe;
 			struct tcp_tw_bucket *tw;
 
-			tw_for_each_inmate(tw, node, safe,
+			tw_for_each_inmate_safe(tw, node, safe,
 					   &tcp_twcal_row[slot]) {
 				__tw_del_dead_node(tw);
 				tcp_timewait_kill(tw);
