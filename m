From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] drop_monitor: make last_rx timestamp private
Date: Wed, 2 Sep 2009 06:55:35 -0400
Message-ID: <20090902105535.GB402@hmsreliant.think-freely.org>
References: <20090831195847.GA6506@hmsreliant.think-freely.org> <20090901.182127.96935772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35436 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbZIBKzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 06:55:43 -0400
Content-Disposition: inline
In-Reply-To: <20090901.182127.96935772.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2009 at 06:21:27PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 31 Aug 2009 15:58:47 -0400
> 
> > It was recently pointed out to me that the last_rx field of the net_device
> > structure wasn't updated regularly.  In fact only the bonding driver really uses
> > it currently.  Since the drop_monitor code relies on the last_rx field to detect
> > drops on recevie in hardware, We need to find a more reliable way to rate limit
> > our drop checks (so that we don't check for drops on every frame recevied, which
> > would be inefficient.  This patch makes a last_rx timestamp that is private to
> > the drop monitor code and is updated for every device that we track.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Neil, this doesn't apply to net-next-2.6:
> 
> > diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> > index 9d66fa9..34a05ce 100644
> > --- a/net/core/drop_monitor.c
> > +++ b/net/core/drop_monitor.c
>  ...
> > @@ -179,18 +180,21 @@ static void trace_napi_poll_hit(struct napi_struct *napi)
> >  {
> >  	struct dm_hw_stat_delta *new_stat;
> >  
> > -	/*
> > -	 * Ratelimit our check time to dm_hw_check_delta jiffies
> > -	 */
> > -	if (!time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
> > -		return;
> >  
> >  	rcu_read_lock();
> >  	list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> 
> In net-next-2.6 this test reads:
> 
> 	/*
> 	 * Ratelimit our check time to dm_hw_check_delta jiffies
> 	 */
> 	if (!napi->dev ||
> 	    !time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
> 		return;
> 
> and you must retain the napi->dev NULL check there as otherwise
> the list traversal tests will blindly dereference that pointer.
> 

Apologies, this raced with Xiao fix to trace_napi_poll hit, which introduced
that null check.  I'll rediff/repost shortly.

Neil

