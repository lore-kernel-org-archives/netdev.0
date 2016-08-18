From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 17 Aug 2016 18:06:42 -0700
Message-ID: <CAKgT0Ud6NJdVTQM0AiHVbhZTko9fnzyvrZ1juGRPrRFGC-5O-g@mail.gmail.com>
References: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com>
 <1471470587-24813-3-git-send-email-dsa@cumulusnetworks.com>
 <CAKgT0UeU+-jxnBr3H5P6ADzMH2Xv29atDrCyzngcOOEyqObUDg@mail.gmail.com> <15a6625f-e969-0c9d-e1fc-72d9361ebb32@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Simon Horman <simon.horman@netronome.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
	Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	olivier.dugeon@orange.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34920 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183AbcHRBGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 21:06:44 -0400
Received: by mail-io0-f193.google.com with SMTP id q83so1191516iod.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 18:06:43 -0700 (PDT)
In-Reply-To: <15a6625f-e969-0c9d-e1fc-72d9361ebb32@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 4:23 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 8/17/16 5:16 PM, Alexander Duyck wrote:
>>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>>> index 1ecbd7715f6d..6d78f162a88b 100644
>>> --- a/net/openvswitch/actions.c
>>> +++ b/net/openvswitch/actions.c
>>> @@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>>>                 skb->mac_len);
>>>         skb_reset_mac_header(skb);
>>>
>>> +       /* for GSO: set MPLS as network header and encapsulated protocol
>>> +        * header as inner network header
>>> +        */
>>> +       skb_set_network_header(skb, skb->mac_len);
>>> +       skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
>>> +
>>>         new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>>>         *new_mpls_lse = mpls->mpls_lse;
>>>
>>
>> So the one question I would have about this is how attached are you to
>> using the network_header to record the offset for the MPLS header?  I
>> ask because I think from a hardware offloading perspective it would
>> make it much easier if instead you used the inner_mac_header to
>> represent the offset for the MPLS header.  This way device drivers
>> could just skip over it like a VLAN and just use network and transport
>> header values like they would otherwise.
>>
>
> Where does the network_header relate to if I change the marker to inner_mac_header? Would it be skipped?

No, the network header would still be the network header.

> skb->protocol is set to MPLS.
> mac_header points to ethernet address
> network_header points to ???

The network_header would point to the IP header like it would be for a
non-MPLS frame.

> inner protocol is set to what is encapsulated (e.g., ipv4 or ipv6)

I am okay with this, but wonder if we actually need it.  Do you know
of any protocols other than IPv4 or IPv6 that can be carried over MPLS
and would expect to be offloaded?  If not we may be able to just get
away with recording the network header offset and then using the first
nibble of the network header to determine the IP version since the
value should be 4 or 6 for the two types we are offloading.

> inner_mac_header points to start of mpls label.

So this is what I would expect.

> inner_network points to start of network header.

The problem is that using inner_network_header to point to the network
header will require me to fork the path pretty significantly for most
of the Intel devices that would want to do MPLS GSO.  The assumption
most drivers make is that if we are offloading things then
network_header and inner_network_header will point to either IPv4 or
IPv6 headers.  Introducing MPLS as the network_header with IPv4 or
IPv6 as the inner_network_header throws a kink in the works because we
currently ignore inner_network_header for the devices that are doing
UDP or GRE tunnel GSO via GSO_PARTIAL with TSO_MANGLEID.

> Is that sufficient for h/w drivers?

I think of this as working like how we handle it for IP over IP
tunnels.  In that case we are at L3 so the inner_network_header field
is populated, but the transport header stays the same.  In the case of
MPLS it isn't really L3 it is more of an L2.5 so my preference would
be to treat it like it is an L2 tunnel or VLAN and just overwrite the
inner_mac_header with the MPLS header offset, and leave the network
and transport headers untouched.

One other bonus that also occurred to me is that you might be able to
get away with doing MPLS offloads for MPLS over IP or GRE tunnels.  I
hadn't realized that MPLS inside of these tunnels was a thing, I had
just noticed it while looking over how the IP-in-IP tunnels are all
being handled.  However if you move the header tracking to
inner_mac_header, and can avoid using skb->inner_protocol by instead
using the first nibble of the network_header value then you could
probably support segmenting those types of tunnels in hardware.

- Alex
