From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
	(v2)
Date: Fri, 9 Oct 2009 19:21:40 -0400
Message-ID: <20091009232140.GA31403@hmsreliant.think-freely.org>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <20091009193515.GA28196@hmsreliant.think-freely.org> <4ACFABAE.5050003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60679 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761567AbZJIXWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 19:22:25 -0400
Content-Disposition: inline
In-Reply-To: <4ACFABAE.5050003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2009 at 11:31:26PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>=20
> > =20
> > +extern void __sock_recv_ts_and_drops(struct msghdr *msg, struct so=
ck *sk,
> > +	struct sk_buff *skb);
>=20
> Surely you meant __sock_recv_drops() ? It only deals with drops.
>=20
No, I certainly meant both.  The defintion clearly handles both the tim=
estamp
cmsg and the drops cmsg.  That way we don't need to make two calls in t=
he
receive path for these

>=20
> > +	case SO_RXQ_OVFL:
> > +		v.val =3D sock_flag(sk, SOCK_RXQ_OVFL);
> > +		break;
> > +
>=20
> Hmm, I advise to use v.val =3D !!sock_flag(sk, SOCK_RXQ_OVFL);
> So that application gets 0 or 1, not 0 or some big value.
> Its better because it allows us to change internal SOCK_RXQ_OVFL if n=
ecessary in the future.
>=20
I don't really see any difference, sock_flag is simply a wrapper around
test_bit.  I can change it if you really need, but it just looks like a=
dditional
operations to me

> >  drop_n_acct:
> > -	spin_lock(&sk->sk_receive_queue.lock);
> > -	po->stats.tp_drops++;
> > -	spin_unlock(&sk->sk_receive_queue.lock);
> > +	po->stats.tp_drops =3D atomic_inc_return(&sk->sk_drops);
>=20
> Yes :)
>=20
> >  EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
> > =20
> > +void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
> > +	struct sk_buff *skb)
> > +{
> > +	put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL, sizeof(__u32), &skb->dropc=
ount);
> > +}
> > +EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
> > +
>=20
> Just change the name.
>=20
No.  I'm differentiating from sock_recv_timestamp here, as I'm concerne=
d about
the case in which we enqueue to sk_error_queue.  For those cases, in wh=
ich
recvmsg is called with MSG_ERRQUEUE, I don't think its right to apply a=
 cmsg
based on skb->dropcount, since the frame may have been from a tx path, =
or may
not have had dropcount set in the first place.  timestamp is still reco=
rded
there, but I don't think we should mark the dropcount.

> And is it really too large to be inlined ?
>=20
No, I was just following the style of sock_recv_timestamp. =20

> In the contrary, sock_recv_timestamp() is so large that I suspect
> your sock_recv_ts_and_drops should *not* be inlined, and include inli=
ned versions only :
>=20
> I suggest something more orthogonal like :
>=20
> void inline sock_recv_drops(struct msghdr *msg, struct sock *sk, stru=
ct sk_buff *skb)
> {
> 	if (sock_flag(sk, SOCK_RXQ_OVFL) && skb && skb->dropcount)
> 		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL,
> 			 sizeof(__u32), &skb->dropcount);
> }
>=20
> void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk, stru=
ct sk_buff *skb)
> {
> 	sock_recv_timestamp(msg, sk, skb); // inlined
> 	sock_recv_drops(msg, sk, skb); // inlined
> }
> EXPORT_SYMBOL_GPL(sock_recv_ts_and_drops)
=46ine.
