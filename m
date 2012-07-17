From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] skbuff: Use correct allocation in skb_copy_ubufs
Date: Tue, 17 Jul 2012 17:35:29 +0530
Message-ID: <20120717120529.16840.51108.sendpatchset@localhost.localdomain>
Cc: xma@us.ibm.com, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:34760 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab2GQMFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 08:05:52 -0400
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Tue, 17 Jul 2012 17:35:49 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6HC5Vsa41222170
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 17:35:31 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6HHYoRD025209
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 03:34:50 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use correct allocation flags during copy of user space fragments
to the kernel. Also "improve" couple of for loops.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 skbuff.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff -ruNp org/net/core/skbuff.c new/net/core/skbuff.c
--- org/net/core/skbuff.c	2012-07-17 09:56:12.000000000 +0530
+++ new/net/core/skbuff.c	2012-07-17 11:05:43.715853844 +0530
@@ -751,7 +751,7 @@ int skb_copy_ubufs(struct sk_buff *skb, 
 		u8 *vaddr;
 		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
 
-		page = alloc_page(GFP_ATOMIC);
+		page = alloc_page(gfp_mask);
 		if (!page) {
 			while (head) {
 				struct page *next = (struct page *)head->private;
@@ -769,15 +769,15 @@ int skb_copy_ubufs(struct sk_buff *skb, 
 	}
 
 	/* skb frags release userspace buffers */
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+	for (i = 0; i < num_frags; i++)
 		skb_frag_unref(skb, i);
 
 	uarg->callback(uarg);
 
 	/* skb frags point to kernel buffers */
-	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
-		__skb_fill_page_desc(skb, i-1, head, 0,
-				     skb_shinfo(skb)->frags[i - 1].size);
+	for (i = num_frags - 1; i >= 0; i--) {
+		__skb_fill_page_desc(skb, i, head, 0,
+				     skb_shinfo(skb)->frags[i].size);
 		head = (struct page *)head->private;
 	}
 
