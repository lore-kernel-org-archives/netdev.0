From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] net: l3mdev: Add hook in ip and ipv6
Date: Sat, 7 May 2016 21:32:05 +0300
Message-ID: <20160507213205.02529bde@halley>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
	<1462585781-9146-2-git-send-email-dsa@cumulusnetworks.com>
	<20160507113025.67c3ab43@halley>
	<572E00C9.4050109@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33484 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbcEGScN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 14:32:13 -0400
Received: by mail-wm0-f65.google.com with SMTP id r12so13841972wme.0
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 11:32:13 -0700 (PDT)
In-Reply-To: <572E00C9.4050109@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sat, 7 May 2016 08:50:49 -0600 David Ahern <dsa@cumulusnetworks.com> wrote:
> >> +static inline
> >> +struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
> >> +{
> >> +	struct net_device *master = NULL;
> >> +
> >> +	if (netif_is_l3_slave(skb->dev))
> >> +		master = netdev_master_upper_dev_get_rcu(skb->dev);
> >> +
> >> +	else if (netif_is_l3_master(skb->dev))
> >> +		master = skb->dev;
> >> +
> >> +	if (master && master->l3mdev_ops->l3mdev_l3_rcv)
> >> +		skb = master->l3mdev_ops->l3mdev_l3_rcv(master, skb, proto);  
> >
> > In the case where netif_is_l3_master(skb->dev) is true, can you explain
> > why we need to pass it through the l3mdev_l3_rcv callback again?  
> 
> what do you mean again? This is only time the l3mdev_l3_rcv method is 
> called on a packet.

You have the following:

	if (netif_is_l3_slave(skb->dev))
		master = netdev_master_upper_dev_get_rcu(skb->dev);
	else if (netif_is_l3_master(skb->dev))
		master = skb->dev;
	if (master && master->l3mdev_ops->l3mdev_l3_rcv)
		skb = master->l3mdev_ops->l3mdev_l3_rcv(master, skb, proto);

So in both conditions (skb->dev being the slave or the master) the skb
is passed to master's l3mdev_l3_rcv callback.

Appreciate if you can elaborate:
 - Why callback needs to be invoked when skb->dev is the L3 master?
 - On which circumstances we end up entering
   l3mdev_ip_rcv/l3mdev_ip6_rcv where skb->dev is the master?
   If I got it right, we enter 'ip_rcv_finish' on a slave device,
   the callback is invoked and eventually sets skb->dev and skb->skb_iif
   to the VRF device; then ip_rcv_finish continues processing the
   altered skb (with the changed skb->dev).
   So on which cicumstances do we enter 'ip_rcv_finish' where the
   skb->dev is ALREADY a master device?

Thanks,
Shmulik
