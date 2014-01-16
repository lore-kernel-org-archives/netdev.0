From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: TI CPSW Ethernet Tx performance regression
Date: Thu, 16 Jan 2014 15:35:34 -0800
Message-ID: <CAGVrzcbdDAAfFXjYc-ksxqxeJWeY_Jyh1DbwFiOW=p7WqRvzFQ@mail.gmail.com>
References: <1389790129-5721-1-git-send-email-mugunthanvnm@ti.com>
 <1389808467.11912.9.camel@bwh-desktop.uk.level5networks.com>
 <CAGVrzca+jeetqMbQ8NvVgddrjEuay+GWZjZadekV2-AiE4OLyw@mail.gmail.com> <52D77716.1020205@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:49022 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbaAPXgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 18:36:15 -0500
Received: by mail-pd0-f175.google.com with SMTP id r10so3216602pdi.6
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 15:36:14 -0800 (PST)
In-Reply-To: <52D77716.1020205@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/15 Mugunthan V N <mugunthanvnm@ti.com>:
> Hi
>
> On Thursday 16 January 2014 02:51 AM, Florian Fainelli wrote:
>> 2014/1/15 Ben Hutchings <bhutchings@solarflare.com>:
>>> On Wed, 2014-01-15 at 18:18 +0530, Mugunthan V N wrote:
>>>> Hi
>>>>
>>>> I am seeing a performance regression with CPSW driver on AM335x EVM. AM335x EVM
>>>> CPSW has 3.2 kernel support [1] and Mainline support from 3.7. When I am
>>>> comparing the performance between 3.2 and 3.13-rc4. TCP receive performance of
>>>> CPSW between 3.2 and 3.13-rc4 is same (~180Mbps) but TCP Transmit performance
>>>> is poor comparing to 3.2 kernel. In 3.2 kernel is it *256Mbps* and in 3.13-rc4
>>>> it is *70Mbps*
>>>>
>>>> Iperf version is *iperf version 2.0.5 (08 Jul 2010) pthreads* on both PC and EVM
>>>>
>>>> On UDP transmit also performance is down comparing to 3.2 kernel. In 3.2 it is
>>>> 196Mbps for 200Mbps band width and in 3.13-rc4 it is 92Mbps
>>>>
>>>> Can someone point me out where can I look for improving Tx performance. I also
>>>> checked whether there is Tx descriptor over flow and there is none. I have
>>>> tries 3.11 and some older kernel, all are giving ~75Mbps Transmit performance
>>>> only.
>>>>
>>>> [1] - http://arago-project.org/git/projects/?p=linux-am33x.git;a=summary
>>> If you don't get any specific suggestions, you could try bisecting to
>>> find out which specific commit(s) changed the performance.
>> Not necessarily related to that issue, but there are a few
>> weird/unusual things done in the CPSW interrupt handler:
>>
>> static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
>> {
>>         struct cpsw_priv *priv = dev_id;
>>
>>         cpsw_intr_disable(priv);
>>         if (priv->irq_enabled == true) {
>>                 cpsw_disable_irq(priv);
>>                 priv->irq_enabled = false;
>>         }
>>
>>         if (netif_running(priv->ndev)) {
>>                 napi_schedule(&priv->napi);
>>                 return IRQ_HANDLED;
>>         }
>>
>> Checking for netif_running() should not be required, you should not
>> get any TX/RX interrupts if your interface is not running.
>
> The driver also supports Dual EMAC with one physical device. More
> description can be found in [1] under the topic *9.2.1.5.2 Dual Mac
> Mode*. If the first interface is down and the second interface is up,
> without checking the interface we will not know which napi to schedule.
>
>>
>>
>>         priv = cpsw_get_slave_priv(priv, 1);
>>         if (!priv)
>>                 return IRQ_NONE;
>>
>> Should not this be moved up as the very first conditional check to do?
>> is not there a risk to leave the interrupts disabled and not
>> re-enabled due to the first 5 lines at the top?
>
> This has to be kept here to check if the interrupt is triggered by the
> second Ethernet port interface when the first interface is down.
>
>>
>>
>>         if (netif_running(priv->ndev)) {
>>                 napi_schedule(&priv->napi);
>>                 return IRQ_HANDLED;
>>         }
>>
>> This was done before, why doing it again?
>>
>> In drivers/net/ethernet/ti/davinci_cpdma.c::cpdma_chan_process()
>> treats equally an error processing a packet (and will stop there) as
>> well as successfully processing num_tx packets, is that also
>> intentional? Should you attempt to keep processing "quota" packets?
>
> I tried it in my local build but no success.
>
>>
>> As Ben suggests, bisecting what is causing the regression is your best bet here.
>
> I can do a bisect but the issue is I don't have a good commit to bisect
> as 3.2 kernel is TI maintained repo and is not upstreamed as is. CPSW
> with base port support is available in mainline kernel from v3.7, and I
> have tested till v3.7 and the Transmit performance is poor when compared
> to v3.2 kernel maintained by TI.

Whenever I had bad TX performance with hardware, the culprit was that
transmit buffers were not freed quickly enough so the transmit
scheduler cannot push as many packets as expected. When this happens,
the root cause for me was bad TX interrupt which messed up the TX flow
control, but there are plenty other stuff that can go wrong.

You could try to check a few things like TX interrupt rate for the
same workload on both kernels, dump the queue usage every few seconds
etc...

>
> [1] - http://www.ti.com/lit/ug/sprugz8e/sprugz8e.pdf
>
> Regards
> Mugunthan V N



-- 
Florian
