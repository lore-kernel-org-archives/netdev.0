From: "Devon H. O'Dell" <dho@fastly.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before xmit
Date: Fri, 9 Oct 2015 09:40:43 -0700
Message-ID: <CADe=ujZWjibL39JXM4U32GSHjK_sc6oov1Z0KrTL2dMGryJCjw@mail.gmail.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
	<56153E6C.9050202@plumgrid.com>
	<CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
	<561727D5.2070001@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:36762 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757049AbbJIQkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 12:40:45 -0400
Received: by obcgx8 with SMTP id gx8so66557638obc.3
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 09:40:44 -0700 (PDT)
In-Reply-To: <561727D5.2070001@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 7:35 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 10/8/15 5:50 PM, Devon H. O'Dell wrote:
>>>
>>> with the amount of skb_sender_cpu_clear() all over the code base
>>> >I wonder whether there is a better solution to all of these.
>>
>> I think there is. We found that splitting the union of sender_cpu and
>> napi_id solved the issue for us. In general, I think this is an OK
>> solution as long as the following hold:
>>
>>   * skbs are always allocated via kzalloc
>>   * out -> out cloned skbs are always cloned on the same CPU
>>   * an extra four bytes in skbuff isn't a bad thing
>
>
> I'm pretty sure extending sk_buff for this is not acceptable.

That's unfortunate.

> I was thinking may be we can use sign bit to distinguish between
> napi_id and sender_cpu.
> Like:
>         if ((int)skb->sender_cpu >= 0)
>                 skb->sender_cpu = - (raw_smp_processor_id() + 1);
> and inside get_xps_queue() use it only if it's negative.

I like the idea, but it seems unnecessarily magical. What about using
a bitfield? Then there's just an option bit that is either
OPTION_NAPI_ID or OPTION_SENDER_CPU. Then the check to set sender_cpu
in netdev_pick_tx becomes

    if (skb->sender_napi_option == OPTION_NAPI_ID || skb->sender_cpu == 0) ...

> Then we can remove skb_sender_cpu_clear() from everywhere.
> Adding a check to napi_hash_add() to make sure that napi_id is not
> negative is probably ok too.

We could change this to check that sender_napi_option would be
OPTION_NAPI_ID with the bitfield idea.

My names are probably bad, but I think the idea is less magical (and
is effectively the same thing you are proposing).

> Thoughts?

--dho
