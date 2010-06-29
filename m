From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] fragment: add fast path
Date: Tue, 29 Jun 2010 15:54:20 +0200
Message-ID: <1277819660.3531.568.camel@edumazet-laptop>
References: <1277434472-2845-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Mitchell Erblich <erblichs@earthlink.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49847 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949Ab0F2Ny0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 09:54:26 -0400
Received: by wyb38 with SMTP id 38so2719780wyb.19
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 06:54:25 -0700 (PDT)
In-Reply-To: <1277434472-2845-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 juin 2010 =C3=A0 10:54 +0800, Changli Gao a =C3=A9crit :
> add fast path
>=20
> As the fragments are sent in order in most of OSes, such as Windows, =
Darwin and
> FreeBSD, it is likely the new fragments are at the end of the inet_fr=
ag_queue.
> In the fast path, we check if the skb at the end of the inet_frag_que=
ue is the
> prev we expect.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

This patch is fine, but they are two indentation glitches.

> ----
>  include/net/inet_frag.h |    1 +
>  net/ipv4/ip_fragment.c  |   12 ++++++++++++
>  net/ipv6/reassembly.c   |   11 +++++++++++
>  3 files changed, 24 insertions(+)
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index 39f2dc9..16ff29a 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -20,6 +20,7 @@ struct inet_frag_queue {
>  	atomic_t		refcnt;
>  	struct timer_list	timer;      /* when will this queue expire? */
>  	struct sk_buff		*fragments; /* list of received fragments */
> +	struct sk_buff		*fragments_tail;
>  	ktime_t			stamp;
>  	int			len;        /* total length of orig datagram */
>  	int			meat;
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index 858d346..dbe8999 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -314,6 +314,7 @@ static int ip_frag_reinit(struct ipq *qp)
>  	qp->q.len =3D 0;
>  	qp->q.meat =3D 0;
>  	qp->q.fragments =3D NULL;
> +	qp->q.fragments_tail =3D NULL;
>  	qp->iif =3D 0;
> =20
>  	return 0;
> @@ -386,6 +387,11 @@ static int ip_frag_queue(struct ipq *qp, struct =
sk_buff *skb)
>  	 * in the chain of fragments so far.  We must know where to put
>  	 * this fragment, right?
>  	 */
> +	prev =3D qp->q.fragments_tail;
> +	if (!prev || FRAG_CB(prev)->offset < offset) {

strange indentation : one tab in excess

> +			next =3D NULL;
> +			goto found;
> +	}
>  	prev =3D NULL;
>  	for (next =3D qp->q.fragments; next !=3D NULL; next =3D next->next)=
 {
>  		if (FRAG_CB(next)->offset >=3D offset)
> @@ -393,6 +399,7 @@ static int ip_frag_queue(struct ipq *qp, struct s=
k_buff *skb)
>  		prev =3D next;
>  	}
> =20
> +found:
>  	/* We found where to put this one.  Check for overlap with
>  	 * preceding fragment, and, if needed, align things so that
>  	 * any overlaps are eliminated.
> @@ -451,6 +458,8 @@ static int ip_frag_queue(struct ipq *qp, struct s=
k_buff *skb)
> =20
>  	/* Insert this fragment in the chain of fragments. */
>  	skb->next =3D next;
> +	if (!next)
> +		qp->q.fragments_tail =3D skb;
>  	if (prev)
>  		prev->next =3D skb;
>  	else
> @@ -504,6 +513,8 @@ static int ip_frag_reasm(struct ipq *qp, struct s=
k_buff *prev,
>  			goto out_nomem;
> =20
>  		fp->next =3D head->next;
> +		if (!fp->next)
> +			qp->q.fragments_tail =3D fp;
>  		prev->next =3D fp;
> =20
>  		skb_morph(head, qp->q.fragments);
> @@ -574,6 +585,7 @@ static int ip_frag_reasm(struct ipq *qp, struct s=
k_buff *prev,
>  	iph->tot_len =3D htons(len);
>  	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
>  	qp->q.fragments =3D NULL;
> +	qp->q.fragments_tail =3D NULL;
>  	return 0;
> =20
>  out_nomem:
> diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
> index 0b97230..b832f7b 100644
> --- a/net/ipv6/reassembly.c
> +++ b/net/ipv6/reassembly.c
> @@ -333,6 +333,11 @@ static int ip6_frag_queue(struct frag_queue *fq,=
 struct sk_buff *skb,
>  	 * in the chain of fragments so far.  We must know where to put
>  	 * this fragment, right?
>  	 */
> +	prev =3D fq->q.fragments_tail;
> +	if (!prev || FRAG6_CB(prev)->offset < offset) {

same here : one tab in excess

> +			next =3D NULL;
> +			goto found;
> +	}
>  	prev =3D NULL;
>  	for(next =3D fq->q.fragments; next !=3D NULL; next =3D next->next) =
{
>  		if (FRAG6_CB(next)->offset >=3D offset)
> @@ -340,6 +345,7 @@ static int ip6_frag_queue(struct frag_queue *fq, =
struct sk_buff *skb,
>  		prev =3D next;
>  	}
> =20
> +found:
>  	/* We found where to put this one.  Check for overlap with
>  	 * preceding fragment, and, if needed, align things so that
>  	 * any overlaps are eliminated.
> @@ -397,6 +403,8 @@ static int ip6_frag_queue(struct frag_queue *fq, =
struct sk_buff *skb,
> =20
>  	/* Insert this fragment in the chain of fragments. */
>  	skb->next =3D next;
> +	if (!next)
> +		fq->q.fragments_tail =3D skb;
>  	if (prev)
>  		prev->next =3D skb;
>  	else
> @@ -463,6 +471,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, =
struct sk_buff *prev,
>  			goto out_oom;
> =20
>  		fp->next =3D head->next;
> +		if (!fp->next)
> +			fq->q.fragments_tail =3D fp;
>  		prev->next =3D fp;
> =20
>  		skb_morph(head, fq->q.fragments);
> @@ -549,6 +559,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, =
struct sk_buff *prev,
>  	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
>  	rcu_read_unlock();
>  	fq->q.fragments =3D NULL;
> +	fq->q.fragments_tail =3D NULL;
>  	return 1;
> =20
>  out_oversize:


