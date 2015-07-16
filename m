From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v4] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Thu, 16 Jul 2015 11:06:42 +0200
Message-ID: <55A77422.8010305@6wind.com>
References: <20150512161402.GC2081@nanopsycho>	<1431519582-4219-1-git-send-email-nicolas.dichtel@6wind.com> <CAKfDRXjM-afW=PD77KSWU3AKk3ow_zUwb5KW3c3pSYDyAuCjqQ@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38024 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133AbbGPJGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 05:06:45 -0400
Received: by wicmv11 with SMTP id mv11so9947798wic.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 02:06:44 -0700 (PDT)
In-Reply-To: <CAKfDRXjM-afW=PD77KSWU3AKk3ow_zUwb5KW3c3pSYDyAuCjqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/07/2015 16:11, Kristian Evensen a =C3=A9crit :
> Hello,
>
> I have a quick question about this patch.
>
> On Wed, May 13, 2015 at 2:19 PM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index 837d30b5ffed..7b25f1ef3d75 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2415,6 +2415,9 @@ void rtmsg_ifinfo(int type, struct net_device =
*dev, unsigned int change,
>>   {
>>          struct sk_buff *skb;
>>
>> +       if (dev->reg_state !=3D NETREG_REGISTERED)
>> +               return;
>> +
>
> Is this check correct, or placed at the correct location? The reason =
I
> am asking is as follows. In rollback_registered_many(), dev->reg_stat=
e
> is set to NETREG_UNREGISTERING for devices that will be unregistered.
> When rtmsg_ifinfo_build_skb(RTM_DELLINK, ...) is called in the
> following loop in rollback_registered_many, this comparison will
> always be true and no DELLINK event generated.


>
> This change led to some applications I have not behaving as expected
> due to missing DELLINK when network devices are removed. I also see n=
o
> DELLINK with ip mon link. Removing the check restores the old behavio=
r
> (DELLINK events are generated). My machine is running 3.18.18, which
> includes this fix.
Ok, I see the problem. My patch depends on commit
395eea6ccf2b ("rtnetlink: delay RTM_DELLINK notification until after nd=
o_uninit()")
which has been introduced in 3.19 (this patch is not backported in 3.18=
).

After 3.19, rtmsg_ifinfo_build_skb() just builds a message (an skb), it=
 never
calls rtmsg_ifinfo(). After this call, rollback_registered_many() calls
rtmsg_ifinfo_send() (which also never calls rtmsg_ifinfo()).

I will submit a patch for the 3.18.


Regards,
Nicolas
