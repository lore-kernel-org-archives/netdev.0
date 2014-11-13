From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH] net: skb_fclone_busy() needs to detect orphaned skb
Date: Thu, 13 Nov 2014 19:15:02 +0000
Message-ID: <20141113191502.GC7095@hercules>
References: <1414690354.9028.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44313 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933587AbaKMTPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:15:07 -0500
Content-Disposition: inline
In-Reply-To: <1414690354.9028.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Oct 30, 2014 at 10:32:34AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Some drivers are unable to perform TX completions in a bound time.
> They instead call skb_orphan()
>=20
> Problem is skb_fclone_busy() has to detect this case, otherwise
> we block TCP retransmits and can freeze unlucky tcp sessions on
> mostly idle hosts.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 1f3279ae0c13 ("tcp: avoid retransmits of TCP packets hanging i=
n host queues")
> ---
>  This is a stable candidate.
>  This problem is known to hurt users of linux-3.16 kernels used by gu=
ests kernels.
>  David, I can provide backports if you want.
>  Thanks !
>=20

We got a bug report[0] where a backport for 3.16 was provided.  Since
I couldn't find the original backport post, I'm not sure who's the
actual author.  Could you please confirm if this backport is correct?
(I'm copying the patch below).

[0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1390604

Cheers,
--
Lu=EDs


diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4e4932b5079b..a8794367cd20 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2082,7 +2082,8 @@ static bool skb_still_in_host_queue(const struct =
sock *sk,
 	const struct sk_buff *fclone =3D skb + 1;
=20
 	if (unlikely(skb->fclone =3D=3D SKB_FCLONE_ORIG &&
-		     fclone->fclone =3D=3D SKB_FCLONE_CLONE)) {
+		     fclone->fclone =3D=3D SKB_FCLONE_CLONE &&
+		     fclone->sk =3D=3D sk)) {
 		NET_INC_STATS_BH(sock_net(sk),
 				 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
 		return true;

>  include/linux/skbuff.h |    8 ++++++--
>  net/ipv4/tcp_output.c  |    2 +-
>  net/xfrm/xfrm_policy.c |    2 +-
>  3 files changed, 8 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 5884f95ff0e9..6c8b6f604e76 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -799,15 +799,19 @@ struct sk_buff_fclones {
>   *	@skb: buffer
>   *
>   * Returns true is skb is a fast clone, and its clone is not freed.
> + * Some drivers call skb_orphan() in their ndo_start_xmit(),
> + * so we also check that this didnt happen.
>   */
> -static inline bool skb_fclone_busy(const struct sk_buff *skb)
> +static inline bool skb_fclone_busy(const struct sock *sk,
> +				   const struct sk_buff *skb)
>  {
>  	const struct sk_buff_fclones *fclones;
> =20
>  	fclones =3D container_of(skb, struct sk_buff_fclones, skb1);
> =20
>  	return skb->fclone =3D=3D SKB_FCLONE_ORIG &&
> -	       fclones->skb2.fclone =3D=3D SKB_FCLONE_CLONE;
> +	       fclones->skb2.fclone =3D=3D SKB_FCLONE_CLONE &&
> +	       fclones->skb2.sk =3D=3D sk;
>  }
> =20
>  static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 3af21296d967..a3d453b94747 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2126,7 +2126,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
>  static bool skb_still_in_host_queue(const struct sock *sk,
>  				    const struct sk_buff *skb)
>  {
> -	if (unlikely(skb_fclone_busy(skb))) {
> +	if (unlikely(skb_fclone_busy(sk, skb))) {
>  		NET_INC_STATS_BH(sock_net(sk),
>  				 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
>  		return true;
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 4c4e457e7888..88bf289abdc9 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1962,7 +1962,7 @@ static int xdst_queue_output(struct sock *sk, s=
truct sk_buff *skb)
>  	struct xfrm_policy *pol =3D xdst->pols[0];
>  	struct xfrm_policy_queue *pq =3D &pol->polq;
> =20
> -	if (unlikely(skb_fclone_busy(skb))) {
> +	if (unlikely(skb_fclone_busy(sk, skb))) {
>  		kfree_skb(skb);
>  		return 0;
>  	}
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
