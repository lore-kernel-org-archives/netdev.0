From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/2] fib: introduce fib notification
 infrastructure
Date: Tue, 6 Sep 2016 17:49:39 +0200
Message-ID: <20160906154939.GD1972@nanopsycho>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <1473163300-2045-2-git-send-email-jiri@resnulli.us>
 <6a4d9ba6-7113-b487-eb52-ca1f703d13f6@cumulusnetworks.com>
 <20160906144408.GH1692@nanopsycho>
 <d75d345a-0571-81cb-63c8-f06ada45f252@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35451 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932874AbcIFPtr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 11:49:47 -0400
Received: by mail-wm0-f67.google.com with SMTP id a6so8000784wmc.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 08:49:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d75d345a-0571-81cb-63c8-f06ada45f252@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 06, 2016 at 05:11:11PM CEST, dsa@cumulusnetworks.com wrote:
>On 9/6/16 8:44 AM, Jiri Pirko wrote:
>> Tue, Sep 06, 2016 at 04:32:12PM CEST, dsa@cumulusnetworks.com wrote:
>>> On 9/6/16 6:01 AM, Jiri Pirko wrote:
>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>
>>>> This allows to pass information about added/deleted fib entries to
>>>> whoever is interested. This is done in a very similar way as devinet
>>>> notifies address additions/removals.
>>>>
>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>> ---
>>>>  include/net/ip_fib.h | 19 +++++++++++++++++++
>>>>  net/ipv4/fib_trie.c  | 43 +++++++++++++++++++++++++++++++++++++++++++
>>>>  2 files changed, 62 insertions(+)
>>>>
>>>
>>> The notifier infrastructure should be generalized for use with IPv4 and IPv6. While the data will be family based, the infra can be generic.
>>>
>> 
>> Yeah, that I thought about as well. Thing is, ipv6 notifier has to be
>> atomic. That is the reason we have:
>> inetaddr_chain and register_inetaddr_notifier (blocking notifier)
>> inet6addr_chain and register_inet6addr_notifier (atomic notifier)
>> 
>
>Why is IPv6 atomic? Looking at code paths for adding addresses seems like all of the locks are dropped before the notifier is called and adding and deleting ipv6 addresses does not show a hit with this WARN_ON:


Maybe historic reasons. Would be good to unite the notifiers then. I'll
look at it.


>
>
>diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
>index bfa941fc1165..4f9f964d95e5 100644
>--- a/net/ipv6/addrconf_core.c
>+++ b/net/ipv6/addrconf_core.c
>@@ -103,6 +103,7 @@ EXPORT_SYMBOL(unregister_inet6addr_notifier);
>
> int inet6addr_notifier_call_chain(unsigned long val, void *v)
> {
>+WARN_ON(in_atomic());
>        return atomic_notifier_call_chain(&inet6addr_chain, val, v);
> }
> EXPORT_SYMBOL(inet6addr_notifier_call_chain);
