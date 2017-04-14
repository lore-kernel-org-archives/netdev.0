From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/9] netfilter: ctnetlink: make it safer when checking the ct helper name
Date: Fri, 14 Apr 2017 02:26:46 +0200
Message-ID: <1492129611-29336-5-git-send-email-pablo@netfilter.org>
References: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35302 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754103AbdDNA1I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 20:27:08 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E7A96E0437
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D8056DA86F
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C7153DA793
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:01 +0200 (CEST)
In-Reply-To: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

One CPU is doing ctnetlink_change_helper(), while another CPU is doing
unhelp() at the same time. So even if help->helper is not NULL at first,
the later statement strcmp(help->helper->name, ...) may still access
the NULL pointer.

So we must use rcu_read_lock and rcu_dereference to avoid such _bad_
thing happen.

Fixes: f95d7a46bc57 ("netfilter: ctnetlink: Fix regression in CTA_HELP processing")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 06d28ac663df..f9c643bc1a8e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1488,11 +1488,16 @@ static int ctnetlink_change_helper(struct nf_conn *ct,
 		 * treat the second attempt as a no-op instead of returning
 		 * an error.
 		 */
-		if (help && help->helper &&
-		    !strcmp(help->helper->name, helpname))
-			return 0;
-		else
-			return -EBUSY;
+		err = -EBUSY;
+		if (help) {
+			rcu_read_lock();
+			helper = rcu_dereference(help->helper);
+			if (helper && !strcmp(helper->name, helpname))
+				err = 0;
+			rcu_read_unlock();
+		}
+
+		return err;
 	}
 
 	if (!strcmp(helpname, "")) {
-- 
2.1.4
