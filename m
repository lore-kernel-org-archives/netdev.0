From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] gro: Allow tunnel stacking in the case of FOU/GUE
Date: Mon, 28 Mar 2016 20:27:07 -0700
Message-ID: <CAKgT0UeszLNiv=hjeD50pHRB7rgT7qWzbvVAj690jkepVQC7Xg@mail.gmail.com>
References: <20160328235613.26269.26291.stgit@localhost.localdomain>
	<CALx6S3624MH3cKF1zPUvvr1saGAwhTUb6DC6tZcrFYKqRMCozA@mail.gmail.com>
	<CAEh+42g2AudOVigy9udEsDz-K1RrG_0GJyYYrMoN5xNUHdJyfg@mail.gmail.com>
	<CALx6S34PLWEMVM3t8jEnj5S4GH+XbCuOdm0aJD_ijPVqoy9ueQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:35159 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbcC2D1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 23:27:08 -0400
Received: by mail-ig0-f176.google.com with SMTP id cl4so66829406igb.0
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 20:27:07 -0700 (PDT)
In-Reply-To: <CALx6S34PLWEMVM3t8jEnj5S4GH+XbCuOdm0aJD_ijPVqoy9ueQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 8:17 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Mar 28, 2016 at 6:54 PM, Jesse Gross <jesse@kernel.org> wrote:
>> On Mon, Mar 28, 2016 at 6:24 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Mon, Mar 28, 2016 at 4:58 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>> This patch should fix the issues seen with a recent fix to prevent
>>>> tunnel-in-tunnel frames from being generated with GRO.  The fix itself is
>>>> correct for now as long as we do not add any devices that support
>>>> NETIF_F_GSO_GRE_CSUM.  When such a device is added it could have the
>>>> potential to mess things up due to the fact that the outer transport header
>>>> points to the outer UDP header and not the GRE header as would be expected.
>>>>
>>>> Fixes: fac8e0f579695 ("tunnels: Don't apply GRO to multiple layers of encapsulation.")
>>>
>>> This could only fix FOU/GUE. It is very possible someone else could
>>> happily be doing some other layered encapsulation and never had a
>>> problem before, so the decision to start enforcing only a single layer
>>> of encapsulation for GRO would still break them. I still think we
>>> should revert the patch, and for next version fixes things to that any
>>> combination/nesting of encapsulation is supported, and if there are
>>> exceptions to that support they need be clearly documented.
>>
>> It was pointed out to me that prior to my patch, it was also possible
>> to remotely cause a stack overflow by filling up a packet with tunnel
>> headers and letting GRO descend through them over and over again.
>>
> Then the fix would be set set a reasonable limit on the number of
> encapsulation levels.
>
>> Tom, I'm sorry that you don't like how I fixed this issue but there
>> really, truly is a bug here. I gave you a specific example to be clear
>> but that doesn't mean that is the only case. I am aware that the bug
>> is not encountered in all situations and that the fix removes an
>> optimization in some of those but I think that ensuring correct
>> behavior must come first.
>
> The example you gave results in packet loss, this is not
> incorrectness. Actually reproduce a real issue that leads to
> incorrectness and then we can talk about a solution.

Tom,

Just take a look in the __skb_udp_tunnel_segment or gre_gso_segment
code.  Then tell me how we are supposed to deal with the fact that the
GSO code expects skb_inner_network_offset() to be valid.  If you have
more than an inner and an outer network header we cannot.  So we
cannot put GRE in UDP, or UDP in GRE if there is a network header
between them.  The FOU/GUE code gets around this because in the IPIP
and SIT cases you are adding an L4 header between two L3 headers.  The
GRE case works because you essentially convert the GRE header into a
tunnel header like VXLAN or GENEVE and we just overwrite the outer
transport header offset.

What it comes down to is that we can only support 2 network headers
per frame.  One for the inner and one for the outer.  That is why we
can have an exception for GUE as it only has 2 network headers.  If we
had multiple levels of UDP, or GRE, or 2 levels of network headers
either before or after either UDP or GRE we cannot support
segmentation because the code will blow up and generate a malformed
frame.

- Alex
