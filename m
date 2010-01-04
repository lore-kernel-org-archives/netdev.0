From: "Berck E. Nash" <flyboy@gmail.com>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Sun, 03 Jan 2010 19:44:28 -0700
Message-ID: <4B41560C.4040500@gmail.com>
References: <4B3C8323.1080301@ring3k.org> <4B3CF2C4.5070203@gmail.com> <4B3D38FB.40105@ring3k.org> <20100101183155.GA8519@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mike McCormack <mikem@ring3k.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, dhazelton@enter.net, mbreuer@majjas.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:39698 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784Ab0ADCok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2010 21:44:40 -0500
Received: by ywh6 with SMTP id 6so14956798ywh.4
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2010 18:44:39 -0800 (PST)
In-Reply-To: <20100101183155.GA8519@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Yes, it seems this lock might be needed around this place, but I'd
> like to check another idea: if it's not about awakening too early.
> Berck, could you try this patch?

Okay, after running with that for several days I have not gotten the
oops.  That doesn't mean that I won't tomorrow, but I've gotten several
of these:

[45621.704025] sky2 eth0: hung mac 124:21 fifo 195 (127:122)
[45621.704027] sky2 eth0: receiver hang detected
[45621.708524] sky2 eth0: disabling interface
[45621.715229] sky2 eth0: enabling interface
[45624.862111] sky2 eth0: Link is up at 1000 Mbps, full duplex, flow
control both
[61024.704036] sky2 eth0: hung mac 124:75 fifo 195 (133:128)
[61024.704039] sky2 eth0: receiver hang detected
[61024.708487] sky2 eth0: disabling interface
[61024.714791] sky2 eth0: enabling interface
[61027.864288] sky2 eth0: Link is up at 1000 Mbps, full duplex, flow
control both

And it hasn't crashed.  The "receiver hang detected" would often (but
not always) be followed by the oops before.

Berck
> ---
> 
>  drivers/net/sky2.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 1c01b96..31f1629 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -1844,7 +1844,7 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
>  	sky2->tx_cons = idx;
>  	smp_mb();
>  
> -	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
> +	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4 && netif_device_present(dev))
>  		netif_wake_queue(dev);
>  }
>  
> 

