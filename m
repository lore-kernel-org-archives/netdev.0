From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: netif_tx_disable and lockless TX
Date: Thu, 01 Jun 2006 20:25:33 -0700
Message-ID: <447FAFAD.9000503@osdl.org>
References: <20060531051451.GA7110@gondor.apana.org.au>	<20060530.232626.00456312.davem@davemloft.net>	<20060531063152.GA8032@gondor.apana.org.au>	<20060531.000818.78646242.davem@davemloft.net>	<20060531120626.GA11925@gondor.apana.org.au>	<1149078972.5462.72.camel@jzny2> <17533.55270.172654.98522@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, jgarzik@pobox.com, mchan@broadcom.com,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44468 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751072AbWFBD1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:27:05 -0400
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17533.55270.172654.98522@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> jamal writes:
>
>  > Latency-wise: TX completion interrupt provides the best latency.
>  > Processing in the poll() -aka softirq- was almost close to the hardirq
>  > variant. So if you can make things run in a softirq such as transmit
>  > one, then the numbers will likely stay the same.
>  
>  I don't remember we tried tasklet for TX a la Herbert's suggestion but we 
>  used use tasklets for controlling RX processing to avoid hardirq livelock
>  in pre-NAPI versions.
>
>  Had variants of tulip driver with both TX cleaning at ->poll and TX
>  cleaning at hardirq and didn't see any performance difference. The 
>  ->poll was much cleaner but we kept Alexey's original work for tulip.
>
>  > Sorry, I havent been following discussions on netchannels[1] so i am not
>  > qualified to comment on the "replacement" part Dave mentioned earlier.
>  > What I can say is the tx processing doesnt have to be part of the NAPI
>  > poll() and still use hardirq.
>
>  Yes true but I see TX numbers with newer boards (wire rate small pakets)
>  with cleaing in ->poll. Also now linux is very safe in network "overload" 
>  situations. Moving work to hardirq may change that.
>
>
>   
I also noticed that you really don't save much by doing TX cleaning at 
hardirq, because in hardirq you need to do dev_kfree_irq and that causes 
a softirq (for the routing case where users=1). So when routing it 
doesn't make much difference, both methods cause the softirq delayed 
processing to be invoked. For locally generated packets which are 
cloned, the hardirq will drop the ref count, and that is faster than 
doing the whole softirq round trip.
