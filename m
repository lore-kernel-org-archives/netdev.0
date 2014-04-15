From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Tue, 15 Apr 2014 09:22:23 -0700
Message-ID: <CA+ZOOTNMHBsGzdwk=3k1==EVvV8Ge-EPxmFLNyHvdke=1QSPzg@mail.gmail.com>
References: <1397516569-31033-1-git-send-email-chema@google.com>
	<534CDE99.6090407@redhat.com>
	<1397572894.4222.98.camel@edumazet-glaptop2.roam.corp.google.com>
	<534D4A72.2010909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	ast@plumgrid.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:54728 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbaDOQWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 12:22:24 -0400
Received: by mail-oa0-f46.google.com with SMTP id i7so11023081oag.19
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 09:22:23 -0700 (PDT)
In-Reply-To: <534D4A72.2010909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 8:04 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 04/15/2014 04:41 PM, Eric Dumazet wrote:
>>
>> On Tue, 2014-04-15 at 09:24 +0200, Daniel Borkmann wrote:
>>
>>>> @@ -773,6 +779,7 @@ static bool convert_bpf_extensions(struct
>>>> sock_filter *fp,
>>>>         case SKF_AD_OFF + SKF_AD_NLATTR:
>>>>         case SKF_AD_OFF + SKF_AD_NLATTR_NEST:
>>>>         case SKF_AD_OFF + SKF_AD_CPU:
>>>> +       case SKF_AD_OFF + SKF_AD_RANDOM:
>>>
>>>
>>> I think instead of a function call, this sould rather be modelled
>>> directly into the internal insn set and thus converted differently,
>>> so we can spare us the call.
>>
>>
>> Hmmm... this would need percpu storage, thus preempt disable/enable
>> calls, and prandom_u32_state() is about 40 instructions.
>>
>> This is really not worth the pain.
>
>
> Absolutely, that was not what I meant actually. Calling to
> prandom_u32_state() is fine, no need to have another prng just
> for that. I was just wondering if it makes sense to model that
> directly as an instruction into a jump-table target that calls
> prandom_u32() from there instead 'indirectly'. Need to think
> about this a bit more ...
I thought about that. In fact, the original patch (written for
FreeBSD) worked by extending the ISA with a new load mode that did "A
= random();". After seeing your eBPF work, I got convinced that we
want to get a generic ISA when possible, where random is typically not
an insn. Also, the bpf_call approach makes it much easier to integrate
with the different JITs.

-Chema
