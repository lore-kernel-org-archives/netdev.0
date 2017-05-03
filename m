From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: Fix warning of freeing alive inet6 address
Date: Wed, 3 May 2017 19:24:20 +0100
Message-ID: <f52bbfcd-e961-190a-6aa5-3f43d833f27c@brocade.com>
References: <1493749857-18032-1-git-send-email-mmanning@brocade.com>
 <CAM_iQpVNqU7zJhOe2Qqn5Og+qer4RKhFwh4bdvRcAnt82zyj3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39514 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751568AbdECSYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 14:24:34 -0400
In-Reply-To: <CAM_iQpVNqU7zJhOe2Qqn5Og+qer4RKhFwh4bdvRcAnt82zyj3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/17 18:58, Cong Wang wrote:
> On Tue, May 2, 2017 at 11:30 AM, Mike Manning <mmanning@brocade.com> wrote:
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
>>         } else if (action == DAD_ABORT) {
>>                 in6_ifa_hold(ifp);
>>                 addrconf_dad_stop(ifp, 1);
>> -               if (disable_ipv6)
>> +               if (disable_ipv6) {
>> +                       in6_ifa_put(ifp);
>>                         addrconf_ifdown(idev->dev, 0);
>> +                       goto unlock;
>> +               }
> 
> 
> But addrconf_dad_stop() calls ipv6_del_addr() which could unhash
> the addr too...
> 

Agreed, and in the mean time Andrey has confirmed that this v1 patch
does not resolve the issue. The problem is not specific to my change
for removing addresses. It seems that generally here the in6_ifa_hold()
and matching in6_ifa_put() are surplus to requirement, as the address
refcnt is 2 even without the hold before calling DAD stop.
