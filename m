From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 21:29:09 -0800
Message-ID: <20090131212909.3ce7a28a@extreme>
References: <20090130112125.GA9908@ioremap.net>
	<20090130125337.GA7155@gondor.apana.org.au>
	<20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com>
Reply-To: Fedora/Linux Management Tools <et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <498349F7.4050300-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/et-mgmt-tools>
List-Post: <mailto:et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Help: <mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=subscribe>
Sender: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Errors-To: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Jan 2009 19:41:59 +0100
Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org> wrote:

> Stephen Hemminger a =C3=A9crit :
> > On Fri, 30 Jan 2009 23:53:37 +1100
> > Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> wrote:
> >=20
> >> Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org> wrote:
> >>> So it is not explicit bind call, but port autoselection in the
> >>> connect(). Can you check what errno is returned?
> >>> Did I understand it right, that connect fails, you try different
> >>> address, but then suddenly all those sockets become 'alive'?
> >> Yes, I think a good strace vs. a bad strace would be really helpful
> >> in these cases.
> >>
> >> Thanks,
> >=20
> > I have the strace but it comes up no different.
> > What is different is that in the broken case (net-next), I see
> > IPV6 being used:
> >=20
> > State      Recv-Q Send-Q      Local Address:Port          Peer Addres=
s:Port  =20
> > ESTAB      23769  0        ::ffff:127.0.0.1:5900      ::ffff:127.0.0.=
1:55987  =20
> > ESTAB      0      0               127.0.0.1:55987            127.0.0.=
1:5900
> >=20
> > and in the working case (2.6.29-rc3), IPV4 is being used
> > State      Recv-Q Send-Q      Local Address:Port          Peer Addres=
s:Port  =20
> > ESTAB      0      0               127.0.0.1:58894            127.0.0.=
1:5901   =20
> > ESTAB      0      0               127.0.0.1:5901             127.0.0.=
1:58894=20
> >=20
>=20
> Reviewing commit a9d8f9110d7e953c2f2b521087a4179677843c2a
>=20
> I see use of a hashinfo->bsockets field that :
>=20
> - lacks proper lock/synchronization
> - suffers from cache line ping pongs on SMP
>=20
> Also there might be a problem at line 175
>=20
> if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN && --attempts >=3D 0) =
{=20
> 	spin_unlock(&head->lock);
> 	goto again;
>=20
> If we entered inet_csk_get_port() with a non null snum, we can "goto ag=
ain"
> while it was not expected.
>=20
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
> index df8e72f..752c6b2 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -172,7 +172,8 @@ tb_found:
>  		} else {
>  			ret =3D 1;
>  			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
> -				if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN && --attempts >=3D=
 0) {
> +				if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN &&
> +					smallest_size =3D=3D -1 &&  --attempts >=3D 0) {
>  					spin_unlock(&head->lock);
>  					goto again;
>  				}
>=20
>=20

That didn't fix it.
