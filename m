From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking send_redirects
Date: Tue, 8 Apr 2014 15:55:12 -0700
Message-ID: <CAM_iQpXNf9rBCtZ2ipiHr2i2Kk4r0QtewiNC-qW8RzR0ChoWqA@mail.gmail.com>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140408.164356.557108616710530006.davem@davemloft.net>
	<CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com>
	<20140408.172343.917107273854891906.davem@davemloft.net>
	<CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com>
	<alpine.LFD.2.11.1404090110500.3310@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:41212 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756372AbaDHWzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 18:55:13 -0400
Received: by mail-ob0-f181.google.com with SMTP id wp4so1766992obc.26
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 15:55:12 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1404090110500.3310@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your reply, David and Julian!

On Tue, Apr 8, 2014 at 3:15 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         Yes, the code will fail if input route is
> tried on loopback device. My first thought was that
> you forgot to 'ip route flush cache' after clearing
> rp_filter.
>

route cache is removed after 3.6, so I don't need to do it?

>> which looks good to me too, since the packet has src addr == dst addr.
>>
>> Which part am I missing?
>
>         What kind of packet is that and why the skb lost its
> output route and now it is trying for input route?
>

Yeah, I just noticed that for normal loopback packets its ->dst
are forced to be kept so that it will not need to lookup route
again on rx. However, in our case, we redirect the packets
from veth0 to lo when src_addr == dst_addr, its ->dst is dropped
after coming out of the network namespace, therefore goes into
the slow path to validate the reverse path and lookup the route.

I think David's point is still valid in this case, __fib_validate_source()
should not reject the packets. So hmm... the only reason I can find is
the following code:

        if (fib_lookup(net, &fl4, &res) == 0) {
                if (res.type == RTN_UNICAST)
                        ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
        }

where its nh_scope == RT_SCOPE_HOST?
