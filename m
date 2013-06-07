From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igmp: hash a hash table to speedup
 ip_check_mc_rcu()
Date: Fri, 07 Jun 2013 08:48:57 -0700
Message-ID: <1370620137.24311.433.camel@edumazet-glaptop>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
	 <1370455997.24311.290.camel@edumazet-glaptop>
	 <20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
	 <1370465535.24311.304.camel@edumazet-glaptop>
	 <1370565301.24311.396.camel@edumazet-glaptop>
	 <20130607144833.GB2995@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:46670 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab3FGPtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 11:49:00 -0400
Received: by mail-pa0-f45.google.com with SMTP id bi5so2663130pad.4
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 08:49:00 -0700 (PDT)
In-Reply-To: <20130607144833.GB2995@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After IP route cache removal, multicast applications using
a lot of multicast addresses hit a O(N) behavior in ip_check_mc_rcu()

Add a per in_device hash table to get faster lookup.

This hash table is created only if the number of items in mc_list is
above 4.

Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Shawn, this is a different version from the v0.
so please test it and add your "Tested-by: " if OK, thanks.

 include/linux/igmp.h       |    1 
 include/linux/inetdevice.h |    5 ++
 net/ipv4/devinet.c         |    1 
 net/ipv4/igmp.c            |   73 +++++++++++++++++++++++++++++++++--
 4 files changed, 77 insertions(+), 3 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 7f2bf15..e3362b5 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -84,6 +84,7 @@ struct ip_mc_list {
 		struct ip_mc_list *next;
 		struct ip_mc_list __rcu *next_rcu;
 	};
+	struct ip_mc_list __rcu *next_hash;
 	struct timer_list	timer;
 	int			users;
 	atomic_t		refcnt;
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ea1e3b8..b99cd23 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -50,12 +50,17 @@ struct ipv4_devconf {
 	DECLARE_BITMAP(state, IPV4_DEVCONF_MAX);
 };
 
+#define MC_HASH_SZ_LOG 9
+
 struct in_device {
 	struct net_device	*dev;
 	atomic_t		refcnt;
 	int			dead;
 	struct in_ifaddr	*ifa_list;	/* IP ifaddr chain		*/
+
 	struct ip_mc_list __rcu	*mc_list;	/* IP multicast filter chain    */
+	struct ip_mc_list __rcu	* __rcu *mc_hash;
+
 	int			mc_count;	/* Number of installed mcasts	*/
 	spinlock_t		mc_tomb_lock;
 	struct ip_mc_list	*mc_tomb;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index b047e2d..3469506 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -215,6 +215,7 @@ void in_dev_finish_destroy(struct in_device *idev)
 
 	WARN_ON(idev->ifa_list);
 	WARN_ON(idev->mc_list);
+	kfree(rcu_dereference_protected(idev->mc_hash, 1));
 #ifdef NET_REFCNT_DEBUG
 	pr_debug("%s: %p=%s\n", __func__, idev, dev ? dev->name : "NIL");
 #endif
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 450f625..f72011d 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1217,6 +1217,57 @@ static void igmp_group_added(struct ip_mc_list *im)
  *	Multicast list managers
  */
 
+static u32 ip_mc_hash(const struct ip_mc_list *im)
+{
+	return hash_32((u32)im->multiaddr, MC_HASH_SZ_LOG);
+}
+
+static void ip_mc_hash_add(struct in_device *in_dev,
+			   struct ip_mc_list *im)
+{
+	struct ip_mc_list __rcu **mc_hash;
+	u32 hash;
+
+	mc_hash = rtnl_dereference(in_dev->mc_hash);
+	if (mc_hash) {
+		hash = ip_mc_hash(im);
+		im->next_hash = rtnl_dereference(mc_hash[hash]);
+		rcu_assign_pointer(mc_hash[hash], im);
+		return;
+	}
+
+	/* do not use a hash table for small number of items */
+	if (in_dev->mc_count < 4)
+		return;
+
+	mc_hash = kzalloc(sizeof(struct ip_mc_list *) << MC_HASH_SZ_LOG,
+			  GFP_KERNEL);
+	if (!mc_hash)
+		return;
+
+	for_each_pmc_rtnl(in_dev, im) {
+		hash = ip_mc_hash(im);
+		im->next_hash = rtnl_dereference(mc_hash[hash]);
+		RCU_INIT_POINTER(mc_hash[hash], im);
+	}
+
+	rcu_assign_pointer(in_dev->mc_hash, mc_hash);
+}
+
+static void ip_mc_hash_remove(struct in_device *in_dev,
+			      struct ip_mc_list *im)
+{
+	struct ip_mc_list __rcu **mc_hash = rtnl_dereference(in_dev->mc_hash);
+	struct ip_mc_list *aux;
+
+	if (!mc_hash)
+		return;
+	mc_hash += ip_mc_hash(im);
+	while ((aux = rtnl_dereference(*mc_hash)) != im)
+		mc_hash = &aux->next_hash;
+	*mc_hash = im->next_hash;
+}
+
 
 /*
  *	A socket has joined a multicast group on device dev.
@@ -1258,6 +1309,8 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	in_dev->mc_count++;
 	rcu_assign_pointer(in_dev->mc_list, im);
 
+	ip_mc_hash_add(in_dev, im);
+
 #ifdef CONFIG_IP_MULTICAST
 	igmpv3_del_delrec(in_dev, im->multiaddr);
 #endif
@@ -1314,6 +1367,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 	     ip = &i->next_rcu) {
 		if (i->multiaddr == addr) {
 			if (--i->users == 0) {
+				ip_mc_hash_remove(in_dev, i);
 				*ip = i->next_rcu;
 				in_dev->mc_count--;
 				igmp_group_dropped(i);
@@ -2321,12 +2375,25 @@ void ip_mc_drop_socket(struct sock *sk)
 int ip_check_mc_rcu(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 proto)
 {
 	struct ip_mc_list *im;
+	struct ip_mc_list __rcu **mc_hash;
 	struct ip_sf_list *psf;
 	int rv = 0;
 
-	for_each_pmc_rcu(in_dev, im) {
-		if (im->multiaddr == mc_addr)
-			break;
+	mc_hash = rcu_dereference(in_dev->mc_hash);
+	if (mc_hash) {
+		u32 hash = hash_32((u32)mc_addr, MC_HASH_SZ_LOG);
+
+		for (im = rcu_dereference(mc_hash[hash]);
+		     im != NULL;
+		     im = rcu_dereference(im->next_hash)) {
+			if (im->multiaddr == mc_addr)
+				break;
+		}
+	} else {
+		for_each_pmc_rcu(in_dev, im) {
+			if (im->multiaddr == mc_addr)
+				break;
+		}
 	}
 	if (im && proto == IPPROTO_IGMP) {
 		rv = 1;
