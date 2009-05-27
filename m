From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix IP DDP appletalk locking.
Date: Wed, 27 May 2009 16:58:04 -0700 (PDT)
Message-ID: <20090527.165804.73643121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755042AbZE0X6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 19:58:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5A50CC8C0F5
	for <netdev@vger.kernel.org>; Wed, 27 May 2009 16:58:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is a patch I had sitting around for a year or so.

When I was doing the TX multiqueue stuff I noticed that the
IPDDP driver did absolutely no locking around it's routing
table even though it's accessed concurrently by the ioctls
and the transmit path.

Added to net-next-2.6

appletalk: Add proper locking around IPDDP routing table.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/appletalk/ipddp.c |   40 ++++++++++++++++++++++++++++++++--------
 1 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index f939e92..9832b75 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -39,6 +39,7 @@
 static const char version[] = KERN_INFO "ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>\n";
 
 static struct ipddp_route *ipddp_route_list;
+static DEFINE_SPINLOCK(ipddp_route_lock);
 
 #ifdef CONFIG_IPDDP_ENCAP
 static int ipddp_mode = IPDDP_ENCAP;
@@ -50,7 +51,7 @@ static int ipddp_mode = IPDDP_DECAP;
 static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev);
 static int ipddp_create(struct ipddp_route *new_rt);
 static int ipddp_delete(struct ipddp_route *rt);
-static struct ipddp_route* ipddp_find_route(struct ipddp_route *rt);
+static struct ipddp_route* __ipddp_find_route(struct ipddp_route *rt);
 static int ipddp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 
 static const struct net_device_ops ipddp_netdev_ops = {
@@ -119,6 +120,8 @@ static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
         struct ipddp_route *rt;
         struct atalk_addr *our_addr;
 
+	spin_lock(&ipddp_route_lock);
+
 	/*
          * Find appropriate route to use, based only on IP number.
          */
@@ -127,8 +130,10 @@ static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
                 if(rt->ip == paddr)
                         break;
         }
-        if(rt == NULL)
+        if(rt == NULL) {
+		spin_unlock(&ipddp_route_lock);
                 return 0;
+	}
 
         our_addr = atalk_find_dev_addr(rt->dev);
 
@@ -174,6 +179,8 @@ static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
         if(aarp_send_ddp(rt->dev, skb, &rt->at, NULL) < 0)
                 dev_kfree_skb(skb);
 
+	spin_unlock(&ipddp_route_lock);
+
         return 0;
 }
 
@@ -196,7 +203,9 @@ static int ipddp_create(struct ipddp_route *new_rt)
                 return -ENETUNREACH;
         }
 
-	if (ipddp_find_route(rt)) {
+	spin_lock_bh(&ipddp_route_lock);
+	if (__ipddp_find_route(rt)) {
+		spin_unlock_bh(&ipddp_route_lock);
 		kfree(rt);
 		return -EEXIST;
 	}
@@ -204,6 +213,8 @@ static int ipddp_create(struct ipddp_route *new_rt)
         rt->next = ipddp_route_list;
         ipddp_route_list = rt;
 
+	spin_unlock_bh(&ipddp_route_lock);
+
         return 0;
 }
 
@@ -216,6 +227,7 @@ static int ipddp_delete(struct ipddp_route *rt)
         struct ipddp_route **r = &ipddp_route_list;
         struct ipddp_route *tmp;
 
+	spin_lock_bh(&ipddp_route_lock);
         while((tmp = *r) != NULL)
         {
                 if(tmp->ip == rt->ip
@@ -223,19 +235,21 @@ static int ipddp_delete(struct ipddp_route *rt)
                         && tmp->at.s_node == rt->at.s_node)
                 {
                         *r = tmp->next;
+			spin_unlock_bh(&ipddp_route_lock);
                         kfree(tmp);
                         return 0;
                 }
                 r = &tmp->next;
         }
 
+	spin_unlock_bh(&ipddp_route_lock);
         return (-ENOENT);
 }
 
 /*
  * Find a routing entry, we only return a FULL match
  */
-static struct ipddp_route* ipddp_find_route(struct ipddp_route *rt)
+static struct ipddp_route* __ipddp_find_route(struct ipddp_route *rt)
 {
         struct ipddp_route *f;
 
@@ -253,7 +267,7 @@ static struct ipddp_route* ipddp_find_route(struct ipddp_route *rt)
 static int ipddp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
         struct ipddp_route __user *rt = ifr->ifr_data;
-        struct ipddp_route rcp;
+        struct ipddp_route rcp, rcp2, *rp;
 
         if(!capable(CAP_NET_ADMIN))
                 return -EPERM;
@@ -267,9 +281,19 @@ static int ipddp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
                         return (ipddp_create(&rcp));
 
                 case SIOCFINDIPDDPRT:
-                        if(copy_to_user(rt, ipddp_find_route(&rcp), sizeof(struct ipddp_route)))
-                                return -EFAULT;
-                        return 0;
+			spin_lock_bh(&ipddp_route_lock);
+			rp = __ipddp_find_route(&rcp);
+			if (rp)
+				memcpy(&rcp2, rp, sizeof(rcp2));
+			spin_unlock_bh(&ipddp_route_lock);
+
+			if (rp) {
+				if (copy_to_user(rt, &rcp2,
+						 sizeof(struct ipddp_route)))
+					return -EFAULT;
+				return 0;
+			} else
+				return -ENOENT;
 
                 case SIOCDELIPDDPRT:
                         return (ipddp_delete(&rcp));
-- 
1.6.3

