From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: eBPF tunable max instructions or max tail call?
Date: Mon, 11 Jul 2016 20:14:49 -0700
Message-ID: <20160712031446.GA49510@ast-mbp.thefacebook.com>
References: <CAMp4zn-6G+41PrsAHH3ZuKcKa-o16_d7ZEuRE517v42iA=Y-Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36211 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932496AbcGLDOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 23:14:54 -0400
Received: by mail-pf0-f173.google.com with SMTP id t190so1608173pfb.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 20:14:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMp4zn-6G+41PrsAHH3ZuKcKa-o16_d7ZEuRE517v42iA=Y-Ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 05:56:07PM -0700, Sargun Dhillon wrote:
> It would be nice to have eBPF programs that are longer than 4096
> instructions. I'm trying to implement XSalsa20 in eBPF, and
> unfortunately, it doesn't fit into 4096 instructions since I'm
> unrolling all of the loops. Further than that, doing tail calls to
> process each block results in me hitting the tail call limit.

a cipher in bpf? wow. that's pushing it :)
we've been discussing various way of adding 'bounded loop' instruction
to avoid manual unrolling, but it will be still limited to the 4k
instruction per program, so probably won't help this use case.
Are you trying to do it in the networking context?

> It don't think that it makes much sense to expose the crypto API as
> BPF helpers, as I'm not sure if we can ensure safety, and timely
> execution with it. I may be wrong here, and if there is a sane, safe
> way to expose the crypto API, I'm all ears.

we had the patches to connect crypto api with bpf, but they were
too hacky to upstream, since then we redesigned the approach
and the latest should be much cleaner. The keys will be managed
through normal xfrm api and bpf will call into crypto with
mechanism similar to tail-call. The program will specify the
offset/length within the packet to encrypt/decrypt and next
program to execute when crypto operation completes.
Root only for xdp and tc only.

> Other than that, it would be nice to make the max instructions a knob,
> and I don't think that it has much downside, given it's only checked
> on load time. It would be nice to make the tail call limit a tunable
> as well, but I'm unsure of the performance impact it might have given
> that it's checked at runtime.
> 
> What do y'all think is reasonable? Make them both tunable? Just one? None?

It is preferred to achieve the goal without introducing a knob.
Also sounds like that increasing 4k to 8k won't really solve it anyway.
