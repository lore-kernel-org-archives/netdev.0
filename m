From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: ipt_CLUSTERIP: dont flood with "no conntrack!"
Date: Thu, 13 Jan 2011 12:13:29 +0100
Message-ID: <1294917210.3570.48.camel@edumazet-laptop>
References: <4D2E1A74.5080102@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D2E1A74.5080102@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipt_CLUSTERIP users might hit this annoying printk, if they forgot an
"iptables -I INPUT -m state --state INVALID -j DROP" before CLUSTERIP
rule. We could use net_ratelimit() here, or not log the message at all.
I chose to log it once per config.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 1e26a48..bac8739 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -47,6 +47,7 @@ struct clusterip_config {
 	u_int8_t clustermac[ETH_ALEN];		/* the MAC address */
 	struct net_device *dev;			/* device */
 	u_int16_t num_total_nodes;		/* total number of nodes */
+	bool warned_no_conntrack;
 	unsigned long local_nodes;		/* node number array */
 
 #ifdef CONFIG_PROC_FS
@@ -301,10 +302,14 @@ clusterip_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct == NULL) {
-		pr_info("no conntrack!\n");
-			/* FIXME: need to drop invalid ones, since replies
-			 * to outgoing connections of other nodes will be
-			 * marked as INVALID */
+		if (unlikely(!cipinfo->config->warned_no_conntrack)) {
+			cipinfo->config->warned_no_conntrack = true;
+			pr_info("no conntrack!\n");
+		}
+		/* FIXME: need to drop invalid ones, since replies
+		 * to outgoing connections of other nodes will be
+		 * marked as INVALID
+		 */
 		return NF_DROP;
 	}
 


