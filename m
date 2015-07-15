From: Marian Corcodel <corcodel.marian@gmail.com>
Subject: Re: [PATCH net-next]r8169: Serialise some operations from open close
Date: Wed, 15 Jul 2015 11:12:14 +0300
Message-ID: <CAGg4U=EZPSNTCAi6bxnOhY1BxUkNyzFK70ukUASm1wJuE_bvfw@mail.gmail.com>
References: <20150714202311.GA5189@192-168-0-3.rdsnet.ro>
	<20150714234005.GA9052@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35039 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbbGOIMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 04:12:15 -0400
Received: by iecuq6 with SMTP id uq6so28327367iec.2
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 01:12:14 -0700 (PDT)
In-Reply-To: <20150714234005.GA9052@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This it.On me rtl 8101/8102 start now an full duplex with maximum
speed , some times need to restart autoneg in order to start .After
mutex_init access on main structure(struct rtl8169_private)  have only
on mutex_lock , mutex_unlock.

2015-07-15 2:40 GMT+03:00 Francois Romieu <romieu@fr.zoreil.com>:
> Corcodel Marian <corcodel.marian@gmail.com> :
> [...]
>> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
>> index 410c1ee..be67873 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -7555,11 +7555,13 @@ static int rtl8169_close(struct net_device *dev)
>>
>>       rtl_lock_work(tp);
>>       clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
>> -
>> -     rtl8169_down(dev);
>>       rtl_unlock_work(tp);
>>
>> +     rtl8169_down(dev);
>> +     //rtl_unlock_work(tp);
>> +        rtl_lock_work(tp);
>>       cancel_work_sync(&tp->wk.work);
>> +     rtl_unlock_work(tp);
>>
>>       free_irq(pdev->irq, dev);
>
> tab/spaces mix. Stray commented code.
>
> rtl_lock_work/cancel_work_sync/rtl_unlock_work makes no sense.
>
> [...]
>> @@ -7611,10 +7614,12 @@ static int rtl_open(struct net_device *dev)
>>       if (retval < 0)
>>               goto err_free_rx_1;
>>
>> +        rtl_lock_work(tp);
>>       INIT_WORK(&tp->wk.work, rtl_task);
>> -
>> +        rtl_unlock_work(tp);
>>       smp_mb();
>
> ?
>
> Irq has not been requested : this code isn't racing with NAPI.
>
> I don't see either how it could race with a runtime resume handler.
>
> Care to elaborate what it is supposed to race with ?
>
>>
>> +        rtl_lock_work(tp);
>>       rtl_request_firmware(tp);
>>
>>       retval = request_irq(pdev->irq, rtl8169_interrupt,
>> @@ -7623,7 +7628,7 @@ static int rtl_open(struct net_device *dev)
>>       if (retval < 0)
>>               goto err_release_fw_2;
>
> You forgot to balance rtl_lock_work after the err_release_fw_2 label.
>
> :o/
>
> --
> Ueimor
