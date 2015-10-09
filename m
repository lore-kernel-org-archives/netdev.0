From: "Devon H. O'Dell" <dho@fastly.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before xmit
Date: Thu, 8 Oct 2015 17:50:13 -0700
Message-ID: <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
	<56153E6C.9050202@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34997 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933655AbbJIAuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 20:50:14 -0400
Received: by obbzf10 with SMTP id zf10so51477457obb.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 17:50:13 -0700 (PDT)
In-Reply-To: <56153E6C.9050202@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 8:46 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 10/7/15 1:16 AM, Daniel Borkmann wrote:
>>
>> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before
>> forwarding"), we also need to clear the skb->sender_cpu when moving
>> from RX to TX via skb_do_redirect() due to the shared location of
>> napi_id (used on RX) and sender_cpu (used on TX).
>>
>> Fixes: 27b29f63058d ("bpf: add bpf_redirect() helper")
>> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
>
>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>
> with the amount of skb_sender_cpu_clear() all over the code base
> I wonder whether there is a better solution to all of these.

I think there is. We found that splitting the union of sender_cpu and
napi_id solved the issue for us. In general, I think this is an OK
solution as long as the following hold:

 * skbs are always allocated via kzalloc
 * out -> out cloned skbs are always cloned on the same CPU
 * an extra four bytes in skbuff isn't a bad thing

I think the first and last points are true, but I'm not 100% sure. I'm
also particularly unsure about the second point. If that assumption
does not hold, it could result in extra cache / bus traffic between
cores / sockets. However, that would also imply that we were already
getting some extra traffic at the point of doing the copy. So maybe
not a big deal? The other problem I could imagine is if the second
point *is* true and skbs end up being cloned multiple times, XPS might
get overworked on individual cores.

Anyway, I'm not 100% sure about any of these things: I'm really not at
all familiar with the Linux kernel, let alone the netstack -- this
just turned out to be not particularly difficult to find given
register context and call stack from the panic. I'd be happy to send a
patch to struct skbuff and toss skb_sender_cpu_clear, but I suspect
someone else on this list could validate that quicker than I. The
patch at that point is trivial.

I think it's probably a good thing to do. The need to call
skb_sender_cpu_clear() around every rx->tx copy interaction seems
brittle and likely to be problematic again in the future unless code
is always cargo culted, and assuming we've found every potential clone
site.

--dho
