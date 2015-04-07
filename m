From: Tom Herbert <tom@herbertland.com>
Subject: Re: [Patch net-next 3/5] fou: fix byte order of udp_config.local_udp_port
Date: Mon, 6 Apr 2015 23:09:09 -0700
Message-ID: <CALx6S350kJnG=Qv9MGBK9O9AciCU-y6s+moxm2oxCJ86SC1Eeg@mail.gmail.com>
References: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
	<1428363690-16288-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33249 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbDGGJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 02:09:10 -0400
Received: by iebmp1 with SMTP id mp1so38576359ieb.0
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 23:09:09 -0700 (PDT)
In-Reply-To: <1428363690-16288-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 6, 2015 at 4:41 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> udp_config.local_udp_port is be16. And iproute2 passes
> network order for FOU_ATTR_PORT.
>
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv4/fou.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
> index ad0ee82..cf606fc 100644
> --- a/net/ipv4/fou.c
> +++ b/net/ipv4/fou.c
> @@ -468,7 +468,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
>         sk = sock->sk;
>
>         fou->flags = cfg->flags;
> -       fou->port = cfg->udp_config.local_udp_port;
> +       fou->port = ntohs(cfg->udp_config.local_udp_port);
>
Cong, I don't think this is right. Port should always be nbo, probably
should be using __b16 instead of u16 for defines. Did you test these
changes?

>         /* Initial for fou type */
>         switch (cfg->type) {
> @@ -523,7 +523,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
>  static int fou_destroy(struct net *net, struct fou_cfg *cfg)
>  {
>         struct fou *fou;
> -       u16 port = cfg->udp_config.local_udp_port;
> +       u16 port = ntohs(cfg->udp_config.local_udp_port);
>         int err = -EINVAL;
>
>         spin_lock(&fou_lock);
> @@ -573,7 +573,7 @@ static int parse_nl_config(struct genl_info *info,
>         }
>
>         if (info->attrs[FOU_ATTR_PORT]) {
> -               u16 port = nla_get_u16(info->attrs[FOU_ATTR_PORT]);
> +               __be16 port = nla_get_be16(info->attrs[FOU_ATTR_PORT]);
>
>                 cfg->udp_config.local_udp_port = port;
>         }
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
