From: Andrey Savochkin <saw@swsoft.com>
Subject: [patch 2/7] net_device list cleanup: proc seq_file output
Date: Mon, 3 Jul 2006 12:18:52 +0400
Message-ID: <20060630151207.B22285@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:32520 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1750944AbWGCQcA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 12:32:00 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060630150823.A22285@castle.nmd.msu.ru>; from "Andrey Savochkin" on Fri, Jun 30, 2006 at 03:08:23PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup of net_device list use in seq_file output routines in core networking
files.  Implementation of /proc/net/dev was copied from dev_mcast, since the
latter did the same in a more compact and cleaner way.

The cleanup consists of
 - converting the to list_head, to make the list double-linked (thus making
   remove operation O(1)), and list walks more readable;
 - introducing of for_each_netdev wrapper over list_for_each.

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
---
Note: functions covered by this patch are good candidates for further
restructuring by introduction of "library" routines for seq_file's showing some
information for each device.

 core/dev.c       |   23 +++++++++++------------
 core/dev_mcast.c |    4 ++--
 ipv4/igmp.c      |   25 +++++++++++++++----------
 ipv6/anycast.c   |   12 +++++++-----
 ipv6/mcast.c     |   25 +++++++++++++++----------
 5 files changed, 50 insertions(+), 39 deletions(-)

--- ./net/core/dev.c.vedevbase-proc	Mon Jul  3 16:09:54 2006
+++ ./net/core/dev.c	Mon Jul  3 16:09:54 2006
@@ -2072,26 +2072,25 @@ static int dev_ifconf(char __user *arg)
  *	This is invoked by the /proc filesystem handler to display a device
  *	in detail.
  */
-static __inline__ struct net_device *dev_get_idx(loff_t pos)
-{
-	struct net_device *dev;
-	loff_t i;
-
-	for (i = 0, dev = dev_base; dev && i < pos; ++i, dev = dev->next);
-
-	return i == pos ? dev : NULL;
-}
-
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	struct net_device *dev;
+	loff_t off = 1;
 	read_lock(&dev_base_lock);
-	return *pos ? dev_get_idx(*pos - 1) : SEQ_START_TOKEN;
+	if (!*pos)
+		return SEQ_START_TOKEN;
+	for_each_netdev(dev) {
+		if (off++ == *pos)
+			return dev;
+	}
+	return NULL;
 }
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
+	struct net_device *dev = v;
 	++*pos;
-	return v == SEQ_START_TOKEN ? dev_base : ((struct net_device *)v)->next;
+	return v == SEQ_START_TOKEN ? first_netdev() : next_netdev(dev);
 }
 
 void dev_seq_stop(struct seq_file *seq, void *v)
--- ./net/core/dev_mcast.c.vedevbase-proc	Mon Jul  3 15:14:19 2006
+++ ./net/core/dev_mcast.c	Mon Jul  3 16:09:54 2006
@@ -225,7 +225,7 @@ static void *dev_mc_seq_start(struct seq
 	loff_t off = 0;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		if (off++ == *pos) 
 			return dev;
 	}
