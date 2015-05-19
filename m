From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 08/13] xen-netback: clone skb if skb->xmit_more is set
Date: Tue, 19 May 2015 16:36:13 +0100
Message-ID: <20150519153613.GG26335@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-9-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>,
	<konrad.wilk@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:5956 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755860AbbESQCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 12:02:03 -0400
Content-Disposition: inline
In-Reply-To: <1431451117-70051-9-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 07:18:32PM +0200, Joao Martins wrote:
> On xenvif_start_xmit() we have an additional queue to the netback RX
> kthread that will sends the packet. When using burst>1 pktgen sets
> skb->xmit_more to tell the driver that there more skbs in the queue.
> However, pktgen transmits the same skb <burst> times, which leads to
> the BUG below. Long story short adding the same skb in the rx_queue
> queue leads to crash. Specifically, having pktgen running with burst=2
> what happens is: when we queue the second skb (that is the same as
> the first queued skb), the list will have the tail element with skb->prev
> which is the skb itself. On skb_unlink (i.e. when dequeueing the skb)
> skb->prev will become NULL, but still having list->next pointing to the
> unlinked skb. Because of this skb_peek will still return an skb, which
> will redo the skb_unlink trying to set (skb->prev)->next where skb->prev
> is now NULL, thus leading to the crash (trace below).
> 

>From your description this doesn't sound Xen specific. Sounds like
pktgen breaks in any driver that has an internal queue, which is plenty.

> I'm not sure what the best way to fix this but since it's only happening
> when we use pktgen with burst>1: I chose doing an skb_clone when we don't
> use persistent grants and skb->xmit_more flag is set, and when
> CONFIG_NET_PKTGEN is compiled builtin.
> 

I don't think we should do this.

Wei.
