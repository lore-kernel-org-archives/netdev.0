From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 14 Feb 2012 16:22:59 -0500 (EST)
Message-ID: <20120214.162259.1368549101249083823.davem@davemloft.net>
References: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755364Ab2BNVXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:23:06 -0500
In-Reply-To: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Sun, 12 Feb 2012 11:13:42 -0800

> I have kept the NLM_F_EXT nlmsg_flags bit to indicate to the kernel
> that the extended ifinfo dump filter mask is present.

No extra indications other than presence of the attribute itself is
necessary.  Please remove this flag.

> @@ -215,6 +216,7 @@ int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
>  #else
>  #define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(8192UL)
>  #endif
> +#define NLMSG_EXT_GOODSIZE SKB_WITH_OVERHEAD(32768UL)

I indicated in my suggestions that you'll need to calculate this at
run-time based upon the extensions enabled and the size of the resulting
message plus attributes.

You absolutely cannot just pick some large number and run with this,
it's highly wasteful and will be potentially causing allocation
failures.

The goodsize value is specifically choosen such that we don't exceed
an order-1 allocation with page sizes of 4096 and larger.

> +struct rtnl_req_extended {
> +	struct nlmsghdr nlh;
> +	struct rtgenmsg g;
> +	char ext[RTA_SPACE(sizeof(__u32))];
> +};
> +
> +/* New extended info filters for IFLA_EXT_MASK */
> +#define RTEXT_FILTER_VF		(1 << 0)
> +

This seems completely unnecessary.

Just define IFLA_EXT_MASK as a variable length array of u32's, but to
be honest, for now, you can just make it a normal u32 attribute.

If we extend it in the future, we can make the kernel handle any
length, u32 or otherwise.  The size field already present in all
netlink attributes will allow us to do this transparently.
