From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next 1/1] net: reflect mark on tcp syn ack packets
Date: Tue, 13 Jun 2017 22:58:24 +0900
Message-ID: <CAKD1Yr1uGL-OPUJ76D=md8kCT0psreew20Em=BokHWEYdP9xOg@mail.gmail.com>
References: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mrv@mojatatu.com, Jamal Hadi Salim <hadi@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:35113 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbdFMN6p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 09:58:45 -0400
Received: by mail-vk0-f52.google.com with SMTP id 191so64299700vko.2
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 06:58:45 -0700 (PDT)
In-Reply-To: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 10, 2017 at 10:31 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>         skb->priority = sk->sk_priority;
> -       skb->mark = sk->sk_mark;
> +       if (!skb->mark)
> +               skb->mark = sk->sk_mark;

It looks a bit iffy to take sk->sk_mark only if skb->mark is zero
instead of relying on the callers to tell this function what they
want. I think the patch is correct, but it might be better to fix the
other callers (dccp_make_response and dccp_ctl_make_reset) to set
skb->mark to what they want. Either way.

>         tcp_ecn_make_synack(req, th);
>         th->source = htons(ireq->ir_num);
>         th->dest = ireq->ir_rmt_port;
> +       if (sock_net(sk)->ipv4.sysctl_tcp_fwmark_accept)
> +               skb->mark = ireq->ir_mark;

I think checking the sysctl here is unnecessary. It seems to me that
ir_mark already takes that into account. Its semantics (see
inet_request_mark) are:

- If listen socket has a nonzero mark, use that
- Else if sysctl_tcp_fwmark_accept is set and inbound SYN packet has
mark, use that
- Else zero.

which is what you want.

Other than that,

Reviewed-By: Lorenzo Colitti <lorenzo@google.com>

Please disregard my earlier comment about fwmark_reflect - I didn't
notice that the code sets ir_mark based on tcp_fwmark_accept, and
doesn't look at fwmark_reflect at all.
