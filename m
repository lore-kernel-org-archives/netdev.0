From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking send_redirects
Date: Fri, 11 Apr 2014 12:11:24 -0700
Message-ID: <CAM_iQpWrWgOBkGFBRsqMriDoM4Ph=L_dUNti4wKtBydkdbo+Qw@mail.gmail.com>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140408.164356.557108616710530006.davem@davemloft.net>
	<CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com>
	<20140408.172343.917107273854891906.davem@davemloft.net>
	<CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com>
	<alpine.LFD.2.11.1404090110500.3310@ja.home.ssi.bg>
	<CAM_iQpXNf9rBCtZ2ipiHr2i2Kk4r0QtewiNC-qW8RzR0ChoWqA@mail.gmail.com>
	<alpine.LFD.2.11.1404091027460.1435@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:38460 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbaDKTLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 15:11:25 -0400
Received: by mail-ob0-f175.google.com with SMTP id vb8so115677obc.34
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 12:11:24 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1404091027460.1435@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 9, 2014 at 1:03 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Tue, 8 Apr 2014, Cong Wang wrote:
>
>> >         Yes, the code will fail if input route is
>> > tried on loopback device. My first thought was that
>> > you forgot to 'ip route flush cache' after clearing
>> > rp_filter.
>> >
>>
>> route cache is removed after 3.6, so I don't need to do it?
>
>         route cache is now FIB cache :)
>
>         My 'ip' tool still does
>
> open("/proc/sys/net/ipv4/route/flush", O_WRONLY) = 4
> write(4, "-1", 2) = 2
> close(4)          = 0
>
>         Which invalidates the FIB cache:
> ipv4_sysctl_rtcache_flush -> rt_cache_flush, fnhe_genid_bump
>
>         The change is noticed via rt_cache_valid and
> rt_is_expired.

OK, I will add this.

>
>> >         What kind of packet is that and why the skb lost its
>> > output route and now it is trying for input route?
>> >
>>
>> Yeah, I just noticed that for normal loopback packets its ->dst
>> are forced to be kept so that it will not need to lookup route
>> again on rx. However, in our case, we redirect the packets
>> from veth0 to lo when src_addr == dst_addr, its ->dst is dropped
>> after coming out of the network namespace, therefore goes into
>> the slow path to validate the reverse path and lookup the route.
>
>         I'm still not sure that it is valid to process
> input route on loopback device. There is also a case
> of broadcasts/multicasts that should preserve their local output
> route while being looped in ip_mc_output(). In this
> case device is not loopback. I need more time to check
> the code again...

OK, please do, you are the expert on routing. :)

>
>> I think David's point is still valid in this case, __fib_validate_source()
>> should not reject the packets. So hmm... the only reason I can find is
>> the following code:
>>
>>         if (fib_lookup(net, &fl4, &res) == 0) {
>>                 if (res.type == RTN_UNICAST)
>>                         ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
>>         }
>
>         I think fib_validate_source is called with
> oif=LOOPBACK_IFINDEX and dev/idev=lo for skb without route,
> that is the problem. In this case fib_validate_source
> thinks this is forwarding from lo to lo. So, there is
> a reason your patch fixes the problem, alternative
> is to add oif == LOOPBACK_IFINDEX check:
>
>         dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev) ||
>         oif == LOOPBACK_IFINDEX

Yeah, actually this is my initial fix, but I thought making an
exception here for loopback does not look good therefore dropped
this idea.

>
>> where its nh_scope == RT_SCOPE_HOST?
>
>         The idea is to avoid calling __fib_validate_source,
> right? No need to look into __fib_validate_source. Also,
> I'm not sure how legal is to receive packets on lo without
> skb->dst...
>

That's my point, but David seems not agree. :)

Thanks!
