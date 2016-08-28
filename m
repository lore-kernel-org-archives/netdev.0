From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net 0/2] ppp: fix deadlock upon recursive xmit
Date: Sun, 28 Aug 2016 20:18:24 +0800
Message-ID: <CA+6hz4qY0jLndSMmb1U+8DGzDg6XRUDzyBrM-HKBVF0irx6ZTw@mail.gmail.com>
References: <20160827202034.6rfolco57rgsstzl@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Paul Mackerras <paulus@samba.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:36024 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932271AbcH1MS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 08:18:26 -0400
Received: by mail-ua0-f170.google.com with SMTP id m60so165894666uam.3
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 05:18:25 -0700 (PDT)
In-Reply-To: <20160827202034.6rfolco57rgsstzl@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2016 at 4:20 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> This series fixes the issue reported by Feng where packets looping
> through a ppp device makes the module deadlock:
> https://marc.info/?l=linux-netdev&m=147134567319038&w=2
>
> The problem can occur on virtual interfaces (e.g. PPP over L2TP, or
> PPPoE on vxlan devices), when a PPP packet is routed back to the PPP
> interface.
>
> PPP's xmit path isn't reentrant, so patch #1 uses a per-cpu variable
> to detect and break recursion. Patch #2 sets the NETIF_F_LLTX flag to
> avoid lock inversion issues between ppp and txqueue locks.
>
> There are multiple entry points to the PPP xmit path. This series has
> been tested with lockdep and should address recursion issues no matter
> how the packet entered the path.
>
>
> A similar issue in L2TP is not covered by this series:
> l2tp_xmit_skb() also isn't reentrant, and it can be called as part of
> PPP's xmit path (pppol2tp_xmit()), or directly from the L2TP socket
> (l2tp_ppp_sendmsg()). If a packet is sent by l2tp_ppp_sendmsg() and
> routed to the parent PPP interface, then it's going to hit
> l2tp_xmit_skb() again.
>
> Breaking recursion as done in ppp_generic is not enough, because we'd
> still have a lock inversion issue (locking in l2tp_xmit_skb() can
> happen before or after locking in ppp_generic). The best approach would
> be to use the ip_tunnel functions and remove the socket locking in
> l2tp_xmit_skb(). But that'd be something for net-next.
>
>
> BTW, I hope the commit messages aren't too long. Just let me know if I
> should trim something.
>
>
> Guillaume Nault (2):
>   ppp: avoid dealock on recursive xmit
>   ppp: declare PPP devices as LLTX
>
>  drivers/net/ppp/ppp_generic.c | 54 +++++++++++++++++++++++++++++++++----------
>  1 file changed, 42 insertions(+), 12 deletions(-)
>
> --
> 2.9.3
>

I am learning your codes. It is better than my solution :))

Best Regards
Feng
