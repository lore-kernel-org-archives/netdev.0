From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Some pktgen fixes for 2.6.11-rc2
Date: Wed, 16 Feb 2005 15:59:48 +0100
Message-ID: <16915.24548.149702.188195@robur.slu.se>
References: <16890.41237.608094.933695@robur.slu.se>
	<20050215134120.3ae4c511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com,
        Jens.Laas@data.slu.se
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050215134120.3ae4c511.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > Robert, can you send me an updated patch against current
 > sources?  Thanks a lot.

 Hello!

 Against linux-2.6.11-rc4
 Some minor bugfixes and some clean ups. Yes version jumps with two.

					    --ro


--- net/core/pktgen.c.foo	2005-01-28 13:16:50.965630000 +0100
+++ net/core/pktgen.c	2005-01-28 16:51:32.932273576 +0100
@@ -148,7 +148,7 @@
 #include <asm/timex.h>
 
 
-#define VERSION  "pktgen v2.54: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.56: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a) 
@@ -167,9 +167,6 @@
 #define F_TXSIZE_RND  (1<<6)  /* Transmit size is random */
 #define F_IPV6        (1<<7)  /* Interface in IPV6 Mode */
 
-#define L_PUSH(t, i)              {i->next = t; t=i;}
-#define L_POP(t, i)               {i=t; if(i) t = i->next;}
-
 /* Thread control flag bits */
 #define T_TERMINATE   (1<<0)  
 #define T_STOP        (1<<1)  /* Stop run */
@@ -1366,19 +1363,15 @@
         p += sprintf(p, "Running: ");
         
         if_lock(t);
-        pkt_dev = t->if_list;
-        while (pkt_dev && pkt_dev->running) {
-                p += sprintf(p, "%s ", pkt_dev->ifname);
-                pkt_dev = pkt_dev->next;
-        }
+        for(pkt_dev = t->if_list;pkt_dev; pkt_dev = pkt_dev->next) 
+		if(pkt_dev->running)
+			p += sprintf(p, "%s ", pkt_dev->ifname);
+        
         p += sprintf(p, "\nStopped: ");
 
-        pkt_dev = t->if_list;
-        while (pkt_dev && !pkt_dev->running) {
-                p += sprintf(p, "%s ", pkt_dev->ifname);
-                pkt_dev = pkt_dev->next;
-        }
-
+        for(pkt_dev = t->if_list;pkt_dev; pkt_dev = pkt_dev->next) 
+		if(!pkt_dev->running)
+			p += sprintf(p, "%s ", pkt_dev->ifname);
 
 	if (t->result[0])
 		p += sprintf(p, "\nResult: %s\n", t->result);
@@ -2393,7 +2386,7 @@
        thread_unlock();
 }
 
-static int running(struct pktgen_thread *t )
+static int thread_is_running(struct pktgen_thread *t )
 {
         struct pktgen_dev *next;
         int res = 0;
@@ -2415,7 +2408,7 @@
         
         if_lock(t);
 
-        while(running(t)) {
+        while(thread_is_running(t)) {
                 if_unlock(t);
         
                 interruptible_sleep_on_timeout(&queue, HZ/10);
@@ -2520,13 +2513,15 @@
                 return -EINVAL;
         }
 
-	if (pkt_dev->skb) 
-		kfree_skb(pkt_dev->skb);
-
         pkt_dev->stopped_at = getCurUs();
         pkt_dev->running = 0;
 
 	show_results(pkt_dev, skb_shinfo(pkt_dev->skb)->nr_frags);
+
+	if (pkt_dev->skb) 
+		kfree_skb(pkt_dev->skb);
+
+	pkt_dev->skb = NULL;
 	
         return 0;
 }
@@ -2855,10 +2850,10 @@
 
         for(pkt_dev=t->if_list; pkt_dev; pkt_dev = pkt_dev->next ) {
                 if (strcmp(pkt_dev->ifname, ifname) == 0) {
-                        goto out;
+                        break;
                 }
         }
- out:
+
         if_unlock(t);
 	PG_DEBUG(printk("pktgen: find_dev(%s) returning %p\n", ifname,pkt_dev));
         return pkt_dev;
@@ -2879,8 +2874,7 @@
                 rv = -EBUSY;
                 goto out;
         }
-
-	L_PUSH(t->if_list, pkt_dev);
+	pkt_dev->next =t->if_list; t->if_list=pkt_dev;
         pkt_dev->pg_thread = t;
 	pkt_dev->running = 0;
 
