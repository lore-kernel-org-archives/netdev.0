From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Sun, 28 Apr 2013 12:31:56 +0800
Message-ID: <CAHrpEqQeOx1HwSP6URtFM_0U+1a0e==Td3SOcA90Tbxadx-0cA@mail.gmail.com>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
	<CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
	<20130426134415.GS1366@pengutronix.de>
	<20130426.143309.1011152996477262852.davem@davemloft.net>
	<20130427090545.GY1366@pengutronix.de>
	<CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
	<20130427120619.GA26097@electric-eye.fr.zoreil.com>
	<CAHrpEqTE-oGcdMVk2LMffW0JWNgJ-b_+RakpCOVBy6WxA_ARGg@mail.gmail.com>
	<20130427191600.GA30373@electric-eye.fr.zoreil.com>
	<CAHrpEqRnWXV7jC+QuQe+chiEJCXOkmOz1tEdna2SPfPBQ2E=1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:64658 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725Ab3D1Eb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 00:31:58 -0400
Received: by mail-wi0-f181.google.com with SMTP id c10so1784490wiw.8
        for <netdev@vger.kernel.org>; Sat, 27 Apr 2013 21:31:57 -0700 (PDT)
In-Reply-To: <CAHrpEqRnWXV7jC+QuQe+chiEJCXOkmOz1tEdna2SPfPBQ2E=1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/28 Frank Li <lznuaa@gmail.com>:
> 2013/4/28 Francois Romieu <romieu@fr.zoreil.com>:
>> Frank Li <lznuaa@gmail.com> :
>>> 2013/4/27, Francois Romieu <romieu@fr.zoreil.com>:
>> [...]
>>> > napi_disable may sleep.
>>> >
>>> > fec_restart can be called with spinlock held in fec_enet_adjust_link
>>>
>>> You are right. Spin lock in FEC enet adjust link can be removed when
>>> remove spinlock in tx and RX.
>>
>> fec_restart is also called from the netdev watchdog handler (fec_timeout)
>> and tasklet can't sleep either. You should imho schedule_work from
>> fec_timeout.
>
> I will add delay_work to fix this issue.
>
>>
>> How is the driver supposed to avoid the napi context
>> fec_enet_tx:netif_queue_stopped vs fec_enet_start_xmit:netif_stop_queue
>> race since both can run on different cpu without any read/write ordering
>> enforcement between one thread netif_* and its peer {dirty/cur}_tx ?
>
> This is lockless design if only one read and one write. It likes kfifo.
>
> Assume CPU1 run xmit.  CPU2 run napi fec_enet_tx
>
> (1)       if (fep->cur_tx == fep->dirty_tx)
> (2)                 netif_stop_queue(ndev);
>
> if CPU2 update fep->dirty_tx before CPU1 run (1).  the condition is false.
> if CPU2 update fep->dirty_tx after (1) before (2),   netif_stop_queue
> will be called.  There are not problem at this time even though queue
> is not full here.  queue is not empty for sure here. fec_enet_tx will
> be called again when NAPI trigger by one frame finished transfer,
> fec_enet_tx will wake up send queue.
>
> Most worse case is waste one BD script.

I just send out a patch to try to fix your problem.
Can you help test it in your sit?

>
>>
>> --
>> Ueimor
