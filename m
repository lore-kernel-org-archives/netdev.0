From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Thu, 22 Jan 2015 08:24:15 -0800
Message-ID: <CA+mtBx9pnkJBVftqFTK6fcd-toAxsJrvB=drTxWQs_=5s9C0+A@mail.gmail.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
	<CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com>
	<CALnjE+rSXpPftiG4Vw3azkN2s2-Ey6ZcZr9Bv422pOdwrvU=tw@mail.gmail.com>
	<CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com>
	<CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com>
	<CA+mtBx-v5dvX-OPGeWJb6uwQGhJ5T6iewD83xJGqXb+Ggf+LQw@mail.gmail.com>
	<CAEP_g=-3GXJfawPb4jevkZhqmzTttsO1Rv_2J6GwpG=PR_a-0g@mail.gmail.com>
	<CA+mtBx9B5aS9Jv6tpUJpmBkvQFnUqjcxcgTjbBHee8K0f1C9KQ@mail.gmail.com>
	<CAEP_g=_B5xTcfONUP4PTw91PdJKx_cN_+Qdd4F6300aXVyzLZg@mail.gmail.com>
	<54C03A57.4080002@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Vincent JARDIN <vincent.jardin@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:40050 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283AbbAVQYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 11:24:16 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so1382397igj.4
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 08:24:15 -0800 (PST)
In-Reply-To: <54C03A57.4080002@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 3:46 PM, Vincent JARDIN
<vincent.jardin@6wind.com> wrote:
> Jesse, Tom,
>
> On 21/01/2015 23:14, Jesse Gross wrote:
>>>
>>> I'm not going to try to draw conclusions from data which is obviously
>>> >biased and incomplete. If you want to move forward on this, then just
>>> >provide network interface for STT so we can independently run our own
>>> >comparisons against other encapsulations like we've been doing all
>>> >along.
>>
>> You have the source code, so you are totally free to run whatever
>> tests you like to draw your own conclusions. Personally, I find a more
>> than doubling of performance in the environments that I have seen
>> compelling. Your mileage may vary.
>
>
> +1 for STT in the kernel:
>   - whatever the performances, it is needed because it happened to be used.

Vincent, it's not that simple. This is not just another case of an
encapsulation protocol that we can easily ignore and filter because it
hides behind a UDP port or even a new protocol number. This is adding
a new definition to *the* most critical protocol on the planet. I
don't see how this anyone can claim this doesn't violate a whole bunch
of long standing RFCs and break a whole bunch of baked in assumptions
we make about TCP (IP protocol number 6).

For example, TCP MUST have congestion avoidance as per RFC2581:

"The slow start and congestion avoidance algorithms MUST be used by a
TCP sender to control the amount of outstanding data being injected
into the network."

But from STT draft:

"STT segments are transmitted as IP datagrams using the TCP protocol
number (6)."-- that makes this a TCP sender.

"STT does not provide any sort of congestion control."-- that puts STT
in clear violation of RFC2581.

Congestion avoidance for TCP is not just a nice to have, it's not
optional, it's not just best effort like UDP is. There is no provision
for reusing the TCP protocol number and claiming to be exempt from
standards compliance because it's now a different protocol. We build
whole data centers around these principles, and in fact the very
operation of the Internet depends on them. For instance, if we allow
this into the kernel and this becomes available on billions of
devices, what assurances do we have that people won't start abusing
this because they find congestion avoidance annoying and this a
convenient way to bypass it?

STT is undoubtedly a creative and unique solution I'll give you that,
but the potential repercussions of allowing this to be widely deployed
are profound. IMO this needs to be fully explored before it can ever
be allowed in the kernel. If there has already been discussion on this
please forward a pointer (I didn't find anything in the IETF mailing
list archives other than the draft posting announcements), but at the
minimum these patches warrant a lot of scrutiny.

Thanks,
Tom

> If the patch can be optimized, someone will do and provide the related
> patches. The patch from Pravin is ok but...
>
>   - ...I agree with Tom, a netdevice is a must have to ack't this patch.
> Such feature should not be added into openvswitch without its counter-part
> netdevice.
>
> thank you,
>   Vincent
