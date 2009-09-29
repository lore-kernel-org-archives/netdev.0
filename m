From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] /proc/net/tcp, overhead removed
Date: Tue, 29 Sep 2009 09:56:29 +0200
Message-ID: <4AC1BDAD.1010400@gmail.com>
References: <1254178906-5293-1-git-send-email-iler.ml@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Yakov Lerner <iler.ml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54167 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbZI2H42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 03:56:28 -0400
In-Reply-To: <1254178906-5293-1-git-send-email-iler.ml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yakov Lerner a =E9crit :
> Take 2.=20
>=20
> "Sharp improvement in performance of /proc/net/tcp when number of=20
> sockets is large and hashsize is large.=20
> O(numsock * hashsize) time becomes O(numsock + hashsize). On slow
> processors, speed difference can be x100 and more."
>=20
> I must say that I'm not fully satisfied with my choice of "st->sbucke=
t"=20
> for the new preserved index. The better name would be "st->snum".=20
> Re-using "st->sbucket" saves 4 bytes, and keeps the patch to one sour=
cefile.
> But "st->sbucket" has different meaning in OPENREQ and LISTEN states;
> this can be confusing.=20
> Maybe better add "snum" member to struct tcp_iter_state ?
>=20
> Shall I change subject when sending "take N+1", or keep the old subje=
ct ?
>=20
> Signed-off-by: Yakov Lerner <iler.ml@gmail.com>
> ---
>  net/ipv4/tcp_ipv4.c |   35 +++++++++++++++++++++++++++++++++--
>  1 files changed, 33 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 7cda24b..e4c4f19 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1994,13 +1994,14 @@ static inline int empty_bucket(struct tcp_ite=
r_state *st)
>  		hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
>  }
> =20
> -static void *established_get_first(struct seq_file *seq)
> +static void *established_get_first_after(struct seq_file *seq, int b=
ucket)
>  {
>  	struct tcp_iter_state *st =3D seq->private;
>  	struct net *net =3D seq_file_net(seq);
>  	void *rc =3D NULL;
> =20
> -	for (st->bucket =3D 0; st->bucket < tcp_hashinfo.ehash_size; ++st->=
bucket) {
> +	for (st->bucket =3D bucket; st->bucket < tcp_hashinfo.ehash_size;
> +	     ++st->bucket) {
>  		struct sock *sk;
>  		struct hlist_nulls_node *node;
>  		struct inet_timewait_sock *tw;
> @@ -2010,6 +2011,8 @@ static void *established_get_first(struct seq_f=
ile *seq)
>  		if (empty_bucket(st))
>  			continue;
> =20
> +		st->sbucket =3D st->num;
> +
>  		spin_lock_bh(lock);
>  		sk_nulls_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain)=
 {
>  			if (sk->sk_family !=3D st->family ||
> @@ -2036,6 +2039,11 @@ out:
>  	return rc;
>  }
> =20
> +static void *established_get_first(struct seq_file *seq)
> +{
> +	return established_get_first_after(seq, 0);
> +}
> +
>  static void *established_get_next(struct seq_file *seq, void *cur)
>  {
>  	struct sock *sk =3D cur;
> @@ -2064,6 +2072,9 @@ get_tw:
>  		while (++st->bucket < tcp_hashinfo.ehash_size &&
>  				empty_bucket(st))
>  			;
> +
> +		st->sbucket =3D st->num;
> +
>  		if (st->bucket >=3D tcp_hashinfo.ehash_size)
>  			return NULL;
> =20
> @@ -2107,6 +2118,7 @@ static void *tcp_get_idx(struct seq_file *seq, =
loff_t pos)
> =20
>  	if (!rc) {
>  		st->state =3D TCP_SEQ_STATE_ESTABLISHED;
> +		st->sbucket =3D 0;
>  		rc	  =3D established_get_idx(seq, pos);
>  	}
> =20
> @@ -2116,6 +2128,25 @@ static void *tcp_get_idx(struct seq_file *seq,=
 loff_t pos)
>  static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
>  {
>  	struct tcp_iter_state *st =3D seq->private;
> +
> +	if (*pos && *pos >=3D st->sbucket &&
> +	    (st->state =3D=3D TCP_SEQ_STATE_ESTABLISHED ||
> +	     st->state =3D=3D TCP_SEQ_STATE_TIME_WAIT)) {
> +		void *cur;
> +		int nskip;
> +
> +		/* for states estab and tw, st->sbucket is index (*pos) */
> +		/* corresponding to the beginning of bucket st->bucket */
> +
> +		st->num =3D st->sbucket;
> +		/* jump to st->bucket, then skip (*pos - st->sbucket) items */
> +		st->state =3D TCP_SEQ_STATE_ESTABLISHED;
> +		cur =3D established_get_first_after(seq, st->bucket);
> +		for (nskip =3D *pos - st->num; cur && nskip > 0; --nskip)
> +			cur =3D established_get_next(seq, cur);
> +		return cur;
> +	}
> +
>  	st->state =3D TCP_SEQ_STATE_LISTENING;
>  	st->num =3D 0;
>  	return *pos ? tcp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;

Just in case you are working on "take 3" of the patch, there is a fonda=
mental problem.

All the scalability problems come from the fact that tcp_seq_start()
*has* to rescan all the tables from the begining, because of lseek() ca=
pability
on /proc/net/tcp file=20

We probably could disable llseek() (on other positions than start of th=
e file),
and rely only on internal state (listening/established hashtable, hash =
bucket, position in chain)

I cannot imagine how an application could rely on lseek() on >0 positio=
n in this file.


