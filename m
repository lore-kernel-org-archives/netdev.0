From: Stefan Agner <stefan@agner.ch>
Subject: Re: FEC on i.MX 7 transmit queue timeout
Date: Thu, 04 May 2017 14:36:10 -0700
Message-ID: <e044b850a90e7112028cc12977d15cf2@agner.ch>
References: <c6b66956c48f981a952048da6b2ddd54@agner.ch>
 <ed24e51d-499f-597b-0c9f-7f180e257acb@nxp.com>
 <e99d7c93b7819507c6448842015bf836@agner.ch>
 <AM4PR0401MB2260EBCD552219D3402B68FEFF180@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <86b63ee28acfff3426c4a0bf72d848c1@agner.ch>
 <2bdd64ab-5644-e0a0-9bfe-b8dd2fca7abb@nxp.com>
 <80191e7c9df5871cd450f13b9ea47a10@agner.ch>
 <ab1fc814-4a81-9eb0-b20b-2cd325158ba8@nxp.com>
 <e366479239b66ba80415b5594def2369@agner.ch>
 <AM4PR0401MB2260F011313883C522EA7684FFEA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: festevam@gmail.com, netdev@vger.kernel.org,
        netdev-owner@vger.kernel.org
To: Andy Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:40732 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751814AbdEDVgi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 17:36:38 -0400
In-Reply-To: <AM4PR0401MB2260F011313883C522EA7684FFEA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-03 20:08, Andy Duan wrote:
> From: Stefan Agner <stefan@agner.ch> Sent: Thursday, May 04, 2017 9:22 AM
>>To: Andy Duan <fugang.duan@nxp.com>
>>Cc: fugang.duan@freescale.com; festevam@gmail.com;
>>netdev@vger.kernel.org; netdev-owner@vger.kernel.org
>>Subject: Re: FEC on i.MX 7 transmit queue timeout
>>
>>Hi Andy,
>>
>>On 2017-04-20 19:48, Andy Duan wrote:
>>> On 2017年04月20日 07:15, Stefan Agner wrote:
>>>> I tested again with imx6sx-fec compatible string. I could reproduce
>>>> it on a Colibri with i.MX 7Dual. But not always: It really depends
>>>> whether queue 2 is counting up or not. Just after boot, I check
>>>> /proc/interrupts twice, if queue 2 is counting it will happen!
>>>>
>>>> But if only queue 0 is mostly in use, then it seems to work just fine.
>>> If your case is only running best effort like tcp/udp, you can re-set
>>> the "fsl,num-tx-queues" and "fsl,num-rx-queues" to 1 in board dts file.
>>> Other two queues are for AVB audio/video queues, they have high
>>> priority than queue 0. If running iperf tcp test on the three queues,
>>> then the tcp segment may be out-of-order that cause net watchdog
>>timeout.
>>>>
>>>> I also tried i.MX 7Dual SabreSD here, and the same thing. I had to
>>>> reboot 3 times, then queue 2 was counting:
>>>>   57:          8     GIC-0 150 Level     30be0000.ethernet
>>>>   58:      20137     GIC-0 151 Level     30be0000.ethernet
>>>>   59:       9269     GIC-0 152 Level     30be0000.ethernet
>>>>
>>>> It took me about 40 minutes on Sabre until it happened, and I had to
>>>> force it using iperf, but then I got the ring dumps:
>>> My board had ran more than 47 hours with nfs rootfs in 4.11.0-rc6, but
>>> not running iperf.
>>> I am testing with iperf.
>>
>>Any update on this issue?
>>
>>When using iperf (server) on the board with Linux 4.11 the issue appears
>>within a few iperf iterations on a Sabre (TO 1.2, Board Rev C, if that matters)...
>>
> I don’t know whether you received my last mail. (maybe failed due to I
> received some rejection mails)

I think I did not... The last email I received was Fri, 21 Apr 2017
02:48:23 UTC.

 
> If your case is only running best effort like tcp/udp, you can re-set
> the "fsl,num-tx-queues" and "fsl,num-rx-queues" to 1 in board dts
> file.

I did test that, and it seems to work fine with those properties set to
1.

> Other two queues are for AVB audio/video queues, they have high
> priority than queue 0. If running iperf tcp test on the three queues,
> then the tcp segment may be out-of-order that cause net watchdog
> timeout.

Okay. A single event would be understandable, but it seems to enter some
kind of loop after that (continuously printing "fec 30be0000.ethernet
eth0: TX ring dump ...").

In a quick test I commented out the fec_dump call, with that it seems to
print only once and continues working afterwards (although, speed starts
to decrease, so something is not good at that point).

> In fsl kernel tree, there have one patch that only select the queue0
> for best effort like tcp/udp. Pls test again in your board, if no
> problem I will upstream the patch.

That sounds like a reasonable fix.

IP, no matter whether TCP/UDP, is the most common use case, so IMHO this
should "just work" by default.
