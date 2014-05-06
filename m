From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2] ipv4: remove inet_addr_hash_lock in devinet.c
Date: Tue,  6 May 2014 11:15:56 -0700
Message-ID: <1399400156-993-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:63769 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbaEFSQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 14:16:03 -0400
Received: by mail-pa0-f42.google.com with SMTP id rd3so835620pab.15
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 11:16:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the callers hold RTNL lock, so there is no need to use inet_addr_hash_lock
to protect the hash list.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
v2: add ASSERT_RTNL() as suggested by David

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index bdbf68b..78692e4 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -106,7 +106,6 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 #define IN4_ADDR_HSIZE		(1U << IN4_ADDR_HSIZE_SHIFT)
 
 static struct hlist_head inet_addr_lst[IN4_ADDR_HSIZE];
-static DEFINE_SPINLOCK(inet_addr_hash_lock);
 
 static u32 inet_addr_hash(struct net *net, __be32 addr)
 {
@@ -119,16 +118,14 @@ static void inet_hash_insert(struct net *net, struct in_ifaddr *ifa)
 {
 	u32 hash = inet_addr_hash(net, ifa->ifa_local);
 
-	spin_lock(&inet_addr_hash_lock);
+	ASSERT_RTNL();
 	hlist_add_head_rcu(&ifa->hash, &inet_addr_lst[hash]);
-	spin_unlock(&inet_addr_hash_lock);
 }
 
 static void inet_hash_remove(struct in_ifaddr *ifa)
 {
-	spin_lock(&inet_addr_hash_lock);
+	ASSERT_RTNL();
 	hlist_del_init_rcu(&ifa->hash);
-	spin_unlock(&inet_addr_hash_lock);
 }
 
 /**
