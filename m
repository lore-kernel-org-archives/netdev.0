From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy choice
Date: Tue, 14 Mar 2017 19:30:47 -0700
Message-ID: <CALx6S34UWgOcKKvnq32FKLnXpXDitDR+t1s8GmhMBnNAQHLTSw@mail.gmail.com>
References: <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com>
 <20170314.114837.619141079617104809.davem@davemloft.net> <20170314132506.6233b1e7@xeon-e3>
 <20170314.172424.1077779028779735713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jakub Sitnicki <jkbs@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Peter Christensen <pch@ordbogen.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36351 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750852AbdCOCat (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 22:30:49 -0400
Received: by mail-qk0-f196.google.com with SMTP id n141so539139qke.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 19:30:48 -0700 (PDT)
In-Reply-To: <20170314.172424.1077779028779735713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 5:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 14 Mar 2017 13:25:06 -0700
>
>> On Tue, 14 Mar 2017 11:48:37 -0700 (PDT)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> Date: Tue, 14 Mar 2017 17:58:46 +0200
>>>
>>> > On 14/03/17 17:55, Stephen Hemminger wrote:
>>> >> On Tue, 14 Mar 2017 17:36:15 +0200
>>> >> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>> >>
>>> >>> This patch adds support for ECMP hash policy choice via a new sysctl
>>> >>> called fib_multipath_hash_policy and also adds support for L4 hashes.
>>> >>> The current values for fib_multipath_hash_policy are:
>>> >>>  0 - layer 3 (default)
>>> >>>  1 - layer 4
>>> >>> If there's an skb hash already set and it matches the chosen policy then it
>>> >>> will be used instead of being calculated (currently only for L4).
>>> >>> In L3 mode we always calculate the hash due to the ICMP error special
>>> >>> case, the flow dissector's field consistentification should handle the
>>> >>> address order thus we can remove the address reversals.
>>> >>>
>>> >>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> >>
>>> >> It is good to see ECMP come back from the grave.
>>> >> Linux used to support it long ago but was abandoned after it was unstable
>>> >> and removed from iproute2 in 2012.
>>> >>
>>> >> The old API was through route attributes which makes more sense than
>>> >> doing it with sysctl. It makes more sense to use netlink instead.
>>> >> Therefore please go back and do something like the old API rather than doing it through
>>> >> sysctl.
>>> >>
>>> >
>>> > That's what my initial version did, but this was discussed during NetConf in Seville
>>> > and it was decided that it's best to make a global sysctl, thus the change.
>>>
>>> Correct, we discussed this, and we all agreed to only have a sysctl for now.
>>
>> Why? If you are going to have private discussions please post the rationale
>> in public.
>
> The idea is that we couldn't come up with an immediate use case, and if one
> came up we could easily add the per-route or per-fib-table attribute.
>
> Most people want the entire system to behave a certain way wrt. ECMP, rather
> than have fine granularity.  For example, the case being discussed here is
> to simply have software's behavior match that of hardware offloads.
>
Agreed, but then why do we even need any complexity here by that
argument? RSS is specifically defined to do 5-tuple hashing for TCP
(and UDP), and 3-tuple. No one has ever complained that doing per flow
RSS for TCP is bad thing AFAIK. We followed that same model for RPS,
RFS, and XPS via state in the connection context. The skb_hash is
often given to us for free, whereas in order to do a 3-tuple we have
to actually do more work and do at least an extra jhash. I suppose the
argument is probably that switches allow this configuration and
somehow we want to have feature parity, but it would be very
interesting to know if anyone is not doing per flow ECMP in real life
and why...

Tom
