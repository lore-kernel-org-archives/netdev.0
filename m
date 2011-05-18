From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 15:20:07 +0200
Message-ID: <1305724807.2991.30.camel@edumazet-laptop>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	 <1305704885.2983.4.camel@edumazet-laptop>
	 <BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
	 <1305707358.2983.14.camel@edumazet-laptop>
	 <4DD38B30.9090601@cn.fujitsu.com> <4DD3BC8F.9050802@hp.com>
	 <BANLkTinQAy+jq_VUwky2rxchomuN3avPQg@mail.gmail.com>
	 <1305723046.2991.19.camel@edumazet-laptop>
	 <BANLkTi=cDwLFSqaBt5szaFOaWmxYzkya9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vladislav Yasevich <vladislav.yasevich@hp.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>, netdev@vger.kernel.org
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44775 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756961Ab1ERNUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 09:20:12 -0400
Received: by fxm17 with SMTP id 17so1185443fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 06:20:11 -0700 (PDT)
In-Reply-To: <BANLkTi=cDwLFSqaBt5szaFOaWmxYzkya9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 15:11 +0200, Jacek Luczak a =C3=A9crit :

> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index faf71d1..6150ac5 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
> *bp, __u16 port)
>  /* Dispose of the address list. */
>  static void sctp_bind_addr_clean(struct sctp_bind_addr *bp)
>  {
> -       struct sctp_sockaddr_entry *addr;
> -       struct list_head *pos, *temp;
> +       struct sctp_sockaddr_entry *addr, *temp;
>=20
>         /* Empty the bind address list. */
> -       list_for_each_safe(pos, temp, &bp->address_list) {
> -               addr =3D list_entry(pos, struct sctp_sockaddr_entry, =
list);
> -               list_del(pos);
> -               kfree(addr);
> +       list_for_each_entry_safe(addr, temp, &bp->address_list, list)=
 {
> +               list_del_rcu(&addr->list);
> +               call_rcu(&addr->rcu, sctp_local_addr_free);
>                 SCTP_DBG_OBJCNT_DEC(addr);
>         }
>  }
>=20
> Does it now look good?
>=20

It seems fine yes !



