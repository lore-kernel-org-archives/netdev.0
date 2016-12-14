From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 19:06:57 +0100
Message-ID: <CAHmME9pz4XudfeqhKBwFNDmp7AYuNwbnevMqB3e6ScPDnUnq9g@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com> <20161214.125612.1361254098267633173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        Andi Kleen <ak@linux.intel.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:51642 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754023AbcLNSHD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 13:07:03 -0500
In-Reply-To: <20161214.125612.1361254098267633173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Dec 14, 2016 at 6:56 PM, David Miller <davem@davemloft.net> wrote:
> Just marking the structure __packed, whether necessary or not, makes
> the compiler assume that the members are not aligned and causes
> byte-by-byte accesses to be performed for words.
> Never, _ever_, use __packed unless absolutely necessary, it pessimizes
> the code on cpus that require proper alignment of types.

Oh, jimminy cricket, I did not realize that it made assignments
byte-by-byte *always*. So what options am I left with? What
immediately comes to mind are:

1)

struct {
    u64 a;
    u32 b;
    u32 c;
    u16 d;
    u8 end[];
} a = {
    .a = a,
    .b = b,
    .c = c,
    .d = d
};
siphash24(&a, offsetof(typeof(a), end), key);

2)

u8 bytes[sizeof(u64) + sizeof(u32) * 2 + sizeof(u16)];
*(u64 *)&bytes[0] = a;
*(u32 *)&bytes[sizeof(u64)] = b;
*(u32 *)&bytes[sizeof(u64) + sizeof(u32)] = c;
*(u16 *)&bytes[sizeof(u64) + sizeof(u32) * 2] = d;
siphash24(bytes, sizeof(bytes), key);


Personally I find (1) a bit neater than (2). What's your opinion?

Jason
