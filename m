From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: ctnetlink: fix incorrect nf_ct_put during hash resize
Date: Mon, 29 May 2017 13:34:32 +0200
Message-ID: <1496057672-6751-5-git-send-email-pablo@netfilter.org>
References: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53116 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750925AbdE2Lev (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 07:34:51 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D6C03303D07
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C4ABD100A40
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E1649100A7F
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 13:34:40 +0200 (CEST)
In-Reply-To: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

If nf_conntrack_htable_size was adjusted by the user during the ct
dump operation, we may invoke nf_ct_put twice for the same ct, i.e.
the "last" ct. This will cause the ct will be freed but still linked
in hash buckets.

It's very easy to reproduce the problem by the following commands:
  # while : ; do
  echo $RANDOM > /proc/sys/net/netfilter/nf_conntrack_buckets
  done
  # while : ; do
  conntrack -L
  done
  # iperf -s 127.0.0.1 &
  # iperf -c 127.0.0.1 -P 60 -t 36000

After a while, the system will hang like this:
  NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [bash:20184]
  NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [iperf:20382]
  ...

So at last if we find cb->args[1] is equal to "last", this means hash
resize happened, then we can set cb->args[1] to 0 to fix the above
issue.

Fixes: d205dc40798d ("[NETFILTER]: ctnetlink: fix deadlock in table dumping")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9799a50bc604..a8be9b72e6cd 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -890,8 +890,13 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 out:
 	local_bh_enable();
-	if (last)
+	if (last) {
+		/* nf ct hash resize happened, now clear the leftover. */
+		if ((struct nf_conn *)cb->args[1] == last)
+			cb->args[1] = 0;
+
 		nf_ct_put(last);
+	}
 
 	while (i) {
 		i--;
-- 
2.1.4
