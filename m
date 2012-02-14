From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 14 Feb 2012 21:34:48 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F8C76C@ORSMSX106.amr.corp.intel.com>
References: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
 <20120214.162259.1368549101249083823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56918 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755490Ab2BNVeW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:34:22 -0500
In-Reply-To: <20120214.162259.1368549101249083823.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 14, 2012 1:23 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Sun, 12 Feb 2012 11:13:42 -0800
> 
> > I have kept the NLM_F_EXT nlmsg_flags bit to indicate to the kernel
> > that the extended ifinfo dump filter mask is present.
> 
> No extra indications other than presence of the attribute itself is
> necessary.  Please remove this flag.
> 
> > @@ -215,6 +216,7 @@ int netlink_sendskb(struct sock *sk, struct sk_buff
> *skb);
> >  #else
> >  #define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(8192UL)
> >  #endif
> > +#define NLMSG_EXT_GOODSIZE SKB_WITH_OVERHEAD(32768UL)
> 
> I indicated in my suggestions that you'll need to calculate this at
> run-time based upon the extensions enabled and the size of the resulting
> message plus attributes.
> 
> You absolutely cannot just pick some large number and run with this,
> it's highly wasteful and will be potentially causing allocation
> failures.
> 
> The goodsize value is specifically choosen such that we don't exceed
> an order-1 allocation with page sizes of 4096 and larger.

If I do the buffer size calculation based upon the extensions enabled then I'll have to assume the maximum possible size because at the time the buffer size is calculated we don't' have a handle to the net devices yet.

So if the VF flag is set then I'll assume that up to 255 VFs might be present and calculate based upon that.

> 
> > +struct rtnl_req_extended {
> > +	struct nlmsghdr nlh;
> > +	struct rtgenmsg g;
> > +	char ext[RTA_SPACE(sizeof(__u32))];
> > +};
> > +
> > +/* New extended info filters for IFLA_EXT_MASK */
> > +#define RTEXT_FILTER_VF		(1 << 0)
> > +
> 
> This seems completely unnecessary.
> 
> Just define IFLA_EXT_MASK as a variable length array of u32's, but to
> be honest, for now, you can just make it a normal u32 attribute.
> 
> If we extend it in the future, we can make the kernel handle any
> length, u32 or otherwise.  The size field already present in all
> netlink attributes will allow us to do this transparently.

OK, I think I see where you and Ben are coming from on this.

Thanks,

- Greg
