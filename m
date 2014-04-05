From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/8] netfilter: x_tables: allow to use cgroup match for LOCAL_IN nf hooks
Date: Sat,  5 Apr 2014 18:03:45 +0200
Message-ID: <1396713830-4009-4-git-send-email-pablo@netfilter.org>
References: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34332 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbaDEQEC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2014 12:04:02 -0400
In-Reply-To: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Perevalov <a.perevalov@samsung.com>

This simple modification allows iptables to work with INPUT chain
in combination with cgroup module. It could be useful for counting
ingress traffic per cgroup with nfacct netfilter module. There
were no problems to count the egress traffic that way formerly.

It's possible to get classified sk_buff after PREROUTING, due to
socket lookup being done in early_demux (tcp_v4_early_demux). Also
it works for udp as well.

Trivial usage example, assuming we're in the same shell every step
and we have enough permissions:

1) Classic net_cls cgroup initialization:

  mkdir /sys/fs/cgroup/net_cls
  mount -t cgroup -o net_cls net_cls /sys/fs/cgroup/net_cls

2) Set up cgroup for interesting application:

  mkdir /sys/fs/cgroup/net_cls/wget
  echo 1 > /sys/fs/cgroup/net_cls/wget/net_cls.classid
  echo $BASHPID > /sys/fs/cgroup/net_cls/wget/cgroup.procs

3) Create kernel counters:

  nfacct add wget-cgroup-in
  iptables -A INPUT -m cgroup ! --cgroup 1 -m nfacct --nfacct-name wget-cgroup-in

  nfacct add wget-cgroup-out
  iptables -A OUTPUT -m cgroup ! --cgroup 1 -m nfacct --nfacct-name wget-cgroup-out

4) Network usage:

  wget https://www.kernel.org/pub/linux/kernel/v3.x/testing/linux-3.14-rc6.tar.xz

5) Check results:

  nfacct list

Cgroup approach is being used for the DataUsage (counting & blocking
traffic) feature for Samsung's modification of the Tizen OS.

Signed-off-by: Alexey Perevalov <a.perevalov@samsung.com>
Acked-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_cgroup.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
index 9a8e77e7..f4e8330 100644
--- a/net/netfilter/xt_cgroup.c
+++ b/net/netfilter/xt_cgroup.c
@@ -54,7 +54,8 @@ static struct xt_match cgroup_mt_reg __read_mostly = {
 	.matchsize  = sizeof(struct xt_cgroup_info),
 	.me         = THIS_MODULE,
 	.hooks      = (1 << NF_INET_LOCAL_OUT) |
-		      (1 << NF_INET_POST_ROUTING),
+		      (1 << NF_INET_POST_ROUTING) |
+		      (1 << NF_INET_LOCAL_IN),
 };
 
 static int __init cgroup_mt_init(void)
-- 
1.7.10.4
