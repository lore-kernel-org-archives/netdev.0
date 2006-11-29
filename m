From: Horms <horms@verge.net.au>
Subject: [PATCH] [IPVS] transparent proxying
Date: Wed, 29 Nov 2006 15:21:28 +0900
Message-ID: <20061129062126.GP25535@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>,
	Wensong Zhan <wensong@linux-vs.org>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	Jinhua Luo <home_king@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:45214 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S934962AbWK2G31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 01:29:27 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This seems to be a pretty clean solution to a real problem.

Ultimately I would like to see IPVS move into the forward chain.
This seems to be a nice way to explore that, without breaking
any existing setups.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

[IPVS] transparent proxying

Patch from Jinhua Luo <home_king@163.com> to allow a web cluseter using
transparent proxying. It works by simply grabing packets that have the
fwmark set and have not already been processed by ipvs (ip_vs_out) and
throwing them into ip_vs_in.

See: http://archive.linuxvirtualserver.org/html/lvs-users/2006-11/msg00261.html

Normally LVS packets are processed by ip_vs_in fron on the INPUT chain,
and packets that are processed in this way never show up on the FORWARD
chain, so they won't hit this rule.

This patch seems like a good precursor to moving LVS permanantly to
the FORWARD chain. As I'm struggling to think how it could break things.

The changes to the original patch are:

* Reformated to use tabs for indentation (instead of 4 spaces)
* Reformated to be < 80 columns wide
* Added some comments
* Rewrote description (this text)

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Jinhua Luo <home_king@163.com>

Index: linux-2.6/net/ipv4/ipvs/ip_vs_core.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_core.c	2006-11-28 15:30:00.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_core.c	2006-11-29 10:27:49.000000000 +0900
@@ -23,7 +23,9 @@
  * Changes:
  *	Paul `Rusty' Russell		properly handle non-linear skbs
  *	Harald Welte			don't use nfcache
- *
+ *	Jinhua Luo                      redirect packets with fwmark on
+ *					NF_IP_FORWARD chain to ip_vs_in(),
+ *					mainly for transparent cache cluster
  */
 
 #include <linux/module.h>
@@ -1070,6 +1072,26 @@
 	return ip_vs_in_icmp(pskb, &r, hooknum);
 }
 
+/*
+ * 	This is hooked into the NF_IP_FORWARD. It catches
+ * 	packets that have not already been handled by ipvs (out)
+ * 	and have a fwmark set. This is to allow transparent proxying
+ * 	of fwmark virtual services.
+ *
+ * 	It will not process packets that are handled by ipvs (in)
+ * 	as they never traverse the NF_IP_FORWARD.
+ */
+static unsigned int
+ip_vs_forward_with_fwmark(unsigned int hooknum, struct sk_buff **pskb,
+			  const struct net_device *in,
+			  const struct net_device *out,
+			  int (*okfn)(struct sk_buff *))
+{
+	if ((*pskb)->ipvs_property || ! (*pskb)->nfmark)
+		return NF_ACCEPT;
+
+	return ip_vs_in(hooknum, pskb, in, out, okfn);
+}
 
 /* After packet filtering, forward packet through VS/DR, VS/TUN,
    or VS/NAT(change destination), so that filtering rules can be
@@ -1082,6 +1104,16 @@
 	.priority       = 100,
 };
 
+/* Allow transparent proxying by fishing packets
+ * out of the forward chain. */
+static struct nf_hook_ops ip_vs_forward_with_fwmark_ops = {
+	.hook		= ip_vs_forward_with_fwmark,
+	.owner		= THIS_MODULE,
+	.pf		= PF_INET,
+	.hooknum	= NF_IP_FORWARD,
+	.priority	= 101,
+};
+
 /* After packet filtering, change source only for VS/NAT */
 static struct nf_hook_ops ip_vs_out_ops = {
 	.hook		= ip_vs_out,
@@ -1160,9 +1192,17 @@
 		goto cleanup_postroutingops;
 	}
 
+	ret = nf_register_hook(&ip_vs_forward_with_fwmark_ops);
+	if (ret < 0) {
+		IP_VS_ERR("can't register forward_with_fwmark hook.\n");
+		goto cleanup_forwardicmpops;
+	}
+
 	IP_VS_INFO("ipvs loaded.\n");
 	return ret;
 
+  cleanup_forwardicmpops:
+	nf_unregister_hook(&ip_vs_forward_icmp_ops);
   cleanup_postroutingops:
 	nf_unregister_hook(&ip_vs_post_routing_ops);
   cleanup_outops:
@@ -1182,6 +1222,7 @@
 
 static void __exit ip_vs_cleanup(void)
 {
+	nf_unregister_hook(&ip_vs_forward_with_fwmark_ops);
 	nf_unregister_hook(&ip_vs_forward_icmp_ops);
 	nf_unregister_hook(&ip_vs_post_routing_ops);
 	nf_unregister_hook(&ip_vs_out_ops);
