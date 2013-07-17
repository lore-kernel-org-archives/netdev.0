From: "George Spelvin" <linux@horizon.com>
Subject: Re: [RFC] tulip: Support for byte queue limits
Date: 17 Jul 2013 00:09:59 -0400
Message-ID: <20130717040959.24815.qmail@science.horizon.com>
References: <1373932689.3745.30.camel@bwh-desktop.uk.level5networks.com>
Cc: eric.dumazet@gmail.com, grantgrundler@gmail.com,
	grundler@parisc-linux.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:63945 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750741Ab3GQEKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 00:10:00 -0400
In-Reply-To: <1373932689.3745.30.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>  	wmb();
>>  
>> -	tp->cur_tx++;
>> -
>>  	/* Trigger an immediate transmit demand. */
>>  	iowrite32(0, tp->base_addr + CSR1);
>>  
>> +	tp->cur_tx++;
>> +	netdev_sent_queue(dev, skb->len);
>>  	spin_unlock_irqrestore(&tp->lock, flags);

> This is not good practice, because once you start DMA you have
> effectively passed ownership of the skb to the TX completion handler.

Thank you for this advice.  Just to be clear, is the only issue reading
skb->len from a potentially deallocated skb?  Or is it also going go
give the byte queue system fits if the transmit complete handler calls
netdev_completed_queue before the transmitter calls netdev_sent_queue?

I'd hope it can underflow safely, and only look at the net value after
the transmit handler returns.

> Presumably the TX completion handler will hold this spinlock and
> therefore cannot free the skb before you use skb->len above.  So this
> will be safe now.  But one day someone may want to get rid of this lock,
> so this is a trap waiting to spring.

Sounds like a fun project.  But I have to dig into the BQL code; if it's
getting and dropping locks inside netdev_*_queue, the win is limited.

(A lock-free version would have separate "sent" and "completed" counters,
and compute the difference when a snapshot is required.)
