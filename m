From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4 : igmp : optimize timer modify logic in
 igmp_mod_timer()
Date: Wed, 23 Nov 2011 16:42:46 +0100
Message-ID: <1322062966.17693.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1322062004-9742-1-git-send-email-mypopydev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jun Zhao <mypopydev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:32987 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab1KWPmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 10:42:50 -0500
Received: by qyd20 with SMTP id 20so493813qyd.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 07:42:49 -0800 (PST)
In-Reply-To: <1322062004-9742-1-git-send-email-mypopydev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 novembre 2011 =C3=A0 23:26 +0800, Jun Zhao a =C3=A9crit =
:
> When timer is pending and expires less-than-or-equal-to new delay,
> we need not used del_timer()/add_timer().
>=20
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>
> ---
>  net/ipv4/igmp.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index c7472ef..50d06c5 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -215,14 +215,14 @@ static void igmp_mod_timer(struct ip_mc_list *i=
m, int max_delay)
>  {
>  	spin_lock_bh(&im->lock);
>  	im->unsolicit_count =3D 0;
> -	if (del_timer(&im->timer)) {
> -		if ((long)(im->timer.expires-jiffies) < max_delay) {
> -			add_timer(&im->timer);
> -			im->tm_running =3D 1;
> -			spin_unlock_bh(&im->lock);
> +	if (timer_pending(&im->timer)) {
> +		if (time_before_eq(im->timer.expires, (jiffies + max_delay))) {
> +			spin_lock_bh(&im->lock);

And you actually tested this patch ?

>  			return;
> +		} else {
> +			del_timer(&im->timer);
> +			atomic_dec(&im->refcnt);
>  		}
> -		atomic_dec(&im->refcnt);
>  	}
>  	igmp_start_timer(im, max_delay);
>  	spin_unlock_bh(&im->lock);


Not sure why you want to optimize this very rare function call, risking
adding bugs in it.
