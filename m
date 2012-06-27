From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH 2/18] gdm72xx: Move away from NLMSG_PUT().
Date: Wed, 27 Jun 2012 13:07:11 +0200
Message-ID: <CAAwP0s0gLPGuitonRhzXkJnrGCzYfkE=AMWV14FLZKrCDSZnvA@mail.gmail.com>
References: <20120626.220206.1076042544693422783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54193 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756494Ab2F0LHc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 07:07:32 -0400
Received: by yenl2 with SMTP id l2so749985yen.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 04:07:31 -0700 (PDT)
In-Reply-To: <20120626.220206.1076042544693422783.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 27, 2012 at 7:02 AM, David Miller <davem@davemloft.net> wro=
te:
>
> And use nlmsg_data() while we're here too.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> =C2=A0drivers/staging/gdm72xx/netlink_k.c | =C2=A0 10 ++++++----
> =C2=A01 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/staging/gdm72xx/netlink_k.c b/drivers/staging/gd=
m72xx/netlink_k.c
> index 292af0f..d0cb48a 100644
> --- a/drivers/staging/gdm72xx/netlink_k.c
> +++ b/drivers/staging/gdm72xx/netlink_k.c
> @@ -127,8 +127,12 @@ int netlink_send(struct sock *sock, int group, u=
16 type, void *msg, int len)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0seq++;
> - =C2=A0 =C2=A0 =C2=A0 nlh =3D NLMSG_PUT(skb, 0, seq, type, len);
> - =C2=A0 =C2=A0 =C2=A0 memcpy(NLMSG_DATA(nlh), msg, len);
> + =C2=A0 =C2=A0 =C2=A0 nlh =3D nlmsg_put(skb, 0, seq, type, len, 0);
> + =C2=A0 =C2=A0 =C2=A0 if (!nlh) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree_skb(skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EMSGSIZE;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 memcpy(nlmsg_data(nlh), msg, len);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NETLINK_CB(skb).pid =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0NETLINK_CB(skb).dst_group =3D 0;
> @@ -144,7 +148,5 @@ int netlink_send(struct sock *sock, int group, u1=
6 type, void *msg, int len)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> -
> -nlmsg_failure:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
> --
> 1.7.10.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml

Hi David,

This also solves an skb memory leak since the sk_buff was allocated
before the NLMSG_PUT() macro and not  freed after jumping to the
nlmsg_failure label. I posted a similar patch before:

http://www.spinics.net/lists/linux-driver-devel/msg25756.html

and is already on linux-next with commitid:

2da049bd5f9b0dbd688519fdb6688a4895fe8395 staging: gdm72xx: fix an skb
memory leak

Best regards,
Javier