@@ -236,7 +236,7 @@ static void *dev_mc_seq_next(struct seq_
 {
 	struct net_device *dev = v;
 	++*pos;
-	return dev->next;
+	return next_netdev(dev);
 }
 
 static void dev_mc_seq_stop(struct seq_file *seq, void *v)
--- ./net/ipv4/igmp.c.vedevbase-proc	Mon Jul  3 15:14:20 2006
+++ ./net/ipv4/igmp.c	Mon Jul  3 16:09:54 2006
@@ -2254,19 +2254,21 @@ struct igmp_mc_iter_state {
 
 static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
 {
+	struct net_device *dev;
 	struct ip_mc_list *im = NULL;
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 
-	for (state->dev = dev_base, state->in_dev = NULL;
-	     state->dev; 
-	     state->dev = state->dev->next) {
+	state->dev = NULL;
+	state->in_dev = NULL;
+	for_each_netdev(dev) {
 		struct in_device *in_dev;
-		in_dev = in_dev_get(state->dev);
+		in_dev = in_dev_get(dev);
 		if (!in_dev)
 			continue;
 		read_lock(&in_dev->mc_list_lock);
 		im = in_dev->mc_list;
 		if (im) {
+			state->dev = dev;
 			state->in_dev = in_dev;
 			break;
 		}
@@ -2285,7 +2287,7 @@ static struct ip_mc_list *igmp_mc_get_ne
 			read_unlock(&state->in_dev->mc_list_lock);
 			in_dev_put(state->in_dev);
 		}
-		state->dev = state->dev->next;
+		state->dev = next_netdev(state->dev);
 		if (!state->dev) {
 			state->in_dev = NULL;
 			break;
@@ -2416,15 +2418,17 @@ struct igmp_mcf_iter_state {
 
 static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 {
+	struct net_device *dev;
 	struct ip_sf_list *psf = NULL;
 	struct ip_mc_list *im = NULL;
 	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
 
-	for (state->dev = dev_base, state->idev = NULL, state->im = NULL;
-	     state->dev; 
-	     state->dev = state->dev->next) {
+	state->dev = NULL;
+	state->im = NULL;
+	state->idev = NULL;
+	for_each_netdev(dev) {
 		struct in_device *idev;
-		idev = in_dev_get(state->dev);
+		idev = in_dev_get(dev);
 		if (unlikely(idev == NULL))
 			continue;
 		read_lock(&idev->mc_list_lock);
@@ -2433,6 +2437,7 @@ static inline struct ip_sf_list *igmp_mc
 			spin_lock_bh(&im->lock);
 			psf = im->sources;
 			if (likely(psf != NULL)) {
+				state->dev = dev;
 				state->im = im;
 				state->idev = idev;
 				break;
@@ -2458,7 +2463,7 @@ static struct ip_sf_list *igmp_mcf_get_n
 				read_unlock(&state->idev->mc_list_lock);
 				in_dev_put(state->idev);
 			}
-			state->dev = state->dev->next;
+			state->dev = next_netdev(state->dev);
 			if (!state->dev) {
 				state->idev = NULL;
 				goto out;
--- ./net/ipv6/anycast.c.vedevbase-proc	Mon Jul  3 16:09:54 2006
+++ ./net/ipv6/anycast.c	Mon Jul  3 16:09:54 2006
@@ -447,19 +447,21 @@ struct ac6_iter_state {
 
 static inline struct ifacaddr6 *ac6_get_first(struct seq_file *seq)
 {
+	struct net_device *dev;
 	struct ifacaddr6 *im = NULL;
 	struct ac6_iter_state *state = ac6_seq_private(seq);
 
-	for (state->dev = dev_base, state->idev = NULL;
-	     state->dev;
-	     state->dev = state->dev->next) {
+	state->dev = NULL;
+	state->idev = NULL;
+	for_each_netdev(dev) {
 		struct inet6_dev *idev;
-		idev = in6_dev_get(state->dev);
+		idev = in6_dev_get(dev);
 		if (!idev)
 			continue;
 		read_lock_bh(&idev->lock);
 		im = idev->ac_list;
 		if (im) {
+			state->dev = dev;
 			state->idev = idev;
 			break;
 		}
@@ -478,7 +480,7 @@ static struct ifacaddr6 *ac6_get_next(st
 			read_unlock_bh(&state->idev->lock);
 			in6_dev_put(state->idev);
 		}
-		state->dev = state->dev->next;
+		state->dev = next_netdev(state->dev);
 		if (!state->dev) {
 			state->idev = NULL;
 			break;
--- ./net/ipv6/mcast.c.vedevbase-proc	Mon Jul  3 15:14:22 2006
+++ ./net/ipv6/mcast.c	Mon Jul  3 16:09:54 2006
@@ -2322,19 +2322,21 @@ struct igmp6_mc_iter_state {
 
 static inline struct ifmcaddr6 *igmp6_mc_get_first(struct seq_file *seq)
 {
+	struct net_device *dev;
 	struct ifmcaddr6 *im = NULL;
 	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
 
-	for (state->dev = dev_base, state->idev = NULL;
-	     state->dev; 
-	     state->dev = state->dev->next) {
+	state->dev = NULL;
+	state->idev = NULL;
+	for_each_netdev(dev) {
 		struct inet6_dev *idev;
-		idev = in6_dev_get(state->dev);
+		idev = in6_dev_get(dev);
 		if (!idev)
 			continue;
 		read_lock_bh(&idev->lock);
 		im = idev->mc_list;
 		if (im) {
+			state->dev = dev;
 			state->idev = idev;
 			break;
 		}
@@ -2354,7 +2356,7 @@ static struct ifmcaddr6 *igmp6_mc_get_ne
 			read_unlock_bh(&state->idev->lock);
 			in6_dev_put(state->idev);
 		}
-		state->dev = state->dev->next;
+		state->dev = next_netdev(state->dev);
 		if (!state->dev) {
 			state->idev = NULL;
 			break;
@@ -2465,15 +2467,17 @@ struct igmp6_mcf_iter_state {
 
 static inline struct ip6_sf_list *igmp6_mcf_get_first(struct seq_file *seq)
 {
+	struct net_device *dev;
 	struct ip6_sf_list *psf = NULL;
 	struct ifmcaddr6 *im = NULL;
 	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
 
-	for (state->dev = dev_base, state->idev = NULL, state->im = NULL;
-	     state->dev; 
-	     state->dev = state->dev->next) {
+	state->dev = NULL;
+	state->im = NULL;
+	state->idev = NULL;
+	for_each_netdev(dev) {
 		struct inet6_dev *idev;
-		idev = in6_dev_get(state->dev);
+		idev = in6_dev_get(dev);
 		if (unlikely(idev == NULL))
 			continue;
 		read_lock_bh(&idev->lock);
@@ -2482,6 +2486,7 @@ static inline struct ip6_sf_list *igmp6_
 			spin_lock_bh(&im->mca_lock);
 			psf = im->mca_sources;
 			if (likely(psf != NULL)) {
+				state->dev = dev;
 				state->im = im;
 				state->idev = idev;
 				break;
@@ -2507,7 +2512,7 @@ static struct ip6_sf_list *igmp6_mcf_get
 				read_unlock_bh(&state->idev->lock);
 				in6_dev_put(state->idev);
 			}
-			state->dev = state->dev->next;
+			state->dev = next_netdev(state->dev);
 			if (!state->dev) {
 				state->idev = NULL;
 				goto out;
