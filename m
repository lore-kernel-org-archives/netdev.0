From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next] tcp: md5: do not use stack storage in crypto operations
Date: Mon, 27 Jun 2016 08:02:43 -0700
Message-ID: <CALCETrXk1O2SatvZYN_TGOCN4M95oCdWLwH3JC1TPjAp+cu1=g@mail.gmail.com>
References: <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com> <20160627.105158.605041440961301398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:32980 "EHLO
	mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbcF0PDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 11:03:05 -0400
Received: by mail-vk0-f49.google.com with SMTP id j3so22846438vkb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 08:03:03 -0700 (PDT)
In-Reply-To: <20160627.105158.605041440961301398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 7:51 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 25 Jun 2016 18:09:35 +0200
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Some arches have virtually mapped kernel stacks, or will soon have.
>>
>> tcp_md5_hash_header() uses an automatic variable to copy tcp header
>> before mangling th->check and calling crypto function, which might
>> be problematic on such arches.
>>
>> So use percpu storage as we already do for the pseudo header,
>> and reduce number of crypto functions calls, as these headers
>> are ridiculously small.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Reported-by: Andy Lutomirski <luto@amacapital.net>
>> ---
>> I am not sure the md5 crypto functions have a problem with data backed
>> in virtually mapped stacks, but this patch seems to remove the doubt.
>
> In a non-SMP build this storage will be in the kernel image itself.
>
> And this violates the crypto layer's requirements.
>
> It has to be memory taken from the page allocator or kmalloc.  So
> before vmalloc'd stacks, the current code is perfectly fine.  And
> with vmalloc'd stacks this patch trades one bug for another.

After poking around a bit: could this use crypto_shash_init +
crypto_shash_finup?  Those functions seem like they'll be just fine
with any virtual address, and I bet they're considerably faster than
using the ahash API.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
