From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/6) tr - expire timer improvements
Date: Wed, 20 Aug 2003 17:19:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820171922.1af68a7c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup the timer code.  It works as is, but:
	- use timer_ macro's when working with jiffies.
	- cleanup the #define's
	- make timer run sooner (ie when next entry will expire)
	  rather than waiting till the next 10 minute quanta.
	- print TTL value in seconds not jiffies
	- change formatting to linux style in code the area affected.


diff -Nru a/net/802/tr.c b/net/802/tr.c
--- a/net/802/tr.c	Wed Aug 20 17:01:05 2003
+++ b/net/802/tr.c	Wed Aug 20 17:01:05 2003
@@ -67,8 +67,6 @@
 
 static spinlock_t rif_lock = SPIN_LOCK_UNLOCKED;
 
-#define RIF_TIMEOUT 60*10*HZ
-#define RIF_CHECK_INTERVAL 60*HZ
 
 /*
  *	Garbage disposal timer.
@@ -76,7 +74,7 @@
  
 static struct timer_list rif_timer;
 
-int sysctl_tr_rif_timeout = RIF_TIMEOUT;
+int sysctl_tr_rif_timeout = 60*10*HZ;
 
 static inline unsigned long rif_hash(const unsigned char *addr)
 {
@@ -430,35 +428,33 @@
 static void rif_check_expire(unsigned long dummy) 
 {
 	int i;
-	unsigned long now=jiffies;
+	unsigned long next_interval = jiffies + sysctl_tr_rif_timeout/2;
 
 	spin_lock_bh(&rif_lock);
 	
-	for(i=0; i < RIF_TABLE_SIZE;i++) 
-	{
-		struct rif_cache_s *entry, **pentry=rif_table+i;	
-		while((entry=*pentry)) 
-		{
-			/*
-			 *	Out it goes
-			 */
-			if((now-entry->last_used) > sysctl_tr_rif_timeout) 
-			{
-				*pentry=entry->next;
+	for(i =0; i < RIF_TABLE_SIZE; i++) {
+		struct rif_cache_s *entry, **pentry;
+		
+		pentry = rif_table+i;
+		while((entry=*pentry) != NULL) {
+			unsigned long expires
+				= entry->last_used + sysctl_tr_rif_timeout;
+
+			if (time_before_eq(expires, jiffies)) {
+				*pentry = entry->next;
 				kfree(entry);
+			} else {
+				pentry = &entry->next;
+
+				if (time_before(expires, next_interval))
+					next_interval = expires;
 			}
-			else
-				pentry=&entry->next;
 		}
 	}
 	
 	spin_unlock_bh(&rif_lock);
 
-	/*
-	 *	Reset the timer
-	 */
-	 
-	mod_timer(&rif_timer, jiffies+sysctl_tr_rif_timeout);
+	mod_timer(&rif_timer, next_interval);
 
 }
 
@@ -533,12 +529,14 @@
 		     "if     TR address       TTL   rcf   routing segments\n");
 	else {
 		struct net_device *dev = dev_get_by_index(entry->iface);
+		long ttl = (long) (entry->last_used + sysctl_tr_rif_timeout)
+				- (long) jiffies;
 
 		seq_printf(seq, "%s %02X:%02X:%02X:%02X:%02X:%02X %7li ",
 			   dev?dev->name:"?",
 			   entry->addr[0],entry->addr[1],entry->addr[2],
 			   entry->addr[3],entry->addr[4],entry->addr[5],
-			   sysctl_tr_rif_timeout-(jiffies-entry->last_used));
+			   ttl/HZ);
 
 			if (entry->local_ring)
 			        seq_puts(seq, "local\n");
@@ -594,7 +592,7 @@
 static int __init rif_init(void)
 {
 	init_timer(&rif_timer);
-	rif_timer.expires  = RIF_TIMEOUT;
+	rif_timer.expires  = sysctl_tr_rif_timeout;
 	rif_timer.data     = 0L;
 	rif_timer.function = rif_check_expire;
 	add_timer(&rif_timer);
