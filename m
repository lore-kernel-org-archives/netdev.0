From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: shy netns_ok check
Date: Wed, 12 Nov 2008 03:15:09 +0300
Message-ID: <20081112001509.GA2749@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:39354 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbYKLALo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 19:11:44 -0500
Received: by ug-out-1314.google.com with SMTP id 39so905722ugf.37
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 16:11:42 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sigh...

Failure to pass netns_ok check is SILENT, except some MIB counted is
incremented somewhere.

And adding "netns_ok = 1" (after long head-scratching session) is usually
the last step in making some protocol netns-ready...

Please, apply.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/ip_input.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -209,9 +209,17 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 
 		hash = protocol & (MAX_INET_PROTOS - 1);
 		ipprot = rcu_dereference(inet_protos[hash]);
-		if (ipprot != NULL && (net == &init_net || ipprot->netns_ok)) {
+		if (ipprot != NULL) {
 			int ret;
 
+			if (!net_eq(net, &init_net) && !ipprot->netns_ok) {
+				if (net_ratelimit())
+					printk("%s: proto %d isn't netns-ready\n",
+						__func__, protocol);
+				kfree_skb(skb);
+				goto out;
+			}
+
 			if (!ipprot->no_policy) {
 				if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 					kfree_skb(skb);
