From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: Re: Synopsys Ethernet QoS
Date: Mon, 12 Dec 2016 17:25:02 +0100
Message-ID: <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net>
 <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>, <larper@axis.com>,
        <rabinv@axis.com>, netdev <netdev@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <Jie.Deng1@synopsys.com>,
        Stephen Warren <swarren@nvidia.com>, <pavel@ucw.cz>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:43560 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbcLLQZH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:25:07 -0500
In-Reply-To: <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/12/2016 11:19 AM, Joao Pinto wrote:
> Hi,
>
> Às 1:44 AM de 12/10/2016, Florian Fainelli escreveu:
>> Le 12/09/16 à 16:16, Andy Shevchenko a écrit :
>>> On Sat, Dec 10, 2016 at 12:52 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>
>>>> It's kind of sad that customers of that IP (stmmac, amd-xgbe, sxgbe)
>>>> did
>>>> actually pioneer the upstreaming effort, but it is good to see people
>>>> from Synopsys willing to fix that in the future.
>>> Wait, you would like to tell that we have more than 2 drivers for the
>>> same (okay, same vendor) IP?!
>>> It's better to unify them earlier, than have n+ copies.
>> Unfortunately that is the case, see this email:
>>
>> https://www.mail-archive.com/netdev@vger.kernel.org/msg142796.html
>>
>> dwc_eth_qos and stmmac have some overlap. There seems to be work
>> underway to unify these two to begin with.
>>
>>> P.S. Though, I don't see how sxgbe got in the list. First glance on
>>> the code doesn't show similarities.
>> Well samsung/sxgbe looks potentially similar to amd/xgbe, but that's
>> just my cursory look at the code, it may very well be something entirely
>> different. The descriptor formats just look suspiciously similar.
>>
> Thank you for your inputs! Renaming seems to be a hotspot. I agree that maybe
> instead of renaming (breaking retro-compatibility as David and Florian
> mentioned), the best is to move stmmac to synopsys/ after merging *qos* and
> removing it. As Florian mentioned, git is capable of detecting folder restructured.
>
> @Rabin Vincent: Hi Rabin. Since Axis is more familiar with the synopsys/*qos*
> driver would it be possible for you to make an initial analysis of what has to
> be merged into Stmmac? This way the development would speed-up.

I can answer that question.

I've sent out 12 patches to the stmmac driver
(all patches are included in the current net-next tree),
with these patches the stmmac driver works properly on Axis hardware
(we use Synopsys GMAC 4.10a synthesized with multiple TX queues).
stmmac's DT binding has also been extended with properties that
existed in DWC EQoS's DT binding, such as no-pbl-x8, txpbl, rxpbl.

Since we have no problem updating the DTB together with the kernel,
we will simply move to using the start using the stmmac driver,
with stmmac's DT binding.

However, I've noticed that NVIDIA has extended the DWC EQoS DT binding,
I don't how easy it would be for them to switch to stmmac's DT binding.
(Adding Stephen Warren to CC.)

The reset sequence that Lars Persson was worried about is not an issue
with the stmmac driver.




There are some performance problems with the stmmac driver though:

When running iperf3 with 3 streams:
iperf3 -c 192.168.0.90 -P 3 -t 30
iperf3 -c 192.168.0.90 -P 3 -t 30 -R

I get really bad fairness between the streams.

This appears to be an issue with how TX IRQ coalescing is implemented in stmmac.
Disabling TX IRQ coalescing in the stmmac driver makes the problem go away.
We have a local patch that implements TX IRQ coalescing in the dwceqos driver,
and we don't see the same problem.

Also netperf TCP_RR and UDP_RR gives really bad results compared to the
dwceqos driver (without IRQ coalescing).
2000 transactions/sec vs 9000 transactions/sec.
Turning TX IRQ coalescing off and RX interrupt watchdog off in stmmac
gives the same performance. I guess it's a trade off, low CPU usage
vs low latency, so I don't know how important TCP_RR/UDP_RR really is.

The best thing would be to get a good working TX IRQ coalesce
implementation with HR timers in stmmac.
Perhaps it should also be investigated if the RX interrupt watchdog
timeout should have a lower default value.



>
> Thanks to all.
>
> Joao
