From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 9 Aug 2016 18:25:26 -0700
Message-ID: <85b76eca-5473-6724-0c9d-7b6fa7677f50@gmail.com>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
 <57AA2001.2010904@codeaurora.org>
 <214dcbb7-0c3b-1e00-3e50-db513d77b10b@gmail.com>
 <57AA7ED0.9000707@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34443 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932540AbcHJBjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 21:39:05 -0400
In-Reply-To: <57AA7ED0.9000707@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2016 06:09 PM, Timur Tabi wrote:
> Florian Fainelli wrote:
> 
>> nr_frags can't be bigger than MAX_SKB_FRAGS, hence these checks all
>> other drivers do against 1 + MAX_SKB_FRAGS.
> 
> Doh, I just realized something.  emac_mac_tx_buf_send() just needs to
> make sure that there's enough room for ONE skb.  For some reason I
> thought it had to make sure there's enough room for multiple SKBs.
> 
> Now it makes a lot more sense.  Thank you.
> 
> So it looks like a given SKB can occupy 3 + nr_frags descriptors.  So I
> need to change that line to:
> 
>     if (emac_tpd_num_free_descs(tx_q) < (MAX_SKB_FRAGS + 3))
>         netif_stop_queue(adpt->netdev);
> 
> Question, some  drivers do <= instead of just <, like this:
> 
>     if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
>         netif_tx_stop_queue(txq);
> 
> Is it necessary to stop the queue if there exactly enough descriptors to
> hold an SKB?  Shouldn't the above be this instead:
> 
>     if (ring->free_bds < (MAX_SKB_FRAGS + 1))
>         netif_tx_stop_queue(txq);

Humm, it kind of depends, but I would err on the side of strictly lesser
than as a better behavior where you may still allow a full fragmented
SKB to make it through on the next xmit call (I know the code you quote
is exactly not doing that).

> 
> 
>>> However, I'm confused about one thing.  Almost every other driver just
>>> sets "netdev->mtu = new_mtu" and does nothing else.  I can't find any
>>> other driver that actually stops the RX path, reprograms the hardware,
>>> and then restarts the RX path.  I know this is a stupid question, but
>>> why is my driver doing that?
>>
>> Most drivers allocate RX buffer sizes that are usually bigger than the
>> MTU, but would probably silently fail or expose transient behavior once
>> the MTU changes to greater than the size pre-defined.
> 
> So it looks like the real problem is a race condition between
> 
>     adpt->rxbuf_size = new_mtu > EMAC_DEF_RX_BUF_SIZE ?
>         ALIGN(max_frame, 8) : EMAC_DEF_RX_BUF_SIZE;
> 
> and
> 
>     if (netif_running(netdev))
>         return emac_reinit_locked(adpt);
> 
> 
> That is, if the interface is running, I set rxbuf_size.  If suddenly I
> receive some packets, then the driver will use the wrong buffer size.

Correct, and possibly other HW settings that you have may have to
program to tell the MAC what the maximum packet length should be.

> 
> Is there an easy way for me to stop the RX path before I set rxbuf_size?
>  Some netif_xxx function I can call?

napi_disable() should take care of that.
-- 
Florian
