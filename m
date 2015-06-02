From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 06/13] xen-netback: copy buffer on xenvif_start_xmit()
Date: Tue, 2 Jun 2015 16:10:00 +0100
Message-ID: <20150602151000.GR19403@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-7-git-send-email-joao.martins@neclab.eu>
 <20150519153558.GE26335@zion.uk.xensource.com>
 <915BCC85-25D1-4960-A1BA-0C6459ABC953@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Joao Martins <Joao.Martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39296 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759380AbbFBPMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 11:12:50 -0400
Content-Disposition: inline
In-Reply-To: <915BCC85-25D1-4960-A1BA-0C6459ABC953@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 10:26:48AM +0000, Joao Martins wrote:
[...]
> >> 	return IRQ_HANDLED;
> >> }
> >> @@ -168,8 +169,12 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >> 	cb = XENVIF_RX_CB(skb);
> >> 	cb->expires = jiffies + vif->drain_timeout;
> >> 
> >> -	xenvif_rx_queue_tail(queue, skb);
> >> -	xenvif_kick_thread(queue);
> >> +	if (!queue->vif->persistent_grants) {
> >> +		xenvif_rx_queue_tail(queue, skb);
> >> +		xenvif_kick_thread(queue);
> >> +	} else if (xenvif_rx_map(queue, skb)) {
> >> +		return NETDEV_TX_BUSY;
> >> +	}
> >> 
> > 
> > We now have two different functions for guest RX, one is xenvif_rx_map,
> > the other is xenvif_rx_action. They look very similar. Can we only have
> > one?
> I think I can merge this into xenvif_rx_action, and I notice that the stall
> detection its missing. I will also add that.
> Perhaps I could also disable the RX kthread, since this doesn't get used with
> persistent grants?
> 

Disabling that kthread is fine. But we do need to make sure we can do
the same things in start_xmit as we are in kthread. I.e. what context
does start_xmit run in and what are the restrictions.

Wei.
