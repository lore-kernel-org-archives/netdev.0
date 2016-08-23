From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Tue, 23 Aug 2016 19:21:41 +0300
Message-ID: <20160823162141.GC12627@office.localdomain>
References: <20160822143834.32422-1-amir@vadai.me>
 <20160822143834.32422-4-amir@vadai.me>
 <891dc7d0-80d5-eebf-662d-7ab63718c3bb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36020 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754385AbcHWQjr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 12:39:47 -0400
Received: by mail-wm0-f67.google.com with SMTP id i138so18814706wmf.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 09:39:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <891dc7d0-80d5-eebf-662d-7ab63718c3bb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2016 at 08:37:07AM -0400, Jamal Hadi Salim wrote:
> On 16-08-22 10:38 AM, Amir Vadai wrote:
> > This action could be used before redirecting packets to a shared tunnel
> > device, or when redirecting packets arriving from a such a device
> > 
> > The action will release the metadata created by the tunnel device
> > (decap), or set the metadata with the specified values for encap
> > operation.
> > 
> > For example, the following flower filter will forward all ICMP packets
> > destined to 11.11.11.2 through the shared vxlan device 'vxlan0'. Before
> > redirecting, a metadata for the vxlan tunnel is created using the
> > iptunnel action and it's arguments:
> > 
> > $ filter add dev net0 protocol ip parent ffff: \
> >     flower \
> >       ip_proto 1 \
> >       dst_ip 11.11.11.2 \
> >     action iptunnel encap \
> >       src_ip 11.11.0.1 \
> >       dst_ip 11.11.0.2 \
> >       id 11 \
> >     action mirred egress redirect dev vxlan0
> 
> The noun "ip tunnel" is a little misleading. Unless you can use
> this for other types of tunnels (ipip, etc). If this is specific
> for just vxlan and metadata setting then some name like vxlanmeta
> or something else that signifies both metadata de/encap + vxlan would
> be helpful.
Yeh, this name is not the best...
The action is not vxlan specific, it should be good for all the
ip tunnel interfaces that use metadata for the outer headers.
I will rename it to something like mdtunnel - unless someone has a
better suggestion.

> 
> 
> > +static int tcf_iptunnel(struct sk_buff *skb, const struct tc_action *a,
> > +			struct tcf_result *res)
> 
> Can you rename this function to something more grep-able
> like tcf_iptunnel_run or tcf_iptunnel_exec?
> You already have a data structure called tcf_iptunnel
ack

> 
> > +{
> > +	struct tcf_iptunnel *t = to_iptunnel(a);
> > +	int action;
> > +
> > +	spin_lock(&t->tcf_lock);
> > +	tcf_lastuse_update(&t->tcf_tm);
> > +	bstats_update(&t->tcf_bstats, skb);
> > +	action = t->tcf_action;
> > +
> > +	switch (t->tcft_action) {
> > +	case TCA_IPTUNNEL_ACT_DECAP:
> > +		skb_dst_set_noref(skb, NULL);
> > +		break;
> 
> 
> So the real decap is going to be at the vxlan dev?
yes, the action here will just cleanup after the tunnel device will peel
off the outer headers and place it in the metadata. This metadata was
used by the classifier and now can be released.

> 
> 
> > +static struct metadata_dst *iptunnel_alloc(struct tcf_iptunnel *t,
> > +					   __be32 saddr, __be32 daddr,
> > +					   __be64 key_id)
> > +{
> > +	struct ip_tunnel_info *tun_info;
> > +	struct metadata_dst *metadata;
> > +
> > +	metadata = metadata_dst_alloc(0, GFP_KERNEL);
> > +	if (!metadata)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	tun_info = &metadata->u.tun_info;
> > +	tun_info->mode = IP_TUNNEL_INFO_TX;
> > +
> 
> More grep-ability tun_info sounds and i think is used by tun netdev.
ack

> 
> Otherwise looks good (although i still think this wouldve scaled better
> if you didnt depend on presence of vxlan dev).
now I start to have some regrets :)
But I don't see a good enough reason to duplicate code, since I can't
point my finger on a performance problem with using the existing code.

Thanks,
Amir

> 
> cheers,
> jamal
