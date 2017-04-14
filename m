From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/9] netfilter: make it safer during the inet6_dev->addr_list traversal
Date: Fri, 14 Apr 2017 02:26:47 +0200
Message-ID: <1492129611-29336-6-git-send-email-pablo@netfilter.org>
References: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35314 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754164AbdDNA1K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 20:27:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 52E11E0441
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:05 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 397FFDA863
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:05 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 33F1DDA862
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:03 +0200 (CEST)
In-Reply-To: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

inet6_dev->addr_list is protected by inet6_dev->lock, so only using
rcu_read_lock is not enough, we should acquire read_lock_bh(&idev->lock)
before the inet6_dev->addr_list traversal.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_redirect.c | 2 ++
 net/netfilter/xt_TPROXY.c       | 5 ++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_redirect.c b/net/netfilter/nf_nat_redirect.c
index d43869879fcf..86067560a318 100644
--- a/net/netfilter/nf_nat_redirect.c
+++ b/net/netfilter/nf_nat_redirect.c
@@ -101,11 +101,13 @@ nf_nat_redirect_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
 		rcu_read_lock();
 		idev = __in6_dev_get(skb->dev);
 		if (idev != NULL) {
+			read_lock_bh(&idev->lock);
 			list_for_each_entry(ifa, &idev->addr_list, if_list) {
 				newdst = ifa->addr;
 				addr = true;
 				break;
 			}
+			read_unlock_bh(&idev->lock);
 		}
 		rcu_read_unlock();
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 80cb7babeb64..df7f1df00330 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -393,7 +393,8 @@ tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr,
 
 	rcu_read_lock();
 	indev = __in6_dev_get(skb->dev);
-	if (indev)
+	if (indev) {
+		read_lock_bh(&indev->lock);
 		list_for_each_entry(ifa, &indev->addr_list, if_list) {
 			if (ifa->flags & (IFA_F_TENTATIVE | IFA_F_DEPRECATED))
 				continue;
@@ -401,6 +402,8 @@ tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr,
 			laddr = &ifa->addr;
 			break;
 		}
+		read_unlock_bh(&indev->lock);
+	}
 	rcu_read_unlock();
 
 	return laddr ? laddr : daddr;
-- 
2.1.4
