From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 1/3] bridge: select IP addr as source addr for querier
Date: Tue, 30 Apr 2013 15:10:17 +0800
Message-ID: <1367305819-14013-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753501Ab3D3HKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 03:10:51 -0400
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

And introduce a new troggle for it, by default we still use
0.0.0.0 as src IP.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v2: introduce a new troggle

 net/bridge/br_multicast.c |    5 ++++-
 net/bridge/br_private.h   |    1 +
 net/bridge/br_sysfs_br.c  |   25 +++++++++++++++++++++++++
 3 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 81f2389..c52d4f3 100644
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
+	iph->saddr = br->multicast_query_zero_source ?
+		     0 : inet_select_addr(br->dev, 0, RT_SCOPE_LINK);
 	iph->daddr = htonl(INADDR_ALLHOSTS_GROUP);
 	((u8 *)&iph[1])[0] = IPOPT_RA;
 	((u8 *)&iph[1])[1] = 4;
@@ -1618,6 +1620,7 @@ void br_multicast_init(struct net_bridge *br)
 
 	br->multicast_router = 1;
 	br->multicast_querier = 0;
+	br->multicast_query_zero_source = 1;
 	br->multicast_last_member_count = 2;
 	br->multicast_startup_query_count = 2;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d2c043a..695033f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -249,6 +249,7 @@ struct net_bridge
 
 	u8				multicast_disabled:1;
 	u8				multicast_querier:1;
+	u8				multicast_query_zero_source:1;
 
 	u32				hash_elasticity;
 	u32				hash_max;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 8baa9c0..ebdfafb 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -375,6 +375,30 @@ static ssize_t store_multicast_snooping(struct device *d,
 static DEVICE_ATTR(multicast_snooping, S_IRUGO | S_IWUSR,
 		   show_multicast_snooping, store_multicast_snooping);
 
+static ssize_t show_multicast_query_zero_source(struct device *d,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->multicast_query_zero_source);
+}
+
+static int set_query_zero_source(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_query_zero_source = !!val;
+	return 0;
+}
+
+static ssize_t store_multicast_query_zero_source(struct device *d,
+				       struct device_attribute *attr,
+				       const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_query_zero_source);
+}
+static DEVICE_ATTR(multicast_query_zero_source, S_IRUGO | S_IWUSR,
+		   show_multicast_query_zero_source,
+		   store_multicast_query_zero_source);
+
 static ssize_t show_multicast_querier(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
@@ -734,6 +758,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
 	&dev_attr_multicast_querier.attr,
+	&dev_attr_multicast_query_zero_source.attr,
 	&dev_attr_hash_elasticity.attr,
 	&dev_attr_hash_max.attr,
 	&dev_attr_multicast_last_member_count.attr,
-- 
1.7.7.6
