From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Tue, 8 Mar 2016 21:23:32 -0800
Message-ID: <CAKgT0Uc94UgzzcNXeFDvA4NKJN78hi-n7d2ar9YFiR8yGhW8Gw@mail.gmail.com>
References: <20160308224238.16551.73881.stgit@localhost.localdomain>
	<1457479557.4067.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35000 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbcCIFXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 00:23:33 -0500
Received: by mail-ig0-f182.google.com with SMTP id vf5so3759675igb.0
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 21:23:33 -0800 (PST)
In-Reply-To: <1457479557.4067.9.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2016 at 3:25 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2016-03-08 at 14:42 -0800, Alexander Duyck wrote:
>> The code for csum_block_add was doing a funky byteswap to swap the even and
>> odd bytes of the checksum if the offset was odd.  Instead of doing this we
>> can save ourselves some trouble and just shift by 8 as this should have the
>> same effect in terms of the final checksum value and only requires one
>> instruction.
>
> 3 instructions?

I was talking about just the one ror vs mov, shl, shr, and ,and, add.

I assume when you say 3 you are including the test and either some
form of conditional move or jump?

>> In addition we can update csum_block_sub to just use csum_block_add with a
>> inverse value for csum2.  This way we follow the same code path as
>> csum_block_add without having to duplicate it.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
>>  include/net/checksum.h |   11 +++++------
>>  1 file changed, 5 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/net/checksum.h b/include/net/checksum.h
>> index 10a16b5bd1c7..f9fac66c0e66 100644
>> --- a/include/net/checksum.h
>> +++ b/include/net/checksum.h
>> @@ -88,8 +88,10 @@ static inline __wsum
>>  csum_block_add(__wsum csum, __wsum csum2, int offset)
>>  {
>>       u32 sum = (__force u32)csum2;
>> -     if (offset&1)
>> -             sum = ((sum&0xFF00FF)<<8)+((sum>>8)&0xFF00FF);
>> +
>> +     if (offset & 1)
>> +             sum = (sum << 24) + (sum >> 8);
>
> Maybe use ror32(sum, 8);

I was actually thinking I could use something like this.  I didn't
realize it was even available.

> or maybe something like:
>
> {
>         u32 sum;
>
>         /* rotated csum2 of odd offset will be the right checksum */
>         if (offset & 1)
>                 sum = ror32((__force u32)csum2, 8);
>         else
>                 sum = (__force u32)csum2;
>

Any specific reason for breaking it up like this?  It seems like it
was easier to just have sum be assigned first and then rotating it if
needed.  What is gained by splitting the assignment up over two
different calls?
