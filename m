From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH RFC] netfilter: iptables target SYNPROXY
Date: Tue, 25 May 2010 12:36:49 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005251207450.1725@obet.zrqbmnf.qr>
References: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2010-05-25 09:06, Changli Gao wrote:
> net/ipv4/netfilter/Kconfig                  |   12 
> net/ipv4/netfilter/Makefile                 |    1 
> net/ipv4/netfilter/ipt_SYNPROXY.c           |  658 ++++++++++++++++++++++++++++
> net/ipv4/syncookies.c                       |   21 
> net/ipv4/tcp_ipv4.c                         |    5 
> net/netfilter/nf_conntrack_core.c           |   44 +

Please make this an Xtables extension.
There is excellent documentation ("Writing Netfilter Modules" to google)
on the details if needed.

>--- a/include/net/netfilter/nf_conntrack_core.h
>+++ b/include/net/netfilter/nf_conntrack_core.h
>@@ -63,8 +63,21 @@ static inline int nf_conntrack_confirm(struct sk_buff *skb)
> 	if (ct && ct != &nf_conntrack_untracked) {
> 		if (!nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct))
> 			ret = __nf_conntrack_confirm(skb);
>-		if (likely(ret == NF_ACCEPT))
>+		if (likely(ret == NF_ACCEPT)) {
>+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
>+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
>+			int (*syn_proxy)(struct sk_buff *, struct nf_conn *,
>+					 enum ip_conntrack_info);
>+#endif
>+
> 			nf_ct_deliver_cached_events(ct);
>+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
>+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
>+			syn_proxy = rcu_dereference(syn_proxy_post_hook);
>+			if (syn_proxy)
>+				ret = syn_proxy(skb, ct, skb->nfctinfo);
>+#endif
>+		}
> 	}
> 	return ret;
> }

I'm sure this is possible with lesser macro intrusion - use a separate
function. Same in nf_conntrack_core.c

>--- a/include/net/tcp.h
>+++ b/include/net/tcp.h
>@@ -460,8 +460,18 @@ extern int			tcp_disconnect(struct sock *sk, int flags);
> extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
> extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
> 				    struct ip_options *opt);
>-extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
>-				     __u16 *mss);
>+extern __u32 __cookie_v4_init_sequence(__be32 saddr, __be32 daddr,
>+				       __be16 sport, __be16 dport, __u32 seq,
>+				       __u16 *mssp);
>+static inline __u32 cookie_v4_init_sequence(const struct iphdr *iph,
>+					    const struct tcphdr *th,
>+					    __u16 *mssp)
>+{
>+	return __cookie_v4_init_sequence(iph->saddr, iph->daddr, th->source,
>+					 th->dest, ntohl(th->seq), mssp);
>+}

Since there is only one cookie_v4_init_sequence user AFAICS,
moving the function there seems to make best sense.

>+static int get_mss(u8 *data, int len)

unsigned

>+	/* only support IPv4 now */

Please fix :)

>+	th = skb_header_pointer(skb, iph->ihl * 4, sizeof(_th), &_th);
>+	BUG_ON(th == NULL);

I wouldn't call that a bug. I think that can happen on an evil TCP tinygram
(with proper IPV4 header).

>+static int syn_proxy_mangle_pkt(struct sk_buff *skb, struct iphdr *iph,
>+				struct tcphdr *th, u32 seq_diff)
>+{
>+	__be32 new;
>+	int olen;
>+
>+	if (skb->len < (iph->ihl + th->doff) * 4)
>+		return NF_DROP;

Verdicts are unsigned too. (Also in other functions.)

>+static struct xt_target synproxy_tg_reg __read_mostly = {
>+	.name		= "SYNPROXY",
>+	.family		= NFPROTO_IPV4,
>+	.target		= synproxy_tg,
>+	.table		= "raw",
>+	.hooks		= (1 << NF_INET_PRE_ROUTING),

No need for (),

>+	.proto		= IPPROTO_TCP,
>+	.me		= THIS_MODULE,
>+};
>+
>+static int __init synproxy_tg_init(void)
>+{
>+	int err, cpu;
>+
>+	for_each_possible_cpu(cpu)
>+		per_cpu(syn_proxy_state, cpu).seq_inited = 0;

Static data starts out zeroed. That also applies to percpu data, doesn't it?

