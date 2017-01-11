From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 7/8] net: Rename TCA*BPF_DIGEST to ..._SHA256
Date: Wed, 11 Jan 2017 10:19:49 -0800
Message-ID: <CALCETrVhuszdsfayLrBBkSzJ+A3m+hJjdZQWDj9FOg+2UB_ZBw@mail.gmail.com>
References: <cover.1484090585.git.luto@kernel.org> <f284a4d87cde103cd78de64b8607e3c80a17e2e5.1484090585.git.luto@kernel.org>
 <58758169.2020408@iogearbox.net> <CALCETrUHenMS1iomFr7+YEy_M3zaotrWbfMe93=BmzCbzJ0fLw@mail.gmail.com>
 <5875F65A.4010904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5875F65A.4010904@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 11, 2017 at 1:09 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Hi Andy,
>
> On 01/11/2017 04:11 AM, Andy Lutomirski wrote:
>>
>> On Tue, Jan 10, 2017 at 4:50 PM, Daniel Borkmann <daniel@iogearbox.net>
>> wrote:
>>>
>>> On 01/11/2017 12:24 AM, Andy Lutomirski wrote:
>>>>
>>>>
>>>> This makes it easier to add another digest algorithm down the road if
>>>> needed.  It also serves to force any programs that might have been
>>>> written against a kernel that had the old field name to notice the
>>>> change and make any necessary changes.
>>>>
>>>> This shouldn't violate any stable API policies, as no released kernel
>>>> has ever had TCA*BPF_DIGEST.
>>>
>>>
>>> Imho, this and patch 6/8 is not really needed. Should there ever
>>> another digest alg be used (doubt it), then you'd need a new nl
>>> attribute and fdinfo line anyway to keep existing stuff intact.
>>> Nobody made the claim that you can just change this underneath
>>> and not respecting abi for existing applications when I read from
>>> above that such apps now will get "forced" to notice a change.
>>
>>
>> Fair enough.  I was more concerned about prerelease iproute2 versions,
>> but maybe that's a nonissue.  I'll drop these two patches.
>
>
> Ok. Sleeping over this a bit, how about a general rename into
> "prog_tag" for fdinfo and TCA_BPF_TAG resp. TCA_ACT_BPF_TAG for
> the netlink attributes, fwiw, it might reduce any assumptions on
> this being made? If this would be preferable, I could cook that
> patch against -net for renaming it?

That would be fine with me.

I think there are two reasonable approaches to computing the actual tag.

1. Use a standard, modern cryptographic hash.  SHA-256, SHA-512,
Blake2b, whatever.  SHA-1 is a bad choice in part because it's partly
broken and in part because the implementation in lib/ is a real mess
to use (as you noticed while writing the code).

2. Use whatever algorithm you like but make the tag so short that it's
obviously not collision-free.  48 or 64 bits is probably reasonable.

The intermediate versions are just asking for trouble.  Alexei wants
to make the tag shorter, but I admit I still don't understand why he
prefers that over using a better crypto hash and letting user code
truncate the tag if it wants.
