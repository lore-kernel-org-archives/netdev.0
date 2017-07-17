From: David Ahern <dsahern@gmail.com>
Subject: Re: BUG triggered in tcp_openreq_init_rwin most likely due to
 13d3b1ebe2876
Date: Mon, 17 Jul 2017 11:47:20 -0600
Message-ID: <0538488c-6b63-eff8-23a4-6ef79ebd1868@gmail.com>
References: <5d6eb001-2f2b-d9d4-5c5e-a0b22cd53f65@gmail.com>
 <CAM_iQpVv9Qxn+B01Ccvi+P5UPytqCr3i2rybG4RZdDjuyLgdbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Lawrence Brakmo <brakmo@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36412 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdGQRrX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 13:47:23 -0400
Received: by mail-pg0-f45.google.com with SMTP id u5so20968088pgq.3
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 10:47:22 -0700 (PDT)
In-Reply-To: <CAM_iQpVv9Qxn+B01Ccvi+P5UPytqCr3i2rybG4RZdDjuyLgdbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/17/17 11:23 AM, Cong Wang wrote:
> I bet req->rsk_listener is NULL, I guess we need the following fix:
> 
> diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
> index 360c082e885c..d41d40ac3efd 100644
> --- a/include/linux/bpf-cgroup.h
> +++ b/include/linux/bpf-cgroup.h
> @@ -85,7 +85,7 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
>         int __ret = 0;                                                         \
>         if (cgroup_bpf_enabled && (sock_ops)->sk) {            \
>                 typeof(sk) __sk = sk_to_full_sk((sock_ops)->sk);               \
> -               if (sk_fullsock(__sk))                                         \
> +               if (__sk && sk_fullsock(__sk))                                 \
>                         __ret = __cgroup_bpf_run_filter_sock_ops(__sk,         \
>                                                                  sock_ops,     \
>                                                          BPF_CGROUP_SOCK_OPS); \
> 

safe bet. I should have seen that since objdump on the address pointed to

        return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);

in sk_fullsock.

Tested-by: David Ahern <dsahern@gmail.com>
