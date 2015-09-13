From: Florian Westphal <fw@strlen.de>
Subject: Re: Netfilter: BUG: unable to handle kernel paging request, RIP:
 physdev_mt+0xd6/0x160
Date: Sun, 13 Sep 2015 20:06:20 +0200
Message-ID: <20150913180620.GK24810@breakpoint.cc>
References: <1620a50057d1e8aadafe27c74ee42d93@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59556 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752758AbbIMSGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2015 14:06:24 -0400
Content-Disposition: inline
In-Reply-To: <1620a50057d1e8aadafe27c74ee42d93@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sander Eikelenboom <linux@eikelenboom.it> wrote:
> Using a linux-4.3-rc1 kernel i encountered the splat below:

Thanks for reporting this bug.

> [  290.200642] BUG: unable to handle kernel paging request at
> 000000000484195d
> [  290.211702] IP: [<ffffffff819bc3e6>] physdev_mt+0xd6/0x160
[..]

> [  290.444088]  [<ffffffff81a4e6c0>] ipt_do_table+0x210/0x390
> [  290.461951]  [<ffffffff81a510ae>] iptable_filter_hook+0x2e/0x70
> [  290.470756]  [<ffffffff8199279c>] nf_iterate+0x4c/0x80
> [  290.479587]  [<ffffffff81992834>] nf_hook_slow+0x64/0xc0
> [  290.488341]  [<ffffffff81a06779>] ip_forward+0x369/0x3c0
> [  290.496927]  [<ffffffff81a06380>] ? ip_frag_mem+0x40/0x40
> [  290.505365]  [<ffffffff81a04961>] ip_rcv_finish+0x101/0x330
> [  290.513480]  [<ffffffff81a05001>] ip_rcv+0x291/0x390
> [  290.521562]  [<ffffffff81a04860>] ?

Aye, ip forwarding of bridged packets with call-iptables=1 is broken.

Please, could you try this patch?  It fixes this bug for me.

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -355,6 +355,7 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 	struct iphdr *iph = ip_hdr(skb);
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
+	bool daddr_changed;
 	int err;
 
 	nf_bridge->frag_max_size = IPCB(skb)->frag_max_size;
@@ -363,8 +364,15 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
 	}
+
+	/* set physoutdev to NULL, its set by the bridge forward hook but
+	 * frame might be routed instead of bridged.
+	 */
+	daddr_changed = br_nf_ipv4_daddr_was_changed(skb, nf_bridge);
+	nf_bridge->physoutdev = NULL;
 	nf_bridge->in_prerouting = 0;
-	if (br_nf_ipv4_daddr_was_changed(skb, nf_bridge)) {
+
+	if (daddr_changed) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
 			struct in_device *in_dev = __in_dev_get_rcu(dev);
 
diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index 77383bf..772222b 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -167,6 +167,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 	struct rtable *rt;
 	struct net_device *dev = skb->dev;
 	const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
+	bool daddr_changed;
 
 	nf_bridge->frag_max_size = IP6CB(skb)->frag_max_size;
 
@@ -174,8 +175,12 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
 	}
+
+	daddr_changed = br_nf_ipv6_daddr_was_changed(skb, nf_bridge);
+	nf_bridge->physoutdev = NULL;
 	nf_bridge->in_prerouting = 0;
-	if (br_nf_ipv6_daddr_was_changed(skb, nf_bridge)) {
+
+	if (daddr_changed) {
 		skb_dst_drop(skb);
 		v6ops->route_input(skb);
 
