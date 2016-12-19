From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: Synopsys Ethernet QoS
Date: Mon, 19 Dec 2016 18:58:05 +0100
Message-ID: <06d47014-5533-e761-2674-17f5688fb13c@axis.com>
References: <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
 <73bf8cb4-5685-2db6-529c-1de99b1fd358@st.com>
 <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com> <20161214125735.GA19542@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>, <larper@axis.com>,
        <rabinv@axis.com>, netdev <netdev@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <Jie.Deng1@synopsys.com>,
        Stephen Warren <swarren@nvidia.com>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:52136 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbcLSR6J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 12:58:09 -0500
In-Reply-To: <20161214125735.GA19542@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2016 01:57 PM, Pavel Machek wrote:
> Hi!
>
>> So if there is a long time before handling interrupts,
>> I guess that it makes sense that one stream could
>> get an advantage in the net scheduler.
>>
>> If I find the time, and if no one beats me to it, I will try to replace
>> the normal timers with HR timers + a smaller default timeout.
>>
> Can you try something like this? Highres timers will be needed, too,
> but this fixes the logic problem.
>
> You'll need to apply it twice as code is copy&pasted.
>
> Best regards,

Hello Pavel

If I first apply your other fix "stmmac: fix memory barriers",
then I can apply this fix without getting a netdev watchdog timeout on tx queue0,
and everything appears to work as it should.

Regarding to fairness, I can't really see a difference, with or without your patch.
I've noticed that for TX, the streams actually stabilize after 5 seconds or so,
but with the default test length of 10 seconds, it's easy to get confused
by the test result summary. So I guess from a fairness point of view,
TX is not really a problem.

For RX fairness, it is very much a real issue. The streams never stabilize.
One key difference is that RX coalescing is implemented by using the
RX watchdog.
Here is an iperf3 run that went for 30 seconds:

[  4]   0.00-30.00  sec  1.54 GBytes   440 Mbits/sec    0             sender
[  4]   0.00-30.00  sec  1.54 GBytes   440 Mbits/sec                  receiver
[  6]   0.00-30.00  sec   600 MBytes   168 Mbits/sec    0             sender
[  6]   0.00-30.00  sec   599 MBytes   168 Mbits/sec                  receiver
[  8]   0.00-30.00  sec  1.17 GBytes   334 Mbits/sec    0             sender
[  8]   0.00-30.00  sec  1.17 GBytes   334 Mbits/sec                  receiver
[SUM]   0.00-30.00  sec  3.29 GBytes   942 Mbits/sec    0             sender
[SUM]   0.00-30.00  sec  3.29 GBytes   942 Mbits/sec                  receiver


> 									Pavel
>
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>
>  	 */
>  	priv->tx_count_frames += nfrags + 1;
>  	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
> -		mod_timer(&priv->txtimer,
> -			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
> +		if (priv->tx_count_frames == nfrags + 1)
> +			mod_timer(&priv->txtimer,
> +				  STMMAC_COAL_TIMER(priv->tx_coal_timer));
>  	} else {
>  		priv->tx_count_frames = 0;
>  		priv->hw->desc->set_tx_ic(desc);
>
>
