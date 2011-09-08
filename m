From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 08 Sep 2011 07:59:32 +0200
Message-ID: <1315461572.2532.7.camel@edumazet-laptop>
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
	 <1315406256.6287.7.camel@schen9-mobl>  <4E680BF1.8000901@intel.com>
	 <1315429583.2361.3.camel@schen9-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43278 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab1IHF7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 01:59:40 -0400
Received: by wwf5 with SMTP id 5so467840wwf.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2011 22:59:39 -0700 (PDT)
In-Reply-To: <1315429583.2361.3.camel@schen9-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 septembre 2011 =C3=A0 14:06 -0700, Tim Chen a =C3=A9crit=
 :
> On Thu, 2011-09-08 at 08:27 +0800, Yan, Zheng wrote:
>=20
> > >  	err =3D -EPIPE;
> > >  out_err:
> > > -	if (skb =3D=3D NULL)
> > > +	if (!steal_refs)
> > >  		scm_destroy(siocb->scm);
> >=20
> > I think we should call scm_release() here in the case of
> > steal_refs =3D=3D true. Otherwise siocb->scm->fp may leak.
>=20
> Yan Zheng,
>=20
> I've updated the patch.  If it looks good to you now, can you add you=
r
> Signed-off-by to the patch.  Pending Sedat's testing on this patch,
> I think it is good to go.
>=20
> Tim
>=20
> ---
> Commit 0856a30409 (Scm: Remove unnecessary pid & credential reference=
s
> in Unix socket's send and receive path) introduced a use-after-free b=
ug.
> The sent skbs from unix_stream_sendmsg could be consumed and destruct=
ed=20
> by the receive side, removing all references to the credentials,=20
> before the send side has finished sending out all=20
> packets. However, send side could continue to consturct new packets i=
n the=20
> stream, using credentials that have lost its last reference and been
> freed. =20
>=20
> In this fix, we don't steal the reference to credentials we have obta=
ined=20
> in scm_send at beginning of unix_stream_sendmsg, till we've reached
> the last packet.  This fixes the problem in commit 0856a30409.
>=20
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> Reported-by: Jiri Slaby <jirislaby@gmail.com>
> Tested-by: Sedat Dilek <sedat.dilek@googlemail.com>
> Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> ---
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 136298c..47780dc 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1383,10 +1383,11 @@ static int unix_attach_fds(struct scm_cookie =
*scm, struct sk_buff *skb)
>  }
> =20
>  static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *s=
kb,
> -			   bool send_fds, bool ref)
> +			   bool send_fds, bool steal_refs)
>  {
>  	int err =3D 0;
> -	if (ref) {
> +
> +	if (!steal_refs) {
>  		UNIXCB(skb).pid  =3D get_pid(scm->pid);
>  		UNIXCB(skb).cred =3D get_cred(scm->cred);
>  	} else {
> @@ -1458,7 +1459,7 @@ static int unix_dgram_sendmsg(struct kiocb *kio=
cb, struct socket *sock,
>  	if (skb =3D=3D NULL)
>  		goto out;
> =20
> -	err =3D unix_scm_to_skb(siocb->scm, skb, true, false);
> +	err =3D unix_scm_to_skb(siocb->scm, skb, true, true);
>  	if (err < 0)
>  		goto out_free;
>  	max_level =3D err + 1;
> @@ -1581,6 +1582,7 @@ static int unix_stream_sendmsg(struct kiocb *ki=
ocb, struct socket *sock,
>  	int sent =3D 0;
>  	struct scm_cookie tmp_scm;
>  	bool fds_sent =3D false;
> +	bool steal_refs =3D false;
>  	int max_level;
> =20
>  	if (NULL =3D=3D siocb->scm)
> @@ -1642,11 +1644,14 @@ static int unix_stream_sendmsg(struct kiocb *=
kiocb, struct socket *sock,
>  		size =3D min_t(int, size, skb_tailroom(skb));
> =20
>=20
> -		/* Only send the fds and no ref to pid in the first buffer */
> -		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
> +		/* Only send the fds in first buffer
> +		 * Last buffer can steal our references to pid/cred
> +		 */
> +		steal_refs =3D (sent + size >=3D len);
> +		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, steal_refs);
>  		if (err < 0) {
>  			kfree_skb(skb);
> -			goto out;
> +			goto out_err;
>  		}
>  		max_level =3D err + 1;
>  		fds_sent =3D true;
> @@ -1654,7 +1659,7 @@ static int unix_stream_sendmsg(struct kiocb *ki=
ocb, struct socket *sock,
>  		err =3D memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
>  		if (err) {
>  			kfree_skb(skb);
> -			goto out;
> +			goto out_err;
>  		}
> =20
>  		unix_state_lock(other);
> @@ -1671,7 +1676,7 @@ static int unix_stream_sendmsg(struct kiocb *ki=
ocb, struct socket *sock,
>  		sent +=3D size;
>  	}
> =20
> -	if (skb)
> +	if (steal_refs)
>  		scm_release(siocb->scm);
>  	else
>  		scm_destroy(siocb->scm);
> @@ -1687,9 +1692,10 @@ pipe_err:
>  		send_sig(SIGPIPE, current, 0);
>  	err =3D -EPIPE;
>  out_err:
> -	if (skb =3D=3D NULL)
> +	if (steal_refs)
> +		scm_release(siocb->scm);
> +	else
>  		scm_destroy(siocb->scm);
> -out:
>  	siocb->scm =3D NULL;
>  	return sent ? : err;
>  }
>=20
>=20
>=20

I dont think this patch is good.

Sedat traces have nothing to do with af_unix.

Once unix_scm_to_skb() was called and successful, and steal_refs is tru=
e
our refs are attached to this skb. They will be released by
skb_free(skb). Same for fp : They either were sent in a previous skb or
this one.

This is why the "goto out;" was OK.
