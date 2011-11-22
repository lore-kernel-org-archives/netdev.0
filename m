From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] AF_UNIX: Fix poll locking problem when reading from
 a stream socket
Date: Tue, 22 Nov 2011 06:23:01 +0100
Message-ID: <1321939381.27077.7.camel@edumazet-laptop>
References: <1321918525-5078-1-git-send-email-himeraster@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexey Moiseytsev <himeraster@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321918525-5078-1-git-send-email-himeraster@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 22 novembre 2011 =C3=A0 03:35 +0400, Alexey Moiseytsev a =C3=A9=
crit :
> poll() call may be locked by concurrent reading from the same stream
> socket.
>=20
> Signed-off-by: Alexey Moiseytsev <himeraster@gmail.com>
> ---
>  net/unix/af_unix.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 466fbcc..b595a3d 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1957,6 +1957,7 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
>  			if ((UNIXCB(skb).pid  !=3D siocb->scm->pid) ||
>  			    (UNIXCB(skb).cred !=3D siocb->scm->cred)) {
>  				skb_queue_head(&sk->sk_receive_queue, skb);
> +				sk->sk_data_ready(sk, skb->len);
>  				break;
>  			}
>  		} else {
> @@ -1974,6 +1975,7 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
>  		chunk =3D min_t(unsigned int, skb->len, size);
>  		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
>  			skb_queue_head(&sk->sk_receive_queue, skb);
> +			sk->sk_data_ready(sk, skb->len);
>  			if (copied =3D=3D 0)
>  				copied =3D -EFAULT;
>  			break;
> @@ -1991,6 +1993,7 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
>  			/* put the skb back if we didn't use it up.. */
>  			if (skb->len) {
>  				skb_queue_head(&sk->sk_receive_queue, skb);
> +				sk->sk_data_ready(sk, skb->len);
>  				break;
>  			}
> =20
> @@ -2006,6 +2009,7 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
> =20
>  			/* put message back and return */
>  			skb_queue_head(&sk->sk_receive_queue, skb);
> +			sk->sk_data_ready(sk, skb->len);
>  			break;
>  		}
>  	} while (size);

=46ine, the fix is technically correct since we own u->readlock mutex,
another thread cannot consume the just requeued skb.=20

Small note : the words "locking" and "locked" are more used to describe
the action of taking a spinlock/mutex/rwlock or something, while the bu=
g
you fixed is more about poll() system call being blocked/frozen forever=
=2E

Thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
