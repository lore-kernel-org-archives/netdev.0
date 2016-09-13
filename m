From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: icmpv6: issue with routing table entries from link local
 addresses
Date: Tue, 13 Sep 2016 04:42:38 +0200
Message-ID: <e2eddc8d-ccd6-682b-265f-55242eef1762@stressinduktion.org>
References: <20160912142732.GI26782@targo.k4n.de>
 <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
 <CACP96tTFX7nyGz6uARYxemvE7-WDxvX7Wj+Jf95PC0Advy7ynw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?Q?Andreas_H=c3=bcbner?= <andreas@k4n.de>,
        netdev <netdev@vger.kernel.org>,
        "d. caratti" <davide.caratti@gmail.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:51061 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750747AbcIMCml (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 22:42:41 -0400
In-Reply-To: <CACP96tTFX7nyGz6uARYxemvE7-WDxvX7Wj+Jf95PC0Advy7ynw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.09.2016 04:03, Sowmini Varadhan wrote:
> On Mon, Sep 12, 2016 at 1:26 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Hello,
>>
>> On 12.09.2016 16:27, Andreas Hübner wrote:
> 
>>>
>>> I have the following setup:
>>>   - 2 directly connected hosts (A+B), both have only link local addresses
>>>     configured (interface on both hosts is eth0)
>            :
>>>       fe80::/64 dev eth1  proto kernel  metric 256
>>>       fe80::/64 dev eth0  proto kernel  metric 256
>            :
>>> The issue I currently have is, that the echo reply that host B should
>>> generate is never sent back to host A. If I change the order of the
>>> routing table entries on host B, everything works fine.
>>> (host A is connected on eth0)
>    :
>> This shouldn't be the case. We certainly carry over the ifindex of the
>> received packet into the routing lookup of the outgoing packet, thus the
>> appropriate rule, with outgoing ifindex should be selected.
> 
> Like Hannes,  I too would first check "is B sending out the echo-resp? on
> which interface?".
> 
> But a couple of unexpected things I noticed in linux: the link-local
> prefix should have a prefixlen of /10 according to
> http://www.iana.org/assignments/ipv6-address-space/ipv6-address-space.xhtml
> but "ip -6 route show"  lists this as a /64..

The link local subnet is still specified to be a /64 as the other parts
of the address must be 0. Legally we probably could blackhole them.
https://tools.ietf.org/html/rfc4291#section-2.5.6

> moreover, even though I cannot use "ip [-6] route add.." to add the
> same prefix multiple times (with different nexthop and/or interface)
> unless I explicitly mark them as ECMP with /sbin/ip, it seems like you
> can create the same onlink prefix on multiple interfaces, but the
> kernel will not treat this as an ECMP group (and sometimes this
> can produce inconsistent results depending on the order of
> route addition, e.g., for ipv4 rp_filter checks). I dont know if some
> variant of  this (latter observation) may be the reason for the behavior
> that  Andreas reports.

iproute sets the NLM_F_EXCL flag. Use ip route prepend ...

We don't have urpf checks for ipv6, those are implemented in netfilter
only. This could very well be a firewall issue or something like that.

Bye,
Hannes
