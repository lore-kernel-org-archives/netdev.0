From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] fib_trie resize break
Date: Fri, 16 Mar 2007 11:46:41 +0100
Message-ID: <17914.30097.150726.261688@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se,
	Jens.Laas@data.slu.se, hans.liss@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:53925 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471AbXCPKqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 06:46:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello.

The patch below adds break condition for the resize operations. If 
we don't achieve the desired fill factor a warning is printed. Trie 
should still be operational but new thresholds should be considered.

Cheers
					--ro


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1e589b9..7ef5948 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -50,7 +50,7 @@
  *		Patrick McHardy <kaber@trash.net>
  */
 
-#define VERSION "0.407"
+#define VERSION "0.408"
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -460,6 +460,7 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 	struct tnode *old_tn;
 	int inflate_threshold_use;
 	int halve_threshold_use;
+	int max_resize;
 
  	if (!tn)
 		return NULL;
@@ -560,7 +561,8 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 		inflate_threshold_use = inflate_threshold;
 
 	err = 0;
-	while ((tn->full_children > 0 &&
+	max_resize = 10;
+	while ((tn->full_children > 0 &&  max_resize-- &&
 	       50 * (tn->full_children + tnode_child_length(tn) - tn->empty_children) >=
 				inflate_threshold_use * tnode_child_length(tn))) {
 
@@ -575,6 +577,17 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 		}
 	}
 
+	if(max_resize < 0) {
+		
+		if(!tn->parent) 
+			printk(KERN_WARNING "Fix inflate_threshold_root. Now=%d size=%d bits\n", 
+			       inflate_threshold_root, tn->bits);
+		
+		else 
+			printk(KERN_WARNING "Fix inflate_threshold. Now=%d size=%d bits\n", 
+			       inflate_threshold, tn->bits);
+	}
+
 	check_tnode(tn);
 
 	/*
@@ -591,7 +604,8 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 		halve_threshold_use = halve_threshold;
 
 	err = 0;
-	while (tn->bits > 1 &&
+	max_resize = 10;
+	while (tn->bits > 1 &&  max_resize-- &&
 	       100 * (tnode_child_length(tn) - tn->empty_children) <
 	       halve_threshold_use * tnode_child_length(tn)) {
 
@@ -606,6 +620,16 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 		}
 	}
 
+	if(max_resize < 0) {
+		
+		if(!tn->parent) 
+			printk(KERN_WARNING "Fix halve_threshold_root. Now=%d size=%d bits\n", 
+			       halve_threshold_root, tn->bits);
+		
+		else 
+			printk(KERN_WARNING "Fix halve_threshold. Now=%d size=%d bits\n", 
+			       halve_threshold, tn->bits);
+	}
 
 	/* Only one child remains */
 	if (tn->empty_children == tnode_child_length(tn) - 1)
