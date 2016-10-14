From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Subject: [PATCH] ethtool: Zero memory allocated for statistics
Date: Fri, 14 Oct 2016 11:59:18 +0200
Message-ID: <1476439158-66060-1-git-send-email-vlad@tsyrklevich.net>
Cc: Vlad Tsyrklevich <vlad@tsyrklevich.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35773 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753607AbcJNJ71 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 05:59:27 -0400
Received: by mail-lf0-f67.google.com with SMTP id x79so17346686lff.2
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 02:59:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zero allocations before they're passed to drivers to be filled out with
statistics. While many drivers always correctly fill out the entire
allocated space, under some failure conditions some drivers will not
clear the allocated space appropriately. Unprivileged users could
induce some of these failure conditions to leak kernel memory. Instead
of fixing drivers one by one, the best solution is to eliminate the
possibility of driver errors leaking kernel memory entirely.

Given that ethtool_get_stats(), ethtool_get_phy_stats(), and
ethtool_get_tunable() are accessible without CAP_NET_ADMIN they are the
most important to clear to avoid memory leaks. ethtool_self_test() and
ethtool_get_any_eeprom() require CAP_NET_ADMIN but were also included
for completeness.

Some examples of driver methods that could fail to fill out memory:
enic_get_ethtool_stats(), cp_get_ethtool_stats(),
mv88e6xxx_get_ethtool_stats(), bnx2x_self_test(), be_self_test(), etc.

Signed-off-by: Vlad Tsyrklevich <vlad@tsyrklevich.net>
---
 net/core/ethtool.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9774898..7202915 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1538,7 +1538,7 @@ static int ethtool_get_any_eeprom(struct net_device *dev, void __user *useraddr,
 	if (eeprom.offset + eeprom.len > total_len)
 		return -EINVAL;
 
-	data = kmalloc(PAGE_SIZE, GFP_USER);
+	data = kzalloc(PAGE_SIZE, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
@@ -1775,7 +1775,7 @@ static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 		return -EFAULT;
 
 	test.len = test_len;
-	data = kmalloc(test_len * sizeof(u64), GFP_USER);
+	data = kcalloc(test_len, sizeof(u64), GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
@@ -1907,7 +1907,7 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	stats.n_stats = n_stats;
-	data = kmalloc(n_stats * sizeof(u64), GFP_USER);
+	data = kcalloc(n_stats, sizeof(u64), GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
@@ -1946,7 +1946,7 @@ static int ethtool_get_phy_stats(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	stats.n_stats = n_stats;
-	data = kmalloc_array(n_stats, sizeof(u64), GFP_USER);
+	data = kcalloc(n_stats, sizeof(u64), GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
@@ -2269,7 +2269,7 @@ static int ethtool_get_tunable(struct net_device *dev, void __user *useraddr)
 	ret = ethtool_tunable_valid(&tuna);
 	if (ret)
 		return ret;
-	data = kmalloc(tuna.len, GFP_USER);
+	data = kzalloc(tuna.len, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 	ret = ops->get_tunable(dev, &tuna, data);
-- 
2.7.0
