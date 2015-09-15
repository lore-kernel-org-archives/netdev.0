From: Florian Westphal <fw@strlen.de>
Subject: Re: IPv6 routing/fragmentation panic
Date: Wed, 16 Sep 2015 01:48:48 +0200
Message-ID: <20150915234848.GO24810@breakpoint.cc>
References: <1442332400.131189.21.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:37129 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751415AbbIOXsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 19:48:50 -0400
Content-Disposition: inline
In-Reply-To: <1442332400.131189.21.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> wrote:
> I can repeatably crash my router with 'ping6 -s 2000' to an external
> machine:
> [   61.741618] skbuff: skb_under_panic: text:c1277f1e len:1294 put:14 head:dec98000 data:dec97ffc tail:0xdec9850a end:0xdec98f40 dev:br-lan
> [   61.754128] ------------[ cut here ]------------
> [   61.758754] Kernel BUG at c1201b1f [verbose debug info unavailable]
> [   61.764005] invalid opcode: 0000 [#1] 
> [   61.764005] Modules linked in: sch_teql 8139cp mii iptable_nat pppoe nf_nat_ipv4 nf_conntrack_ipv6 nf_conntrack_ipv4 ipt_REJECT ipt_MASQUERADE xt_time xt_tcpudp xt_state xt_nat xt_multiport xt_mark xt_mac xt_limit xt_conntrack xt_comment xt_TCPMSS xt_REDIRECT xt_LOG xt_CT solos_pci pppox ppp_async nf_reject_ipv4 nf_nat_redirect nf_nat_masquerade_ipv4 nf_nat_ftp nf_nat nf_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack iptable_raw iptable_mangle iptable_filter ip_tables crc_ccitt act_skbedit act_mirred em_u32 cls_u32 cls_tcindex cls_flow cls_route cls_fw sch_hfsc sch_ingress ledtrig_heartbeat ledtrig_gpio ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 nf_log_common ip6table_raw ip6table_mangle ip6table_filter ip6_tables x_tables pppoatm ppp_generic slhc br2684 atm geode_ae
 s cbc arc4 aes_i586
> [   61.764005] CPU: 0 PID: 0 Comm: swapper Not tainted 4.2.0+ #2
> [   61.764005] task: c138d540 ti: c1386000 task.ti: c1386000
> [   61.764005] EIP: 0060:[<c1201b1f>] EFLAGS: 00210286 CPU: 0
> [   61.764005] EIP is at skb_panic+0x3b/0x3d
> [   61.764005] EAX: 0000007c EBX: deca3000 ECX: c13a0910 EDX: c139f3c4
> [   61.764005] ESI: dee85d8c EDI: dec9800a EBP: defe3b40 ESP: dec0bd50
> [   61.764005]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> [   61.764005] CR0: 8005003b CR2: b7704474 CR3: 1ef0d000 CR4: 00000090
> [   61.764005] Stack:
> [   61.764005]  c135e48c c12e1580 c1277f1e 0000050e 0000000e dec98000 dec97ffc dec9850a
> [   61.764005]  dec98f40 deca3000 dee85d00 c120337b c12e1580 c1277f1e 00000000 0000000e
> [   61.764005]  dee85d7c ff671e02 deca3000 c109afd3 00200282 00001d91 00000028 dec98012
> [   61.764005] Call Trace:
> [   61.764005]  [<c1277f1e>] ? ip6_finish_output2+0x196/0x4da

Hmm, unlike ip the ip6 stack doesn't check headroom size before adding hh.

> But should the kernel *panic* without it? If there are requirements on
> the headroom I must leave on received packets, where are they
> documented? Or is this a bug in the IPv6 fragmentation code, to make
> such assumptions?

I'm not sure the ipv6 (re)fragmentation code is to blame here.
In particular, we could have setups where additional headers need to be
inserted which could also require headroom expansion.

> I'm not entirely sure how to interpret the above stack trace. Is the
> incoming IPv6 packet being reassembled for netfilter's benefit, then re
> -fragmented for transmission?

Yes, ipv6 connection tracking depends on defragmentation.

ip6_fragment should use the frag_list of the (reassembled) skb so no
refragmentation should be happening, we should just be re-using the
original fragmented skbs from that fraglist.

What I don't understand is why you see this with fragmented ipv6 packets only
(and not with all ipv6 forwarded skbs).

Something like this copy-pastry from ip_finish_output2 should fix it:

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -62,6 +62,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 	struct net_device *dev = dst->dev;
 	struct neighbour *neigh;
 	struct in6_addr *nexthop;
+	unsigned int hh_len;
 	int ret;
 
 	skb->protocol = htons(ETH_P_IPV6);
@@ -104,6 +105,21 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
+	hh_len = LL_RESERVED_SPACE(dev);
+	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
+		struct sk_buff *skb2;
+
+		skb2 = skb_realloc_headroom(skb, hh_len);
+		if (!skb2) {
+			kfree_skb(skb);
+			return -ENOMEM;
+		}
+		if (skb->sk)
+			skb_set_owner_w(skb2, skb->sk);
+		consume_skb(skb);
+		skb = skb2;
+	}
+
 	rcu_read_lock_bh();
 	nexthop = rt6_nexthop((struct rt6_info *)dst, &ipv6_hdr(skb)->daddr);
 	neigh = __ipv6_neigh_lookup_noref(dst->dev, nexthop);
