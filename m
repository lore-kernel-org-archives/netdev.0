From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 2/3] net/act_pedit: Support using offset
 relative to the conventional network headers
Date: Fri, 2 Dec 2016 12:40:29 +0200
Message-ID: <20161202104029.GA7729@office.localdomain>
References: <20161130090928.14816-1-amir@vadai.me>
 <20161130090928.14816-3-amir@vadai.me>
 <20161201.144114.648583754166260714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, ogerlitz@mellanox.com,
        hadarh@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36194 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934104AbcLBKkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 05:40:39 -0500
Received: by mail-wj0-f196.google.com with SMTP id j10so2285027wjb.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 02:40:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161201.144114.648583754166260714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 02:41:14PM -0500, David Miller wrote:
> From: Amir Vadai <amir@vadai.me>
> Date: Wed, 30 Nov 2016 11:09:27 +0200
> 
> > @@ -119,18 +119,45 @@ static bool offset_valid(struct sk_buff *skb, int offset)
> >  	return true;
> >  }
> >  
> > +static int pedit_skb_hdr_offset(struct sk_buff *skb,
> > +				enum pedit_header_type htype, int *hoffset)
> > +{
> > +	int ret = -1;
> > +
> > +	switch (htype) {
> > +	case PEDIT_HDR_TYPE_ETH:
> > +		if (skb_mac_header_was_set(skb)) {
> > +			*hoffset = skb_mac_offset(skb);
> > +			ret = 0;
> > +		}
> > +		break;
> > +	case PEDIT_HDR_TYPE_RAW:
> > +	case PEDIT_HDR_TYPE_IP4:
> > +	case PEDIT_HDR_TYPE_IP6:
> > +		*hoffset = skb_network_offset(skb);
> > +		ret = 0;
> > +		break;
> > +	case PEDIT_HDR_TYPE_TCP:
> > +	case PEDIT_HDR_TYPE_UDP:
> > +		if (skb_transport_header_was_set(skb)) {
> > +			*hoffset = skb_transport_offset(skb);
> > +			ret = 0;
> > +		}
> > +		break;
> > +	};
> > +
> > +	return ret;
> > +}
> > +
> 
> The only distinction between the cases is "L2", "L3", and "L4".
> 
> Therefore I don't see any reason to break it down into IP4 vs. IP6 vs.
> RAW, for example.  They all map to the same thing.
> 
> So why not just have PEDIT_HDR_TYPE_L2, PEDIT_HDR_TYPE_L3, and
> PEDIT_HDR_TYPE_L4?  It definitely seems more straightforward
> and cleaner that way.
Yeh, is isn't by mistake. The next step will be to implement hardware
offloading of the action, and for that we would like to keep the
information about the specific header type.

> 
> Thanks.
