From: Jann Horn <jann@thejh.net>
Subject: [PATCH] netfilter: don't permit unprivileged writes to global state via sysctls
Date: Sat, 24 Sep 2016 00:21:04 +0200
Message-ID: <1474669264-3283-1-git-send-email-jann@thejh.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thejh.net ([37.221.195.125]:48332 "EHLO thejh.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759816AbcIWWVI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 18:21:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This prevents the modification of nf_conntrack_max in unprivileged network
namespaces. For unprivileged network namespaces, ip_conntrack_max is kept
as a readonly sysctl in order to minimize potential compatibility issues.

This patch should apply cleanly to the net tree.

Signed-off-by: Jann Horn <jann@thejh.net>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index ae1a71a..a639e94 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -358,6 +358,9 @@ static int ipv4_init_net(struct net *net)
 	if (!in->ctl_table)
 		return -ENOMEM;
 
+	if (net->user_ns != &init_user_ns)
+		in->ctl_table[0].mode = 0444;
+
 	in->ctl_table[0].data = &nf_conntrack_max;
 	in->ctl_table[1].data = &net->ct.count;
 	in->ctl_table[2].data = &nf_conntrack_htable_size;
-- 
2.1.4
