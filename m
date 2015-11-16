From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Mon, 16 Nov 2015 10:07:56 -0800
Message-ID: <1447697276.22599.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
	 <56153E6C.9050202@plumgrid.com>
	 <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
	 <561727D5.2070001@plumgrid.com> <5617FA5A.9090406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"Devon H. O'Dell" <dho@fastly.com>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35997 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbbKPSH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 13:07:59 -0500
Received: by pacdm15 with SMTP id dm15so182058964pac.3
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 10:07:59 -0800 (PST)
In-Reply-To: <5617FA5A.9090406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-09 at 19:33 +0200, Daniel Borkmann wrote:
> On 10/09/2015 04:35 AM, Alexei Starovoitov wrote:
> > On 10/8/15 5:50 PM, Devon H. O'Dell wrote:
> >>> with the amount of skb_sender_cpu_clear() all over the code base
> >>> >I wonder whether there is a better solution to all of these.
> >> I think there is. We found that splitting the union of sender_cpu and
> >> napi_id solved the issue for us. In general, I think this is an OK
> >> solution as long as the following hold:
> >>
> >>   * skbs are always allocated via kzalloc
> >>   * out -> out cloned skbs are always cloned on the same CPU
> >>   * an extra four bytes in skbuff isn't a bad thing
> >
> > I'm pretty sure extending sk_buff for this is not acceptable.
> 
> +1, I agree.
> 
> > I was thinking may be we can use sign bit to distinguish between
> > napi_id and sender_cpu.
> > Like:
> >          if ((int)skb->sender_cpu >= 0)
> >                  skb->sender_cpu = - (raw_smp_processor_id() + 1);
> > and inside get_xps_queue() use it only if it's negative.
> > Then we can remove skb_sender_cpu_clear() from everywhere.
> > Adding a check to napi_hash_add() to make sure that napi_id is not
> > negative is probably ok too.
> > Thoughts?
> 
> I think this doesn't make it any more maintainable.
> 
> skb_sender_cpu_clear(), one can at least git-grep to easily find
> out and review call-sites in the code. There are various members
> already used differently depending on the context.

Extending busy polling support for tunnels devices actually requires to
make some changes in this area.

We need to keep skb->napi_id set until skb reaches a socket, but
skb_scrub_packet() currently defeats the thing.

I will leave skb_sender_cpu_clear() in place but it will be empty.
