From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH next] neigh: initialize neigh entry correctly during arp processing
Date: Thu, 17 Aug 2017 09:58:33 +0900
Message-ID: <CAPA1RqDjJvZkCTt0w=4LPps1vCdKEEVemXWjBXRkZMQGaLPDnw@mail.gmail.com>
References: <20170817000251.38469-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Ido Schimmel <idosch@mellanox.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Reshetova Elena <elena.reshetova@intel.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Florian Westphal <fw@strlen.de>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Ihar Hrachyshka <ihrachys@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        Mahesh Bandewar <maheshb@google.com>,
        =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:35672 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751490AbdHQA6y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 20:58:54 -0400
Received: by mail-it0-f53.google.com with SMTP id 76so24966744ith.0
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 17:58:54 -0700 (PDT)
In-Reply-To: <20170817000251.38469-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2017-08-17 9:02 GMT+09:00 Mahesh Bandewar <mahesh@bandewar.net>:
> From: Mahesh Bandewar <maheshb@google.com>
>
> If the ARP processing creates a neigh entry, it's immediately marked
> as STALE without timer and stays that way in that state as long as
> host do not send traffic to that neighbour.
>
> I observed this on hosts which are in IPv6 environment, where there is
> very little to no IPv4 traffic and neigh-entries are stuck in STALE
> mode. Ideally, the host should have PROBEd these neighbours before it
> can send the first packet out.

No, we do not probe neighbors until we have packet for/through
it.


>
> It happens as a result of following call sequence in an environment
> where host is mostly quiet as far as IPv4 traffic but few connected
> hosts/gateways are sending ARPs.
>
>    arp_process()
>      neigh_event_ns()
>        neigh_lookup()
>          neigh_create()
>            neigh_alloc()
>              nud_state=NUD_NONE
>      neigh_update(nud_state=NUD_STALE)
>
> In the above scenario, the neighbour entry does not get a chance to get
> PROBEd as subsequent call to neigh_update() marks  this entry STALE.
> This patch initializes the neigh-entry correctly if it was created as a
> result of neigh_lookup instead of just updating it in neigh_event_ns()
> right after creating it.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  net/core/neighbour.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 16a1a4c4eb57..d8a35db6c43b 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1300,9 +1300,13 @@ struct neighbour *neigh_event_ns(struct neigh_table *tbl,
>  {
>         struct neighbour *neigh = __neigh_lookup(tbl, saddr, dev,
>                                                  lladdr || !dev->addr_len);
> -       if (neigh)
> -               neigh_update(neigh, lladdr, NUD_STALE,
> -                            NEIGH_UPDATE_F_OVERRIDE, 0);
> +       if (neigh) {
> +               if (neigh->nud_state & NUD_VALID)
> +                       neigh_update(neigh, lladdr, NUD_STALE,
> +                                    NEIGH_UPDATE_F_OVERRIDE, 0);
> +               else
> +                       neigh_event_send(neigh, NULL);
> +       }
>         return neigh;
>  }
>  EXPORT_SYMBOL(neigh_event_ns);
> --
> 2.14.1.480.gb18f417b89-goog
>
