From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Performance regression from routing cache removal?
Date: Wed, 5 Jun 2013 15:32:53 -0500
Message-ID: <20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
 <1370455997.24311.290.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:45441 "EHLO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757222Ab3FEUc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 16:32:58 -0400
Received: by mail-ob0-f180.google.com with SMTP id eh20so3313807obb.25
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 13:32:57 -0700 (PDT)
In-Reply-To: <1370455997.24311.290.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 05, 2013 at 11:13:17AM -0700, Eric Dumazet wrote:
> On Wed, 2013-06-05 at 12:57 -0500, Shawn Bohrer wrote:
> > I've got a performance regression that I've been trying to track down
> > for the last couple of days.  The last known good kernel was 3.4 and
> > now I'm testing 3.10 so there has been a lot of changes in between.
> > The workload I'm testing has a single machine receiving UDP multicast
> > packets across approximately 350 multicast groups.  We've got one
> > socket per multicast address receiving the data.  The traffic is small
> > packets and tends to be very bursty.  With the 3.10 kernel I'm seeing
> > occasional spikes in one-way latency that are in the 100-500
> > millisecond range, and regularly in the 10 millisecond range.  I've
> > started a git bisect which has narrowed me down to:
> > 
> > bad f5b0a8743601a4477419171f5046bd07d1c080a0
> > good fa0afcd10951afad2022dda09777d2bf70cdab3d
> > 
> > The remaining commits are all part of the routing cache removal so
> > I've stopped my bisection for now.  I can bisect further if anyone
> > thinks it will be valuable.
> 
> > 
> > Digging through the git history the ip_check_mc_rcu appears to be the
> > result of the routing cache removal. 
> 
> Yes, ip_check_mc_rcu() does a linear scan of your ~350 groups :
> 
> for_each_pmc_rcu(in_dev, im) {
>     if (im->multiaddr == mc_addr)
>           break;
> }

Indeed it does.  So what are my options here?

1) Use fewer multicast addresses.  This may not be possible since in
some cases I don't control the incoming data/addresses.  I am running
a test sending the same data over ~280 vs 350 and naturally it does
appear to be better.

2) Make that linear scan a hash lookup?  Are there any downsides or
reasons not to do this?

3) ?

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
