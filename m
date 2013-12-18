From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] rps: NUMA flow limit allocations
Date: Wed, 18 Dec 2013 06:46:23 -0800
Message-ID: <1387377983.19078.320.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:53992 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab3LROqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:46:19 -0500
Received: by mail-pa0-f44.google.com with SMTP id fa1so6067918pad.3
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:46:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Given we allocate memory for each cpu, we can do this
using NUMA affinities, instead of using NUMA policies
of the process changing flow_limit_cpu_bitmap value.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/core/sysctl_net_core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cca444190907..cf9cd13509a7 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -122,7 +122,8 @@ static int flow_limit_cpu_sysctl(struct ctl_table *table, int write,
 				synchronize_rcu();
 				kfree(cur);
 			} else if (!cur && cpumask_test_cpu(i, mask)) {
-				cur = kzalloc(len, GFP_KERNEL);
+				cur = kzalloc_node(len, GFP_KERNEL,
+						   cpu_to_node(i));
 				if (!cur) {
 					/* not unwinding previous changes */
 					ret = -ENOMEM;
