From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] igmp: Use next_net_device_rcu()
Date: Thu, 12 Nov 2009 04:48:52 +0100
Message-ID: <4AFB85A4.1050408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57913 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbZKLDsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:48:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to use next_det_device_rcu() in RCU protected section.

We also can avoid in_dev_get()/in_dev_put() overhead (code size mainly)
in rcu_read_lock() sections.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/igmp.c |   27 +++++++++++----------------
 1 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index bd24f65..6110c6d 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2313,7 +2313,8 @@ static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
 	state->in_dev = NULL;
 	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *in_dev;
-		in_dev = in_dev_get(state->dev);
+
+		in_dev = __in_dev_get_rcu(state->dev);
 		if (!in_dev)
 			continue;
 		read_lock(&in_dev->mc_list_lock);
@@ -2323,7 +2324,6 @@ static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
 			break;
 		}
 		read_unlock(&in_dev->mc_list_lock);
-		in_dev_put(in_dev);
 	}
 	return im;
 }
@@ -2333,16 +2333,15 @@ static struct ip_mc_list *igmp_mc_get_next(struct seq_file *seq, struct ip_mc_li
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 	im = im->next;
 	while (!im) {
-		if (likely(state->in_dev != NULL)) {
+		if (likely(state->in_dev != NULL))
 			read_unlock(&state->in_dev->mc_list_lock);
-			in_dev_put(state->in_dev);
-		}
-		state->dev = next_net_device(state->dev);
+
+		state->dev = next_net_device_rcu(state->dev);
 		if (!state->dev) {
 			state->in_dev = NULL;
 			break;
 		}
-		state->in_dev = in_dev_get(state->dev);
+		state->in_dev = __in_dev_get_rcu(state->dev);
 		if (!state->in_dev)
 			continue;
 		read_lock(&state->in_dev->mc_list_lock);
@@ -2384,7 +2383,6 @@ static void igmp_mc_seq_stop(struct seq_file *seq, void *v)
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 	if (likely(state->in_dev != NULL)) {
 		read_unlock(&state->in_dev->mc_list_lock);
-		in_dev_put(state->in_dev);
 		state->in_dev = NULL;
 	}
 	state->dev = NULL;
@@ -2464,7 +2462,7 @@ static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 	state->im = NULL;
 	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *idev;
-		idev = in_dev_get(state->dev);
+		idev = __in_dev_get_rcu(state->dev);
 		if (unlikely(idev == NULL))
 			continue;
 		read_lock(&idev->mc_list_lock);
@@ -2480,7 +2478,6 @@ static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 			spin_unlock_bh(&im->lock);
 		}
 		read_unlock(&idev->mc_list_lock);
-		in_dev_put(idev);
 	}
 	return psf;
 }
@@ -2494,16 +2491,15 @@ static struct ip_sf_list *igmp_mcf_get_next(struct seq_file *seq, struct ip_sf_l
 		spin_unlock_bh(&state->im->lock);
 		state->im = state->im->next;
 		while (!state->im) {
-			if (likely(state->idev != NULL)) {
+			if (likely(state->idev != NULL))
 				read_unlock(&state->idev->mc_list_lock);
-				in_dev_put(state->idev);
-			}
-			state->dev = next_net_device(state->dev);
+
+			state->dev = next_net_device_rcu(state->dev);
 			if (!state->dev) {
 				state->idev = NULL;
 				goto out;
 			}
-			state->idev = in_dev_get(state->dev);
+			state->idev = __in_dev_get_rcu(state->dev);
 			if (!state->idev)
 				continue;
 			read_lock(&state->idev->mc_list_lock);
@@ -2555,7 +2551,6 @@ static void igmp_mcf_seq_stop(struct seq_file *seq, void *v)
 	}
 	if (likely(state->idev != NULL)) {
 		read_unlock(&state->idev->mc_list_lock);
-		in_dev_put(state->idev);
 		state->idev = NULL;
 	}
 	state->dev = NULL;
