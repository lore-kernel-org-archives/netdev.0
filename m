From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv4: use the right lock for ping_group_range
Date: Thu, 20 Oct 2016 14:19:46 -0700
Message-ID: <1476998386-20935-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, Eric Salo <salo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33837 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754069AbcJTVTw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 17:19:52 -0400
Received: by mail-pf0-f195.google.com with SMTP id 128so6561934pfz.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 14:19:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit a681574c99be23e4d20b769bf0e543239c364af5
("ipv4: disable BH in set_ping_group_range()") because we never
read ping_group_range in BH context (unlike local_port_range).

Then, since we already have a lock for ping_group_range, those
using ip_local_ports.lock for ping_group_range are clearly typos.

We might consider to share a same lock for both ping_group_range
and local_port_range w.r.t. space saving, but that should be for
net-next.

Fixes: a681574c99be ("ipv4: disable BH in set_ping_group_range()")
Fixes: ba6b918ab234 ("ping: move ping_group_range out of CONFIG_SYSCTL")
Cc: Eric Dumazet <edumazet@google.com>
Cc: Eric Salo <salo@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/sysctl_net_ipv4.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 500ae40..80bc36b 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -96,11 +96,11 @@ static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low
 		container_of(table->data, struct net, ipv4.ping_group_range.range);
 	unsigned int seq;
 	do {
-		seq = read_seqbegin(&net->ipv4.ip_local_ports.lock);
+		seq = read_seqbegin(&net->ipv4.ping_group_range.lock);
 
 		*low = data[0];
 		*high = data[1];
-	} while (read_seqretry(&net->ipv4.ip_local_ports.lock, seq));
+	} while (read_seqretry(&net->ipv4.ping_group_range.lock, seq));
 }
 
 /* Update system visible IP port range */
@@ -109,10 +109,10 @@ static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t hig
 	kgid_t *data = table->data;
 	struct net *net =
 		container_of(table->data, struct net, ipv4.ping_group_range.range);
-	write_seqlock_bh(&net->ipv4.ip_local_ports.lock);
+	write_seqlock(&net->ipv4.ping_group_range.lock);
 	data[0] = low;
 	data[1] = high;
-	write_sequnlock_bh(&net->ipv4.ip_local_ports.lock);
+	write_sequnlock(&net->ipv4.ping_group_range.lock);
 }
 
 /* Validate changes from /proc interface. */
-- 
2.1.0
