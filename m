From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 2/3] tunnels: Don't apply GRO to multiple layers of encapsulation.
Date: Mon, 28 Mar 2016 09:31:51 -0700
Message-ID: <CALx6S35WiXiKDJL6s_nW4xWNx8M6atZVQYEgb8kO5ty2WhjFyQ@mail.gmail.com>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
	<1458405122-12565-3-git-send-email-jesse@kernel.org>
	<CALx6S36Zw+ky+u0XHROV1AE21H=EU5=SEoAj7+AskxLw6b0Odg@mail.gmail.com>
	<CAEh+42hbYUMK4WMZYDtzfynd1XFb7OxKkmdPOdT1Z7=n-kw4sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38710 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbcC1Qbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 12:31:52 -0400
Received: by mail-ig0-f176.google.com with SMTP id a1so21912835igb.1
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 09:31:52 -0700 (PDT)
In-Reply-To: <CAEh+42hbYUMK4WMZYDtzfynd1XFb7OxKkmdPOdT1Z7=n-kw4sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 27, 2016 at 9:38 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Sat, Mar 26, 2016 at 12:41 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Sat, Mar 19, 2016 at 9:32 AM, Jesse Gross <jesse@kernel.org> wrote:
>>> When drivers express support for TSO of encapsulated packets, they
>>> only mean that they can do it for one layer of encapsulation.
>>> Supporting additional levels would mean updating, at a minimum,
>>> more IP length fields and they are unaware of this.
>>>
>> This patch completely breaks GRO for FOU and GUE.
>>
>>> No encapsulation device expresses support for handling offloaded
>>> encapsulated packets, so we won't generate these types of frames
>>> in the transmit path. However, GRO doesn't have a check for
>>> multiple levels of encapsulation and will attempt to build them.
>>>
>>> UDP tunnel GRO actually does prevent this situation but it only
>>> handles multiple UDP tunnels stacked on top of each other. This
>>> generalizes that solution to prevent any kind of tunnel stacking
>>> that would cause problems.
>>>
>> GUE and FOU regularly create packets that will be both GSO UDP tunnels
>> and IPIP, SIT, GRE, etc. This is by design. There should be no
>> ambiguity in the drivers as to what this means. For instance, if
>> SKB_GSO_UDP_TUNNEL and SKB_GSO_GRE are set that is GRE/UDP packet, a
>> driver can use ndo_features_check to validate.
>>
>> So multiple levels of encapsulation with GRO is perfectly valid and I
>> would suggest to simply revert this patch. The one potential issue we
>> could have is the potential for GRO to construct a packet which is a
>> UDP-encapsulation inside another encapsulation, like UDP-encap in GRE.
>> In this case the GSO flags don't provide enough information to
>> distinguish say between GRE/UDP (common case) and UDP/GRE (uncommon
>> case). To make this clear we can set udp_mark in GRE, ipip, and sit
>> but *not* check for it.
>
> Generally speaking, multiple levels of encapsulation offload are not
> valid. I think this is pretty clear from the fact that none of the
> encapsulation drivers expose support for encapsulation offloads on
> transmit and the drivers supporting NETIF_F_GSO_GRE and
> NETIF_F_GSO_UDP_TUNNEL do not mean they can handle GRE in VXLAN.
>

Kernel software offload does support this combination just fine.
Seriously, I've tested that more than a thousand times. This is a few
HW implementations you're referring to. The limitations of these
drivers should not dictate how we build the software-- it needs to
work the other way around.

> Asking drivers to assume that this combination of flags means FOU
> doesn't seem right to me. To the best of my knowledge, no driver uses
> ndo_feature_check to do validation of multiple tunnel offload flags
> since the assumption is that the stack will never try to do this.
> Since FOU is being treated as only a single level of encapsulation, I
> think it would be better to just advertise it that way on transmit
> (i.e. only set SKB_GSO_UDP_TUNNEL).
>
If it's not FOU it will be something else. Arbitrarily declaring
multi-levels of encapsulation invalid is simply the wrong direction,
we should be increasing generality and capabilities of the kernel not
holding it down with artificial limits. This is why the generic TSO
work that Alexander and Edward are looking at is so important-- if
this flies then we can offload any combination of encapsulations with
out protocol specific information.

> The change that you are suggesting would result in packets generated
> by GRO that cannot be handled properly on transmit in some cases and
> would likely end up being dropped or malformed. GRO is just an
> optimization and correctness must come first so we cannot use it if it
> might corrupt traffic.

That's (a few) drivers problem. It's no different than if they had
decided that SKB_GSO_UDP_TUNNEL means vxlan, or they can support GRE
in IPv4 offload but not GRE in IPv6, or they can only handle headers
of a certain size, can't handle IPv6 ext. hdrs., etc. As I mentioned,
the long term solution is to eliminate the GSO_ flags and use a
generic segmentation offload interface. But in the interim, it is
*incumbent* on drivers to determine if they can handle a GSO packet
and the interfaces to do that exist. Restricting the capabilities of
GRO just to appease those drivers is not right. Breaking existing GRO
for their benefit is definitely not right.

Tom
