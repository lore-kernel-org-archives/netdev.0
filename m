From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab name
Date: Sat, 14 May 2016 14:31:04 -0700
Message-ID: <CA+55aFx_PuzNC0riLEN7PUpVnvQg374ZqCYBV-Uw6Be-OA=DwQ@mail.gmail.com>
References: <alpine.LFD.2.20.1605141116100.24646@i7>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Network Development List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36567 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038AbcENVbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 17:31:05 -0400
Received: by mail-io0-f193.google.com with SMTP id k129so19935193iof.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 14:31:04 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1605141116100.24646@i7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 11:24 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> -       net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%p", net);
> +       net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%llu",
> +                               (u64)atomic64_inc_return(&unique_id));

Oh well. I suspect this is going to cause a new warning on alpha and
ia64 and possibly others.

"u64" is indeed "unsigned long long" on x86 and many other
architectures, but on alpga and ia64 it's just "unsigned long".

So that case should have been to "long long". I detest how there isn't
a "64-bit size" printf specifier.

And no, PRId64 preprocessor garbage and similar disgusting hacks by
POSIX isn't the answer. I think MSC actually got that right with
"%I64d".

Oh well. It's a fairly harmless compiler warning, it isn't a code
correctness issue.

               Linus
