From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: reduce cycles spend on ICMP replies that
 gets rate limited
Date: Fri, 06 Jan 2017 14:08:06 -0800
Message-ID: <1483740486.9712.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170106173907.32104.52294.stgit@firesoul>
         <1483731621.9712.31.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35850 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935323AbdAFWII (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 17:08:08 -0500
Received: by mail-pf0-f194.google.com with SMTP id b22so4094998pfd.3
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 14:08:08 -0800 (PST)
In-Reply-To: <1483731621.9712.31.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-06 at 11:40 -0800, Eric Dumazet wrote:
> On Fri, 2017-01-06 at 18:39 +0100, Jesper Dangaard Brouer wrote:
> 
> 
> > @@ -648,13 +668,17 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
> >  		}
> >  	}
> >  
> > -	icmp_param = kmalloc(sizeof(*icmp_param), GFP_ATOMIC);
> > -	if (!icmp_param)
> > -		return;
> > -
> >  	sk = icmp_xmit_lock(net);
> >  	if (!sk)
> > -		goto out_free;
> > +		goto out;
> > +
> > +	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
> > +	if (!icmpv4_global_allow(net, type, code))
> > +		goto out_unlock;
> > +
> > +	icmp_param = kmalloc(sizeof(*icmp_param), GFP_ATOMIC);
> > +	if (!icmp_param)
> > +		goto out_unlock;
> 

You could call icmp_xmit_lock() _after_ checking global limit perhaps. 

That would remove one atomic op.

if (!icmpv4_global_allow(net, type, code))
    goto out;

sk = icmp_xmit_lock(net);
if (!sk)
    goto out;
