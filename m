From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netfilter: xt_hashlimit: avoid 64-bit division
Date: Thu, 7 Sep 2017 13:16:15 +0200
Message-ID: <CAK8P3a0tTApdk_mbxd_Xm4j0X6-=u6Zxg9wGyp_bPp5aov_mtw@mail.gmail.com>
References: <20170906195825.3715290-1-arnd@arndb.de> <7791dee1-64a9-dcaa-c5d9-0b04a44bc526@akamai.com>
 <CAK8P3a1GxBjWqnK+fdKmzOhXyFK1XbCFWau8md3OjnLjUZOeDg@mail.gmail.com> <20170907101931.GB2049@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Vishwanath Pai <vpai@akamai.com>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Josh Hunt <johunt@akamai.com>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35049 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754188AbdIGLQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 07:16:17 -0400
In-Reply-To: <20170907101931.GB2049@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 7, 2017 at 12:19 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Wed, Sep 06, 2017 at 10:48:22PM +0200, Arnd Bergmann wrote:
>> On Wed, Sep 6, 2017 at 10:22 PM, Vishwanath Pai <vpai@akamai.com> wrote:
>> > On 09/06/2017 03:57 PM, Arnd Bergmann wrote:
>> >> 64-bit division is expensive on 32-bit architectures, and
>> >> requires a special function call to avoid a link error like:
>> >>
>> >> net/netfilter/xt_hashlimit.o: In function `hashlimit_mt_common':
>> >> xt_hashlimit.c:(.text+0x1328): undefined reference to `__aeabi_uldivmod'
>> >>
>> >> In the case of hashlimit_mt_common, we don't actually need a
>> >> 64-bit operation, we can simply rewrite the function slightly
>> >> to make that clear to the compiler.
>> >>
>> >> Fixes: bea74641e378 ("netfilter: xt_hashlimit: add rate match mode")
>> >> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> >> ---
>> >>  net/netfilter/xt_hashlimit.c | 5 ++++-
>> >>  1 file changed, 4 insertions(+), 1 deletion(-)
>> >>
>> >> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
>> >> index 10d48234f5f4..50b53d86eef5 100644
>> >> --- a/net/netfilter/xt_hashlimit.c
>> >> +++ b/net/netfilter/xt_hashlimit.c
>> >> @@ -531,7 +531,10 @@ static u64 user2rate_bytes(u64 user)
>> >>  {
>> >>       u64 r;
>> >>
>> >> -     r = user ? 0xFFFFFFFFULL / user : 0xFFFFFFFFULL;
>> >> +     if (user > 0xFFFFFFFFULL)
>> >> +             return 0;
>> >> +
>> >> +     r = user ? 0xFFFFFFFFULL / (u32)user : 0xFFFFFFFFULL;
>> >>       r = (r - 1) << 4;
>> >>       return r;
>> >>  }
>> >>
>> >
>> > I have submitted another patch to fix this:
>> > https://patchwork.ozlabs.org/patch/809881/
>> >
>> > We have seen this problem before, I was careful not to introduce this
>> > again in the new patch but clearly I overlooked this particular line :(
>> >
>> > In the other cases we fixed it by replacing division with div64_u64().
>>
>> div64_u64() seems needlessly expensive here since the dividend
>> is known to be a 32-bit number. I guess the function is not called
>> frequently though, so it doesn't matter much.
>
> This is called from the packet path, only for the first packet for
> each new destination IP entry in the hashtable, still from the
> datapath. So if we can take something faster (for 32 bit arches) that
> is correct, I think it's sensible to take.
>
> Let me know in any case.

I think my version should be slightly better then, unless someone
finds something wrong with it.

       Arnd
