From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/10] IPV4: use rcu to walk list of devices in IGMP
Date: Tue, 10 Nov 2009 09:54:55 -0800
Message-ID: <20091110175647.754389168@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58740 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756550AbZKJSIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:08:10 -0500
Content-Disposition: inline; filename=ipv4-igmp.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also needs to be optimized for large number of devices.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/igmp.c	2009-11-09 22:19:08.899543825 -0800
+++ b/net/ipv4/igmp.c	2009-11-10 09:28:38.636438291 -0800
@@ -2311,7 +2311,7 @@ static inline struct ip_mc_list *igmp_mc
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 
 	state->in_dev = NULL;
-	for_each_netdev(net, state->dev) {
+	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *in_dev;
 		in_dev = in_dev_get(state->dev);
 		if (!in_dev)
@@ -2361,9 +2361,9 @@ static struct ip_mc_list *igmp_mc_get_id
 }
 
 static void *igmp_mc_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(rcu)
 {
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	return *pos ? igmp_mc_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
@@ -2379,7 +2379,7 @@ static void *igmp_mc_seq_next(struct seq
 }
 
 static void igmp_mc_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(rcu)
 {
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 	if (likely(state->in_dev != NULL)) {
@@ -2388,7 +2388,7 @@ static void igmp_mc_seq_stop(struct seq_
 		state->in_dev = NULL;
 	}
 	state->dev = NULL;
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static int igmp_mc_seq_show(struct seq_file *seq, void *v)
@@ -2462,7 +2462,7 @@ static inline struct ip_sf_list *igmp_mc
 
 	state->idev = NULL;
 	state->im = NULL;
-	for_each_netdev(net, state->dev) {
+	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *idev;
 		idev = in_dev_get(state->dev);
 		if (unlikely(idev == NULL))
@@ -2528,8 +2528,9 @@ static struct ip_sf_list *igmp_mcf_get_i
 }
 
 static void *igmp_mcf_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(rcu)
 {
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	return *pos ? igmp_mcf_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
@@ -2545,6 +2546,7 @@ static void *igmp_mcf_seq_next(struct se
 }
 
 static void igmp_mcf_seq_stop(struct seq_file *seq, void *v)
+	__releases(rcu)
 {
 	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
 	if (likely(state->im != NULL)) {
@@ -2557,7 +2559,7 @@ static void igmp_mcf_seq_stop(struct seq
 		state->idev = NULL;
 	}
 	state->dev = NULL;
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static int igmp_mcf_seq_show(struct seq_file *seq, void *v)

-- 

