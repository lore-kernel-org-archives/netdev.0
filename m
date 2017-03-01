From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv6: ignore null_entry in inet6_rtm_getroute() too
Date: Wed, 1 Mar 2017 09:51:54 -0800
Message-ID: <CAM_iQpV-kRgPXCWzkoxJcJfyj=thdgUFeLy+NhM=6G34vzhspA@mail.gmail.com>
References: <1488307478-10081-1-git-send-email-xiyou.wangcong@gmail.com>
 <ee659bf6-789f-edc0-a668-db1c4b0abb20@cumulusnetworks.com>
 <CAM_iQpXEYQbGzJNO6E5kb6pUGTcDuZdupFj8xtiRG5Vx836j8g@mail.gmail.com> <e4c27c86-b97a-e37b-c2a3-8329f1a7301c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34416 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752948AbdCARwW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:52:22 -0500
Received: by mail-wm0-f66.google.com with SMTP id m70so8610186wma.1
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 09:52:21 -0800 (PST)
In-Reply-To: <e4c27c86-b97a-e37b-c2a3-8329f1a7301c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 2:35 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 2/28/17 11:48 AM, Cong Wang wrote:
>> On Tue, Feb 28, 2017 at 11:01 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>> On 2/28/17 10:44 AM, Cong Wang wrote:
>>>> Like commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route dumps"),
>>>> we need to ignore null entry in inet6_rtm_getroute() too.
>>>>
>>>> Return -ENOENT here because we return the same errno when deleting
>>>> the null entry.
>>>>
>>>> Fixes: a1a22c1206 ("net: ipv6: Keep nexthop of multipath route on admin down")
>>>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>>>> Cc: David Ahern <dsa@cumulusnetworks.com>
>>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>>> ---
>>>>  net/ipv6/route.c | 6 ++++++
>>>>  1 file changed, 6 insertions(+)
>>>>
>>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>>> index f54f426..25590d1 100644
>>>> --- a/net/ipv6/route.c
>>>> +++ b/net/ipv6/route.c
>>>> @@ -3627,6 +3627,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
>>>>               rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
>>>>       }
>>>>
>>>> +     if (rt == net->ipv6.ip6_null_entry) {
>>>> +             ip6_rt_put(rt);
>>>> +             err = -ENOENT;
>>>> +             goto errout;
>>>> +     }
>>>> +
>>>>       skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
>>>>       if (!skb) {
>>>>               ip6_rt_put(rt);
>>>>
>>>
>>> hold on. That test exposed something else, not just a getroute problem.
>>> I accidentally ran 'unsahre -n; ip -6 ro ls' on my host machine instead
>>> of a VM, so took some time to recover. dumproute already covers the null
>>> route.
>
> My host was running a slightly older kernel (did not have the null_entry
> check in the dump route path for one).
>
> As for trapping null_entry on getroute, this changes user experience.
> Right now you always get a route response for IPv6 with the error set as
> rta_error. This patch changes that. I am fine with it since it makes
> IPv6 more like IPv4:
>
> # ip -6 ro get 2001:db8:12::1
> RTNETLINK answers: Network is unreachable
>

Yeah, I am not sure if we really want to "return" the null entry here,
since we ignore it in dump anyway. If we really want, an alternative
patch is probably something like:

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 25590d1..e60dc1c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3322,7 +3322,7 @@ static int rt6_nexthop_info(struct sk_buff *skb,
struct rt6_info *rt,
 {
        if (!netif_running(rt->dst.dev) || !netif_carrier_ok(rt->dst.dev)) {
                *flags |= RTNH_F_LINKDOWN;
-               if (rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
+               if (rt->rt6i_idev &&
rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
                        *flags |= RTNH_F_DEAD;
        }


> But, if we are going to do this then err should be set based on
> rt->dst.error (ENOENT is not the right error) and the commit message
> should state the change.
>

Makes sense, I will change the errno and update changelog.
