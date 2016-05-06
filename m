From: David Russell <david@aprsworld.com>
Subject: Re: [PATCH] netdev: enc28j60 kernel panic fix.
Date: Fri, 6 May 2016 13:26:10 -0500
Message-ID: <CAEGHc+ymc3uY0C0WhjfEo5RoS-bQ7h7f6tbBQpAGEJ=D9rr6FA@mail.gmail.com>
References: <CAEGHc+xdoSVa9J_uYm-Az7n4xc+mycy7Jf1p75pss3eVK3jUHA@mail.gmail.com>
	<20160505085110.GA29858@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34949 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758091AbcEFS0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 14:26:25 -0400
Received: by mail-ig0-f181.google.com with SMTP id bi2so53546261igb.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 11:26:25 -0700 (PDT)
In-Reply-To: <20160505085110.GA29858@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I kind of thought my patch was at best incomplete.  When you state
this change silences the bug but does not fix it, what are the
implications of systems running this patch?  We have some production
systems using this patch.  They reboot daily, but have been solid.

In addition, if we sent you a pi and the ethernet controller and a
small but reasonable sum of money for your labor, would you be able to
properly fix it?  Short of that, do you have any recommendations on
quick overviews of the networking stack in the kernel and then
documentation on the various flags and such?

Thanks.

-David Russell
APRS World, LLC
http://www.aprsworld.com/


On Thu, May 5, 2016 at 3:51 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> David Russell <david@aprsworld.com> :
>> When connected directly to another system (not via a switch)
>> eventually a condition where a NULL pointer dereference occurs in
>> enc28j60_hw_tx() and this patch simply checks for that condition and
>> returns gracefully without causing a kernel panic.  I believe, but
>> have not investigated this is caused by a packet collision and am not
>> sure if the kernel tracks collisions or counts them as errors, so that
>> should probably be added if this is what's happening.  I'm also not
>> familiar with the linux kernel, so may have fixed this in a less than
>> ideal way.
>
> Is it possible for EIR.EIR_TXERIF and EIR.EIR_TXIF to be set for the
> same packet ?
>
> If so the driver is intrinsically racy:
> - EIR.EIR_TXIF completes transmission, clears tx_skb and enables queueing
>   again (see netif_wake_queue in enc28j60_tx_clear)
>
> - insert start_xmit here: tx_skb is set and enc28j60_hw_tx is scheduled
>   for late execution (user context work)
>
> - EIR.EIR_EIR.EIR_TXERIF issues same enc28j60_tx_clear and clears tx_skb
>
> - enc28j60_hw_tx is run but tx_skb is NULL
>
>> diff --git a/drivers/net/ethernet/microchip/enc28j60.c
>> b/drivers/net/ethernet/microchip/enc28j60.c
>> index 86ea17e..36ac65f 100644
>> --- a/drivers/net/ethernet/microchip/enc28j60.c
>> +++ b/drivers/net/ethernet/microchip/enc28j60.c
>> @@ -1233,6 +1233,9 @@ static void enc28j60_irq_work_handler(struct
>> work_struct *work)
>>   */
>>  static void enc28j60_hw_tx(struct enc28j60_net *priv)
>>  {
>> +       if (!priv->tx_skb)
>> +               return;
>> +
>>         if (netif_msg_tx_queued(priv))
>>                 printk(KERN_DEBUG DRV_NAME
>>                         ": Tx Packet Len:%d\n", priv->tx_skb->len);
>
> enc28j60_hw_tx isn't the culprit. It's the victim.
>
> This change silences the bug but it does not fix it at all.
>
> --
> Ueimor
