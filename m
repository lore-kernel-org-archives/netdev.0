From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 7/9] geneve: Consolidate Geneve functionality
 in single module.
Date: Wed, 19 Aug 2015 11:18:49 -0700
Message-ID: <CAEP_g=_4FHejf_qfXbXzO3kyx1WJ2ssOY9OMF=vySFNu-CPOqA@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com> <1439845905-31666-8-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35499 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbbHSSTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:19:11 -0400
Received: by lbcbn3 with SMTP id bn3so8747637lbc.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:19:09 -0700 (PDT)
In-Reply-To: <1439845905-31666-8-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index e58468b..18ff83b 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -181,7 +181,7 @@ config VXLAN
>
>  config GENEVE
>         tristate "Generic Network Virtualization Encapsulation netdev"
> -       depends on INET && GENEVE_CORE
> +       depends on INET
>         select NET_IP_TUNNEL

I think my comments on v1 one this patch were overlooked (about the
UDP_TUNNEL dependency and the name).

> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 5b43382..eb298ff 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> +static void geneve_build_header(struct genevehdr *geneveh,
> +                               __be16 tun_flags, u8 vni[3],
> +                               u8 options_len, u8 *options)
[...]
> +static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
> +                           __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
> +                           bool csum)

It seems like we could just merge these functions. I'm not sure that
the role is all that different.

In geneve_build_skb(), the error labels are somewhat confusing (for
example, free_rt doesn't free the rt). Also, is it right that we don't
free the rt if udp_tunnel_handle_offloads() fails()? It might be
cleaner if the caller retains ownership of rt.

My guess is that if the issue from the earlier patch about overlapping
collect_md tunnels is fixed then that might allow us to simplify
things a little further, since for those tunnels we can assume there
is a 1:1 mapping between collect_md tunnels and sockets.
