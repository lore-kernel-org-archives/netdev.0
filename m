From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/2] ipv4: provide addr and netconf dump consistency info
Date: Fri, 22 Mar 2013 15:42:39 +0100
Message-ID: <1363963360-3603-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, junwei.zhang@6wind.com, hongjun.li@6wind.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56243 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932792Ab3CVOnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:43:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes benefit of dev_addr_genid and dev_base_seq to check if a change
occurs during a netlink dump. If a change is detected, the flag NLM_F_DUMP_INTR
is set in the first message after the dump was interrupted.

Reported-by: Junwei Zhang <junwei.zhang@6wind.com>
Reported-by: Hongjun Li <hongjun.li@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/devinet.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index af57bba..158ca5e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1499,6 +1499,8 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 		idx = 0;
 		head = &net->dev_index_head[h];
 		rcu_read_lock();
+		cb->seq = atomic_read(&net->ipv4.dev_addr_genid) ^
+			  net->dev_base_seq;
 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
@@ -1519,6 +1521,7 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 					rcu_read_unlock();
 					goto done;
 				}
+				nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 			}
 cont:
 			idx++;
@@ -1808,6 +1811,8 @@ static int inet_netconf_dump_devconf(struct sk_buff *skb,
 		idx = 0;
 		head = &net->dev_index_head[h];
 		rcu_read_lock();
+		cb->seq = atomic_read(&net->ipv4.dev_addr_genid) ^
+			  net->dev_base_seq;
 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
@@ -1825,6 +1830,7 @@ static int inet_netconf_dump_devconf(struct sk_buff *skb,
 				rcu_read_unlock();
 				goto done;
 			}
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
 		}
-- 
1.8.0.1
