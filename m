From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 04/17] netfilter: add namespace support for
 l4proto_generic
Date: Mon, 28 May 2012 11:54:00 +0200
Message-ID: <20120528095400.GB10379@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-5-git-send-email-gaofeng@cn.fujitsu.com>
 <20120523103232.GD2836@1984>
 <4FBD8B40.4020303@cn.fujitsu.com>
 <20120524095222.GA13091@1984>
 <4FBE1678.7050903@cn.fujitsu.com>
 <20120524144038.GB15898@1984>
 <4FC041B4.6080501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FC041B4.6080501@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 26, 2012 at 10:36:36AM +0800, Gao feng wrote:
> >>>>>> @@ -1586,9 +1587,12 @@ static int nf_conntrack_init_net(struct net *net)
> >>>>>>  	ret = nf_conntrack_helper_init(net);
> >>>>>>  	if (ret < 0)
> >>>>>>  		goto err_helper;
> >>>>>> -
> >>>>>> +	ret = nf_conntrack_proto_generic_init(net);
> >>>>>> +	if (ret < 0)
> >>>>>> +		goto err_generic;
> >>>>>>  	return 0;
> >>>>>> -
> >>>>>> +err_generic:
> >>>>>> +	nf_conntrack_helper_fini(net);
> >>>>>>  err_helper:
> >>>>>>  	nf_conntrack_timeout_fini(net);
> >>>>>>  err_timeout:
> >>>>>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> >>>>>> index 7ee6653..9b4bf6d 100644
> >>>>>> --- a/net/netfilter/nf_conntrack_proto.c
> >>>>>> +++ b/net/netfilter/nf_conntrack_proto.c
> >>>>>> @@ -287,10 +287,16 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
> >>>>>>  static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
> >>>>>>  					      struct nf_conntrack_l4proto *l4proto)
> >>>>>>  {
> >>>>>> -	if (l4proto->net_id)
> >>>>>> -		return net_generic(net, *l4proto->net_id);
> >>>>>> -	else
> >>>>>> -		return NULL;
> >>>>>> +	switch (l4proto->l4proto) {
> >>>>>> +	case 255: /* l4proto_generic */
> >>>>>> +		return (struct nf_proto_net *)&net->ct.proto.generic;
> >>>>>> +	default:
> >>>>>> +		if (l4proto->net_id)
> >>>>>> +			return net_generic(net, *l4proto->net_id);
> >>>>>> +		else
> >>>>>> +			return NULL;
> >>>>>> +	}
> >>>>>> +	return NULL;
> >>>>>>  }
> >>>>>>  
> >>>>>>  int nf_ct_l4proto_register_sysctl(struct net *net,
> >>>>>> @@ -457,11 +463,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
> >>>>>>  int nf_conntrack_proto_init(void)
> >>>>>>  {
> >>>>>>  	unsigned int i;
> >>>>>> -	int err;
> >>>>>> -
> >>>>>> -	err = nf_ct_l4proto_register_sysctl(&init_net, &nf_conntrack_l4proto_generic);
> >>>>>> -	if (err < 0)
> >>>>>> -		return err;
> >>>>>
> >>>>> I like that all protocols sysctl are registered by
> >>>>> nf_conntrack_proto_init. Can you keep using that?
> >>>>
> >>>> you mean per-net's generic_proto sysctl are registered by
> >>>> nf_conntrack_proto_init?
> >>>>
> >>>> such as
> >>>>
> >>>> int nf_conntrack_proto_init(struct net *net)
> >>>> {
> >>>> 	...
> >>>> 	err = nf_ct_l4proto_register_sysctl(net, &nf_conntrack_l4proto_generic);
> >>>
> >>> Yes, all protocol trackers included in nf_conntrack_proto_init:
> >>>
> >>>         err = nf_conntrack_proto_generic_init(net);
> >>>         ...
> >>>         err = nf_conntrack_proto_tcp_init(net);
> >>>         ...
> >>>
> >>> and so on.
> >>
> >> sounds good,but the l4protos except l4proto_generic are enabled by
> >> insmod modules(such as nf_conntrack_ipv4,nf_conntrack_proto_udplite).
> >>
> >> So I think it makes no sense to init all protocol here, unless we decide
> >> to put those protos into module nf_conntrack.
> > 
> > Sorry, I meant to say all protocols that are built-in.
> > 
> > So, just put there those that are built-in, like TCP, UDP and generic
> 
> AFAIK l4proto_generic is registered when install module nf_conntrack,
> BUT l4proto_tcp,l4proto_udp,l4proto_icmp are registered when install module nf_conntrack_ipv4.
> 
> So we can only register generic proto here.

You are all right.
