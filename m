From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 05/10] netfilter: nf_tables: fix mismatch in big-endian
 system
Date: Thu, 16 Mar 2017 10:58:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB26B2@AcuExch.aculab.com>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
 <1489597272-30347-6-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:51446 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdCPK6P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:58:15 -0400
In-Reply-To: <1489597272-30347-6-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso
> Sent: 15 March 2017 17:01
> From: Liping Zhang <zlpnobody@gmail.com>
> 
> Currently, there are two different methods to store an u16 integer to
> the u32 data register. For example:
>   u32 *dest = &regs->data[priv->dreg];
>   1. *dest = 0; *(u16 *) dest = val_u16;
>   2. *dest = val_u16;
> 
> For method 1, the u16 value will be stored like this, either in
> big-endian or little-endian system:
>   0          15           31
>   +-+-+-+-+-+-+-+-+-+-+-+-+
>   |   Value   |     0     |
>   +-+-+-+-+-+-+-+-+-+-+-+-+
> 
> For method 2, in little-endian system, the u16 value will be the same
> as listed above. But in big-endian system, the u16 value will be stored
> like this:
>   0          15           31
>   +-+-+-+-+-+-+-+-+-+-+-+-+
>   |     0     |   Value   |
>   +-+-+-+-+-+-+-+-+-+-+-+-+
> 
> So later we use "memcmp(&regs->data[priv->sreg], data, 2);" to do
> compare in nft_cmp, nft_lookup expr ..., method 2 will get the wrong
> result in big-endian system, as 0~15 bits will always be zero.
> 
> For the similar reason, when loading an u16 value from the u32 data
> register, we should use "*(u16 *) sreg;" instead of "(u16)*sreg;",
> the 2nd method will get the wrong value in the big-endian system.
...

That seems to be papering over some of the obvious cracks.

The fact that the entire 32bits are zeroed makes me suspect that
in some places values are written as 8 bits and read later as 32.
The only way that can work on BE is if the values are always written
as 32 bit ones (assignment style 2).

OTOH using memcmp(,,2) relies on the data being in the lower addressed
bytes.

If the data does need to be in the lower addressed bytes I'd suggest
using a union rather than all the casts.

	David
