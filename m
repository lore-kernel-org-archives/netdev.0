From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 1/3] team: Do not hold rcu_read_lock when
 running netlink cmds
Date: Wed, 16 Nov 2011 22:17:24 +0100
Message-ID: <1321478244.3274.5.camel@edumazet-laptop>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
	 <1321477749-1877-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47364 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab1KPVR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 16:17:29 -0500
Received: by wyh11 with SMTP id 11so1079211wyh.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 13:17:28 -0800 (PST)
In-Reply-To: <1321477749-1877-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 novembre 2011 =C3=A0 22:09 +0100, Jiri Pirko a =C3=A9cri=
t :
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/team/team.c |   12 ++++--------
>  1 files changed, 4 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 60672bb..e0cf11c 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1043,8 +1043,7 @@ err_msg_put:
> =20
>  /*
>   * Netlink cmd functions should be locked by following two functions=
=2E
> - * To ensure team_uninit would not be called in between, hold rcu_re=
ad_lock
> - * all the time.
> + * Since dev gets held here, that ensures dev won't disappear in bet=
ween.
>   */
>  static struct team *team_nl_team_get(struct genl_info *info)
>  {
> @@ -1057,12 +1056,9 @@ static struct team *team_nl_team_get(struct ge=
nl_info *info)
>  		return NULL;
> =20
>  	ifindex =3D nla_get_u32(info->attrs[TEAM_ATTR_TEAM_IFINDEX]);
> -	rcu_read_lock();
> -	dev =3D dev_get_by_index_rcu(net, ifindex);
> -	if (!dev || dev->netdev_ops !=3D &team_netdev_ops) {
> -		rcu_read_unlock();
> +	dev =3D dev_get_by_index(net, ifindex);
> +	if (!dev || dev->netdev_ops !=3D &team_netdev_ops)

Hmmm, you return NULL but dev refcnt was increased...

>  		return NULL;
> -	}
> =20
>  	team =3D netdev_priv(dev);
>  	spin_lock(&team->lock);
> @@ -1072,7 +1068,7 @@ static struct team *team_nl_team_get(struct gen=
l_info *info)
>  static void team_nl_team_put(struct team *team)
>  {
>  	spin_unlock(&team->lock);
> -	rcu_read_unlock();
> +	dev_put(team->dev);
>  }
> =20
>  static int team_nl_send_generic(struct genl_info *info, struct team =
*team,
