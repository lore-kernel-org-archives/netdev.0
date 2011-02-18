From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: bond_select_queue off by one
Date: Fri, 18 Feb 2011 23:06:12 +0000
Message-ID: <1298070372.2211.59.camel@localhost>
References: <20110218020713.GA9696@linuxace.com> <22094.1298004108@death>
	 <20110218224958.GC11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Phil Oester <kernel@linuxace.com>,
	netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11626 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab1BRXGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 18:06:16 -0500
In-Reply-To: <20110218224958.GC11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-18 at 17:49 -0500, Andy Gospodarek wrote:
> On Thu, Feb 17, 2011 at 08:41:48PM -0800, Jay Vosburgh wrote:
> > Phil Oester <kernel@linuxace.com> wrote:
> > 
> > >The bonding driver's bond_select_queue function simply returns
> > >skb->queue_mapping.  However queue_mapping could be == 16
> > >for queue #16.  This causes the following message to be flooded
> > >to syslog:
> > >
> > >kernel: bondx selects TX queue 16, but real number of TX queues is 16
> > >
> > >ndo_select_queue wants a zero-based number, so bonding driver needs
> > >to subtract one to return the proper queue number.  Also fix grammar in
> > >a comment while in the vicinity.
> > 
> > 	Andy, can you comment on this?
> > 
> > 	If memory serves, the omission of queue ID zero was on purpose;
> > is this patch going to break any of the functionality added by:
> > 
> > commit bb1d912323d5dd50e1079e389f4e964be14f0ae3
> > Author: Andy Gospodarek <andy@greyhouse.net>
> > Date:   Wed Jun 2 08:40:18 2010 +0000
> > 
> >     bonding: allow user-controlled output slave selection
> > 
> 
> My original intent was that a queue_mapping == 0 would indicate that the
> mode's default transmit routine would be used.  We could still operate
> under this assumption, however.  I think the patch below will work.
> 
> > Ben Hutchings <bhutchings@solarflare.com> wrote:
> > 
> > >This looks basically correct, but it should use the proper functions:
> > >
> > >	skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
> > 
> > 	As Ben points out, skb_rx_queue_recorded, skb_record_rx_queue,
> > et al, do the offset by one internally, but the bond_slave_override
> > function is comparing the slave's queue_id to the skb->queue_mapping.
> > 
> > 	That makes me wonder if this patch is going to mess things up,
> > and if bond_slave_override should also use the skb_rx_queue_recorded, et
> > al, functions.
> > 
> 
> They could be use them, but I really dislike using functions with 'rx'
> in the name for options that are clearly for transmit.

This isn't an option for transmit, it is a record of the result of RX
hashing (or steering).  It may or may not then be used to select a TX
queue.

[...]
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2194,6 +2194,21 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
>         return skb->queue_mapping != 0;
>  }
>  
> +static inline void skb_record_tx_queue(struct sk_buff *skb, u16 tx_queue)
> +{
> +       skb->queue_mapping = tx_queue + 1;
> +}
> +
> +static inline u16 skb_get_tx_queue(const struct sk_buff *skb)
> +{
> +       return skb->queue_mapping - 1;
> +}
> +
> +static inline bool skb_tx_queue_recorded(const struct sk_buff *skb)
> +{
> +       return skb->queue_mapping != 0;
> +}
> +
[...]

This is nonsense.  After the TX queue has been selected, it's recorded
in queue_mapping *without* the offset (skb_set_queue_mapping()).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

