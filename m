From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.5] olympic: Repost: spin_lock_bh() called in irq handler
Date: Thu, 27 May 2004 12:31:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405271931.i4RJVXNN007213@death.nxdomain.ibm.com>
Cc: linux-tr@linuxtr.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	I posted this about a month ago, but didn't see any response.
The patch has since been verified to fix an actual problem (IBM iseries
systems would see errors due to the _bh locking in interrupt context).

	Comments?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


To: Paul Mackerras <paulus@samba.org>
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Subject: Re: spin_lock_bh() called in irq handler 
Date: Wed, 28 Apr 2004 10:55:33 -0700
From: Jay Vosburgh <fubar@us.ibm.com>


>I had a look and found that all of the token-ring drivers call
>tr_type_trans() at interrupt level.  That seems perfectly reasonable
>to me.  To fix the bug, it seems to me that there are two options:
>either move the tr_add_rif_info() call elsewhere (but I have no idea
>where) or else use spin_lock_irqsave instead of spin_lock_bh.
>
>Which is the more appropriate fix?

	I'm guessing spin_lock_irqsave; would the following be
appropriate?  I'm not absolutely sure about using spin_(un)lock_irq in
rif_seq_start/stop, but it'd be complicated to deal with the flags in
that case.

	I've built this and given it some basic testing, but not really
hammered on it.  The system doesn't panic when I cat /proc/net/tr_rif,
which is a good sign.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


diff -urN linux-2.6.5-orig/net/802/tr.c linux-2.6.5/net/802/tr.c
--- linux-2.6.5-orig/net/802/tr.c	2004-04-28 10:02:12.000000000 -0700
+++ linux-2.6.5/net/802/tr.c	2004-04-28 10:15:47.000000000 -0700
@@ -250,10 +250,11 @@
 	unsigned int hash;
 	struct rif_cache_s *entry;
 	unsigned char *olddata;
+	unsigned long flags;
 	static const unsigned char mcast_func_addr[] 
 		= {0xC0,0x00,0x00,0x04,0x00,0x00};
 	
-	spin_lock_bh(&rif_lock);
+	spin_lock_irqsave(&rif_lock, flags);
 
 	/*
 	 *	Broadcasts are single route as stated in RFC 1042 
@@ -322,7 +323,7 @@
 	else 
 		slack = 18 - ((ntohs(trh->rcf) & TR_RCF_LEN_MASK)>>8);
 	olddata = skb->data;
-	spin_unlock_bh(&rif_lock);
+	spin_unlock_irqrestore(&rif_lock, flags);
 
 	skb_pull(skb, slack);
 	memmove(skb->data, olddata, sizeof(struct trh_hdr) - slack);
@@ -336,10 +337,11 @@
 static void tr_add_rif_info(struct trh_hdr *trh, struct net_device *dev)
 {
 	unsigned int hash, rii_p = 0;
+	unsigned long flags;
 	struct rif_cache_s *entry;
 
 
-	spin_lock_bh(&rif_lock);
+	spin_lock_irqsave(&rif_lock, flags);
 	
 	/*
 	 *	Firstly see if the entry exists
@@ -377,7 +379,7 @@
 		if(!entry) 
 		{
 			printk(KERN_DEBUG "tr.c: Couldn't malloc rif cache entry !\n");
-			spin_unlock_bh(&rif_lock);
+			spin_unlock_irqrestore(&rif_lock, flags);
 			return;
 		}
 
@@ -419,7 +421,7 @@
 		    }                                         
            	entry->last_used=jiffies;               
 	}
-	spin_unlock_bh(&rif_lock);
+	spin_unlock_irqrestore(&rif_lock, flags);
 }
 
 /*
@@ -429,9 +431,9 @@
 static void rif_check_expire(unsigned long dummy) 
 {
 	int i;
-	unsigned long next_interval = jiffies + sysctl_tr_rif_timeout/2;
+	unsigned long flags, next_interval = jiffies + sysctl_tr_rif_timeout/2;
 
-	spin_lock_bh(&rif_lock);
+	spin_lock_irqsave(&rif_lock, flags);
 	
 	for(i =0; i < RIF_TABLE_SIZE; i++) {
 		struct rif_cache_s *entry, **pentry;
@@ -453,7 +455,7 @@
 		}
 	}
 	
-	spin_unlock_bh(&rif_lock);
+	spin_unlock_irqrestore(&rif_lock, flags);
 
 	mod_timer(&rif_timer, next_interval);
 
@@ -484,7 +486,7 @@
 
 static void *rif_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	spin_lock_bh(&rif_lock);
+	spin_lock_irq(&rif_lock);
 
 	return *pos ? rif_get_idx(*pos - 1) : SEQ_START_TOKEN;
 }
@@ -515,7 +517,7 @@
 
 static void rif_seq_stop(struct seq_file *seq, void *v)
 {
-	spin_unlock_bh(&rif_lock);
+	spin_unlock_irq(&rif_lock);
 }
 
 static int rif_seq_show(struct seq_file *seq, void *v)
