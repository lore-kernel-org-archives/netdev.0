From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Wed, 1 Mar 2017 08:14:05 -0800
Message-ID: <CAKgT0Ud7dPwyj4Ze4HRJOXTpywBF8VZrELQAay-Sxsv+7+Pozw@mail.gmail.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UeSpxzgePoidJumQFvM5a2mOC5+rL8gCHqvX-HBvrn74A@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DCFE727EB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36786 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752086AbdCAQoq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 11:44:46 -0500
Received: by mail-io0-f169.google.com with SMTP id l7so34913487ioe.3
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 08:44:40 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE727EB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 1, 2017 at 2:41 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Alexander Duyck
>> Sent: 28 February 2017 17:20
> ...
>> You might want to consider just using a combination AND, divide,
>> multiply, and OR to avoid having to have any conditional branches
>> being added due to this code path.  Basically the logic would look
>> like:
>>     new = val | NAPIF_STATE_SCHED;
>>     new |= (val & NAPIF_STATE_SCHED) / NAPIF_STATE_SCHED * NAPIF_STATE_MISSED;
>>
>> In assembler that all ends up getting translated out to AND, SHL, OR.
>> You avoid the branching, or MOV/OR/TEST/CMOV type code you would end
>> up with otherwise.
>
> It is a shame gcc doesn't contain that optimisation.
> It also doesn't even make a good job of (a & b)/b * c since it
> always does a shr and a sal (gcc 4.7.3 and 5.4).

What build flags are you using?  With -Os or -O2 I have seen it
convert the /b * c into a single shift.

> Worthy of a #define or static inline.
> Something like:
> #define BIT_IF(v, a, b) ((b & (b-1) ? (v & a)/a * b : a > b ? (v & a) / (a/b) : (v & a) * (b/a))
>
>         David

Feel free to put together a patch.  I use this kind of thing in the
Intel drivers in multiple spots to shift stuff from TX_FLAGS into
descriptor flags.

- Alex
