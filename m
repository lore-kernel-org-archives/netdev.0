From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] tcp: Always cleanup skb before sending
Date: Wed, 1 Nov 2017 14:32:53 -0700
Message-ID: <CANn89iLv+0+A79-pNu8HZ2kBbyNt2ini2Zjbm++s9TT7mtOamw@mail.gmail.com>
References: <20171101211001.57901-1-cpaasch@apple.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:56440 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934466AbdKAVcz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:32:55 -0400
Received: by mail-wm0-f53.google.com with SMTP id z3so7385413wme.5
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:32:55 -0700 (PDT)
In-Reply-To: <20171101211001.57901-1-cpaasch@apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 1, 2017 at 2:10 PM, Christoph Paasch <cpaasch@apple.com> wrote:
> Since commit 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache
> line misses") IPCB/IP6CB is no more at the beginning of the tcp_skb_cb.
> This means that on the output path, we need to make sure that it has
> been correctly initialized to 0, as is done in tcp_transmit_skb.
>
> However, when going through the other code-path in TCP that can send an
> skb (e.g., through tcp_v6_send_synack), we end up in a situation where
> IP6CB has some of its fields set to unexpected values. Depending on the
> layout of tcp_skb_cb across the different kernel-versions this can be
> lastopt, flags,...

Or not use tcp_init_nondata_skb() on non fast clones, since it adds
unnecessary writes and clears.

tcp_make_synack() really has no business using tcp_init_nondata_skb()
and could simply set th->seq = htonl(tcp_rsk(req)->snt_isn);
