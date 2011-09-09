From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH net-next] af_unix: fix use after free in
 unix_stream_recvmsg()
Date: Fri, 09 Sep 2011 03:39:58 -0700
Message-ID: <1315564798.2363.37.camel@schen9-mobl>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	 <1315372100.3400.76.camel@edumazet-laptop> <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
	 <CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>
	 <CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com>
	 <1315406256.6287.7.camel@schen9-mobl> <4E680BF1.8000901@intel.com>
	 <1315429583.2361.3.camel@schen9-mobl>
	 <1315461572.2532.7.camel@edumazet-laptop> <4E685F19.6030407@intel.com>
	 <1315465919.2532.19.camel@edumazet-laptop> <4E686D71.30603@intel.com>
	 <1315467184.2532.22.camel@edumazet-laptop>
	 <CA+icZUWH8953m4qs74JLhNwrzJM0eMfE8aizJ1XtuVFFTtLKqg@mail.gmail.com>
	 <1315488103.2456.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315471065.2301.1.camel@schen9-mobl>
	 <1315551100.5410.30.camel@edumazet-laptop>
	 <1315555109.2294.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sedat.dilek@gmail.com, "Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65306 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753566Ab1IIRkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Sep 2011 13:40:00 -0400
In-Reply-To: <1315555109.2294.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-09 at 09:58 +0200, Eric Dumazet wrote:
> Le vendredi 09 septembre 2011 =C3=A0 08:51 +0200, Eric Dumazet a =C3=A9=
crit :
>=20
> > Now we have to fix a bug in unix_stream_recvmsg() as well.
> >=20
> > consume_skb() call actually releases pid/cred references, and we ca=
n use
> > them after their eventual freeing.
> >=20
> > Keep also in mind that receiver can provides a too short user buffe=
r,
> > and skb can be put back to head of sk_receive_queue
> >=20
>=20
> Here is the patch to address this point.
>=20
> Apply it after (af_unix: Fix use-after-free crashes)
>=20
> I can make a combo patch once everybody agrees.
>=20
> [PATCH net-next] af_unix: fix use after free in unix_stream_recvmsg()
>=20
> Commit 0856a30409 (Scm: Remove unnecessary pid & credential reference=
s
> in Unix socket's send and receive path) introduced an use-after-free
> bug in unix_stream_recvmsg().
>=20
> We should call consume_skb(skb) only after our possible use of pid/cr=
ed.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/unix/af_unix.c |   13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index c8a08ba..1bd4ecf 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1873,6 +1873,7 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
>  	int target;
>  	int err =3D 0;
>  	long timeo;
> +	struct sk_buff *skb;
> =20
>  	err =3D -EINVAL;
>  	if (sk->sk_state !=3D TCP_ESTABLISHED)
> @@ -1904,7 +1905,6 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
> =20
>  	do {
>  		int chunk;
> -		struct sk_buff *skb;
> =20
>  		unix_state_lock(sk);
>  		skb =3D skb_dequeue(&sk->sk_receive_queue);
> @@ -1949,6 +1949,7 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
>  			if ((UNIXCB(skb).pid  !=3D siocb->scm->pid) ||
>  			    (UNIXCB(skb).cred !=3D siocb->scm->cred)) {
>  				skb_queue_head(&sk->sk_receive_queue, skb);
> +				skb =3D NULL;
>  				break;
>  			}
>  		} else {
> @@ -1967,6 +1968,7 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
>  		chunk =3D min_t(unsigned int, skb->len, size);
>  		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
>  			skb_queue_head(&sk->sk_receive_queue, skb);
> +			skb =3D NULL;
>  			if (copied =3D=3D 0)
>  				copied =3D -EFAULT;
>  			break;
> @@ -1984,13 +1986,14 @@ static int unix_stream_recvmsg(struct kiocb *=
iocb, struct socket *sock,
>  			/* put the skb back if we didn't use it up.. */
>  			if (skb->len) {
>  				skb_queue_head(&sk->sk_receive_queue, skb);
> +				skb =3D NULL;
>  				break;
>  			}
> =20
> -			consume_skb(skb);
> -
> -			if (siocb->scm->fp)
> +			if (UNIXCB(skb).pid || siocb->scm->fp)
>  				break;
> +			consume_skb(skb);
> +			skb =3D NULL;
>  		} else {
>  			/* It is questionable, see note in unix_dgram_recvmsg.
>  			 */
> @@ -1999,12 +2002,14 @@ static int unix_stream_recvmsg(struct kiocb *=
iocb, struct socket *sock,
> =20
>  			/* put message back and return */
>  			skb_queue_head(&sk->sk_receive_queue, skb);
> +			skb =3D NULL;
>  			break;
>  		}
>  	} while (size);
> =20
>  	mutex_unlock(&u->readlock);
>  	scm_recv(sock, msg, siocb->scm, flags);
> +	consume_skb(skb);
>  out:
>  	return copied ? : err;
>  }
>=20
>=20

Acked-by: Tim Chen <tim.c.chen@linux.intel.com>
