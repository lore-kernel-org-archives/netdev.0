From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Tue, 5 Feb 2013 10:40:03 +0800
Message-ID: <CAHrpEqQMZNmzRrNQK60hokR2r5S=U65YdC-5h6aHHHzAVdEWKw@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<kepftg$f3c$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:63831 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab3BECkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 21:40:06 -0500
Received: by mail-wg0-f54.google.com with SMTP id fm10so5171538wgb.21
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 18:40:04 -0800 (PST)
In-Reply-To: <kepftg$f3c$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/5 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>:
> On Fri, 01 Feb 2013 16:56:26 +0800, Frank Li wrote:
>
>> BUG: spinlock bad magic on CPU#1, swapper/0/1 lock: 0xbfae0f8c, .magic:
>> 00000000, .owner: <none>/-1, .owner_cpu: 0 Backtrace:
>>  [<80011d54>] (dump_backtrace+0x0/0x10c) from [<804e7800>]
>>  (dump_stack+0x18/0x1c)
>>  r6:bfae0000 r5:bfae0f8c r4:00000000 r3:806c1310 [<804e77e8>]
>>  (dump_stack+0x0/0x1c) from [<804e9f20>] (spin_dump+0x80/0x94)
>>  [<804e9ea0>] (spin_dump+0x0/0x94) from [<804e9f60>]
>>  (spin_bug+0x2c/0x30)
>>  r5:805f6f8c r4:bfae0f8c [<804e9f34>] (spin_bug+0x0/0x30) from
>>  [<80257984>] (do_raw_spin_lock+0x170/0x1b0
>>             )
>>  r5:806b4950 r4:bfae0f8c [<80257814>] (do_raw_spin_lock+0x0/0x1b0) from
>>  [<804ed15c>] (_raw_spin_lock_irqs
>>    ave+0x18/0x20) [<804ed144>] (_raw_spin_lock_irqsave+0x0/0x20) from
>>  [<8033c694>] (fec_ptp_start_
>>  cyclecounter+0x3c/0x120)
>>  r4:bfae0f8c r3:00000002 [<8033c658>]
>>  (fec_ptp_start_cyclecounter+0x0/0x120) from [<80339e08>] (fec_resta
>>                                      rt+0x56c/0x5f8) r8:00000000
>>  r7:806e6f48 r6:00000112 r5:806b4950 r4:bfae0000 [<8033989c>]
>>  (fec_restart+0x0/0x5f8) from [<8033b9e4>] (fec_probe+0x508/0xa48)
>>
>> Signed-off-by: Frank Li <Frank.Li@freescale.com>
>> ---
>>  drivers/net/ethernet/freescale/fec.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.c
>> b/drivers/net/ethernet/freescale/fec.c index 69b16b9..f900ae4 100644 ---
>> a/drivers/net/ethernet/freescale/fec.c +++
>> b/drivers/net/ethernet/freescale/fec.c @@ -1607,6 +1607,7 @@ static int
>> fec_enet_init(struct net_device *ndev)
>>       }
>>
>>       spin_lock_init(&fep->hw_lock);
>> +     spin_lock_init(&fep->tmreg_lock);
>>
>>       fep->netdev = ndev;
>
> Please excuse me, if I'm wrong. I would consider this as a very wrong
> solution:
>
> First, then the spin lock is initialised twice (first time in
> fec_enet_init(), second time in fec_ptp_init()).
>
> Then this patch actually hides the fact that PTP part of fec
> is accessed from fec_ptp_start_cyclecounter() way before
> than fec_ptp_init() is called to initialize PTP).
>
> In my opinion the right patch should either move fec_ptp_init() call
> before fec_restart(), or make fec_restart intelelctual about calling
> fec_ptp_init()/fec_ptp_startcyclecounter() at proper time.

Yes, you are right.

>
> --
> With best wishes
> Dmitry
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
