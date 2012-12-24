From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Mon, 24 Dec 2012 14:12:33 +0100
Message-ID: <20121224131233.GA29307@1984>
References: <50D327CD.3050904@gmail.com>
 <50D45E25.7050703@mojatatu.com>
 <50D46060.2070308@gmail.com>
 <50D46928.9070809@mojatatu.com>
 <50D46EC1.2040608@gmail.com>
 <50D5B366.30005@mojatatu.com>
 <50D5BC96.9010602@gmail.com>
 <50D5BF00.7050304@mojatatu.com>
 <50D83DDB.102@mojatatu.com>
 <50D8413C.8050508@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45187 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752125Ab2LXNMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Dec 2012 08:12:39 -0500
Content-Disposition: inline
In-Reply-To: <50D8413C.8050508@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Felix,

On Mon, Dec 24, 2012 at 12:49:16PM +0100, Felix Fietkau wrote:
> On 2012-12-24 12:34 PM, Jamal Hadi Salim wrote:
> > 
> > Some good news Yury.
> > I am told Felix Fietkau <nbd@openwrt.org> (on CC) actually
> > already solved this issue and it is a feature in openwrt. I
> > cant find the code.
> > 
> > Felix - Yury is trying to retrieve skb->mark fields from
> > netfilter connmark. My understanding is you have written
> > such an action. Can you please point us to it - and any
> > reason you havent submitted this for inclusion in kernel
> > proper?
> After I added it as an experiment, I got distracted with other projects
> again and forgot about submitting it. Take a look at the code - if the
> approach is reasonable, I'll submit this thing for inclusion soon.
> 
> - Felix
> 
> --- /dev/null
> +++ b/net/sched/act_connmark.c
> @@ -0,0 +1,137 @@
> +/*
> + * Copyright (c) 2011 Felix Fietkau <nbd@openwrt.org>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along with
> + * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
> + * Place - Suite 330, Boston, MA 02111-1307 USA.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/skbuff.h>
> +#include <linux/rtnetlink.h>
> +#include <linux/pkt_cls.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <net/netlink.h>
> +#include <net/pkt_sched.h>
> +#include <net/act_api.h>
> +
> +#include <net/netfilter/nf_conntrack.h>
> +#include <net/netfilter/nf_conntrack_core.h>
> +
> +#define TCA_ACT_CONNMARK	20
> +
> +#define CONNMARK_TAB_MASK     3
> +static struct tcf_common *tcf_connmark_ht[CONNMARK_TAB_MASK + 1];
> +static u32 connmark_idx_gen;
> +static DEFINE_RWLOCK(connmark_lock);
> +
> +static struct tcf_hashinfo connmark_hash_info = {
> +	.htab	=	tcf_connmark_ht,
> +	.hmask	=	CONNMARK_TAB_MASK,
> +	.lock	=	&connmark_lock,
> +};
> +
> +static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
> +		       struct tcf_result *res)
> +{
> +	struct nf_conn *c;
> +	enum ip_conntrack_info ctinfo;
> +	int proto;
> +	int r;
> +
> +	if (skb->protocol == htons(ETH_P_IP)) {
> +		if (skb->len < sizeof(struct iphdr))
> +			goto out;
> +		proto = PF_INET;
> +	} else if (skb->protocol == htons(ETH_P_IPV6)) {
> +		if (skb->len < sizeof(struct ipv6hdr))
> +			goto out;
> +		proto = PF_INET6;
> +	} else
> +		goto out;
> +
> +	r = nf_conntrack_in(dev_net(skb->dev), proto, NF_INET_PRE_ROUTING, skb);

conntrack needs to see defragmented packets, you have to call
nf_defrag_ipv4 / _ipv6 respectively before that.

This also changes the semantics of the raw table in iptables since it
will now see packet with conntrack already attached. So this would
also break -j CT --notrack.

This needs more thinking. I can appreciate the value of calling
conntrack from different points of the packet traversal, but there are
a couple of thing we have to resolve before allowing that.
