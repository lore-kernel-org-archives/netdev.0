From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Fri, 29 Apr 2011 12:37:50 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755018E025F07@orsmsx508.amr.corp.intel.com>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
 <20110429.122940.179938280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4165 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755Ab1D2Thw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 15:37:52 -0400
In-Reply-To: <20110429.122940.179938280.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, April 29, 2011 12:30 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com
> Subject: Re: [RFC PATCH] netlink: Increase netlink dump skb message size
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Mon, 25 Apr 2011 15:01:57 -0700
> 
> > The message size allocated for rtnl info dumps was limited to a single
> page.
> > This is not enough for additional interface info available with devices
> > that support SR-IOV.  Check that the amount of data allocated is
> sufficient
> > for the amount of data requested.
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> 
> Actually, thinking about this problem some more I think your approach
> is close to what we should actually do.
> 
> The only problem is that you've specialized netlink_dump() too much,
> hide the issue in the rtnetlink device dumping code and provide
> the necessary information via the control block.
> 
> 1) Add some information to struct netlink_callback.
> 
>    	"u16	min_dump_alloc;"
> 
>    I think you can change "int family;" there to "u16 family;"
>    so that there is no new space required to add this functionality.
> 
> 2) In netlink_dump().
> 
> 	int alloc_size;
> 
> 	mutex_lock(nlk->cb_mutex);
> 	cb = nlk->cb;
> 	if (cb == NULL) {
> 		...
> 	}
> 	alloc_size = max_t(int, cb->min_dump_alloc, NLMSG_GOODSIZE);
> 	skb = sock_rmalloc(sk, alloc_size, 0, GFP_KERNEL);
> 	if (!skb) {
> 	...
> 
> 3) In net/core/rtnetlink.c add a new method pointer to struct rtnl_link,
>    "u16 (*calc_min_dump_alloc)(struct sk_buff *);"
>    Add an implementation for the RTM_GETLINK slot.
> 
>    This function does the logic to compute the maximum space needed
>    for the devices currently configured, as you hacked directly into
>    the netlink_dump() logic in your match.
> 
> 4) Make netlink_dump_start() take a new argument, this is where you
>    pass the new min_dump_alloc value that will get stored in the
>    newly allocated callback object.
> 
> 	calcit = rtnl_get_calcit(family, type);
> 
>    	min_dump_alloc = 0;
> 	if (calcit)
> 		min_dump_alloc = calcit(skb);
> 	err = netlink_dump_start(rtnl, skb, nlh, dumpit, min_dump_alloc,
> NULL);
> 
> Anyways, something like that.
[Greg Rose] 

I'll look into this and try to get a revised patch done by early next week.

The feedback and suggestions are much appreciated.

- Greg


