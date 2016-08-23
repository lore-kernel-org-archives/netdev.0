From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Tue, 23 Aug 2016 08:37:07 -0400
Message-ID: <891dc7d0-80d5-eebf-662d-7ab63718c3bb@mojatatu.com>
References: <20160822143834.32422-1-amir@vadai.me>
 <20160822143834.32422-4-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33685 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753810AbcHWMhL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 08:37:11 -0400
Received: by mail-it0-f68.google.com with SMTP id d65so7893776ith.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 05:37:11 -0700 (PDT)
In-Reply-To: <20160822143834.32422-4-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-22 10:38 AM, Amir Vadai wrote:
> This action could be used before redirecting packets to a shared tunnel
> device, or when redirecting packets arriving from a such a device
>
> The action will release the metadata created by the tunnel device
> (decap), or set the metadata with the specified values for encap
> operation.
>
> For example, the following flower filter will forward all ICMP packets
> destined to 11.11.11.2 through the shared vxlan device 'vxlan0'. Before
> redirecting, a metadata for the vxlan tunnel is created using the
> iptunnel action and it's arguments:
>
> $ filter add dev net0 protocol ip parent ffff: \
>     flower \
>       ip_proto 1 \
>       dst_ip 11.11.11.2 \
>     action iptunnel encap \
>       src_ip 11.11.0.1 \
>       dst_ip 11.11.0.2 \
>       id 11 \
>     action mirred egress redirect dev vxlan0

The noun "ip tunnel" is a little misleading. Unless you can use
this for other types of tunnels (ipip, etc). If this is specific
for just vxlan and metadata setting then some name like vxlanmeta
or something else that signifies both metadata de/encap + vxlan would
be helpful.


> +static int tcf_iptunnel(struct sk_buff *skb, const struct tc_action *a,
> +			struct tcf_result *res)

Can you rename this function to something more grep-able
like tcf_iptunnel_run or tcf_iptunnel_exec?
You already have a data structure called tcf_iptunnel

> +{
> +	struct tcf_iptunnel *t = to_iptunnel(a);
> +	int action;
> +
> +	spin_lock(&t->tcf_lock);
> +	tcf_lastuse_update(&t->tcf_tm);
> +	bstats_update(&t->tcf_bstats, skb);
> +	action = t->tcf_action;
> +
> +	switch (t->tcft_action) {
> +	case TCA_IPTUNNEL_ACT_DECAP:
> +		skb_dst_set_noref(skb, NULL);
> +		break;


So the real decap is going to be at the vxlan dev?


> +static struct metadata_dst *iptunnel_alloc(struct tcf_iptunnel *t,
> +					   __be32 saddr, __be32 daddr,
> +					   __be64 key_id)
> +{
> +	struct ip_tunnel_info *tun_info;
> +	struct metadata_dst *metadata;
> +
> +	metadata = metadata_dst_alloc(0, GFP_KERNEL);
> +	if (!metadata)
> +		return ERR_PTR(-ENOMEM);
> +
> +	tun_info = &metadata->u.tun_info;
> +	tun_info->mode = IP_TUNNEL_INFO_TX;
> +

More grep-ability tun_info sounds and i think is used by tun netdev.

Otherwise looks good (although i still think this wouldve scaled better
if you didnt depend on presence of vxlan dev).

cheers,
jamal
