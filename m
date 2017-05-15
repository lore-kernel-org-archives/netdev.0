From: Ryan Mallon <rmallon@gmail.com>
Subject: Re: [PATCH v2 net-next 06/12] ep93xx_eth: add GRO support
Date: Tue, 16 May 2017 06:43:20 +1000
Message-ID: <591A12E8.1050603@gmail.com>
References: <20170204232502.22361-1-edumazet@google.com> <20170204232502.22361-7-edumazet@google.com> <20170515103132.GA24992@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hartley Sweeten <hsweeten@visionengravers.com>,
        alexander.sverdlin@gmail.com
To: Lennert Buytenhek <buytenh@wantstofly.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33056 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdEOUmJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 16:42:09 -0400
Received: by mail-pg0-f68.google.com with SMTP id s62so18366531pgc.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 13:42:09 -0700 (PDT)
In-Reply-To: <20170515103132.GA24992@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 15/05/17 20:31, Lennert Buytenhek wrote:
> On Sat, Feb 04, 2017 at 03:24:56PM -0800, Eric Dumazet wrote:
> 
>> Use napi_complete_done() instead of __napi_complete() to :
>>
>> 1) Get support of gro_flush_timeout if opt-in
>> 2) Not rearm interrupts for busy-polling users.
>> 3) use standard NAPI API.
>> 4) get rid of baroque code and ease maintenance.
>>
>> [...]
>>
>> @@ -310,35 +311,17 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
>>  	return processed;
>>  }
>>  
>> -static int ep93xx_have_more_rx(struct ep93xx_priv *ep)
>> -{
>> -	struct ep93xx_rstat *rstat = ep->descs->rstat + ep->rx_pointer;
>> -	return !!((rstat->rstat0 & RSTAT0_RFP) && (rstat->rstat1 & RSTAT1_RFP));
>> -}
>> -
>>  static int ep93xx_poll(struct napi_struct *napi, int budget)
>>  {
>>  	struct ep93xx_priv *ep = container_of(napi, struct ep93xx_priv, napi);
>>  	struct net_device *dev = ep->dev;
>> -	int rx = 0;
>> -
>> -poll_some_more:
>> -	rx = ep93xx_rx(dev, rx, budget);
>> -	if (rx < budget) {
>> -		int more = 0;
>> +	int rx;
>>  
>> +	rx = ep93xx_rx(dev, budget);
>> +	if (rx < budget && napi_complete_done(napi, rx)) {
>>  		spin_lock_irq(&ep->rx_lock);
>> -		__napi_complete(napi);
>>  		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
>> -		if (ep93xx_have_more_rx(ep)) {
>> -			wrl(ep, REG_INTEN, REG_INTEN_TX);
>> -			wrl(ep, REG_INTSTSP, REG_INTSTS_RX);
>> -			more = 1;
>> -		}
>>  		spin_unlock_irq(&ep->rx_lock);
>> -
>> -		if (more && napi_reschedule(napi))
>> -			goto poll_some_more;
>>  	}
>>  
>>  	if (rx) {
> 
> This code was the way it was because the ep93xx hardware is somewhat
> braindead.  If I remember correctly (but it's been a while since I wrote
> this code):
> 
> 1. ep93xx netdev IRQs are edge-triggered, so if you re-enable IRQs
>    while there was still work to be done, you will not get another IRQ.
> 
> 2. Disabling an interrupt source in the interrupt mask register will
>    cause its interrupt status bit to always return zero, so you cannot
>    check whether an interrupt status is pending without having the
>    interrupt source enabled.
> 
> (I'll admit that a comment explaining this would have been in order.)
> 
> I don't know if we really care about this hardware anymore (I don't),
> but the ep93xx platform is still listed as being maintained in the
> MAINTAINERS file -- adding Ryan and Hartley.

I no longer have any ep93xx hardware to test with, and I never looked at
the Ethernet, so don't know the details. I think there are still a
handful of users. Adding Alexander who sent an ADC support series this
week, who might be able to test this?

~Ryan
