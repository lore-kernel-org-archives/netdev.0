From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: =?UTF-8?Q?Re:_=e7=ad=94=e5=a4=8d:_[PATCH]_ipv6:_addrconf:_fix_dev_r?=
 =?UTF-8?Q?efcont_leak_when_DAD_failed?=
Date: Mon, 5 Sep 2016 14:03:38 +0200
Message-ID: <b839581a-5a5d-e2fa-a5f4-a9a821cf21b2@stressinduktion.org>
References: <1473062791-21118-1-git-send-email-weiyongjun1@huawei.com>
 <6cf03c21-6853-99da-21e0-64b029a9e24f@stressinduktion.org>
 <6AADFAC011213A4C87B956458587ADB46B4BE2@SZXEMI508-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
To: "weiyongjun (A)" <weiyongjun1@huawei.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:35166 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754545AbcIEMDn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 08:03:43 -0400
In-Reply-To: <6AADFAC011213A4C87B956458587ADB46B4BE2@SZXEMI508-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.09.2016 13:54, weiyongjun (A) wrote:
> On 05.09.2016 10:06, Wei Yongjun wrote:
>>>> In general, when DAD detected IPv6 duplicate address, ifp->state will 
>>>> be set to INET6_IFADDR_STATE_ERRDAD and DAD is stopped by a delayed 
>>>> work, the call tree should be like this:
>>>>
>>>> ndisc_recv_ns
>>>>   -> addrconf_dad_failure        <- missing ifp put
>>>>      -> addrconf_mod_dad_work
>>>>        -> schedule addrconf_dad_work()
>>>>          -> addrconf_dad_stop()  <- missing ifp hold before call it
>>>>
>>>> addrconf_dad_failure() called with ifp refcont holding but not put.
>>>> addrconf_dad_work() call addrconf_dad_stop() without extra holding 
>>>> refcount. This will not cause any issue normally.
>>>>
>>>> But the race between addrconf_dad_failure() and addrconf_dad_work() 
>>>> may cause ifp refcount leak and netdevice can not be unregister, 
>>>> dmesg show the following messages:
>>>>
>>>> IPv6: eth0: IPv6 duplicate address fe80::XX:XXXX:XXXX:XX detected!
>>>> ...
>>>> unregister_netdevice: waiting for eth0 to become free. Usage count = 
>>>> 1
>>>>
>>>> Cc: stable@vger.kernel.org
>>>> Fixes: c15b1ccadb32 ("ipv6: move DAD and addrconf_verify processing 
>>>> to
>>>> workqueue")
>>>> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
>>>>
>>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c index
>>>> bdf368e..2f1f5d4 100644
>>>> --- a/net/ipv6/addrconf.c
>>>> +++ b/net/ipv6/addrconf.c
>>>> @@ -1948,6 +1948,7 @@ errdad:
>>>>  	spin_unlock_bh(&ifp->lock);
>>>>  
>>>>  	addrconf_mod_dad_work(ifp, 0);
>>>> +	in6_ifa_put(ifp);
>>>>  }
> 
>>> This in6_ifa_put makes sense.
> 
>>>>  
>>>>  /* Join to solicited addr multicast group.
>>>> @@ -3857,6 +3858,7 @@ static void addrconf_dad_work(struct work_struct *w)
>>>>  		addrconf_dad_begin(ifp);
>>>>  		goto out;
>>>>  	} else if (action == DAD_ABORT) {
>>>> +		in6_ifa_hold(ifp);
>>>>  		addrconf_dad_stop(ifp, 1);
>>>>  		if (disable_ipv6)
>>>>  			addrconf_ifdown(idev->dev, 0);
>>>>
> 
>>> But why you add a in6_ifa_hold here isn't clear to me. Could you 
>>> explain why this is necessary? I don't see any async stuff being done 
>>> in addrconf_dad_stop, thus the reference we already have should be sufficient for the lifetime of addrconf_dad_stop.
> 
>> I think it that link local is added with flag IFA_F_PERMANENT, which we real need it is to remove in6_ifa_put() in addrconf_dad_stop.
> 
>> static void addrconf_dad_stop(...)
>> {
>> 	if (ifp->flags&IFA_F_PERMANENT) {
>> 		...
>> 		in6_ifa_put(ifp);   <== remove this line since caller hold refcount
>> 	} else if (ifp->flags&IFA_F_TEMPORARY) {
>> 		...
>> 		ipv6_del_addr(ifp);
>> 	} else {
>> 		ipv6_del_addr(ifp);
>> 	}
>> }
> 
> I see the comment of ipv6_del_addr:
> 
> /* This function wants to get referenced ifp and releases it before return */
> static void ipv6_del_addr(struct inet6_ifaddr *ifp)
> {
>    ...
> }
> 
> Both in6_ifa_put() and ipv6_del_addr() need a refcount holding, so we should
> use a extra in6_ifa_hold() call before call addrconf_dad_stop() as the origin patch.

You are correct!

We always call in6_ifa_put() at the end of addrconf_dad_work. In this
case it is not correct. Either we add a in6_ifa_hold or we suppress or
jump over the last in6_ifa_put.

Good catch!

Hannes
