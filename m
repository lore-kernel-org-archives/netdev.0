From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
 (v3)
Date: Sat, 10 Oct 2009 06:59:53 +0200
Message-ID: <4AD014C9.2010801@gmail.com>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <20091009235631.GA31501@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50305 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbZJJFAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 01:00:36 -0400
In-Reply-To: <20091009235631.GA31501@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Ok, take 3 with Erics new notes
>=20
> Change Notes:
>=20
> 1) Modified inlining of sock_recv_ts_and_drops to be more efficient
>=20
> 2) modify getsockopt for SO_RXQ_OVFL to gurantee only a 1 or 0 return
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
>=20
> Create a new socket level option to report number of queue overflows
>=20
> Recently I augmented the AF_PACKET protocol to report the number of f=
rames lost
> on the socket receive queue between any two enqueued frames.  This va=
lue was
> exported via a SOL_PACKET level cmsg.  AFter I completed that work it=
 was
> requested that this feature be generalized so that any datagram orien=
ted socket
> could make use of this option.  As such I've created this patch, It c=
reates a
> new SOL_SOCKET level option called SO_RXQ_OVFL, which when enabled ex=
ports a
> SOL_SOCKET level cmsg that reports the nubmer of times the sk_receive=
_queue
> overflowed between any two given frames.  It also augments the AF_PAC=
KET
> protocol to take advantage of this new feature (as it previously did =
not touch
> sk->sk_drops, which this patch uses to record the overflow count).  T=
ested
> successfully by me.
>=20
> Notes:
>=20
> 1) Unlike my previous patch, this patch simply records the sk_drops v=
alue, which
> is not a number of drops between packets, but rather a total number o=
f drops.
> Deltas must be computed in user space.
>=20
> 2) While this patch currently works with datagram oriented protocols,=
 it will
> also be accepted by non-datagram oriented protocols. I'm not sure if =
thats
> agreeable to everyone, but my argument in favor of doing so is that, =
for those
> protocols which aren't applicable to this option, sk_drops will alway=
s be zero,
> and reporting no drops on a receive queue that isn't used for those
> non-participating protocols seems reasonable to me.  This also saves =
us having
> to code in a per-protocol opt in mechanism.
>=20
> 3) This applies cleanly to net-next assuming that commit
> 977750076d98c7ff6cbda51858bb5a5894a9d9ab (my af packet cmsg patch) is=
 reverted
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

I read your patch and found one error (at the very end)

=46eel free to resubmit with my

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

> =20
> +inline void sock_recv_drops(struct msghdr *msg, struct sock *sk, str=
uct sk_buff *skb)
> +{
> +	if (sock_flag(sk, SOCK_RXQ_OVFL) && skb && skb->dropcount)
> +		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL,
> +			sizeof(__u32), &skb->dropcount);
> +}
> +
> +void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
> +	struct sk_buff *skb)
> +{
> +	sock_recv_timestamp(msg, sk, skb);
> +	sock_recv_drops(msg, sk, skb);


> +	put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL, sizeof(__u32), &skb->dropcou=
nt);
It's already part of sock_recv_drops()


> +}
> +EXPORT_SYMBOL_GPL(sock_recv_ts_and_drops);
> +

