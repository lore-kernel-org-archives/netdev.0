From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] Netfilter: Fix an ICMPv6 bug which caused by a latter
 ICMPv6 NA packet to inherit the mark of previous NS packet.
Date: Fri, 21 Oct 2016 11:00:35 +0200
Message-ID: <20161021090035.GA32634@breakpoint.cc>
References: <1477038230-17288-1-git-send-email-evan.xu.tianwen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yasuyuki.kozakai@toshiba.co.jp, pablo@netfilter.org,
        kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: XU Tianwen <evan.xu.tianwen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477038230-17288-1-git-send-email-evan.xu.tianwen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

XU Tianwen <evan.xu.tianwen@gmail.com> wrote:
> The root cause is an ICMPv6 packet hits an untracked connection and inherits a mark from the previous packet to which it is not related, IMO it doesn't make sense to inherit mark for nf_conntrack_untracked.
> 
> Signed-off-by: XU Tianwen <evan.xu.tianwen@gmail.com>
> ---
>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
> index f5a61bc..1be9000 100644
> --- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
> +++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
> @@ -223,6 +223,9 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
>  	if (type >= 0 && type < sizeof(noct_valid_new) &&
>  	    noct_valid_new[type]) {
>  		skb->nfct = &nf_ct_untracked_get()->ct_general;
> +#ifdef CONFIG_NF_CONNTRACK_MARK
> +		((struct nf_conn *)skb->nfct)->mark = 0;
> +#endif
>  		skb->nfctinfo = IP_CT_NEW;
>  		nf_conntrack_get(skb->nfct);
>  		return NF_ACCEPT;
> -- 
> 2.1.2

Where does that bogus mark come from in first place?
Untracked mark should always be 0.

Maybe we need this instead?

diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -44,7 +44,7 @@ connmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
        u_int32_t newmark;
 
        ct = nf_ct_get(skb, &ctinfo);
-       if (ct == NULL)
+       if (ct == NULL || nf_ct_is_untracked(ct))
                return XT_CONTINUE;
