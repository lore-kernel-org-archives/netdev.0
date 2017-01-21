From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net v2 1/2] net: Specify the owning module for lwtunnel ops
Date: Sat, 21 Jan 2017 00:21:25 +0000
Message-ID: <1484958086-6151-2-git-send-email-rshearma@brocade.com>
References: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
 <1484958086-6151-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Lebrun <david.lebrun@uclouvain.be>,
        "Thomas Graf" <tgraf@suug.ch>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:49648 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752229AbdAUAYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:24:54 -0500
In-Reply-To: <1484958086-6151-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modules implementing lwtunnel ops should not be allowed to unload
while there is state alive using those ops, so specify the owning
module for all lwtunnel ops.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/net/lwtunnel.h    | 2 ++
 net/core/lwt_bpf.c        | 1 +
 net/ipv4/ip_tunnel_core.c | 2 ++
 net/ipv6/ila/ila_lwt.c    | 1 +
 net/ipv6/seg6_iptunnel.c  | 1 +
 net/mpls/mpls_iptunnel.c  | 1 +
 6 files changed, 8 insertions(+)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 0b585f1fd340..73dd87647460 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -44,6 +44,8 @@ struct lwtunnel_encap_ops {
 	int (*get_encap_size)(struct lwtunnel_state *lwtstate);
 	int (*cmp_encap)(struct lwtunnel_state *a, struct lwtunnel_state *b);
 	int (*xmit)(struct sk_buff *skb);
+
+	struct module *owner;
 };
 
 #ifdef CONFIG_LWTUNNEL
diff --git a/net/core/lwt_bpf.c b/net/core/lwt_bpf.c
index 71bb3e2eca08..b3eef90b2df9 100644
--- a/net/core/lwt_bpf.c
+++ b/net/core/lwt_bpf.c
@@ -386,6 +386,7 @@ static const struct lwtunnel_encap_ops bpf_encap_ops = {
 	.fill_encap	= bpf_fill_encap_info,
 	.get_encap_size = bpf_encap_nlsize,
 	.cmp_encap	= bpf_encap_cmp,
+	.owner		= THIS_MODULE,
 };
 
 static int __init bpf_lwt_init(void)
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index fed3d29f9eb3..0fd1976ab63b 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -313,6 +313,7 @@ static const struct lwtunnel_encap_ops ip_tun_lwt_ops = {
 	.fill_encap = ip_tun_fill_encap_info,
 	.get_encap_size = ip_tun_encap_nlsize,
 	.cmp_encap = ip_tun_cmp_encap,
+	.owner = THIS_MODULE,
 };
 
 static const struct nla_policy ip6_tun_policy[LWTUNNEL_IP6_MAX + 1] = {
@@ -403,6 +404,7 @@ static const struct lwtunnel_encap_ops ip6_tun_lwt_ops = {
 	.fill_encap = ip6_tun_fill_encap_info,
 	.get_encap_size = ip6_tun_encap_nlsize,
 	.cmp_encap = ip_tun_cmp_encap,
+	.owner = THIS_MODULE,
 };
 
 void __init ip_tunnel_core_init(void)
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index a7bc54ab46e2..13b5e85fe0d5 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -238,6 +238,7 @@ static const struct lwtunnel_encap_ops ila_encap_ops = {
 	.fill_encap = ila_fill_encap_info,
 	.get_encap_size = ila_encap_nlsize,
 	.cmp_encap = ila_encap_cmp,
+	.owner = THIS_MODULE,
 };
 
 int ila_lwt_init(void)
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 1d60cb132835..c46f8cbf5ab5 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -422,6 +422,7 @@ static const struct lwtunnel_encap_ops seg6_iptun_ops = {
 	.fill_encap = seg6_fill_encap_info,
 	.get_encap_size = seg6_encap_nlsize,
 	.cmp_encap = seg6_encap_cmp,
+	.owner = THIS_MODULE,
 };
 
 int __init seg6_iptunnel_init(void)
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 2f7ccd934416..1d281c1ff7c1 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -215,6 +215,7 @@ static const struct lwtunnel_encap_ops mpls_iptun_ops = {
 	.fill_encap = mpls_fill_encap_info,
 	.get_encap_size = mpls_encap_nlsize,
 	.cmp_encap = mpls_encap_cmp,
+	.owner = THIS_MODULE,
 };
 
 static int __init mpls_iptunnel_init(void)
-- 
2.1.4
