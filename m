From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH 3/3] netfilter: xt_hashlimit: uses div_u64 for division
Date: Fri, 30 Sep 2016 13:21:42 -0400
Message-ID: <57EE9F26.30203@akamai.com>
References: <20160930160559.4102745-1-arnd@arndb.de>
 <20160930160559.4102745-3-arnd@arndb.de>
 <1475253522.28155.195.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Joshua Hunt <johunt@akamai.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:30313 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750703AbcI3RVo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 13:21:44 -0400
In-Reply-To: <1475253522.28155.195.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2016 12:38 PM, Eric Dumazet wrote:
> On Fri, 2016-09-30 at 18:05 +0200, Arnd Bergmann wrote:
>> The newly added support for high-resolution pps rates introduced multiple 64-bit
>> division operations in one function, which fails on all 32-bit architectures:
>>
>> net/netfilter/xt_hashlimit.o: In function `user2credits':
>> xt_hashlimit.c:(.text.user2credits+0x3c): undefined reference to `__aeabi_uldivmod'
>> xt_hashlimit.c:(.text.user2credits+0x68): undefined reference to `__aeabi_uldivmod'
>> xt_hashlimit.c:(.text.user2credits+0x88): undefined reference to `__aeabi_uldivmod'
>>
>> This replaces the division with an explicit call to div_u64 for version 2
>> to documents that this is a slow operation, and reverts back to 32-bit arguments
>> for the version 1 data to restore the original faster 32-bit division.
>>
>> With both changes combined, we no longer get a link error.
>>
>> Fixes: 11d5f15723c9 ("netfilter: xt_hashlimit: Create revision 2 to support higher pps rates")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>> Vishwanath Pai already sent a patch for this, and I did my version independently.
>> The difference is that his version also the more expensive division for the
>> version 1 variant that doesn't need it.
>>
>> See also http://patchwork.ozlabs.org/patch/676713/
>> ---
>>  net/netfilter/xt_hashlimit.c | 17 ++++++++++-------
>>  1 file changed, 10 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
>> index 44a095ecc7b7..3d5525df6eb3 100644
>> --- a/net/netfilter/xt_hashlimit.c
>> +++ b/net/netfilter/xt_hashlimit.c
>> @@ -464,20 +464,23 @@ static u32 xt_hashlimit_len_to_chunks(u32 len)
>>  static u64 user2credits(u64 user, int revision)
>>  {
>>  	if (revision == 1) {
>> +		u32 user32 = user; /* use 32-bit division */
>> +
> 
> This looks dangerous to me. Have you really tried all possible cases ?
> 
> Caller (even if using revision == 1) does
> user2credits(cfg->avg * cfg->burst, revision);
> 

It does look like we might lose precision here because of 64bit to 32bit
conversion, but I am not sure how much it matters here. Iirc this is how
it used to be before rev2 code.

> Since this is not a fast path, I would prefer to keep the 64bit divide.
> 

Agreed, this code does not get executed too often for us to worry about
div_u64 being slow. And it reverts back to regular division on 64 bit
arch anyways.

> Vishwanath version looks safer.
> 
> 

-Vishwanath
