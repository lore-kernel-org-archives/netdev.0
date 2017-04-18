From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status feature
Date: Tue, 18 Apr 2017 11:25:46 +0100
Message-ID: <a52b781a-fa2a-0143-14ee-fe2a21468677@synopsys.com>
References: <f43dda26d3c43fdf19d6872306741c16b635558c.1491989111.git.jpinto@synopsys.com>
 <20170412115643.GA32596@lunn.ch>
 <d5e99129-eef0-1d15-7277-e3c82435bf9f@synopsys.com>
 <20170412145833.GD7023@lunn.ch>
 <b8207712-0191-20be-a6dd-ca91d9fa1440@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:59490 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752481AbdDRKZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 06:25:51 -0400
In-Reply-To: <b8207712-0191-20be-a6dd-ca91d9fa1440@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Florian,

Às 6:43 PM de 4/12/2017, Florian Fainelli escreveu:
> On 04/12/2017 07:58 AM, Andrew Lunn wrote:
>> On Wed, Apr 12, 2017 at 01:07:02PM +0100, Joao Pinto wrote:
>>> Hi Andrew,
>>>
>>> Às 12:56 PM de 4/12/2017, Andrew Lunn escreveu:
>>>> On Wed, Apr 12, 2017 at 10:26:20AM +0100, Joao Pinto wrote:
>>>>> When the Drop Transmit Status bit is set, the Tx packet status
>>>>> received from the MAC is dropped in the MTL. When this bit is reset,
>>>>> the Tx packet status received from the MAC is forwarded to the
>>>>> application. This feature will cause a performance improvement.
>>>>>
>>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>>>> ---
>>>>> changes v1->v2:
>>>>> - removed mask from dwmac4_enable_tx_drop()
>>>>>
>>>>>  Documentation/devicetree/bindings/net/stmmac.txt      |  1 +
>>>>>  drivers/net/ethernet/stmicro/stmmac/common.h          |  2 ++
>>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h          |  1 +
>>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c     | 12 ++++++++++++
>>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  3 +++
>>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  2 ++
>>>>>  include/linux/stmmac.h                                |  1 +
>>>>>  7 files changed, 22 insertions(+)
>>>>>
>>>>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
>>>>> index f652b0c..dbcb2cc 100644
>>>>> --- a/Documentation/devicetree/bindings/net/stmmac.txt
>>>>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>>>>> @@ -60,6 +60,7 @@ Optional properties:
>>>>>  		 and MAC2MAC connection.
>>>>>  - snps,tso: this enables the TSO feature otherwise it will be managed by
>>>>>  		 MAC HW capability register. Only for GMAC4 and newer.
>>>>> +- snps,drop-tx-status: this enables drop tx status
>>>>
>>>> Hi Joao
>>>>
>>>> Was the conclusion from testing that this cannot be turned on by
>>>> default?
>>>
>>> This feature is great for applications that need good performance, but has a
>>> drawback since it has an impact in timestamp feature in Tx. There are some
>>> operations in PTP where the timestamp is given to the host through the TX status
>>> in the descriptor, so this will have an impact.
>>>
>>> There's a way of solving this of course by making the driver checking the
>>> timestamp in the MAC_Tx_Timestamp_Status_XXX registers, but I can only look into
>>> that feature later in the future.
>>
>> So the numbers you show, even if they are not on real hardware that
>> anybody uses, do look good.
>>
>> But i don't like this DT property, it sounds like it can potential do
>> bad things to PTP, and you say it can be done without the DT or PTP
>> problems. So I would personally NACK this patch, and ask you to
>> re-submit when you have solved these issues.
> 
> Is not it possible to simply figure out whether this can safely be
> enabled at run time or not? If nobody uses PTP, then turn that on as
> soon as you get someone using PTP, turn this back off?

Yes that might work, and cause a performance improvement since TX processing
would be lighter. According to the R&D, the PTP problem can be overcome by
reading a special register that contains the timestamping, but I will need to
investigate that more.

I am going to start working on TSN features soon, and then I will get the "Drop
Status" topic again with the PTP issue solved and submit the patch again.

> 
> The problem is the commit message is extremely scarce about what this
> implies, and quite frankly, I don't understand what "application" means
> here, whether this means:
> 
> - application in the sense of the HW IP, which is then, the OS'
> networking stack presumably?
> 
> - application in the sense of the OS, which is sort of conflated with
> the socket user?
> 
> Worst case, can't you create a new netdev feature (e.g: similar to
> NETIF_F_RXFCS) that allows dynamically turning this on based on user
> configuration? Not suggesting this is the right approach here, but it
> should be thought of. Maybe an ethtool private flag is more appropriate?
> 
> One perspective you need to look at is the following:
> 
> - as an IP vendor, you would like to exercise every little configuration
> knob that the IP can be synthesized with, and that's fine and fun to do
> as long as you are in your controlled environment, this may result in
> custom DT properties, but those may not be candidate for the upstream
> kernel (just downstream)

Totally agree :), I done that with a local gitlab, since the Drop Status feature
will useful in some test cases I will be working on.
Sometimes we don't have the 100% of the thing and as you say some things work
well in a controlled environment but can be complicated in production
environment if not done to wok out of the box.

> 
> - customers want something that works out of the box, don't require
> reading a DT binding (in fact, not reading at all is best) and just get
> the promised performance, and the upstream kernel is the best place to
> get this done, but it needs to be painless

Understand and totally agree with you.

> 
> Finally, and completely tangential to this patch, pretty much *every*
> SoC that has a STMMAC is reasonably cheap to buy, so if Synopsys does
> not, you could, with your own personal money acquire a full set of
> Allwinner, Meson, Sunxi and what not platforms and put these in a test
> labs, heck, I'm sure someone could offer these. Most maintainers just
> collect HW as well as tribal knowledge about what typically breaks on
> this or that platform, and then run their tests on said platforms.
> 

I managed to get a several prototypes for ETH 3.x, 4.x and latest 5.x to have
more test power, but they are prototypes with the "ideal" design configuration,
so we can have suprises in real world hardware, since the original designs are
then adapted to fit the SoC. I totally understand this topic and I already
raised the question inside, so lets see how it develops.

> Hope this helps!
> 

Thank you very much for your e-mail, it was very helpful!

Joao
