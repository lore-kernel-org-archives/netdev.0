From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: BUG triggered in tcp_openreq_init_rwin most likely due to 13d3b1ebe2876
Date: Mon, 17 Jul 2017 10:23:54 -0700
Message-ID: <CAM_iQpVv9Qxn+B01Ccvi+P5UPytqCr3i2rybG4RZdDjuyLgdbw@mail.gmail.com>
References: <5d6eb001-2f2b-d9d4-5c5e-a0b22cd53f65@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Lawrence Brakmo <brakmo@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35278 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdGQRYQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 13:24:16 -0400
Received: by mail-wm0-f51.google.com with SMTP id w126so82712840wme.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 10:24:15 -0700 (PDT)
In-Reply-To: <5d6eb001-2f2b-d9d4-5c5e-a0b22cd53f65@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 16, 2017 at 4:47 PM, David Ahern <dsahern@gmail.com> wrote:
> Hi:
>
> I am getting the following while testing IPv6 changes:
>
> [ 3904.250981] TCP: request_sock_TCPv6: Possible SYN flooding on port
> 12345. Sending cookies.  Check SNMP counters.
> [ 3904.252862]
> ==================================================================
> [ 3904.254057] BUG: KASAN: null-ptr-deref in
> tcp_openreq_init_rwin+0x1d5/0x2b4
> [ 3904.255113] Read of size 1 at addr 0000000000000012 by task vrf-test/1166
> [ 3904.256149]
> [ 3904.256405] CPU: 0 PID: 1166 Comm: vrf-test Not tainted 4.12.0+ #307
> [ 3904.257373] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [ 3904.258899] Call Trace:
> [ 3904.259291]  <IRQ>
> [ 3904.259629]  dump_stack+0x81/0xb6
> [ 3904.260167]  kasan_report+0x234/0x269
> [ 3904.260688]  __asan_load1+0x45/0x47
> [ 3904.261176]  tcp_openreq_init_rwin+0x1d5/0x2b4
> [ 3904.261811]  tcp_conn_request+0xb1e/0xe11
> [ 3904.262448]  tcp_v6_conn_request+0x72/0x85
> [ 3904.263010]  ? tcp_v6_conn_request+0x72/0x85
> [ 3904.263605]  tcp_rcv_state_process+0xe6/0x1243
> [ 3904.264236]  ? lock_release+0x27f/0x444
> [ 3904.264793]  tcp_v6_do_rcv+0x321/0x559
> [ 3904.265316]  ? tcp_v6_do_rcv+0x321/0x559
> [ 3904.265858]  ? tcp_filter+0x82/0x95
> [ 3904.266357]  tcp_v6_rcv+0x6c7/0xb33
> [ 3904.266886]  ip6_input_finish+0x1de/0x5ca
> [ 3904.267471]  ip6_input+0x66/0x6c
>
>
> This is enough to prevent the problem the crash which suggest the recent
> bpf sock_ops is the culprit:
>
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 0ff83c1637d8..88904882b4ad 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -364,7 +364,7 @@ void tcp_openreq_init_rwin(struct request_sock *req,
>             (req->rsk_window_clamp > full_space || req->rsk_window_clamp
> == 0))
>                 req->rsk_window_clamp = full_space;
>
> -       rcv_wnd = tcp_rwnd_init_bpf((struct sock *)req);
> +       rcv_wnd = 0; // tcp_rwnd_init_bpf((struct sock *)req);
>         if (rcv_wnd == 0)
>                 rcv_wnd = dst_metric(dst, RTAX_INITRWND);
>         else if (full_space < rcv_wnd * mss)


I bet req->rsk_listener is NULL, I guess we need the following fix:

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 360c082e885c..d41d40ac3efd 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -85,7 +85,7 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
        int __ret = 0;                                                         \
        if (cgroup_bpf_enabled && (sock_ops)->sk) {            \
                typeof(sk) __sk = sk_to_full_sk((sock_ops)->sk);               \
-               if (sk_fullsock(__sk))                                         \
+               if (__sk && sk_fullsock(__sk))                                 \
                        __ret = __cgroup_bpf_run_filter_sock_ops(__sk,         \
                                                                 sock_ops,     \
                                                         BPF_CGROUP_SOCK_OPS); \
