From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 05/11] net: Add inet_addr lookup by table
Date: Thu, 13 Aug 2015 14:59:04 -0600
Message-ID: <1439499551-90231-6-git-send-email-dsa@cumulusnetworks.com>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34245 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbbHMVAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:00:00 -0400
Received: by igui7 with SMTP id i7so91462666igu.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 13:59:59 -0700 (PDT)
In-Reply-To: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently inet_addr_type and inet_dev_addr_type expect local addresses
to be in the local table. With the VRF device local routes for devices
associated with a VRF will be in the table associated with the VRF.
Provide an alternate inet_addr lookup to use a specific table rather
than defaulting to the local table.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/route.h     |  1 +
 net/ipv4/fib_frontend.c | 22 +++++++++++++++-------
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 94189d4bd899..6ba681f0b98d 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -189,6 +189,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk);
 void ip_rt_send_redirect(struct sk_buff *skb);
 
 unsigned int inet_addr_type(struct net *net, __be32 addr);
+unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr);
 void ip_rt_multicast_event(struct in_device *);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index d8ced1d89f1b..b11321a8e58d 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -212,12 +212,12 @@ void fib_flush_external(struct net *net)
  */
 static inline unsigned int __inet_dev_addr_type(struct net *net,
 						const struct net_device *dev,
-						__be32 addr)
+						__be32 addr, int tb_id)
 {
 	struct flowi4		fl4 = { .daddr = addr };
 	struct fib_result	res;
 	unsigned int ret = RTN_BROADCAST;
-	struct fib_table *local_table;
+	struct fib_table *table;
 
 	if (ipv4_is_zeronet(addr) || ipv4_is_lbcast(addr))
 		return RTN_BROADCAST;
@@ -226,10 +226,10 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 
 	rcu_read_lock();
 
-	local_table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (local_table) {
+	table = fib_get_table(net, tb_id);
+	if (table) {
 		ret = RTN_UNICAST;
-		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
+		if (!fib_table_lookup(table, &fl4, &res, FIB_LOOKUP_NOREF)) {
 			if (!dev || dev == res.fi->fib_dev)
 				ret = res.type;
 		}
@@ -239,16 +239,24 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	return ret;
 }
 
+unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id)
+{
+	return __inet_dev_addr_type(net, NULL, addr, tb_id);
+}
+EXPORT_SYMBOL(inet_addr_type_table);
+
 unsigned int inet_addr_type(struct net *net, __be32 addr)
 {
-	return __inet_dev_addr_type(net, NULL, addr);
+	return __inet_dev_addr_type(net, NULL, addr, RT_TABLE_LOCAL);
 }
 EXPORT_SYMBOL(inet_addr_type);
 
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr)
 {
-	return __inet_dev_addr_type(net, dev, addr);
+	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+
+	return __inet_dev_addr_type(net, dev, addr, rt_table);
 }
 EXPORT_SYMBOL(inet_dev_addr_type);
 
-- 
2.3.2 (Apple Git-55)
