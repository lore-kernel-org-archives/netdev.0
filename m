From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Mon, 29 Sep 2014 18:59:07 -0700
Message-ID: <CA+mtBx8Yti0TPdRJTVN86FsP-JvvArcof0PTMcPSCqnHj3WYcA@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	<CAEP_g=-bGgu8QqtvcEDj=txbmvoQgKtcJxrmzX3DR7xB05c0RQ@mail.gmail.com>
	<CA+mtBx-MdxNrmE82Cqut_T8WuzoOVivPmWKjC0pT8iSrGxWBQg@mail.gmail.com>
	<CAEP_g=9gEhR3UKNe9aVJq8Prmg3awm6fDYHkZy_CumHKFkNNuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <gerlitz.or@gmail.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:46735 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbaI3B7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 21:59:08 -0400
Received: by mail-ig0-f171.google.com with SMTP id h3so3953071igd.4
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 18:59:07 -0700 (PDT)
In-Reply-To: <CAEP_g=9gEhR3UKNe9aVJq8Prmg3awm6fDYHkZy_CumHKFkNNuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 5:33 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Sep 29, 2014 at 1:47 PM, Tom Herbert <therbert@google.com> wrote:
>> On Mon, Sep 29, 2014 at 1:13 PM, Jesse Gross <jesse@nicira.com> wrote:
>>> On Sun, Sep 28, 2014 at 8:50 PM, Tom Herbert <therbert@google.com> wrote:
>>>> Add ndo_gso_check which a device can define to indicate whether is
>>>> is capable of doing GSO on a packet. This funciton would be called from
>>>> the stack to determine whether software GSO is needed to be done. A
>>>> driver should populate this function if it advertises GSO types for
>>>> which there are combinations that it wouldn't be able to handle. For
>>>> instance a device that performs UDP tunneling might only implement
>>>> support for transparent Ethernet bridging type of inner packets
>>>> or might have limitations on lengths of inner headers.
>>>>
>>>> Signed-off-by: Tom Herbert <therbert@google.com>
>>>
>>> Offloads that might have limitations extend beyond GSO - checksum is
>>> another possibility that could need something like a length check.
>>>
>> There are several examples of drivers that advertise checksum offload
>> but then in TX path decide that they can't do it for various reasons--
>> in this case they need to do software checksum calculation themselves.
>> Applying this model to GSO, that is drivers do software GSO when they
>> need to punt on packet, seems pretty hard to me, but maybe someone can
>> look at it.
>
> Yes, I definitely think that it's easier to have GSO done in the
> stack. I agree with you that exposing various capabilities,
> limitations, etc. for different features will get messy very quickly,
> so I guess this model makes sense for now.
>
>>> In addition, while I would also like to be optimistic about the
>>> capabilities of existing NICs it's unlikely that any of them that are
>>> advertising SKB_GSO_UDP_TUNNEL can actually do it with full
>>> generality. So unless we can get the driver writers to chime in about
>>> their capabilities (maybe we can, there's only a handful of them right
>>> now), we probably need to provide a more conservative implementation
>>> for those drivers. I guess I would probably do length equal to VXLAN
>>> and perhaps containing Ethernet as a balance between the most
>>> conservative and the most optimistic.
>>
>> Checking header length in ndo_gso_check would be trivial.
>
> I agree - I just think that we need to provide some implementations in
> existing drivers to do this. Otherwise, as we introduce new protocols
> they will probably be broken in some situations.

A large part of the problem is that potential driver interfaces
(around GSO, checksum) are not clearly specified and especially with
encapsulation the meanings may not be intuitively obvious. For
instance, there's not a single comment in skbuff.h about what any of
the GSO constants mean. I think this is something that we should
address!
