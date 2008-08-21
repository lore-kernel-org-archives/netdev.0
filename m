From: adobriyan@gmail.com
Subject: [PATCH 02/38] netns nf: ip6table_raw in netns for real
Date: Fri, 22 Aug 2008 01:57:19 +0400
Message-ID: <20080821215719.GB31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/netfilter/ip6table_raw.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -45,25 +45,37 @@ static struct xt_table packet_raw = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6t_hook(unsigned int hook,
+ip6t_pre_routing_hook(unsigned int hook,
 	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(skb, hook, in, out, init_net.ipv6.ip6table_raw);
+	return ip6t_do_table(skb, hook, in, out,
+			     dev_net(in)->ipv6.ip6table_raw);
+}
+
+static unsigned int
+ip6t_local_out_hook(unsigned int hook,
+	 struct sk_buff *skb,
+	 const struct net_device *in,
+	 const struct net_device *out,
+	 int (*okfn)(struct sk_buff *))
+{
+	return ip6t_do_table(skb, hook, in, out,
+			     dev_net(out)->ipv6.ip6table_raw);
 }
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
-	  .hook = ip6t_hook,
+	  .hook = ip6t_pre_routing_hook,
 	  .pf = PF_INET6,
 	  .hooknum = NF_INET_PRE_ROUTING,
 	  .priority = NF_IP6_PRI_FIRST,
 	  .owner = THIS_MODULE,
 	},
 	{
-	  .hook = ip6t_hook,
+	  .hook = ip6t_local_out_hook,
 	  .pf = PF_INET6,
 	  .hooknum = NF_INET_LOCAL_OUT,
 	  .priority = NF_IP6_PRI_FIRST,

