From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/6)  tr - spin_lock consitency
Date: Wed, 20 Aug 2003 17:07:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820170740.7a80a9a8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use spin_lock on hash table consistently, this code is only called
from bottom half context, never from interrupt context so use spin_lock_bh.

Patch against 2.6.0-test3 bk latest.

diff -Nru a/net/802/tr.c b/net/802/tr.c
--- a/net/802/tr.c	Wed Aug 20 15:51:27 2003
+++ b/net/802/tr.c	Wed Aug 20 15:51:27 2003
@@ -236,9 +236,8 @@
 	struct rif_cache_s *entry;
 	unsigned char *olddata;
 	unsigned char mcast_func_addr[] = {0xC0,0x00,0x00,0x04,0x00,0x00};
-	unsigned long flags ; 
 	
-	spin_lock_irqsave(&rif_lock,flags);
+	spin_lock_bh(&rif_lock);
 
 	/*
 	 *	Broadcasts are single route as stated in RFC 1042 
@@ -308,7 +307,7 @@
 	else 
 		slack = 18 - ((ntohs(trh->rcf) & TR_RCF_LEN_MASK)>>8);
 	olddata = skb->data;
-	spin_unlock_irqrestore(&rif_lock,flags);
+	spin_unlock_bh(&rif_lock);
 
 	skb_pull(skb, slack);
 	memmove(skb->data, olddata, sizeof(struct trh_hdr) - slack);
@@ -418,9 +417,8 @@
 {
 	int i;
 	unsigned long now=jiffies;
-	unsigned long flags ; 
 
-	spin_lock_irqsave(&rif_lock,flags);
+	spin_lock_bh(&rif_lock);
 	
 	for(i=0; i < RIF_TABLE_SIZE;i++) 
 	{
@@ -440,7 +438,7 @@
 		}
 	}
 	
-	spin_unlock_irqrestore(&rif_lock,flags);
+	spin_unlock_bh(&rif_lock);
 
 	/*
 	 *	Reset the timer
@@ -477,10 +475,7 @@
 
 static void *rif_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&rif_lock, flags);
-	seq->private = (void *) flags;
+	spin_lock_bh(&rif_lock);
 
 	return *pos ? rif_get_idx(*pos - 1) : RIF_PROC_START;
 }
@@ -492,8 +487,7 @@
 
 static void rif_seq_stop(struct seq_file *seq, void *v)
 {
-	unsigned long flags = (unsigned long) seq->private;
-	spin_lock_irqsave(&rif_lock, flags);
+	spin_unlock_bh(&rif_lock);
 }
 
 static int rif_seq_show(struct seq_file *seq, void *v)
