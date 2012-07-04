From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bridged networking panics
Date: Wed, 04 Jul 2012 15:24:58 +0200
Message-ID: <1341408298.2583.1963.camel@edumazet-glaptop>
References: <4FEC62DD.6000303@navynet.it>  <4FF41E1A.4070102@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Massimo Cetra <ctrix+debianbugs@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40479 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab2GDNZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 09:25:04 -0400
In-Reply-To: <4FF41E1A.4070102@navynet.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-04 at 12:42 +0200, Massimo Cetra wrote:

> Ok, waiting for an answer (sincerely i don't understand why no ones 
> cares for months) i'm attaching 3 more panics happened this morning on a 
> vanilla 3.2.21.
> 
> The problem is related to heavy network traffic.
> 
> I'm not a kernel hacker but I see that net_rx_action() is in the backtrace.
> So (probably reaching wrong conclusions) if those panics are triggered 
> by incoming network traffic, can an attacker use this to crash a machine ?
> 
> Anyone willing to reply or at least tell me what's going on ?

Posting a bug report is not enough to get people working for free on the
problem.

Apparently your configuration is kind of special if nobody but you hits
the problem so often.

So it would help if you can reproduce the bug using current kernel and
provide all necessary steps to reproduce the bug. Ideally a script.sh
file doing all the configuration you use to trigger the bug, assuming
a basic machine freshly booted with no special config already done.

The panics dont happen in the bridge code itself, but in the
BRIDGE_NETFILTER one. Do you need it, and why ?

Are you using vlans ?

Please try following patch

 net/bridge/br_netfilter.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index e41456b..a73a8cb 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -173,9 +173,13 @@ static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 static inline struct net_device *bridge_parent(const struct net_device *dev)
 {
 	struct net_bridge_port *port;
+	struct net_device *parent;
 
 	port = br_port_get_rcu(dev);
-	return port ? port->br->dev : NULL;
+	parent = port ? port->br->dev : NULL;
+	if (parent && !(parent->flags & IFF_UP))
+		parent = NULL;
+	return parent;
 }
 
 static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
@@ -510,6 +514,8 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 	struct net_device *vlan, *br;
 
 	br = bridge_parent(dev);
+	if (!br)
+		return NULL;
 	if (brnf_pass_vlan_indev == 0 || !vlan_tx_tag_present(skb))
 		return br;
 
@@ -748,7 +754,7 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 				     int (*okfn)(struct sk_buff *))
 {
 	struct nf_bridge_info *nf_bridge;
-	struct net_device *parent;
+	struct net_device *parent, *ldev;
 	u_int8_t pf;
 
 	if (!skb->nf_bridge)
@@ -789,8 +795,11 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_FORWARD, skb, brnf_get_logical_dev(skb, in), parent,
-		br_nf_forward_finish);
+	ldev = brnf_get_logical_dev(skb, in);
+	if (!ldev)
+		return NF_DROP;
+
+	NF_HOOK(pf, NF_INET_FORWARD, skb, ldev, parent, br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
@@ -861,12 +870,13 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 				       int (*okfn)(struct sk_buff *))
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
-	struct net_device *realoutdev = bridge_parent(skb->dev);
+	struct net_device *realoutdev;
 	u_int8_t pf;
 
 	if (!nf_bridge || !(nf_bridge->mask & BRNF_BRIDGED))
 		return NF_ACCEPT;
 
+	realoutdev = bridge_parent(skb->dev);
 	if (!realoutdev)
 		return NF_DROP;
 
