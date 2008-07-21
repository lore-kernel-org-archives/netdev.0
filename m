From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] arptables in netns for real
Date: Mon, 21 Jul 2008 20:29:20 +0400
Message-ID: <20080721162920.GD13264@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IN, FORWARD -- grab netns from in device,
OUT -- from out device.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter/arptable_filter.c |   39 ++++++++++++++++++++++++++---------
 1 file changed, 30 insertions(+), 9 deletions(-)

--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -55,32 +55,53 @@ static struct xt_table packet_filter = {
 };
 
 /* The work comes in here from netfilter.c */
-static unsigned int arpt_hook(unsigned int hook,
-			      struct sk_buff *skb,
-			      const struct net_device *in,
-			      const struct net_device *out,
-			      int (*okfn)(struct sk_buff *))
+static unsigned int arpt_in_hook(unsigned int hook,
+				 struct sk_buff *skb,
+				 const struct net_device *in,
+				 const struct net_device *out,
+				 int (*okfn)(struct sk_buff *))
 {
-	return arpt_do_table(skb, hook, in, out, init_net.ipv4.arptable_filter);
+	return arpt_do_table(skb, hook, in, out,
+			     dev_net(in)->ipv4.arptable_filter);
+}
+
+static unsigned int arpt_out_hook(unsigned int hook,
+				  struct sk_buff *skb,
+				  const struct net_device *in,
+				  const struct net_device *out,
+				  int (*okfn)(struct sk_buff *))
+{
+	return arpt_do_table(skb, hook, in, out,
+			     dev_net(out)->ipv4.arptable_filter);
+}
+
+static unsigned int arpt_forward_hook(unsigned int hook,
+				      struct sk_buff *skb,
+				      const struct net_device *in,
+				      const struct net_device *out,
+				      int (*okfn)(struct sk_buff *))
+{
+	return arpt_do_table(skb, hook, in, out,
+			     dev_net(in)->ipv4.arptable_filter);
 }
 
 static struct nf_hook_ops arpt_ops[] __read_mostly = {
 	{
-		.hook		= arpt_hook,
+		.hook		= arpt_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NF_ARP,
 		.hooknum	= NF_ARP_IN,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
-		.hook		= arpt_hook,
+		.hook		= arpt_out_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NF_ARP,
 		.hooknum	= NF_ARP_OUT,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
-		.hook		= arpt_hook,
+		.hook		= arpt_forward_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NF_ARP,
 		.hooknum	= NF_ARP_FORWARD,
-- 
1.5.4.5


