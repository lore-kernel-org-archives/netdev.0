From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/7] gue: Remote checksum offload
Date: Mon, 3 Nov 2014 16:59:23 -0800
Message-ID: <CA+mtBx91Q6T1vxr9V5-RM_WWK_yTW=q=0tgT7+VnDCzLQpmztQ@mail.gmail.com>
References: <1414882683-25484-1-git-send-email-therbert@google.com>
	<CAEP_g=88Q155PxTm9qbNVuxevqDneH3bed0nRfw1nKnZEKvMfQ@mail.gmail.com>
	<CA+mtBx-t2a80VhYypH8d0pjWh7FqT8GRGZt1F=o23GC3BZm-sA@mail.gmail.com>
	<CAEP_g=-rgL1D3kEQaCCmgArsVZQ0D=-JxDjoyZut3iykASYjNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:42802 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbaKDA7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 19:59:24 -0500
Received: by mail-ig0-f172.google.com with SMTP id a13so5784999igq.11
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 16:59:23 -0800 (PST)
In-Reply-To: <CAEP_g=-rgL1D3kEQaCCmgArsVZQ0D=-JxDjoyZut3iykASYjNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 3, 2014 at 4:19 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Nov 3, 2014 at 2:39 PM, Tom Herbert <therbert@google.com> wrote:
>> On Mon, Nov 3, 2014 at 1:26 PM, Jesse Gross <jesse@nicira.com> wrote:
>>> On Sat, Nov 1, 2014 at 3:57 PM, Tom Herbert <therbert@google.com> wrote:
>>>> This patch set implements remote checksum offload for
>>>> GUE, which is a mechanism that provides checksum offload of
>>>> encapsulated packets using rudimentary offload capabilities found in
>>>> most Network Interface Card (NIC) devices. The outer header checksum
>>>> for UDP is enabled in packets and, with some additional meta
>>>> information in the GUE header, a receiver is able to deduce the
>>>> checksum to be set for an inner encapsulated packet. Effectively this
>>>> offloads the computation of the inner checksum. Enabling the outer
>>>> checksum in encapsulation has the additional advantage that it covers
>>>> more of the packet than the inner checksum including the encapsulation
>>>> headers.
>>>
>>> Tom, I have a pretty hard time squaring this with your previous
>>> comments on hardware offload. This looks almost identical to a
>>> protocol-specific hardware offload to me in terms of the implications
>>> on the stack. It actually is more invasive and less likely to scale
>>> across protocols, so the relative cost/benefit doesn't really add up
>>> in my mind.
>>
>> With this patch and checksum-unnecessary conversion we can provide
>> checksum offload for encapsulation on millions of already deployed
>> NICs without any HW or FW change.  Why do you think this is not a good
>> cost/benefit tradeoff?
>
> I just don't see how this is consistent with your previously stated
> goal of keeping protocol-specific offload code out of the core stack.
> Can you explain how this is different?

I think my request was more to avoid putting protocol-specific HW
offload code in the core stack when existing mechanisms could be used.
For instance, ntuple filtering is a more generic interface to tell a
device about special processing for a UDP port than adding an port
registration mechanism that needs to account for each possible
encapsulation protocol.

In these patches we do modify __skb_udp_tunnel_segment which I assume
is what you're referring to in touching the core stack. There are two
parts to this: 1) Allowing checksum offload of outer UDP header is
applicable to any UDP encapsulation protocol 2) When doing remote
checksum we need to avoid touching the inner checksum.  The latter is
indicated by SKB_GSO_TUNNEL_REMCSUM being set by the encapsulation
layer. As I mention in the I-D, remote checksum offload can be
implemented by any encapsulation protocol that supports some
reasonable extension (for instance, this is probably something that
could be implemented in geneve). SKB_GSO_TUNNEL_REMCSUM is a generic
interface by that definition.

But, if you really have a strong objection, I suppose we can start
using at gso_segment in udp_offloads and put the remote checksum
offload processing for GSO in a GUE specific segment function.

Thanks,
Tom
