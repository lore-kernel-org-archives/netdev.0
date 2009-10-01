From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Thu, 01 Oct 2009 09:08:06 +0200
Message-ID: <4AC45556.9080303@hartkopp.net>
References: <1254324077.3959.7.camel@johannes.local>	<4AC39A90.6060602@hartkopp.net>	<4AC3A0F1.3060306@hartkopp.net> <20090930.163333.234658158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, mb@bu3sch.de, kalle.valo@iki.fi,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:11177 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755566AbZJAHIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 03:08:06 -0400
In-Reply-To: <20090930.163333.234658158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Wed, 30 Sep 2009 20:18:25 +0200
> 
>> Socket buffers that are generated and received inside softirqs or from process
>> context must not use netif_rx() that's intended to be used from irq context only.
>>
>> This patch introduces a new helper function netif_rx_ti(skb) that tests for
>> in_interrupt() before invoking netif_rx() or netif_rx_ni().
>>
>> It fixes the ratelimited kernel warning
>>
>>         NOHZ: local_softirq_pending 08
>>
>> in the mac80211 and can subsystems.
>>
>> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> 
> I bet all of these code paths can use netif_receive_skb() or
> don't need this conditional blob at all.
> 
> Looking at some specific cases in this patch:
> 
> 1) VCAN:  This RX routine is only invoked from the drivers
>    ->ndo_start_xmit() handler, and therefore like the loopback
>    driver we know that BH's are already disabled and therefore
>    it can always use netif_rx() safely.
> 
>    Why did you convert this case?
> 
>    And if this needs to be converted, why doesn't loopback need
>    to be?
> 
> 2) af_can.c:  In what situation will netif_rx_ni() not be appropriate
>    here?  It should always execute in softirq or user context, now
>    hardirq context.
> 
> And the list goes on and on, I don't really like this new conditional
> testing of interrupt state.

Hello Dave,

i'm confused about in_interrupt(), in_softirq() and in_irq() as pointed out by
Johannes here:

http://marc.info/?l=linux-wireless&m=125432410405562&w=2

Indeed in the two cases for the CAN stuff (in vcan.c and af_can.c) the skb's
are received in process-context and softirq-context only.

Therefore i used netif_rx_ni() in my last change of this code.

Now i was reading from Johannes that in_interrupt() is used for
hardirq-context /and/ softirq-context, so i was just *unsure* and used the
newly introduced netif_rx_ti() for that, which tests for in_interrupt().

Indeed i'm not really happy with that, as it is always better to check each
receive case in which context it can be used and used exactly the right
function for that.

So when netif_rx_ni() or netif_receive_skb() is the best i can use when in
process-context or in softirq-context, i'll do it with pleasure.

And if it is like this the problematic netif_rx() calls in mac80211 need to be
sorted out in detail also ...

Regards,
Oliver

