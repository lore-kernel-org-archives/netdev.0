From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH nf-next] netfilter: xt_CHECKSUM: avoid bad offload warnings on
 GSO packets
Date: Thu, 24 Aug 2017 12:48:24 +0200 (CEST)
Message-ID: <20170824104824.2C318A0F3A@unicorn.suse.cz>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Markos Chandras <markos.chandras@suse.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When --checksum_fill action is applied to a GSO packet, checksum_tg() calls
skb_checksum_help() which is only meant to be applied to non-GSO packets so
that it issues a warning.

This can be easily triggered by using e.g.

  iptables -t mangle -A OUTPUT -j CHECKSUM --checksum-fill

and sending TCP stream via a device with GSO enabled.

While this can be considered a misconfiguration, I believe the bad offload
warning is supposed to catch bugs in drivers and networking stack, not
misconfigured firewalls. So let's ignore such packets and only issue a one
time warning with pr_warn_once() rather than a WARN with stack trace and
tainted kernel.

Reported-by: Markos Chandras <markos.chandras@suse.com>
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/netfilter/xt_CHECKSUM.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_CHECKSUM.c b/net/netfilter/xt_CHECKSUM.c
index 0f642ef8cd26..9a007153ba7f 100644
--- a/net/netfilter/xt_CHECKSUM.c
+++ b/net/netfilter/xt_CHECKSUM.c
@@ -25,8 +25,12 @@ MODULE_ALIAS("ip6t_CHECKSUM");
 static unsigned int
 checksum_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		skb_checksum_help(skb);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (unlikely(skb_is_gso(skb)))
+			pr_warn_once("cannot mangle checksum of a GSO packet\n");
+		else
+			skb_checksum_help(skb);
+	}
 
 	return XT_CONTINUE;
 }
-- 
2.14.1

