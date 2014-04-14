From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking send_redirects
Date: Mon, 14 Apr 2014 15:59:27 -0700
Message-ID: <CAM_iQpVoxj3Udve1ByEoDk7NCB_p4KzoqjES3j0_fhwTwHDGYg@mail.gmail.com>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140408.164356.557108616710530006.davem@davemloft.net>
	<CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com>
	<20140408.172343.917107273854891906.davem@davemloft.net>
	<CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com>
	<alpine.LFD.2.11.1404090110500.3310@ja.home.ssi.bg>
	<CAM_iQpXNf9rBCtZ2ipiHr2i2Kk4r0QtewiNC-qW8RzR0ChoWqA@mail.gmail.com>
	<alpine.LFD.2.11.1404091027460.1435@ja.home.ssi.bg>
	<CAM_iQpWrWgOBkGFBRsqMriDoM4Ph=L_dUNti4wKtBydkdbo+Qw@mail.gmail.com>
	<alpine.LFD.2.11.1404131746100.1423@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:58064 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbaDNW71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 18:59:27 -0400
Received: by mail-ob0-f181.google.com with SMTP id gq1so10696obb.40
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 15:59:27 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1404131746100.1423@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 13, 2014 at 7:57 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         It looks like LOOPBACK_IFINDEX is used only for
> flowi4_iif. Users can distinguish input from output route
> lookups by 'ip rule ... iif lo' matching. This trick works
> because the lo interface was never used for input routes.
> This is documented in iproute2/doc/ip-cref.tex, look for
> 'iif NAME' for the ip rules.
>
>         As result, input routes are not expected on loopback.
> Not sure if you can configure your setup in different way.
> We still can solve it by fixing another problem, read below.
>
>         Considering how flowi_iif is matched in fib_rule_match(),
> it is wrong to provide 0 for the flowi4_iif field in
> __fib_validate_source(). By this way, users can not match
> this reverse flow with 'ip rule ... iif lo'. Of course,
> such rules are rarely used.
>
>         There are other places that need to provide
> LOOPBACK_IFINDEX instead of 0:
>
> - include/net/flow.h flowi4_init_output()
> - net/ipv4/ipmr.c reg_vif_xmit(): skb->skb_iif ? : LOOPBACK_IFINDEX;
> - net/ipv4/netfilter/ipt_rpfilter.c rpfilter_mt()
>
>         Simply, flowi4_iif must not contain 0, it does not
> look logical to ignore all ip rules with specified iif.
>
>         So, we can implement such changes:
>
> - all places that provide LOOPBACK_IFINDEX to fib_validate_source()
> should be changed to provide 0 for oif. By this way the
> 'dev->ifindex != oif' check will work for your setup.
>
> - then __fib_validate_source() will use:
>
>         -       fl4.flowi4_iif = oif;
>         +       fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
>
>         What we achieve is:
>
> - correct 'ip rule ... iif lo' matching for rp_filter checks
>
> - fib_validate_source() will not call __fib_validate_source()
> for loopback interface (when rp_filter is 0).
>
>         By this way we do not add extra check in fib_validate_source(),
> it goes in __fib_validate_source. The special semantic for
> 'lo' is coded at the right place, just for flowi4_iif.

Thanks for the details! This makes a lot sense to me. :)

I just cooked 3 patches based on your suggestion, I will give them
some quick tests before sending them out.

Will send them soon with you Cc'ed.

Regards.
