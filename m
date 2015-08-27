From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v4 net-next 7/8] geneve: Consolidate Geneve functionality
 in single module.
Date: Wed, 26 Aug 2015 20:08:25 -0700
Message-ID: <CAEP_g=-YCEE_0h11vpwbdPQwRJoNgg7GvNr4xRMrBmu403BiPg@mail.gmail.com>
References: <1440626079-11689-1-git-send-email-pshelar@nicira.com> <1440626079-11689-8-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:33674 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbH0DIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 23:08:46 -0400
Received: by labns7 with SMTP id ns7so3785852lab.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 20:08:45 -0700 (PDT)
In-Reply-To: <1440626079-11689-8-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 2:54 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index d05150c..a36a1de 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -138,16 +164,18 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
>                 opts = ip_tunnel_info_opts(&tun_dst->u.tun_info,
>                                            gnvh->opt_len * 4);
>                 memcpy(opts, gnvh->options, gnvh->opt_len * 4);
> +               xnet = false;
>         } else {
>                 /* Drop packets w/ critical options,
>                  * since we don't support any...
>                  */
>                 if (gnvh->critical)
>                         goto drop;
> +               xnet = !net_eq(geneve->net, dev_net(geneve->dev));
>         }

Now that devices can be placed in any namespace, I think we can't
assume that xnet is false in the first case.

> @@ -293,15 +615,13 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
[...]
> +               err = geneve_build_skb(rt, skb, key->tun_flags, vni,
> +                                      info->options_len, opts, udp_csum);
> +               if (unlikely(err))
> +                       goto err;
[...]
>  tx_error:
> -       dev->stats.tx_errors++;
>         dev_kfree_skb(skb);
> +err:
> +       dev->stats.tx_errors++;
>         return NETDEV_TX_OK;
>  }

I'm not sure that it makes sense to break out these error conditions -
geneve_build_skb() doesn't free the skb, so it looks like there is a
leak on failure.
