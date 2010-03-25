From: kaber@trash.net
Subject: [PATCH 3/4] netfilter: ip6table_raw: fix table priority
Date: Thu, 25 Mar 2010 18:54:45 +0100
Message-ID: <1269539686-3885-4-git-send-email-kaber@trash.net>
References: <1269539686-3885-1-git-send-email-kaber@trash.net>
 <1269539686-3885-2-git-send-email-kaber@trash.net>
 <1269539686-3885-3-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56924 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab0CYRyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 13:54:51 -0400
In-Reply-To: <1269539686-3885-3-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The order of the IPv6 raw table is currently reversed, that makes impossible
to use the NOTRACK target in IPv6: for example if someone enters

ip6tables -t raw -A PREROUTING -p tcp --dport 80 -j NOTRACK

and if we receive fragmented packets then the first fragment will be
untracked and thus skip nf_ct_frag6_gather (and conntrack), while all
subsequent fragments enter nf_ct_frag6_gather and reassembly will never
successfully be finished.

Singed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_ipv6.h    |    1 +
 net/ipv6/netfilter/ip6table_raw.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index d654873..1f7e300 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -59,6 +59,7 @@
 enum nf_ip6_hook_priorities {
 	NF_IP6_PRI_FIRST = INT_MIN,
 	NF_IP6_PRI_CONNTRACK_DEFRAG = -400,
+	NF_IP6_PRI_RAW = -300,
 	NF_IP6_PRI_SELINUX_FIRST = -225,
 	NF_IP6_PRI_CONNTRACK = -200,
 	NF_IP6_PRI_MANGLE = -150,
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index aef31a2..b9cf7cd 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -13,7 +13,7 @@ static const struct xt_table packet_raw = {
 	.valid_hooks = RAW_VALID_HOOKS,
 	.me = THIS_MODULE,
 	.af = NFPROTO_IPV6,
-	.priority = NF_IP6_PRI_FIRST,
+	.priority = NF_IP6_PRI_RAW,
 };
 
 /* The work comes in here from netfilter.c. */
-- 
1.6.5.7

