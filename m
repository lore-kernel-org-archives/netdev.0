From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 20/31] netns ct: NOTRACK in netns
Date: Mon, 21 Jul 2008 19:05:10 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0807211901220.21244@fbirervta.pbzchgretzou.qr>
References: <20080721165028.GF13390@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, dev@openvz.org, xemul@openvz.org,
	ebiederm@xmission.com, dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080721165028.GF13390@martell.zuzino.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2008-07-21 18:50, Alexey Dobriyan wrote:

>Make untracked conntrack per-netns. Compare conntracks with untracked
>one in relevant netns.
>
>The following code may looks funny (sort-of self-referential):
>
>	if (ct == ct->ct_net->ct.untracked)
>		...

The untracked conntrack is a singleton as I see it, as such it
should not be netnsed.


>+++ b/net/netfilter/xt_NOTRACK.c
>@@ -25,7 +26,7 @@ notrack_tg(struct sk_buff *skb, const struct net_device *in,
> 	   If there is a real ct entry correspondig to this packet,
> 	   it'll hang aroun till timing out. We don't deal with it
> 	   for performance reasons. JK */
>-	skb->nfct = &nf_conntrack_untracked.ct_general;
>+	skb->nfct = &dev_net(in ? in : out)->ct.untracked.ct_general;

You can just use 'in ? : out'.

>+++ b/net/netfilter/xt_state.c
>@@ -30,7 +31,7 @@ state_mt(const struct sk_buff *skb, const struct net_device *in,
> 	enum ip_conntrack_info ctinfo;
> 	unsigned int statebit;
> 
>-	if (nf_ct_is_untracked(skb))
>+	if (nf_ct_is_untracked(dev_net(in ? in : out), skb))

Does this even do the right thing? Given the forward path, where
both in!=NULL and out!=NULL, why should it specifically be 'in'
that is selected?
