From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v5 1/3] bridge: use the bridge IP addr as source addr for querier
Date: Wed, 22 May 2013 15:52:54 +0800
Message-ID: <1369209176-6841-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31002 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143Ab3EVHx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 03:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Quote from Adam:
"If it is believed that the use of 0.0.0.0
as the IP address is what is causing strange behaviour on other devices
then is there a good reason that a bridge rather than a router shouldn't
be the active querier? If not then using the bridge IP address and
having the querier enabled by default may be a reasonable solution
(provided that our querier obeys the election rules and shuts up if it
sees a query from a lower IP address that isn't 0.0.0.0). Just because a
device is the elected querier for IGMP doesn't appear to mean it is
required to perform any other routing functions."

And introduce a new troggle for it, as suggested by Herbert.

Suggested-by: Adam Baker <linux@baker-net.org.uk>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v5: change the sysfs file name to multicast_query_use_ifaddr
v4: no change
v3: no change
v2: introduce a new troggle

 net/bridge/br_multicast.c |    5 ++++-
 net/bridge/br_private.h   |    1 +
 net/bridge/br_sysfs_br.c  |   26 ++++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 81f2389..2475147 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -23,6 +23,7 @@
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/timer.h>
+#include <linux/inetdevice.h>
 #include <net/ip.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -381,7 +382,8 @@ static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
 	iph->frag_off = htons(IP_DF);
 	iph->ttl = 1;
 	iph->protocol = IPPROTO_IGMP;
-	iph->saddr = 0;
+	iph->saddr = br->multicast_query_use_ifaddr ?
+		     inet_select_addr(br->dev, 0, RT_SCOPE_LINK) : 0;
 	iph->daddr = htonl(INADDR_ALLHOSTS_GROUP);
 	((u8 *)&iph[1])[0] = IPOPT_RA;
 	((u8 *)&iph[1])[1] = 4;
@@ -1618,6 +1620,7 @@ void br_multicast_init(struct net_bridge *br)
 
 	br->multicast_router = 1;
 	br->multicast_querier = 0;
+	br->multicast_query_use_ifaddr = 0;
 	br->multicast_last_member_count = 2;
 	br->multicast_startup_query_count = 2;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d2c043a..e260710 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -249,6 +249,7 @@ struct net_bridge
 
 	u8				multicast_disabled:1;
 	u8				multicast_querier:1;
+	u8				multicast_query_use_ifaddr:1;
 
 	u32				hash_elasticity;
 	u32				hash_max;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 8baa9c0..394bb96 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -375,6 +375,31 @@ static ssize_t store_multicast_snooping(struct device *d,
 static DEVICE_ATTR(multicast_snooping, S_IRUGO | S_IWUSR,
 		   show_multicast_snooping, store_multicast_snooping);
 
+static ssize_t show_multicast_query_use_ifaddr(struct device *d,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->multicast_query_use_ifaddr);
+}
+
+static int set_query_use_ifaddr(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_query_use_ifaddr = !!val;
+	return 0;
+}
+
+static ssize_t
+store_multicast_query_use_ifaddr(struct device *d,
+				 struct device_attribute *attr,
+				 const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_query_use_ifaddr);
+}
+static DEVICE_ATTR(multicast_query_use_ifaddr, S_IRUGO | S_IWUSR,
+		   show_multicast_query_use_ifaddr,
+		   store_multicast_query_use_ifaddr);
+
 static ssize_t show_multicast_querier(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
@@ -734,6 +759,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
 	&dev_attr_multicast_querier.attr,
+	&dev_attr_multicast_query_use_ifaddr.attr,
 	&dev_attr_hash_elasticity.attr,
 	&dev_attr_hash_max.attr,
 	&dev_attr_multicast_last_member_count.attr,
-- 
1.7.7.6
