From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/2 nf-next] net: bridge: deprecate call_iptables=1 default
Date: Tue, 16 Sep 2014 17:47:37 +0200
Message-ID: <1410882457-16641-2-git-send-email-fw@strlen.de>
References: <1410882457-16641-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:58282 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753702AbaIPPrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 11:47:43 -0400
In-Reply-To: <1410882457-16641-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add a warning and tell users to set call_iptables to 0 or 1
depending on desired behaviour before adding ports to the bridge.

Might allow changing default to 0 in the future.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_netfilter.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index c6715a2..0b19a81 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -58,9 +58,9 @@ static int brnf_filter_vlan_tagged __read_mostly = 0;
 static int brnf_filter_pppoe_tagged __read_mostly = 0;
 static int brnf_pass_vlan_indev __read_mostly = 0;
 
-int brnf_call_iptables __read_mostly = 1;
-int brnf_call_ip6tables __read_mostly = 1;
-int brnf_call_arptables __read_mostly = 1;
+int brnf_call_iptables __read_mostly = 2;
+int brnf_call_ip6tables __read_mostly = 2;
+int brnf_call_arptables __read_mostly = 2;
 #else
 #define brnf_filter_vlan_tagged 0
 #define brnf_filter_pppoe_tagged 0
@@ -1065,9 +1065,16 @@ static struct ctl_table brnf_table[] = {
 static void __br_register_hooks_init(struct work_struct *w)
 {
 	int ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
-	if (ret == 0)
+	if (ret == 0) {
 		static_key_slow_inc(&brnf_hooks_active);
 
+		if ((brnf_call_iptables|brnf_call_ip6tables|brnf_call_arptables) == 2)
+			pr_info("bridge: automatic filtering via arp/ip/ip6tables "
+				"is deprecated and it will "
+				"be disabled soon. "
+				"Set bridge-nf-call-{ip,ip6,arp}tables sysctls to 1 or 0 "
+				"before adding bridge ports instead.\n");
+	}
 	mutex_unlock(&brnf_hook_mutex);
 	kfree(w);
 
-- 
1.8.1.5
