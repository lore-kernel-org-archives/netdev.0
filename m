From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Mon, 24 Dec 2012 07:19:26 -0500
Message-ID: <50D8484E.5070109@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com> <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com> <50D46060.2070308@gmail.com> <50D46928.9070809@mojatatu.com> <50D46EC
 1.2040608@gmail.com> <50D5B366.30005@mojatatu.com> <50D5BC96.9010602@gmail.com> <50D5BF00.7050304@mojatatu.com> <50D83DDB.102@mojatatu.com> <50D8413C.8050508@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50D8413C.8050508@openwrt.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-12-24 06:49 AM, Felix Fietkau wrote:

>
> After I added it as an experiment, I got distracted with other projects
> again and forgot about submitting it. Take a look at the code - if the
> approach is reasonable, I'll submit this thing for inclusion soon.
>

Excellent ;-> Simple and elegant.

Usable as is  - some minor comments.
First nitpick: The name is not very reflective, how about:
GetMarkFromConntrack or something along those lines?


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

I would have said that this action is probably also not useful for 
egress qdisc path since skb->mark would already be set. It maybe worth 
checking skb->tc_verd and skipping overhead of nf_conntrack_in() call.
Look at act_mirred for such a check.

> +	r = nf_conntrack_in(dev_net(skb->dev), proto, NF_INET_PRE_ROUTING, skb);
> +	if (r != NF_ACCEPT)
> +		goto out;
> +
> +	c = nf_ct_get(skb, &ctinfo);
> +	if (!c)
> +		goto out;
> +
> +	skb->mark = c->mark;
> +	nf_conntrack_put(skb->nfct);
> +	skb->nfct = NULL;
> +
> +out:
> +	return TC_ACT_PIPE;

Ok, perhaps set tcf_action in (iproute2) user space to TC_ACT_PIPE then 
just return policy->tcf_action here.

Even better is to have a different TC_ACT_XXX returned for failure
vs success... Your success path becomes TC_ACT_PIPE and let the
user program the failure branch optionally. This would allow for 
branching to different actions if success/failure, example:
if mark is found {
    if mark is 0xa redirect to ifb0
    else
      redirect to ifb1
} else
       set mark to 3 then redirect to ifb9

etc.

Not sure if that made sense. I am under the influence of nyquil ;->

cheers,
jamal


