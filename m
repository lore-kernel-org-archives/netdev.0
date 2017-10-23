From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/7] ipv6: addrconf: do not block BH in /proc/net/if_inet6 handling
Date: Mon, 23 Oct 2017 16:17:50 -0700
Message-ID: <20171023231751.29530-7-edumazet@google.com>
References: <20171023231751.29530-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:43754 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdJWXSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:18:09 -0400
Received: by mail-io0-f194.google.com with SMTP id 134so21913657ioo.0
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:18:09 -0700 (PDT)
In-Reply-To: <20171023231751.29530-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Table is really RCU protected, no need to block BH

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6c1e7ffb62ff2333d63b3c7639d99649d43b32fc..9232e9537082ea44f5e0af4e4b0d052d780395fd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4097,9 +4097,9 @@ struct if6_iter_state {
 
 static struct inet6_ifaddr *if6_get_first(struct seq_file *seq, loff_t pos)
 {
-	struct inet6_ifaddr *ifa = NULL;
 	struct if6_iter_state *state = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct inet6_ifaddr *ifa = NULL;
 	int p = 0;
 
 	/* initial bucket if pos is 0 */
@@ -4109,7 +4109,7 @@ static struct inet6_ifaddr *if6_get_first(struct seq_file *seq, loff_t pos)
 	}
 
 	for (; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
-		hlist_for_each_entry_rcu_bh(ifa, &inet6_addr_lst[state->bucket],
+		hlist_for_each_entry_rcu(ifa, &inet6_addr_lst[state->bucket],
 					 addr_lst) {
 			if (!net_eq(dev_net(ifa->idev->dev), net))
 				continue;
@@ -4135,7 +4135,7 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq,
 	struct if6_iter_state *state = seq->private;
 	struct net *net = seq_file_net(seq);
 
-	hlist_for_each_entry_continue_rcu_bh(ifa, addr_lst) {
+	hlist_for_each_entry_continue_rcu(ifa, addr_lst) {
 		if (!net_eq(dev_net(ifa->idev->dev), net))
 			continue;
 		state->offset++;
@@ -4144,7 +4144,7 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq,
 
 	while (++state->bucket < IN6_ADDR_HSIZE) {
 		state->offset = 0;
-		hlist_for_each_entry_rcu_bh(ifa,
+		hlist_for_each_entry_rcu(ifa,
 				     &inet6_addr_lst[state->bucket], addr_lst) {
 			if (!net_eq(dev_net(ifa->idev->dev), net))
 				continue;
@@ -4157,9 +4157,9 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq,
 }
 
 static void *if6_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(rcu_bh)
+	__acquires(rcu)
 {
-	rcu_read_lock_bh();
+	rcu_read_lock();
 	return if6_get_first(seq, *pos);
 }
 
@@ -4173,9 +4173,9 @@ static void *if6_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void if6_seq_stop(struct seq_file *seq, void *v)
-	__releases(rcu_bh)
+	__releases(rcu)
 {
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 }
 
 static int if6_seq_show(struct seq_file *seq, void *v)
-- 
2.15.0.rc0.271.g36b669edcc-goog
