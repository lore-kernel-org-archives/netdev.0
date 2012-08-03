From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove parentheses in return statement
Date: Fri, 03 Aug 2012 11:53:58 +0200
Message-ID: <1343987638.9299.912.camel@edumazet-glaptop>
References: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
	 <1343985584.9299.873.camel@edumazet-glaptop>
	 <20120803.022240.1997423719431165575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sakiwit@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37593 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab2HCJyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 05:54:03 -0400
Received: by bkwj10 with SMTP id j10so171223bkw.19
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 02:54:01 -0700 (PDT)
In-Reply-To: <20120803.022240.1997423719431165575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-03 at 02:22 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 03 Aug 2012 11:19:44 +0200
> 
> > On Fri, 2012-08-03 at 01:43 -0600, Jean Sacren wrote:
> > 
> >> @@ -106,8 +106,8 @@ static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
> >>  {
> >>  	u32 val = (__force u32) addr ^ hash_ptr(net, 8);
> >>  
> >> -	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> >> -		(IN4_ADDR_HSIZE - 1));
> >> +	return (val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> >> +	       (IN4_ADDR_HSIZE - 1);
> >>  }
> > 
> > BTW This should use a faster implementation, I'll send a patch when
> > net-next is opened.
> 
> There seems to be a few spots where we want the pointer "as a 32-bit
> integer" for hashing.  We were discussing arp_hashfn() and ndisc_hashfn()
> the other day.
> 
> It should basically do something like:
> 
> 	(u32) ((u64)ptr >> 32 | ((u32) ptr))
> 
> on 64-bit and simply (u32)(ptr) on 32-bit.

We already have such thing in fact : net_hash_mix() which returns 0 if
NS are not configured.

(hash_ptr(net,8) is really overkill on 64bit arches)

High order bits on "struct net *" have absolutely no entropy, unless you
have a monster machine (more than 256 GB of ram)

This is the patch I prepared :


diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 44bf82e..b9753ab 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -94,25 +94,22 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 	[IFA_LABEL]     	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 };
 
-/* inet_addr_hash's shifting is dependent upon this IN4_ADDR_HSIZE
- * value.  So if you change this define, make appropriate changes to
- * inet_addr_hash as well.
- */
-#define IN4_ADDR_HSIZE	256
+#define IN4_ADDR_HSIZE_SHIFT	8
+#define IN4_ADDR_HSIZE		(1U << IN4_ADDR_HSIZE_SHIFT)
+
 static struct hlist_head inet_addr_lst[IN4_ADDR_HSIZE];
 static DEFINE_SPINLOCK(inet_addr_hash_lock);
 
-static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
+static u32 inet_addr_hash(struct net *net, __be32 addr)
 {
-	u32 val = (__force u32) addr ^ hash_ptr(net, 8);
+	u32 val = (__force u32) addr ^ net_hash_mix(net);
 
-	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
-		(IN4_ADDR_HSIZE - 1));
+	return hash_32(val, IN4_ADDR_HSIZE_SHIFT);
 }
 
 static void inet_hash_insert(struct net *net, struct in_ifaddr *ifa)
 {
-	unsigned int hash = inet_addr_hash(net, ifa->ifa_local);
+	u32 hash = inet_addr_hash(net, ifa->ifa_local);
 
 	spin_lock(&inet_addr_hash_lock);
 	hlist_add_head_rcu(&ifa->hash, &inet_addr_lst[hash]);
@@ -136,18 +133,18 @@ static void inet_hash_remove(struct in_ifaddr *ifa)
  */
 struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 {
-	unsigned int hash = inet_addr_hash(net, addr);
+	u32 hash = inet_addr_hash(net, addr);
 	struct net_device *result = NULL;
 	struct in_ifaddr *ifa;
 	struct hlist_node *node;
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(ifa, node, &inet_addr_lst[hash], hash) {
-		struct net_device *dev = ifa->ifa_dev->dev;
-
-		if (!net_eq(dev_net(dev), net))
-			continue;
 		if (ifa->ifa_local == addr) {
+			struct net_device *dev = ifa->ifa_dev->dev;
+
+			if (!net_eq(dev_net(dev), net)
+				continue;
 			result = dev;
 			break;
 		}
