From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: IPsec: Why do pfkey_getspi and xfrm_alloc_userspi call xfrm_find_acq_byseq?
Date: Mon, 23 Aug 2010 15:30:46 +0200
Message-ID: <4C727806.3060102@6wind.com>
References: <4C6D29B9.5070403@6wind.com> <20100822.005353.260099324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49502 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704Ab0HWNdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 09:33:22 -0400
Received: by wyb32 with SMTP id 32so6805738wyb.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 06:33:21 -0700 (PDT)
In-Reply-To: <20100822.005353.260099324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

First of all, thank you for your answer.

David Miller wrote:
> From: Christophe Gouault <christophe.gouault@6wind.com>
> Date: Thu, 19 Aug 2010 14:55:21 +0200
>
>> The call to xfrm_find_acq_byseq() by the pfkey_getspi() and
>> xfrm_alloc_userspi() functions is quite costly and proves to entail
>> scalability issues when performing thousands of IKE negotiations with
>> racoon (from ipsec-tools distribution) or charon (from strongswan
>> distribution).
>>
>> Removing this call in the kernel drastically accelerates the
>> processing and does not seem to entail functional problems.
>>
>> For now, I don't see the point of this call. I need to understand its
>> purpose, because I'm highly tempted to simply remove it.
> First of all, removing a function because you don't understand
> why it's there is rarely a good idea :-)
Yes, don't worry, I never act that way. I was deliberately a little 
provocative ;-)
> I think the semantics require that we check for existing ACQUIRE
> state entries before we allocate an SPI.
Well, I still don't see in which case this can happen. The only 
situations in which an ACQUIRE state entry is created is when an acquire 
message is raised by the kernel (this creates a temporary outbound 
state) or when a getspi is issued from the userland (this creates a 
temporary state, as far as I know, this is the future inbound state 
negotiated by IKE).

In my humble opinion, issuing a getspi for the output state does not 
make sense since the SPI is chosen by the destination host.
So the possibly existing ACQUIRE state entry would be the result of a 
former getspi with the same value of the seq field. So this call would 
aim at cancelling a former call to getspi, maybe to cope with an 
application that would retry a failed negotiation before the former 
getspi expired?... I'm not really convinced by this explanation.

But there are maybe other uses of the getspi call than assigning a SPI 
for the inbound state of an IKE negotiation...
> The likelyhood of breaking something if you remove the call is very
> high.
Probably. I'm still interested in a concrete example ;-)

Christophe
