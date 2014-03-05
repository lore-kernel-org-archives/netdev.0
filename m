From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net-gre-gro: Fix a bug that breaks the forwarding path
Date: Tue, 4 Mar 2014 16:50:53 -0800
Message-ID: <CA+mtBx9i1tOTzgjCfoxXjzjkJyFWCoQDYdvQAejWXketUf8VYQ@mail.gmail.com>
References: <1393536377-32243-1-git-send-email-hkchu@google.com>
	<CAJZOPZKy7w-q5+pp=FgCs8LdQL6e16zAiJr89VMkh+h7obAArg@mail.gmail.com>
	<CAPshTCgLo8ycMTtoa+D14+7pPxJaiC-jUzyR3PJcrMKFw9V0zA@mail.gmail.com>
	<20140228.165614.1112789771887381245.davem@davemloft.net>
	<5315FBAA.3030809@mellanox.com>
	<alpine.LFD.2.03.1403041359350.7122@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:39525 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbaCEAuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 19:50:54 -0500
Received: by mail-ig0-f171.google.com with SMTP id hl1so9464280igb.4
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 16:50:53 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1403041359350.7122@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 4, 2014 at 2:36 PM, Joseph Gasparakis
<joseph.gasparakis@intel.com> wrote:
>
>
> On Tue, 4 Mar 2014, Or Gerlitz wrote:
>
>> On 28/02/2014 23:56, David Miller wrote:
>> > The topic of the skb->encapsulation semantics has come up several times in
>> > the past few weeks. We cannot move forward on any changes in this area until
>> > the semantics are well defined, and documented. Can someone work on a patch
>> > which documents skb->encapsulation properly, and then we can come back to
>> > fixing this bug? Thanks.
>>
>> Lets try... the skb->encapsulation flag was introduced and used in 3.8 by the
>> sequence of these three commits
>>
>> 0afb166 vxlan: Add capability of Rx checksum offload for inner packet
>> d6727fe vxlan: capture inner headers during encapsulation
>> 6a674e9 net: Add support for hardware-offloaded encapsulation
>>
>> When discussed earlier on the list in the context of the skb->ip_summed field,
>> Tom Herbert came with the following interpretation for the semantics which
>> Joseph confirmed
>>
>> "when skb->encapsulation is set the ip_summed is valid for both the inner and
>> outer header
>> (e.g. CHECKSUM_COMPLETE is always assumed okay for both layers). If
>> skb->encapsulation is not set then ip_summed is only valid for outer header"
>>
>
> Agree. This should be valid for both Rx and Tx.
>
>> As for the TX side of things, the change-log of commit 6a674e9 states
>>
>> "For Tx encapsulation offload, the driver will need to set the right bits in
>> netdev->hw_enc_features. The protocol driver will have to set the
>> skb->encapsulation bit and populate the inner headers, so the NIC driver will
>> use those inner headers to calculate the csum in hardware."
>>
>> So in higher level, it seems that the role of the skb->encapsulation field is
>> to mark the skb to carry encapsulated packet for the code path between the
>> time the packet is encapsulated by the protocol driver (e.g vxlan/ipip) to the
>> time driver xmit is called. Or from the time driver rx code runs till the the
>> time the packet is decapsulated.
> Correct. Here is a little bit more explanation about the though behind
> these statements:
>
> When the packet gets decapsulated skb->encapsulation should be reset to 0 as
> all that is left is the (previously to decap) inner packet. For the same reason
> the inner headers also will not be valid any more: there are no inner headers as such.
> Personaly in Rx I assume that when the skb leaves the driver, and the
> hardware has detected encapsulation and hence the csums have been verified
> (or not), the skb->encapsulation is on and skb->ip_summed is set accordingly for both
> layers, but the inner headers are not set and even if they are they are not valid.
>
I am concerned that we are overloading the skb->encpasulation, for
instance if this is set in TX path meaning inner headers are valid,
this should also be true of RX. It might be better if this field
indicated characteristics of the packet independent of being in RX or
TX path. For checksum, maybe we should have a separate encap_checksum
field. Also, to be future proof may this should be two bits for the
devices that can verify checksums in multiple levels of encapsulations
(yes, I know this sounds absurd, but it's no more absurd than devices
vendors taking it upon themselves to parse to some restricted set of
encapsulations instead of just giving us the full packet checksum! :-)
).

I hope to have patches soon on fixing CHECKSUM_COMPLETE, I think it
entails some more state in skb indicating offset and extent of
checksum value in the packet. An like a said, we need to get out of
the habit of stashing pseudo csums there (unless CHECKSUM_PARTIAL is
set).

> Also for Tx, skb->encapsulation should be the indication to the
> driver that it can use the inner headers (i.e. they are valid) in the skb
> in order to offload the inner csum.
>
>>
>> Further, my personal interpretation was that on the rx path, skb should carry
>> the encapsulation flag **only** if the HW was able to offload the inner
>> checksum.
>>
>> Joseph, what's your thinking here?
>
> Yes, I agree. If the hardware cannot offload the inner checksum most
> probably it couldn't even detect the encapsulation.
>
>>
>> Or.
>>
>>
>>
