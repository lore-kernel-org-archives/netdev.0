From: Rex Ge <lungothrin@gmail.com>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking send_redirects
Date: Sat, 12 Apr 2014 13:32:03 +0800
Message-ID: <D857DE45-97A1-45C1-B88E-F3657DCC3E33@gmail.com>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com> <20140408.164356.557108616710530006.davem@davemloft.net> <CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com> <20140408.172343.917107273854891906.davem@davemloft.net> <CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com> <alpine.LFD.2.11.1404090110500.3310@ja.home.ssi.bg> <CAM_iQpXNf9rBCtZ2ipiHr2i2Kk4r0QtewiNC-qW8RzR0ChoWqA@mail.gmail.com> <alpine.LFD.2.11.1404091027460.1435@ja.home.ssi.bg> <CAM_iQpWrWgOBkGFBRsqMriDoM4Ph=L_dUNti4wKtBydkdbo+Qw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:56224 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaDLFcK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 01:32:10 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so6273152pbb.28
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 22:32:09 -0700 (PDT)
In-Reply-To: <CAM_iQpWrWgOBkGFBRsqMriDoM4Ph=L_dUNti4wKtBydkdbo+Qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry for send this the third time, I believe I fix the Content-Type this time.


I agree with David.
If your packet fail RP filter, that means something else went seriously wrong. This is not the fix.
some information, like what is the "src addr" you refer to, what does your routing table look like, would help

Rex

On Apr 12, 2014, at 3:11 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Wed, Apr 9, 2014 at 1:03 AM, Julian Anastasov <ja@ssi.bg> wrote:
>> 
>>        Hello,
>> 
>> On Tue, 8 Apr 2014, Cong Wang wrote:
>> 
>>>>        Yes, the code will fail if input route is
>>>> tried on loopback device. My first thought was that
>>>> you forgot to 'ip route flush cache' after clearing
>>>> rp_filter.
>>>> 
>>> 
>>> route cache is removed after 3.6, so I don't need to do it?
>> 
>>        route cache is now FIB cache :)
>> 
>>        My 'ip' tool still does
>> 
>> open("/proc/sys/net/ipv4/route/flush", O_WRONLY) = 4
>> write(4, "-1", 2) = 2
>> close(4)          = 0
>> 
>>        Which invalidates the FIB cache:
>> ipv4_sysctl_rtcache_flush -> rt_cache_flush, fnhe_genid_bump
>> 
>>        The change is noticed via rt_cache_valid and
>> rt_is_expired.
> 
> OK, I will add this.
> 
>> 
>>>>        What kind of packet is that and why the skb lost its
>>>> output route and now it is trying for input route?
>>>> 
>>> 
>>> Yeah, I just noticed that for normal loopback packets its ->dst
>>> are forced to be kept so that it will not need to lookup route
>>> again on rx. However, in our case, we redirect the packets
>>> from veth0 to lo when src_addr == dst_addr, its ->dst is dropped
>>> after coming out of the network namespace, therefore goes into
>>> the slow path to validate the reverse path and lookup the route.
>> 
>>        I'm still not sure that it is valid to process
>> input route on loopback device. There is also a case
>> of broadcasts/multicasts that should preserve their local output
>> route while being looped in ip_mc_output(). In this
>> case device is not loopback. I need more time to check
>> the code again...
> 
> OK, please do, you are the expert on routing. :)
> 
>> 
>>> I think David's point is still valid in this case, __fib_validate_source()
>>> should not reject the packets. So hmm... the only reason I can find is
>>> the following code:
>>> 
>>>        if (fib_lookup(net, &fl4, &res) == 0) {
>>>                if (res.type == RTN_UNICAST)
>>>                        ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
>>>        }
>> 
>>        I think fib_validate_source is called with
>> oif=LOOPBACK_IFINDEX and dev/idev=lo for skb without route,
>> that is the problem. In this case fib_validate_source
>> thinks this is forwarding from lo to lo. So, there is
>> a reason your patch fixes the problem, alternative
>> is to add oif == LOOPBACK_IFINDEX check:
>> 
>>        dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev) ||
>>        oif == LOOPBACK_IFINDEX
> 
> Yeah, actually this is my initial fix, but I thought making an
> exception here for loopback does not look good therefore dropped
> this idea.
> 
>> 
>>> where its nh_scope == RT_SCOPE_HOST?
>> 
>>        The idea is to avoid calling __fib_validate_source,
>> right? No need to look into __fib_validate_source. Also,
>> I'm not sure how legal is to receive packets on lo without
>> skb->dst...
>> 
> 
> That's my point, but David seems not agree. :)
> 
> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
