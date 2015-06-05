From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net] ipv6: fix possible use after free of dev stats
Date: Fri, 5 Jun 2015 18:51:54 +0100
Message-ID: <1433526714-18770-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:31728 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752050AbbFERxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 13:53:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory pointed to by idev->stats.icmpv6msgdev,
idev->stats.icmpv6dev and idev->stats.ipv6 can each be used in an RCU
read context without taking a reference on idev. For example, through
IP6_*_STATS_* calls in ip6_rcv. These memory blocks are freed without
waiting for an RCU grace period to elapse. This could lead to the
memory being written to after it has been freed.

Fix this by using call_rcu to free the memory used for stats, as well
as idev after an RCU grace period has elapsed.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
I have no evidence of this causing any problems in reality - this
issue was found by inspection.

 net/ipv6/addrconf_core.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index d873ceea86e6..ca09bf49ac68 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -133,6 +133,14 @@ static void snmp6_free_dev(struct inet6_dev *idev)
 	free_percpu(idev->stats.ipv6);
 }
 
+static void in6_dev_finish_destroy_rcu(struct rcu_head *head)
+{
+	struct inet6_dev *idev = container_of(head, struct inet6_dev, rcu);
+
+	snmp6_free_dev(idev);
+	kfree(idev);
+}
+
 /* Nobody refers to this device, we may destroy it. */
 
 void in6_dev_finish_destroy(struct inet6_dev *idev)
@@ -151,7 +159,6 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 		pr_warn("Freeing alive inet6 device %p\n", idev);
 		return;
 	}
-	snmp6_free_dev(idev);
-	kfree_rcu(idev, rcu);
+	call_rcu(&idev->rcu, in6_dev_finish_destroy_rcu);
 }
 EXPORT_SYMBOL(in6_dev_finish_destroy);
-- 
2.1.4
