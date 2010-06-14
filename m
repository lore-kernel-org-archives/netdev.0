From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 07:35:43 +0200
Message-ID: <1276493743.2448.41.camel@edumazet-laptop>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:42291 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644Ab0FNFfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 01:35:50 -0400
Received: by wwb18 with SMTP id 18so3401333wwb.19
        for <netdev@vger.kernel.org>; Sun, 13 Jun 2010 22:35:48 -0700 (PDT)
In-Reply-To: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 07:16 +0800, Changli Gao a =C3=A9crit :
> add fast path
>=20
> As the fragments are usually in order, it is likely the new fragments=
 are
> at the end of the inet_frag_queue. In the fast path, we check if the =
skb at the
> end of the inet_frag_queue is the prev we expect.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  include/net/inet_frag.h |    1 +
>  net/ipv4/ip_fragment.c  |   17 +++++++++++++++++
>  net/ipv6/reassembly.c   |   16 ++++++++++++++++
>  3 files changed, 34 insertions(+)
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
> index 75347ea..d8c36d4 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -317,6 +317,7 @@ static int ip_frag_reinit(struct ipq *qp)
>  	qp->q.len =3D 0;
>  	qp->q.meat =3D 0;
>  	qp->q.fragments =3D NULL;
> +	qp->q.fragments_tail =3D NULL;
>  	qp->iif =3D 0;
> =20
>  	return 0;
> @@ -389,6 +390,16 @@ static int ip_frag_queue(struct ipq *qp, struct =
sk_buff *skb)
>  	 * in the chain of fragments so far.  We must know where to put
>  	 * this fragment, right?
>  	 */
> +	prev =3D qp->q.fragments_tail;
> +	if (prev) {
> +		if (FRAG_CB(prev)->offset < offset) {
> +			next =3D NULL;
> +			goto found;
> +		}
> +	} else {
> +		next =3D NULL;

How can this chunk be a win ? queue is empty anyway.
You add tests and slow the 'other path'

> +		goto found;
> +	}

Quite frankly, one easy way to speedup things would be to move 'offset'
from  ipfrag_skb_cb close to skb->next field so that only one cache lin=
e
per frag is used during lookup.

I am not sure why we need "struct inet_skb_parm h;" field in struct
ipfrag_skb_cb...=20

I probably need to wakeup this monday morning ?

Untested patch follows, only compiled.

[PATCH] frags: Remove unecessary bits

While trying to move 'offset' to the beginning of frag CB, I found
inet_skb_parm field was unused.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 75347ea..0f51ae0 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -55,7 +55,6 @@ static int sysctl_ipfrag_max_dist __read_mostly =3D 6=
4;
=20
 struct ipfrag_skb_cb
 {
-	struct inet_skb_parm	h;
 	int			offset;
 };
=20
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 6d4292f..122e0be 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -57,7 +57,6 @@
=20
 struct ip6frag_skb_cb
 {
-	struct inet6_skb_parm	h;
 	int			offset;
 };
=20


