From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/12] netfilter: ipset: Fix race between dump and swap
Date: Mon,  9 Oct 2017 18:25:39 +0200
Message-ID: <1507566346-32553-6-git-send-email-pablo@netfilter.org>
References: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57810 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755205AbdJIQ0A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 12:26:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 20B1EC0B3B
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:25:59 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 121A6DA38C
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:25:59 +0200 (CEST)
In-Reply-To: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ross Lagerwall <ross.lagerwall@citrix.com>

Fix a race between ip_set_dump_start() and ip_set_swap().
The race is as follows:
* Without holding the ref lock, ip_set_swap() checks ref_netlink of the
  set and it is 0.
* ip_set_dump_start() takes a reference on the set.
* ip_set_swap() does the swap (even though it now has a non-zero
  reference count).
* ip_set_dump_start() gets the set from ip_set_list again which is now a
  different set since it has been swapped.
* ip_set_dump_start() calls __ip_set_put_netlink() and hits a BUG_ON due
  to the reference count being 0.

Fix this race by extending the critical region in which the ref lock is
held to include checking the ref counts.

The race can be reproduced with the following script:
  while :; do
    ipset destroy hash_ip1
    ipset destroy hash_ip2
    ipset create hash_ip1 hash:ip family inet hashsize 1024 \
        maxelem 500000
    ipset create hash_ip2 hash:ip family inet hashsize 300000 \
        maxelem 500000
    ipset create hash_ip3 hash:ip family inet hashsize 1024 \
        maxelem 500000
    ipset save &
    ipset swap hash_ip3 hash_ip2
    ipset destroy hash_ip3
    wait
  done

Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index a7f049ff3049..cf84f7b37cd9 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1191,14 +1191,17 @@ static int ip_set_swap(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 	      from->family == to->family))
 		return -IPSET_ERR_TYPE_MISMATCH;
 
-	if (from->ref_netlink || to->ref_netlink)
+	write_lock_bh(&ip_set_ref_lock);
+
+	if (from->ref_netlink || to->ref_netlink) {
+		write_unlock_bh(&ip_set_ref_lock);
 		return -EBUSY;
+	}
 
 	strncpy(from_name, from->name, IPSET_MAXNAMELEN);
 	strncpy(from->name, to->name, IPSET_MAXNAMELEN);
 	strncpy(to->name, from_name, IPSET_MAXNAMELEN);
 
-	write_lock_bh(&ip_set_ref_lock);
 	swap(from->ref, to->ref);
 	ip_set(inst, from_id) = to;
 	ip_set(inst, to_id) = from;
-- 
2.1.4
