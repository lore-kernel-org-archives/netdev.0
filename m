From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v3] MPLS: Add limited GSO support
Date: Mon, 20 May 2013 12:18:17 +0900
Message-ID: <20130520031814.GE16811@verge.net.au>
References: <1368773452-32310-1-git-send-email-horms@verge.net.au>
 <1368811574.3301.109.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43930 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755192Ab3ETDSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 23:18:21 -0400
Content-Disposition: inline
In-Reply-To: <1368811574.3301.109.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 10:26:14AM -0700, Eric Dumazet wrote:
> On Fri, 2013-05-17 at 15:50 +0900, Simon Horman wrote:
> 
> > @@ -509,6 +511,8 @@ struct sk_buff {
> >  		__u32		reserved_tailroom;
> >  	};
> >  
> > +	__be16			inner_protocol;
> > +	/* 16/48 bit hole */
> >  	sk_buff_data_t		inner_transport_header;
> >  	sk_buff_data_t		inner_network_header;
> >  	sk_buff_data_t		inner_mac_header;
> 
> We are reaching the point where sk_buff is so big that per packet cost
> is killing us, and guys want linux kernel bypass.
> 
> sizeof(sk_buff) = 0xf8 -> 0x100
> 
> sizeof(skbuff_fclone_cache) = 0x200 -> 0x240 
> 
> So TCP stack performance is going to be hurt by this change, as the
> atomic_t containing fclone_ref will be in a separate cache line.
> 
> __copy_skb_header() needs to be smarter and perform a bulk copy using
> long words
> 
> Maybe we could use 16 bits instead of 32 for the inner_*_headers ?

Thanks. I have made a patch to implement that and it seems to
both reduce the size of struct sk_buff and leave a hole for inner_protocol.

I will also update this patch to guard inner_protocol with
#ifdef CONFIG_NET_MPLS_GSO in struct sk_buff as it is otherwise unused.
