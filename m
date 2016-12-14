From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 3/3] netns: fix net_generic() "id - 1" bloat
Date: Wed, 14 Dec 2016 16:19:33 +0300
Message-ID: <CACVxJT9HAMex1Pa+VbTVJwDPuY_dnfgfQgAZFSjMuUmgCiZD1w@mail.gmail.com>
References: <20161202012132.GD31170@avx2> <063D6719AE5E284EB5DD2968C1650D6DB0234CCB@AcuExch.aculab.com>
 <CACVxJT8axg6i0Lvem=fvKqrjTuOzwg63BDbAuR6bzTPrtLuP+g@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0236F41@AcuExch.aculab.com>
 <CACVxJT8fT0Lbe_ojNjU9DYYO=PO+QzA=jpQb7V6_US8W9D-KTQ@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DB023DBE9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xemul@openvz.org" <xemul@openvz.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:34813 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755565AbcLNNTh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 08:19:37 -0500
Received: by mail-wj0-f195.google.com with SMTP id xy5so4650253wjc.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 05:19:36 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB023DBE9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 5:42 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Alexey Dobriyan
>> Sent: 13 December 2016 14:23
> ...
>> Well, the point of the patch is to save .text, so might as well save
>> as much as possible. Any form other than "ptr[id]" is going
>> to be either bigger or bigger and slower and "ptr" should be the first field.
>
> You've not read and understood the next bit:
>
>> > However if you offset the 'id' values so that only
>> > values 2 up are valid the code becomes:
>> >         return net->gen2->ptr[id - 2];
>> > which will be exactly the same code as:
>> >         return net->gen1->ptr[id];
>> > but it is much more obvious that 'id' values must be >= 2.
>> >
>> > The '2' should be generated from the structure offset, but with my method
>> > is doesn't actually matter if it is wrong.
>
> If you have foo->bar[id - const] then the compiler has to add the
> offset of 'bar' and subtract for 'const'.
> If the numbers match no add or subtract is needed.
>
> It is much cleaner to do this by explicitly removing the offset on the
> accesses than using a union.

Surprisingly, the trick only works if array index is cast to "unsigned long"
before subtracting.

Code becomes

    ...
    ptr = ng->ptr[(unsigned long)id - 3];
    ...

I'll post a patch when net-next reopens.
