From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next 2/2] Add a eBPF helper function to retrieve
 socket uid
Date: Fri, 3 Feb 2017 10:18:37 +0900
Message-ID: <CAKD1Yr1tPP-7ic4nreqzKk6Gb+ZgyKo8yqw-KP=w7oqABkiZQA@mail.gmail.com>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com>
 <20170202205950.100334-3-chenbofeng.kernel@gmail.com> <5893A587.6090000@iogearbox.net>
 <CAKD1Yr30K4Yi8U0bnTOq60rPW6aYY1Vb4xxmRgZdz319UmLmRw@mail.gmail.com> <1486081861.21871.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:34138 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751831AbdBCBS7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 20:18:59 -0500
Received: by mail-ua0-f180.google.com with SMTP id 35so3835613uak.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 17:18:58 -0800 (PST)
In-Reply-To: <1486081861.21871.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 9:31 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> It should be safe to call sock_net_uid on any type of socket
>> (including NULL). sk_uid was added to struct sock in 86741ec25462
>> ("net: core: Add a UID field to struct sock.")
>
> But a request socket or a timewait socket do not have this field.
>
> Daniel point is valid.

My bad. Yes.

It would definitely be useful to have the UID available in request
sockets, and perhaps timewait sockets as well. That could be done by
moving the UID to sock_common, or with something along the lines of:

 static inline kuid_t sock_net_uid(const struct net *net, const struct sock *sk)
 {
+       if (sk && sk->sk_state == TCP_NEW_SYN_RECV)
+               sk = sk->__sk_common.skc_listener;
+       else if (sk && !sk_fullsock(sk))
+               sk = NULL;
+
        return sk ? sk->sk_uid : make_kuid(net->user_ns, 0);
 }

Any thoughts on which is better?
