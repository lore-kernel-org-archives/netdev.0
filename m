From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next v3 07/15] bpf: Add setsockopt helper function to bpf
Date: Tue, 20 Jun 2017 17:25:46 -0400
Message-ID: <CAEfhGiyi4xb6HmfUJmXxgvCUGmW6p37yoqVio=PcUn091hBUsA@mail.gmail.com>
References: <20170620030048.3275347-1-brakmo@fb.com> <20170620030048.3275347-8-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
        Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35998 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdFTVZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 17:25:50 -0400
Received: by mail-qt0-f193.google.com with SMTP id s33so24890100qtg.3
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 14:25:50 -0700 (PDT)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com. [209.85.216.180])
        by smtp.gmail.com with ESMTPSA id t42sm9539890qtg.43.2017.06.20.14.25.47
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 14:25:48 -0700 (PDT)
Received: by mail-qt0-f180.google.com with SMTP id v20so27702354qtg.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 14:25:47 -0700 (PDT)
In-Reply-To: <20170620030048.3275347-8-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 19, 2017 at 11:00 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
> Added support for calling a subset of socket setsockopts from
> BPF_PROG_TYPE_SOCK_OPS programs. The code was duplicated rather
> than making the changes to call the socket setsockopt function because
> the changes required would have been larger.
>
> @@ -2671,6 +2672,69 @@ static const struct bpf_func_proto bpf_get_socket_uid_proto = {
>         .arg1_type      = ARG_PTR_TO_CTX,
>  };
>
> +BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
> +          int, level, int, optname, char *, optval, int, optlen)
> +{
> +       struct sock *sk = bpf_sock->sk;
> +       int ret = 0;
> +       int val;
> +
> +       if (bpf_sock->is_req_sock)
> +               return -EINVAL;
> +
> +       if (level == SOL_SOCKET) {
> +               /* Only some socketops are supported */
> +               val = *((int *)optval);
> +
> +               switch (optname) {
> +               case SO_RCVBUF:
> +                       sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
> +                       sk->sk_rcvbuf = max_t(int, val * 2, SOCK_MIN_RCVBUF);
> +                       break;
> +               case SO_SNDBUF:
> +                       sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
> +                       sk->sk_sndbuf = max_t(int, val * 2, SOCK_MIN_SNDBUF);
> +                       break;
> +               case SO_MAX_PACING_RATE:
> +                       sk->sk_max_pacing_rate = val;
> +                       sk->sk_pacing_rate = min(sk->sk_pacing_rate,
> +                                                sk->sk_max_pacing_rate);
> +                       break;
> +               case SO_PRIORITY:
> +                       sk->sk_priority = val;
> +                       break;
> +               case SO_RCVLOWAT:
> +                       if (val < 0)
> +                               val = INT_MAX;
> +                       sk->sk_rcvlowat = val ? : 1;
> +                       break;
> +               case SO_MARK:
> +                       sk->sk_mark = val;
> +                       break;

Isn't the socket lock required when manipulating these fields?  It's
not obvious that the lock is held from every bpf hook point that could
trigger this function...
