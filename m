From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Tue, 03 Jul 2007 09:26:20 -0400
Message-ID: <1183469180.5159.89.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru>
	 <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
	 <1182275300.4968.83.camel@localhost> <1182989145.5155.81.camel@localhost>
	 <1183411245.6609.16.camel@teletran1>  <1183422081.4947.14.camel@dell>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>,
	netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:7662 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbXGCN0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 09:26:25 -0400
Received: by wr-out-0506.google.com with SMTP id q50so958182wrq
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 06:26:24 -0700 (PDT)
In-Reply-To: <1183422081.4947.14.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-02-07 at 17:21 -0700, Michael Chan wrote:

[Matt, please include the count in the fix per previous email]

> Only base_flags and mss are needed and these can be determined right
> before sending the frame.  So is it better not to store these in the
> skb->cb at all?

long answer:
My goal with storing these values and computing them was to do certain
things that dont require holding the netif_tx_lock within a batch as
well. Evaluating the packet metadata and formating the packet to be
ready for stashing into DMA was one thing i could do outside of holding
the lock easily - and running that in loop of 100 packets amortizes the
instruction cache and allows me (when i get to it) to hold the lock for
a lot less computation.
In the e1000 for example i was able to go as far as computing how many
descriptors are needed per skb and stashing those in the skb->cb; the
way the tg3 is structured makes doing all that needing some big changes.
So to answer your question: It would be nice if i could keep the skb->cb
for now and we can get rid of it later if deemed a nuisance for
batching.

>  
> +	dcount = tg3_tx_avail(tp);
>  	if (unlikely(netif_queue_stopped(tp->dev) &&
> -		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
> +		     (dcount > TG3_TX_WAKEUP_THRESH(tp)))) {
>  		netif_tx_lock(tp->dev);
> +		tp->dev->xmit_win = 1;
>  		if (netif_queue_stopped(tp->dev) &&
> -		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
> +		    (dcount > TG3_TX_WAKEUP_THRESH(tp))) {
>  			netif_wake_queue(tp->dev);
> +			tp->dev->xmit_win = dcount;
> +		}
>  		netif_tx_unlock(tp->dev);
>  	}
>  }
> 
> This is also not right.  tg3_tx() runs without netif_tx_lock().
> tg3_tx_avail() can change after you get the netif_tx_lock() and we must
> get the updated value again.  If we just rely on dcount, we can call
> wake_queue() when the ring is full, or there may be no wakeup when the
> ring is empty.

You are right, I was trying to be a smart-ass there so i didnt have to
fold the lines (for readability). Can you or Matt restore it to the way
it was originally while keeping the xmit_win update and just send me a
patch?

Thanks a lot Michael and Matt for looking at this and improving it.
Maybe i should switch all my nics to tg3 from now on ;->

cheers,
jamal

