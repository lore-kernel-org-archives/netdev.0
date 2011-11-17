From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 2/2] team: avoid using variable-length array
Date: Thu, 17 Nov 2011 15:31:18 +0100
Message-ID: <1321540278.2751.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321539365-1125-1-git-send-email-jpirko@redhat.com>
	 <1321539365-1125-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com, mirqus@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50513 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757671Ab1KQObX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 09:31:23 -0500
Received: by bke11 with SMTP id 11so2050508bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 06:31:22 -0800 (PST)
In-Reply-To: <1321539365-1125-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 15:16 +0100, Jiri Pirko a =C3=A9crit :
> Apparently using variable-length array is not correct
> (https://lkml.org/lkml/2011/10/23/25). So remove it.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/team/team.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 5b169c1..c48ef19 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -96,10 +96,13 @@ int team_options_register(struct team *team,
>  			  size_t option_count)
>  {
>  	int i;
> -	struct team_option *dst_opts[option_count];
> +	struct team_option **dst_opts;
>  	int err;
> =20
> -	memset(dst_opts, 0, sizeof(dst_opts));
> +	dst_opts =3D kzalloc(sizeof(struct team_option *) * option_count,
> +			   GFP_KERNEL);
> +	if (!dst_opts)
> +		return -ENOMEM;
>  	for (i =3D 0; i < option_count; i++, option++) {
>  		struct team_option *dst_opt;
> =20
> @@ -119,12 +122,14 @@ int team_options_register(struct team *team,
>  	for (i =3D 0; i < option_count; i++)
>  		list_add_tail(&dst_opts[i]->list, &team->option_list);
> =20
> +	kfree(dst_opts);
>  	return 0;
> =20
>  rollback:
>  	for (i =3D 0; i < option_count; i++)
>  		kfree(dst_opts[i]);
> =20
> +	kfree(dst_opts);
>  	return err;
>  }
> =20

Please use kmemdup() as well, or someone else will do it ;)

dst_opt =3D kmalloc(sizeof(*option), GFP_KERNEL);
=2E..
memcpy(dst_opt, option, sizeof(*option));

-> dst_opt =3D kmemdup(...);
