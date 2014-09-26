From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] dql: dql_queued() should write first to reduce bus
 transactions
Date: Fri, 26 Sep 2014 13:06:35 +0200
Message-ID: <1411729595.1776139.172032293.6FCC3EBB@webmail.messagingengine.com>
References: <20140924160932.9721.56450.stgit@localhost>
 <20140924161047.9721.43080.stgit@localhost>
 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140924195831.6fb91051@redhat.com>
 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
 <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411711496.16953.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	=?UTF-8?Q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:41361 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752149AbaIZLGg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 07:06:36 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id EED3020B4C
	for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 07:06:35 -0400 (EDT)
In-Reply-To: <1411711496.16953.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014, at 08:04, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> While doing high throughput test on a BQL enabled NIC,
> I found a very high cost in ndo_start_xmit() when accessing BQL data.
>=20
> It turned out the problem was caused by compiler trying to be
> smart, but involving a bad MESI transaction :
>=20
>   0.05 =E2=94=82  mov    0xc0(%rax),%edi    // LOAD dql->num_queued
>   0.48 =E2=94=82  mov    %edx,0xc8(%rax)    // STORE dql->last_obj_cn=
t =3D count
>  58.23 =E2=94=82  add    %edx,%edi
>   0.58 =E2=94=82  cmp    %edi,0xc4(%rax)
>   0.76 =E2=94=82  mov    %edi,0xc0(%rax)    // STORE dql->num_queued =
+=3D count
>   0.72 =E2=94=82  js     bd8
>=20
>=20
> I got an incredible 10 % gain [1] by making sure cpu do not attempt
> to get the cache line in Shared mode, but directly requests for
> ownership.
>=20
> New code :
> 	mov    %edx,0xc8(%rax)  // STORE dql->last_obj_cnt =3D count
> 	add    %edx,0xc0(%rax)  // RMW   dql->num_queued +=3D count
> 	mov    0xc4(%rax),%ecx  // LOAD dql->adj_limit
> 	mov    0xc0(%rax),%edx  // LOAD dql->num_queued
> 	cmp    %edx,%ecx
>=20
> The TX completion was running from another cpu, with high interrupts
> rate.
>=20
> Note that I am using barrier() as a soft hint, as mb() here could be
> too heavy cost.
>=20
> [1] This was a netperf TCP_STREAM with TSO disabled, but GSO enabled.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/dynamic_queue_limits.h |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/dynamic_queue_limits.h
> b/include/linux/dynamic_queue_limits.h
> index 5621547d631b..a4be70398ce1 100644
> --- a/include/linux/dynamic_queue_limits.h
> +++ b/include/linux/dynamic_queue_limits.h
> @@ -73,14 +73,22 @@ static inline void dql_queued(struct dql *dql,
> unsigned int count)
>  {
>  	BUG_ON(count > DQL_MAX_OBJECT);
> =20
> -       dql->num_queued +=3D count;
>  	dql->last_obj_cnt =3D count;
> +
> +       /* We want to force a write first, so that cpu do not attempt
> +        * to get cache line containing last_obj_cnt, num_queued,
> adj_limit
> +        * in Shared state, but directly does a Request For Ownership
> +        * It is only a hint, we use barrier() only.
> +        */
> +       barrier();
> +
> +       dql->num_queued +=3D count;
>  }

I thought that prefetchw() would be the canonical way to solve write
stalls in CPUs and prepare the specific cache line to be written to.
Interesting, thanks Eric.

Thanks,
Hannes
