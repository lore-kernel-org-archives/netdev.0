From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v7 2/3] Add a eBPF helper function to retrieve
 socket uid
Date: Wed, 22 Mar 2017 11:09:38 +0000
Message-ID: <CAF=yD-+D5oHcU3qq4nDDWE1Bt4k2Vv9Ekf=FoKMdrc0F5dGS_Q@mail.gmail.com>
References: <1490133934-7055-1-git-send-email-chenbofeng.kernel@gmail.com> <1490133934-7055-3-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36687 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934031AbdCVLKl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 07:10:41 -0400
Received: by mail-qk0-f195.google.com with SMTP id n141so25633542qke.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 04:10:19 -0700 (PDT)
In-Reply-To: <1490133934-7055-3-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
> +{
> +       struct sock *sk = sk_to_full_sk(skb->sk);
> +       kuid_t kuid;
> +
> +       if (!sk || !sk_fullsock(sk))
> +               return overflowuid;
> +       kuid = sock_net_uid(sock_net(sk), sk);
> +       return from_kuid_munged(&init_user_ns, kuid);

Ideally, this would be the user namespace relative to the BPF program.

With no such association stored, using init_user_ns is fine. But if we
define it as such now, we cannot change it to resolve userns later.

We could associate a BPF program with the userns of the process that
loads the program. And expose bpf_prog state to external functions,
for instance through a perpcu local variable.

Also, unconditionally using init_user_ns will allow a process
sandboxed in a user namespace to learn its uid in the initns. If the
initns is not its parentns, this may be a new capability.
