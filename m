From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Wed, 9 Mar 2016 08:03:05 -0800
Message-ID: <CAKgT0Uc6dHuL5TfmAhbnvKjejOXFAJx9a-fr8Z8beTfNzmXZSw@mail.gmail.com>
References: <20160308224238.16551.73881.stgit@localhost.localdomain>
	<1457479557.4067.9.camel@perches.com>
	<063D6719AE5E284EB5DD2968C1650D6D4111BB63@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35162 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbcCIQDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 11:03:07 -0500
Received: by mail-io0-f174.google.com with SMTP id g203so71096179iof.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 08:03:05 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D4111BB63@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 9, 2016 at 2:54 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Joe Perches
>> Sent: 08 March 2016 23:26
> ...
>> > +
>> > +   if (offset & 1)
>> > +           sum = (sum << 24) + (sum >> 8);
>>
>> Maybe use ror32(sum, 8);
>>
>> or maybe something like:
>>
>> {
>>       u32 sum;
>>
>>       /* rotated csum2 of odd offset will be the right checksum */
>>       if (offset & 1)
>>               sum = ror32((__force u32)csum2, 8);
>>       else
>>               sum = (__force u32)csum2;
>
> Or even:
>         sum = ror32((__force u32)csum2, (offset & 1) * 8);
> to remove the conditional.
> Assuming 'rotate by 0 bits' is valid.
> If not add 16 to rotate by 16 or 24.

The problem is "ror %cl" can be significantly more expensive than just
a "ror $8".  In the case of x86 the difference is as much as 6 cycles
or more on some of the older architectures so it may be better to just
do the rotate by 8 and then an "and" or "test" and "cmovne" which is
what this compiles into right now.

- Alex
