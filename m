From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [Patch] arp: fix a regression in arp_solicit()
Date: Sun, 23 Dec 2012 15:49:58 +0100
Message-ID: <CA+icZUWKNAGe+jMbsonrigVZ5Sk7dDdciZn1r7oMcsAWe7i3fQ@mail.gmail.com>
References: <1356273778-19113-1-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:49426 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab2LWOt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 09:49:59 -0500
Received: by mail-qa0-f53.google.com with SMTP id a19so4442120qad.12
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2012 06:49:58 -0800 (PST)
In-Reply-To: <1356273778-19113-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 23, 2012 at 3:42 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
>
> Sedat reported the following commit caused a regression:
>
> commit 9650388b5c56578fdccc79c57a8c82fb92b8e7f1
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Fri Dec 21 07:32:10 2012 +0000
>
>     ipv4: arp: fix a lockdep splat in arp_solicit
>
> This is due to the 6th parameter of arp_send() needs to be NULL
> for broatcase case, the above commit changed it to all-zero non-NULL
> hw addr.
>

s/broatcase/broadcast ?

- Sedat -

> Reported-by: Sedat Dilek <sedat.dilek@gmail.com>
> Tested-by: Sedat Dilek <sedat.dilek@gmail.com>
> Cc: Sedat Dilek <sedat.dilek@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> ---
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 1169ed4..9547a273 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -321,7 +321,7 @@ static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb)
>  static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>  {
>         __be32 saddr = 0;
> -       u8 dst_ha[MAX_ADDR_LEN];
> +       u8 dst_ha[MAX_ADDR_LEN], *dst_hw = NULL;
>         struct net_device *dev = neigh->dev;
>         __be32 target = *(__be32 *)neigh->primary_key;
>         int probes = atomic_read(&neigh->probes);
> @@ -364,8 +364,8 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>                 if (!(neigh->nud_state & NUD_VALID))
>                         pr_debug("trying to ucast probe in NUD_INVALID\n");
>                 neigh_ha_snapshot(dst_ha, neigh, dev);
> +               dst_hw = dst_ha;
>         } else {
> -               memset(dst_ha, 0, dev->addr_len);
>                 probes -= neigh->parms->app_probes;
>                 if (probes < 0) {
>  #ifdef CONFIG_ARPD
> @@ -376,7 +376,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>         }
>
>         arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
> -                dst_ha, dev->dev_addr, NULL);
> +                dst_hw, dev->dev_addr, NULL);
>  }
>
>  static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
