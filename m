From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] netfilter: remove forward module param confusion.
Date: Fri, 23 Mar 2012 08:57:06 +1030
Message-ID: <8739909sqt.fsf@rustcorp.com.au>
References: <20120322182623.GA29859@elgon.mountain> <8762dw9to2.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <8762dw9to2.fsf@rustcorp.com.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It used to be an int, and it got changed to a bool parameter at least
7 years ago.  It happens that NF_ACCEPT and NF_DROP are 0 and 1, so
this works, but it's unclear, and the check that it's in range is not
required.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 net/ipv4/netfilter/iptable_filter.c  |    9 ++-------
 net/ipv6/netfilter/ip6table_filter.c |    9 ++-------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -52,7 +52,7 @@ iptable_filter_hook(unsigned int hook, s
 static struct nf_hook_ops *filter_ops __read_mostly;
 
 /* Default to forward because I got too much mail already. */
-static bool forward = NF_ACCEPT;
+static bool forward = true;
 module_param(forward, bool, 0000);
 
 static int __net_init iptable_filter_net_init(struct net *net)
@@ -64,7 +64,7 @@ static int __net_init iptable_filter_net
 		return -ENOMEM;
 	/* Entry 1 is the FORWARD hook */
 	((struct ipt_standard *)repl->entries)[1].target.verdict =
-		-forward - 1;
+		forward ? -NF_ACCEPT - 1 : -NF_DROP - 1;
 
 	net->ipv4.iptable_filter =
 		ipt_register_table(net, &packet_filter, repl);
@@ -88,11 +88,6 @@ static int __init iptable_filter_init(vo
 {
 	int ret;
 
-	if (forward < 0 || forward > NF_MAX_VERDICT) {
-		pr_err("iptables forward must be 0 or 1\n");
-		return -EINVAL;
-	}
-
 	ret = register_pernet_subsys(&iptable_filter_net_ops);
 	if (ret < 0)
 		return ret;
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -44,7 +44,7 @@ ip6table_filter_hook(unsigned int hook, 
 static struct nf_hook_ops *filter_ops __read_mostly;
 
 /* Default to forward because I got too much mail already. */
-static bool forward = NF_ACCEPT;
+static bool forward = true;
 module_param(forward, bool, 0000);
 
 static int __net_init ip6table_filter_net_init(struct net *net)
@@ -56,7 +56,7 @@ static int __net_init ip6table_filter_ne
 		return -ENOMEM;
 	/* Entry 1 is the FORWARD hook */
 	((struct ip6t_standard *)repl->entries)[1].target.verdict =
-		-forward - 1;
+		forward ? -NF_ACCEPT - 1 : -NF_DROP - 1;
 
 	net->ipv6.ip6table_filter =
 		ip6t_register_table(net, &packet_filter, repl);
@@ -80,11 +80,6 @@ static int __init ip6table_filter_init(v
 {
 	int ret;
 
-	if (forward < 0 || forward > NF_MAX_VERDICT) {
-		pr_err("iptables forward must be 0 or 1\n");
-		return -EINVAL;
-	}
-
 	ret = register_pernet_subsys(&ip6table_filter_net_ops);
 	if (ret < 0)
 		return ret;
-- 
  How could I marry someone with more hair than me?  http://baldalex.org
