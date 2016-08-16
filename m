From: Doug Applegate <doug.applegate@gmail.com>
Subject: Re: [PATCH RFC 0/1] xfrm: dst lookup doesn't account for fwmark
Date: Tue, 16 Aug 2016 11:19:28 -0600
Message-ID: <CACwzwmVFUWs9UYZdycwA1EUDBnhctdZTKWwS9RyA1LErMF5cbw@mail.gmail.com>
References: <CACwzwmXfY3rpWfaspveT3JvumhPXYrMCH3TUwM1WNgEFKZ_t4A@mail.gmail.com>
 <20160728052013.GK5710@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34222 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbcHPRT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 13:19:29 -0400
Received: by mail-yw0-f195.google.com with SMTP id j12so3770782ywb.1
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 10:19:29 -0700 (PDT)
In-Reply-To: <20160728052013.GK5710@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shortly I will post an updated patch.

Please ignore the 'onlink' on those routes. It is irrelevant.

The particular use case is load balancing by using fwmark. Consider if
we don't define any routes except load balancing based on fwmarks.
The only requirement is that the traffic must exit the same interface
it comes in on. Therefore you have these firewall rules:

-A PREROUTING -m state --state NEW -i eth0 -j MARK --set-xmark 0x1/0x7e
-A PREROUTING -m state --state NEW -i eth1 -j MARK --set-xmark 0x2/0x7e

# ip rule list
40000: from all fwmark 0x1 lookup 3
40000: from all fwmark 0x2 lookup 4

# ip route list table 3
default via 25.0.0.2 dev eth0
# ip route list table 4
default via 35.0.0.2 dev eth1

outgoing traffic gets the mark restored:
-A OUTPUT -m mark --mark 0x0/0x7e -j CONNMARK --restore-mark --nfmask
0x7e --ctmask 0x7e

Imagine vpn traffic coming in on eth1, therefore the reroute check
before postrouting should specify the outgoing interface as eth1,
however, for vpn traffic the mark isn't taking in account that the
traffic could egress the incorrect interface as shown in the trace I
sent earlier.  Furthermore, I seem to recall, that the transformed
packet (the one encapsulated with the outer ip address) will inherit
the mark from the inner ipsec packet and a second reroute check  is
not performed.

There are a number of ways to work around this bug. However, this
patch addresses this issue and makes it easy to add other flow
information in case we need it down the line.

Thanks!
Doug


On Wed, Jul 27, 2016 at 11:20 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Fri, Jul 22, 2016 at 03:50:30PM -0600, Doug Applegate wrote:
>> I ran into an issue trying to route outgoing ipsec traffic from an
>> ipsec responder hub that uses fwmark to route out a specific
>> interface. The fwmark points to a route table that contains a default
>> route out a specific interface.  The fwmark is applied based on
>> incoming interface of incoming traffic. I noticed that the mark was
>> not being used when doing a route lookup. Is there any reason why this
>> is? If not does this patch look reasonable? I just followed similar
>> logic to how TOS was being used before route-lookup. I've only tested
>> on an earlier kernel (3.14) and it works. Thanks!
>>
>> Here's an example:
>>
>> The ipsec policy is simple, just a tunnel from 192.168.0.0/24 <-->
>> 192.168.1.0/24 the ipsec hub is at 35.0.0.1 but when traffic is being
>> responded too, instead of the expected interface (eth2) we end it out
>> a different interface (eth0)
>>
>> route table:
>> # ip rule list
>> 0: from all lookup local
>> 32766: from all lookup main
>> 32767: from all lookup default
>> 40000: from all fwmark 0x2 lookup 3
>> 40000: from all fwmark 0x4 lookup 4
>> 50000: from all lookup 3
>>
>> # ip route
>> 25.0.0.0/30 dev eth0  src 25.0.0.1
>> 35.0.0.0/30 dev eth2  src 35.0.0.1
>> 192.168.1.0/24 dev lan1  src 192.168.1.1
>>
>> # ip route list table 4
>> default via 35.0.0.2 dev eth2 onlink
>> # ip route list table 3
>> default via 25.0.0.2 dev eth0 onlink
>
> Can you provide some more information about your usecase?
> Mapping between interfaces and IP addresses, policies
> and states would be good.
>
> Btw. why do you need to insert the routes as 'onlink'?
> This disables some checks if this route is valid.
