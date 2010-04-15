From: David Miller <davem@davemloft.net>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 01:33:47 -0700 (PDT)
Message-ID: <20100415.013347.98375530.davem@davemloft.net>
References: <u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
	<20100415.005726.205428265.davem@davemloft.net>
	<k2y412e6f7f1004150127u4e7ec668r80f066bfb3efea81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37434
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755745Ab0DOIdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:33:43 -0400
In-Reply-To: <k2y412e6f7f1004150127u4e7ec668r80f066bfb3efea81@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 15 Apr 2010 16:27:19 +0800

> I think the following patch from Eric should be applied instead.
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index c65f18e..d1bcc9f 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -120,7 +120,7 @@ static int ip_dev_loopback_xmit(struct sk_buff *newskb)
>        newskb->pkt_type = PACKET_LOOPBACK;
>        newskb->ip_summed = CHECKSUM_UNNECESSARY;
>        WARN_ON(!skb_dst(newskb));
> -       netif_rx(newskb);
> +       netif_rx_ni(newskb);
>        return 0;
>  }

Yes, this looks more reasonable.  Eric if you agree please (re-)submit
this formally, I must have missed this somehow, sorry.

And this is a bug fix in any kernel, not just one's that have RPS
patches applied.

If we are not called from some interrupt context, there is no sure
trigger to make sure software interrupts will be executed after the
packet is queued locally.  netif_rx_ni() makes sure that any pending
software interrupts will run in such cases.
