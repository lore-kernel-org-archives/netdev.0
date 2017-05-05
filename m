From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: Fix warning of freeing alive inet6 address
Date: Fri, 5 May 2017 17:51:30 +0100
Message-ID: <e4e4a347-1102-a9c3-5f44-4b59b467dc22@brocade.com>
References: <1493749857-18032-1-git-send-email-mmanning@brocade.com>
 <CAM_iQpVNqU7zJhOe2Qqn5Og+qer4RKhFwh4bdvRcAnt82zyj3A@mail.gmail.com>
 <f52bbfcd-e961-190a-6aa5-3f43d833f27c@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54409 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750854AbdEEQvr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:51:47 -0400
In-Reply-To: <f52bbfcd-e961-190a-6aa5-3f43d833f27c@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/17 19:24, Mike Manning wrote:
> On 03/05/17 18:58, Cong Wang wrote:
>> On Tue, May 2, 2017 at 11:30 AM, Mike Manning <mmanning@brocade.com> wrote:
>>> While this is not reproducible manually, Andrey's syzkaller program hit
>>> the warning "IPv6: Freeing alive inet6 address" with this part trace:
>>>
>>> inet6_ifa_finish_destroy+0x12e/0x190 c:894
>>> in6_ifa_put ./include/net/addrconf.h:330
>>> addrconf_dad_work+0x4e9/0x1040 net/ipv6/addrconf.c:3963
>>>
>>> The fix is to call in6_ifa_put() for the inet6_ifaddr before rather
>>> than after calling addrconf_ifdown(), as the latter may remove it from
>>> the address hash table.
>>>
>>> Fixes: 85b51b12115c ("net: ipv6: Remove addresses for failures with strict DAD")
>>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>>> ---
>>>  net/ipv6/addrconf.c | 6 +++++-
>>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>> index 80ce478..361993a 100644
>>> --- a/net/ipv6/addrconf.c
>>> +++ b/net/ipv6/addrconf.c
>>> @@ -3902,8 +3902,11 @@ static void addrconf_dad_work(struct work_struct *w)
>>>         } else if (action == DAD_ABORT) {
>>>                 in6_ifa_hold(ifp);
>>>                 addrconf_dad_stop(ifp, 1);
>>> -               if (disable_ipv6)
>>> +               if (disable_ipv6) {
>>> +                       in6_ifa_put(ifp);
>>>                         addrconf_ifdown(idev->dev, 0);
>>> +                       goto unlock;
>>> +               }
>>
>>
>> But addrconf_dad_stop() calls ipv6_del_addr() which could unhash
>> the addr too...
>>

Further investigation shows that none of the code block above is at fault. Debugging
shows that the problem is happening with DAD_BEGIN and not DAD_ABORT. Follows more
detail on the issue, but as I do not have a fix at this stage, I retract this
submission altogether.

The problem is due to rapidly adding the same address fd00::bb on ip6tnl0, and also
without running DAD (accept_dad < 1), so it's an edge case. Typically the call to
addrconf_dad_work() starts with an ifp refcnt of 3. Then via addrconf_dad_begin()
and addrconf_dad_completed(), the call to addrconf_del_dad_work() results in a dec
of the refcnt to 2 due to the call to cancel_delayed_work() returning 1.

The 2nd normal case is if the call to addrconf_dad_work() starts with an ifp refcnt of
2, in which case the call to cancel_delayed_work() returns 0 and so no decrement
of the refcnt, which correctly stays at 2.

The error case is when the call to addrconf_dad_work() starts with an ifp refcnt of
2, but the call to cancel_delayed_work() then also results in a dec of the refcnt to 1,
so the final in6_ifa_put() detects that the refcnt is being reduced to 0 for an active
address.

So the question is whether the interaction of cancel_delayed_work() in 
addrconf_dad_work(), delayed_work_pending() in addrconf_mod_dad_work() and
INIT_DELAYED_WORK in ipv6_add_addr() [along with the handling for this when deleting
addresses] needs improving, and if so how?
