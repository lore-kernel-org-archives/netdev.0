From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/18] audit: netlink: Move away from NLMSG_NEW().
Date: Tue, 26 Jun 2012 22:02:41 -0700 (PDT)
Message-ID: <20120626.220241.640674634018942070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2F0FCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:41 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5E9E4584195
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 kernel/audit.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 1c7f2c6..30b252a 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -384,7 +384,7 @@ static void audit_hold_skb(struct sk_buff *skb)
 static void audit_printk_skb(struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(skb);
-	char *data = NLMSG_DATA(nlh);
+	char *data = nlmsg_data(nlh);
 
 	if (nlh->nlmsg_type != AUDIT_EOE) {
 		if (printk_ratelimit())
@@ -516,14 +516,15 @@ struct sk_buff *audit_make_reply(int pid, int seq, int type, int done,
 	if (!skb)
 		return NULL;
 
-	nlh	= NLMSG_NEW(skb, pid, seq, t, size, flags);
-	data	= NLMSG_DATA(nlh);
+	nlh	= nlmsg_put(skb, pid, seq, t, size, flags);
+	if (!nlh)
+		goto out_kfree_skb;
+	data = nlmsg_data(nlh);
 	memcpy(data, payload, size);
 	return skb;
 
-nlmsg_failure:			/* Used by NLMSG_NEW */
-	if (skb)
-		kfree_skb(skb);
+out_kfree_skb:
+	kfree_skb(skb);
 	return NULL;
 }
 
@@ -680,7 +681,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	sessionid = audit_get_sessionid(current);
 	security_task_getsecid(current, &sid);
 	seq  = nlh->nlmsg_seq;
-	data = NLMSG_DATA(nlh);
+	data = nlmsg_data(nlh);
 
 	switch (msg_type) {
 	case AUDIT_GET:
@@ -1060,13 +1061,15 @@ static struct audit_buffer * audit_buffer_alloc(struct audit_context *ctx,
 
 	ab->skb = nlmsg_new(AUDIT_BUFSIZ, gfp_mask);
 	if (!ab->skb)
-		goto nlmsg_failure;
+		goto err;
 
-	nlh = NLMSG_NEW(ab->skb, 0, 0, type, 0, 0);
+	nlh = nlmsg_put(ab->skb, 0, 0, type, 0, 0);
+	if (!nlh)
+		goto out_kfree_skb;
 
 	return ab;
 
-nlmsg_failure:                  /* Used by NLMSG_NEW */
+out_kfree_skb:
 	kfree_skb(ab->skb);
 	ab->skb = NULL;
 err:
-- 
1.7.10.2
