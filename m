From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Fri, 09 Oct 2015 19:33:14 +0200
Message-ID: <5617FA5A.9090406@iogearbox.net>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net> <56153E6C.9050202@plumgrid.com> <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com> <561727D5.2070001@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"Devon H. O'Dell" <dho@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35089 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758117AbbJIRd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 13:33:27 -0400
In-Reply-To: <561727D5.2070001@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2015 04:35 AM, Alexei Starovoitov wrote:
> On 10/8/15 5:50 PM, Devon H. O'Dell wrote:
>>> with the amount of skb_sender_cpu_clear() all over the code base
>>> >I wonder whether there is a better solution to all of these.
>> I think there is. We found that splitting the union of sender_cpu and
>> napi_id solved the issue for us. In general, I think this is an OK
>> solution as long as the following hold:
>>
>>   * skbs are always allocated via kzalloc
>>   * out -> out cloned skbs are always cloned on the same CPU
>>   * an extra four bytes in skbuff isn't a bad thing
>
> I'm pretty sure extending sk_buff for this is not acceptable.

+1, I agree.

> I was thinking may be we can use sign bit to distinguish between
> napi_id and sender_cpu.
> Like:
>          if ((int)skb->sender_cpu >= 0)
>                  skb->sender_cpu = - (raw_smp_processor_id() + 1);
> and inside get_xps_queue() use it only if it's negative.
> Then we can remove skb_sender_cpu_clear() from everywhere.
> Adding a check to napi_hash_add() to make sure that napi_id is not
> negative is probably ok too.
> Thoughts?

I think this doesn't make it any more maintainable.

skb_sender_cpu_clear(), one can at least git-grep to easily find
out and review call-sites in the code. There are various members
already used differently depending on the context.

Thanks,
Daniel
