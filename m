From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net v2 2/3] tunnels: Don't apply GRO to multiple layers of encapsulation.
Date: Mon, 28 Mar 2016 10:37:39 -0700
Message-ID: <CAKgT0UdiqecAMihYP=gfmBYp7-Ko54EkO23=GWg4jEAuHocKJQ@mail.gmail.com>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
	<1458405122-12565-3-git-send-email-jesse@kernel.org>
	<CALx6S36Zw+ky+u0XHROV1AE21H=EU5=SEoAj7+AskxLw6b0Odg@mail.gmail.com>
	<CAEh+42hbYUMK4WMZYDtzfynd1XFb7OxKkmdPOdT1Z7=n-kw4sA@mail.gmail.com>
	<CALx6S35WiXiKDJL6s_nW4xWNx8M6atZVQYEgb8kO5ty2WhjFyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35749 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbcC1Rhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 13:37:40 -0400
Received: by mail-io0-f175.google.com with SMTP id g185so28962799ioa.2
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 10:37:40 -0700 (PDT)
In-Reply-To: <CALx6S35WiXiKDJL6s_nW4xWNx8M6atZVQYEgb8kO5ty2WhjFyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 9:31 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Sun, Mar 27, 2016 at 9:38 PM, Jesse Gross <jesse@kernel.org> wrote:
>> On Sat, Mar 26, 2016 at 12:41 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Sat, Mar 19, 2016 at 9:32 AM, Jesse Gross <jesse@kernel.org> wrote:
>>>> When drivers express support for TSO of encapsulated packets, they
>>>> only mean that they can do it for one layer of encapsulation.
>>>> Supporting additional levels would mean updating, at a minimum,
>>>> more IP length fields and they are unaware of this.
>>>>
>>> This patch completely breaks GRO for FOU and GUE.
>>>
>>>> No encapsulation device expresses support for handling offloaded
>>>> encapsulated packets, so we won't generate these types of frames
>>>> in the transmit path. However, GRO doesn't have a check for
>>>> multiple levels of encapsulation and will attempt to build them.
>>>>
>>>> UDP tunnel GRO actually does prevent this situation but it only
>>>> handles multiple UDP tunnels stacked on top of each other. This
>>>> generalizes that solution to prevent any kind of tunnel stacking
>>>> that would cause problems.
>>>>
>>> GUE and FOU regularly create packets that will be both GSO UDP tunnels
>>> and IPIP, SIT, GRE, etc. This is by design. There should be no
>>> ambiguity in the drivers as to what this means. For instance, if
>>> SKB_GSO_UDP_TUNNEL and SKB_GSO_GRE are set that is GRE/UDP packet, a
>>> driver can use ndo_features_check to validate.
>>>
>>> So multiple levels of encapsulation with GRO is perfectly valid and I
>>> would suggest to simply revert this patch. The one potential issue we
>>> could have is the potential for GRO to construct a packet which is a
>>> UDP-encapsulation inside another encapsulation, like UDP-encap in GRE.
>>> In this case the GSO flags don't provide enough information to
>>> distinguish say between GRE/UDP (common case) and UDP/GRE (uncommon
>>> case). To make this clear we can set udp_mark in GRE, ipip, and sit
>>> but *not* check for it.
>>
>> Generally speaking, multiple levels of encapsulation offload are not
>> valid. I think this is pretty clear from the fact that none of the
>> encapsulation drivers expose support for encapsulation offloads on
>> transmit and the drivers supporting NETIF_F_GSO_GRE and
>> NETIF_F_GSO_UDP_TUNNEL do not mean they can handle GRE in VXLAN.
>>
>
> Kernel software offload does support this combination just fine.
> Seriously, I've tested that more than a thousand times. This is a few
> HW implementations you're referring to. The limitations of these
> drivers should not dictate how we build the software-- it needs to
> work the other way around.

Jesse does have a point.  Drivers aren't checking for this kind of
thing currently as the transmit side doesn't generate these kind of
frames.  The fact that GRO is makes things a bit more messy as we will
really need to restructure the GSO code in order to handle it.  As far
as drivers testing for it I am pretty certain the i40e isn't.  I would
wonder if we need to add yet another GSO bit to indicate that we
support multiple layers of encapsulation.  I'm pretty sure the only
way we could possibly handle it would be in software since what you
are indicating is a indeterminate number of headers that all require
updates.

>> Asking drivers to assume that this combination of flags means FOU
>> doesn't seem right to me. To the best of my knowledge, no driver uses
>> ndo_feature_check to do validation of multiple tunnel offload flags
>> since the assumption is that the stack will never try to do this.
>> Since FOU is being treated as only a single level of encapsulation, I
>> think it would be better to just advertise it that way on transmit
>> (i.e. only set SKB_GSO_UDP_TUNNEL).
>>
> If it's not FOU it will be something else. Arbitrarily declaring
> multi-levels of encapsulation invalid is simply the wrong direction,
> we should be increasing generality and capabilities of the kernel not
> holding it down with artificial limits. This is why the generic TSO
> work that Alexander and Edward are looking at is so important-- if
> this flies then we can offload any combination of encapsulations with
> out protocol specific information.

The segmentation code isn't designed to handle more than 2 layers of
headers.  Currently we have the pointers for the inner headers and the
outer headers.  If you are talking about adding yet another level we
would need additional pointers in the skbuff to handle them and we
currently don't have them at present.

>> The change that you are suggesting would result in packets generated
>> by GRO that cannot be handled properly on transmit in some cases and
>> would likely end up being dropped or malformed. GRO is just an
>> optimization and correctness must come first so we cannot use it if it
>> might corrupt traffic.
>
> That's (a few) drivers problem. It's no different than if they had
> decided that SKB_GSO_UDP_TUNNEL means vxlan, or they can support GRE
> in IPv4 offload but not GRE in IPv6, or they can only handle headers
> of a certain size, can't handle IPv6 ext. hdrs., etc. As I mentioned,
> the long term solution is to eliminate the GSO_ flags and use a
> generic segmentation offload interface. But in the interim, it is
> *incumbent* on drivers to determine if they can handle a GSO packet
> and the interfaces to do that exist. Restricting the capabilities of
> GRO just to appease those drivers is not right. Breaking existing GRO
> for their benefit is definitely not right.

This isn't about if drivers can handle it.  It is about if the skbuff
can handle it.  The problem as it stands right now is that we start
losing data once we go past 1 level of encapsulation.  We only have
the standard mac_header, network_header, transport_header, and then
the inner set of the same pointers.  If we try to go multiple levels
deep we start losing data.

If we are wanting to start allowing unlimited headers then maybe we
need to start allowing for "partial" GRO to complement the partial GSO
implementation I have.  With that at least we might be able to track
the first and last headers and we could leave the remaining headers
static.  Then when the frame made it to the driver it would know that
the headers in the long list can be replicated and it only has to
update the outer network header and the inner transport header,
otherwise if it doesn't support that it can just chop up the frame in
software and send that out.

- Alex
