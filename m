From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Thu, 21 Sep 2017 17:58:14 +0100
Message-ID: <207ecd4c-b1b4-3dcd-62a6-30824c19dbf7@solarflare.com>
References: <7013ee9d-a8e6-13fd-cc5f-86cf3d8bf4e0@solarflare.com>
 <20170921155215.jta52sesbiq54vri@ast-mbp>
 <4cfac985-4f99-cf85-fc15-c3ad1f8ff123@solarflare.com>
 <CAH3MdRWAHJS8Y8ketOAghYyorVUp6JijjZcSVY7gOiGAr7e_pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Y Song <ys114321@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([148.163.129.52]:37887 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750790AbdIUQ6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:58:21 -0400
In-Reply-To: <CAH3MdRWAHJS8Y8ketOAghYyorVUp6JijjZcSVY7gOiGAr7e_pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/09/17 17:40, Y Song wrote:
> On Thu, Sep 21, 2017 at 9:24 AM, Edward Cree <ecree@solarflare.com> wrote:
>> On 21/09/17 16:52, Alexei Starovoitov wrote:
>>> imo
>>> (u16) r4 endian be
>>> isn't intuitive.
>>> Can we come up with some better syntax?
>>> Like
>>> bswap16be r4
>>> bswap32le r4
>> Hmm, I don't like these, since bswapbe is a swap on *le* and a nop on be.
>>> or
>>>
>>> to_be16 r4
>>> to_le32 r4
>> And the problem here is that it's not just to_be, it's also from_be.
> Could you explain what is "from_be" here? Do not quite understand.
Taking the example of a little-endian processor:
cpu_to_be16() is a byte-swap, converting a u16 (cpu-endian) to a __be16.
be16_to_cpu(), to convert a __be16 to a u16, is *also* a byte-swap.
Meanwhile, cpu_to_le16() and le16_to_cpu() are both no-ops.

More generally, the conversions between cpu-endian and fixed-endian for
 any given size are self-inverses.  eBPF takes advantage of this by only
 having a single opcode for both the "to" and "from" direction.  So to
 specify an endianness conversion, you need only the size and the fixed
 endianness (le or be), not the to/from direction.  Conversely, when
 disassembling one of these instructions, you don't know whether it's a
 cpu_to_be16() or a be16_to_cpu(), because they both look the same at an
 instruction level (they only differ in what types the programmer thought
 of the register as holding before and after).
