From: David Ahern <dsahern@gmail.com>
Subject: Re: routing UAPI mismatch invalid state behavior?
Date: Sun, 15 Oct 2017 19:56:34 -0600
Message-ID: <8510da96-d8dc-8248-166a-d3ce22051a98@gmail.com>
References: <CAOHTApje2ABpRPghhqabD=JkBOzjFjVmc1N67ReDBLHeGGVe1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
To: Alexander Aring <aring@mojatatu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:45874 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751779AbdJPB4g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 21:56:36 -0400
Received: by mail-pf0-f182.google.com with SMTP id d28so14656418pfe.2
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 18:56:36 -0700 (PDT)
In-Reply-To: <CAOHTApje2ABpRPghhqabD=JkBOzjFjVmc1N67ReDBLHeGGVe1Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/17 11:02 AM, Alexander Aring wrote:
> Hi,
> 
> I figure out some problem, easy to reproduce:
> 
> # setup dummy
> $ modprobe dummy
> $ ip link set dummy0 up
> 
> # issue
> $ ip route replace default via 169.254.65.37 dev dummy0
> RTNETLINK answers: Network is unreachable

This fails in fib_check_nh. Basically the lookup of the address fails
making it an invalid gateway.

> 
> so it will forbid me to do that, but:
> 
> $ ip route replace 169.254.65.37 dev dummy0

This succeeds because iproute2 adds NLM_F_CREATE to flags along with
REPLACE:

        if (matches(*argv, "replace") == 0)
                return iproute_modify(RTM_NEWROUTE,
NLM_F_CREATE|NLM_F_REPLACE,
                                      argc-1, argv+1);

but your overall intent here of resolving 169.254.65.37 is the key.

> $ ip route replace default via 169.254.65.37 dev dummy0

The existence of the previous route allows the gateway check in
fib_check_nh to succeed.

> $ ip route del 169.254.65.37 dev dummy0
> 
> allows me to do that. Is there now a invalid state in my routing table
> or is it an expected behavior?

There are no recursive checks to gateway lookups once the routes are
installed. With the way routes and nexthops are currently created doing
so would be very expensive in some setups.
