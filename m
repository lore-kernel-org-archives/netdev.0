From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Mon, 28 May 2012 18:14:29 +0200
Message-ID: <4FC3A465.4030203@uclouvain.be>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:32812 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab2E1QOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 12:14:35 -0400
In-Reply-To: <20120528115102.12068.79994.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 05/28/2012 01:52 PM, Jesper Dangaard Brouer wrote:
> The following series is a RFC (Request For Comments) for implementing
> a faster and parallel handling of TCP SYN connections, to mitigate SY=
N
> flood attacks.  This is against DaveM's net (f0d1b3c2bc), as net-next
> is closed, as DaveM has mentioned numerous times ;-)
>=20
> Only IPv4 TCP is handled here. The IPv6 TCP code also need to be
> updated, but I'll deal with that part after we have agreed on a
> solution for IPv4 TCP.
>=20
>  Patch 1/2: Is a cleanup, where I split out the SYN cookie handling
>   from tcp_v4_conn_request() into tcp_v4_syn_conn_limit().
>=20
>  Patch 2/2: Move tcp_v4_syn_conn_limit() outside bh_lock_sock() in
>   tcp_v4_rcv().  I would like some input on, (1) if this safe without
>   the lock, (2) if we need to do some sock lookup, before calling
>   tcp_v4_syn_conn_limit() (Christoph Paasch
>   <christoph.paasch@uclouvain.be> mentioned something about SYN
>   retransmissions)

Concerning (1):
I think, there are places where you may have troube because you don't
hold the lock.
E.g., in tcp_make_synack (called by tcp_v4_send_synack from your
tcp_v4_syn_conn_limit) there is:

if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
	(req->window_clamp > tcp_full_space(sk) ||
	 req->window_clamp =3D=3D 0))
	req->window_clamp =3D tcp_full_space(sk);

Thus, tcp_full_space(sk) may have different values between the check an=
d
setting req->window_clamp.


Concerning (2):

Imagine, a SYN coming in, when the reqsk-queue is not yet full. A
request-sock will be added to the reqsk-queue. Then, a retransmission o=
f
this SYN comes in and the queue got full by the time. This time
tcp_v4_syn_conn_limit will do syn-cookies and thus generate a different
seq-number for the SYN/ACK.


But I don't see how you could fix these issues in your proposed framewo=
rk.

Cheers,
Christoph

>=20
> ---
>=20
> Jesper Dangaard Brouer (2):
>       tcp: Early SYN limit and SYN cookie handling to mitigate SYN fl=
oods
>       tcp: extract syncookie part of tcp_v4_conn_request()
>=20
>=20
>  net/ipv4/tcp_ipv4.c |  131 +++++++++++++++++++++++++++++++++++++++++=
+---------
>  1 files changed, 107 insertions(+), 24 deletions(-)
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=C3=A9 Catholique de Louvain
--=20
