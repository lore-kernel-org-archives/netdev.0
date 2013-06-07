From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression from routing cache removal?
Date: Thu, 06 Jun 2013 17:35:01 -0700
Message-ID: <1370565301.24311.396.camel@edumazet-glaptop>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
	 <1370455997.24311.290.camel@edumazet-glaptop>
	 <20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
	 <1370465535.24311.304.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:56288 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab3FGAfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 20:35:07 -0400
Received: by mail-oa0-f44.google.com with SMTP id n12so2819215oag.3
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 17:35:06 -0700 (PDT)
In-Reply-To: <1370465535.24311.304.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 13:52 -0700, Eric Dumazet wrote:

> It can be easily done, with a threshold : 
> 
> Above say 4 multicast addresses in the mc_list, allocate a hash table
> and populate it.

Please try the following (untested) patch :

 include/linux/igmp.h       |    1 
 include/linux/inetdevice.h |    5 ++
 net/ipv4/igmp.c            |   73 +++++++++++++++++++++++++++++++++--
 3 files changed, 76 insertions(+), 3 deletions(-)

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
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 450f625..9c60482 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1217,6 +1217,56 @@ static void igmp_group_added(struct ip_mc_list *im)
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
+	} else if (in_dev->mc_count >= 4) {
+		mc_hash = kzalloc(sizeof(struct ip_mc_list *) << MC_HASH_SZ_LOG,
+				  GFP_KERNEL);
+		if (mc_hash) {
+			struct ip_mc_list *aux = rtnl_dereference(in_dev->mc_list);
+
+			while (aux) {
+				hash = ip_mc_hash(aux);
+
+				aux->next_hash = rcu_dereference_protected(mc_hash[hash], 1);
+				RCU_INIT_POINTER(mc_hash[hash], aux);
+				aux = rtnl_dereference(aux->next_rcu);
+			}
+			rcu_assign_pointer(in_dev->mc_hash, mc_hash);
+		}
+	}
+}
+
+static void ip_mc_hash_remove(struct in_device *in_dev,
+			      struct ip_mc_list *im)
+{
+	struct ip_mc_list __rcu **mc_hash = rtnl_dereference(in_dev->mc_hash);
+	struct ip_mc_list *aux;
+	unsigned int hash;
+
+	if (!mc_hash)
+		return;
+	hash = ip_mc_hash(im);
+	mc_hash += hash;
+	while ((aux = rtnl_dereference(*mc_hash)) != im)
+		mc_hash = &aux->next_hash;
+	*mc_hash = im->next_hash;
+}
+
 
 /*
  *	A socket has joined a multicast group on device dev.
@@ -1258,6 +1308,8 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	in_dev->mc_count++;
 	rcu_assign_pointer(in_dev->mc_list, im);
 
+	ip_mc_hash_add(in_dev, im);
+
 #ifdef CONFIG_IP_MULTICAST
 	igmpv3_del_delrec(in_dev, im->multiaddr);
 #endif
@@ -1314,6 +1366,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 	     ip = &i->next_rcu) {
 		if (i->multiaddr == addr) {
 			if (--i->users == 0) {
+				ip_mc_hash_remove(in_dev, i);
 				*ip = i->next_rcu;
 				in_dev->mc_count--;
 				igmp_group_dropped(i);
@@ -1431,6 +1484,7 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 		ip_mc_clear_src(i);
 		ip_ma_put(i);
 	}
+	kfree(in_dev->mc_hash);
 }
 
 /* RTNL is locked */
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
