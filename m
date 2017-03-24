From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Fri, 24 Mar 2017 15:34:51 -0700
Message-ID: <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
 <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com> <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daurnimator <quae@daurnimator.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>, mtk.manpages@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:35646 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751417AbdCXWfN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 18:35:13 -0400
Received: by mail-wr0-f171.google.com with SMTP id u1so2009245wra.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 15:35:12 -0700 (PDT)
In-Reply-To: <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Cc'ing Michael Kerrisk)

On Wed, Mar 22, 2017 at 10:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-23 at 13:22 +1100, Daurnimator wrote:
>> On 9 March 2017 at 14:10, Daurnimator <quae@daurnimator.com> wrote:
>> > When debugging https://github.com/daurnimator/lua-http/issues/73 which
>> > uses https://github.com/wahern/dns we ran into an issue where modern
>> > linux kernels return EINVAL if you try and re-use a udp socket.
>> > The issue seems to occur if you go from a local destination ip to a
>> > non-local one.
>>
>> Did anyone get a chance to look into this issue?
>
> I believe man page is not complete.
>
> A disconnect is needed before another connect()

Is it? Making connect() reentrant is reasonable for connection-less
protocol like UDP, but I don't dig POSIX for the details. If so we need
something like below...

--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -40,7 +40,7 @@ int __ip4_datagram_connect(struct sock *sk, struct
sockaddr *uaddr, int addr_len
        sk_dst_reset(sk);

        oif = sk->sk_bound_dev_if;
-       saddr = inet->inet_saddr;
+       saddr = inet->inet_saddr = 0;
        if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
                if (!oif)
                        oif = inet->mc_index;
