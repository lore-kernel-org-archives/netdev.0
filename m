From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v3 net-next] net: diag: support SOCK_DESTROY for UDP sockets
Date: Wed, 24 Aug 2016 01:37:54 +0900
Message-ID: <CAKD1Yr19f3E-z4Lat-YDwJ7U7-fmVBeissz08dsk2o+196OQRQ@mail.gmail.com>
References: <1471964547-18098-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:37073 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752798AbcHWQjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 12:39:15 -0400
Received: by mail-it0-f53.google.com with SMTP id f6so144586204ith.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 09:38:15 -0700 (PDT)
In-Reply-To: <1471964547-18098-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 12:02 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> +int udp_abort(struct sock *sk, int err)
> +{
> +       lock_sock(sk);
> +
> +       sk->sk_err = err;
> +       sk->sk_error_report(sk);
> +       udp_disconnect(sk, 0);

I notice that udp_disconnect does "inet->inet_daddr = 0" but doesn't
touch sk_v6_daddr. I wonder if that's correct. Even if it isn't,
that's likely not specific to this patch, since udpv6_prot specifies
udp_disconnect as its disconnect function pointer.

> +       if (req->sdiag_family == AF_INET)
> +               sk = __udp4_lib_lookup(net,
> +                               req->id.idiag_dst[0], req->id.idiag_dport,
> +                               req->id.idiag_src[0], req->id.idiag_sport,
> +                               req->id.idiag_if, tbl, NULL);
> +#if IS_ENABLED(CONFIG_IPV6)
> +       else if (req->sdiag_family == AF_INET6)
> +               sk = __udp6_lib_lookup(net,

I think you need to check for mapped addresses like Eric added to
inet_diag_find_one_icsk in 7c1306723 .

> +                               (struct in6_addr *)req->id.idiag_dst,
> +                               req->id.idiag_dport,
> +                               (struct in6_addr *)req->id.idiag_src,
> +                               req->id.idiag_sport,
> +                               req->id.idiag_if, tbl, NULL);
> +#endif

If you want to be consistent with what the TCP code does, return
-EINVAL here instead of -ENOENT if an invalid address family was
passed in (e.g., if user passes in AF_INET6 and IPv6 is not compiled
in).

> +       if (sock_diag_check_cookie(sk, req->id.idiag_cookie)) {
> +               sock_put(sk);
> +               return -ENOENT;
> +       }
> +
> +       return sock_diag_destroy(sk, ECONNABORTED);

Looking at the code again, it seems that there's a bug in
sock_diag_destroy. If the destroy operation does not occur (e.g., if
sock_diag_destroy returns EPERM, or the protocol doesn't support
destroy), then it doesn't release the refcount. This affects the TCP
code as well and as such is my fault, not yours. The most obvious way
to fix this might be to call sock_gen_put in sock_diag_destroy.
