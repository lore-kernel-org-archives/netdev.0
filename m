From: David Miller <davem@davemloft.net>
Subject: Re: running an eBPF program
Date: Sat, 27 May 2017 20:11:07 -0400 (EDT)
Message-ID: <20170527.201107.1558140531080967167.davem@davemloft.net>
References: <CAErYV9EjKGh9ta8TZ9PRmaATH5VcXQH4cd=WuL5NfMOpcuoLfw@mail.gmail.com>
        <CAH3MdRVMixv8s10gKF1jQjtSY7MHeB-Rs16hX6HwAgUOQ0g=EA@mail.gmail.com>
        <CAH3MdRWg57Aw666ahVGb04UcSTqxrz1Wd33JDLyCqY4fh=xstA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adelfuchs@gmail.com, netdev@vger.kernel.org
To: ys114321@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53038 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdE1ALO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:11:14 -0400
In-Reply-To: <CAH3MdRWg57Aw666ahVGb04UcSTqxrz1Wd33JDLyCqY4fh=xstA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Y Song <ys114321@gmail.com>
Date: Sat, 27 May 2017 13:52:27 -0700

> On Sat, May 27, 2017 at 1:23 PM, Y Song <ys114321@gmail.com> wrote:
>>
>> From verifier error message:
>> ======
>> 0: (bf) r6 = r1
>>
>> 1: (18) r9 = 0xffe0000e
>>
>> 3: (69) r0 = *(u16 *)(r6 +16)
>>
>> invalid bpf_context access off=16 size=2
>> ======
>>
>> The offset 16 of struct __sk_buff is hash.
>> What instruction #3 tries to do is to access 2 bytes of the hash value
>> instead of full 4 bytes.
>> This is explicitly not allowed in verifier due to endianness issue.
> 
> 
> I can reproduce the issue now. My previous statement saying to access
> "hash" field is not correct. It is accessing the protocol field.
> 
> static __inline__ bool flow_dissector(struct __sk_buff *skb,
>                                       struct flow_keys *flow)
> {
>         int poff, nh_off = BPF_LL_OFF + ETH_HLEN;
>         __be16 proto = skb->protocol;
>         __u8 ip_proto;
> 
> The plan so far is to see whether we can fix the issue in LLVM side.

If the compiler properly asks for "__sk_buff + 16" on little-endian
and "__sk_buff + 20" on big-endian, the verifier should instead be
fixed to allow the access to pass.

I can't see any reason why LLVM won't set the offset properly like
that, and it's a completely legitimate optimization that we shouldn't
try to stop LLVM from performing.

It also makes it so that we don't have to fix having absurdly defined
__sk_buff's protocol field as a u32.

Thanks.
