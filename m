From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 2/2] drop_monitor: Make updating data->skb smp safe
Date: Mon, 4 Jun 2012 06:39:06 -0400
Message-ID: <20120604103906.GA20232@hmsreliant.think-freely.org>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
 <1335557509-32726-1-git-send-email-nhorman@tuxdriver.com>
 <1335557509-32726-3-git-send-email-nhorman@tuxdriver.com>
 <1338795910.2760.1739.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42773 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035Ab2FDKj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 06:39:27 -0400
Content-Disposition: inline
In-Reply-To: <1338795910.2760.1739.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 09:45:10AM +0200, Eric Dumazet wrote:
> On Fri, 2012-04-27 at 16:11 -0400, Neil Horman wrote:
> > Eric Dumazet pointed out to me that the drop_monitor protocol has some holes in
> > its smp protections.  Specifically, its possible to replace data->skb while its
> > being written.  This patch corrects that by making data->skb and rcu protected
> > variable.  That will prevent it from being overwritten while a tracepoint is
> > modifying it.
> > 
> 
> >  static void send_dm_alert(struct work_struct *unused)
> >  {
> >  	struct sk_buff *skb;
> > -	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
> > +	struct per_cpu_dm_data *data = &get_cpu_var(dm_cpu_data);
> >  
> >  	/*
> >  	 * Grab the skb we're about to send
> >  	 */
> > -	skb = data->skb;
> > +	skb = rcu_dereference_protected(data->skb, 1);
> >  
> >  	/*
> >  	 * Replace it with a new one
> > @@ -111,8 +134,10 @@ static void send_dm_alert(struct work_struct *unused)
> >  	/*
> >  	 * Ship it!
> >  	 */
> > -	genlmsg_multicast(skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
> > +	if (skb)
> > +		genlmsg_multicast(skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
> >  
> > +	put_cpu_var(dm_cpu_data);
> >  }
> >  
> 
> Oh well, drop_monitor can still trigger alerts :
> 
Grr, Not sure why I didn't see this before.  I'll take care of it shortly.
Neil
