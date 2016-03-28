From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net v2 2/3] tunnels: Don't apply GRO to multiple layers of encapsulation.
Date: Sun, 27 Mar 2016 21:38:34 -0700
Message-ID: <CAEh+42hbYUMK4WMZYDtzfynd1XFb7OxKkmdPOdT1Z7=n-kw4sA@mail.gmail.com>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
 <1458405122-12565-3-git-send-email-jesse@kernel.org> <CALx6S36Zw+ky+u0XHROV1AE21H=EU5=SEoAj7+AskxLw6b0Odg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:43616 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512AbcC1Eiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 00:38:52 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D362E20259
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 04:38:50 +0000 (UTC)
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 86BFD2024C
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 04:38:49 +0000 (UTC)
Received: by mail-qg0-f50.google.com with SMTP id u110so100878773qge.3
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 21:38:49 -0700 (PDT)
In-Reply-To: <CALx6S36Zw+ky+u0XHROV1AE21H=EU5=SEoAj7+AskxLw6b0Odg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 26, 2016 at 12:41 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Sat, Mar 19, 2016 at 9:32 AM, Jesse Gross <jesse@kernel.org> wrote:
>> When drivers express support for TSO of encapsulated packets, they
>> only mean that they can do it for one layer of encapsulation.
>> Supporting additional levels would mean updating, at a minimum,
>> more IP length fields and they are unaware of this.
>>
> This patch completely breaks GRO for FOU and GUE.
>
>> No encapsulation device expresses support for handling offloaded
>> encapsulated packets, so we won't generate these types of frames
>> in the transmit path. However, GRO doesn't have a check for
>> multiple levels of encapsulation and will attempt to build them.
>>
>> UDP tunnel GRO actually does prevent this situation but it only
>> handles multiple UDP tunnels stacked on top of each other. This
>> generalizes that solution to prevent any kind of tunnel stacking
>> that would cause problems.
>>
> GUE and FOU regularly create packets that will be both GSO UDP tunnels
> and IPIP, SIT, GRE, etc. This is by design. There should be no
> ambiguity in the drivers as to what this means. For instance, if
> SKB_GSO_UDP_TUNNEL and SKB_GSO_GRE are set that is GRE/UDP packet, a
> driver can use ndo_features_check to validate.
>
> So multiple levels of encapsulation with GRO is perfectly valid and I
> would suggest to simply revert this patch. The one potential issue we
> could have is the potential for GRO to construct a packet which is a
> UDP-encapsulation inside another encapsulation, like UDP-encap in GRE.
> In this case the GSO flags don't provide enough information to
> distinguish say between GRE/UDP (common case) and UDP/GRE (uncommon
> case). To make this clear we can set udp_mark in GRE, ipip, and sit
> but *not* check for it.

Generally speaking, multiple levels of encapsulation offload are not
valid. I think this is pretty clear from the fact that none of the
encapsulation drivers expose support for encapsulation offloads on
transmit and the drivers supporting NETIF_F_GSO_GRE and
NETIF_F_GSO_UDP_TUNNEL do not mean they can handle GRE in VXLAN.

Asking drivers to assume that this combination of flags means FOU
doesn't seem right to me. To the best of my knowledge, no driver uses
ndo_feature_check to do validation of multiple tunnel offload flags
since the assumption is that the stack will never try to do this.
Since FOU is being treated as only a single level of encapsulation, I
think it would be better to just advertise it that way on transmit
(i.e. only set SKB_GSO_UDP_TUNNEL).

The change that you are suggesting would result in packets generated
by GRO that cannot be handled properly on transmit in some cases and
would likely end up being dropped or malformed. GRO is just an
optimization and correctness must come first so we cannot use it if it
might corrupt traffic.
