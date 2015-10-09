From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Thu, 8 Oct 2015 19:35:01 -0700
Message-ID: <561727D5.2070001@plumgrid.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
 <56153E6C.9050202@plumgrid.com>
 <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
To: "Devon H. O'Dell" <dho@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33112 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756689AbbJICfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:35:03 -0400
Received: by pacex6 with SMTP id ex6so72041527pac.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:35:03 -0700 (PDT)
In-Reply-To: <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/8/15 5:50 PM, Devon H. O'Dell wrote:
>> with the amount of skb_sender_cpu_clear() all over the code base
>> >I wonder whether there is a better solution to all of these.
> I think there is. We found that splitting the union of sender_cpu and
> napi_id solved the issue for us. In general, I think this is an OK
> solution as long as the following hold:
>
>   * skbs are always allocated via kzalloc
>   * out -> out cloned skbs are always cloned on the same CPU
>   * an extra four bytes in skbuff isn't a bad thing

I'm pretty sure extending sk_buff for this is not acceptable.
I was thinking may be we can use sign bit to distinguish between
napi_id and sender_cpu.
Like:
         if ((int)skb->sender_cpu >= 0)
                 skb->sender_cpu = - (raw_smp_processor_id() + 1);
and inside get_xps_queue() use it only if it's negative.
Then we can remove skb_sender_cpu_clear() from everywhere.
Adding a check to napi_hash_add() to make sure that napi_id is not
negative is probably ok too.
Thoughts?
