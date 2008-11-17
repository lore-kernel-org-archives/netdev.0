From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] filter: add SKF_AD_NLATTR_NEST to look for nested attributes
Date: Mon, 17 Nov 2008 15:35:09 +0100
Message-ID: <4921811D.3080204@trash.net>
References: <20081117083136.10840.70283.stgit@Decadence> <20081117.003622.132924683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081117.003622.132924683.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
>> SKF_AD_NLATTR allows us to find the first matching attribute in a
>> stream of netlink attributes from one offset to the end of the
>> netlink message. This is not suitable to look for a specific
>> matching inside a set of nested attributes.
>>
>> For example, in ctnetlink messages, if we look for the CTA_V6_SRC
>> attribute in a message that talks about an IPv4 connection,
>> SKF_AD_NLATTR returns the offset of CTA_STATUS which has the same
>> value of CTA_V6_SRC but outside the nest. To differenciate
>> CTA_STATUS and CTA_V6_SRC, we would have to make assumptions on the
>> size of the attribute and the usual offset, resulting in horrible
>> BSF code.
>>
>> This patch adds SKF_AD_NLATTR_NEST, which is a variant of
>> SKF_AD_NLATTR, that looks for an attribute inside the limits of
>> a nested attributes, but not further.
>>
>> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> This looks fine to me, Patrick is it ok with you too?
> 
> If Patrick has no objections I'll apply it to net-next-2.6

I think this needs more validation to avoid overruning the skb data:

> +		case SKF_AD_NLATTR_NEST: {
> +			struct nlattr *nla;
> +
> +			if (skb_is_nonlinear(skb))
> +				return 0;
> +			if (A > skb->len - sizeof(struct nlattr))
> +				return 0;
> +
> +			nla = nla_find_nested((struct nlattr *)&skb->data[A],X);

This interprets skb->data as nlattr and takes the nla_len member
as limit for nla_find(), so it needs to be validated not to exceed
the skb length.

Besides that, the patch looks fine.
