From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net] ipv6: ignore null_entry in inet6_rtm_getroute() too
Date: Tue, 28 Feb 2017 14:35:22 -0800
Message-ID: <e4c27c86-b97a-e37b-c2a3-8329f1a7301c@cumulusnetworks.com>
References: <1488307478-10081-1-git-send-email-xiyou.wangcong@gmail.com>
 <ee659bf6-789f-edc0-a668-db1c4b0abb20@cumulusnetworks.com>
 <CAM_iQpXEYQbGzJNO6E5kb6pUGTcDuZdupFj8xtiRG5Vx836j8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34495 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751556AbdB1Wff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 17:35:35 -0500
Received: by mail-pg0-f41.google.com with SMTP id p5so11405951pga.1
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 14:35:23 -0800 (PST)
In-Reply-To: <CAM_iQpXEYQbGzJNO6E5kb6pUGTcDuZdupFj8xtiRG5Vx836j8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/28/17 11:48 AM, Cong Wang wrote:
> On Tue, Feb 28, 2017 at 11:01 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 2/28/17 10:44 AM, Cong Wang wrote:
>>> Like commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route dumps"),
>>> we need to ignore null entry in inet6_rtm_getroute() too.
>>>
>>> Return -ENOENT here because we return the same errno when deleting
>>> the null entry.
>>>
>>> Fixes: a1a22c1206 ("net: ipv6: Keep nexthop of multipath route on admin down")
>>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>>> Cc: David Ahern <dsa@cumulusnetworks.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> ---
>>>  net/ipv6/route.c | 6 ++++++
>>>  1 file changed, 6 insertions(+)
>>>
>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>> index f54f426..25590d1 100644
>>> --- a/net/ipv6/route.c
>>> +++ b/net/ipv6/route.c
>>> @@ -3627,6 +3627,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
>>>               rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
>>>       }
>>>
>>> +     if (rt == net->ipv6.ip6_null_entry) {
>>> +             ip6_rt_put(rt);
>>> +             err = -ENOENT;
>>> +             goto errout;
>>> +     }
>>> +
>>>       skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
>>>       if (!skb) {
>>>               ip6_rt_put(rt);
>>>
>>
>> hold on. That test exposed something else, not just a getroute problem.
>> I accidentally ran 'unsahre -n; ip -6 ro ls' on my host machine instead
>> of a VM, so took some time to recover. dumproute already covers the null
>> route.

My host was running a slightly older kernel (did not have the null_entry
check in the dump route path for one).

As for trapping null_entry on getroute, this changes user experience.
Right now you always get a route response for IPv6 with the error set as
rta_error. This patch changes that. I am fine with it since it makes
IPv6 more like IPv4:

# ip -6 ro get 2001:db8:12::1
RTNETLINK answers: Network is unreachable

But, if we are going to do this then err should be set based on
rt->dst.error (ENOENT is not the right error) and the commit message
should state the change.
