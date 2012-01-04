From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: [PATCH] ipv6/addrconf: speedup /proc/net/if_inet6 filling
Date: Wed,  4 Jan 2012 11:31:35 +0200
Message-ID: <1325669495-5626-1-git-send-email-mmaruseac@ixiacom.com>
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	mihai.maruseac@gmail.com, Mihai Maruseac <mmaruseac@ixiacom.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:65414 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694Ab2ADJby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 04:31:54 -0500
Received: by eekc4 with SMTP id c4so16516568eek.19
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 01:31:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures a linear behaviour when filling /proc/net/if_inet6 thus making
ifconfig run really fast on IPv6 only addresses. In fact, with this patch and
the IPv4 one sent a while ago, ifconfig will run in linear time regardless of
address type.

IPv4 related patch: f04565ddf52e401880f8ba51de0dff8ba51c99fd
	 dev: use name hash for dev_seq_ops
	 ...

Some statistics (running ifconfig > /dev/null on a different setup):

iface count / IPv6 no-patch time / IPv6 patched time / IPv4 time
----------------------------------------------------------------
      6250  |       0.23 s       |      0.13 s       |  0.11 s
     12500  |       0.62 s       |      0.28 s       |  0.22 s
     25000  |       2.91 s       |      0.57 s       |  0.46 s
     50000  |      11.37 s       |      1.21 s       |  0.94 s
    128000  |      86.78 s       |      3.05 s       |  2.54 s

Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/ipv6/addrconf.c |   43 ++++++++++++++++++++++++++++---------------
 1 files changed, 28 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 59a9d0e..adb972a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3078,20 +3078,39 @@ static void addrconf_dad_run(struct inet6_dev *idev)
 struct if6_iter_state {
 	struct seq_net_private p;
 	int bucket;
+	int offset;
 };
 
-static struct inet6_ifaddr *if6_get_first(struct seq_file *seq)
+static struct inet6_ifaddr *if6_get_first(struct seq_file *seq, loff_t pos)
 {
 	struct inet6_ifaddr *ifa = NULL;
 	struct if6_iter_state *state = seq->private;
 	struct net *net = seq_file_net(seq);
+	int p = 0;
 
-	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
+	/* initial bucket if pos is 0 */
+	if (pos == 0) {
+		state->bucket = 0;
+		state->offset = 0;
+	}
+
+	for (; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
 		struct hlist_node *n;
 		hlist_for_each_entry_rcu_bh(ifa, n, &inet6_addr_lst[state->bucket],
-					 addr_lst)
+					 addr_lst) {
+			/* sync with offset */
+			if (p < state->offset) {
+				p++;
+				continue;
+			}
+			state->offset++;
 			if (net_eq(dev_net(ifa->idev->dev), net))
 				return ifa;
+		}
+
+		/* prepare for next bucket */
+		state->offset = 0;
+		p = 0;
 	}
 	return NULL;
 }
@@ -3103,13 +3122,17 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq,
 	struct net *net = seq_file_net(seq);
 	struct hlist_node *n = &ifa->addr_lst;
 
-	hlist_for_each_entry_continue_rcu_bh(ifa, n, addr_lst)
+	hlist_for_each_entry_continue_rcu_bh(ifa, n, addr_lst) {
+		state->offset++;
 		if (net_eq(dev_net(ifa->idev->dev), net))
 			return ifa;
+	}
 
 	while (++state->bucket < IN6_ADDR_HSIZE) {
+		state->offset = 0;
 		hlist_for_each_entry_rcu_bh(ifa, n,
 				     &inet6_addr_lst[state->bucket], addr_lst) {
+			state->offset++;
 			if (net_eq(dev_net(ifa->idev->dev), net))
 				return ifa;
 		}
@@ -3118,21 +3141,11 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq,
 	return NULL;
 }
 
-static struct inet6_ifaddr *if6_get_idx(struct seq_file *seq, loff_t pos)
-{
-	struct inet6_ifaddr *ifa = if6_get_first(seq);
-
-	if (ifa)
-		while (pos && (ifa = if6_get_next(seq, ifa)) != NULL)
-			--pos;
-	return pos ? NULL : ifa;
-}
-
 static void *if6_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(rcu_bh)
 {
 	rcu_read_lock_bh();
-	return if6_get_idx(seq, *pos);
+	return if6_get_first(seq, *pos);
 }
 
 static void *if6_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-- 
1.7.4.1
