From: Florian Westphal <fw@strlen.de>
Subject: Re: BUG: unable to handle kernel paging request at
 0000000000609920 in networking code on 3.2.23.
Date: Fri, 25 Jan 2013 00:08:50 +0100
Message-ID: <20130124230850.GI8541@breakpoint.cc>
References: <A60E26F6-16DC-4A29-BFDE-1B17DC51F64F@telemetry.com>
 <loom.20130124T115328-292@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Rafal Kupka <rkupka@telemetry.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <loom.20130124T115328-292@post.gmane.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafal Kupka <rkupka@telemetry.com> wrote:

[ cc nf-devel ]

> > After upgrade to 3.2.23 (debian backports 2.6.32-45 package) from 2.6.32 I
> experience server crash.
> New round of tests on 3.2.35-2~bpo60+1. Still similar crashes.
> 
> > Iptables:
> > 
> > Chain INPUT (policy ACCEPT)
> > target     prot opt source               destination
> > dumbtcp    tcp  --  0.0.0.0/0            91.217.135.0/24
> > 
> > Chain OUTPUT (policy ACCEPT)
> > target     prot opt source               destination
> > dumbtcp    tcp  --  91.217.135.0/24      0.0.0.0/0
> > 
> > Chain dumbtcp (2 references)
> > target     prot opt source               destination
> > TCPOPTSTRIP  tcp  --  0.0.0.0/0            0.0.0.0/0            tcpflags:
> 0x02/0x02 TCPOPTSTRIP options 3,4,5,8,19
> > ECN        tcp  --  0.0.0.0/0            0.0.0.0/0            ECN TCP remove
> 
> This Netfilter rules are causing it. Either ECN or TCPOPTSTRIP module.

I don't see any relevant changes in either TCPOPTSTRIP or ECN.

> 3.2.35 calltrace:
> [15368.854247] Call Trace:
> [15368.856749]  <IRQ> 
> [15368.858898]  [<ffffffff812a02a8>] ? skb_release_data+0x6c/0xe4
> [15368.864791]  [<ffffffff812a08b0>] ? __kfree_skb+0x11/0x73
> [15368.870254]  [<ffffffff812e5c5f>] ? tcp_rcv_state_process+0x74/0x8d9
> [15368.876632]  [<ffffffff812ed0b7>] ? tcp_v4_do_rcv+0x388/0x3eb
> [15368.882448]  [<ffffffff812ee54e>] ? tcp_v4_rcv+0x447/0x6ed
> [15368.888007]  [<ffffffff812cb746>] ? nf_hook_slow+0x68/0xfd
> [15368.893572]  [<ffffffff812d197e>] ? T.1004+0x4f/0x4f
> [15368.898614]  [<ffffffff812d1abb>] ? ip_local_deliver_finish+0x13d/0x1aa
> [15368.905301]  [<ffffffff812aab66>] ? __netif_receive_skb+0x47d/0x4b0
> [15368.911642]  [<ffffffff81013a01>] ? read_tsc+0x5/0x16
> [15368.916768]  [<ffffffff812aadc7>] ? netif_receive_skb+0x67/0x6d
> [15368.922757]  [<ffffffff812ab335>] ? napi_gro_receive+0x1f/0x2c
> [15368.928661]  [<ffffffff812aaea1>] ? napi_skb_finish+0x1c/0x31
> [15368.934495]  [<ffffffffa0049a61>] ? e1000_clean_rx_irq+0x1ea/0x29a [e1000e]
> [15368.941533]  [<ffffffffa0049fa2>] ? e1000_clean+0x71/0x229 [e1000e]
> [15368.947875]  [<ffffffff8103b982>] ? __wake_up+0x35/0x46
> [15368.953171]  [<ffffffff812ab460>] ? net_rx_action+0xa8/0x207
> [15368.958908]  [<ffffffff81046351>] ? finish_task_switch+0x50/0xc7
> [15368.964995]  [<ffffffff8104f2ca>] ? __do_softirq+0xc4/0x1a0
> [15368.970636]  [<ffffffff81097ec6>] ? handle_irq_event_percpu+0x163/0x181
> [15368.977324]  [<ffffffff8136f8ac>] ? call_softirq+0x1c/0x30
> [15368.982884]  [<ffffffff8100fa3f>] ? do_softirq+0x3f/0x79
> [15368.988266]  [<ffffffff8104f09a>] ? irq_exit+0x44/0xb5
> [15368.993473]  [<ffffffff8100f38a>] ? do_IRQ+0x94/0xaa
> [15368.998489]  [<ffffffff8136836e>] ? common_interrupt+0x6e/0x6e
> [15369.004397]  <EOI> 
> [15369.006537]  [<ffffffff81107e38>] ? fput+0x17a/0x1a2
> [15369.011576]  [<ffffffff81046351>] ? finish_task_switch+0x50/0xc7
> [15369.017653]  [<ffffffff81366b46>] ? __schedule+0x57a/0x5cd
> [15369.023209]  [<ffffffff81368416>] ? retint_careful+0x14/0x32

However, it does seem to me as if both are missing a few sanity checks.
Especially TCPOPSTRIP can read/write beyond end-of-packet when
tcph->doff is bogus?

Something like this (not even compile tested):

diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 4bf3dc4..a1f8a59 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -86,7 +86,7 @@ ecn_tg(struct sk_buff *skb, const struct xt_action_param *par)
 			return NF_DROP;
 
 	if (einfo->operation & (IPT_ECN_OP_SET_ECE | IPT_ECN_OP_SET_CWR) &&
-	    ip_hdr(skb)->protocol == IPPROTO_TCP)
+	   (ip_hdr(skb)->frag_off & htons(IP_OFFSET)) == 0)
 		if (!set_ect_tcp(skb, einfo))
 			return NF_DROP;
 
diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTSTRIP.c
index 25fd1c4..ebb9451 100644
--- a/net/netfilter/xt_TCPOPTSTRIP.c
+++ b/net/netfilter/xt_TCPOPTSTRIP.c
@@ -35,10 +35,18 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
 {
 	unsigned int optl, i, j;
 	struct tcphdr *tcph;
+	struct tcphdr _tcph;
 	u_int16_t n, o;
 	u_int8_t *opt;
 
-	if (!skb_make_writable(skb, skb->len))
+	if (skb->len < minlen)
+		return XT_CONTINUE;
+
+	tcph = skb_header_pointer(skb, tcphoff, sizeof(_tcph), &_tcph);
+	if (!tcph)
+		return XT_CONTINUE; /* no options -> nothing to do */
+
+	if (!skb_make_writable(skb, tcphoff + (tcph->doff * 4)))
 		return NF_DROP;
 
 	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
@@ -76,6 +84,9 @@ tcpoptstrip_mangle_packet(struct sk_buff *skb,
 static unsigned int
 tcpoptstrip_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
+	if (ip_hdr(skb)->frag_off & htons(IP_OFFSET))
+		return XT_CONTINUE;
+
 	return tcpoptstrip_mangle_packet(skb, par->targinfo, ip_hdrlen(skb),
 	       sizeof(struct iphdr) + sizeof(struct tcphdr));
 }

