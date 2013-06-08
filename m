From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] igmp: hash a hash table to speedup
 ip_check_mc_rcu()
Date: Fri, 07 Jun 2013 22:23:13 -0700
Message-ID: <1370668993.24311.460.camel@edumazet-glaptop>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
	 <1370455997.24311.290.camel@edumazet-glaptop>
	 <20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
	 <1370465535.24311.304.camel@edumazet-glaptop>
	 <1370565301.24311.396.camel@edumazet-glaptop>
	 <20130607144833.GB2995@sbohrermbp13-local.rgmadvisors.com>
	 <1370620137.24311.433.camel@edumazet-glaptop> <kouci0$2eu$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:65412 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab3FHFXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 01:23:16 -0400
Received: by mail-pb0-f52.google.com with SMTP id xa12so5448649pbc.11
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 22:23:16 -0700 (PDT)
In-Reply-To: <kouci0$2eu$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-08 at 04:39 +0000, Cong Wang wrote:
> On Fri, 07 Jun 2013 at 15:48 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > diff --git a/include/linux/igmp.h b/include/linux/igmp.h
> > index 7f2bf15..e3362b5 100644
> > --- a/include/linux/igmp.h
> > +++ b/include/linux/igmp.h
> > @@ -84,6 +84,7 @@ struct ip_mc_list {
> >  		struct ip_mc_list *next;
> >  		struct ip_mc_list __rcu *next_rcu;
> >  	};
> > +	struct ip_mc_list __rcu *next_hash;
> 
> 
> Why not put this into the above union?
> 

Because it must be a different storage.

Read ip_mc_hash_add(), its pretty clear...

> 
> > +static void ip_mc_hash_add(struct in_device *in_dev,
> > +			   struct ip_mc_list *im)
> > +{
> > +	struct ip_mc_list __rcu **mc_hash;
> > +	u32 hash;
> > +
> > +	mc_hash = rtnl_dereference(in_dev->mc_hash);
> > +	if (mc_hash) {
> > +		hash = ip_mc_hash(im);
> > +		im->next_hash = rtnl_dereference(mc_hash[hash]);
> > +		rcu_assign_pointer(mc_hash[hash], im);
> > +		return;
> > +	}
> > +
> > +	/* do not use a hash table for small number of items */
> > +	if (in_dev->mc_count < 4)
> > +		return;
> 
> 
> Can this check be moved to the beginning of this function?

Absolutely not.

Once hash table is created, all items must be inserted in,
because of RCU lookups.
