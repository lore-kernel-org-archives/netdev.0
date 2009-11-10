From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/10] ipv6: use RCU to walk list of network devices
Date: Tue, 10 Nov 2009 09:54:54 -0800
Message-ID: <20091110175647.683253741@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58737 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756429AbZKJSIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:08:05 -0500
Content-Disposition: inline; filename=ipv6-rdlock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer need read_lock(&dev_base_lock), use RCU instead.
This also needs to be optimized for large number of devices.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2009-11-09 22:19:08.925480813 -0800
+++ b/net/ipv6/addrconf.c	2009-11-10 09:28:38.577438386 -0800
@@ -3828,9 +3828,9 @@ static int inet6_dump_ifinfo(struct sk_b
 	struct net_device *dev;
 	struct inet6_dev *idev;
 
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	idx = 0;
-	for_each_netdev(net, dev) {
+	for_each_netdev_rcu(net, dev) {
 		if (idx < s_idx)
 			goto cont;
 		if ((idev = in6_dev_get(dev)) == NULL)
@@ -3843,7 +3843,7 @@ static int inet6_dump_ifinfo(struct sk_b
 cont:
 		idx++;
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 	cb->args[0] = idx;
 
 	return skb->len;
--- a/net/ipv6/anycast.c	2009-11-09 22:19:08.926480759 -0800
+++ b/net/ipv6/anycast.c	2009-11-10 09:28:38.577438386 -0800
@@ -431,7 +431,7 @@ static inline struct ifacaddr6 *ac6_get_
 	struct net *net = seq_file_net(seq);
 
 	state->idev = NULL;
-	for_each_netdev(net, state->dev) {
+	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
 		idev = in6_dev_get(state->dev);
 		if (!idev)
@@ -482,9 +482,9 @@ static struct ifacaddr6 *ac6_get_idx(str
 }
 
 static void *ac6_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(rcu)
 {
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	return ac6_get_idx(seq, *pos);
 }
 
@@ -497,14 +497,14 @@ static void *ac6_seq_next(struct seq_fil
 }
 
 static void ac6_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(rcu)
 {
 	struct ac6_iter_state *state = ac6_seq_private(seq);
 	if (likely(state->idev != NULL)) {
 		read_unlock_bh(&state->idev->lock);
 		in6_dev_put(state->idev);
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static int ac6_seq_show(struct seq_file *seq, void *v)
--- a/net/ipv6/mcast.c	2009-11-09 22:19:08.929480873 -0800
+++ b/net/ipv6/mcast.c	2009-11-10 09:28:38.578438329 -0800
@@ -2375,7 +2375,7 @@ static inline struct ifmcaddr6 *igmp6_mc
 	struct net *net = seq_file_net(seq);
 
 	state->idev = NULL;
-	for_each_netdev(net, state->dev) {
+	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
 		idev = in6_dev_get(state->dev);
 		if (!idev)
@@ -2426,9 +2426,9 @@ static struct ifmcaddr6 *igmp6_mc_get_id
 }
 
 static void *igmp6_mc_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(rcu)
 {
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	return igmp6_mc_get_idx(seq, *pos);
 }
 
@@ -2441,7 +2441,7 @@ static void *igmp6_mc_seq_next(struct se
 }
 
 static void igmp6_mc_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(rcu)
 {
 	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
 	if (likely(state->idev != NULL)) {
@@ -2450,7 +2450,7 @@ static void igmp6_mc_seq_stop(struct seq
 		state->idev = NULL;
 	}
 	state->dev = NULL;
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static int igmp6_mc_seq_show(struct seq_file *seq, void *v)
@@ -2507,7 +2507,7 @@ static inline struct ip6_sf_list *igmp6_
 
 	state->idev = NULL;
 	state->im = NULL;
-	for_each_netdev(net, state->dev) {
+	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
 		idev = in6_dev_get(state->dev);
 		if (unlikely(idev == NULL))
@@ -2573,9 +2573,9 @@ static struct ip6_sf_list *igmp6_mcf_get
 }
 
 static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(rcu)
 {
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	return *pos ? igmp6_mcf_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
@@ -2591,7 +2591,7 @@ static void *igmp6_mcf_seq_next(struct s
 }
 
 static void igmp6_mcf_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(rcu)
 {
 	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
 	if (likely(state->im != NULL)) {
@@ -2604,7 +2604,7 @@ static void igmp6_mcf_seq_stop(struct se
 		state->idev = NULL;
 	}
 	state->dev = NULL;
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static int igmp6_mcf_seq_show(struct seq_file *seq, void *v)

-- 

