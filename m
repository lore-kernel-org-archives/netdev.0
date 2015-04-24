From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next 1/3] ipvlan: Defer multicast / broadcast processing
 to a work-queue
Date: Thu, 23 Apr 2015 17:32:29 -0700
Message-ID: <1429835549.22254.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429824589-23663-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Dan Willems <dcbw@redhat.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33508 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbbDXAcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 20:32:32 -0400
Received: by igbpi8 with SMTP id pi8so20005552igb.0
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 17:32:31 -0700 (PDT)
In-Reply-To: <1429824589-23663-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 14:29 -0700, Mahesh Bandewar wrote:

> +static void ipvlan_multicast_enqueue(struct ipvl_port *port,
> +				     struct sk_buff *skb)
> +{
> +	if (skb->protocol == htons(ETH_P_PAUSE))
> +		return;

But what happens to this packet ? It seems leaked ?

> +
> +	spin_lock(&port->backlog.lock);
> +	if (skb_queue_len(&port->backlog) < IPVLAN_QBACKLOG_LIMIT) {
> +		__skb_queue_tail(&port->backlog, skb);
> +		spin_unlock(&port->backlog.lock);
> +	} else {
> +		spin_unlock(&port->backlog.lock);
> +		atomic_long_inc(&skb->dev->rx_dropped);
> +		kfree_skb(skb);
> +	}
> +	schedule_work(&port->wq);

No point calling schedule_work(&port->wq); if packet was dropped.

We are under pressure, so don't add extra cpu cycles ;)
