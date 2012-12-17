From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: Do I need to skb_put() Ethernet frames to a minimum of 60 bytes?
Date: Mon, 17 Dec 2012 14:43:11 +0100
Message-ID: <50CF216F.2010107@atmel.com>
References: <502A9EC4.4040208@xdin.com> <1344976557.2690.43.camel@bwh-desktop.uk.solarflarecom.com> <5033C6B0.4060508@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:8961 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605Ab2LQNnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 08:43:14 -0500
In-Reply-To: <5033C6B0.4060508@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 07:34 PM, Arvid Brodin :
> On 2012-08-14 22:35, Ben Hutchings wrote:
>> On Tue, 2012-08-14 at 18:53 +0000, Arvid Brodin wrote:
>>> Hi,
>>>
>>> If I create an sk_buff with a payload of less than 28 bytes (ethheader + data),
>>> and send it using the cadence/macb (Ethernet) driver, I get
>>>
>>> eth0: TX underrun, resetting buffers
>>>
>>> Now I know the minimum Ethernet frame size is 64 bytes (including the 4-byte
>>> FCS), but whose responsibility is it to pad the frame to this size if necessary?
>>> Mine or the driver's - i.e. should I just skb_put() to the minimum size or
>>> should I report the underrun as a driver bug?
>>
>> If the hardware doesn't pad frames automatically then it's the driver's
>> reponsibility to do so.
>>
> 
> Nicolas, can you take a look at this? At the moment I'm using the following change
> in macb.c to avoid TX underruns on short packages:
> 
> --- a/drivers/net/ethernet/cadence/macb.c	2012-05-04 19:14:41.927719667 +0200
> +++ b/drivers/net/ethernet/cadence/macb.c	2012-08-21 19:22:40.063739049 +0200
> @@ -618,6 +618,7 @@ static void macb_poll_controller(struct
>  }
>  #endif
> 
> +#define MIN_ETHFRAME_LEN	60
>  static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct macb *bp = netdev_priv(dev);
> @@ -635,6 +636,12 @@ static int macb_start_xmit(struct sk_buf
>  	printk("\n");
>  #endif
> 
> +	if (skb->len < MIN_ETHFRAME_LEN) {
> +		/* Pad skb to minium Ethernet frame size */
> +		if (skb_tailroom(skb) >= MIN_ETHFRAME_LEN - skb->len)
> +			memset(skb_put(skb, MIN_ETHFRAME_LEN - skb->len), 0,
> +						MIN_ETHFRAME_LEN - skb->len);
> +	}
>  	len = skb->len;
>  	spin_lock_irqsave(&bp->lock, flags);
> 
> 
> ... but as you can see this is limited to linear skbs which has been allocated with
> enough tailroom. Perhaps there are better ways to fix the problem? (Maybe the hardware
> is actually doing the padding already and the problem has to do with the way the DMA
> transfer is set up?)

I come back to this issue. It seems to me that the macb Cadence IP is
padding automatically a too little packet. It is the usual behavior
unless you specify otherwise in the CTRL register embedded in the tx
descriptor. I also verified this with wireshark on both ICMP and UDP
packets.

The error that you are experiencing is on at91sam9260 or at91sam9263
SoCs, am I right?

Best regards,
-- 
Nicolas Ferre
