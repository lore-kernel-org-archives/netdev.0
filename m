From: Adel Fuchs <adelfuchs@gmail.com>
Subject: Fwd: running an eBPF program
Date: Sun, 28 May 2017 10:40:37 +0300
Message-ID: <CAErYV9Fok4UUfUx1t_gm6vGLiapPhxJRJ=7j7qo=5hjTkJ3V8Q@mail.gmail.com>
References: <CAErYV9EjKGh9ta8TZ9PRmaATH5VcXQH4cd=WuL5NfMOpcuoLfw@mail.gmail.com>
 <CAH3MdRVMixv8s10gKF1jQjtSY7MHeB-Rs16hX6HwAgUOQ0g=EA@mail.gmail.com>
 <CAH3MdRWg57Aw666ahVGb04UcSTqxrz1Wd33JDLyCqY4fh=xstA@mail.gmail.com>
 <20170527.201107.1558140531080967167.davem@davemloft.net> <CAH3MdRUukbz+hy76afQiHi=k-_CsA12ShjaoQKnFcLnoVxBHPQ@mail.gmail.com>
 <CAErYV9HhBoWnMVZS4XBJPN0TM4V2=U2Y+NBSyY8bqHJopvWTGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:35455 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdE1Hkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 03:40:39 -0400
Received: by mail-vk0-f67.google.com with SMTP id x71so2739831vkd.2
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 00:40:38 -0700 (PDT)
In-Reply-To: <CAErYV9HhBoWnMVZS4XBJPN0TM4V2=U2Y+NBSyY8bqHJopvWTGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Is there any way to run this eBPF program without that patch?
Alternatively, is there any other eBPF sample that does run properly?
I need to run a program that filters packets according to IP address
or port.
Thanks,
Adel

On Sun, May 28, 2017 at 8:08 AM, Y Song <ys114321@gmail.com> wrote:
> On Sat, May 27, 2017 at 5:11 PM, David Miller <davem@davemloft.net> wrote:
>> From: Y Song <ys114321@gmail.com>
>> Date: Sat, 27 May 2017 13:52:27 -0700
>>
>>> On Sat, May 27, 2017 at 1:23 PM, Y Song <ys114321@gmail.com> wrote:
>>>>
>>>> From verifier error message:
>>>> ======
>>>> 0: (bf) r6 = r1
>>>>
>>>> 1: (18) r9 = 0xffe0000e
>>>>
>>>> 3: (69) r0 = *(u16 *)(r6 +16)
>>>>
>>>> invalid bpf_context access off=16 size=2
>>>> ======
>>>>
>>>> The offset 16 of struct __sk_buff is hash.
>>>> What instruction #3 tries to do is to access 2 bytes of the hash value
>>>> instead of full 4 bytes.
>>>> This is explicitly not allowed in verifier due to endianness issue.
>>>
>>>
>>> I can reproduce the issue now. My previous statement saying to access
>>> "hash" field is not correct. It is accessing the protocol field.
>>>
>>> static __inline__ bool flow_dissector(struct __sk_buff *skb,
>>>                                       struct flow_keys *flow)
>>> {
>>>         int poff, nh_off = BPF_LL_OFF + ETH_HLEN;
>>>         __be16 proto = skb->protocol;
>>>         __u8 ip_proto;
>>>
>>> The plan so far is to see whether we can fix the issue in LLVM side.
>>
>> If the compiler properly asks for "__sk_buff + 16" on little-endian
>> and "__sk_buff + 20" on big-endian, the verifier should instead be
>> fixed to allow the access to pass.
>>
>> I can't see any reason why LLVM won't set the offset properly like
>> that, and it's a completely legitimate optimization that we shouldn't
>> try to stop LLVM from performing.
>
> I do agree that such optimization in LLVM is perfect fine and actually
> beneficial.
> The only reason I was thinking was to avoid introduce endianness into verifier.
> Maybe not too much work there. Let me do some experiments and come with
> a patch for that.
>
> Thanks!
>
> Yonghong
>
>>
>> It also makes it so that we don't have to fix having absurdly defined
>> __sk_buff's protocol field as a u32.
>>
>> Thanks.
