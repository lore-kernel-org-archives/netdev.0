From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] dccp: fix use-after-free in dccp_feat_activate_values
Date: Sun, 5 Mar 2017 21:38:07 -0800
Message-ID: <CAM_iQpUwGN_M8SVWVprUk04fduOb_Fd7kXWhoJWMi5dUQ6RPcQ@mail.gmail.com>
References: <CAAeHK+xDhUDe9_-uEakJG9iqTtD_+fFr+JyUbkWCHHLBCcu1uQ@mail.gmail.com>
 <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
 <CACT4Y+YUJGsvzFuFT3r0M-3KbPrcx62fzSHHQX=B43-syLYU0A@mail.gmail.com>
 <1488551576.9415.328.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488552503.9415.330.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+Z6t_jGoh3Gm3Sxuu_ugF5kQ3QJ37LVdqoEK_ab52tQMA@mail.gmail.com>
 <CACT4Y+ZhNzcKTODGkD3R-68KgkOtYCaf4cZYPH51=HhREXVPGg@mail.gmail.com>
 <CANn89i+E+DkUJBV-3AQ38hstj9=G7=3fLJuG8LA6upp77ecwPA@mail.gmail.com>
 <1488556814.9415.334.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+Zg9PptopGHPBYmf_2hfHg3kTrTkyhQuT9C7Krf4nX6AA@mail.gmail.com> <1488739936.9415.368.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:33528 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750982AbdCFFrl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 00:47:41 -0500
Received: by mail-wr0-f176.google.com with SMTP id u48so108622041wrc.0
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 21:46:48 -0800 (PST)
In-Reply-To: <1488739936.9415.368.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 5, 2017 at 10:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> --- a/net/dccp/minisocks.c
> +++ b/net/dccp/minisocks.c
> @@ -142,6 +142,13 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
>         struct dccp_request_sock *dreq = dccp_rsk(req);
>         bool own_req;
>
> +       /* TCP/DCCP listeners became lockless.
> +        * DCCP stores complex state in its request_sock, so we need
> +        * a protection for them, now this code runs without being protected
> +        * by the parent (listener) lock.
> +        */
> +       spin_lock_bh(&dreq->dreq_lock);
> +

Do you really want to disable BH again here?

dccp_check_req() should be always called on RX path where BH
is already disabled and BH can't be disabled twice?
