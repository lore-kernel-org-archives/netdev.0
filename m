From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] shaper.c: fix locking
Date: Fri, 27 May 2005 13:54:50 +0200
Message-ID: <20050527115450.GA19469@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 o use a semaphore instead of an opencoded and racy lock
 o move locking out of shaper_kick and into the callers - most just
   released the lock before calling shaper_kick
 o remove in_interrupt() tests.  from ->close we can always block, from
   ->hard_start_xmit and timer context never


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/if_shaper.h
===================================================================
--- linux-2.6.orig/include/linux/if_shaper.h	2005-04-30 10:17:19.000000000 +0200
+++ linux-2.6/include/linux/if_shaper.h	2005-05-27 13:47:47.000000000 +0200
@@ -23,7 +23,7 @@
 	__u32 shapeclock;
 	unsigned long recovery;	/* Time we can next clock a packet out on
 				   an empty queue */
-        unsigned long locked;
+	struct semaphore sem;
         struct net_device_stats stats;
 	struct net_device *dev;
 	int  (*hard_start_xmit) (struct sk_buff *skb,
@@ -38,7 +38,6 @@
 	int (*hard_header_cache)(struct neighbour *neigh, struct hh_cache *hh);
 	void (*header_cache_update)(struct hh_cache *hh, struct net_device *dev, unsigned char *  haddr);
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
-	wait_queue_head_t  wait_queue;
 	struct timer_list timer;
 };
 
Index: linux-2.6/drivers/net/shaper.c
===================================================================
--- linux-2.6.orig/drivers/net/shaper.c	2005-04-30 10:17:15.000000000 +0200
+++ linux-2.6/drivers/net/shaper.c	2005-05-27 13:50:41.000000000 +0200
@@ -100,35 +100,8 @@
 
 #define SHAPER_BANNER	"CymruNet Traffic Shaper BETA 0.04 for Linux 2.1\n"
 
-/*
- *	Locking
- */
- 
-static int shaper_lock(struct shaper *sh)
-{
-	/*
-	 *	Lock in an interrupt must fail
-	 */
-	while (test_and_set_bit(0, &sh->locked))
-	{
-		if (!in_interrupt())
-			sleep_on(&sh->wait_queue);
-		else
-			return 0;
-			
-	}
-	return 1;
-}
-
 static void shaper_kick(struct shaper *sh);
 
-static void shaper_unlock(struct shaper *sh)
-{
-	clear_bit(0, &sh->locked);
-	wake_up(&sh->wait_queue);
-	shaper_kick(sh);
-}
-
 /*
  *	Compute clocks on a buffer
  */
@@ -157,17 +130,15 @@
  *	Throw a frame at a shaper.
  */
   
-static int shaper_qframe(struct shaper *shaper, struct sk_buff *skb)
+
+static int shaper_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	struct shaper *shaper = dev->priv;
  	struct sk_buff *ptr;
    
- 	/*
- 	 *	Get ready to work on this shaper. Lock may fail if its
- 	 *	an interrupt and locked.
- 	 */
- 	 
- 	if(!shaper_lock(shaper))
- 		return -1;
+	if (down_trylock(&shaper->sem))
+		return -1;
+
  	ptr=shaper->sendq.prev;
  	
  	/*
@@ -260,7 +231,8 @@
                 dev_kfree_skb(ptr);
                 shaper->stats.collisions++;
  	}
- 	shaper_unlock(shaper);
+	shaper_kick(shaper);
+	up(&shaper->sem);
  	return 0;
 }
 
@@ -297,8 +269,13 @@
  
 static void shaper_timer(unsigned long data)
 {
-	struct shaper *sh=(struct shaper *)data;
-	shaper_kick(sh);
+	struct shaper *shaper = (struct shaper *)data;
+
+	if (!down_trylock(&shaper->sem)) {
+		shaper_kick(shaper);
+		up(&shaper->sem);
+	} else
+		mod_timer(&shaper->timer, jiffies);
 }
 
 /*
@@ -311,19 +288,6 @@
 	struct sk_buff *skb;
 	
 	/*
-	 *	Shaper unlock will kick
-	 */
-	 
-	if (test_and_set_bit(0, &shaper->locked))
-	{
-		if(sh_debug)
-			printk("Shaper locked.\n");
-		mod_timer(&shaper->timer, jiffies);
-		return;
-	}
-
-		
-	/*
 	 *	Walk the list (may be empty)
 	 */
 	 
@@ -364,8 +328,6 @@
 	 
 	if(skb!=NULL)
 		mod_timer(&shaper->timer, SHAPERCB(skb)->shapeclock);
-
-	clear_bit(0, &shaper->locked);
 }
 
 
@@ -376,14 +338,12 @@
 static void shaper_flush(struct shaper *shaper)
 {
 	struct sk_buff *skb;
- 	if(!shaper_lock(shaper))
-	{
-		printk(KERN_ERR "shaper: shaper_flush() called by an irq!\n");
- 		return;
-	}
+
+	down(&shaper->sem);
 	while((skb=skb_dequeue(&shaper->sendq))!=NULL)
 		dev_kfree_skb(skb);
-	shaper_unlock(shaper);
+	shaper_kick(shaper);
+	up(&shaper->sem);
 }
 
 /*
@@ -426,13 +386,6 @@
  *	ARP and other resolutions and not before.
  */
 
-
-static int shaper_start_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	struct shaper *sh=dev->priv;
-	return shaper_qframe(sh, skb);
-}
-
 static struct net_device_stats *shaper_get_stats(struct net_device *dev)
 {
      	struct shaper *sh=dev->priv;
@@ -623,7 +576,6 @@
 	init_timer(&sh->timer);
 	sh->timer.function=shaper_timer;
 	sh->timer.data=(unsigned long)sh;
-	init_waitqueue_head(&sh->wait_queue);
 }
 
 /*
