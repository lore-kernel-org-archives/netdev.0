From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Sun, 29 Mar 2015 20:39:31 -0400
Message-ID: <55189B43.6000407@mojatatu.com>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35439 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbbC3Ajv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 20:39:51 -0400
Received: by igcau2 with SMTP id au2so60389439igc.0
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 17:39:50 -0700 (PDT)
In-Reply-To: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri,

Comments below

On 03/26/15 08:53, Jiri Pirko wrote:
> This patch introduces OpenFlow-based filter. So far, the very essential
> packet fields are supported (according to OpenFlow v1.4 spec).
>
> This patch is only the first step. There is a lot of potential performance
> improvements possible to implement. Also a lot of features are missing
> now. They will be addressed in follow-up patches.
>
> To the name of this classifier, I believe that "cls_openflow" is pretty
> accurate. It is actually a OpenFlow classifier.
>


I agree with your statement above.
Small comments below:


> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

> +struct of_flow_key {
> +	int	indev_ifindex;
> +	struct {
> +		u8	src[ETH_ALEN];
> +		u8	dst[ETH_ALEN];
> +		__be16	type;
> +	} eth;


Could you have got rid of "type" above given we always have
a "proto" field in tc that is checked at the core?


> +	struct {
> +		u8	proto;
> +	} ip;
> +	union {
> +		struct {
> +			__be32 src;
> +			__be32 dst;
> +		} ipv4;
> +		struct {
> +			struct in6_addr src;
> +			struct in6_addr dst;
> +		} ipv6;
> +	};
> +	union {
> +		struct {
> +			__be16 src;
> +			__be16 dst;
> +		} tp;
> +	};

Was there something else that was intended to go into that tp union?

> +static int of_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
> +		   struct sk_buff *skb, struct tcmsg *t)
> +{
> +	struct cls_of_filter *f = (struct cls_of_filter *) fh;
> +	struct nlattr *nest;
> +	struct of_flow_key *key, *mask;
> +
> +	if (!f)
> +		return skb->len;
> +
> +	t->tcm_handle = f->handle;
> +
> +	nest = nla_nest_start(skb, TCA_OPTIONS);
> +	if (!nest)
> +		goto nla_put_failure;
> +
> +	if (f->res.classid &&
> +	    nla_put_u32(skb, TCA_BASIC_CLASSID, f->res.classid))
> +		goto nla_put_failure;


I am sure you didnt meant the above;->

Other than that looks good. I dont mind saying
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

General comments:
so what happens if someone adds a new field? It sounds to me like
given it is tied to datapath match it will never be backward compatible
(i.e think old tc, new kernel vs new tc, old kernel)

cheers,
jamal
