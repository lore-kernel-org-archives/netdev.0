From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH 05/10] netfilter: nf_tables: fix mismatch in big-endian system
Date: Fri, 17 Mar 2017 12:31:53 +0800
Message-ID: <CAML_gOdW4ur_CgxLF6_DG5N1QHOv+6qjiMXQFCOYEr82EV3O=A@mail.gmail.com>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
 <1489597272-30347-6-git-send-email-pablo@netfilter.org> <063D6719AE5E284EB5DD2968C1650D6DCFFB26B2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:34798 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdCQEbz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 00:31:55 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFB26B2@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
2017-03-16 18:58 GMT+08:00 David Laight <David.Laight@aculab.com>:
[...]
>> For the similar reason, when loading an u16 value from the u32 data
>> register, we should use "*(u16 *) sreg;" instead of "(u16)*sreg;",
>> the 2nd method will get the wrong value in the big-endian system.
> ...
>
> That seems to be papering over some of the obvious cracks.
>
> The fact that the entire 32bits are zeroed makes me suspect that
> in some places values are written as 8 bits and read later as 32.
> The only way that can work on BE is if the values are always written
> as 32 bit ones (assignment style 2).

In nftables, user can use concatenations to put two or more selectors together.
For example, we can use "nft add rule x y tcp dport . ip saddr 22 . 1.1.1.1"
to match the tcp dest port and ip source addr at the same time.

In such case, tcp dport will be stored to REG0 and ip saddr will be stored to
REG1, so the layout will be like this(from the lowest address):
  PORT(2 bytes) - XXXX(2 bytes) - IPADDR(4 bytes)

Later we will use the statement "memcmp(&reg, &data, 8)" to do compare,
so the XXXX part must be filled with zero to avoid garbage value.

>
> OTOH using memcmp(,,2) relies on the data being in the lower addressed
> bytes.
>
> If the data does need to be in the lower addressed bytes I'd suggest
> using a union rather than all the casts.
>
>         David
>
