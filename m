From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking send_redirects
Date: Tue, 8 Apr 2014 14:50:09 -0700
Message-ID: <CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140408.164356.557108616710530006.davem@davemloft.net>
	<CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com>
	<20140408.172343.917107273854891906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:46770 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756980AbaDHVuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 17:50:10 -0400
Received: by mail-ob0-f181.google.com with SMTP id wp4so1765760obc.12
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 14:50:09 -0700 (PDT)
In-Reply-To: <20140408.172343.917107273854891906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 8, 2014 at 2:23 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 8 Apr 2014 14:17:08 -0700
>
>> We are not supposed even to execute __fib_validate_source() in such
>> case, are we? :)
>
> Yes, we used to, every time we'd make a routing cache entry, we'd
> execute this code.
>
> Check fib_validate_source() from before the routing cache removal if
> you don't believe me.
>
> That check you are editing was added by myself as an optimization
> that was necessary after the routing cache removal since this
> function performs two FIB table lookups every time it is called.

I must miss something here. Looking at the code:

        int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);

        if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
            (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
                *itag = 0;
                return 0;
        }

r == 0 is true in our case since we disable rp_filter manually.
And fib_num_tclassid_users() == 0 by default too.

Therefore, the only thing takes effect is if dev->ifindex == oif.
Given the fact that disabling send_redirects makes the problem
disappear, dev->ifindex != oif must be false, otherwise it doesn't
even need to check TX_REDIRECTS.

The rx interface is loopback, so skb->dev == lo, and the oif we pass
here must be LOOPBACK_IFINDEX, therefore the following code
in ip_route_input_slow():

        if (res.type == RTN_LOCAL) {
                err = fib_validate_source(skb, saddr, daddr, tos,
                                          LOOPBACK_IFINDEX,
                                          dev, in_dev, &itag);
                if (err < 0)
                        goto martian_source_keep_err;
                goto local_input;
        }

which looks good to me too, since the packet has src addr == dst addr.

Which part am I missing?

Thanks!
