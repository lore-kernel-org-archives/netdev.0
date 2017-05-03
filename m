From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH] net: ipv6: Fix warning of freeing alive inet6 address
Date: Wed, 3 May 2017 16:58:36 +0200
Message-ID: <CAAeHK+zMXGp+TYru3bJuTYoN0YUJciHY9o=mVoOV+R+-61B-Sw@mail.gmail.com>
References: <1493749857-18032-1-git-send-email-mmanning@brocade.com> <1fb7b6de-ddb8-0207-0567-91d1ed0aad83@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:35646 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdECO6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 10:58:38 -0400
Received: by mail-yw0-f180.google.com with SMTP id u70so86288590ywe.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 07:58:37 -0700 (PDT)
In-Reply-To: <1fb7b6de-ddb8-0207-0567-91d1ed0aad83@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 3, 2017 at 4:16 PM, Mike Manning <mmanning@brocade.com> wrote:
> On reflection, please put this on hold subject to testing with syzkaller. I have not had a repro of the issue and so the fix even though harmless may not be effective.

Hi Mike,

I didn't see your patch, you think you might have forgotten to add me
to recipients.

Did you try building the kernel with the provided config and then
running the reproducer?

Would you like me to test if this patch fixes the warning?

Thanks!

>
> Thanks
> Mike
>
> On 02/05/17 19:30, Mike Manning wrote:
>> While this is not reproducible manually, Andrey's syzkaller program hit
>> the warning "IPv6: Freeing alive inet6 address" with this part trace:
>>
>> inet6_ifa_finish_destroy+0x12e/0x190 c:894
>> in6_ifa_put ./include/net/addrconf.h:330
>> addrconf_dad_work+0x4e9/0x1040 net/ipv6/addrconf.c:3963
>>
>> The fix is to call in6_ifa_put() for the inet6_ifaddr before rather
>> than after calling addrconf_ifdown(), as the latter may remove it from
>> the address hash table.
>>
>> Fixes: 85b51b12115c ("net: ipv6: Remove addresses for failures with strict DAD")
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>> ---
>>  net/ipv6/addrconf.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 80ce478..361993a 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -3902,8 +3902,11 @@ static void addrconf_dad_work(struct work_struct *w)
>>       } else if (action == DAD_ABORT) {
>>               in6_ifa_hold(ifp);
>>               addrconf_dad_stop(ifp, 1);
>> -             if (disable_ipv6)
>> +             if (disable_ipv6) {
>> +                     in6_ifa_put(ifp);
>>                       addrconf_ifdown(idev->dev, 0);
>> +                     goto unlock;
>> +             }
>>               goto out;
>>       }
>>
>> @@ -3950,6 +3953,7 @@ static void addrconf_dad_work(struct work_struct *w)
>>                     ifp->dad_nonce);
>>  out:
>>       in6_ifa_put(ifp);
>> +unlock:
>>       rtnl_unlock();
>>  }
>>
>>
>
