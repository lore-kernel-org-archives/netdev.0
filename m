From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next 05/19] ixgbe: Add support for UDP-encapsulated tx
 checksum offload
Date: Wed, 2 Sep 2015 10:38:17 -0700
Message-ID: <CALx6S36T4tzB5aq3bbKq4DMEumvC4q2YhGscn19se0mGXGe5cQ@mail.gmail.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1441156443-33381-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<CALx6S34-mUvQyUQNcVC+o+NeUxWEsCG2GS=Eq++eGqoh=kv8kg@mail.gmail.com>
	<F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34305 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbbIBRiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 13:38:18 -0400
Received: by igcpb10 with SMTP id pb10so31180507igc.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 10:38:17 -0700 (PDT)
In-Reply-To: <F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 2, 2015 at 9:46 AM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>> On Sep 1, 2015, at 8:17 PM, Tom Herbert <tom@herbertland.com> wrote:
>>
>> I suspect this is not UDP-encapsulation specific, will it work with
>> TCP/IP/IP, TCP/IP/GRE etc.?
>
> It could do more, but this is what has been tested up to this point.
>
Well, please test the those other encapsulations too! It's nice and
all if they get the benefit, but it's really bad news if these changes
were to screw them up (i.e. you don't want users of the GRE, IPIP to
find out that they're now broken).

>> Isn't there anyway the ixgbe could just be made to NETIF_HW_CSUM? That
>> would be so much more straightforward and support nearly all use cases
>> without needing to jump through all these hoops.
>
> Well, the description says:
>
>  ---
> Note: NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM + NETIF_F_IPV6_CSUM.
> It means that device can fill TCP/UDP-like checksum anywhere in the packets
> whatever headers there might be.
>  ---
>
> The device can't do whatever, wherever. There is always a limit to the offset to the inner headers that can be handled, for instance.
>
If the device does NETIF_F_HW_CSUM then inner/outer headers are
irrelevant at least in the non-GSO case. All the device needs to do is
compute the checksum from start and write the answer at the given
offset. No protocol awareness needed in the device, no need to parse
headers on transmit.

I have the same complaint that ixgbe requires a bunch of driver logic
to offload VXLAN checksum unnecessary instead of just providing
CHECKSUM_COMPLETE which would work with any encapsulation protocol,
require no encapsulation awareness in the device, and should be a much
simpler driver implementation.

So my input to NIC vendors will continue to be they provide general
protocol agnostic solutions and *stop* perpetuating these narrow
protocol specific and unnecessarily complicated solutions. If you
don't believe me, see the similar longstanding comments in skbuff.h
about NIC capabilities and checksums and what choices vendors make.

Tom

> --
> Mark Rustad, Networking Division, Intel Corporation
>
