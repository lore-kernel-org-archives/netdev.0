From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] net: reduce cycles spend on ICMP replies that
 gets rate limited
Date: Sat, 7 Jan 2017 10:28:01 +0100
Message-ID: <20170107102801.49fdf5f0@redhat.com>
References: <20170106173907.32104.52294.stgit@firesoul>
        <1483731621.9712.31.camel@edumazet-glaptop3.roam.corp.google.com>
        <1483740486.9712.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52198 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941243AbdAGJ2F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 7 Jan 2017 04:28:05 -0500
In-Reply-To: <1483740486.9712.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 06 Jan 2017 14:08:06 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Fri, 2017-01-06 at 11:40 -0800, Eric Dumazet wrote:
> > On Fri, 2017-01-06 at 18:39 +0100, Jesper Dangaard Brouer wrote:
> > 
> >   
> > > @@ -648,13 +668,17 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
> > >  		}
> > >  	}
> > >  
> > > -	icmp_param = kmalloc(sizeof(*icmp_param), GFP_ATOMIC);
> > > -	if (!icmp_param)
> > > -		return;
> > > -
> > >  	sk = icmp_xmit_lock(net);
> > >  	if (!sk)
> > > -		goto out_free;
> > > +		goto out;
> > > +
> > > +	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
> > > +	if (!icmpv4_global_allow(net, type, code))
> > > +		goto out_unlock;
> > > +
> > > +	icmp_param = kmalloc(sizeof(*icmp_param), GFP_ATOMIC);
> > > +	if (!icmp_param)
> > > +		goto out_unlock;  
> >   
> 
> You could call icmp_xmit_lock() _after_ checking global limit perhaps. 
> 
> That would remove one atomic op.

The reason I don't do this is, because icmp_xmit_lock() disables BH and
icmp_global_allow() have a comment that it need to run with BH-disabled.
Thus, I'm depending on the BH-disable from icmp_xmit_lock().

I would have to move out the BH-disable part of icmp_xmit_lock, to do
this. Would that be acceptable?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
