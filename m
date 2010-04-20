From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: A possible bug in reqsk_queue_hash_req()
Date: Tue, 20 Apr 2010 13:06:51 +0200
Message-ID: <1271761611.3845.223.camel@edumazet-laptop>
References: <i2x9b948ee41004200335vc229a59cvc0a08c35c949d7dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50687 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507Ab0DTLHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 07:07:00 -0400
In-Reply-To: <i2x9b948ee41004200335vc229a59cvc0a08c35c949d7dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 18:35 +0800, Li Yu a =C3=A9crit :
> Hi,
>=20
>      I found out a possible bug in reqsk_queue_hash_req(), it seem
> that we should move "req->dl_next =3D lopt->syn_table[hash];" stateme=
nt
> into follow write lock protected scope.
>=20
>      As I browsed source code, this function only can be call at rx
> code path which is protected a spin lock over struct sock , but its
> caller (  inet_csk_reqsk_queue_hash_add() ) is a GPL exported symbol,
> so I think that we'd best move this statement into below write lock
> protected scope.
>=20
>      Below is the patch to play this change, please do not apply it o=
n
> source code, it's just for show.
>=20
>     Thanks.
>=20
> Yu
>=20
> --- include/net/request_sock.h  2010-04-09 15:27:14.000000000 +0800
> +++ include/net/request_sock.h        2010-04-20 18:11:32.000000000 +=
0800
> @@ -247,9 +247,9 @@ static inline void reqsk_queue_hash_req(
>         req->expires =3D jiffies + timeout;
>         req->retrans =3D 0;
>         req->sk =3D NULL;
> -       req->dl_next =3D lopt->syn_table[hash];
>=20
>         write_lock(&queue->syn_wait_lock);
> +       req->dl_next =3D lopt->syn_table[hash];
>         lopt->syn_table[hash] =3D req;
>         write_unlock(&queue->syn_wait_lock);
>  }

I believe its not really necessary, because we are the only possible
writer at this stage.

The write_lock() ... write_unlock() is there only to enforce a
synchronisation with readers.

All callers of this reqsk_queue_hash_req() must have the socket locked



