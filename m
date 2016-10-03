From: Eric Nelson <eric@nelint.com>
Subject: Re: [PATCH 3/3] net: fec: align IP header in hardware
Date: Mon, 3 Oct 2016 20:48:32 +0200
Message-ID: <326383a0-9879-3cb0-8836-1508adfe5980@nelint.com>
References: <1474728139-9335-1-git-send-email-eric@nelint.com>
 <1474728139-9335-4-git-send-email-eric@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
 <4d199f32-092c-1c0a-7a01-6d0d317ef676@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A73F@AcuExch.aculab.com>
 <5cf173c4-84e0-f309-f356-35b114cc166e@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010E25C@AcuExch.aculab.com>
 <af74a33e-a164-bd2f-4c63-24a128d1ffb5@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010FE38@AcuExch.aculab.com>
 <638d2aa0-eb4a-dd4b-e516-d7ad89eca627@nelint.com>
 <20161001195215.GP1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "fugang.duan@nxp.com" <fugang.duan@nxp.com>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35443 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752367AbcJCSsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 14:48:38 -0400
Received: by mail-wm0-f50.google.com with SMTP id f193so124447969wmg.0
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 11:48:37 -0700 (PDT)
In-Reply-To: <20161001195215.GP1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

On 10/01/2016 09:52 PM, Russell King - ARM Linux wrote:
> On Fri, Sep 30, 2016 at 07:16:12AM -0700, Eric Nelson wrote:
>> On ARM, the CPU can't handle misaligned memory cycles without
>> taking an alignment fault and NET_IP_ALIGN is set to 2.
> 
> Let's get this right...  With Linux on MMU parts:
> 
> On ARMv6+, unaligned memory cycles using the LDR, LDRH and corresponding
> store instructions are handled in hardware without any exception being
> raised.
> 
> On pre-ARMv6, such instructions raise an alignment exception, and we fix
> up the load/store manually.
> 
> Where things behave the same is with the LDM (load multiple) and STM
> (store multiple) instructions.  Hardware does not fix these up if they
> are unaligned: it is expected that the base address will always be
> aligned to a 32-bit word.
> 

Thanks for the clarification. This helps me understand why I didn't
see the exceptions that Eric warned about:

https://www.spinics.net/lists/netdev/msg397012.html

> For some reason, the compiler guys have decided it's okay to use these
> instructions as an optimisation, and I see no way to disable this
> behaviour.
> 
>> On ARM, we have CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
>> but I find it hard to believe that taking alignment faults is more
>> efficient than adding two bytes to the start of the frame.
> 
> ... see above, hence why CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set.
> It's only when the compiler decides to do silly things that things go
> wrong.  However, net code does not care about that configuration
> setting, so it's irrelevant to this discussion.
> 

The obfuscated optimization in ip_gro_receive doesn't help by
reading two 16-bit values as a __be32:

id = ntohl(*(__be32 *)&iph->id);
flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id & ~IP_DF));
id >>= 16;

> The issue with the networking layer is that it passes around structure
> pointers which may not be "naturally aligned" - technically it goes
> against the C standard specs.  However, you'll find it hard to argue
> against this, so we have to accept that the networking people expect
> it to work.
> 
> The optimisation that the C compiler uses (using LDM to access multiple
> 32-bit consecutive words) is legal and efficient when the structure
> pointers are aligned as it expects, but that all breaks if the pointer
> is not so aligned.  So, raising it as a bug against the C compiler isn't
> going to work either.
> 
> What may work is to raise a feature request with compiler people to have
> a mechanism to disable the LDM/STM optimisation for code where we know
> that pointers may not be naturally aligned.
> 

Agreed, but that's a long path even if the compiler folks agree
immediately.

It's probably to just fix the driver with known issues for now.

Did you have any comments on the patch? I tried to pull what I found
from your patch set, but only the enabling of the SHIFT16 bit.

Please advise,


Eric
